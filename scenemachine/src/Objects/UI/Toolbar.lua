local UI = SceneMachine.UI;
local Resources = SceneMachine.Resources;
local Editor = SceneMachine.Editor;
UI.Toolbar = {};

--- @class Toolbar : Element
local Toolbar = UI.Toolbar;

Toolbar.__index = Toolbar;
setmetatable(Toolbar, UI.Element)

--- Creates a new Toolbar object.
--- @param x number? The x-coordinate of the toolbar's position.
--- @param y number? The y-coordinate of the toolbar's position.
--- @param w number? The width of the toolbar.
--- @param h number? The height of the toolbar.
--- @param parent Element? The parent element of the toolbar.
--- @param window Element? The window element associated with the toolbar.
--- @param iconData table? The icon data for the toolbar.
--- @return Toolbar: The newly created Toolbar object.
function Toolbar:New(x, y, w, h, parent, window, iconData)
    --- @class Toolbar : Element
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

--- Builds the toolbar UI element.
function Toolbar:Build()
    self.frame = UI.Rectangle:NewTLTR(self.x, self.y, 0, 0, self.h, self.parent, 0.1757, 0.1757, 0.1875, 1);
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

--- Retrieves the icon and its coordinates based on the given name.
--- @param name string The name of the icon.
--- @param mirrorX boolean Whether to mirror the icon horizontally. Defaults to false.
--- @return table: The icon texture and its coordinates.
function Toolbar:GetIcon(name, mirrorX)
    mirrorX = mirrorX or false;
    local iconCoords = self.iconCoordLookup[name];
    if (mirrorX) then
        return { self.iconsTexture, { iconCoords[2], iconCoords[1], iconCoords[3], iconCoords[4] } };
    end
    return { self.iconsTexture, iconCoords };
end

--- Creates a group of UI components within the toolbar.
--- @param x number The x-coordinate of the group.
--- @param y number The y-coordinate of the group.
--- @param w number The width of the group.
--- @param h number The height of the group.
--- @param components table A table containing the components to be added to the group.
--- @return table: The created group.
function Toolbar:CreateGroup(x, y, w, h, components)
    local group = UI.Rectangle:NewTLTR(x, y, 0, 0, h, self.frame:GetFrame(), 0.1757, 0.1757, 0.1875, 1);
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
                if (component.tooltips) then
                    -- we have separate tooltips
                    if (group.components[c].toggleOn) then
                        group.components[c].tooltip = component.tooltips[1];
                    else
                        group.components[c].tooltip = component.tooltips[2];
                    end

                    -- need to update the tooltip if it's currently active
                    if (Editor.ui.tooltip:IsVisible()) then
                        Editor.ui:RefreshTooltip(group.components[c].tooltip, component.tooltipDetailed);
                    end
                end
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
        elseif (component.type == "Label") then
            group.components[c] = UI.Label:New(x, 0, component.width, 22, group:GetFrame(), "LEFT", "LEFT");
            x = x + component.width;
        end

        group.components[c].type = component.type;
        group.components[c].name = component.name;
        if (component.tooltip) then
            group.components[c].tooltip = component.tooltip;
        elseif (component.tooltips) then
            if (component.default) then
                group.components[c].tooltip = component.tooltips[1];
            else
                group.components[c].tooltip = component.tooltips[2];
            end
        end
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

--- Refreshes the layout of a group in the toolbar.
--- @param group table The group to refresh.
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