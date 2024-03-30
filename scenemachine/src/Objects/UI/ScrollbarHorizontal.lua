local Editor = SceneMachine.Editor; -- reference needed for Update loop
local UI = SceneMachine.UI;
local Resources = SceneMachine.Resources;

SceneMachine.UI.ScrollbarHorizontal = {};

--- @class ScrollbarHorizontal : Element
local ScrollbarHorizontal = SceneMachine.UI.ScrollbarHorizontal;

ScrollbarHorizontal.__index = ScrollbarHorizontal;
setmetatable(ScrollbarHorizontal, SceneMachine.UI.Element)

--- Creates a new instance of ScrollbarHorizontal.
--- @param xA number: The x-coordinate of the bottom-left corner of the scrollbar frame.
--- @param yA number: The y-coordinate of the bottom-left corner of the scrollbar frame.
--- @param xB number: The x-coordinate of the bottom-right corner of the scrollbar frame.
--- @param yB number: The y-coordinate of the bottom-right corner of the scrollbar frame.
--- @param h number: The height of the scrollbar frame.
--- @param parent table: The parent element to which the scrollbar belongs.
--- @param onScroll function: The callback function to be called when the scrollbar is scrolled.
--- @return ScrollbarHorizontal: The newly created ScrollbarHorizontal instance.
function ScrollbarHorizontal:NewBLBR(xA, yA, xB, yB, h, parent, onScroll)
    --- @class ScrollbarHorizontal : Element
	local v =
    {
        parent = parent or nil,
        inputState = {
            movingScrollbarHorizontal = false,
            mousePosStartX = 0,
            ScrollbarHorizontalFramePosStart = 0,
        },
        visible = true,
        enabled = true,
        onScroll = onScroll,
        width = 100,
    };

	setmetatable(v, ScrollbarHorizontal);

    v.frame = CreateFrame("Frame", "SceneMachine.UI.ScrollbarHorizontal.frame", parent);
    v.frame:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", xA, yA);
    v.frame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", xB, yB);
    v.frame:SetHeight(h);
    v:Build();

    Editor.ui:AddElement(v);
	return v;
end

--- Builds the horizontal scrollbar.
function ScrollbarHorizontal:Build()
    local h = self.frame:GetHeight();
    local parent = self.parent;
    local inputState = self.inputState;

    -- Background
    self.frame:SetScript("OnSizeChanged",
        function(_, width, height)
            self.width = width;
        end);

    self.frameLeft = UI.ImageBox:New(0, 0, h/2, h, self.frame, "LEFT", "LEFT", Resources.textures["ScrollBar"], { 0, 0.5, 0, 1 });
    self.frameLeft:SetVertexColor(0.18,0.18,0.18,1);

    self.frameCenter = UI.ImageBox:NewLR(h/2, 0, -h/2, 0, h, self.frame, Resources.textures["ScrollBar"], { 0.4, 0.6, 0, 1 });
    self.frameCenter:SetVertexColor(0.18,0.18,0.18,1);
    
    self.frameRight = UI.ImageBox:New(0, 0, h/2, h, self.frame, "RIGHT", "RIGHT", Resources.textures["ScrollBar"], { 0.5, 1, 0, 1 });
    self.frameRight:SetVertexColor(0.18,0.18,0.18,1);

    -- Slider
    self.scrollbarSlider = CreateFrame("Button", "ScrollbarSlider", self.frame)
	self.scrollbarSlider:SetPoint("LEFT", self.frame, "LEFT", 0, 0);
	self.scrollbarSlider:SetSize(50, h);
    self.scrollbarSlider.ntex = self.scrollbarSlider:CreateTexture();
    self.scrollbarSlider.ntex:SetColorTexture(0,0,0,0);
    self.scrollbarSlider.ntex:SetAllPoints();
    self.scrollbarSlider:SetNormalTexture(self.scrollbarSlider.ntex);
    self.scrollbarSlider:SetScript("OnMouseDown", function()
        if (math.ceil(self.frame:GetWidth()) == parent:GetWidth()) then
            return;
        end
        inputState.movingScrollbarHorizontal = true;
        local mouseXRaw, mouseYRaw = GetCursorPosition();
        inputState.mousePosStartX = mouseXRaw;
        local gpointC, grelativeToC, grelativePointC, gxOfsC, gyOfsC = self.scrollbarSlider:GetPoint(1);
        inputState.ScrollbarHorizontalFramePosStart = gxOfsC;
    end);
    self.scrollbarSlider:SetScript("OnMouseUp", function() inputState.movingScrollbarHorizontal = false; end);

    self.scrollbarSliderCenter = UI.ImageBox:NewLR(h/2, 0, -h/2, 0, h, self.scrollbarSlider, Resources.textures["ScrollBar"], { 0.4, 0.6, 0, 1 });
    self.scrollbarSliderCenter:SetVertexColor(0.3,0.3,0.3,1);

    self.scrollbarSliderLeft = UI.ImageBox:New(0, 0, h/2, h, self.scrollbarSlider, "LEFT", "LEFT", Resources.textures["ScrollBar"], { 0, 0.5, 0, 1 });
    self.scrollbarSliderLeft:SetVertexColor(0.3,0.3,0.3,1);

    self.scrollbarSliderRight = UI.ImageBox:New(0, 0, h/2, h, self.scrollbarSlider, "RIGHT", "RIGHT", Resources.textures["ScrollBar"], { 0.5, 1, 0, 1 });
    self.scrollbarSliderRight:SetVertexColor(0.3,0.3,0.3,1);
