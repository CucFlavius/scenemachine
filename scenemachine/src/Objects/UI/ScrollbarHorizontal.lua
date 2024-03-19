local Editor = SceneMachine.Editor; -- reference needed for Update loop
local UI = SceneMachine.UI;
local Resources = SceneMachine.Resources;

SceneMachine.UI.ScrollbarHorizontal = {};
local ScrollbarHorizontal = SceneMachine.UI.ScrollbarHorizontal;
ScrollbarHorizontal.__index = ScrollbarHorizontal;
setmetatable(ScrollbarHorizontal, SceneMachine.UI.Element)

function ScrollbarHorizontal:New(x, y, w, h, parent, onScroll)
	local v = 
    {
        x = x or 0,
        y = y or 0,
        w = w or 20,
        h = h or 20,
        parent = parent or nil,
        inputState = {
            movingScrollbarHorizontal = false,
            mousePosStartX = 0,
            ScrollbarHorizontalFramePosStart = 0,
        },
        visible = true,
        enabled = true,
        onScroll = onScroll,
    };

	setmetatable(v, ScrollbarHorizontal);
    v:Build();
    Editor.ui:AddElement(v);
	return v;
end

function ScrollbarHorizontal:Set(x, y, w, h, parent)
    self.x = x or 0;
    self.y = y or 0;
    self.w = w or 20;
    self.h = h or 20;
    self.parent = parent or nil;
    self.currentValue = 0;

    self.frame:ClearAllPoints();
	self.frame:SetPoint("TOPRIGHT", parent, "TOPRIGHT", x, y);
	self.frame:SetSize(w, h);
end

function ScrollbarHorizontal:Build()
    local x = self.x;
    local y = self.y;
    local w = self.w;
    local h = self.h;
    local parent = self.parent;
    local inputState = self.inputState;

    -- Background
    self.frame = UI.Rectangle:New(x, y, w, h, parent, "BOTTOMLEFT", "BOTTOMLEFT",  0, 0, 0, 0);
    self.frame:GetFrame():SetScript("OnSizeChanged",
        function(_, width, height)
            self.width = width;
        end);

    self.frameLeft = UI.ImageBox:New(0, 0, h/2, h, self.frame.frame, "LEFT", "LEFT", Resources.textures["ScrollBar"], { 0, 0.5, 0, 1 });
    self.frameLeft:SetVertexColor(0.18,0.18,0.18,1);

    self.frameCenter = UI.ImageBox:New(0, 0, w, h, self.frame.frame, "LEFT", "LEFT", Resources.textures["ScrollBar"], { 0.4, 0.6, 0, 1 });
    self.frameCenter:ClearAllPoints();
    self.frameCenter:SetPoint("LEFT", self.frame.frame, "LEFT", h/2, 0);
    self.frameCenter:SetPoint("RIGHT", self.frame.frame, "RIGHT", -h/2, 0);
    self.frameCenter:SetVertexColor(0.18,0.18,0.18,1);
    
    self.frameRight = UI.ImageBox:New(0, 0, h/2, h, self.frame.frame, "RIGHT", "RIGHT", Resources.textures["ScrollBar"], { 0.5, 1, 0, 1 });
    self.frameRight:SetVertexColor(0.18,0.18,0.18,1);

    -- Slider
    self.scrollbarSlider = CreateFrame("Button", "ScrollbarSlider", self.frame.frame)
	self.scrollbarSlider:SetPoint("LEFT", self.frame.frame, "LEFT", 0, 0);
	self.scrollbarSlider:SetSize(50, h);
    self.scrollbarSlider.ntex = self.scrollbarSlider:CreateTexture();
    self.scrollbarSlider.ntex:SetColorTexture(0,0,0,0);
    self.scrollbarSlider.ntex:SetAllPoints();
    self.scrollbarSlider:SetNormalTexture(self.scrollbarSlider.ntex);
    self.scrollbarSlider:SetScript("OnMouseDown", function()
        if (math.ceil(self:GetWidth()) == parent:GetWidth()) then
            return;
        end
        inputState.movingScrollbarHorizontal = true;
        local mouseXRaw, mouseYRaw = GetCursorPosition();
        inputState.mousePosStartX = mouseXRaw;
        local gpointC, grelativeToC, grelativePointC, gxOfsC, gyOfsC = self.scrollbarSlider:GetPoint(1);
        inputState.ScrollbarHorizontalFramePosStart = gxOfsC;
    end);
    self.scrollbarSlider:SetScript("OnMouseUp", function() inputState.movingScrollbarHorizontal = false; end);

    self.scrollbarSliderCenter = UI.ImageBox:New(0, 0, w, h, self.scrollbarSlider, "CENTER", "CENTER", Resources.textures["ScrollBar"], { 0.4, 0.6, 0, 1 });
    self.scrollbarSliderCenter:ClearAllPoints();
    self.scrollbarSliderCenter:SetPoint("LEFT", self.scrollbarSlider, "LEFT", h/2, 0);
    self.scrollbarSliderCenter:SetPoint("RIGHT", self.scrollbarSlider, "RIGHT", -h/2, 0);
    self.scrollbarSliderCenter:SetVertexColor(0.3,0.3,0.3,1);

    self.scrollbarSliderLeft = UI.ImageBox:New(0, 0, h/2, h, self.scrollbarSlider, "LEFT", "LEFT", Resources.textures["ScrollBar"], { 0, 0.5, 0, 1 });
    self.scrollbarSliderLeft:SetVertexColor(0.3,0.3,0.3,1);

    self.scrollbarSliderRight = UI.ImageBox:New(0, 0, h/2, h, self.scrollbarSlider, "RIGHT", "RIGHT", Resources.textures["ScrollBar"], { 0.5, 1, 0, 1 });
    self.scrollbarSliderRight:SetVertexColor(0.3,0.3,0.3,1);
