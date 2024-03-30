local UI = SceneMachine.UI;
local ColorPicker = SceneMachine.Editor.ColorPicker;
UI.PropertyFieldColor = {};

--- @class PropertyFieldColor : PropertyField
local PropertyFieldColor = UI.PropertyFieldColor;

PropertyFieldColor.__index = PropertyFieldColor;
setmetatable(PropertyFieldColor, UI.PropertyField)

--- Creates a new instance of PropertyFieldColor.
--- @param y number? The y position of the field.
--- @param h number? The height of the field.
--- @param parent table? The parent object.
--- @param title string? The title of the field.
--- @param R number? The red component of the color.
--- @param G number? The green component of the color.
--- @param B number? The blue component of the color.
--- @param A number? The alpha component of the color.
--- @param onSetColor function? The callback function when the color is set.
--- @param onStartAction function? The callback function when the action starts.
--- @param onFinishAction function? The callback function when the action finishes.
--- @return PropertyFieldColor: The new instance of PropertyFieldColor.
function PropertyFieldColor:New(y, h, parent, title, R, G, B, A, onSetColor, onStartAction, onFinishAction)
    --- @class PropertyFieldColor : PropertyField
	local v =
    {
        y = y or 0,
        h = h or 20,
        parent = parent or nil,
        title = title or nil,
        R = R or 0,
        G = G or 0,
        B = B or 0,
        A = A or 1,
        onSetColor = onSetColor or nil,
        onStartAction = onStartAction or nil,
        onFinishAction = onFinishAction or nil,
        visible = true,
    };

	setmetatable(v, PropertyFieldColor);
    v:BuildBase();
    v:Build();
	return v;
end

--- Builds the color field for the property field.
function PropertyFieldColor:Build()
    self.colorField = CreateFrame("Button", "self.colorField", self.parent);
    self.colorField:SetPoint("TOPRIGHT", self.parent, "TOPRIGHT", -20, self.y);
    self.colorField:SetWidth(80);
    self.colorField:SetHeight(self.h);
    self.colorField.ntex = self.colorField:CreateTexture();
    self.colorField.ntex:SetColorTexture(1,1,1,1);
    self.colorField.ntex:SetAllPoints();
    self.colorField:SetNormalTexture(self.colorField.ntex);
    self.colorField.ntex:SetVertexColor(self.R, self.G, self.B, self.A);

    self.colorField:SetScript("OnClick", function(_, button, up)
        ColorPicker.Open(self.R, self.G, self.B, self.A, function(r, g, b, a)
            self:Set(r, g, b, a);
            self.onSetColor(self.R, self.G, self.B, self.A);
        end, self.onStartAction, self.onFinishAction);
    end);
end

--- Sets the color values for the PropertyFieldColor.
---@param r number The red component of the color (0-1).
---@param g number The green component of the color (0-1).
---@param b number The blue component of the color (0-1).
---@param a number The alpha component of the color (0-1).
function PropertyFieldColor:Set(r, g, b, a)
    self.R = r;
    self.G = g;
    self.B = b;
    self.A = a;
    self.colorField.ntex:SetVertexColor(self.R, self.G, self.B, self.A);
end

--- Sets the enabled state of the PropertyFieldColor. (NYI)
--- @param enabled boolean - The enabled state to set.
function PropertyFieldColor:SetEnabled(enabled)
    --[[
    local c = 0.5;
    if (enabled) then
        c = 1;
    end

    self.xField:SetEnabled(enabled);
    self.xField:SetTextColor(1, 1, 1, c);
    self.yField:SetEnabled(enabled);
    self.yField:SetTextColor(1, 1, 1, c);
    self.zField:SetEnabled(enabled);
    self.zField:SetTextColor(1, 1, 1, c);
    --]]
end