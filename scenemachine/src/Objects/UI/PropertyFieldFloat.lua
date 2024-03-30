local UI = SceneMachine.UI;
local L = SceneMachine.Editor.localization;
UI.PropertyFieldFloat = {};

--- @class PropertyFieldFloat : PropertyField
local PropertyFieldFloat = UI.PropertyFieldFloat;

local Resources = SceneMachine.Resources;
PropertyFieldFloat.__index = PropertyFieldFloat;
setmetatable(PropertyFieldFloat, UI.PropertyField)

--- Creates a new instance of PropertyFieldFloat.
---@param y number? The y position of the field.
---@param h number? The height of the field.
---@param parent table? The parent object.
---@param title string? The title of the field.
---@param default number? The default value of the field.
---@param onSetValue function? The callback function to be called when the value changes.
---@return PropertyFieldFloat: The new instance of PropertyFieldFloat.
function PropertyFieldFloat:New(y, h, parent, title, default, onSetValue)
    --- @class PropertyFieldFloat : PropertyField
	local v =
    {
        y = y or 0,
        h = h or 20,
        parent = parent or nil,
        title = title or nil,
        default = default or 0,
        onSetValue = onSetValue or nil,
        visible = true,
    };

	setmetatable(v, PropertyFieldFloat);
    v:BuildBase();
    v:Build();
	return v;
end

--- Builds the PropertyFieldFloat UI element.
function PropertyFieldFloat:Build()
    local fieldPad = 2;
    self.field = self:BuildFloatField(self.onSetValue, self.default);
    self.field:SetPoint("TOPLEFT", self.fieldGroup, "TOPLEFT", 0, 0);
    self.field:SetPoint("BOTTOMRIGHT", self.fieldGroup, "BOTTOMRIGHT", -20 - fieldPad, 0);

    local resetButton = UI.Button:New(0, 0, 20, 20, self.fieldGroup, "TOPRIGHT", "TOPRIGHT", nil, Resources.textures["ResetIcon"]);
    resetButton:SetScript("OnClick", function(_)
        self.field:SetText(tostring(self.default));
        self.onSetValue(self.default);
    end);
    resetButton.tooltip = L["OP_TT_RESET_VALUE"];
end

--- Sets the value of the PropertyFieldFloat.
--- @param value number The new value to set.
function PropertyFieldFloat:Set(value)
    self.field:SetText(tostring(value));
end

--- Sets the enabled state of the PropertyFieldFloat.
--- @param enabled boolean - Whether the PropertyFieldFloat should be enabled or disabled.
function PropertyFieldFloat:SetEnabled(enabled)
    local c = 0.5;
    if (enabled) then
        c = 1;
    end

    self.field:SetEnabled(enabled);
    self.field:SetTextColor(1, 1, 1, c);
end