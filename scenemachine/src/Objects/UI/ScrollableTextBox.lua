local Editor = SceneMachine.Editor;
local Resources = SceneMachine.Resources;
local L = Editor.localization;
local UI = SceneMachine.UI;
UI.ScrollableTextBox = {};
local ScrollableTextBox = UI.ScrollableTextBox;
ScrollableTextBox.__index = ScrollableTextBox;
setmetatable(ScrollableTextBox, UI.Element);

function ScrollableTextBox:New(x, y, w, h, parent, point, parentPoint, text, textHeight, textFont, includeScrollButtons)
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
        includeScrollButtons = includeScrollButtons or false,
        visible = true,
    };

	setmetatable(v, ScrollableTextBox);
    v:Build();
	return v;
end

-- the scrollable edit box is a bit awful because it's two frames wrapped around the actual editbox
-- object
--   frame
--     scrollbox
--       editBox

-- to get the editbox or scrollbox from the object, use the accessors
--  object:GetEditBox()
--  object:GetScrollBox()

function ScrollableTextBox:Build()
	self.frame = CreateFrame("Frame", "SceneMachine.UI.ScrollableEditBox.frame", self.parent, "ScrollingEditBoxTemplate");
	self.frame:SetPoint(self.point, self.parent, self.parentPoint, self.x, self.y);
	self.frame:SetSize(self.w, self.h);

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

function ScrollableTextBox:SetScript(handler, func)
    self.frame:GetEditBox():SetScript(handler, func);
end

function ScrollableTextBox:SetFocus()
    self.frame:GetEditBox():SetFocus();
end

function ScrollableTextBox:ClearFocus()
    self.frame:GetEditBox():ClearFocus();
end

function ScrollableTextBox:SetText(text, skipUpdate)
    self.text = text;
    if not skipUpdate then
        self.frame:GetEditBox():SetText(text);
    end
end

function ScrollableTextBox:GetText()
    return self.text;
end

function ScrollableTextBox:GetEditBox()
    return self.frame:GetEditBox();
end

function ScrollableTextBox:GetScrollBox()
    return self.frame:GetScrollBox();
end

function ScrollableTextBox:SetJustifyH(justifyH)
    self.frame:GetEditBox():SetJustifyH(justifyH);
end

function ScrollableTextBox:SetTextColor(R, G, B, A)
    self.frame:GetEditBox():SetTextColor(R, G, B, A);
end

function ScrollableTextBox:SetEnabled(on)
    self.frame:GetEditBox():SetEnabled(on);
end

function ScrollableTextBox:SetMultiLine(on)
    self.frame:GetEditBox():SetMultiLine(on);
end

function ScrollableTextBox:SetMaxLetters(number)
    self.frame:GetEditBox():SetMaxLetters(number);
end

function ScrollableTextBox:SetInterpolateScroll(interpolate)
    self.frame:SetInterpolateScroll(interpolate);
end

ScrollableTextBox.__tostring = function(self)
	return string.format("ScrollableTextBox( %.3f, %.3f, %.3f, %.3f, %s )", self.x, self.y, self.w, self.h, self.parent);
end