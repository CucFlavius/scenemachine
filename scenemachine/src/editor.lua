local Editor = SceneMachine.Editor;
local Win = ZWindowAPI;
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

Editor.width = 1280;
Editor.height = 720;
Editor.scale = 1.0;
Editor.toolbarHeight = 15 + 30;
local rightPanelWidth = 300;
local leftPanelWidth = 300;
local bottomPanelHeight = 220;
Editor.isOpen = false;
Editor.isInitialized = false;

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

    scenemachine_settings = scenemachine_settings or {
        minimap_button = minimap_button or {
            minimapPos = minimapPos or 90;
            hide = hide or false;
            lock = lock or true;
        };
        editor_is_open = editor_is_open or false;
    };

    -- Create all of the UI --
    Win.Initialize("Interface\\AddOns\\scenemachine\\src\\Libraries\\ZWindowAPI");
    Editor.CreateMainWindow();
    Editor.MainMenu.Create();
    local toolbar = Editor.Toolbar.Create(0, -15, Editor.width, 30, SceneMachine.mainWindow);
    Editor.mainToolbar = toolbar;
    toolbar.CreateGroup(0, 0, Editor.width, 30, toolbar,
        {
            { type = "DragHandle" },
            { type = "Button", name = "Project", icon = toolbar.getIcon("projects"), action = function(self) Editor.ProjectManager.OpenWindow() end },
            { type = "Dropdown", name = "ProjectList", width = 200, options = {}, action = function(index) Editor.ProjectManager.LoadProjectByIndex(index); end },
            { type = "Separator" },
            { type = "Button", name = "Select", icon = toolbar.getIcon("select"), action = function(self) Gizmos.activeTransformGizmo = 0; end },
            { type = "Button", name = "Move", icon = toolbar.getIcon("move"), action = function(self) Gizmos.activeTransformGizmo = 1; end },
            { type = "Button", name = "Rotate", icon = toolbar.getIcon("rotate"), action = function(self) Gizmos.activeTransformGizmo = 2; end },
            { type = "Button", name = "Scale", icon = toolbar.getIcon("scale"), action = function(self) Gizmos.activeTransformGizmo = 3; end },
            { type = "Separator" },
            { type = "Button", name = "L", icon = toolbar.getIcon("localpivot"), action = function(self) Gizmos.space = 1; print("Local Space"); end },
            { type = "Button", name = "W", icon = toolbar.getIcon("worldpivot"), action = function(self) Gizmos.space = 0; print("World Space"); end },
            { type = "Separator" },
            { type = "Button", name = "Center", icon = toolbar.getIcon("centerpivot"), action = function(self) Gizmos.pivot = 0; print("Pivot Center"); end },
            { type = "Button", name = "Base", icon = toolbar.getIcon("basepivot"), action = function(self) Gizmos.pivot = 1; print("Pivot Base"); end },
            { type = "Separator" },
        }
    );

    Editor.CreateRightPanel();
    Editor.CreateLeftPanel();
    Editor.CreateBottomPanel();
    Editor.ProjectManager.CreateWindow();
    MousePick.Initialize();

    -- Create Scene manager
    local sceneX = leftPanelWidth;
    local sceneY = -(Editor.toolbarHeight + 6);
    local sceneW = Editor.width - (rightPanelWidth + leftPanelWidth);
    local sceneH = Editor.height - (Editor.toolbarHeight + bottomPanelHeight + 6);
    Editor.SceneManager.Create(sceneX, sceneY, sceneW, sceneH, SceneMachine.mainWindow);

    -- Create minimap icon --
    local LDB = LibStub("LibDataBroker-1.1", true)
    local ldbIcon = LibStub("LibDBIcon-1.0", true)

    local SceneMachineMinimapBtn = LDB:NewDataObject("SceneMachine", {
        type = "launcher",
        text = "SceneMachine",
        icon = "Interface\\AddOns\\scenemachine\\static\\textures\\icon32.png",
        OnClick = function(_, button)
            if button == "LeftButton" then Editor.Toggle() end
        end,
        OnTooltipShow = function(tt)
            tt:AddLine("SceneMachine")
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
	SceneMachine.Input.AddKeyBind("LSHIFT", function() 
        CC.Action.ShiftSpeed = true;
        SceneMachine.Input.ShiftModifier = true;
    end,
    function() 
        CC.Action.ShiftSpeed = false;
        SceneMachine.Input.ShiftModifier = false;
    end);
    SceneMachine.Input.AddKeyBind("DELETE",function()
        if (Win.focused == false) then
            SM.DeleteObject(SM.selectedObject);
        end
    end, nil);
    SceneMachine.Input.AddKeyBind("F",function() CC.FocusObject(SM.selectedObject); end, nil);
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
                Editor.mainToolbar.transformGroup.components[c].SetOptions(projectNames);
                Editor.mainToolbar.transformGroup.components[c].ShowSelectedName(selectedName);
            end
        end
    end
end

function Editor.Show()
    SceneMachine.mainWindow:Show();
    local screenHeight = GetScreenHeight();
    --Input.KeyboardListener:SetPropagateKeyboardInput(false);
    Editor.ResetWindow();
    if (SceneMachine.mainWindow:GetTop() + 20 > screenHeight) then
        Editor.ResetWindow();
    end
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
        Editor:Hide();
    else
        Editor:Show();
    end
end

function Editor.SetScale(percent)
    local n = percent / 100;
    Editor.scale = n * (1 / UIParent:GetScale());
    SceneMachine.mainWindow:SetScale(Editor.scale);
end

function Editor.ResetWindow()
    SceneMachine.mainWindow:ClearAllPoints();
    SceneMachine.mainWindow:SetPoint("CENTER", nil, "CENTER", 0, 0);
    SceneMachine.mainWindow:SetSize(Editor.width, Editor.height);

    Editor.SetScale(90);
end

function Editor.CreateMainWindow()
	SceneMachine.mainWindow = Win.CreateWindow(math.floor(Editor.width / 2), math.floor(Editor.height / 2), Editor.width, Editor.height, nil, "TOPLEFT", "TOPLEFT", true, "Scene Machine " .. Editor.version);
    SceneMachine.mainWindow.CloseButton:SetScript("OnClick", function (self, button, down) Editor.Hide(); end)
	SceneMachine.mainWindow:SetFrameStrata(Editor.MAIN_FRAME_STRATA);
    SceneMachine.mainWindow:SetScale(Editor.scale);
	SceneMachine.WINDOW_WIDTH = Editor.width;
	SceneMachine.WINDOW_HEIGHT = Editor.height;
    SceneMachine.mainWindow.TitleBar.text:SetJustifyH("LEFT");
    SceneMachine.mainWindow.TitleBar.text:ClearAllPoints();
    SceneMachine.mainWindow.TitleBar.text:SetPoint("LEFT", 25, 0);
	--SceneMachine.mainWindow:SetIgnoreParentScale(true);		-- This way the camera doesn't get offset when the wow window or UI changes size/aspect
    SceneMachine.mainWindow.texture:SetColorTexture(c4[1], c4[2], c4[3],1);
    SceneMachine.mainWindow.TitleBar.texture:SetColorTexture(c1[1], c1[2], c1[3], 1);
    SceneMachine.mainWindow.CloseButton.ntex:SetColorTexture(c1[1], c1[2], c1[3], 1);
    SceneMachine.mainWindow.CloseButton.htex:SetColorTexture(c2[1], c2[2], c2[3], 1);
    SceneMachine.mainWindow.CloseButton.ptex:SetColorTexture(c3[1], c3[2], c3[3], 1);

    SceneMachine.mainWindow.TitleBarIcon = Win.CreateImageBox(5/2, -5/2, 15, 15, SceneMachine.mainWindow.TitleBar, "TOPLEFT", "TOPLEFT",
	"Interface\\Addons\\scenemachine\\static\\textures\\icon32.png");

    --SceneMachine.mainWindow.ResizeFrame = Win.CreateRectangle(10, -10, 20, 20, SceneMachine.mainWindow, "BOTTOMRIGHT", "BOTTOMRIGHT", 1, 1, 1, 1);
    --SceneMachine.mainWindow.ResizeFrame = Win.CreateButton(10, -10, 20, 20, SceneMachine.mainWindow, "BOTTOMRIGHT", "BOTTOMRIGHT", "", nil, nil, nil)
    --SceneMachine.mainWindow.ResizeFrame:EnableMouse(true);
    --SceneMachine.mainWindow:SetResizable(true)
    --SceneMachine.mainWindow.ResizeFrame:RegisterForDrag("LeftButton");
    --SceneMachine.mainWindow.ResizeFrame:SetScript("OnDragStart", function() SceneMachine.mainWindow:StartSizing("BOTTOMRIGHT"); end);
	--SceneMachine.mainWindow.ResizeFrame:SetScript("OnDragStop", function() SceneMachine.mainWindow:StopMovingOrSizing(); end);
end

function Editor.CreateRightPanel()
    local rightPanel = Win.CreateRectangle(0, -Editor.toolbarHeight/2, rightPanelWidth, Editor.height - Editor.toolbarHeight, SceneMachine.mainWindow, "RIGHT", "RIGHT", c4[1], c4[2], c4[3], 1);
    
    local edge = 10;
    local tilesGroup = Editor.CreateGroup("Asset Explorer", Editor.height - Editor.toolbarHeight - edge , rightPanel);

    Editor.AssetBrowser.Create(tilesGroup, rightPanelWidth - 12, Editor.height - Editor.toolbarHeight - edge -(Editor.toolbarHeight / 2));
end

function Editor.CreateLeftPanel()
    SH.CreatePanel(0, -Editor.toolbarHeight, leftPanelWidth - 12, 350, c4);
    OP.CreatePanel(0, -(Editor.toolbarHeight + 350 + 5), leftPanelWidth - 12, 310, c1, c2, c3, c4);
end

function Editor.CreateBottomPanel()
    local bottomPanel = Win.CreateRectangle(leftPanelWidth, 0, Editor.width - (rightPanelWidth + leftPanelWidth),
        bottomPanelHeight, SceneMachine.mainWindow, "BOTTOMLEFT", "BOTTOMLEFT", c4[1], c4[2], c4[3], 1);

    -- Create Animation manager
    --local animX = leftPanelWidth;
    --local animY = -(Editor.toolbarHeight + 6) - Renderer.h;
    AM.CreateAnimationManager(0, 0, Editor.width - (rightPanelWidth + leftPanelWidth), bottomPanelHeight, bottomPanel);
end

function Editor.CreateGroup(name, groupHeight, groupParent)
    local groupBG = Win.CreateRectangle(6, -6, leftPanelWidth - 12, groupHeight, groupParent, "TOPLEFT", "TOPLEFT",  c1[1], c1[2], c1[3], 1);
    local groupTitleText = Win.CreateTextBoxSimple(0, 0, leftPanelWidth - 30, 20, groupBG, "TOP", "TOP", name, 9);
    local groupContent = Win.CreateRectangle(0, -20, leftPanelWidth - 12, groupHeight - 20, groupBG, "TOPLEFT", "TOPLEFT", 0.1445, 0.1445, 0.1445, 1);

    return groupContent;
end

function SceneMachine.CreateStatsFrame()
	SceneMachine.StatsFrame = CreateFrame("Frame", nil, Renderer.projectionFrame);
	SceneMachine.StatsFrame:SetPoint("TOPRIGHT", Renderer.projectionFrame, "TOPRIGHT", 0, 0);
	SceneMachine.StatsFrame:SetWidth(200);
	SceneMachine.StatsFrame:SetHeight(200);
	SceneMachine.StatsFrame.text = SceneMachine.StatsFrame:CreateFontString(nil, "BACKGROUND", "GameTooltipText");
	SceneMachine.StatsFrame.text:SetFont(Win.defaultFont, 9, "NORMAL");

	SceneMachine.StatsFrame.text:SetPoint("TOPRIGHT",-5,-5);
	SceneMachine.StatsFrame.text:SetJustifyV("TOP");
	SceneMachine.StatsFrame.text:SetJustifyH("LEFT");
	SceneMachine.StatsFrame:Show();
end

function Editor.Save()
    scenemachine_projects = Editor.ProjectManager.projects;

    -- ask for restart / or restart --
    Win.OpenMessageBox(SceneMachine.mainWindow, 
    "Save", "Saving requires a UI reload, continue?",
    true, true, function() ReloadUI(); end, function() end);
    Win.messageBox:SetFrameStrata(Editor.MESSAGE_BOX_FRAME_STRATA);
end

function Editor.ShowProjectManager()
    Editor.ProjectManager.OpenWindow();
end

function Editor.OpenContextMenu(x, y)
	local menuOptions = {
        { ["Name"] = "Select", ["Action"] = function() Gizmos.activeTransformGizmo = 0; end },
        { ["Name"] = "Move", ["Action"] = function() Gizmos.activeTransformGizmo = 1; end },
        { ["Name"] = "Rotate", ["Action"] = function() Gizmos.activeTransformGizmo = 2; end },
        { ["Name"] = "Scale", ["Action"] = function() Gizmos.activeTransformGizmo = 3; end },
        { ["Name"] = nil },
        { ["Name"] = "Delete", ["Action"] = function() SM.DeleteObject(SM.selectedObject); end },
        { ["Name"] = "Hide/Show", ["Action"] = function() SM.ToggleObjectVisibility(SM.selectedObject); end },
        { ["Name"] = "Freeze/Unfreeze", ["Action"] = function()
            SM.ToggleObjectFreezeState(SM.selectedObject);
            if (SM.selectedObject) then
                if (SM.selectedObject.frozen) then
                    SM.selectedObject = nil;
                    SH.RefreshHierarchy();
                    OP.Refresh();
                end
            end
        end },
	};

    Win.PopupWindowMenu(x, y, SceneMachine.mainWindow, menuOptions);
end