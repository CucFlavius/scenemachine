local Editor = SceneMachine.Editor; -- reference needed for Update loop
local UI = SceneMachine.UI;

SceneMachine.UI.Scrollbar = {};
local Scrollbar = SceneMachine.UI.Scrollbar;
Scrollbar.__index = Scrollbar;
setmetatable(Scrollbar, SceneMachine.UI.Element)

function Scrollbar:New(x, y, w, h, parent, onScroll)
	local v = 
    {
        x = x or 0,
        y = y or 0,
        w = w or 20,
        h = h or 20,
        parent = parent or nil,
        inputState = {
            movingScrollbar = false,
            mousePosStartY = 0,
            scrollbarFramePosStart = 0,
        },
        visible = true,
        enabled = true,
        onScroll = onScroll,
    };

	setmetatable(v, Scrollbar);
    v:Build();
    Editor.ui:AddElement(v);
	return v;
end

function Scrollbar:Set(x, y, w, h, parent)
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

function Scrollbar:Build()
    local x = self.x;
    local y = self.y;
    local w = self.w;
    local h = self.h;
    local parent = self.parent;
    local inputState = self.inputState;

    -- Background
    self.frame = UI.Rectangle:New(x, y, w, h, parent, "TOPRIGHT", "TOPRIGHT",  0, 0, 0, 0);
    self.frame:GetFrame():SetScript("OnSizeChanged",
        function(_, width, height)
            --print(width .. " " .. height);
            self.height = height;
        end);

    self.frameTop = UI.ImageBox:New(0, 0, w, w / 2, self.frame.frame, "TOP", "TOP", Scrollbar.texture, { 0, 1, 0, 0.5 });
    self.frameTop:SetVertexColor(0.18,0.18,0.18,1);
    --self.frameTop:SetVertexColor(0.1171, 0.1171, 0.1171, 1);
    
    self.frameCenter = UI.ImageBox:New(0, 0, w, h - w, self.frame.frame, "TOP", "TOP", Scrollbar.texture, { 0, 1, 0.4, 0.6 });
    self.frameCenter:ClearAllPoints();
    self.frameCenter:SetPoint("TOP", self.frame.frame, "TOP", 0, -w / 2);
    self.frameCenter:SetPoint("BOTTOM", self.frame.frame, "BOTTOM", 0, w / 2);
    self.frameCenter:SetVertexColor(0.18,0.18,0.18,1);
    --self.frameCenter:SetVertexColor(0.1171, 0.1171, 0.1171, 1);
    
    self.frameBottom = UI.ImageBox:New(0, 0, w, w / 2, self.frame.frame, "BOTTOM", "BOTTOM", Scrollbar.texture, { 0, 1, 0.5, 1 });
    self.frameBottom:SetVertexColor(0.18,0.18,0.18,1);
    --self.frameBottom:SetVertexColor(0.1171, 0.1171, 0.1171, 1);

    -- Slider
    self.scrollbarSlider = CreateFrame("Button", "scrollbarSlider", self.frame.frame)
	self.scrollbarSlider:SetPoint("TOP", self.frame.frame, "TOP", 0, 0);
	self.scrollbarSlider:SetSize(w, 50);
    self.scrollbarSlider.ntex = self.scrollbarSlider:CreateTexture();
    self.scrollbarSlider.ntex:SetColorTexture(0,0,0,0);
    self.scrollbarSlider.ntex:SetAllPoints();
    self.scrollbarSlider:SetNormalTexture(self.scrollbarSlider.ntex);
    self.scrollbarSlider:SetScript("OnMouseDown", function()
        if (math.ceil(self:GetHeight()) == parent:GetHeight()) then
            return;
        end
        inputState.movingScrollbar = true;
        local mouseXRaw, mouseYRaw = GetCursorPosition();
        inputState.mousePosStartY = mouseYRaw;
        local gpointC, grelativeToC, grelativePointC, gxOfsC, gyOfsC = self.scrollbarSlider:GetPoint(1);
        inputState.scrollbarFramePosStart = gyOfsC;
    end);
    self.scrollbarSlider:SetScript("OnMouseUp", function() inputState.movingScrollbar = false; end);

    self.scrollbarSliderCenter = UI.ImageBox:New(0, 0, w, h, self.scrollbarSlider, "CENTER", "CENTER", Scrollbar.texture, { 0, 1, 0.4, 0.6 });
    self.scrollbarSliderCenter:ClearAllPoints();
    self.scrollbarSliderCenter:SetPoint("TOP", self.scrollbarSlider, "TOP", 0, -w / 2);
    self.scrollbarSliderCenter:SetPoint("BOTTOM", self.scrollbarSlider, "BOTTOM", 0, w / 2);
    self.scrollbarSliderCenter:SetVertexColor(0.3,0.3,0.3,1);

    self.scrollbarSliderTop = UI.ImageBox:New(0, 0, w, w / 2, self.scrollbarSlider, "TOP", "TOP", Scrollbar.texture, { 0, 1, 0, 0.5 });
    self.scrollbarSliderTop:SetVertexColor(0.3,0.3,0.3,1);

    self.scrollbarSliderBottom = UI.ImageBox:New(0, 0, w, w / 2, self.scrollbarSlider, "BOTTOM", "BOTTOM", Scrollbar.texture, { 0, 1, 0.5, 1 });
    self.scrollbarSliderBottom:SetVertexColor(0.3,0.3,0.3,1);
end

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
        self.scrollbarSlider:SetPoint("TOP", self.frame:GetFrame(), "TOP", 0, newPoint);
        
        -- Scroll the items list --
        local newPointNormalized = math.abs(newPoint) / (groupBgH - sliderSize);
        if (self.onScroll) then
            self.currentValue = newPointNormalized;
            self.onScroll(newPointNormalized);
        end
    end
end

function Scrollbar:Resize(viewportH, listH)
    local minScrollbar = 20;
    local maxScrollbar = viewportH;
    local desiredScrollbar = (viewportH / listH) * viewportH;
    local newScrollbarHeight = max(minScrollbar, min(maxScrollbar, desiredScrollbar));

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

function Scrollbar:Disable()
    self.enabled = false;
    self.scrollbarSlider:Hide();
end

function Scrollbar:Enable()
    self.enabled = true;
    self.scrollbarSlider:Show();
end

function Scrollbar:SetValue(value)
    self:SetValueWithoutAction(value);
    if (self.onScroll) then
        self.onScroll(value);
    end
end

function Scrollbar:SetValueWithoutAction(value)
    self.currentValue = value;
    local newPoint = value * (self.height - self.scrollbarSlider:GetHeight());
    self.scrollbarSlider:ClearAllPoints();
    self.scrollbarSlider:SetPoint("TOP", self.frame:GetFrame(), "TOP", 0, -newPoint);
end

Scrollbar.__tostring = function(self)
	return string.format("Scrollbar( %.3f, %.3f, %.3f, %.3f, %s )", self.x, self.y, self.w, self.h, self.parent);
end

Scrollbar.texture = "Interface\\Addons\\scenemachine\\static\\textures\\scrollBar.png";