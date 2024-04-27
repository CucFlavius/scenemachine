local Editor = SceneMachine.Editor; -- reference needed for Update loop
local UI = SceneMachine.UI;
local Resources = SceneMachine.Resources;

SceneMachine.UI.Scrollbar = {};

--- @class Scrollbar : Element
local Scrollbar = SceneMachine.UI.Scrollbar;

Scrollbar.__index = Scrollbar;
setmetatable(Scrollbar, SceneMachine.UI.Element)

--- Builds the scrollbar UI elements.
function Scrollbar:Build()
    self.inputState = {
        movingScrollbar = false,
        mousePosStartY = 0,
        scrollbarFramePosStart = 0,
    };

    self.enabled = true;
    self.onScroll = self.values[1];
    self.height = self.frame:GetHeight();

    local w = self.frame:GetWidth();
    local parent = self.parent;
    local inputState = self.inputState;

    -- Background
    self.frame:SetScript("OnSizeChanged",
        function(_, width, height)
            self.height = height;
        end);

    self.frameTop = UI.ImageBox:New(0, 0, w, w / 2, self.frame, "TOP", "TOP", Resources.textures["ScrollBar"], { 0, 1, 0, 0.5 });
    self.frameTop:SetVertexColor(0,0,0,0.2);
    
    self.frameCenter = UI.ImageBox:NewTB(0, -w / 2, 0, w / 2, w, self.frame, Resources.textures["ScrollBar"], { 0, 1, 0.4, 0.6 });
    self.frameCenter:SetVertexColor(0,0,0,0.2);
    
    self.frameBottom = UI.ImageBox:New(0, 0, w, w / 2, self.frame, "BOTTOM", "BOTTOM", Resources.textures["ScrollBar"], { 0, 1, 0.5, 1 });
    self.frameBottom:SetVertexColor(0,0,0,0.2);

    -- Slider
    self.scrollbarSlider = CreateFrame("Button", "scrollbarSlider", self.frame)
	self.scrollbarSlider:SetPoint("TOP", self.frame, "TOP", 0, 0);
	self.scrollbarSlider:SetSize(w, 50);
    self.scrollbarSlider.ntex = self.scrollbarSlider:CreateTexture();
    self.scrollbarSlider.ntex:SetColorTexture(0,0,0,0);
    self.scrollbarSlider.ntex:SetAllPoints();
    self.scrollbarSlider:SetNormalTexture(self.scrollbarSlider.ntex);
    self.scrollbarSlider:SetScript("OnMouseDown", function()
        if (math.ceil(self.frame:GetHeight()) == parent:GetHeight()) then
            return;
        end
        inputState.movingScrollbar = true;
        local mouseXRaw, mouseYRaw = GetCursorPosition();
        inputState.mousePosStartY = mouseYRaw;
        local gpointC, grelativeToC, grelativePointC, gxOfsC, gyOfsC = self.scrollbarSlider:GetPoint(1);
        inputState.scrollbarFramePosStart = gyOfsC;
    end);
    self.scrollbarSlider:SetScript("OnMouseUp", function() inputState.movingScrollbar = false; end);

    self.scrollbarSliderCenter = UI.ImageBox:NewTB(0, -w / 2, 0, w / 2, w, self.scrollbarSlider,Resources.textures["ScrollBar"], { 0, 1, 0.4, 0.6 });
    self.scrollbarSliderCenter:SetVertexColor(0.3,0.3,0.3,1);

    self.scrollbarSliderTop = UI.ImageBox:New(0, 0, w, w / 2, self.scrollbarSlider, "TOP", "TOP", Resources.textures["ScrollBar"], { 0, 1, 0, 0.5 });
    self.scrollbarSliderTop:SetVertexColor(0.3,0.3,0.3,1);

    self.scrollbarSliderBottom = UI.ImageBox:New(0, 0, w, w / 2, self.scrollbarSlider, "BOTTOM", "BOTTOM", Resources.textures["ScrollBar"], { 0, 1, 0.5, 1 });
    self.scrollbarSliderBottom:SetVertexColor(0.3,0.3,0.3,1);

    Editor.ui:AddElement(self);
