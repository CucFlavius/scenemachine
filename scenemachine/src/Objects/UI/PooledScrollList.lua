local UI = SceneMachine.UI;
UI.PooledScrollList = {};

--- @class PooledScrollList : Element
local PooledScrollList = UI.PooledScrollList;
PooledScrollList.__index = PooledScrollList;
setmetatable(PooledScrollList, UI.Element)

--- Creates a new instance of the PooledScrollList class.
--- @param x number? The x-coordinate of the scroll list's position.
--- @param y number? The y-coordinate of the scroll list's position.
--- @param w number? The width of the scroll list.
--- @param h number? The height of the scroll list.
--- @param parent table? The parent element of the scroll list.
--- @param point string? The anchor point of the scroll list relative to its parent.
--- @param parentPoint string? The anchor point of the parent element relative to the scroll list.
--- @return PooledScrollList: The newly created PooledScrollList instance.
function PooledScrollList:New(x, y, w, h, parent, point, parentPoint)
    --- @class PooledScrollList : Element
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

    v.frame = CreateFrame("Frame", "SceneMachine.UI.PooledScrollList.frame", v.parent);
    v.frame:SetPoint(v.point, v.parent, v.parentPoint, v.x, v.y);
    v.frame:SetSize(v.w, v.h);

    v:Build();

    return v;
end

--- Creates a new instance of the PooledScrollList class.
--- @param xA number The x-coordinate of the top-left corner of the scroll list.
--- @param yA number The y-coordinate of the top-left corner of the scroll list.
--- @param xB number The x-coordinate of the bottom-right corner of the scroll list.
--- @param yB number The y-coordinate of the bottom-right corner of the scroll list.
--- @param parent table? The parent frame of the scroll list.
--- @return PooledScrollList: The newly created PooledScrollList instance.
function PooledScrollList:NewTLBR(xA, yA, xB, yB, parent)
    --- @class PooledScrollList : Element
    local v =
    {
        parent = parent or nil,
        viewportHeight = 0;
        visible = true,
        currentDif = 0,
        currentPos = 0,
    };

    setmetatable(v, PooledScrollList);

    v.frame = CreateFrame("Frame", "SceneMachine.UI.PooledScrollList.frame", v.parent);
    v.frame:SetPoint("TOPLEFT", parent, "TOPLEFT", xA, yA);
    v.frame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", xB, yB);

    v:Build();

    return v;
end