end

--- Sets the frame level of the horizontal scrollbar and its components.
--- @param level number The new frame level to set.
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

--- Updates the horizontal scrollbar based on user input.
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
            self.onScroll(newPointNormalized);
        end
    end
end

--- Resizes the horizontal scrollbar based on the viewport width and list width.
--- @param viewportW number The width of the viewport.
--- @param listW number The width of the list.
function ScrollbarHorizontal:Resize(viewportW, listW)
    -- Check if listW is nil
    if (not listW) then
        return;
    end

    local minScrollbarHorizontal = 20;
    local maxScrollbarHorizontal = viewportW;
    local desiredScrollbarHorizontal = (viewportW / listW) * viewportW;
    local newScrollbarHorizontalWidth = math.max(minScrollbarHorizontal, math.min(maxScrollbarHorizontal, desiredScrollbarHorizontal));

    -- Check if the new scrollbar width is greater than or equal to the maximum scrollbar width
    if (newScrollbarHorizontalWidth >= maxScrollbarHorizontal) then
        -- Disable the scrollbar
        self:Disable();
        self.currentValue = 0;
    else
        -- Enable the scrollbar
        self:Enable();
    end

    -- Set the width of the scrollbar slider
    self.scrollbarSlider:SetWidth(math.floor(newScrollbarHorizontalWidth));
    self:Update();
    self:SetValueWithoutAction(self.currentValue or 0);
end

--- Disables the horizontal scrollbar.
function ScrollbarHorizontal:Disable()
    self.enabled = false;
    self.scrollbarSlider:Hide();
end

--- Enables the horizontal scrollbar.
function ScrollbarHorizontal:Enable()
    self.enabled = true;
    self.scrollbarSlider:Show();
end

--- Sets the value of the horizontal scrollbar.
--- @param value number The new value to set.
function ScrollbarHorizontal:SetValue(value)
    self:SetValueWithoutAction(value);
    if (self.onScroll) then
        self.onScroll(value);
    end
end

--- Sets the value of the horizontal scrollbar without triggering any action.
--- @param value number The new value for the scrollbar.
function ScrollbarHorizontal:SetValueWithoutAction(value)
    if (not value) then
        return;
    end
    
    self.currentValue = value;
    local newPoint = value * (self.width - self.scrollbarSlider:GetWidth());
    self.scrollbarSlider:ClearAllPoints();
    self.scrollbarSlider:SetPoint("LEFT", self.frame, "LEFT", newPoint, 0);
end

ScrollbarHorizontal.__tostring = function(self)
	return string.format("ScrollbarHorizontal( %.3f, %.3f, %.3f, %.3f, %s )", self.x, self.y, self.w, self.h, self.parent);
end