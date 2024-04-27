SceneMachine.UI.UI = 
{
    updateElements = {}
}

--- @class UI
local UI = SceneMachine.UI.UI;

local Resources = SceneMachine.Resources;
local Editor = SceneMachine.Editor;

setmetatable(UI, UI)

local fields = {}

--- Creates a new instance of the UI class.
--- @return UI: The newly created UI instance.
function UI:New()
	--- @class UI
	local v =
	{
		updateElements = {},
		focused = false,
		tooltipDelay = 0.5,
		tooltipDetailedDelay = 1.5,
		animateTooltip = false,
		animateTooltipTimer = 0.0;
		animateTooltipMaxSize = 0;
	};

	setmetatable(v, UI);
	v:BuildTooltip();
	return v;
end

--- Adds an element to the UI.
--- @param element table The element to be added.
function UI:AddElement(element)
	self.updateElements[#self.updateElements + 1] = element;
end

--- Updates the UI elements and animates the tooltip if necessary.
function UI:Update()
	-- Update visible elements
	for i = 1, #self.updateElements, 1 do
		if (self.updateElements[i].visible) then
			self.updateElements[i]:Update();
		end
	end

	-- Animate tooltip if enabled
	if (self.animateTooltip) then
		self.animateTooltipTimer = self.animateTooltipTimer + SceneMachine.deltaTime;

		-- Calculate normalized value for tooltip animation
		local normalizedValue = self.animateTooltipTimer / self.tooltipDetailedDelay;
		self.tooltiploadingbar:SetWidth(normalizedValue * self.animateTooltipMaxSize);

		-- Check if animation is complete
		if (self.animateTooltipTimer >= self.tooltipDetailedDelay) then
			self.animateTooltipTimer = 0;
			self.animateTooltip = false;
		end
	end
end

--- Builds the tooltip frame and its components
function UI:BuildTooltip()
	-- Create the main tooltip frame
	self.tooltip = CreateFrame("Frame", "tooltip.frame", UIParent);
	self.tooltip:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 0, 0);
	self.tooltip:SetSize(100, 20);
	self.tooltip:SetFrameStrata(Editor.MESSAGE_BOX_FRAME_STRATA);

	-- Create the background texture for the tooltip frame
	self.tooltiptexture = self.tooltip:CreateTexture("tooltip.texture", "BACKGROUND");
	self.tooltiptexture:SetColorTexture(0,0,0,1);
	self.tooltiptexture:SetAllPoints(self.tooltip);

	-- Create the arrow frame for the tooltip
	self.tooltiparrow = CreateFrame("Frame", "tooltip.frame", self.tooltip);
	self.tooltiparrow:SetPoint("BOTTOMLEFT", self.tooltip, "TOPLEFT", 10, 0);
	self.tooltiparrow:SetSize(10, 10);

	-- Create the background texture for the tooltip arrow
	self.tooltiparrowtexture = self.tooltiparrow:CreateTexture("tooltip.texture", "BACKGROUND");
	self.tooltiparrowtexture:SetColorTexture(0,0,0,1);
	self.tooltiparrowtexture:SetAllPoints(self.tooltiparrow);
	self.tooltiparrowtexture:SetVertexOffset(1, 5, 0);
	self.tooltiparrowtexture:SetVertexOffset(3, -5, 0);

	-- Create the text for the tooltip
	self.tooltiptext = self.tooltip:CreateFontString("Zee.WindowAPI.TextBox text");
	self.tooltiptext:SetFont(Resources.defaultFont, Resources.defaultFontSize, "NORMAL");
	self.tooltiptext:SetPoint("TOPLEFT", self.tooltip, "TOPLEFT", 5, 0);
	self.tooltiptext:SetPoint("BOTTOMRIGHT", self.tooltip, "BOTTOMRIGHT", 5, 0);
	self.tooltiptext:SetText("");
	self.tooltiptext:SetJustifyV("MIDDLE");
	self.tooltiptext:SetJustifyH("LEFT");

	-- Create the loading bar for the tooltip
	self.tooltiploadingbar = CreateFrame("Frame", "tooltiploadingbar.frame", self.tooltip);
	self.tooltiploadingbar:SetPoint("BOTTOMLEFT", self.tooltip, "BOTTOMLEFT", 0, 0);
	self.tooltiploadingbar:SetHeight(2);
	self.tooltiploadingbar:SetWidth(100);

	-- Create the background texture for the loading bar
	self.tooltiploadingbartexture = self.tooltiploadingbar:CreateTexture("tooltiploadingbar.texture", "BACKGROUND");
	self.tooltiploadingbartexture:SetColorTexture(1,1,1,0.2);
	self.tooltiploadingbartexture:SetAllPoints(self.tooltiploadingbar);

	-- Hide the tooltip initially
	self.tooltip:Hide();
