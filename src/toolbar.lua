local Editor = SceneMachine.Editor;
local Win = ZWindowAPI;
local Toolbar = Editor.Toolbar;

local c1 = { 0.1757, 0.1757, 0.1875 };
local c2 = { 0.242, 0.242, 0.25 };
local c3 = { 0, 0.4765, 0.7968 };
local c4 = { 0.1171, 0.1171, 0.1171 };

function Toolbar.Create()
    local toolbar = Win.CreateRectangle(0, -15, Editor.width, 30, SceneMachine.mainWindow, "TOP", "TOP", c1[1], c1[2], c1[3], 1);
    toolbar.button1 = Win.CreateButton(0, 0, 30, 30, toolbar, "LEFT", "LEFT", "Project Manager", nil, "BUTTON_VS");
    toolbar.button1:SetScript("OnClick", function(self) Editor.ProjectManager.OpenWindow() end);

    toolbar.button2 = Win.CreateButton(30, 0, 30, 30, toolbar, "LEFT", "LEFT", "Select", nil, "BUTTON_VS");
    toolbar.button2:SetScript("OnClick", function(self) Gizmos.activeTransformGizmo = 0; end);

    toolbar.button3 = Win.CreateButton(60, 0, 30, 30, toolbar, "LEFT", "LEFT", "Move", nil, "BUTTON_VS");
    toolbar.button3:SetScript("OnClick", function(self) Gizmos.activeTransformGizmo = 1; end);

    toolbar.button4 = Win.CreateButton(90, 0, 30, 30, toolbar, "LEFT", "LEFT", "Rotate", nil, "BUTTON_VS");
    toolbar.button4:SetScript("OnClick", function(self) Gizmos.activeTransformGizmo = 2; end);

    toolbar.button5 = Win.CreateButton(120, 0, 30, 30, toolbar, "LEFT", "LEFT", "Scale", nil, "BUTTON_VS");
    toolbar.button5:SetScript("OnClick", function(self) Gizmos.activeTransformGizmo = 3; end);

    toolbar.button6 = Win.CreateButton(150, 0, 30, 30, toolbar, "LEFT", "LEFT", "L", nil, "BUTTON_VS");
    toolbar.button6:SetScript("OnClick", function(self) Gizmos.space = 1; print("Local Space"); end);

    toolbar.button7 = Win.CreateButton(180, 0, 30, 30, toolbar, "LEFT", "LEFT", "W", nil, "BUTTON_VS");
    toolbar.button7:SetScript("OnClick", function(self) Gizmos.space = 0; print("World Space"); end);

    toolbar.button8 = Win.CreateButton(210, 0, 30, 30, toolbar, "LEFT", "LEFT", "Center", nil, "BUTTON_VS");
    toolbar.button8:SetScript("OnClick", function(self) Gizmos.pivot = 0; print("Pivot Center"); end);

    toolbar.button9 = Win.CreateButton(240, 0, 30, 30, toolbar, "LEFT", "LEFT", "Base", nil, "BUTTON_VS");
    toolbar.button9:SetScript("OnClick", function(self) Gizmos.pivot = 1; print("Pivot Base"); end);
end