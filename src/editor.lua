SceneMachine.Editor = SceneMachine.Editor or {}
SceneMachine.Editor.AssetBrowser = SceneMachine.Editor.AssetBrowser or {}
local Editor = SceneMachine.Editor;
local Win = ZWindowAPI;
local FX = SceneMachine.FX;
local Renderer = SceneMachine.Renderer;

local width = 1280;
local height = 720;
local toolbarHeight = 15 + 30;
local rightPanelWidth = 300;
local leftPanelWidth = 300;
local bottomPanelHeight = 200;
local c1 = { 0.1757, 0.1757, 0.1875 };
local c2 = { 0.242, 0.242, 0.25 };
local c3 = { 0, 0.4765, 0.7968 };
local c4 = { 0.1171, 0.1171, 0.1171 };

function Editor.CreateMainWindow()
    SceneMachine.CreateWindow("Editor", width, height);
    SceneMachine.mainWindow.texture:SetColorTexture(c4[1], c4[2], c4[3],1);
    SceneMachine.mainWindow.TitleBar.texture:SetColorTexture(c1[1], c1[2], c1[3], 1);
    SceneMachine.mainWindow.CloseButton.ntex:SetColorTexture(c1[1], c1[2], c1[3], 1);
    SceneMachine.mainWindow.CloseButton.htex:SetColorTexture(c2[1], c2[2], c2[3], 1);
    SceneMachine.mainWindow.CloseButton.ptex:SetColorTexture(c3[1], c3[2], c3[3], 1);
end

function Editor.CreateGroup(name, groupHeight, groupParent)
    local groupBG = Win.CreateRectangle(6, -6, leftPanelWidth - 12, groupHeight, groupParent, "TOPLEFT", "TOPLEFT",  c1[1], c1[2], c1[3], 1);
    local groupTitleText = Win.CreateTextBoxSimple(0, 0, leftPanelWidth - 30, 20, groupBG, "TOP", "TOP", name, 9);
    local groupContent = Win.CreateRectangle(0, -20, leftPanelWidth - 12, groupHeight - 20, groupBG, "TOPLEFT", "TOPLEFT", 0.1445, 0.1445, 0.1445, 1);

    return groupContent;
end

function Editor.CreateToolbar()
    local menubar = Win.CreateRectangle(0, 0, width, 15, SceneMachine.mainWindow, "TOP", "TOP", c1[1], c1[2], c1[3], 1);
    menubar.menu1btn = Win.CreateButton(0, 0, 50, 15, menubar, "LEFT", "LEFT", "File", nil, "BUTTON_VS");
    menubar.menu2btn = Win.CreateButton(50, 0, 50, 15, menubar, "LEFT", "LEFT", "Tools", nil, "BUTTON_VS");
    menubar.menu3btn = Win.CreateButton(100, 0, 50, 15, menubar, "LEFT", "LEFT", "Help", nil, "BUTTON_VS");

    local toolbar = Win.CreateRectangle(0, -15, width, 30, SceneMachine.mainWindow, "TOP", "TOP", c1[1], c1[2], c1[3], 1);
    toolbar.button1 = Win.CreateButton(0, 0, 30, 30, toolbar, "LEFT", "LEFT", "Btn", nil, "BUTTON_VS");
    toolbar.button2 = Win.CreateButton(30, 0, 30, 30, toolbar, "LEFT", "LEFT", "Btn", nil, "BUTTON_VS");
end

function Editor.CreateRightPanel()
    local rightPanel = Win.CreateRectangle(0, -toolbarHeight/2, rightPanelWidth, height - toolbarHeight, SceneMachine.mainWindow, "RIGHT", "RIGHT", c4[1], c4[2], c4[3], 1);
    
    local edge = 10;
    local tilesGroup = Editor.CreateGroup("Model List", height - toolbarHeight - edge , rightPanel);

    Editor.AssetBrowser.Create(tilesGroup, rightPanelWidth - 12, height - toolbarHeight - edge -(toolbarHeight/2));
end


function Editor.CreateLeftPanel()
    local leftPanelHeight = height - toolbarHeight;
    local leftPanel = Win.CreateRectangle(0, -toolbarHeight, leftPanelWidth, leftPanelHeight, SceneMachine.mainWindow, "TOPLEFT", "TOPLEFT", c4[1], c4[2], c4[3], 1);
    local fxGroup = Editor.CreateGroup("Test group name", 300, leftPanel);

    Win.CreateTextBoxSimple(0, -10, leftPanelWidth - 30, 20, fxGroup, "TOP", "TOP", "Test title", 9);

    local slider1 = Win.CreateSlider(fxGroup, "test", "teest", 0, 3000, 10);
    slider1:SetPoint("TOPLEFT", fxGroup, "TOPLEFT", 10, -40);
    slider1:SetValue(0);
    slider1:HookScript("OnValueChanged", function(self,value)
        --FX.Fog.minZ = value;
        --FX.Fog.RecalculatePlanes();
      end);
end

function Editor.CreateBottomPanel()
    local bottomPanel = Win.CreateRectangle(leftPanelWidth, 0, width - (rightPanelWidth + leftPanelWidth),
     bottomPanelHeight, SceneMachine.mainWindow, "BOTTOMLEFT", "BOTTOMLEFT", c4[1], c4[2], c4[3], 1);
end

function Editor.Initialize()
    Win.Initialize("Interface\\AddOns\\scenemachine\\src\\Libraries\\ZWindowAPI");
    Editor.CreateMainWindow();
    Editor.CreateToolbar();
    Editor.CreateRightPanel();
    --Editor.CreateLeftPanel();
    --Editor.CreateBottomPanel();

    local groupBG = Win.CreateRectangle(leftPanelWidth, -(toolbarHeight + 6), width - (rightPanelWidth + leftPanelWidth), 20, SceneMachine.mainWindow, "TOPLEFT", "TOPLEFT",  c1[1], c1[2], c1[3], 1);
    local groupTitleText = Win.CreateTextBoxSimple(0, 0, width - (rightPanelWidth + leftPanelWidth) - 18, 20, groupBG, "TOP", "TOP", "Scene", 9);
    SceneMachine.Renderer.CreateRenderer(SceneMachine.mainWindow, leftPanelWidth, bottomPanelHeight, width - (rightPanelWidth + leftPanelWidth), height - (toolbarHeight + bottomPanelHeight + 6 + 20), "BOTTOMLEFT", "BOTTOMLEFT");
end