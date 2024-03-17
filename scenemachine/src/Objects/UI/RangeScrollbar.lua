local Editor = SceneMachine.Editor; -- reference needed for Update loop
local UI = SceneMachine.UI;
local Resources = SceneMachine.Resources;
local Input = SceneMachine.Input;

SceneMachine.UI.RangeScrollbar = {};
local RangeScrollbar = SceneMachine.UI.RangeScrollbar;
RangeScrollbar.__index = RangeScrollbar;
setmetatable(RangeScrollbar, SceneMachine.UI.Element)

function RangeScrollbar:New(x, y, h, parent, onRangeChange)
	local v = 
    {
        x = x or 0,
        y = y or 0,
        h = h or 20,
        parent = parent or nil,
        inputState = {
            movingMin = false;
            movingMax = false;
            movingCenter = false;
            mousePosStartX = 0;
            minFramePosStart = 0;
            maxFramePosStart = 0;
            centerFramePosStart = 0;
        },
        currentMin = 0;
        currentMax = 0.5;
        visible = true,
        enabled = true,
        onRangeChange = onRangeChange,
    };

	setmetatable(v, RangeScrollbar);
    v:Build();
    Editor.ui:AddElement(v);
	return v;
end

function RangeScrollbar:Set(x, y, h, parent)
    self.x = x or 0;
    self.y = y or 0;
    self.h = h or 20;
    self.parent = parent or nil;

    self.frame:ClearAllPoints();
	self.frame:SetPoint("TOPRIGHT", parent, "TOPRIGHT", x, y);
	self.frame:SetSize(w, h);
end