end

--- Sets the frame level of the scrollbar and its components.
--- @param level number The new frame level to set.
function Scrollbar:SetFrameLevel(level)
    self.frame:SetFrameLevel(level);

    self.frameTop:SetFrameLevel(level + 1);
    self.frameCenter:SetFrameLevel(level + 1);
    self.frameBottom:SetFrameLevel(level + 1);

    self.scrollbarSlider:SetFrameLevel(level + 1);
    self.scrollbarSliderCenter:SetFrameLevel(level + 2);
    self.scrollbarSliderTop:SetFrameLevel(level + 2);
    self.scrollbarSliderBottom:SetFrameLevel(level + 2);
end

-- Updates the scrollbar's position and triggers the onScroll event if the scrollbar is being moved.
function Scrollbar:Update()
    if (not self.enabled) then
        return;
    end

    if (self.inputState.movingScrollbar) then
        local groupBgH = self.height;
        local sliderSize = self.scrollbarSlider:GetHeight();
        local mouseXRaw, mouseYRaw = GetCursorPosition();
        local mouseDiff = (self.inputState.mousePosStartY - mouseYRaw); --* UI.UI.scale;
        local nextPoint = self.inputState.scrollbarFramePosStart - mouseDiff;
        local newPoint = 0;

        if (nextPoint < 0 and nextPoint > -(groupBgH - sliderSize)) then
            newPoint = nextPoint;
        else
            if (nextPoint >= 0) then
                newPoint = 0;
            elseif (nextPoint < -(groupBgH - sliderSize)) then
                newPoint = -(groupBgH - sliderSize);
            else
                newPoint = nextPoint;
            end
        end

        self.scrollbarSlider:ClearAllPoints();
        self.scrollbarSlider:SetPoint("TOP", self.frame, "TOP", 0, newPoint);
        
        -- Scroll the items list --
        local newPointNormalized = math.abs(newPoint) / (groupBgH - sliderSize);
        if (self.onScroll) then
            self.currentValue = newPointNormalized;
            self.onScroll(newPointNormalized);
        end
    end
end

--- Resizes the scrollbar based on the viewport height and list height.
--- @param viewportH number The height of the viewport.
--- @param listH number The height of the list.
function Scrollbar:Resize(viewportH, listH)
    -- Check if listH is nil
    if (not listH) then
        self:Disable();
        return;
    end

    if (listH == 0) then
        self:Disable();
        return;
    end

    local minScrollbar = 20;
    local maxScrollbar = viewportH;
    local desiredScrollbar = (viewportH / listH) * viewportH;
    local newScrollbarHeight = math.max(minScrollbar, math.min(maxScrollbar, desiredScrollbar));

    if (newScrollbarHeight >= maxScrollbar) then
        -- disable
        self:Disable();
    else
        -- enable
        self:Enable();
    end

    self.scrollbarSlider:SetHeight(math.floor(newScrollbarHeight));
    self:Update();
    self:SetValueWithoutAction(self.currentValue or 0);
end

--- Disables the scrollbar.
function Scrollbar:Disable()
    self.enabled = false;
    self.scrollbarSlider:Hide();
end

--- Enables the scrollbar.
function Scrollbar:Enable()
    self.enabled = true;
    self.scrollbarSlider:Show();
end

--- Sets the value of the scrollbar.
--- @param value number The new value for the scrollbar.
function Scrollbar:SetValue(value)
    self:SetValueWithoutAction(value);
    if (self.onScroll) then
        self.onScroll(value);
    end
end

--- Sets the value of the scrollbar without triggering any action.
--- @param value number The new value for the scrollbar.
function Scrollbar:SetValueWithoutAction(value)
    self.currentValue = value;
    local newPoint = value * (self.height - self.scrollbarSlider:GetHeight());
    self.scrollbarSlider:ClearAllPoints();
    self.scrollbarSlider:SetPoint("TOP", self.frame, "TOP", 0, -newPoint);
end

Scrollbar.__tostring = function(self)
	return string.format("Scrollbar( %.3f, %.3f, %.3f, %.3f, %s )", self.x, self.y, self.w, self.h, self.parent);
end