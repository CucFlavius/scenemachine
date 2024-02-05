local Editor = SceneMachine.Editor;
local Toolbar = Editor.Toolbar;
local Gizmos = SceneMachine.Gizmos;
local UI = SceneMachine.UI;

local c1 = { 0.1757, 0.1757, 0.1875 };
local c2 = { 0.242, 0.242, 0.25 };
local c3 = { 0, 0.4765, 0.7968 };
local c4 = { 0.1171, 0.1171, 0.1171 };

function Toolbar.Create(x, y, w, h, parent, iconCrop, window)
    iconCrop = iconCrop or 0;
    local toolbar = UI.Rectangle:New(x, y, w, h, parent, "TOP", "TOP", c1[1], c1[2], c1[3], 1);

    local iconsTexture = "Interface\\Addons\\scenemachine\\static\\textures\\toolbar.png";

    local iconCoordMap = {
        { "select", "move", "rotate", "scale", "worldpivot", "localpivot", "centerpivot", "basepivot" },
        { "projects", "", "", "", "", "", "", "" },
        { "", "", "", "", "", "", "", "" },
        { "", "", "", "", "", "", "", "" },
        { "", "", "", "", "", "", "", "" },
        { "", "", "", "", "", "", "", "" },
        { "", "addanim", "removeanim", "addkey", "removekey", "loop", "loopoff", "" },
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
        local group = UI.Rectangle:New(x, y, w, h, toolbar:GetFrame(), "TOPLEFT", "TOPLEFT", c1[1], c1[2], c1[3], 1);
        group.components = {};
    
        local x = 0;
        local buttonW = h;
        local buttonH = h;
    
        for c = 1, #components, 1 do
            local component = components[c];
            
            if (component.type == "Separator") then
                group.components[c] = UI.Rectangle:New(x + 2, 0, 1, 20, group:GetFrame(), "LEFT", "LEFT", c2[1], c2[2], c2[3], 1);
                x = x + 6;
            elseif (component.type == "DragHandle") then
                group.components[c] = UI.Rectangle:New(x + 2, 0, 5, 20, group:GetFrame(), "LEFT", "LEFT", c2[1], c2[2], c2[3], 1);
                x = x + 9;
            elseif (component.type == "Button") then
                if (component.icon ~= nil) then
                    group.components[c] = UI.Button:New(x, 0, buttonW, buttonH, group:GetFrame(), "LEFT", "LEFT", nil, component.icon[1], component.icon[2]);
                else
                    group.components[c] = UI.Button:New(x, 0, buttonW, buttonH, group:GetFrame(), "LEFT", "LEFT", component.name, nil);
                end
                group.components[c]:SetScript("OnClick", component.action);
                x = x + buttonW;
            elseif (component.type == "Toggle") then
                if (component.default) then
                    group.components[c] = UI.Button:New(x, 0, buttonW, buttonH, group:GetFrame(), "LEFT", "LEFT", nil, component.iconOn[1], component.iconOn[2]);
                else
                    group.components[c] = UI.Button:New(x, 0, buttonW, buttonH, group:GetFrame(), "LEFT", "LEFT", nil, component.iconOff[1], component.iconOff[2]);
                end
                
                group.components[c].toggleOn = component.default;
                group.components[c]:SetScript("OnClick", function (self, button, down)
                    group.components[c].toggleOn = not group.components[c].toggleOn;
                    component.action(group.components[c], group.components[c].toggleOn);
                    if (group.components[c].toggleOn) then
                        group.components[c]:SetTexCoords(component.iconOn[2]);
                    else
                        group.components[c]:SetTexCoords(component.iconOff[2]);
                    end
                end);
                x = x + buttonW;
            elseif (component.type == "Dropdown") then
                group.components[c] = UI.Dropdown:New(x, 0, component.width, buttonH, group:GetFrame(), "LEFT", "LEFT", component.options, component.action, window);
                x = x + component.width;
            end
    
            group.components[c].type = component.type;
            group.components[c].name = component.name;
        end
    
        toolbar.transformGroup = group;
    end

    return toolbar;
end