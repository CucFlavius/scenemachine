local Editor = SceneMachine.Editor;
local Resources = SceneMachine.Resources;
local L = Editor.localization;
local UI = SceneMachine.UI;
UI.ScrollableTextBox = {};

--- @class ScrollableTextBox : Element
local ScrollableTextBox = UI.ScrollableTextBox;

ScrollableTextBox.__index = ScrollableTextBox;
setmetatable(ScrollableTextBox, UI.Element);

-- the scrollable edit box is a bit awful because it's two frames wrapped around the actual editbox
-- object
--   frame
--     scrollbox
--       editBox

-- to get the editbox or scrollbox from the object, use the accessors
--  object:GetEditBox()
--  object:GetScrollBox()

--- Builds the scrollable text box.
function ScrollableTextBox:Build()
    self.text = self.values[1];
    self.textHeight = self.values[2];
    self.textFont = self.values[3];
    self.includeScrollButtons = self.values[4];

    local editBox = self.frame:GetEditBox();
	editBox:SetFont(self.textFont, self.textHeight, "OUTLINE");
    editBox:SetText(self.text);
    editBox.fontName = self.textFont;
    editBox.scrollable = true;

	self.frame.texture = self.frame:CreateTexture("SceneMachine.UI.ScrollableEditBox.frame.texture", "BACKGROUND");
	self.frame.texture:SetColorTexture(0,0,0,0.5);
	self.frame.texture:SetAllPoints(self.frame);
	editBox:SetAutoFocus(false);
	editBox:EnableMouse(true);
	editBox:SetMaxLetters(250); -- higher limit cause if it's scrollable, it's probably got more to say
	editBox:SetScript('OnEscapePressed', function() editBox:ClearFocus(); Editor.ui.focused = false; end);
	editBox:SetScript('OnEnterPressed', function() editBox:ClearFocus(); Editor.ui.focused = false; end);
	editBox:SetScript('OnMouseDown', function() editBox:SetFocus(); end);
	editBox:SetScript("OnEditFocusGained", function() Editor.ui.focused = true; end);
	editBox:SetScript("OnEditFocusLost", function() Editor.ui.focused = false; end);
    editBox:SetScript("OnTextChanged", function() self:SetText(editBox:GetText(), true); end);
    editBox:SetScript("OnEnter", function ()
		if (self.tooltip) then
			self.holdTimer = C_Timer.NewTimer(Editor.ui.tooltipDelay, function()
				Editor.ui:ShowTooltip(self.w / 2, 0, editBox, self.tooltip, self.tooltipDetailed);
			end);
		end
	end);
	editBox:SetScript("OnLeave", function ()
        if (self.holdTimer) then
            self.holdTimer:Cancel();
            Editor.ui:HideTooltip();
        end
	end);

    if self.includeScrollButtons then
        -- scroll buttons
        local scrollBox = self:GetScrollBox();
        TEST_SCROLLBOX = scrollBox;
        local bLevel = scrollBox:GetFrameLevel() + 1;

        local btxOffset, btyOffset = -20, 40;
        local bWidth, bHeight = 15, 15;
        self.scrollButtonTop = UI.Button:New(btxOffset, btyOffset, bWidth, bHeight, self.parent, "BOTTOMRIGHT", "BOTTOMRIGHT", nil, Resources.textures.ResizeArrowV, {0, 1, 0, 0.5});
        self.scrollButtonTop:GetFrame():SetFrameLevel(bLevel);
        self.scrollButtonTop:SetScript("OnClick", function() scrollBox:ScrollToBegin(); end);
        self.scrollButtonTop.tooltip = L["SCROLL_TOP"]; -- TODO: make tooltips able to show from any side of the frame instead of just the bottom

        local bbxOffset, bbyOffset = btxOffset, 20;
        self.scrollButtonBottom = UI.Button:New(bbxOffset, bbyOffset, bWidth, bHeight, self.parent, "BOTTOMRIGHT", "BOTTOMRIGHT", nil, Resources.textures.ResizeArrowV, {0, 1, 0.5, 1});
        self.scrollButtonBottom:GetFrame():SetFrameLevel(bLevel);
        self.scrollButtonBottom:SetScript("OnClick", function() scrollBox:ScrollToEnd(); end);
        self.scrollButtonBottom.tooltip = L["SCROLL_BOTTOM"]; -- TODO: make tooltips able to show from any side of the frame instead of just the bottom

        -- reactivity
        local function UpdateScrollButtonVisibility()
            if not scrollBox:HasScrollableExtent() then
                self.scrollButtonTop:Hide();
                self.scrollButtonBottom:Hide();
                return;
            end

            local scrollPercentage = scrollBox:CalculateScrollPercentage();
            self.scrollButtonTop:GetFrame():SetShown(scrollPercentage ~= 0);
            self.scrollButtonBottom:GetFrame():SetShown(scrollPercentage ~= 1);
        end

        scrollBox:RegisterCallback(BaseScrollBoxEvents.OnScroll, UpdateScrollButtonVisibility);
    end