--- Builds the PooledScrollList.
function PooledScrollList:Build()
    -- Set the OnMouseWheel script for the frame
    self.frame:SetScript("OnMouseWheel",
        function(_, delta)
            self:ScrollStep(delta);
            --self:SetPosition(self.currentPos - (delta / #self.data));
        end);

    -- Create the viewport rectangle
    self.viewport = UI.Rectangle:NewTLBR(0, 0, 0, 0, self.frame,1, 0, 1, 0);
    self.viewport:SetClipsChildren(true);

    -- Set the OnSizeChanged script for the viewport frame
    self.viewport:GetFrame():SetScript("OnSizeChanged",
        function(_, width, height)
            self:MakePool(width - 16, height);
            self.viewportHeight = height;
            self.scrollbar:Resize(height, #self.data * self.template.height);
            if (self.template.useHorizontalScrollbar) then
                self.viewportWidth = width;
                self.scrollbarH:Resize(width, self.maxWidth);
            end
            self:SetPosition(self.currentPos);
            --self:Refresh(self.currentDif);
        end);

    -- Create the scrollbar
    self.scrollbar = UI.Scrollbar:NewTRBR(0, 0, 0, 0, 16, self.frame, function(v) self:SetPosition(v); end);

    -- Initialize data and item pool
    self.data = {};
    self.itemPool = {};
    self.dataStartIdx = 1;
end

--- Sets the frame level of the PooledScrollList and its components.
--- @param level number The new frame level to set.
function PooledScrollList:SetFrameLevel(level)
    self.frame:SetFrameLevel(level);
    self.viewport:SetFrameLevel(level + 1);

    for i = 1, #self.itemPool, 1 do
        self.itemPool[i]:SetFrameLevel(level + 2 + i);
        for c = 1, #self.itemPool[i].components, 1 do
            self.itemPool[i].components[c]:SetFrameLevel(level + 2 + i + c);
        end
    end
end

--- Sets the item template for the PooledScrollList.
--- @param template table The template to set.
function PooledScrollList:SetItemTemplate(template)
    self.template = template;

    if (self.template.useHorizontalScrollbar) then
        self.viewport:ClearAllPoints();
        self.viewport:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 0, 0);
        self.viewport:SetPoint("BOTTOMRIGHT", self.frame, "BOTTOMRIGHT", -16, 16);

        self.scrollbarH = UI.ScrollbarHorizontal:NewBLBR(0, 0, -16, 0, 16, self.frame, function(v) self:SetHorizontalPosition(v); end);
        self.scrollbarH:SetFrameLevel(self.viewport:GetFrameLevel() + 100);
    end
end

--- Creates a pool of items for the scroll list based on the specified viewport dimensions.
--- If no dimensions are provided, it uses the dimensions of the current viewport.
--- @param viewportWidth number? The width of the viewport (optional)
--- @param viewportHeight number? The height of the viewport (optional)
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

--- Scrolls the PooledScrollList by the specified value.
--- @param value number The value by which to scroll the list.
function PooledScrollList:ScrollStep(value)
    self.dataStartIdx = self.dataStartIdx - value;
    self.currentPos = math.min(1, self.dataStartIdx / (#self.data - (self.visibleElementCount - 1)));
    self.scrollbar:SetValueWithoutAction(self.currentPos);
    self:Refresh(0);
end

--- Sets the position of the PooledScrollList.
--- @param value number The position value between 0 and 1.
function PooledScrollList:SetPosition(value)
    if (value >= 1) then value = 0.9999; end -- this fixes my bad logic which causes a pop when scrolling to the end
    self.currentPos = value;
    local offs = (value * #self.data) - (value * (self.visibleElementCount - 1));
    local roundedOffs = math.floor(offs);
    local dif = 0;
    if (offs ~= roundedOffs) then
        dif = roundedOffs - offs;
    end
    self.dataStartIdx = math.ceil(offs);
    self:Refresh(dif);
end

--- Sets the horizontal position of the PooledScrollList.
--- @param value number The horizontal position value between 0 and 1.
function PooledScrollList:SetHorizontalPosition(value)
    local maxOffset = self.maxWidth - self.viewportWidth
    local offset = -value * maxOffset
    for i = 1, #self.itemPool, 1 do
        local gpointC, grelativeToC, grelativePointC, gxOfsC, gyOfsC = self.itemPool[i]:GetPoint(1);
        self.itemPool[i]:SetSinglePoint("TOPLEFT", offset, gyOfsC);
    end
end

--- Sets the data for the PooledScrollList and refreshes the list.
--- @param data table The data to be set for the PooledScrollList.
function PooledScrollList:SetData(data)
    self.data = data;
    self.scrollbar:Resize(self.viewportHeight, #self.data * self.template.height);
    self:Refresh(self.currentDif);
end

--- Refreshes the PooledScrollList with new data and updates the visible elements.
--- @param dif number The difference in position of the elements.
function PooledScrollList:Refresh(dif)
    self.currentDif = dif;
    if (self.template.useHorizontalScrollbar) then
        self.maxWidth = 0;
    end
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
        if (self.template.useHorizontalScrollbar) then
            self.maxWidth = math.max(self.maxWidth, item.width or 0);
        end
        pidx = pidx + 1;
    end

    if (pidx < #self.itemPool) then
        for p = pidx, #self.itemPool, 1 do
            self.itemPool[p]:Hide();
        end
    end

    if (self.template.useHorizontalScrollbar) then
        self.scrollbarH:Resize(self.viewportWidth, self.maxWidth);
        self.scrollbarH:SetValueWithoutAction(0);
    end
end

--- Refreshes the static items in the PooledScrollList.
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