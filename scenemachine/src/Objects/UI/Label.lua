local Resources = SceneMachine.Resources;
local UI = SceneMachine.UI;
UI.Label = {};

--- @class Label : Element
local Label = UI.Label;

Label.__index = Label;
setmetatable(Label, UI.Element)

--- Builds the label by creating a font string and setting its properties.
function Label:Build()
    self.text = self.values[1];
    self.textHeight = self.values[2] or 9;
    self.textFont = self.values[3] or Resources.defaultFont;

    self.frame.text = self.frame:CreateFontString("Zee.WindowAPI.TextBox text");
    self.frame.text:SetFont(self.textFont, self.textHeight, "NORMAL");
    self.frame.text:SetAllPoints(self.frame);
    self.frame.text:SetText(self.text);
    self.frame.text:SetJustifyV("CENTER");
    self.frame.text:SetJustifyH("LEFT");
end

--- Sets the text of the label.
--- @param text string The text to set.
function Label:SetText(text)
    self.text = text;
    self.frame.text:SetText(text);
end

--- Gets the text of the label.
--- @return string: The text of the label.
function Label:GetText()
    return self.text;
end

--- Returns the width of the string displayed in the label.
--- @return number: The width of the string in pixels.
function Label:GetStringWidth()
    return self.frame.text:GetStringWidth();
end

--- Sets the horizontal justification of the label's text.
--- @param justifyH string The horizontal justification to set.
function Label:SetJustifyH(justifyH)
    self.frame.text:SetJustifyH(justifyH);
end

--- Sets the text color of the label.
--- @param R number The red component of the color (0-1).
--- @param G number The green component of the color (0-1).
--- @param B number The blue component of the color (0-1).
--- @param A number The alpha component of the color (0-1).
function Label:SetTextColor(R, G, B, A)
    self.frame.text:SetTextColor(R, G, B, A);
end

Label.__tostring = function(self)
	return string.format("Label( %.3f, %.3f, %.3f, %.3f, %s )", self.x, self.y, self.w, self.h, self.parent);
end