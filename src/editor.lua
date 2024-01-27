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

Editor.width = 1280;
Editor.height = 720;
Editor.toolbarHeight = 15 + 30;
local rightPanelWidth = 300;
local leftPanelWidth = 300;
local bottomPanelHeight = 200;

local c1 = { 0.1757, 0.1757, 0.1875 };
local c2 = { 0.242, 0.242, 0.25 };
local c3 = { 0, 0.4765, 0.7968 };
local c4 = { 0.1171, 0.1171, 0.1171 };

function Editor.Initialize()
    -- Create all of the UI --
    Win.Initialize("Interface\\AddOns\\scenemachine\\src\\Libraries\\ZWindowAPI");
    Editor.CreateMainWindow();
    Editor.MainMenu.Create();
    Editor.Toolbar.Create();
    Editor.CreateRightPanel();
    Editor.CreateLeftPanel();
    Editor.CreateBottomPanel();
    Editor.ProjectManager.CreateWindow();
    MousePick.Initialize();

    local sceneX = leftPanelWidth;
    local sceneY = -(Editor.toolbarHeight + 6);
    local sceneW = Editor.width - (rightPanelWidth + leftPanelWidth);
    local sceneH = Editor.height - (Editor.toolbarHeight + bottomPanelHeight + 6 + 20);
    Editor.SceneManager.Create(sceneX, sceneY, sceneW, sceneH, SceneMachine.mainWindow);

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
end

function Editor.CreateMainWindow()
	SceneMachine.mainWindow = Win.CreateWindow(0, 0, Editor.width, Editor.height, nil, nil, nil, true, "Editor");
	SceneMachine.mainWindow:SetFrameStrata("BACKGROUND");
	SceneMachine.WINDOW_WIDTH = Editor.width;
	SceneMachine.WINDOW_HEIGHT = Editor.height;
	SceneMachine.mainWindow:SetIgnoreParentScale(true);		-- This way the camera doesn't get offset when the wow window or UI changes size/aspect
    SceneMachine.mainWindow.texture:SetColorTexture(c4[1], c4[2], c4[3],1);
    SceneMachine.mainWindow.TitleBar.texture:SetColorTexture(c1[1], c1[2], c1[3], 1);
    SceneMachine.mainWindow.CloseButton.ntex:SetColorTexture(c1[1], c1[2], c1[3], 1);
    SceneMachine.mainWindow.CloseButton.htex:SetColorTexture(c2[1], c2[2], c2[3], 1);
    SceneMachine.mainWindow.CloseButton.ptex:SetColorTexture(c3[1], c3[2], c3[3], 1);
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
	SceneMachine.StatsFrame:SetFrameStrata("LOW");
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
    Win.messageBox:SetFrameStrata("DIALOG");
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
        { ["Name"] = "Delete Selected", ["Action"] = function() SM.DeleteObject(SM.selectedObject); end },
	};

    Win.PopupWindowMenu(x, y, SceneMachine.mainWindow, menuOptions);
end