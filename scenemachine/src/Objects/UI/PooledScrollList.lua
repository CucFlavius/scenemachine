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
        visible = true,
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
    end);
    
    self.viewport = UI.Rectangle:New(self.x, self.y, self.w - 16, self.h, self.frame:GetFrame(), "TOPLEFT", "TOPLEFT", 1, 1, 1, 0);
    self.viewport:SetClipsChildren(true);
    self.scrollbar = UI.Scrollbar:New(0, 0, 16, self.h, self.frame:GetFrame(), function(v) self:SetPosition(v); end);

    self.data = {};
    self.itemPool = {};
    self.dataStartIdx = 1;
end

function PooledScrollList:SetItemTemplate(template)
    self.template = template;
end

function PooledScrollList:MakePool()
    local viewportHeight = self.viewport:GetHeight();
    local viewportWidth = self.viewport:GetWidth();
    local itemHeight = self.template.height;

    local poolSize = math.ceil(viewportHeight / itemHeight + 1);

    for i = #self.itemPool + 1, poolSize, 1 do
        local item = UI.Rectangle:New(0, 0, 50, self.template.height, self.viewport:GetFrame(), "TOPLEFT", "TOPLEFT", 1, 1, 1, 0);
        item:SetSinglePoint("TOPLEFT", 0, -(i - 1) * itemHeight);
        item:SetWidth(viewportWidth);
        item.components = {};
        self.template.buildItem(item);
        self.itemPool[i] = item;
    end
end

function PooledScrollList:ScrollStep(value)
    self.dataStartIdx = self.dataStartIdx - value;
    self.scrollbar:SetValueWithoutAction(self.dataStartIdx / (#self.data - (#self.itemPool - 4)));
    self:Refresh(0);
end

function PooledScrollList:SetPosition(value)
    if (value >= 1) then value = 0.999; end -- this fixes my bad logic which causes a pop when scrolling to the end
    local offs = (value * #self.data) - (value * (#self.itemPool - 3));
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
    self.scrollbar:Resize(self.viewport:GetHeight(), #self.data * self.template.height);
    self:Refresh(0);
end

function PooledScrollList:Refresh(dif)
    self.dataEndIdx = self.dataStartIdx + #self.itemPool - 1;

    if (self.dataStartIdx + #self.itemPool - 3 > #self.data) then
        self.dataStartIdx = (#self.data - #self.itemPool) + 3;
        self.dataEndIdx = self.dataStartIdx + #self.itemPool - 1;
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
        self.template.refreshItem(self.data[d], item);
        pidx = pidx + 1;
    end

    if (pidx < #self.itemPool) then
        for p = pidx, #self.itemPool, 1 do
            self.itemPool[p]:Hide();
        end
    end
end

PooledScrollList.__tostring = function(self)
	return string.format("PooledScrollList( %.3f, %.3f, %.3f, %.3f, %s )", self.x, self.y, self.w, self.h, self.parent);
end