local UI = SceneMachine.UI;
local L = SceneMachine.Editor.localization;
UI.PropertyFieldCheckbox = {};

--- @class PropertyFieldCheckbox : PropertyField
local PropertyFieldCheckbox = UI.PropertyFieldCheckbox;

PropertyFieldCheckbox.__index = PropertyFieldCheckbox;
setmetatable(PropertyFieldCheckbox, UI.PropertyField)

--- Creates a new instance of PropertyFieldCheckbox.
--- @param y number The y position of the checkbox.
--- @param h number The height of the checkbox.
--- @param parent table The parent object of the checkbox.
--- @param title string The title of the checkbox.
--- @param default boolean The default value of the checkbox.
--- @param onSetValue function The callback function to be called when the checkbox value is set.
--- @return PropertyFieldCheckbox: The newly created PropertyFieldCheckbox instance.
function PropertyFieldCheckbox:New(y, h, parent, title, default, onSetValue)
    --- @class PropertyFieldCheckbox : PropertyField
	local v =
    {
        y = y or 0,
        h = h or 20,
        parent = parent or nil,
        title = title or nil,
        default = default or false,
        onSetValue = onSetValue or nil,
        visible = true,
    };

	setmetatable(v, PropertyFieldCheckbox);
    v:BuildBase();
    v:Build();
	return v;
end

--- Builds the checkbox property field.
function PropertyFieldCheckbox:Build()
    local fieldPad = 2;
    self.field = self:BuildCheckboxField(self.onSetValue, self.default);
    self.field:SetPoint("RIGHT", self.fieldGroup, "RIGHT", 0, 0);
end

--- Sets the value of the checkbox field.
--- @param value boolean The value to set.
function PropertyFieldCheckbox:Set(value)
    self.field:SetChecked(value);
end

--- Sets the enabled state of the checkbox. (NYI)
--- @param enabled boolean Whether the checkbox should be enabled or disabled.
function PropertyFieldCheckbox:SetEnabled(enabled)
    --[[
    local c = 0.5;
    if (enabled) then
        c = 1;
    end

    self.field:SetEnabled(enabled);
    self.field:SetTextColor(1, 1, 1, c);
    --]]
end