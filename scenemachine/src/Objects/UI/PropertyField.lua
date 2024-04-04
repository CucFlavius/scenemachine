local UI = SceneMachine.UI;
local Editor = SceneMachine.Editor;
UI.PropertyField = {};

--- @class PropertyField : Element
local PropertyField = UI.PropertyField;

PropertyField.__index = PropertyField;
setmetatable(PropertyField, UI.Element)

--- Builds the base structure of the PropertyField.
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

--- Builds a float field for the PropertyField class.
--- @param setValue function The function called when a value is set on the field.
--- @param default number The default value for the field.
--- @return table: The created float field.
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

--- Builds a checkbox field for the PropertyField class.
--- @param setValue function The function to be called when the checkbox value changes.
--- @param default boolean The default value for the checkbox.
--- @return table The created CheckButton object.
function PropertyField:BuildCheckboxField(setValue, default)
    --local myCheckButton = CreateFrame("CheckButton", "PropertyField.Checkbox", self.fieldGroup, "ChatConfigCheckButtonTemplate");
    --myCheckButton:SetChecked(default);
    --myCheckButton:SetScript("OnClick", function(frame) setValue(frame:GetChecked()); end)

    local checkbox = UI.Checkbox:New(-10, 0, 16, 16, self.fieldGroup, "RIGHT", "RIGHT", default, setValue);

    return checkbox;
end