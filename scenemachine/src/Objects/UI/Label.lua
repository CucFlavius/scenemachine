local Editor = SceneMachine.Editor;
local UI = SceneMachine.UI;
UI.Label = {};
local Label = UI.Label;
Label.__index = Label;
setmetatable(Label, UI.Element)

function Label:New(x, y, w, h, parent, point, parentPoint, text, textHeight, textFont)
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

	setmetatable(v, Label);
    v:Build();
	return v;
end

function Label:Build()
	self.frame = CreateFrame("Frame", "SceneMachine.UI.Label.frame", self.parent);
	self.frame:SetPoint(self.point, self.parent, self.parentPoint, self.x, self.y);
	self.frame:SetSize(self.w, self.h);
    
	self.frame.text = self.frame:CreateFontString("Zee.WindowAPI.TextBox text");
	self.frame.text:SetFont(self.textFont, self.textHeight, "NORMAL");
	self.frame.text:SetAllPoints(self.frame);
	self.frame.text:SetText(self.text);
	self.frame.text:SetJustifyV("CENTER");
	self.frame.text:SetJustifyH("LEFT");
end

function Label:SetText(text)
    self.text = text;
    self.frame.text:SetText(text);
end

function Label:GetText()
    return self.text;
end

function Label:SetJustifyH(justifyH)
    self.frame.text:SetJustifyH(justifyH);
end

function Label:SetTextColor(R, G, B, A)
    self.frame.text:SetTextColor(R, G, B, A);
end

Label.__tostring = function(self)
	return string.format("Label( %.3f, %.3f, %.3f, %.3f, %s )", self.x, self.y, self.w, self.h, self.parent);
end