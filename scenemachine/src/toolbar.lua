local Editor = SceneMachine.Editor;
local Win = ZWindowAPI;
local Toolbar = Editor.Toolbar;
local Gizmos = SceneMachine.Gizmos;

local c1 = { 0.1757, 0.1757, 0.1875 };
local c2 = { 0.242, 0.242, 0.25 };
local c3 = { 0, 0.4765, 0.7968 };
local c4 = { 0.1171, 0.1171, 0.1171 };

function Toolbar.Create()
    local toolbar = Win.CreateRectangle(0, -15, Editor.width, 30, SceneMachine.mainWindow, "TOP", "TOP", c1[1], c1[2], c1[3], 1);

    local iconsTexture = "Interface\\Addons\\scenemachine\\static\\textures\\toolbar.png";

    local iconCoordMap = {
        { "select", "move", "rotate", "scale", "worldpivot", "localpivot", "centerpivot", "basepivot" },
        { "projects", "", "", "", "", "", "", "" },
        { "", "", "", "", "", "", "", "" },
        { "", "", "", "", "", "", "", "" },
        { "", "", "", "", "", "", "", "" },
        { "", "", "", "", "", "", "", "" },
        { "", "", "", "", "", "", "", "" },
        { "", "", "", "", "", "", "", "" },
    };

    local iconCoordLookup = {};

    local div = 1 / 8;
    for x = 1, 8, 1 do
        for y = 1, 8, 1 do
            iconCoordLookup[iconCoordMap[y][x]] = { div * (x - 1), div * x, div * (y - 1), div * y };
        end
    end

    local function getIcon(name)
        local iconCoords = iconCoordLookup[name];
        return { iconsTexture, iconCoords };
    end

    Toolbar.transformGroup = Toolbar.CreateGroup(0, toolbar,
        {
            { type = "DragHandle" },
            { type = "Button", name = "Project", icon = getIcon("projects"), action = function(self) Editor.ProjectManager.OpenWindow() end },
            { type = "Dropdown", name = "ProjectList", width = 200, options = {}, action = function(index) Editor.ProjectManager.LoadProjectByIndex(index); end },
            { type = "Separator" },
            { type = "Button", name = "Select", icon = getIcon("select"), action = function(self) Gizmos.activeTransformGizmo = 0; end },
            { type = "Button", name = "Move", icon = getIcon("move"), action = function(self) Gizmos.activeTransformGizmo = 1; end },
            { type = "Button", name = "Rotate", icon = getIcon("rotate"), action = function(self) Gizmos.activeTransformGizmo = 2; end },
            { type = "Button", name = "Scale", icon = getIcon("scale"), action = function(self) Gizmos.activeTransformGizmo = 3; end },
            { type = "Separator" },
            { type = "Button", name = "L", icon = getIcon("localpivot"), action = function(self) Gizmos.space = 1; print("Local Space"); end },
            { type = "Button", name = "W", icon = getIcon("worldpivot"), action = function(self) Gizmos.space = 0; print("World Space"); end },
            { type = "Separator" },
            { type = "Button", name = "Center", icon = getIcon("centerpivot"), action = function(self) Gizmos.pivot = 0; print("Pivot Center"); end },
            { type = "Button", name = "Base", icon = getIcon("basepivot"), action = function(self) Gizmos.pivot = 1; print("Pivot Base"); end },
            { type = "Separator" },
        }
    );
end

function Toolbar.RefreshProjectsDropdown()
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
    
    for c = 1, #Toolbar.transformGroup.components, 1 do
        local component = Toolbar.transformGroup.components[c];

        if (component.type == "Dropdown") then
            if (component.name == "ProjectList") then
                Toolbar.transformGroup.components[c].SetOptions(projectNames);
                Toolbar.transformGroup.components[c].ShowSelectedName(selectedName);
            end
        end
    end
end

function Toolbar.CreateGroup(x, toolbar, components)
    local group = Win.CreateRectangle(x, 0, Editor.width, 30, toolbar, "TOPLEFT", "TOPLEFT", c1[1], c1[2], c1[3], 1);
    group.components = {};

    local x = 0;
    local buttonW = 30;
    local buttonH = 30;

    for c = 1, #components, 1 do
        local component = components[c];
        
        if (component.type == "Separator") then
            group.components[c] = Win.CreateRectangle(x + 2, 0, 1, 20, group, "LEFT", "LEFT", c2[1], c2[2], c2[3], 1);
            x = x + 6;
        elseif (component.type == "DragHandle") then
            group.components[c] = Win.CreateRectangle(x + 2, 0, 5, 20, group, "LEFT", "LEFT", c2[1], c2[2], c2[3], 1);
            x = x + 9;
        elseif (component.type == "Button") then
            if (component.icon ~= nil) then
                group.components[c] = Win.CreateButton(x, 0, buttonW, buttonH, group, "LEFT", "LEFT", nil, component.icon[1], "BUTTON_VS", component.icon[2]);
            else
                group.components[c] = Win.CreateButton(x, 0, buttonW, buttonH, group, "LEFT", "LEFT", component.name, nil, "BUTTON_VS");
            end
            group.components[c]:SetScript("OnClick", component.action);
            x = x + buttonW;
        elseif (component.type == "Dropdown") then
            -- Win.CreateDropdown(posX, posY, sizeX, sizeY, parent, dropdownPoint, parentPoint)
            group.components[c] = Win.CreateDropdown(x, 0, component.width, buttonH, group, "LEFT", "LEFT", component.options, component.action);
            x = x + component.width;
        end

        group.components[c].type = component.type;
        group.components[c].name = component.name;
    end

    return group;
end