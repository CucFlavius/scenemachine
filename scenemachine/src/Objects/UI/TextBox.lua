local Editor = SceneMachine.Editor;
local Resources = SceneMachine.Resources;
local UI = SceneMachine.UI;
UI.TextBox = {};

--- @class TextBox : Element
local TextBox = UI.TextBox;

TextBox.__index = TextBox;
setmetatable(TextBox, UI.Element);

--- Creates a new TextBox object.
---@param x number? The x-coordinate of the TextBox's position.
---@param y number? The y-coordinate of the TextBox's position.
---@param w number? The width of the TextBox.
---@param h number? The height of the TextBox.
---@param parent table? The parent object of the TextBox.
---@param point string? The anchor point of the TextBox relative to its parent.
---@param parentPoint string? The anchor point of the parent object.
---@param text string? The initial text of the TextBox.
---@param textHeight number? The height of the text in the TextBox.
---@param textFont string? The font of the text in the TextBox.
---@return TextBox: The newly created TextBox object.
function TextBox:New(x, y, w, h, parent, point, parentPoint, text, textHeight, textFont)
    --- @class TextBox : Element
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
        tooltip = nil,
        tooltipDetailed = nil,
    };

    setmetatable(v, TextBox);

    v.frame = CreateFrame("EditBox", "SceneMachine.UI.TextBox.frame", v.parent);
    v.frame:SetPoint(v.point, v.parent, v.parentPoint, v.x, v.y);
    v.frame:SetSize(v.w, v.h);

    v:Build();
    return v;
end

--- Creates a new TextBox object with the specified parameters.
--- @param xA number The x-coordinate of the bottom-left corner of the TextBox.
--- @param yA number The y-coordinate of the bottom-left corner of the TextBox.
--- @param xB number The x-coordinate of the bottom-right corner of the TextBox.
--- @param yB number The y-coordinate of the bottom-right corner of the TextBox.
--- @param h number The height of the TextBox.
--- @param parent table The parent element of the TextBox.
--- @param text string The initial text to be displayed in the TextBox.
--- @param textHeight number? The height of the text in the TextBox.
--- @param textFont string? The font to be used for the text in the TextBox.
--- @return TextBox: The newly created TextBox object.
function TextBox:NewBLBR(xA, yA, xB, yB, h, parent, text, textHeight, textFont)
    --- @class TextBox : Element
    local v =
    {
        parent = parent or nil,
        text = text or nil,
        textHeight = textHeight or 9,
        textFont = textFont or Resources.defaultFont,
        visible = true,
    };

    setmetatable(v, TextBox);

    v.frame = CreateFrame("EditBox", "SceneMachine.UI.TextBox.frame", v.parent);
    v.frame:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", xA, yA);
    v.frame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", xB, yB);
    v.frame:SetHeight(h);

    v:Build();
    return v;
end

--- Creates a new TextBox object with top-left to bottom-right positioning.
--- @param xA number The x-coordinate of the top-left corner.
--- @param yA number The y-coordinate of the top-left corner.
--- @param xB number The x-coordinate of the bottom-right corner.
--- @param yB number The y-coordinate of the bottom-right corner.
--- @param h number The height of the TextBox.
--- @param parent table The parent element to attach the TextBox to.
--- @param text string The initial text to display in the TextBox.
--- @param textHeight number? The height of the text in the TextBox.
--- @param textFont string? The font to use for the text in the TextBox.
--- @return TextBox: The newly created TextBox object.
function TextBox:NewTLTR(xA, yA, xB, yB, h, parent, text, textHeight, textFont)
    --- @class TextBox : Element
    local v =
    {
        parent = parent or nil,
        text = text or nil,
        textHeight = textHeight or 9,
        textFont = textFont or Resources.defaultFont,
        visible = true,
    };

    setmetatable(v, TextBox);

    v.frame = CreateFrame("EditBox", "SceneMachine.UI.TextBox.frame", v.parent);
    v.frame:SetPoint("TOPLEFT", parent, "TOPLEFT", xA, yA);
    v.frame:SetPoint("TOPRIGHT", parent, "TOPRIGHT", xB, yB);
    v.frame:SetHeight(h);

    v:Build();
    return v;
end

--- Creates a new TextBox object with the specified parameters.
--- @param xA number The x-coordinate of the top-left corner of the TextBox.
--- @param yA number The y-coordinate of the top-left corner of the TextBox.
--- @param xB number The x-coordinate of the bottom-right corner of the TextBox.
--- @param yB number The y-coordinate of the bottom-right corner of the TextBox.
--- @param parent table The parent element to attach the TextBox to.
--- @param text string? The initial text to display in the TextBox.
--- @param textHeight number? The height of the text in the TextBox.
--- @param textFont string? The font to use for the text in the TextBox.
--- @return TextBox: The newly created TextBox object.
function TextBox:NewTLBR(xA, yA, xB, yB, parent, text, textHeight, textFont)
    --- @class TextBox : Element
    local v =
    {
        parent = parent or nil,
        text = text or nil,
        textHeight = textHeight or 9,
        textFont = textFont or Resources.defaultFont,
        visible = true,
    };

    setmetatable(v, TextBox);

    v.frame = CreateFrame("EditBox", "SceneMachine.UI.TextBox.frame", v.parent);
    v.frame:SetPoint("TOPLEFT", parent, "TOPLEFT", xA, yA);
    v.frame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", xB, yB);

    v:Build();
    return v;
end

--- Builds the TextBox UI element.
function TextBox:Build()
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