end

--- Sets the script for the ScrollableTextBox.
--- @param handler string The name of the script handler.
--- @param func function The function to be executed when the script is triggered.
function ScrollableTextBox:SetScript(handler, func)
    self.frame:GetEditBox():SetScript(handler, func);
end

--- Sets the focus on the scrollable text box.
function ScrollableTextBox:SetFocus()
    self.frame:GetEditBox():SetFocus();
end

--- Clears the focus from the scrollable text box.
function ScrollableTextBox:ClearFocus()
    self.frame:GetEditBox():ClearFocus();
end

--- Sets the text of the scrollable text box.
--- @param text string The text to set.
--- @param skipUpdate boolean (optional) Whether to skip updating the edit box. Defaults to false.
function ScrollableTextBox:SetText(text, skipUpdate)
    if (text) then
        self.text = text;
        if not skipUpdate then
            self.frame:GetEditBox():SetText(text);
        end
    end
end

--- Gets the text of the scrollable text box.
--- @return string: The text of the scrollable text box.
function ScrollableTextBox:GetText()
    return self.text;
end

--- Retrieves the edit box associated with the scrollable text box.
--- @return table: The edit box associated with the scrollable text box.
function ScrollableTextBox:GetEditBox()
    return self.frame:GetEditBox();
end

--- Retrieves the scroll box associated with the scrollable text box.
--- @return table: The scroll box associated with the scrollable text box.
function ScrollableTextBox:GetScrollBox()
    return self.frame:GetScrollBox();
end

--- Sets the horizontal justification of the scrollable text box.
--- @param justifyH string The horizontal justification value to set.
function ScrollableTextBox:SetJustifyH(justifyH)
    self.frame:GetEditBox():SetJustifyH(justifyH);
end

--- Sets the text color of the scrollable text box.
--- @param R number: The red component of the color (0-1).
--- @param G number: The green component of the color (0-1).
--- @param B number: The blue component of the color (0-1).
--- @param A number: The alpha component of the color (0-1).
function ScrollableTextBox:SetTextColor(R, G, B, A)
    self.frame:GetEditBox():SetTextColor(R, G, B, A);
end

--- Sets the enabled state of the ScrollableTextBox.
--- @param on boolean Whether the ScrollableTextBox should be enabled or not.
function ScrollableTextBox:SetEnabled(on)
    self.frame:GetEditBox():SetEnabled(on);
end

--- Sets whether the text box should allow multiple lines.
--- @param on boolean Whether to enable or disable multi-line mode.
function ScrollableTextBox:SetMultiLine(on)
    self.frame:GetEditBox():SetMultiLine(on);
end

--- Sets the maximum number of letters allowed in the scrollable text box.
--- @param number number The maximum number of letters.
function ScrollableTextBox:SetMaxLetters(number)
    self.frame:GetEditBox():SetMaxLetters(number);
end

--- Sets whether the scroll should be interpolated.
--- @param interpolate boolean Whether to interpolate the scroll.
function ScrollableTextBox:SetInterpolateScroll(interpolate)
    self.frame:SetInterpolateScroll(interpolate);
end

ScrollableTextBox.__tostring = function(self)
	return string.format("ScrollableTextBox( %.3f, %.3f, %.3f, %.3f, %s )", self.x, self.y, self.w, self.h, self.parent);
end