function RangeScrollbar:Build()
    local x = self.x;
    local w = 200;
    local y = self.y;
    local h = self.h;
    local parent = self.parent;

    self.frame = UI.Rectangle:New(x, y, w, h, parent, "BOTTOMLEFT", "BOTTOMLEFT", 0, 0, 0, 0);
    self.frame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", x, y);

    self.frameCenter = UI.ImageBox:New(h, 0, w - (h * 2), h, self.frame:GetFrame(), "LEFT", "LEFT", Resources.textures["CropBar"], { 0.25 + 0.125, 0.75 - 0.125, 0, 0.5 });
    self.frameCenter:SetPoint("RIGHT", self.frame:GetFrame(), "RIGHT", -h, y);
    self.frameCenter:SetVertexColor(0.18,0.18,0.18,1);

    self.frameLeft = UI.ImageBox:New(0, 0, h, h, self.frame:GetFrame(), "LEFT", "LEFT", Resources.textures["CropBar"], { 0, 0.5, 0, 0.5 });
    self.frameLeft:SetVertexColor(0.18,0.18,0.18,1);

    self.frameRight = UI.ImageBox:New(0, 0, h, h, self.frame:GetFrame(), "RIGHT", "RIGHT", Resources.textures["CropBar"], { 0.5, 1.0, 0, 0.5 });
    self.frameRight:SetVertexColor(0.18,0.18,0.18,1);

    local initialSliderLength = w * (self.currentMax - self.currentMin) - 10;

    -- Left handle
    self.leftDrag = CreateFrame("Button", "self.leftDrag", self.frame:GetFrame())
	self.leftDrag:SetPoint("LEFT", self.frame:GetFrame(), "LEFT", 0, 0);
	self.leftDrag:SetSize(h, h);
    --self.leftDrag:SetAlpha(0.5);
    self.leftDrag.ntex = self.leftDrag:CreateTexture();
    self.leftDrag.ntex:SetTexture(Resources.textures["CropBar"]);
    self.leftDrag.ntex:SetTexCoord(0, 0.5, 0, 0.5);    -- (left,right,top,bottom)
    self.leftDrag.ntex:SetAllPoints();
    self.leftDrag.ntex:SetVertexColor(0.3,0.3,0.3,1);
    self.leftDrag:SetNormalTexture(self.leftDrag.ntex);
    self.leftDrag:RegisterForClicks("LeftButtonUp", "LeftButtonDown");
    self.leftDrag:SetScript("OnMouseDown", function(_, button)
        self.inputState.movingMin = true;
        local gpointL, grelativeToL, grelativePointL, gxOfsL, gyOfsL = self.leftDrag:GetPoint(1);
        self.inputState.minFramePosStart = gxOfsL;
        local gpointR, grelativeToR, grelativePointR, gxOfsR, gyOfsR = self.rightDrag:GetPoint(1);
        self.inputState.maxFramePosStart = gxOfsR;
        self.inputState.mousePosStartX = Input.mouseXRaw;
    end);
    self.leftDrag:SetScript("OnMouseUp", function(_, button) self.inputState.movingMin = false; end);
    local burgerLD = UI.ImageBox:New(0, 0, h, h, self.leftDrag, "CENTER", "CENTER", Resources.textures["CropBar"], { 0, 0.5, 0.5, 1 });
    burgerLD:SetAlpha(0.2);

    -- Right handle
    self.rightDrag = CreateFrame("Button", "self.rightDrag", self.frame:GetFrame())
	self.rightDrag:SetPoint("LEFT", self.frame:GetFrame(), "LEFT", initialSliderLength, 0);
	self.rightDrag:SetSize(h, h);
    --self.rightDrag:SetAlpha(0.5);
    self.rightDrag.ntex = self.rightDrag:CreateTexture();
    self.rightDrag.ntex:SetTexture(Resources.textures["CropBar"]);
    self.rightDrag.ntex:SetTexCoord(0.5, 1.0, 0, 0.5);    -- (left,right,top,bottom)
    self.rightDrag.ntex:SetAllPoints();
    self.rightDrag.ntex:SetVertexColor(0.3,0.3,0.3,1);
    self.rightDrag:SetNormalTexture(self.rightDrag.ntex);
    self.rightDrag:RegisterForClicks("LeftButtonUp", "LeftButtonDown");
    self.rightDrag:SetScript("OnMouseDown", function(_, button)
        self.inputState.movingMax = true;
        local gpointL, grelativeToL, grelativePointL, gxOfsL, gyOfsL = self.leftDrag:GetPoint(1);
        self.inputState.minFramePosStart = gxOfsL;
        local gpointR, grelativeToR, grelativePointR, gxOfsR, gyOfsR = self.rightDrag:GetPoint(1);
        self.inputState.maxFramePosStart = gxOfsR;
        self.inputState.mousePosStartX = Input.mouseXRaw;
    end);
    self.rightDrag:SetScript("OnMouseUp", function(_, button) self.inputState.movingMax = false; end);
    local burgerRD = UI.ImageBox:New(0, 0, h, h, self.rightDrag, "CENTER", "CENTER", Resources.textures["CropBar"], { 0, 0.5, 0.5, 1 })
    burgerRD:SetAlpha(0.2);

    -- Middle handle
    self.middleDrag = CreateFrame("Button", "self.middleDrag", self.frame:GetFrame())
	self.middleDrag:SetPoint("LEFT", self.frame:GetFrame(), "LEFT", h, 0);
	self.middleDrag:SetSize(initialSliderLength-h, h);
    --self.middleDrag:SetAlpha(0.5);
    self.middleDrag.ntex = self.middleDrag:CreateTexture();
    self.middleDrag.ntex:SetTexture(Resources.textures["CropBar"]);
    self.middleDrag.ntex:SetTexCoord(0.25 + 0.125, 0.75 - 0.125, 0, 0.5);    -- (left,right,top,bottom)
    self.middleDrag.ntex:SetAllPoints();
    self.middleDrag.ntex:SetVertexColor(0.3,0.3,0.3,1);
    self.middleDrag:SetNormalTexture(self.middleDrag.ntex);
    self.middleDrag:SetScript("OnMouseDown", function(_, button)
        self.inputState.movingCenter = true;
        local gpointC, grelativeToC, grelativePointC, gxOfsC, gyOfsC = self.middleDrag:GetPoint(1);
        self.inputState.centerFramePosStart = gxOfsC - 16;
        local gpointL, grelativeToL, grelativePointL, gxOfsL, gyOfsL = self.leftDrag:GetPoint(1);
        self.inputState.minFramePosStart = gxOfsL;
        local gpointR, grelativeToR, grelativePointR, gxOfsR, gyOfsR = self.rightDrag:GetPoint(1);
        self.inputState.maxFramePosStart = gxOfsR;
        self.inputState.mousePosStartX = Input.mouseXRaw;
    end);
    self.middleDrag:SetScript("OnMouseUp", function(_, button) self.inputState.movingCenter = false; end);
