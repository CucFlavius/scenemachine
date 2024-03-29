local Editor = SceneMachine.Editor;
local FX = SceneMachine.FX;
local Renderer = SceneMachine.Renderer;
local SH = Editor.SceneHierarchy;
local MousePick = Editor.MousePick;
local OP = Editor.ObjectProperties;
local Gizmos = SceneMachine.Gizmos;
local SM = Editor.SceneManager;
local CC = SceneMachine.CameraController;
local PM = Editor.ProjectManager;
local Input = SceneMachine.Input;
local AM = Editor.AnimationManager;
local UI = SceneMachine.UI;
local Resources = SceneMachine.Resources;
local ColorPicker = Editor.ColorPicker;
local L = Editor.localization;
local Actions = SceneMachine.Actions;

Editor.MODE_LOCAL = 1;
Editor.MODE_NETWORK = 2;

Editor.width = 1280;
Editor.height = 720;
Editor.scale = 1.0;
Editor.toolbarHeight = 15 + 30;
Editor.isOpen = false;
Editor.isInitialized = false;
Editor.mode = Editor.MODE_LOCAL;

local c1 = { 0.1757, 0.1757, 0.1875 };
local c2 = { 0.242, 0.242, 0.25 };
local c3 = { 0, 0.4765, 0.7968 };
local c4 = { 0.1171, 0.1171, 0.1171 };

-- Need to start at high so that the editor window displays on top of the spellbar
-- This is a tool not a game so it's fine
Editor.MAIN_FRAME_STRATA = "HIGH";              -- Main window
Editor.SUB_FRAME_STRATA = "DIALOG";             -- Child windows like "Project Manager"
Editor.MESSAGE_BOX_FRAME_STRATA = "FULLSCREEN"; -- Dialogs like "Are you sure you wanna?""

function Editor.Initialize()
    Editor.version = GetAddOnMetadata("scenemachine", "Version");
    
    SceneMachine.Settings.Initialize();
    
    Editor.ui = UI.UI:New();

    if (Editor.isInitialized) then
        return;
    end

    -- pixel perfect multiplier
    Editor.pmult = 1.0;
    local res = GetCVar("gxWindowedResolution")
    if res then
        local w,h = string.match(res, "(%d+)x(%d+)")
        Editor.pmult = (768 / h)
    end

    -- Create all of the UI --
    Editor.CreateMainWindow(1);
    Editor.MainMenu.Create();
    Editor.CreateToolbar();
    Editor.CreateRightPanel(2);
    Editor.CreateLeftPanel(2);
    Editor.CreateBottomPanel(2);
    Editor.ProjectManager.CreateWindow();
    MousePick.Initialize();
    ColorPicker.Initialize(1, 0, 0);

    -- Create Scene manager
    local sceneX = scenemachine_settings.leftPanelW;
    local sceneY = -(Editor.toolbarHeight + 6);
    local sceneW = Editor.width - (scenemachine_settings.rightPanelW + scenemachine_settings.leftPanelW);
    local sceneH = Editor.height - (Editor.toolbarHeight + scenemachine_settings.animationManagerH + 6);
    Editor.SceneManager.Create(sceneX, sceneY, sceneW, sceneH, SceneMachine.mainWindow:GetFrame(), 2);

    -- Create minimap icon --
    local LDB = LibStub("LibDataBroker-1.1", true)
    local ldbIcon = LibStub("LibDBIcon-1.0", true)

    local SceneMachineMinimapBtn = LDB:NewDataObject("SceneMachine", {
        type = "launcher",
        text = "SceneMachine",
        icon = Resources.textures["Icon32"],
        OnClick = function(_, button)
            if button == "LeftButton" then Editor.Toggle() end
            if button == "RightButton" then Editor.ResetWindow(); Editor.SetScale(90); end
        end,
        OnTooltipShow = function(tt)
            tt:AddLine("SceneMachine\n- Click to open\n- Right click to reset window")
        end,
    });

    ldbIcon:Register("SceneMachine", SceneMachineMinimapBtn, scenemachine_settings)

    -- Keybinds --
    SceneMachine.Input.AddKeyBind("W", function() CC.Action.MoveForward = true end, function() CC.Action.MoveForward = false end);
    SceneMachine.Input.AddKeyBind("S", function() CC.Action.MoveBackward = true end, function() CC.Action.MoveBackward = false end);
    SceneMachine.Input.AddKeyBind("A", function() CC.Action.TurnLeft = true end, function() CC.Action.TurnLeft = false end);
    SceneMachine.Input.AddKeyBind("D", function() CC.Action.TurnRight = true end, function() CC.Action.TurnRight = false end);
    SceneMachine.Input.AddKeyBind("Q", function() CC.Action.StrafeLeft = true end, function() CC.Action.StrafeLeft = false end);
    SceneMachine.Input.AddKeyBind("E", function() CC.Action.StrafeRight = true end, function() CC.Action.StrafeRight = false end);
    SceneMachine.Input.AddKeyBind("SPACE", function() CC.Action.MoveUp = true end, function() CC.Action.MoveUp = false end);
    SceneMachine.Input.AddKeyBind("X", function() CC.Action.MoveDown = true end, function() CC.Action.MoveDown = false end);
	SceneMachine.Input.AddKeyBind("Z", function() 
        if (SceneMachine.Input.ControlModifier) then
            Editor.Undo();
        end
    end);
    SceneMachine.Input.AddKeyBind("Y", function()
        if (SceneMachine.Input.ControlModifier) then
            Editor.Redo();
        end
    end);
    SceneMachine.Input.AddKeyBind("LSHIFT", function() 
        CC.Action.ShiftSpeed = true;
        SceneMachine.Input.ShiftModifier = true;
    end,
    function() 
        CC.Action.ShiftSpeed = false;
        SceneMachine.Input.ShiftModifier = false;
    end);
    SceneMachine.Input.AddKeyBind("RSHIFT", function() 
        CC.Action.ShiftSpeed = true;
        SceneMachine.Input.ShiftModifier = true;
    end,
    function() 
        CC.Action.ShiftSpeed = false;
        SceneMachine.Input.ShiftModifier = false;
    end);
    SceneMachine.Input.AddKeyBind("LCTRL", function() 
        SceneMachine.Input.ControlModifier = true;
    end,
    function() 
        SceneMachine.Input.ControlModifier = false;
    end);
    SceneMachine.Input.AddKeyBind("RCTRL", function() 
        SceneMachine.Input.ControlModifier = true;
    end,
    function() 
        SceneMachine.Input.ControlModifier = false;
    end);
    SceneMachine.Input.AddKeyBind("DELETE",function()
        if (Editor.ui.focused == false) then
            Editor.DeleteLastSelected();
        end
    end);
    SceneMachine.Input.AddKeyBind("DELETE",function()
        if (Editor.ui.focused == false) then
            Editor.DeleteLastSelected();
        end
    end);
    SceneMachine.Input.AddKeyBind("F",function() CC.FocusObjects(SM.selectedObjects); end);
    SceneMachine.Input.AddKeyBind("1", function() Gizmos.activeTransformGizmo = 0; end);
    SceneMachine.Input.AddKeyBind("2", function() Gizmos.activeTransformGizmo = 1; end);
    SceneMachine.Input.AddKeyBind("3", function() Gizmos.activeTransformGizmo = 2; end);
    SceneMachine.Input.AddKeyBind("4", function() Gizmos.activeTransformGizmo = 3; end);

    -- load saved variables (this is safe to do because Editor.Initialize() is done on ADDON_LOADED)
    Editor.ProjectManager.LoadSavedData();

    SceneMachine.mainWindow:Hide();
    Editor.isInitialized = true;

    -- open if it was left open
    if (scenemachine_settings.editor_is_open) then
        Editor.Show();
    end

    Editor.RefreshActionToolbar();
