local UI = SceneMachine.UI;
UI.PooledGridScrollList = {};
local PooledGridScrollList = UI.PooledGridScrollList;
PooledGridScrollList.__index = PooledGridScrollList;
setmetatable(PooledGridScrollList, UI.Element)

function PooledGridScrollList:New(x, y, w, h, parent, point, parentPoint)
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
    };

	setmetatable(v, PooledGridScrollList);
    v:Build();
	return v;
end

function PooledGridScrollList:NewP(parent, xA, yA, pointA, parentPointA, xB, yB, pointB, parentPointB)
	local v = 
    {
        parent = parent or nil,
        xA = xA or 0;
        yA = yA or 0;
        pointA = pointA or "TOPLEFT",
        parentPointA = parentPointA or "TOPLEFT",
        xB = xB or 0;
        yB = yB or 0;
        pointB = pointB or "BOTTOMRIGHT",
        parentPointB = parentPointB or "BOTTOMRIGHT",
        viewportHeight = 0;
        visible = true,
    };

	setmetatable(v, PooledGridScrollList);
    v:Build();
	return v;
end

function PooledGridScrollList:Build()
    if (self.xA) then
        self.frame = UI.Rectangle:New(self.xA, self.yA, 100, 100, self.parent, self.pointA, self.parentPointA, 1, 1, 1, 0);
        self.frame:SetPoint(self.pointB, self.parent, self.parentPointB, self.xB, self.yB);
    else
        self.frame = UI.Rectangle:New(self.x, self.y, self.w, self.h, self.parent, self.point, self.parentPoint, 1, 1, 1, 0);
    end
	self.frame:GetFrame():SetScript("OnMouseWheel",
    function(_, delta)
        self:ScrollStep(delta);
    end);
    
    self.viewport = UI.Rectangle:New(0, 0, 100, 100, self.frame:GetFrame(), "TOPLEFT", "TOPLEFT", 1, 0, 1, 0);
    self.viewport:SetAllPoints(self.frame:GetFrame());
    self.viewport:SetClipsChildren(true);
    self.viewport:GetFrame():SetScript("OnSizeChanged",
    function(_, width, height)
        if (not self.template) then
            return;
        end
        self:MakePool(width - 16, height);
        self.viewportWidth = width - 16;
        self.viewportHeight = height;
        self.totalRows = math.ceil(#self.data / self.visibleColumns);
        self.scrollbar:Resize(height, self.itemHeight * self.totalRows);
        self:SetPosition(self.scrollbar.currentValue);
    end);
    self.scrollbar = UI.Scrollbar:New(0, 0, 16, 1, self.frame:GetFrame(), function(v) self:SetPosition(v); end);
    self.scrollbar:SetPoint("BOTTOMRIGHT", self.frame:GetFrame(), "BOTTOMRIGHT", 0, 0);

    self.data = {};
    self.itemPool = {};
    self.dataStartIdx = 1;
    self.rowStartIdx = 1;
end

function PooledGridScrollList:SetItemTemplate(template)
    self.template = template;
end

function PooledGridScrollList:MakePool(viewportWidth, viewportHeight)
    if (not self.template) then
        return;
    end

    viewportHeight = viewportHeight or self.viewport:GetHeight();
    viewportWidth = viewportWidth or self.viewport:GetWidth();

    local itemHeight = self.template.height;
    local itemWidth = self.template.width;
    local aspect = itemHeight / itemWidth;

    self.visibleColumns = math.ceil(viewportWidth / itemWidth);
    self.itemWidth = viewportWidth / self.visibleColumns;
    self.itemHeight = self.itemWidth * aspect
    self.visibleRows = math.ceil(viewportHeight / self.itemHeight) + 1;

    local poolSize = self.visibleRows * self.visibleColumns;

    for i = 1, #self.itemPool, 1 do
        self.itemPool[i]:SetWidth(viewportWidth);
    end

    for i = #self.itemPool + 1, poolSize, 1 do
        local item = UI.Rectangle:New(0, 0, self.itemWidth, self.itemHeight, self.viewport:GetFrame(), "TOPLEFT", "TOPLEFT", 1, 1, 1, 0);
        item.components = {};
        self.template.buildItem(item);
        self.itemPool[i] = item;
    end

    for i = poolSize + 1, #self.itemPool, 1 do
        self.itemPool[i]:Hide();
    end
end

function PooledGridScrollList:ScrollStep(value)
    value = -value;
        if (self.scrollbar.enabled) then
        self.totalRows = math.ceil(#self.data / self.visibleColumns);
        self.scrollbar.currentValue = self.scrollbar.currentValue + (0.5 / self.totalRows * value);
        self.scrollbar.currentValue = math.max(0, math.min(1, self.scrollbar.currentValue));
        self:SetPosition(self.scrollbar.currentValue);
        self.scrollbar:SetValueWithoutAction(self.scrollbar.currentValue);
    end
end

function PooledGridScrollList:SetPosition(value)
    self.totalRows = math.ceil(#self.data / self.visibleColumns);

    -- this fixes some rounding issues
    if (value >= 1) then value = 0.999999; end
    if (value <= 0) then value = 0.000001; end

    local visibleRowsF =  self.viewportHeight / self.itemHeight;
    local offs = (value * (self.totalRows)) - (value * visibleRowsF);
    local roundedOffs = math.floor(offs);
    local dif = 0;
    if (offs ~= roundedOffs) then
        dif = roundedOffs - offs;
    end
    self.rowStartIdx = math.ceil(offs);
    self:Refresh(dif);
end

function PooledGridScrollList:SetData(data)
    self.data = data;
    self.scrollbar:Resize(self.viewportHeight, #self.data * self.template.height);
    self:MakePool(self.viewportWidth, self.viewportHeight);
    self.scrollbar:SetValueWithoutAction(0);
    self:Refresh(0);
    self:SetPosition(0);
end

function PooledGridScrollList:Refresh(dif)
    local totalVisibleCells = (self.visibleColumns * self.visibleRows);
    
    self.dataStartIdx = self.rowStartIdx * self.visibleColumns - self.visibleColumns + 1;
    self.dataEndIdx = self.dataStartIdx + totalVisibleCells;

    local dIdx = self.dataStartIdx;
    local pidx = 1;
    for r = 1, self.visibleRows, 1 do
        for c = 1, self.visibleColumns, 1 do
            local item = self.itemPool[pidx];

            item:Show();
            item:SetSinglePoint("TOPLEFT", (c - 1) * self.itemWidth, -((r - 1) + dif) * self.itemHeight);
            item:SetSize(self.itemWidth, self.itemHeight);

            if (self.data[dIdx]) then
                self.template.refreshItem(self.data[dIdx], item);
            else
                item:Hide();
            end

            pidx = pidx + 1;
            dIdx = dIdx + 1;
        end
    end
end

function PooledGridScrollList:RefreshStatic()
    local pidx = 1;
    for d = self.dataStartIdx, self.dataEndIdx, 1 do
        local item = self.itemPool[pidx];
        self.template.refreshItem(self.data[d], item);
        pidx = pidx + 1;
    end
end

PooledGridScrollList.__tostring = function(self)
	return string.format("PooledGridScrollList( %.3f, %.3f, %.3f, %.3f, %s )", self.x, self.y, self.w, self.h, self.parent);
end