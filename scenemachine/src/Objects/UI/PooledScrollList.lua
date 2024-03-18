local UI = SceneMachine.UI;
UI.PooledScrollList = {};
local PooledScrollList = UI.PooledScrollList;
PooledScrollList.__index = PooledScrollList;
setmetatable(PooledScrollList, UI.Element)

function PooledScrollList:New(x, y, w, h, parent, point, parentPoint)
	local v = 
    {
        x = x or 0,
        y = y or 0,
        w = w or 20,
        h = h or 20,
        parent = parent or nil,
        point = point or "TOPLEFT",
        parentPoint = parentPoint or "TOPLEFT",
        viewportHeight = 0;
        visible = true,
        currentDif = 0,
        currentPos = 0,
    };

	setmetatable(v, PooledScrollList);
    v:Build();
	return v;
end

function PooledScrollList:Build()
    self.frame = UI.Rectangle:New(self.x, self.y, self.w, self.h, self.parent, self.point, self.parentPoint, 1, 1, 1, 0);
	self.frame:GetFrame():SetScript("OnMouseWheel",
    function(_, delta)
        self:ScrollStep(delta);
        --self:SetPosition(self.currentPos - (delta / #self.data));
    end);
    
    self.viewport = UI.Rectangle:New(self.x, self.y, self.w - 16, self.h, self.frame:GetFrame(), "TOPLEFT", "TOPLEFT", 1, 0, 1, 0);
    self.viewport:SetAllPoints(self.frame:GetFrame());
    self.viewport:SetClipsChildren(true);
    self.viewport:GetFrame():SetScript("OnSizeChanged",
    function(_, width, height)
        --print(width .. " " .. height);
        self:MakePool(width - 16, height);
        self.viewportHeight = height;
        self.scrollbar:Resize(height, #self.data * self.template.height);
        self:SetPosition(self.currentPos);
        --self:Refresh(self.currentDif);
    end);
    self.scrollbar = UI.Scrollbar:New(0, 0, 16, self.h, self.frame:GetFrame(), function(v) self:SetPosition(v); end);
    self.scrollbar:SetPoint("BOTTOMRIGHT", self.frame:GetFrame(), "BOTTOMRIGHT", 0, 0);

    self.data = {};
    self.itemPool = {};
    self.dataStartIdx = 1;
end

function PooledScrollList:SetItemTemplate(template)
    self.template = template;
end

function PooledScrollList:MakePool(viewportWidth, viewportHeight)
    viewportHeight = viewportHeight or self.viewport:GetHeight();
    viewportWidth = viewportWidth or self.viewport:GetWidth();

    local itemHeight = self.template.height;

    local poolSize = math.ceil(viewportHeight / itemHeight + 1);
    self.visibleElementCount = poolSize;

    for i = 1, #self.itemPool, 1 do
        self.itemPool[i]:SetWidth(viewportWidth);
    end

    for i = #self.itemPool + 1, poolSize, 1 do
        local item = UI.Rectangle:New(0, 0, 50, self.template.height, self.viewport:GetFrame(), "TOPLEFT", "TOPLEFT", 0, 0, 0, 1);
        item:SetSinglePoint("TOPLEFT", 0, -(i - 1) * itemHeight);
        item:SetWidth(viewportWidth);
        item.components = {};
        self.template.buildItem(item);
        self.itemPool[i] = item;
    end
end

function PooledScrollList:ScrollStep(value)
    self.dataStartIdx = self.dataStartIdx - value;
    self.currentPos = math.min(1, self.dataStartIdx / (#self.data - (self.visibleElementCount - 2)));
    self.scrollbar:SetValueWithoutAction(self.currentPos);
    self:Refresh(0);
end

function PooledScrollList:SetPosition(value)
    if (value >= 1) then value = 0.999; end -- this fixes my bad logic which causes a pop when scrolling to the end
    self.currentPos = value;
    local offs = (value * #self.data) - (value * (self.visibleElementCount - 2));
    local roundedOffs = math.floor(offs);
    local dif = 0;
    if (offs ~= roundedOffs) then
        dif = roundedOffs - offs;
    end
    self.dataStartIdx = math.ceil(offs);
    self:Refresh(dif);
end

function PooledScrollList:SetData(data)
    self.data = data;
    self.scrollbar:Resize(self.viewportHeight, #self.data * self.template.height);
    self:Refresh(self.currentDif);
end

function PooledScrollList:Refresh(dif)
    self.currentDif = dif;
    self.dataEndIdx = self.dataStartIdx + self.visibleElementCount - 1;

    if (self.dataStartIdx + self.visibleElementCount - 3 > #self.data) then
        self.dataStartIdx = (#self.data - self.visibleElementCount) + 3;
        self.dataEndIdx = self.dataStartIdx + self.visibleElementCount - 1;
    end

    if (self.dataStartIdx < 1) then
        self.dataStartIdx = 1;
    end

    if (self.dataEndIdx > #self.data) then
        self.dataEndIdx = #self.data;
    end

    local pidx = 1;
    for d = self.dataStartIdx, self.dataEndIdx, 1 do
        local item = self.itemPool[pidx];
        item:Show();
        item:SetSinglePoint("TOPLEFT", 0, -((pidx - 1) + dif) * self.template.height);
        self.template.refreshItem(self.data[d], item, d);
        pidx = pidx + 1;
    end

    if (pidx < #self.itemPool) then
        for p = pidx, #self.itemPool, 1 do
            self.itemPool[p]:Hide();
        end
    end
end

function PooledScrollList:RefreshStatic()
    local pidx = 1;
    for d = self.dataStartIdx, self.dataEndIdx, 1 do
        local item = self.itemPool[pidx];
        self.template.refreshItem(self.data[d], item, d);
        pidx = pidx + 1;
    end
end

PooledScrollList.__tostring = function(self)
	return string.format("PooledScrollList( %.3f, %.3f, %.3f, %.3f, %s )", self.x, self.y, self.w, self.h, self.parent);
end