end

function Editor.Update()
    Editor.ui:Update();
    if (ColorPicker.enabled) then
        ColorPicker.Update();
    end
end

function Editor.CreateToolbar()
    local toolbar = UI.Toolbar:New(0, -15, Editor.width, 30, SceneMachine.mainWindow:GetFrame(), SceneMachine.mainWindow, Resources.iconData["MainToolbar"]);
    toolbar:SetFrameLevel(2);
    Editor.mainToolbar = toolbar;
    Editor.mainToolbar.transformGroup = toolbar:CreateGroup(0, 0, Editor.width, 30,
        {
            { type = "DragHandle" },
            {
                type = "Button", name = "Project", icon = toolbar:GetIcon("projects"), action = function(self) Editor.ProjectManager.OpenWindow() end,
                tooltip = L["EDITOR_TOOLBAR_TT_OPEN_PROJECT_MANAGER"],
            },
            {
                type = "Dropdown", name = "ProjectList", width = 200, options = {}, action = function(index) Editor.ProjectManager.LoadProjectByIndex(index); end,
                tooltip = L["EDITOR_TOOLBAR_TT_PROJECT_LIST"],
            },
            { type = "Separator" },
            {
                type = "Button", name = "Undo", icon = toolbar:GetIcon("undo"), action = function(self) Editor.Undo() end,
                tooltip = L["EDITOR_TOOLBAR_TT_UNDO"],
            },
            {
                type = "Button", name = "Redo", icon = toolbar:GetIcon("redo"), action = function(self) Editor.Redo() end,
                tooltip = L["EDITOR_TOOLBAR_TT_REDO"],
            },
            { type = "Separator" },
            {
                type = "Button", name = "Select", icon = toolbar:GetIcon("select"), action = function(self) Gizmos.activeTransformGizmo = 0; end,
                tooltip = L["EDITOR_TOOLBAR_TT_SELECT_TOOL"],
            },
            {
                type = "Button", name = "Move", icon = toolbar:GetIcon("move"), action = function(self) Gizmos.activeTransformGizmo = 1; end,
                tooltip = L["EDITOR_TOOLBAR_TT_MOVE_TOOL"],
            },
            {
                type = "Button", name = "Rotate", icon = toolbar:GetIcon("rotate"), action = function(self) Gizmos.activeTransformGizmo = 2; end,
                tooltip = L["EDITOR_TOOLBAR_TT_ROTATE_TOOL"],
            },
            {
                type = "Button", name = "Scale", icon = toolbar:GetIcon("scale"), action = function(self) Gizmos.activeTransformGizmo = 3; end,
                tooltip = L["EDITOR_TOOLBAR_TT_SCALE_TOOL"],
            },
            { type = "Separator" },
            {
                type = "Toggle", name = "PivotSpace", iconOn = toolbar:GetIcon("localpivot"), iconOff = toolbar:GetIcon("worldpivot"),
                action = function(self, on) if (on) then Gizmos.space = 1; else Gizmos.space = 0; end end,
                default = true, tooltips = { L["EDITOR_TOOLBAR_TT_PIVOT_LOCAL_SPACE"], L["EDITOR_TOOLBAR_TT_PIVOT_WORLD_SPACE"] },
            },
            {
                type = "Toggle", name = "PivotLocation", iconOn = toolbar:GetIcon("centerpivot"), iconOff = toolbar:GetIcon("basepivot"),
                action = function(self, on) if (on) then Editor.SetPivotMode(0); else Editor.SetPivotMode(1); end end,
                default = true, tooltips = { L["EDITOR_TOOLBAR_TT_PIVOT_CENTER"], L["EDITOR_TOOLBAR_TT_PIVOT_BASE"] },
            },
            {
                type = "Toggle", name = "MultiTransform", iconOn = toolbar:GetIcon("together"), iconOff = toolbar:GetIcon("individual"),
                action = function(self, on) if (on) then Editor.SetMultiTransformMode(0); else Editor.SetMultiTransformMode(1); end end,
                default = true, tooltips = { L["EDITOR_TOOLBAR_TT_MULTITRANSFORM_TOGETHER"], L["EDITOR_TOOLBAR_TT_MULTITRANSFORM_INDIVIDUAL"] },
            },
            { type = "DragHandle" },
            {
                type = "Button", name = "AddCamera", icon = toolbar:GetIcon("addcamera"), action = function(self) SM.CreateCamera(); end,
                tooltip = L["EDITOR_TOOLBAR_TT_CREATE_CAMERA"],
            },
            {
                type = "Button", name = "AddCharacter", icon = toolbar:GetIcon("addcharacter"), action = function(self) SM.CreateCharacter(0, 0, 0); end,
                tooltip = L["EDITOR_TOOLBAR_TT_CREATE_CHARACTER"],
            },
        }
    );

    Editor.mainToolbar.transformGroup:SetFrameLevel(3);
