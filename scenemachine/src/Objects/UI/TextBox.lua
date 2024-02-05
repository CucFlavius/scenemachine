local Editor = SceneMachine.Editor;
local UI = SceneMachine.UI;
UI.TextBox = {};
local TextBox = UI.TextBox;
TextBox.__index = TextBox;
setmetatable(TextBox, UI.Element)

function TextBox:New(x, y, w, h, parent, point, parentPoint, text, textHeight, textFont)
	local v = 
    {
        x = x or 0,
        y = y or 0,
        w = w or 20,
        h = h or 20,
        parent = parent or nil,
        point = point or "TOPLEFT",
        parentPoint = parentPoint or "TOPLEFT",
        text = text or nil,
        textHeight = textHeight or 9,
        textFont = textFont or Editor.ui.defaultFont,
        visible = true,
    };

	setmetatable(v, TextBox);
    v:Build();
	return v;
end

function TextBox:Build()
	self.frame = CreateFrame("EditBox", "SceneMachine.UI.EditBox.frame", self.parent);
	self.frame:SetPoint(self.point, self.parent, self.parentPoint, self.x, self.y);
	self.frame:SetSize(self.w, self.h);
	self.frame:SetFont(self.textFont, self.textHeight, "OUTLINE");
    self.frame:SetText(self.text);

	self.frame.texture = self.frame:CreateTexture("SceneMachine.UI.EditBox.frame.texture", "BACKGROUND");
	self.frame.texture:SetColorTexture(0,0,0,1);
	self.frame.texture:SetAllPoints(self.frame);
	self.frame:SetAutoFocus(false);
	self.frame:EnableMouse(true);
	self.frame:SetMaxLetters(100);
	self.frame:SetScript('OnEscapePressed', function() self.frame:ClearFocus(); Editor.ui.focused = false; end);
	self.frame:SetScript('OnEnterPressed', function() self.frame:ClearFocus(); Editor.ui.focused = false; end);
	self.frame:EnableMouse();
	self.frame:SetScript('OnMouseDown', function() self.frame:SetFocus(); end);
	self.frame:SetScript("OnEditFocusGained", function() Editor.ui.focused = true; end);
	self.frame:SetScript("OnEditFocusLost", function() Editor.ui.focused = false; end);
end

function TextBox:SetScript(handler, func)
    self.frame:SetScript(handler, func);
end

function TextBox:SetFocus()
    self.frame:SetFocus();
end

function TextBox:ClearFocus()
    self.frame:ClearFocus();
end

function TextBox:SetText(text)
    self.text = text;
    self.frame:SetText(text);
end

function TextBox:GetText()
    return self.text;
end

function TextBox:SetJustifyH(justifyH)
    self.frame:SetJustifyH(justifyH);
end

function TextBox:SetTextColor(R, G, B, A)
    self.frame:SetTextColor(R, G, B, A);
end

function TextBox:SetEnabled(on)
    self.frame:SetEnabled(on);
end

function TextBox:SetMultiLine(on)
    self.frame:SetMultiLine(on);
end

function TextBox:SetMaxLetter(number)
    self.frame:SetMaxLetters(number);
end

TextBox.__tostring = function(self)
	return string.format("TextBox( %.3f, %.3f, %.3f, %.3f, %s )", self.x, self.y, self.w, self.h, self.parent);
end