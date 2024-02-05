local UI = SceneMachine.UI;
UI.Toolbar = {};
local Toolbar = UI.Toolbar;
Toolbar.__index = Toolbar;
setmetatable(Toolbar, UI.Element)

function Toolbar:New(x, y, w, h, parent, iconCrop, window)
	local v =
    {
        x = x or 0,
        y = y or 0,
        w = w or 20,
        h = h or 20,
        parent = parent or nil,
        iconCrop = iconCrop or 0,
        window = window or nil,
        groups = {},
        visible = true,
    };

	setmetatable(v, Toolbar);
    v:Build();
	return v;
end

function Toolbar:Build()
    self.frame = UI.Rectangle:New(self.x, self.y, self.w, self.h, self.parent, "TOP", "TOP", 0.1757, 0.1757, 0.1875, 1);

    self.iconsTexture = "Interface\\Addons\\scenemachine\\static\\textures\\toolbar.png";

    self.iconCoordMap = {
        { "select", "move", "rotate", "scale", "worldpivot", "localpivot", "centerpivot", "basepivot" },
        { "projects", "", "", "", "", "", "", "" },
        { "", "", "", "", "", "", "", "" },
        { "", "", "", "", "", "", "", "" },
        { "", "", "", "", "", "", "", "" },
        { "", "", "", "", "", "", "", "" },
        { "", "addanim", "removeanim", "addkey", "removekey", "loop", "loopoff", "" },
        { "timesettings", "addobj", "removeobj", "play", "pause", "fastforward", "skiponeframe", "skiptoend" },
    };

    self.iconCoordLookup = {};

    local div = 1 / 8;
    local iconCropDiv = self.iconCrop * div;
    for x = 1, 8, 1 do
        for y = 1, 8, 1 do
            self.iconCoordLookup[self.iconCoordMap[y][x]] = { div * (x - 1) + iconCropDiv, div * x - iconCropDiv, div * (y - 1) + iconCropDiv, div * y - iconCropDiv };
        end
    end
end


function Toolbar:GetIcon(name, mirrorX)
    mirrorX = mirrorX or false;
    local iconCoords = self.iconCoordLookup[name];
    if (mirrorX) then
        return { self.iconsTexture, { iconCoords[2], iconCoords[1], iconCoords[3], iconCoords[4] } };
    end
    return { self.iconsTexture, iconCoords };
end

function Toolbar:CreateGroup(x, y, w, h, components)
    local group = UI.Rectangle:New(x, y, w, h, self.frame:GetFrame(), "TOPLEFT", "TOPLEFT", 0.1757, 0.1757, 0.1875, 1);
    group.components = {};

    local x = 0;
    local buttonW = h;
    local buttonH = h;

    for c = 1, #components, 1 do
        local component = components[c];
        
        if (component.type == "Separator") then
            group.components[c] = UI.Rectangle:New(x + 2, 0, 1, 20, group:GetFrame(), "LEFT", "LEFT", 0.242, 0.242, 0.25, 1);
            x = x + 6;
        elseif (component.type == "DragHandle") then
            group.components[c] = UI.Rectangle:New(x + 2, 0, 5, 20, group:GetFrame(), "LEFT", "LEFT", 0.242, 0.242, 0.25, 1);
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
            group.components[c] = UI.Dropdown:New(x, 0, component.width, buttonH, group:GetFrame(), "LEFT", "LEFT", component.options, component.action, self.window);
            x = x + component.width;
        end

        group.components[c].type = component.type;
        group.components[c].name = component.name;
    end

    self.groups[#self.groups + 1] = group;
    return group;
end

Toolbar.__tostring = function(self)
	return string.format("Toolbar( %.3f, %.3f, %.3f, %.3f )", self.x, self.y, self.w, self.h);
end