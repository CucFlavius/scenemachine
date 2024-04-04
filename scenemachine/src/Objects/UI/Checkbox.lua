local Resources = SceneMachine.Resources;
local UI = SceneMachine.UI;
local Editor = SceneMachine.Editor;
UI.Checkbox = {};

--- @class Checkbox : Element
local Checkbox = UI.Checkbox;

Checkbox.__index = Checkbox;
setmetatable(Checkbox, UI.Element)

function Checkbox:GetFrameType()
    return "Button";
end

--- Builds the Checkbox by creating and configuring its textures, icon, and text.
function Checkbox:Build()
    self.defaultValue = self.values[1] or false;
    self.onCheck = self.values[2];

    self.checked = self.defaultValue;

    -- normal texture
    self.ntex = self.frame:CreateTexture();
    self.ntex:SetColorTexture(0, 0, 0, 0.5);
    self.ntex:SetAllPoints();
    self.frame:SetNormalTexture(self.ntex);

    self.checkmark = UI.ImageBox:New(0, 0, self.frame:GetWidth(), self.frame:GetWidth(), self.frame, "CENTER", "CENTER", Resources.textures["Checkbox"], { 0.5, 1, 0, 1 });

    if (self.defaultValue) then
        self.checkmark:Show();
    else
        self.checkmark:Hide();
    end

    self.frame:SetScript("OnClick", function()
        self:SetChecked(not self:GetChecked());
    end);

    -- tooltip
    self.frame:SetScript("OnEnter", function ()
        if (self.tooltip) then
            self.holdTimer = C_Timer.NewTimer(Editor.ui.tooltipDelay, function()
                Editor.ui:ShowTooltip(self:GetWidth() / 2, 0, self.frame, self.tooltip, self.tooltipDetailed);
            end);
        end
    end);
    self.frame:SetScript("OnLeave", function ()
        if (self.holdTimer) then
            self.holdTimer:Cancel();
            Editor.ui:HideTooltip();
        end
    end);
end

--- Sets the checked state of the checkbox.
--- @param checked boolean The checked state to set.
function Checkbox:SetChecked(checked)
    self.checked = checked;
    if (checked) then
        self.checkmark:Show();
    else
        self.checkmark:Hide();
    end
    if (self.onCheck) then
        self.onCheck(checked);
    end
end

--- Gets the checked state of the checkbox.
--- @return boolean: The checked state of the checkbox.
function Checkbox:GetChecked()
    return self.checked;
end

Checkbox.__tostring = function(self)
	return string.format("Checkbox( %.3f, %.3f, %.3f, %.3f )", self.x, self.y, self.w, self.h);
end