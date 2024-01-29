local Editor = SceneMachine.Editor;
local Win = ZWindowAPI;
local Toolbar = Editor.Toolbar;
local Gizmos = SceneMachine.Gizmos;

local c1 = { 0.1757, 0.1757, 0.1875 };
local c2 = { 0.242, 0.242, 0.25 };
local c3 = { 0, 0.4765, 0.7968 };
local c4 = { 0.1171, 0.1171, 0.1171 };

function Toolbar.Create(x, y, w, h, parent, iconCrop)
    iconCrop = iconCrop or 0;
    local toolbar = Win.CreateRectangle(x, y, w, h, parent, "TOP", "TOP", c1[1], c1[2], c1[3], 1);

    local iconsTexture = "Interface\\Addons\\scenemachine\\static\\textures\\toolbar.png";

    local iconCoordMap = {
        { "select", "move", "rotate", "scale", "worldpivot", "localpivot", "centerpivot", "basepivot" },
        { "projects", "", "", "", "", "", "", "" },
        { "", "", "", "", "", "", "", "" },
        { "", "", "", "", "", "", "", "" },
        { "", "", "", "", "", "", "", "" },
        { "", "", "", "", "", "", "", "" },
        { "", "", "", "", "", "", "", "" },
        { "timesettings", "addobj", "removeobj", "play", "pause", "fastforward", "skiponeframe", "skiptoend" },
    };

    local iconCoordLookup = {};

    local div = 1 / 8;
    iconCrop = iconCrop * div;
    for x = 1, 8, 1 do
        for y = 1, 8, 1 do
            iconCoordLookup[iconCoordMap[y][x]] = { div * (x - 1) + iconCrop, div * x - iconCrop, div * (y - 1) + iconCrop, div * y - iconCrop };
        end
    end

    function toolbar.getIcon(name, mirrorX)
        local iconCoords = iconCoordLookup[name];
        if (mirrorX) then
            return { iconsTexture, { iconCoords[2], iconCoords[1], iconCoords[3], iconCoords[4] } };
        end
        return { iconsTexture, iconCoords };
    end

    function toolbar.CreateGroup(x, y, w, h, toolbar, components)
        local group = Win.CreateRectangle(x, y, w, h, toolbar, "TOPLEFT", "TOPLEFT", c1[1], c1[2], c1[3], 1);
        group.components = {};
    
        local x = 0;
        local buttonW = h;
        local buttonH = h;
    
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
    
        toolbar.transformGroup = group;
    end

    return toolbar;
end