end

--- Refreshes the tooltip with the specified text and detailed text.
--- @param text string The main text to display in the tooltip.
--- @param textDetailed string (optional) The detailed text to display in the tooltip.
function UI:RefreshTooltip(text, textDetailed)
	self:ShowTooltip(self.tooltip.x, self.tooltip.y, self.tooltip.parent, text, textDetailed);
end

--- Shows a tooltip at the specified position with the given text.
--- @param x number The x-coordinate of the tooltip position.
--- @param y number The y-coordinate of the tooltip position.
--- @param parent table The parent frame of the tooltip.
--- @param text string The main text to display in the tooltip.
--- @param textDetailed string? Additional detailed text to display in the tooltip.
function UI:ShowTooltip(x, y, parent, text, textDetailed)
	self.tooltip.x = x;
	self.tooltip.y = y;
	self.tooltip.parent = parent;
	self.tooltip:Show();
	self.tooltip:ClearAllPoints();
	self.tooltip:SetParent(parent);
	self.tooltip:SetPoint("TOPLEFT", parent, "BOTTOMLEFT", x - 15, y - 10);
	self.tooltiptext:SetWidth(1000);
	self.tooltiptext:SetHeight(1000);
	self.tooltiptext:SetText(text);
	local strW = self.tooltiptext:GetStringWidth();
	local strH = self.tooltiptext:GetStringHeight();
	self.tooltip:SetWidth(strW + 10);
	self.tooltip:SetHeight(strH + 10);
	if (strW + 10 < 30) then
		self.tooltiparrow:ClearAllPoints();
		self.tooltiparrow:SetPoint("BOTTOMLEFT", self.tooltip, "TOPLEFT", 0, 0);
	else
		self.tooltiparrow:ClearAllPoints();
		self.tooltiparrow:SetPoint("BOTTOMLEFT", self.tooltip, "TOPLEFT", 10, 0);
	end
	self.tooltip:SetParent(SceneMachine.mainWindow:GetFrame());
	self.tooltip:SetFrameStrata(Editor.MESSAGE_BOX_FRAME_STRATA);
	self.tooltip:SetFrameLevel(1000);
	self.tooltiploadingbar:Hide();
	if (textDetailed) then
		self.animateTooltip = true;
		self.animateTooltipTimer = 0.0;
		self.animateTooltipMaxSize = strW + 10;
		self.tooltiploadingbar:Show();
		self.holdTimerB = C_Timer.NewTimer(self.tooltipDetailedDelay, function()
			self:ShowTooltip(x, y, parent, textDetailed);
			self.tooltiploadingbar:Hide();
		end);
	end
end

--- Hides the tooltip and related elements.
function UI:HideTooltip()
	self.tooltip:Hide();
	self.tooltiploadingbar:Hide();
	if (self.holdTimerB) then
		self.holdTimerB:Cancel();
	end
	self.animateTooltip = false;
end

--- Adds a backdrop shadow to a frame.
--- @param frame table The frame to add the backdrop shadow to.
--- @param oX number The offset in the x-axis for the shadow position (optional, default is 0).
--- @param oY number The offset in the y-axis for the shadow position (optional, default is 0).
--- @param oW number The offset in the width for the shadow position (optional, default is 0).
--- @param oH number The offset in the height for the shadow position (optional, default is 0).
function SceneMachine.UI.AddBackdropShadow(frame, oX, oY, oW, oH)
	oX = oX or 0;
	oY = oY or 0;
	oW = oW or 0;
	oH = oH or 0;

	local backdropInfo =
	{
		edgeFile = Resources.textures["Dropshadow"],
		tileEdge = true,
		edgeSize = 32,
	}
	
	frame.shadow = CreateFrame("Frame", nil, frame, "BackdropTemplate");
	local size = 8;
	frame.shadow:SetPoint("TOPLEFT", -size - oX, size + oY);
	frame.shadow:SetPoint("BOTTOMRIGHT", size + oW, -size - oH);
	frame.shadow:SetFrameLevel(max(0, frame:GetFrameLevel()-10));
	frame.shadow:SetBackdrop(backdropInfo);
	frame.shadow:SetAlpha(0.4);
end

UI.__tostring = function(self)
	return "UI";
end

UI.__index = function(t,k)
	local var = rawget(UI, k)
		
	if var == nil then							
		var = rawget(fields, k)
		
		if var ~= nil then
			return var(t)	
		end
	end
	
	return var
end