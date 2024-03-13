local UI = SceneMachine.UI;
local L = SceneMachine.Editor.localization;
UI.PropertyFieldCheckbox = {};
local PropertyFieldCheckbox = UI.PropertyFieldCheckbox;
local Resources = SceneMachine.Resources;
PropertyFieldCheckbox.__index = PropertyFieldCheckbox;
setmetatable(PropertyFieldCheckbox, UI.PropertyField)

function PropertyFieldCheckbox:New(y, h, parent, title, default, onSetValue)
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

	setmetatable(v, PropertyFieldCheckbox);
    v:BuildBase();
    v:Build();
	return v;
end

function PropertyFieldCheckbox:Build()
    local fieldPad = 2;
    self.field = self:BuildCheckboxField(self.onSetValue, self.default);
    self.field:SetPoint("RIGHT", self.fieldGroup, "RIGHT", 0, 0);
end

function PropertyFieldCheckbox:Set(value)
    self.field:SetChecked(value);
end

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