end

function ScrollbarHorizontal:Update()
    if (not self.enabled) then
        return;
    end

    if (self.inputState.movingScrollbarHorizontal) then
        local groupBgH = self.width;
        local sliderSize = self.scrollbarSlider:GetWidth();
        local mouseXRaw, mouseYRaw = GetCursorPosition();
        local mouseDiff = (self.inputState.mousePosStartX - mouseXRaw);
        local nextPoint = self.inputState.ScrollbarHorizontalFramePosStart - mouseDiff;
        local newPoint = 0;

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

        self.scrollbarSlider:ClearAllPoints();
        self.scrollbarSlider:SetPoint("LEFT", self.frame:GetFrame(), "LEFT", newPoint, 0);
        
        -- Scroll the items list --
        local newPointNormalized = math.abs(newPoint) / (groupBgH - sliderSize);
        if (self.onScroll) then
            self.currentValue = newPointNormalized;
            self.onScroll(newPointNormalized);
        end
    end
end

function ScrollbarHorizontal:Resize(viewportW, listW)
    if (not listW) then
        return;
    end

    local minScrollbarHorizontal = 20;
    local maxScrollbarHorizontal = viewportW;
    local desiredScrollbarHorizontal = (viewportW / listW) * viewportW;
    local newScrollbarHorizontalWidth = max(minScrollbarHorizontal, min(maxScrollbarHorizontal, desiredScrollbarHorizontal));

    if (newScrollbarHorizontalWidth >= maxScrollbarHorizontal) then
        -- disable
        self:Disable();
        self.currentValue = 0;
    else
        -- enable
        self:Enable();
    end

    self.scrollbarSlider:SetWidth(math.floor(newScrollbarHorizontalWidth));
    self:Update();
    self:SetValueWithoutAction(self.currentValue or 0);
end

function ScrollbarHorizontal:SetFrameLevel(level)
    self.frame:SetFrameLevel(level);
    self.frameLeft:SetFrameLevel(level + 1);
    self.frameCenter:SetFrameLevel(level + 1);
    self.frameRight:SetFrameLevel(level + 1);
    self.scrollbarSlider:SetFrameLevel(level + 2);
    self.scrollbarSliderCenter:SetFrameLevel(level + 2);
    self.scrollbarSliderLeft:SetFrameLevel(level + 2);
    self.scrollbarSliderRight:SetFrameLevel(level + 2);
end

function ScrollbarHorizontal:Disable()
    self.enabled = false;
    self.scrollbarSlider:Hide();
end

function ScrollbarHorizontal:Enable()
    self.enabled = true;
    self.scrollbarSlider:Show();
end

function ScrollbarHorizontal:SetValue(value)
    self:SetValueWithoutAction(value);
    if (self.onScroll) then
        self.onScroll(value);
    end
end

function ScrollbarHorizontal:SetValueWithoutAction(value)
    if (not value) then
        return;
    end
    
    self.currentValue = value;
    local newPoint = value * (self.width - self.scrollbarSlider:GetWidth());
    self.scrollbarSlider:ClearAllPoints();
    self.scrollbarSlider:SetPoint("LEFT", self.frame:GetFrame(), "LEFT", newPoint, 0);
end

ScrollbarHorizontal.__tostring = function(self)
	return string.format("ScrollbarHorizontal( %.3f, %.3f, %.3f, %.3f, %s )", self.x, self.y, self.w, self.h, self.parent);
end