end

function Editor.RefreshProjectsDropdown()
    local projectNames = {}
    local selectedName = "";
    
    if (Editor.ProjectManager.currentProject) then
        for v in pairs(Editor.ProjectManager.projects) do
            projectNames[#projectNames + 1] = Editor.ProjectManager.projects[v].name;

            if (Editor.ProjectManager.currentProject.ID == v) then
                selectedName = Editor.ProjectManager.projects[v].name;
            end
        end
    end
    
    for c = 1, #Editor.mainToolbar.transformGroup.components, 1 do
        local component = Editor.mainToolbar.transformGroup.components[c];

        if (component.type == "Dropdown") then
            if (component.name == "ProjectList") then
                Editor.mainToolbar.transformGroup.components[c]:SetOptions(projectNames);
                Editor.mainToolbar.transformGroup.components[c]:ShowSelectedName(selectedName);
            end
        end
    end
end

function Editor.Show()
    SceneMachine.mainWindow:Show();
    local screenHeight = GetScreenHeight();

    if (SceneMachine.mainWindow:GetTop() + 20 > screenHeight) then
        Editor.ResetWindow();
    end

    --Editor.SetScale(scenemachine_settings.editor_scale);
    Editor.scale = scenemachine_settings.editor_scale / 100 * (1 / UIParent:GetScale());
    SceneMachine.mainWindow:SetScale(Editor.scale);

    scenemachine_settings.editor_is_open = true;
    Editor.isOpen = true;
end

function Editor.Hide()
    SceneMachine.mainWindow:Hide();
    --Input.KeyboardListener:SetPropagateKeyboardInput(true);
    scenemachine_settings.editor_is_open = false;
    Editor.isOpen = false;
end

function Editor.Toggle()
    if (Editor.isOpen) then
        Editor.Hide();
    else
        Editor.Show();
    end
end

function Editor.DeleteLastSelected()
    if (Editor.lastSelectedType == "obj") then
        local complexObject = false;
        for i = 1, #SM.selectedObjects, 1 do
            if (SM.ObjectHasTrack(SM.selectedObjects[i])) then
                complexObject = true;
            end
        end

        if (complexObject) then
            Editor.OpenMessageBox(SceneMachine.mainWindow:GetFrame(), L["EDITOR_MSG_DELETE_OBJECT_TITLE"], L["EDITOR_MSG_DELETE_OBJECT_MESSAGE"],
            true, true, function() SM.DeleteObjects(SM.selectedObjects); end, function() end);
        else
            SM.DeleteObjects(SM.selectedObjects);
        end

    elseif (Editor.lastSelectedType == "track") then
        local hasAnims = AM.TrackHasAnims(AM.selectedTrack);
        local hasKeyframes = AM.TrackHasKeyframes(AM.selectedTrack);
        local msgTitle = L["EDITOR_MSG_DELETE_TRACK_TITLE"];
        local msgText;

        if (hasAnims and hasKeyframes) then
            msgText = L["EDITOR_MSG_DELETE_TRACK_A_K_MESSAGE"];
        elseif (hasAnims) then
            msgText = L["EDITOR_MSG_DELETE_TRACK_A_MESSAGE"];
        elseif (hasKeyframes) then
            msgText = L["EDITOR_MSG_DELETE_TRACK_K_MESSAGE"];
        end

        if (hasAnims or hasKeyframes) then
            Editor.OpenMessageBox(SceneMachine.mainWindow:GetFrame(), msgTitle, msgText, true, true, function()
                local obj = AM.GetObjectOfTrack(AM.selectedTrack);
                AM.RemoveTracks({ AM.selectedTrack });
                SM.SelectObject(obj);
            end, function() end);
        else
            local obj = AM.GetObjectOfTrack(AM.selectedTrack);
            AM.RemoveTracks({ AM.selectedTrack });
            SM.SelectObject(obj);
        end
    elseif (Editor.lastSelectedType == "anim") then
        AM.RemoveAnim(AM.selectedTrack, AM.selectedAnim);
    elseif (Editor.lastSelectedType == "key") then
        AM.RemoveKeys(AM.selectedTrack, AM.selectedKeys);
    end
end

function Editor.SetScale(percent)
    local n = percent / 100;
    Editor.scale = n * (1 / UIParent:GetScale());
    SceneMachine.mainWindow:SetScale(Editor.scale);
    scenemachine_settings.editor_scale = percent;

    local screenW = GetScreenWidth();
    local screenH = GetScreenHeight();
    --local aspect = screenW / screenH;
    local maxW = screenW - 50;
    local maxH = screenH - 50;
    local w = min(maxW, SceneMachine.mainWindow:GetWidth());
    local h = min(maxH, SceneMachine.mainWindow:GetHeight());
    SceneMachine.mainWindow:SetSize(w / Editor.scale, h / Editor.scale);
end

function Editor.ResetWindow()
    SceneMachine.mainWindow:ClearAllPoints();
    SceneMachine.mainWindow:SetPoint("CENTER", nil, "CENTER", 0, 0);
    SceneMachine.mainWindow:SetSize(Editor.width, Editor.height);
end

function Editor.CreateMainWindow(startLevel)
    local x = math.floor(Editor.width / 2);
    local y = math.floor(Editor.height / 2);
    local w = Editor.width;
    local h = Editor.height;
    -- Window:New(x, y, w, h, parent, point, parentPoint, title)
	SceneMachine.mainWindow = UI.Window:New(x, y, w, h, UIParent, "TOPLEFT", "TOPLEFT", L["ADDON_NAME"]);
    SceneMachine.mainWindow.closeButton:SetScript("OnClick", function() Editor.Hide(); end);
	SceneMachine.mainWindow:SetFrameStrata(Editor.MAIN_FRAME_STRATA);
    SceneMachine.mainWindow:SetScale(Editor.scale);
    SceneMachine.mainWindow.titleBar_text:SetJustifyH("LEFT");
    SceneMachine.mainWindow.titleBar_text:ClearAllPoints();
    SceneMachine.mainWindow.titleBar_text:SetPoint("LEFT", 25, 0);
    SceneMachine.mainWindow:SetFrameLevel(startLevel);

    SceneMachine.mainWindow:GetFrame():SetResizeBounds(640, 480, 1920, 1080);

    SceneMachine.mainWindow.TitleBarIcon = UI.ImageBox:New(5/2, -5/2, 15, 15, SceneMachine.mainWindow.titleBar, "TOPLEFT", "TOPLEFT", Resources.textures["Icon32"]);
	SceneMachine.mainWindow.TitleBarIcon:SetFrameLevel(startLevel + 1);
end

function Editor.CreateRightPanel(startLevel)
    local rightPanel = UI.Rectangle:New(0, -Editor.toolbarHeight, scenemachine_settings.rightPanelW, Editor.height - Editor.toolbarHeight, SceneMachine.mainWindow:GetFrame(), "TOPRIGHT", "TOPRIGHT", 0.1171, 0.1171, 0.1171, 1);
    rightPanel:SetPoint("BOTTOMRIGHT", SceneMachine.mainWindow:GetFrame(), "BOTTOMRIGHT", 0, 0);
    rightPanel:SetFrameLevel(startLevel);
    rightPanel.frame:SetResizeBounds(200, 100, 650, 200);
    rightPanel.frame:SetResizable(true);
    rightPanel.frame:SetUserPlaced(true);

    Editor.verticalSeparatorR = UI.Rectangle:New(0, 0, 6, 310, rightPanel:GetFrame(), "TOPLEFT", "TOPLEFT", 1,1,1,0);
    Editor.verticalSeparatorR:SetPoint("BOTTOMLEFT", rightPanel:GetFrame(), "BOTTOMLEFT", 0, 0);
    Editor.verticalSeparatorR:SetFrameLevel(100);
    Editor.verticalSeparatorR:GetFrame():EnableMouse(true);
    Editor.verticalSeparatorR:GetFrame():RegisterForDrag("LeftButton");
    Editor.verticalSeparatorR:GetFrame():SetScript("OnDragStart", function()
        rightPanel.frame:StartSizing("LEFT");
        SetCursor(Resources.textures["CursorResizeH"]);
    end);
	Editor.verticalSeparatorR:GetFrame():SetScript("OnDragStop", function()
        scenemachine_settings.rightPanelW = SceneMachine.mainWindow:GetRight() - rightPanel:GetLeft();
        rightPanel.frame:StopMovingOrSizing();
        rightPanel:SetPoint("TOPRIGHT", SceneMachine.mainWindow:GetFrame(), "TOPRIGHT", 0, -Editor.toolbarHeight);
        rightPanel:SetPoint("BOTTOMRIGHT", SceneMachine.mainWindow:GetFrame(), "BOTTOMRIGHT", 0, 0);
        ResetCursor();
    end);
    Editor.verticalSeparatorR:GetFrame():SetScript('OnEnter', function() SetCursor(Resources.textures["CursorResizeH"]); end)
    Editor.verticalSeparatorR:GetFrame():SetScript('OnLeave', function() ResetCursor(); end)
    
    local edge = 10;
    local tilesGroup = Editor.CreateGroup("Asset Explorer", Editor.height - Editor.toolbarHeight - edge , rightPanel:GetFrame(), startLevel + 1);

    Editor.AssetBrowser.Create(tilesGroup, scenemachine_settings.rightPanelW - 12, Editor.height - Editor.toolbarHeight - edge -(Editor.toolbarHeight / 2), startLevel + 4);
end

function Editor.CreateLeftPanel(startLevel)
    local leftPanel = UI.Rectangle:New(0, -Editor.toolbarHeight, scenemachine_settings.leftPanelW, 310, SceneMachine.mainWindow:GetFrame(), "TOPLEFT", "TOPLEFT", c4[1], c4[2], c4[3], 1);
    leftPanel:SetPoint("BOTTOMLEFT", SceneMachine.mainWindow:GetFrame(), "BOTTOMLEFT", 0, 0);
    leftPanel:SetFrameLevel(startLevel);

	leftPanel.frame:SetResizeBounds(200, 100, 600, 200);
    leftPanel.frame:SetResizable(true);
    leftPanel.frame:SetUserPlaced(true);
    
    Editor.verticalSeparatorL = UI.Rectangle:New(0, 0, 6, 310, leftPanel:GetFrame(), "TOPRIGHT", "TOPRIGHT", 1,1,1,0);
    Editor.verticalSeparatorL:SetPoint("BOTTOMRIGHT", leftPanel:GetFrame(), "BOTTOMRIGHT", 0, 0);
    Editor.verticalSeparatorL:SetFrameLevel(100);
    Editor.verticalSeparatorL:GetFrame():EnableMouse(true);
    Editor.verticalSeparatorL:GetFrame():RegisterForDrag("LeftButton");
    Editor.verticalSeparatorL:GetFrame():SetScript("OnDragStart", function()
        leftPanel.frame:StartSizing("RIGHT");
        SetCursor(Resources.textures["CursorResizeH"]);
    end);
	Editor.verticalSeparatorL:GetFrame():SetScript("OnDragStop", function()
        scenemachine_settings.leftPanelW = leftPanel:GetRight() - SceneMachine.mainWindow:GetLeft();
        leftPanel.frame:StopMovingOrSizing();
        leftPanel:SetPoint("TOPLEFT", SceneMachine.mainWindow:GetFrame(), "TOPLEFT", 0, -Editor.toolbarHeight);
        leftPanel:SetPoint("BOTTOMLEFT", SceneMachine.mainWindow:GetFrame(), "BOTTOMLEFT", 0, 0);
        ResetCursor();
    end);
    Editor.verticalSeparatorL:GetFrame():SetScript('OnEnter', function() SetCursor(Resources.textures["CursorResizeH"]); end)
    Editor.verticalSeparatorL:GetFrame():SetScript('OnLeave', function() ResetCursor(); end)

    OP.CreatePanel(scenemachine_settings.leftPanelW, scenemachine_settings.propertiesPanelH, c1, c2, c3, c4, leftPanel, startLevel + 2);
    SH.CreatePanel(scenemachine_settings.leftPanelW, 350, leftPanel, startLevel + 2);
end

function Editor.CreateBottomPanel(startLevel)
    local bottomPanel = UI.Rectangle:New(0, 0, Editor.width - (scenemachine_settings.rightPanelW + scenemachine_settings.leftPanelW),
        scenemachine_settings.animationManagerH, Editor.verticalSeparatorL:GetFrame(), "BOTTOMLEFT", "BOTTOMRIGHT", c4[1], c4[2], c4[3], 1);
    bottomPanel:SetPoint("BOTTOMRIGHT", Editor.verticalSeparatorR:GetFrame(), "BOTTOMLEFT", 0, 0);
    bottomPanel:SetFrameLevel(startLevel);
    bottomPanel.frame:SetResizable(true);
    bottomPanel.frame:SetUserPlaced(true);
    bottomPanel.frame:SetResizeBounds(120, 120, 800, 800);

    Editor.horizontalSeparator = UI.Rectangle:New(0, 6, 6, 6, bottomPanel:GetFrame(), "TOPLEFT", "TOPLEFT", 1,1,1,0);
    Editor.horizontalSeparator:SetPoint("TOPRIGHT", bottomPanel:GetFrame(), "TOPRIGHT", 0, 0);
    Editor.horizontalSeparator:SetFrameLevel(100);
    Editor.horizontalSeparator:GetFrame():EnableMouse(true);
    Editor.horizontalSeparator:GetFrame():RegisterForDrag("LeftButton");
    Editor.horizontalSeparator:GetFrame():SetScript("OnDragStart", function()
        bottomPanel.frame:StartSizing("TOP");
        SetCursor(Resources.textures["CursorResizeV"]);
    end);
	Editor.horizontalSeparator:GetFrame():SetScript("OnDragStop", function()
        scenemachine_settings.animationManagerH = (bottomPanel:GetTop()) - SceneMachine.mainWindow:GetBottom();
        bottomPanel.frame:StopMovingOrSizing();
        bottomPanel:SetPoint("BOTTOMLEFT", Editor.verticalSeparatorL:GetFrame(), "BOTTOMRIGHT", 0, 0);
        bottomPanel:SetPoint("BOTTOMRIGHT", Editor.verticalSeparatorR:GetFrame(), "BOTTOMLEFT", 0, 0);
        ResetCursor();
    end);
    Editor.horizontalSeparator:GetFrame():SetScript('OnEnter', function() SetCursor(Resources.textures["CursorResizeV"]); end)
    Editor.horizontalSeparator:GetFrame():SetScript('OnLeave', function() ResetCursor(); end)

    -- Create Animation manager
    --local animX = leftPanelWidth;
    --local animY = -(Editor.toolbarHeight + 6) - Renderer.h;
    AM.CreateAnimationManager(0, 0, Editor.width - (scenemachine_settings.rightPanelW + scenemachine_settings.leftPanelW), scenemachine_settings.animationManagerH, bottomPanel:GetFrame(), startLevel);
end

function Editor.CreateGroup(name, groupHeight, groupParent, startLevel)
    local groupBG = UI.Rectangle:New(6, -6, scenemachine_settings.leftPanelW - 12, groupHeight, groupParent, "TOPLEFT", "TOPLEFT",  c1[1], c1[2], c1[3], 1);
    groupBG:SetPoint("BOTTOMRIGHT", groupParent, "BOTTOMRIGHT", -6, 6);
    groupBG:SetFrameLevel(startLevel);
    local groupTitleText = UI.Label:New(0, 0, scenemachine_settings.leftPanelW - 30, 20, groupBG:GetFrame(), "TOPLEFT", "TOPLEFT", "   " .. name, 9);
    groupTitleText:SetPoint("TOPRIGHT", groupBG:GetFrame(), "TOPRIGHT", 0, 0);
    groupTitleText:SetFrameLevel(startLevel + 1);
    local groupContent = UI.Rectangle:New(0, -20, scenemachine_settings.leftPanelW - 12, groupHeight - 20, groupBG:GetFrame(), "TOPLEFT", "TOPLEFT", 0.1445, 0.1445, 0.1445, 1);
    groupContent:SetPoint("BOTTOMRIGHT", groupBG:GetFrame(), "BOTTOMRIGHT", 0, 0);
    groupContent:SetFrameLevel(startLevel + 2);
    return groupContent:GetFrame();
end

function SceneMachine.CreateStatsFrame()
	SceneMachine.StatsFrame = CreateFrame("Frame", nil, Renderer.projectionFrame);
	SceneMachine.StatsFrame:SetPoint("TOPRIGHT", Renderer.projectionFrame, "TOPRIGHT", 0, 0);
	SceneMachine.StatsFrame:SetWidth(200);
	SceneMachine.StatsFrame:SetHeight(200);
	SceneMachine.StatsFrame.text = SceneMachine.StatsFrame:CreateFontString(nil, "BACKGROUND", "GameTooltipText");
	SceneMachine.StatsFrame.text:SetFont(Resources.defaultFont, 9, "NORMAL");

	SceneMachine.StatsFrame.text:SetPoint("TOPRIGHT",-5,-5);
	SceneMachine.StatsFrame.text:SetJustifyV("TOP");
	SceneMachine.StatsFrame.text:SetJustifyH("LEFT");
	SceneMachine.StatsFrame:Show();
end

function Editor.Save()
    scenemachine_projects = Editor.ProjectManager.projects;

    -- ask for restart / or restart --
    Editor.OpenMessageBox(SceneMachine.mainWindow:GetFrame(),  L["EDITOR_MSG_SAVE_TITLE"], L["EDITOR_MSG_SAVE_MESSAGE"], true, true, function() ReloadUI(); end, function() end);
end

function Editor.ShowProjectManager()
    Editor.ProjectManager.OpenWindow();
end

function Editor.ShowImportExportWindow(action, text)
    -- create
    if (not Editor.importExportWindow) then
        local xOffset, yOffset = 0, 0;
        local windowWidth, windowHeight = 400, 400;

        Editor.importExportWindow = UI.Window:New(xOffset, yOffset, windowWidth, windowHeight, SceneMachine.mainWindow:GetFrame(), "CENTER", "CENTER", L["EDITOR_IMPORT_EXPORT_WINDOW_TITLE"]);
        Editor.importExportWindow:SetFrameStrata(Editor.SUB_FRAME_STRATA);
        Editor.importExportWindow:MakeWholeWindowDraggable();

        local textHeight = 9;
        local ebWidth, ebHeight = 390, 390; -- this just gets eaten by the anchors anyways but might as well keep it
        Editor.importExportWindow.editBox = UI.ScrollableTextBox:New(xOffset, yOffset, ebWidth, ebHeight, Editor.importExportWindow:GetFrame(), "TOPLEFT", "TOPLEFT", "", textHeight, nil, true);

        local editBox = Editor.importExportWindow.editBox;
        editBox:SetPoint("BOTTOMRIGHT", Editor.importExportWindow:GetFrame(), 0, 0);
        editBox:SetMultiLine(true);
        editBox:SetMaxLetters(0);
        editBox:SetScript('OnEscapePressed', function()
            editBox:ClearFocus();
            Editor.ui.focused = false;
            editBox:SetText("");
        end);

        local scrollModifier = 3.5; -- textHeight x this modifier will be the scroll step size
        local scrollBox = editBox:GetScrollBox();
        scrollBox:SetInterpolateScroll(true);
        scrollBox:SetPanExtent(textHeight * scrollModifier);

        local resizeButton = Editor.importExportWindow.resizeFrame;
        resizeButton:SetFrameStrata(Editor.SUB_FRAME_STRATA);
        resizeButton:SetFrameLevel(scrollBox:GetFrameLevel() + 1);
    end

    Editor.importExportWindow.editBox:SetScript('OnEnterPressed', function()
        Editor.importExportWindow.editBox:ClearFocus();
        Editor.ui.focused = false;
        Editor.importExportWindow:Hide();
        if (action) then
            action(Editor.importExportWindow.editBox:GetText());
        end
    end);

    Editor.importExportWindow.editBox:SetText(text);
    Editor.importExportWindow:Show();
end

function Editor.OpenQuickTextbox(action, text, title)
    -- create
    if (not Editor.quickTextWindow) then
        local xOffset, yOffset = 10, -10;
        local windowWidth, windowHeight = 400, 60;

        Editor.quickTextWindow = UI.Window:New(xOffset, yOffset, windowWidth, windowHeight, SceneMachine.mainWindow:GetFrame(), "CENTER", "CENTER", L["EDITOR_NAME_RENAME_WINDOW_TITLE"]);
        Editor.quickTextWindow:SetFrameStrata(Editor.SUB_FRAME_STRATA);
        Editor.quickTextWindow:GetFrame():SetResizeBounds(windowWidth - 200, windowHeight, windowWidth + 200, windowHeight);
        Editor.quickTextWindow:MakeWholeWindowDraggable();

        local textHeight = 9;
        local ebWidth, ebHeight = 390, 30; -- this just gets eaten by the anchors anyways but might as well keep it
        Editor.quickTextWindow.editBox = UI.TextBox:New(xOffset, yOffset, ebWidth, ebHeight, Editor.quickTextWindow:GetFrame(), "TOPLEFT", "TOPLEFT", "", textHeight);

        Editor.quickTextWindow.editBox:SetPoint("BOTTOMRIGHT", Editor.quickTextWindow:GetFrame(), -xOffset, -yOffset);
        Editor.quickTextWindow.editBox:SetScript('OnEscapePressed', function()
            Editor.quickTextWindow.editBox:ClearFocus();
            Editor.ui.focused = false;
            Editor.quickTextWindow.editBox:SetText("");
        end);
    end
    
    Editor.quickTextWindow.editBox:SetText(text);

    Editor.quickTextWindow:SetTitleText(title or L["EDITOR_NAME_RENAME_WINDOW_TITLE"]);

    Editor.quickTextWindow.editBox:SetScript('OnEnterPressed', function(self1)
        Editor.quickTextWindow.editBox:ClearFocus();
        Editor.ui.focused = false;
        if (action) then
            action(self1:GetText());
        end
        Editor.quickTextWindow:Hide();
    end);

    Editor.quickTextWindow:Show();
end

function Editor.SetPivotMode(mode)
    Gizmos.pivot = mode;
end

function Editor.SetMultiTransformMode(mode)
    Gizmos.multiTransform = mode;
end

function Editor.OpenContextMenu(x, y)
	local menuOptions = {
        { ["Name"] = L["CM_SELECT"], ["Action"] = function() Gizmos.activeTransformGizmo = 0; end },
        { ["Name"] = L["CM_MOVE"], ["Action"] = function() Gizmos.activeTransformGizmo = 1; end },
        { ["Name"] = L["CM_ROTATE"], ["Action"] = function() Gizmos.activeTransformGizmo = 2; end },
        { ["Name"] = L["CM_SCALE"], ["Action"] = function() Gizmos.activeTransformGizmo = 3; end },
        { ["Name"] = nil },
        { ["Name"] = L["CM_DELETE"], ["Action"] = function() SM.DeleteObjects(SM.selectedObjects); end },
        { ["Name"] = L["CM_HIDE_SHOW"], ["Action"] = function() SM.ToggleObjectsVisibility(SM.selectedObjects); end },
        { ["Name"] = L["CM_FREEZE_UNFREEZE"], ["Action"] = function()
            SM.ToggleObjectsFreezeState(SM.selectedObjects);
            if (#SM.selectedObjects > 0) then
                for i= #SM.selectedObjects, 1, -1 do
                    if (SM.selectedObjects[i].frozen) then
                        table.remove(SM.selectedObjects, i);
                    end
                end
                SH.RefreshHierarchy();
                OP.Refresh();
            end
        end },
        { ["Name"] = L["CM_FOCUS"], ["Action"] = function() CC.FocusObjects(SM.selectedObjects); end },
        { ["Name"] = L["CM_GROUP"], ["Action"] = function() SM.GroupObjects(SM.selectedObjects); end },
	};

    local scale =  SceneMachine.mainWindow:GetEffectiveScale();
    SceneMachine.mainWindow:PopupWindowMenu(x * scale, y * scale, menuOptions);
end

function Editor.OpenMessageBox( window, title, message, hasYesButton, hasNoButton, onYesButton, onNoButton )
    if (not Editor.messageBox) then
        Editor.messageBox = UI.Window:New(0, 0, 300, 150, window, "CENTER", "CENTER", title);
        Editor.messageBox:MakeWholeWindowDraggable();
        Editor.messageBox:SetFrameStrata(Editor.MESSAGE_BOX_FRAME_STRATA);
        Editor.messageBox.textBox = UI.Label:New(0, 10, 280, 100, Editor.messageBox:GetFrame(), "CENTER", "CENTER", message, 10);
        Editor.messageBox.yesButton = UI.Button:New(-75, 10, 50, 25, Editor.messageBox:GetFrame(), "BOTTOMRIGHT", "BOTTOMRIGHT", L["YES"]);
        Editor.messageBox.noButton = UI.Button:New(-20, 10, 50, 25, Editor.messageBox:GetFrame(), "BOTTOMRIGHT", "BOTTOMRIGHT", L["NO"]);
        Editor.messageBox:GetFrame():SetResizable(false);
        Editor.messageBox.resizeFrame:Hide();
    end

    Editor.messageBox:SetParent(window);
    Editor.messageBox:SetTitle(title);
    Editor.messageBox.textBox:SetText(message);

    Editor.messageBox:Show();

    if (hasYesButton) then
        Editor.messageBox.yesButton:Show();
        Editor.messageBox.yesButton:SetScript("OnClick", function (self, button, down)
            Editor.messageBox:Hide();
            if (onYesButton) then
                onYesButton();
            end
        end);
    else
        Editor.messageBox.yesButton:Hide();
    end

    if (hasNoButton) then
        Editor.messageBox.noButton:Show();
        Editor.messageBox.noButton:SetScript("OnClick", function (self, button, down)
            Editor.messageBox:Hide();
            if (onNoButton) then
                onNoButton();
            end
        end);
    else
        Editor.messageBox.noButton:Hide();
    end
end

function Editor.SetMode(mode)
    Editor.mode = mode;

    if (Editor.mode == Editor.MODE_LOCAL) then
        
    elseif (Editor.mode == Editor.MODE_NETWORK) then

    end
end

function Editor.Undo()
    if (not SM.loadedScene) then
        return;
    end
    
    if (SM.loadedScene.actionPointer < 1) then
        return;
    end

    SM.loadedScene.actionPool[SM.loadedScene.actionPointer]:Undo();
    SM.loadedScene.actionPointer = SM.loadedScene.actionPointer - 1;
    SM.loadedScene.actionPointer = max(0, SM.loadedScene.actionPointer);

    Editor.RefreshActionToolbar();
    SH.RefreshHierarchy();
    OP.Refresh();
end

function Editor.Redo()
    if (not SM.loadedScene) then
        return;
    end

    if (SM.loadedScene.actionPointer >= #SM.loadedScene.actionPool) then
        return;
    end

    SM.loadedScene.actionPointer = SM.loadedScene.actionPointer + 1;
    SM.loadedScene.actionPointer = min(#SM.loadedScene.actionPool, SM.loadedScene.actionPointer);
    SM.loadedScene.actionPool[SM.loadedScene.actionPointer]:Redo();

    Editor.RefreshActionToolbar();
    SH.RefreshHierarchy();
    OP.Refresh();
end

function Editor.StartAction(type, ...)
    if (not SM.loadedScene) then
        return;
    end
    --print("Start Action " .. type);

    if (type == Actions.Action.Type.TransformObject) then
        SM.loadedScene.startedAction = Actions.TransformObject:New(...);
    elseif (type == Actions.Action.Type.DestroyObject) then
        SM.loadedScene.startedAction = Actions.DestroyObject:New(...);
    elseif (type == Actions.Action.Type.CreateObject) then
        SM.loadedScene.startedAction = Actions.CreateObject:New(...);
    elseif (type == Actions.Action.Type.DestroyTrack) then
        SM.loadedScene.startedAction = Actions.DestroyTrack:New(...);
    elseif (type == Actions.Action.Type.CreateTrack) then
        SM.loadedScene.startedAction = Actions.CreateTrack:New(...);
    elseif (type == Actions.Action.Type.SceneProperties) then
        SM.loadedScene.startedAction = Actions.SceneProperties:New(...);
    elseif (type == Actions.Action.Type.DestroyTimeline) then
        SM.loadedScene.startedAction = Actions.DestroyTimeline:New(...);
    elseif (type == Actions.Action.Type.CreateTimeline) then
        SM.loadedScene.startedAction = Actions.CreateTimeline:New(...);
    elseif (type == Actions.Action.Type.TimelineProperties) then
        SM.loadedScene.startedAction = Actions.TimelineProperties:New(...);
    elseif (type == Actions.Action.Type.TrackAnimations) then
        SM.loadedScene.startedAction = Actions.TrackAnimations:New(...);
    elseif (type == Actions.Action.Type.TrackKeyframes) then
        SM.loadedScene.startedAction = Actions.TrackKeyframes:New(...);
    elseif (type == Actions.Action.Type.HierarchyChange) then
        SM.loadedScene.startedAction = Actions.HierarchyChange:New(...);
    else
        print ("NYI Editor.StartAction() type:" .. type);
    end
end

function Editor.CancelAction()
    if (not SM.loadedScene) then
        return;
    end

    SM.loadedScene.startedAction = nil;
end

function Editor.FinishAction(...)
    if (not SM.loadedScene) then
        return;
    end

    if (not SM.loadedScene.startedAction) then
        return;
    end

    --print("Finish Action " .. SM.loadedScene.startedAction.type);

    SM.loadedScene.actionPointer = SM.loadedScene.actionPointer + 1;
    SM.loadedScene.startedAction:Finish(...);
    SM.loadedScene.actionPool[SM.loadedScene.actionPointer] = SM.loadedScene.startedAction;
    SM.loadedScene.startedAction = nil;

    -- performing an action has to clear the actionPool after the current action pointer
    for i = #SM.loadedScene.actionPool, SM.loadedScene.actionPointer + 1, -1 do
        table.remove(SM.loadedScene.actionPool, i);
    end

    Editor.RefreshActionToolbar();
end

function Editor.RefreshActionToolbar()
    if (not SM.loadedScene) then
        return;
    end

    local undoVisible = true;
    local redoVisible = true;

    if (#SM.loadedScene.actionPool == 0) then
        undoVisible = false;
        redoVisible = false;
    end

    if (SM.loadedScene.actionPointer < 1) then
        undoVisible = false;
    end

    if (SM.loadedScene.actionPointer >= #SM.loadedScene.actionPool) then
        redoVisible = false;
    end

    for i = 1, #Editor.mainToolbar.transformGroup.components, 1 do
        if (Editor.mainToolbar.transformGroup.components[i].name == "Undo") then
            if (undoVisible) then
                local coords = Editor.mainToolbar:GetIcon("undo")[2];
                Editor.mainToolbar.transformGroup.components[i].icon:SetTexCoords(coords);
                Editor.mainToolbar.transformGroup.components[i].inactive = false;
            else
                local coords = Editor.mainToolbar:GetIcon("undooff")[2];
                Editor.mainToolbar.transformGroup.components[i].icon:SetTexCoords(coords);
                Editor.mainToolbar.transformGroup.components[i].inactive = true;
            end
        end

        if (Editor.mainToolbar.transformGroup.components[i].name == "Redo") then
            if (redoVisible) then
                local coords = Editor.mainToolbar:GetIcon("redo")[2];
                Editor.mainToolbar.transformGroup.components[i].icon:SetTexCoords(coords);
                Editor.mainToolbar.transformGroup.components[i].inactive = false;
            else
                local coords = Editor.mainToolbar:GetIcon("redooff")[2];
                Editor.mainToolbar.transformGroup.components[i].icon:SetTexCoords(coords);
                Editor.mainToolbar.transformGroup.components[i].inactive = true;
            end
        end
    end
end

function Editor.ClearActions()
    if (not SM.loadedScene) then
        return;
    end
    
    for i = 1, #SM.loadedScene.actionPool, 1 do
        SM.loadedScene.actionPool[i] = nil;
    end

    SM.loadedScene.actionPool = {};
    SM.loadedScene.startedAction = nil;
    SM.loadedScene.actionPointer = 0;
    Editor.RefreshActionToolbar();
end

function Editor.PreprocessSavedVars()
    if (not scenemachine_projects) then
        return;
    end

    -- clear runtime data
    for ID in pairs(scenemachine_projects) do
        for s = 1, #scenemachine_projects[ID].scenes, 1 do
            local scene = scenemachine_projects[ID].scenes[s];
            scene.actionPool = nil;
            scene.actionPointer = nil;

            if (scene.objects) then
                for o = 1, #scene.objects, 1 do
                    scene.objects[o].matrix = nil;
                end
            end
        end
    end
end