SceneMachine.UI = {};

SceneMachine.UI.UI = 
{
    updateElements = {}
}

local UI = SceneMachine.UI.UI;
local Resources = SceneMachine.Resources;
local Editor = SceneMachine.Editor;

setmetatable(UI, UI)

local fields = {}

function UI:New()
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

function UI:AddElement(element)
	self.updateElements[#self.updateElements + 1] = element;
end

function UI:Update()
	for i = 1, #self.updateElements, 1 do
		if (self.updateElements[i].visible) then
        	self.updateElements[i]:Update();
		end
    end

	if (self.animateTooltip) then
		self.animateTooltipTimer = self.animateTooltipTimer + SceneMachine.deltaTime;

		local normalizedValue = self.animateTooltipTimer / self.tooltipDetailedDelay;
		self.tooltiploadingbar:SetWidth(normalizedValue * self.animateTooltipMaxSize);

		if (self.animateTooltipTimer >= self.tooltipDetailedDelay) then
			self.animateTooltipTimer = 0;
			self.animateTooltip = false;
		end
	end
end

function UI:BuildTooltip()
	self.tooltip = CreateFrame("Frame", "tooltip.frame", UIParent);
	self.tooltip:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 0, 0);
	self.tooltip:SetSize(100, 20);
	self.tooltip:SetFrameStrata(Editor.MESSAGE_BOX_FRAME_STRATA);
	self.tooltiptexture = self.tooltip:CreateTexture("tooltip.texture", "BACKGROUND");
	self.tooltiptexture:SetColorTexture(0,0,0,1);
	self.tooltiptexture:SetAllPoints(self.tooltip);
    
	self.tooltiparrow = CreateFrame("Frame", "tooltip.frame", self.tooltip);
	self.tooltiparrow:SetPoint("BOTTOMLEFT", self.tooltip, "TOPLEFT", 10, 0);
	self.tooltiparrow:SetSize(10, 10);
	self.tooltiparrowtexture = self.tooltiparrow:CreateTexture("tooltip.texture", "BACKGROUND");
	self.tooltiparrowtexture:SetColorTexture(0,0,0,1);
	self.tooltiparrowtexture:SetAllPoints(self.tooltiparrow);
	self.tooltiparrowtexture:SetVertexOffset(1, 5, 0);
	self.tooltiparrowtexture:SetVertexOffset(3, -5, 0);

	self.tooltiptext = self.tooltip:CreateFontString("Zee.WindowAPI.TextBox text");
	self.tooltiptext:SetFont(Resources.defaultFont, 9, "NORMAL");
	self.tooltiptext:SetPoint("TOPLEFT", self.tooltip, "TOPLEFT", 5, 0);
	self.tooltiptext:SetPoint("BOTTOMRIGHT", self.tooltip, "BOTTOMRIGHT", 5, 0);
	--self.tooltiptext:SetAllPoints(self.tooltip);
	self.tooltiptext:SetText("");
	self.tooltiptext:SetJustifyV("CENTER");
	self.tooltiptext:SetJustifyH("LEFT");

	self.tooltiploadingbar = CreateFrame("Frame", "tooltiploadingbar.frame", self.tooltip);
	self.tooltiploadingbar:SetPoint("BOTTOMLEFT", self.tooltip, "BOTTOMLEFT", 0, 0);
	--self.tooltiploadingbar:SetPoint("BOTTOMRIGHT", self.tooltip, "BOTTOMRIGHT", 0, 0);
	self.tooltiploadingbar:SetHeight(2);
	self.tooltiploadingbar:SetWidth(100);
	self.tooltiploadingbartexture = self.tooltiploadingbar:CreateTexture("tooltiploadingbar.texture", "BACKGROUND");
	self.tooltiploadingbartexture:SetColorTexture(1,1,1,0.2);
	self.tooltiploadingbartexture:SetAllPoints(self.tooltiploadingbar);

	self.tooltip:Hide();
end

function UI:ShowTooltip(x, y, parent, text, textDetailed)
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

function UI:HideTooltip()
	self.tooltip:Hide();
	self.tooltiploadingbar:Hide();
	if (self.holdTimerB) then
		self.holdTimerB:Cancel();
	end
	self.animateTooltip = false;
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