local Win = ZWindowAPI;
local Editor = SceneMachine.Editor; -- reference needed for Update loop

SceneMachine.Scrollbar = 
{
    x = 0,
    y = 0,
    w = 20,
    h = 20,
    parent = nil,
    inputState = {
        movingScrollbar = false,
        mousePosStartY = 0,
        scrollbarFramePosStart = 0,
    },
    visible = true,
    enabled = true,
    onScroll = nil,
};

local Scrollbar = SceneMachine.Scrollbar;

setmetatable(Scrollbar, Scrollbar)

local fields = {}

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

    self.scrollbarBg:ClearAllPoints();
	self.scrollbarBg:SetPoint("TOPRIGHT", parent, "TOPRIGHT", x, y);
	self.scrollbarBg:SetSize(w, h);
end

function Scrollbar:Build()
    local x = self.x;
    local y = self.y;
    local w = self.w;
    local h = self.h;
    local parent = self.parent;
    local inputState = self.inputState;
    --print(x .. " " .. y .. " " .. w .. " " .. h)

    self.scrollbarBg = Win.CreateRectangle(x, y, w, h, parent, "TOPRIGHT", "TOPRIGHT",  0, 0, 0, 0);
    --self.scrollbarBg:SetScript("OnUpdate", function() self:Update() end);
    
    self.scrollbarBgCenter = Win.CreateImageBox(0, 0, w, h - w, self.scrollbarBg, "CENTER", "CENTER", Scrollbar.texture, { 0, 1, 0.4, 0.6 });
    self.scrollbarBgCenter.texture:SetVertexColor(0.18,0.18,0.18,1);
    
    self.scrollbarBgTop = Win.CreateImageBox(0, 0, w, w / 2, self.scrollbarBg, "TOP", "TOP", Scrollbar.texture, { 0, 1, 0, 0.5 });
    self.scrollbarBgTop.texture:SetVertexColor(0.18,0.18,0.18,1);

    self.scrollbarBgBottom = Win.CreateImageBox(0, 0, w, w / 2, self.scrollbarBg, "BOTTOM", "BOTTOM", Scrollbar.texture, { 0, 1, 0.5, 1 });
    self.scrollbarBgBottom.texture:SetVertexColor(0.18,0.18,0.18,1);

    -- Scrollbar
    self.scrollbarSlider = CreateFrame("Button", "scrollbarSlider", self.scrollbarBg)
	self.scrollbarSlider:SetPoint("TOP", self.scrollbarBg, "TOP", 0, 0);
	self.scrollbarSlider:SetSize(w, 50);
    self.scrollbarSlider.ntex = self.scrollbarSlider:CreateTexture();
    self.scrollbarSlider.ntex:SetColorTexture(0,0,0,0);
    self.scrollbarSlider.ntex:SetAllPoints();
    self.scrollbarSlider:SetNormalTexture(self.scrollbarSlider.ntex);
    self.scrollbarSlider:SetScript("OnMouseDown", function(self, button)
        if (math.ceil(self:GetHeight()) == parent:GetHeight()) then
            return;
        end
        inputState.movingScrollbar = true;
        local mouseXRaw, mouseYRaw = GetCursorPosition();
        inputState.mousePosStartY = mouseYRaw;
        local gpointC, grelativeToC, grelativePointC, gxOfsC, gyOfsC = scrollbarSlider:GetPoint(1);
        inputState.scrollbarFramePosStart = gyOfsC;
    end);
    self.scrollbarSlider:SetScript("OnMouseUp", function(self, button) inputState.movingScrollbar = false; end);

    self.scrollbarSliderCenter = Win.CreateImageBox(0, 0, w, h, self.scrollbarSlider, "CENTER", "CENTER", Scrollbar.texture, { 0, 1, 0.4, 0.6 });
    self.scrollbarSliderCenter:ClearAllPoints();
    self.scrollbarSliderCenter:SetPoint("TOP", self.scrollbarSlider, "TOP", 0, -w / 2);
    self.scrollbarSliderCenter:SetPoint("BOTTOM", self.scrollbarSlider, "BOTTOM", 0, w / 2);
    self.scrollbarSliderCenter.texture:SetVertexColor(0.3,0.3,0.3,1);

    self.scrollbarSliderTop = Win.CreateImageBox(0, 0, w, w / 2, self.scrollbarSlider, "TOP", "TOP", Scrollbar.texture, { 0, 1, 0, 0.5 });
    self.scrollbarSliderTop.texture:SetVertexColor(0.3,0.3,0.3,1);

    self.scrollbarSliderBottom = Win.CreateImageBox(0, 0, w, w / 2, self.scrollbarSlider, "BOTTOM", "BOTTOM", Scrollbar.texture, { 0, 1, 0.5, 1 });
    self.scrollbarSliderBottom.texture:SetVertexColor(0.3,0.3,0.3,1);

    self.scrollbarSlider:SetHeight(50);
end

function Scrollbar:Update()
    if (not self.enabled) then
        return;
    end
    
    if (self.inputState.movingScrollbar) then
        local groupBgH = self.scrollbarBg:GetHeight();
        local sliderSize = self.scrollbarSlider:GetHeight();
        local mouseXRaw, mouseYRaw = GetCursorPosition();
        local mouseDiff = (self.inputState.mousePosStartY - mouseYRaw);-- * Renderer.scale;
        local nextPoint = self.inputState.scrollbarFramePosStart - mouseDiff;
        local newPoint = 0;

        if (nextPoint < 0 and nextPoint > -(groupBgH - sliderSize)) then
            newPoint = nextPoint;
        else
            if (nextPoint >= 0) then
                newPoint = 0;
            end
            if (nextPoint < -(groupBgH - sliderSize)) then
                newPoint = -(groupBgH - sliderSize);
            end
        end

        self.scrollbarSlider:ClearAllPoints();
        self.scrollbarSlider:SetPoint("TOP", self.scrollbarBg, "TOP", 0, newPoint);
        
        -- Scroll the items list --
        local newPointNormalized = math.abs(newPoint) / (groupBgH - sliderSize);
        if (self.onScroll) then
            self.onScroll(newPointNormalized);
        end
    end
end

function Scrollbar:Resize(viewportH, listH)
    local minScrollbar = 20;
    local maxScrollbar = viewportH;
    local desiredScrollbar = (viewportH / listH) * viewportH;
    local newScrollbarHeight = max(minScrollbar, min(maxScrollbar, desiredScrollbar));

    if (newScrollbarHeight == maxScrollbar) then
        -- disable
        self:Disable();
    else
        -- enable
        self:Enable();
    end

    self.scrollbarSlider:SetHeight(newScrollbarHeight);
end

function Scrollbar:Show()
    self.visible = true;
    self.scrollbarBg:Show();
end

function Scrollbar:Hide()
    self.visible = false;
    self.scrollbarBg:Hide();
end

function Scrollbar:Disable()
    self.enabled = false;
    self.scrollbarSlider:Hide();
end

function Scrollbar:Enable()
    self.enabled = true;
    self.scrollbarSlider:Show();
end

Scrollbar.__tostring = function(self)
	return string.format("Scrollbar( %.3f, %.3f, %.3f, %.3f, %s )", self.x, self.y, self.w, self.h, self.parent);
end

Scrollbar.__index = function(t,k)
	local var = rawget(Scrollbar, k)
		
	if var == nil then							
		var = rawget(fields, k)
		
		if var ~= nil then
			return var(t)	
		end
	end
	
	return var
end

Scrollbar.texture = "Interface\\Addons\\scenemachine\\static\\textures\\scrollBar.png";