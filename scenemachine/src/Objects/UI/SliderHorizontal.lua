local Editor = SceneMachine.Editor; -- reference needed for Update loop
local UI = SceneMachine.UI;
local Resources = SceneMachine.Resources;

SceneMachine.UI.SliderHorizontal = {};

--- @class SliderHorizontal : Element
local SliderHorizontal = SceneMachine.UI.SliderHorizontal;

SliderHorizontal.__index = SliderHorizontal;
setmetatable(SliderHorizontal, SceneMachine.UI.Element)

--- Builds the horizontal scrollbar.
function SliderHorizontal:Build()
    self.inputState = {
        movingSliderHorizontal = false,
        mousePosStartX = 0,
        SliderHorizontalFramePosStart = 0,
    };

    self.width = self.frame:GetWidth();
    self.enabled = true;

    self.onScroll = self.values[1];
    self.startValue = self.values[2];
    self.endValue = self.values[3];
    self.step = self.values[4];
    if (self.step) then
        self.step = self.step / (self.endValue - self.startValue);
    end

    Editor.ui:AddElement(self);

    local h = self.frame:GetHeight();
    local parent = self.parent;
    local inputState = self.inputState;

    -- Background
    self.frame:SetScript("OnSizeChanged",
        function(_, width, height)
            self.width = width;
            self:RefreshStepFrames();
            self:SetValueWithoutAction(self:DenormalizeValue(self.currentValue or 0));
        end);

    self.frameLeft = UI.ImageBox:New(0, 0, h/2, h, self.frame, "LEFT", "LEFT", Resources.textures["ScrollBar"], { 0, 0.5, 0, 1 });
    self.frameLeft:SetVertexColor(0.1171, 0.1171, 0.1171,1);

    self.frameCenter = UI.ImageBox:NewLR(h/2, 0, -h/2, 0, h, self.frame, Resources.textures["ScrollBar"], { 0.4, 0.6, 0, 1 });
    self.frameCenter:SetVertexColor(0.1171, 0.1171, 0.1171,1);
    
    self.frameRight = UI.ImageBox:New(0, 0, h/2, h, self.frame, "RIGHT", "RIGHT", Resources.textures["ScrollBar"], { 0.5, 1, 0, 1 });
    self.frameRight:SetVertexColor(0.1171, 0.1171, 0.1171,1);

    local totalSteps = 1 / self.step;
    if (totalSteps < 100) then
        self.stepFrames = {};
        local level = self.frameCenter:GetFrameLevel();
        local w = self.frameCenter:GetWidth() + (h * 2);
        for i = 1, totalSteps + 1, 1 do
            local x = ((i - 1) * self.step) * w + h/2 + 1;
            local stepFrame = UI.ImageBox:New(x, 0, 3, h * 2, self.frameCenter:GetFrame(), "LEFT", "LEFT", Resources.textures["TimeNeedle"], { 0.4, 0.6, 0, 1 });
            stepFrame:SetVertexColor(0.1171, 0.1171, 0.1171,1);
            stepFrame:SetFrameLevel(level);
            table.insert(self.stepFrames, stepFrame);
        end
    end

    -- Slider
    self.scrollbarSlider = CreateFrame("Button", "ScrollbarSlider", self.frame)
	self.scrollbarSlider:SetPoint("LEFT", self.frame, "LEFT", 0, 0);
	self.scrollbarSlider:SetSize(h * 3, h * 3);
    self.scrollbarSlider.ntex = self.scrollbarSlider:CreateTexture();
    self.scrollbarSlider.ntex:SetColorTexture(0,0,0,0);
    self.scrollbarSlider.ntex:SetAllPoints();
    self.scrollbarSlider:SetNormalTexture(self.scrollbarSlider.ntex);
    self.scrollbarSlider:SetScript("OnMouseDown", function()
        if (math.ceil(self.frame:GetWidth()) == self.parent:GetWidth()) then
            return;
        end
        inputState.movingSliderHorizontal = true;
        local mouseXRaw, mouseYRaw = GetCursorPosition();
        inputState.mousePosStartX = mouseXRaw;
        local gpointC, grelativeToC, grelativePointC, gxOfsC, gyOfsC = self.scrollbarSlider:GetPoint(1);
        inputState.SliderHorizontalFramePosStart = gxOfsC;
    end);
    self.scrollbarSlider:SetScript("OnMouseUp", function() inputState.movingSliderHorizontal = false; end);

    self.scrollbarSliderCenter = UI.ImageBox:NewAP(self.scrollbarSlider, Resources.textures["ScrollBar"], { 0, 1, 0, 1 });
    self.scrollbarSliderCenter:SetVertexColor(0.3,0.3,0.3,1);