end

function RangeScrollbar:Update()
    if (not self.enabled) then
        return;
    end

    if (self.inputState.movingMin) then
        local scale = self.parent:GetEffectiveScale();
        local groupBgW = self.parent:GetWidth() + 6;
        local mouseDiff = (self.inputState.mousePosStartX - Input.mouseXRaw) * scale;
        local nextPoint = self.inputState.minFramePosStart - mouseDiff;
        local newPoint = 0;
        if (nextPoint >= 0 and nextPoint < self.inputState.maxFramePosStart - 32) then
            self.leftDrag:ClearAllPoints();
            newPoint = nextPoint;
            self.leftDrag:SetPoint("LEFT", nextPoint, 0);
        else
            if (nextPoint <= 0) then
                self.leftDrag:ClearAllPoints();
                newPoint = 0;
                self.leftDrag:SetPoint("LEFT", 0, 0);
            end
            if (nextPoint >= self.inputState.maxFramePosStart - 32) then
                self.leftDrag:ClearAllPoints();
                newPoint = self.inputState.maxFramePosStart - 32;
                self.leftDrag:SetPoint("LEFT", self.inputState.maxFramePosStart - 32, 0);
            end
        end

        self.middleDrag:ClearAllPoints();
        self.middleDrag:SetPoint("LEFT", self.frame:GetFrame(), "LEFT", newPoint + 16, 0);
        self.middleDrag:SetPoint("RIGHT", self.frame:GetFrame(), "LEFT", self.inputState.maxFramePosStart, 0);
        local newPointNormalized = newPoint / groupBgW;
        self.currentMin = max(0, newPointNormalized);
        if (self.onRangeChange) then
            self.onRangeChange(self.currentMin, self.currentMax);
        end
    end

    if (self.inputState.movingMax) then
        local scale = self.parent:GetEffectiveScale();
        local groupBgW = self.parent:GetWidth() - 16;
        local mouseDiff = (self.inputState.mousePosStartX - Input.mouseXRaw) * scale;
        local nextPoint = self.inputState.maxFramePosStart - mouseDiff;
        local newPoint = 0;
        if (nextPoint > self.inputState.minFramePosStart + 32 and nextPoint < groupBgW) then
            self.rightDrag:ClearAllPoints();
            newPoint = nextPoint;
            self.rightDrag:SetPoint("LEFT", nextPoint, 0);
        else
            if (nextPoint <= self.inputState.minFramePosStart + 32) then
                self.rightDrag:ClearAllPoints();
                newPoint = self.inputState.minFramePosStart + 32;
                self.rightDrag:SetPoint("LEFT", self.inputState.minFramePosStart + 32, 0);
            end
            if (nextPoint > groupBgW) then
                self.rightDrag:ClearAllPoints();
                newPoint = groupBgW;
                self.rightDrag:SetPoint("LEFT", groupBgW, 0);
            end
        end

        self.middleDrag:ClearAllPoints();
        self.middleDrag:SetPoint("RIGHT", self.frame:GetFrame(), "LEFT", newPoint, 0);
        self.middleDrag:SetPoint("LEFT", self.frame:GetFrame(), "LEFT", self.inputState.minFramePosStart + 16, 0);
        local newPointNormalized = newPoint / groupBgW;
        self.currentMax = min(1, newPointNormalized);
        if (self.onRangeChange) then
            self.onRangeChange(self.currentMin, self.currentMax);
        end
    end

    if (self.inputState.movingCenter) then
        local scale = self.parent:GetEffectiveScale();
        local groupBgW = self.parent:GetWidth() - 16;
        local sliderSize = self.inputState.maxFramePosStart - self.inputState.minFramePosStart;
        local mouseDiff = (self.inputState.mousePosStartX - Input.mouseXRaw) * scale;
        local nextPoint = self.inputState.centerFramePosStart - mouseDiff;
        local newPoint = 0;
        if (nextPoint > 0 and nextPoint < (groupBgW) - sliderSize) then
            newPoint = nextPoint;
        else
            if (nextPoint <= 0) then
                newPoint = 0;
            end
            if (nextPoint > groupBgW - sliderSize) then
                newPoint = groupBgW - sliderSize;
            end
        end

        self.middleDrag:ClearAllPoints();
        self.middleDrag:SetPoint("RIGHT", self.frame:GetFrame(), "LEFT", newPoint + sliderSize, 0);
        self.middleDrag:SetPoint("LEFT", self.frame:GetFrame(), "LEFT", newPoint + 16, 0);
        
        self.rightDrag:ClearAllPoints();
        self.rightDrag:SetPoint("LEFT", newPoint + sliderSize, 0);
        
        self.leftDrag:ClearAllPoints();
        self.leftDrag:SetPoint("LEFT", newPoint, 0);

        local newPointMinNormalized = newPoint / groupBgW;
        local newPointMaxNormalized = (newPoint + sliderSize) / groupBgW;
        self.currentMax = min(1, newPointMaxNormalized);
        self.currentMin = max(0, newPointMinNormalized);
        if (self.onRangeChange) then
            self.onRangeChange(self.currentMin, self.currentMax);
        end
    end

