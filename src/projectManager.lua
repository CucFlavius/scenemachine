SceneMachine.Editor = SceneMachine.Editor or {};
local Win = ZWindowAPI;
local Editor = SceneMachine.Editor;
Editor.ProjectManager = Editor.ProjectManager or {};
local PM = Editor.ProjectManager;
local c1 = { 0.1757, 0.1757, 0.1875 };
local c2 = { 0.242, 0.242, 0.25 };
local c3 = { 0, 0.4765, 0.7968 };
local c4 = { 0.1171, 0.1171, 0.1171 };

local managerWindowWidth = 500;
local managerWindowHeight = 300;

function PM.Create()
    PM.window = Win.CreatePopupWindow(0, 0, managerWindowWidth, managerWindowHeight, SceneMachine.mainWindow, "CENTER", "CENTER", "ProjectManager");
    local dropShadow = Win.CreateImageBox(0, 10, managerWindowWidth * 1.20, managerWindowHeight * 1.29, PM.window, "CENTER", "CENTER",
	"Interface\\Addons\\scenemachine\\static\\textures\\dropShadowSquare.png");
    dropShadow:SetFrameStrata("MEDIUM");
    PM.window.texture:SetColorTexture(c4[1], c4[2], c4[3],1);
    PM.window.TitleBar.texture:SetColorTexture(c1[1], c1[2], c1[3], 1);
    PM.window.CloseButton.ntex:SetColorTexture(c1[1], c1[2], c1[3], 1);
    PM.window.CloseButton.htex:SetColorTexture(c2[1], c2[2], c2[3], 1);
    PM.window.CloseButton.ptex:SetColorTexture(c3[1], c3[2], c3[3], 1);
end