local Resources = SceneMachine.Resources;
local UI = SceneMachine.UI;
UI.Label = {};

--- @class Label : Element
local Label = UI.Label;

Label.__index = Label;
setmetatable(Label, UI.Element)

--- Creates a new Label object.
--- @param x number? The x-coordinate of the label's position.
--- @param y number? The y-coordinate of the label's position.
--- @param w number? The width of the label.
--- @param h number? The height of the label.
--- @param parent table? The parent element of the label.
--- @param point string? The anchor point of the label relative to its parent.
--- @param parentPoint string? The anchor point of the parent element.
--- @param text string? The text to be displayed on the label.
--- @param textHeight number? The height of the text.
--- @param textFont string? The font to be used for the text.
--- @return Label: The newly created Label object.
function Label:New(x, y, w, h, parent, point, parentPoint, text, textHeight, textFont)
    --- @class Label : Element
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
        textFont = textFont or Resources.defaultFont,
        visible = true,
    };

	setmetatable(v, Label);

	v.frame = CreateFrame("Frame", "SceneMachine.UI.Label.frame", v.parent);
	v.frame:SetPoint(v.point, v.parent, v.parentPoint, v.x, v.y);
	v.frame:SetSize(v.w, v.h);

    v:Build();
	return v;
end

--- Creates a new Label object with top-left to top-right positioning.
--- @param xA number: The x-coordinate of the top-left corner.
--- @param yA number: The y-coordinate of the top-left corner.
--- @param xB number: The x-coordinate of the top-right corner.
--- @param yB number: The y-coordinate of the top-right corner.
--- @param h number: The height of the label.
--- @param parent table: The parent element to attach the label to.
--- @param text string: The text to display in the label.
--- @param textHeight number: The height of the text.
--- @param textFont string: The font to use for the text.
--- @return Label: The newly created Label object.
function Label:NewTLTR(xA, yA, xB, yB, h, parent, text, textHeight, textFont)
    --- @class Label : Element
    local v =
    {
        parent = parent or nil,
        text = text or nil,
        textHeight = textHeight or 9,
        textFont = textFont or Resources.defaultFont,
        visible = true,
    };

    setmetatable(v, Label);

    v.frame = CreateFrame("Frame", "SceneMachine.UI.Label.frame", parent);
    v.frame:SetPoint("TOPLEFT", parent, "TOPLEFT", xA, yA);
    v.frame:SetPoint("TOPRIGHT", parent, "TOPRIGHT", xB, yB);
    v.frame:SetHeight(h);

    v:Build();
    return v;
end

--- Creates a new Label object.
--- @param xA number The x-coordinate of the left anchor point.
--- @param yA number The y-coordinate of the left anchor point.
--- @param xB number The x-coordinate of the right anchor point.
--- @param yB number The y-coordinate of the right anchor point.
--- @param h number The height of the label.
--- @param parent table? The parent element.
--- @param text string? The text to display on the label.
--- @param textHeight number? The height of the text.
--- @param textFont table? The font to use for the text.
--- @return Label: The newly created Label object.
function Label:NewLR(xA, yA, xB, yB, h, parent, text, textHeight, textFont)
    --- @class Label : Element
    local v =
    {
        parent = parent or nil,
        text = text or nil,
        textHeight = textHeight or 9,
        textFont = textFont or Resources.defaultFont,
        visible = true,
    };

    setmetatable(v, Label);

    v.frame = CreateFrame("Frame", "SceneMachine.UI.Label.frame", v.parent);
    v.frame:SetPoint("LEFT", parent, "LEFT", xA, yA);
    v.frame:SetPoint("RIGHT", parent, "RIGHT", xB, yB);
    v.frame:SetHeight(h);

    v:Build();
    return v;
end

--- Creates a new Label object with a bottom-left and bottom-right position, height, parent, text, text height, and text font.
--- @param xA number The x-coordinate of the bottom-left position.
--- @param yA number The y-coordinate of the bottom-left position.
--- @param xB number The x-coordinate of the bottom-right position.
--- @param yB number The y-coordinate of the bottom-right position.
--- @param h number The height of the label.
--- @param parent table? The parent frame of the label.
--- @param text string? The text to be displayed on the label.
--- @param textHeight number? The height of the text.
--- @param textFont string? The font of the text.
--- @return Label: The newly created Label object.
function Label:NewBLBR(xA, yA, xB, yB, h, parent, text, textHeight, textFont)
    --- @class Label : Element
    local v =
    {
        parent = parent or nil,
        text = text or nil,
        textHeight = textHeight or 9,
        textFont = textFont or Resources.defaultFont,
        visible = true,
    };

    setmetatable(v, Label);

    v.frame = CreateFrame("Frame", "SceneMachine.UI.Label.frame", v.parent);
    v.frame:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", xA, yA);
    v.frame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", xB, yB);
    v.frame:SetHeight(h);

    v:Build();
    return v;
end

--- Builds the label by creating a font string and setting its properties.
function Label:Build()
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