end

function RangeScrollbar:SetRange(min, max)
    self.currentMin = min;
    self.currentMax = max;

    local groupBgW = self.parent:GetWidth() - 16;
    local minDenormalized = min * groupBgW;
    local maxDenormalized = max * groupBgW;

    self.middleDrag:ClearAllPoints();
    self.middleDrag:SetPoint("RIGHT", self.frame:GetFrame(), "LEFT", maxDenormalized, 0);
    self.middleDrag:SetPoint("LEFT", self.frame:GetFrame(), "LEFT", minDenormalized + 16, 0);
    
    self.rightDrag:ClearAllPoints();
    self.rightDrag:SetPoint("LEFT", maxDenormalized, 0);
    
    self.leftDrag:ClearAllPoints();
    self.leftDrag:SetPoint("LEFT", minDenormalized, 0);
end

function RangeScrollbar:Resize()
    self:SetRange(self.currentMin, self.currentMax);
end

--[[
function RangeScrollbar:Resize(viewportH, listH)
    local minRangeScrollbar = 20;
    local maxRangeScrollbar = viewportH;
    local desiredRangeScrollbar = (viewportH / listH) * viewportH;
    local newRangeScrollbarHeight = max(minRangeScrollbar, min(maxRangeScrollbar, desiredRangeScrollbar));

    if (newRangeScrollbarHeight >= maxRangeScrollbar) then
        -- disable
        self:Disable();
    else
        -- enable
        self:Enable();
    end

    self.RangeScrollbarSlider:SetHeight(math.floor(newRangeScrollbarHeight));
    self:Update();
    self:SetValueWithoutAction(self.currentValue or 0);
end
--]]
function RangeScrollbar:Disable()
    self.enabled = false;
    self.RangeScrollbarSlider:Hide();
end

function RangeScrollbar:Enable()
    self.enabled = true;
    self.RangeScrollbarSlider:Show();
end

--[[
function RangeScrollbar:SetValue(value)
    self:SetValueWithoutAction(value);
    if (self.onScroll) then
        self.onScroll(value);
    end
end
--]]

--[[
function RangeScrollbar:SetValueWithoutAction(value)
    self.currentValue = value;
    local newPoint = value * (self.height - self.RangeScrollbarSlider:GetHeight());
    self.RangeScrollbarSlider:ClearAllPoints();
    self.RangeScrollbarSlider:SetPoint("TOP", self.frame:GetFrame(), "TOP", 0, -newPoint);
end
--]]
RangeScrollbar.__tostring = function(self)
	return string.format("RangeScrollbar( %.3f, %.3f, %.3f, %.3f, %s )", self.x, self.y, self.w, self.h, self.parent);
end