local UI = SceneMachine.UI;
local Editor = SceneMachine.Editor;
UI.PropertyField = {};
local PropertyField = UI.PropertyField;
PropertyField.__index = PropertyField;
setmetatable(PropertyField, UI.Element)

function PropertyField:New(y, h, parent, title)
	local v = 
    {
        y = y or 0,
        h = h or 20,
        parent = parent or nil,
        title = title or nil,
        visible = true,
    };

	setmetatable(v, PropertyField);
    v:BuildBase();
	return v;
end

function PropertyField:BuildBase()
    local titleWidth = 80;
    local sidePad = 8;

	self.frame = CreateFrame("Frame", "SceneMachine.UI.PropertyField.frame", self.parent);
	self.frame:SetPoint("TOPLEFT", self.parent, "TOPLEFT", 0, self.y);
    self.frame:SetPoint("TOPRIGHT", self.parent, "TOPRIGHT", 0, self.y);
	self.frame:SetHeight(self.h);

    self.title = UI.Label:New(sidePad, 0, titleWidth, 20, self.frame, "LEFT", "LEFT", self.title, 9);

    self.fieldGroup = CreateFrame("Frame", "SceneMachine.UI.PropertyField.fieldGroup", self.frame);
    self.fieldGroup:SetPoint("TOPLEFT", self.frame, "TOPLEFT", titleWidth, 0);
    self.fieldGroup:SetPoint("BOTTOMRIGHT", self.frame, "BOTTOMRIGHT", -sidePad, 0);
end

function PropertyField:BuildFloatField(setValue, default)
    local transform = UI.TextBox:New(0, 0, 20, 20, self.fieldGroup, "TOPLEFT", "TOPLEFT", "0");
    transform.frame.value = default;
    transform:SetScript('OnEscapePressed', function(self)
        -- restore value
        self:SetText(tostring(self.value));
        self:ClearFocus();
        Editor.ui.focused = false;
    end);
    transform:SetScript('OnEnterPressed', function(self)
        -- set value
        local valText = self:GetText();
        if (valText == nil or valText == "") then
            valText = tostring(default);
        end
        local val = tonumber(valText);
        if (val ~= nil) then
            self.value = val;
        end
        setValue(tonumber(self:GetText()));
        self:ClearFocus();
        Editor.ui.focused = false;
    end);
    transform:SetScript('OnEditFocusLost', function(self)
        -- set value
        local valText = self:GetText();
        if (valText == nil or valText == "") then
            valText = tostring(default);
        end
        local val = tonumber(valText);
        if (val ~= nil) then
            self.value = val;
        end
        setValue(tonumber(self:GetText()));
        Editor.ui.focused = false;
    end);
    return transform;
end