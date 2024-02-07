local UI = SceneMachine.UI;
UI.PropertyFieldFloat = {};
local PropertyFieldFloat = UI.PropertyFieldFloat;
PropertyFieldFloat.__index = PropertyFieldFloat;
setmetatable(PropertyFieldFloat, UI.PropertyField)

function PropertyFieldFloat:New(y, h, parent, title, default, onSetValue)
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

function PropertyFieldFloat:Build()
    local fieldPad = 2;
    self.field = self:BuildFloatField(self.onSetValue, self.default);
    self.field:SetPoint("TOPLEFT", self.fieldGroup, "TOPLEFT", 0, 0);
    self.field:SetPoint("BOTTOMRIGHT", self.fieldGroup, "BOTTOMRIGHT", -20 - fieldPad, 0);

    local resetButton = UI.Button:New(0, 0, 20, 20, self.fieldGroup, "TOPRIGHT", "TOPRIGHT", "R", nil);
    resetButton:SetScript("OnClick", function(_)
        self.field:SetText(tostring(self.default));
        self.onSetValue(self.default);
    end);
end

function PropertyFieldFloat:Set(value)
    self.field:SetText(tostring(value));
end

function PropertyFieldFloat:SetEnabled(enabled)
    local c = 0.5;
    if (enabled) then
        c = 1;
    end

    self.field:SetEnabled(enabled);
    self.field:SetTextColor(1, 1, 1, c);
end