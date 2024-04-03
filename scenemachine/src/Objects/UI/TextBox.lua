local Editor = SceneMachine.Editor;
local Resources = SceneMachine.Resources;
local UI = SceneMachine.UI;
UI.TextBox = {};

--- @class TextBox : Element
local TextBox = UI.TextBox;

TextBox.__index = TextBox;
setmetatable(TextBox, UI.Element);

function TextBox:GetFrameType()
    return "EditBox";
end

--- Builds the TextBox UI element.
function TextBox:Build()
    self.text = self.values[1];
    self.textHeight = self.values[2] or 9;
    self.textFont = self.values[3] or Resources.defaultFont;

    -- Create the frame
    self.frame:SetFont(self.textFont, self.textHeight, "OUTLINE");
    self.frame:SetText(self.text);

    -- Create the texture
    self.frame.texture = self.frame:CreateTexture("SceneMachine.UI.EditBox.frame.texture", "BACKGROUND");
    self.frame.texture:SetColorTexture(0,0,0,0.5);
    self.frame.texture:SetAllPoints(self.frame);

    -- Configure the frame
    self.frame:SetAutoFocus(false);
    self.frame:EnableMouse(true);
    self.frame:SetMaxLetters(100);

    -- Set script handlers
    self.frame:SetScript('OnEscapePressed', function() self.frame:ClearFocus(); Editor.ui.focused = false; end);
    self.frame:SetScript('OnEnterPressed', function() self.frame:ClearFocus(); Editor.ui.focused = false; end);
    self.frame:SetScript('OnMouseDown', function() self.frame:SetFocus(); end);
    self.frame:SetScript("OnEditFocusGained", function() Editor.ui.focused = true; end);
    self.frame:SetScript("OnEditFocusLost", function() Editor.ui.focused = false; end);
    self.frame:SetScript("OnEnter", function ()
        if (self.tooltip) then
            self.holdTimer = C_Timer.NewTimer(Editor.ui.tooltipDelay, function()
                Editor.ui:ShowTooltip(self.w / 2, 0, self.frame, self.tooltip, self.tooltipDetailed);
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

--- Sets the script for the TextBox.
--- @param handler string The name of the script handler.
--- @param func function The function to be executed when the script is triggered.
function TextBox:SetScript(handler, func)
    self.frame:SetScript(handler, func);
end

--- Sets the focus on the text box.
function TextBox:SetFocus()
    self.frame:SetFocus();
end

--- Clears the focus from the text box.
function TextBox:ClearFocus()
    self.frame:ClearFocus();
end

--- Sets the text of the TextBox.
--- @param text string The text to set.
function TextBox:SetText(text)
    self.text = text;
    self.frame:SetText(text);
end

--- Gets the text of the TextBox.
--- @return string The text of the TextBox.
function TextBox:GetText()
    return self.text;
end

--- Sets the horizontal justification of the TextBox.
--- @param justifyH string The horizontal justification to set.
function TextBox:SetJustifyH(justifyH)
    self.frame:SetJustifyH(justifyH);
end

--- Sets the text color of the TextBox.
--- @param R number The red component of the color (0-1).
--- @param G number The green component of the color (0-1).
--- @param B number The blue component of the color (0-1).
--- @param A number The alpha component of the color (0-1).
function TextBox:SetTextColor(R, G, B, A)
    self.frame:SetTextColor(R, G, B, A);
end

--- Sets the enabled state of the TextBox.
--- @param on boolean Whether the TextBox should be enabled or disabled.
function TextBox:SetEnabled(on)
    self.frame:SetEnabled(on);
end

--- Sets whether the TextBox should allow multiple lines of text.
--- @param on boolean Whether to enable or disable multi-line mode.
function TextBox:SetMultiLine(on)
    self.frame:SetMultiLine(on);
end

--- Sets the maximum number of letters allowed in the text box.
--- @param number number The maximum number of letters.
function TextBox:SetMaxLetters(number)
    self.frame:SetMaxLetters(number);
end

TextBox.__tostring = function(self)
	return string.format("TextBox( %.3f, %.3f, %.3f, %.3f, %s )", self.x, self.y, self.w, self.h, self.parent);
end