end

--- Sets the frame level of the horizontal scrollbar and its components.
--- @param level number The new frame level to set.
function SliderHorizontal:SetFrameLevel(level)
    self.frame:SetFrameLevel(level);
    self.frameLeft:SetFrameLevel(level + 1);
    self.frameCenter:SetFrameLevel(level + 1);
    self.frameRight:SetFrameLevel(level + 1);
    self.scrollbarSlider:SetFrameLevel(level + 2);
    self.scrollbarSliderCenter:SetFrameLevel(level + 2);
end

function SliderHorizontal:RefreshStepFrames()
    if (self.stepFrames == nil) then
        return;
    end

    local h = self.frame:GetHeight();
    local w = self.frameCenter:GetWidth() - (h * 2);
    for i = 1, #self.stepFrames, 1 do
        local x = ((i - 1) * self.step) * w + h/2 + 1;
        self.stepFrames[i]:SetPoint("LEFT", self.frameCenter:GetFrame(), "LEFT", x, 0);
    end
end

--- Updates the horizontal scrollbar based on user input.
function SliderHorizontal:Update()
    if (not self.enabled) then
        return;
    end

    if (self.inputState.movingSliderHorizontal) then
        local groupBgH = self.width;
        local sliderSize = self.scrollbarSlider:GetWidth();
        local mouseXRaw, mouseYRaw = GetCursorPosition();
        local mouseDiff = (self.inputState.mousePosStartX - mouseXRaw);
        local nextPoint = self.inputState.SliderHorizontalFramePosStart - mouseDiff;
        local newPoint = 0;

        -- Calculate the new position of the scrollbar slider
        if (nextPoint > 0 and nextPoint < (groupBgH - sliderSize)) then
            newPoint = nextPoint;
        else
            if (nextPoint <= 0) then
                newPoint = 0;
            elseif (nextPoint > (groupBgH - sliderSize)) then
                newPoint = (groupBgH - sliderSize);
            else
                newPoint = nextPoint;
            end
        end

        -- Update the position of the scrollbar slider
        self.scrollbarSlider:ClearAllPoints();
        self.scrollbarSlider:SetPoint("LEFT", self.frame, "LEFT", newPoint, 0);
        
        -- Scroll the items list
        local newPointNormalized = math.abs(newPoint) / (groupBgH - sliderSize);
        if (self.onScroll) then
            self.currentValue = newPointNormalized;

            if (self.step) then
                self.currentValue = math.floor(self.currentValue / self.step) * self.step;
                self.scrollbarSlider:SetPoint("LEFT", self.frame, "LEFT", self.currentValue * (groupBgH - sliderSize), 0);
            end

            self.onScroll(self:DenormalizeValue(self.currentValue));
        end
    end
end

--- Disables the horizontal scrollbar.
function SliderHorizontal:Disable()
    self.enabled = false;
    self.scrollbarSlider:Hide();
end

--- Enables the horizontal scrollbar.
function SliderHorizontal:Enable()
    self.enabled = true;
    self.scrollbarSlider:Show();
end

--- Sets the value of the horizontal scrollbar.
--- @param value number The new value to set.
function SliderHorizontal:SetValue(value)
    self:SetValueWithoutAction(value);
    if (self.onScroll) then
        self.onScroll(self:DenormalizeValue(value));
    end
end

function SliderHorizontal:NormalizeValue(value)
    return (value - self.startValue) / (self.endValue - self.startValue);
end

function SliderHorizontal:DenormalizeValue(value)
    return value * (self.endValue - self.startValue) + self.startValue;
end

--- Sets the value of the horizontal scrollbar without triggering any action.
--- @param value number The new value for the scrollbar.
function SliderHorizontal:SetValueWithoutAction(value)
    if (not value) then
        return;
    end

    value = self:NormalizeValue(value);

    self.currentValue = value;

    --[[
    if (self.step) then
        self.currentValue = math.floor(self.currentValue / self.step) * self.step;
        local groupBgH = self.width;
        local sliderSize = self.scrollbarSlider:GetWidth();
        self.scrollbarSlider:SetPoint("LEFT", self.frame, "LEFT", self.currentValue * (groupBgH - sliderSize), 0);
    end
    --]]
    local newPoint = value * (self.width - self.scrollbarSlider:GetWidth());
    self.scrollbarSlider:ClearAllPoints();
    self.scrollbarSlider:SetPoint("LEFT", self.frame, "LEFT", newPoint, 0);
end

SliderHorizontal.__tostring = function(self)
	return string.format("SliderHorizontal( %.3f, %.3f, %.3f, %.3f, %s )", self.x, self.y, self.w, self.h, self.parent);
end