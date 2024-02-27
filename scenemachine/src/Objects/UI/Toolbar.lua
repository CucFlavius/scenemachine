local UI = SceneMachine.UI;
local Resources = SceneMachine.Resources;
UI.Toolbar = {};
local Toolbar = UI.Toolbar;
Toolbar.__index = Toolbar;
setmetatable(Toolbar, UI.Element)

function Toolbar:New(x, y, w, h, parent, window, iconData)
	local v =
    {
        x = x or 0,
        y = y or 0,
        w = w or 20,
        h = h or 20,
        parent = parent or nil,
        window = window or nil,
        groups = {},
        visible = true,
        iconData = iconData or {},
    };

	setmetatable(v, Toolbar);
    v:Build();
	return v;
end

function Toolbar:Build()
    self.frame = UI.Rectangle:New(self.x, self.y, self.w, self.h, self.parent, "TOPLEFT", "TOPLEFT", 0.1757, 0.1757, 0.1875, 1);
    self.frame:SetPoint("TOPRIGHT", self.parent, "TOPRIGHT", 0, 0);
    self.iconsTexture = self.iconData.texture;
    self.iconCoordMap = self.iconData.coords;
    self.iconCoordLookup = {};

    local divX = 1 / self.iconData.rows;
    local divY = 1 / self.iconData.columns;
    for x = 1, self.iconData.rows, 1 do
        for y = 1, self.iconData.columns, 1 do
            self.iconCoordLookup[self.iconCoordMap[y][x]] = { divX * (x - 1), divX * x, divY * (y - 1), divY * y };
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
    group:SetPoint("TOPRIGHT", self.frame:GetFrame(), "TOPRIGHT", 0, 0);
    group:SetClipsChildren(true);
    group.components = {};
    group.h = h;
    local currentLevel = group:GetFrameLevel();

    local x = 0;
    local buttonW = h;
    local buttonH = h;

    for c = 1, #components, 1 do
        local component = components[c];
        
        if (component.type == "Separator") then
            group.components[c] = UI.Rectangle:New(x + 2, 0, 1, 20, group:GetFrame(), "LEFT", "LEFT", 0.242, 0.242, 0.25, 1);
            group.components[c]:SetFrameLevel(currentLevel + 1);
            x = x + 6;
        elseif (component.type == "DragHandle") then
            group.components[c] = UI.Rectangle:New(x + 2, 0, 5, 20, group:GetFrame(), "LEFT", "LEFT", 0.242, 0.242, 0.25, 1);
            group.components[c]:SetFrameLevel(currentLevel + 1);
            x = x + 9;
        elseif (component.type == "Button") then
            if (component.icon ~= nil) then
                group.components[c] = UI.Button:New(x, 0, buttonW, buttonH, group:GetFrame(), "LEFT", "LEFT", nil, component.icon[1], component.icon[2]);
            else
                group.components[c] = UI.Button:New(x, 0, buttonW, buttonH, group:GetFrame(), "LEFT", "LEFT", component.name, nil);
            end
            group.components[c]:SetScript("OnClick", component.action);
            x = x + buttonW;
        elseif (component.type == "SplitButton") then
            local icons = {};
            local coords = {};
            for i = 1, #component.icons, 1 do
                icons[i] = component.icons[i][1];
                coords[i] = component.icons[i][2];
            end
            group.components[c] = UI.SplitButton:New(x, 0, buttonW, buttonH, group:GetFrame(), "LEFT", "LEFT", icons, coords, component.splitaction, component.action);
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
            group.components[c] = UI.Dropdown:New(x, 0, component.width, 22, group:GetFrame(), "LEFT", "LEFT", component.options, component.action, self.window);
            x = x + component.width;
        end

        group.components[c].type = component.type;
        group.components[c].name = component.name;
        group.components[c].tooltip = component.tooltip;
        group.components[c].tooltipDetailed = component.tooltipDetailed;
    end

    self.groups[#self.groups + 1] = group;
    return group;
end

function Toolbar:ToggleGroupComponent(group, name, on)
    for c = 1, #group.components, 1 do
        local component = group.components[c];
        if (component.name == name) then
            if (on) then
                component:Show();
            else
                component:Hide();
            end
        end
    end
end

function Toolbar:RefreshGroup(group)
    local currentLevel = group:GetFrameLevel();

    local x = 0;
    local buttonW = group.h;
    local buttonH = group.h;

    for c = 1, #group.components, 1 do
        local component = group.components[c];
        if (group.components[c]:IsVisible()) then

            if (component.type == "Separator") then
                component.x = x + 2;
                component:ClearAllPoints();
                component:SetPoint("LEFT", group:GetFrame(), "LEFT", x + 2, 0);
                component:SetFrameLevel(currentLevel + 1);
                x = x + 6;
            elseif (component.type == "DragHandle") then
                component.x = x + 2;
                component:ClearAllPoints();
                component:SetPoint("LEFT", group:GetFrame(), "LEFT", x + 2, 0);
                component:SetFrameLevel(currentLevel + 1);
                x = x + 9;
            elseif (component.type == "Button") then
                component.x = x;
                component:ClearAllPoints();
                component:SetPoint("LEFT", group:GetFrame(), "LEFT", x, 0);
                component:SetFrameLevel(currentLevel + 1);
                x = x + buttonW;
            elseif (component.type == "SplitButton") then
                component.x = x;
                component:ClearAllPoints();
                component:SetPoint("LEFT", group:GetFrame(), "LEFT", x, 0);
                component:SetFrameLevel(currentLevel + 1);
                x = x + buttonW;
            elseif (component.type == "Toggle") then
                component.x = x;
                component:ClearAllPoints();
                component:SetPoint("LEFT", group:GetFrame(), "LEFT", x, 0);
                component:SetFrameLevel(currentLevel + 1);
                x = x + buttonW;
            elseif (component.type == "Dropdown") then
                component.x = x;
                component:ClearAllPoints();
                component:SetPoint("LEFT", group:GetFrame(), "LEFT", x, 0);
                component:SetFrameLevel(currentLevel + 1);
                x = x + component:GetWidth();
            end
        end
    end
end

Toolbar.__tostring = function(self)
	return string.format("Toolbar( %.3f, %.3f, %.3f, %.3f )", self.x, self.y, self.w, self.h);
end