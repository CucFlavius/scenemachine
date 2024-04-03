local UI = SceneMachine.UI;
UI.PooledGridScrollList = {};

--- @class PooledGridScrollList : Element
local PooledGridScrollList = UI.PooledGridScrollList;

PooledGridScrollList.__index = PooledGridScrollList;
setmetatable(PooledGridScrollList, UI.Element)

--- Builds the PooledGridScrollList.
function PooledGridScrollList:Build()
    self.viewportHeight = 0;

    -- Set the OnMouseWheel script for the frame
    self.frame:SetScript("OnMouseWheel",
        function(_, delta)
            self:ScrollStep(delta);
        end);

    -- Create the viewport rectangle
    self.viewport = UI.Rectangle:NewAP(self.frame, 1, 0, 1, 0);
    self.viewport:SetClipsChildren(true);

    -- Set the OnSizeChanged script for the viewport frame
    self.viewport:GetFrame():SetScript("OnSizeChanged",
        function(_, width, height)
            if (not self.template) then
                return;
            end
            self:MakePool(width - 16, height);
            self.viewportWidth = width - 16;
            self.viewportHeight = height;
            if (self.data) then
                self.totalRows = math.ceil(#self.data / self.visibleColumns);
            else
                self.totalRows = 0;
            end
            self.scrollbar:Resize(height, self.itemHeight * self.totalRows);
            self:SetPosition(self.scrollbar.currentValue);
        end);

    -- Create the scrollbar
    self.scrollbar = UI.Scrollbar:NewTRBR(0, 0, 0, 0, 16, self.frame, function(v) self:SetPosition(v); end);

    -- Initialize variables
    self.data = {};
    self.itemPool = {};
    self.dataStartIdx = 1;
    self.rowStartIdx = 1;
end

--- Sets the frame level of the PooledGridScrollList and its components.
--- @param level number The new frame level to set.
function PooledGridScrollList:SetFrameLevel(level)
    self.frame:SetFrameLevel(level);
    self.viewport:SetFrameLevel(level + 1);

    for i = 1, #self.itemPool, 1 do
        self.itemPool[i]:SetFrameLevel(level + 2 + i);
        for c = 1, #self.itemPool[i].components, 1 do
            self.itemPool[i].components[c]:SetFrameLevel(level + 2 + i + c);
        end
    end
end

--- Sets the item template for the PooledGridScrollList.
--- @param template table[] The template to be used for the items in the list.
function PooledGridScrollList:SetItemTemplate(template)
    self.template = template;
end

--- Initializes the object pool for the grid scroll list.
--- @param viewportWidth number? The width of the viewport.
--- @param viewportHeight number? The height of the viewport.
function PooledGridScrollList:MakePool(viewportWidth, viewportHeight)
    -- Check if a template is set
    if (not self.template) then
        return;
    end

    -- Set the viewport dimensions
    viewportHeight = viewportHeight or self.viewport:GetHeight();
    viewportWidth = viewportWidth or self.viewport:GetWidth();

    -- Calculate the aspect ratio of the template
    local itemHeight = self.template.height;
    local itemWidth = self.template.width;
    local aspect = itemHeight / itemWidth;

    -- Calculate the number of visible columns and rows
    self.visibleColumns = math.ceil(viewportWidth / itemWidth);
    self.itemWidth = viewportWidth / self.visibleColumns;
    self.itemHeight = self.itemWidth * aspect
    self.visibleRows = math.ceil(viewportHeight / self.itemHeight) + 1;

    -- Calculate the size of the object pool
    local poolSize = self.visibleRows * self.visibleColumns;

    -- Set the width of existing items in the pool
    for i = 1, #self.itemPool, 1 do
        self.itemPool[i]:SetWidth(viewportWidth);
    end

    -- Create new items and add them to the pool
    for i = #self.itemPool + 1, poolSize, 1 do
        local item = UI.Rectangle:New(0, 0, self.itemWidth, self.itemHeight, self.viewport:GetFrame(), "TOPLEFT", "TOPLEFT", 1, 1, 1, 0);
        item.components = {};
        self.template.buildItem(item);
        self.itemPool[i] = item;
    end

    -- Hide any extra items in the pool
    for i = poolSize + 1, #self.itemPool, 1 do
        self.itemPool[i]:Hide();
    end
end

--- Scrolls the PooledGridScrollList by a given value.
--- @param value number The value by which to scroll the list.
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

--- Sets the position of the PooledGridScrollList.
--- @param value number The position value to set (between 0 and 1)
function PooledGridScrollList:SetPosition(value)
    if (self.data) then
        self.totalRows = math.ceil(#self.data / self.visibleColumns);
    else
        self.totalRows = 0;
    end

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

--- Sets the data for the PooledGridScrollList and updates the scrollbar and pool accordingly.
--- @param data table[] The data to be set for the PooledGridScrollList.
function PooledGridScrollList:SetData(data)
    self.data = data;

    if (data == nil) then
        self.scrollbar:Resize(self.viewportHeight, 0);
    else
        self.scrollbar:Resize(self.viewportHeight, #self.data * self.template.height / self.visibleColumns);
    end

    self:MakePool(self.viewportWidth, self.viewportHeight);
    self.scrollbar:SetValueWithoutAction(0);
    self:Refresh(0);
    self:SetPosition(0);
end

--- Refreshes the PooledGridScrollList with new data.
--- @param dif number The difference in position of the scroll list.
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

            if (self.data) then
                if (self.data[dIdx]) then
                    self.template.refreshItem(self.data[dIdx], item, dIdx);
                else
                    if (self.template.clearItem) then
                        self.template.clearItem(item);
                    end
                    item:Hide();
                end
            else
                item:Hide();
            end

            pidx = pidx + 1;
            dIdx = dIdx + 1;
        end
    end
end

--- Refreshes the static content of the PooledGridScrollList.
function PooledGridScrollList:RefreshStatic()
    local totalVisibleCells = (self.visibleColumns * self.visibleRows);
    
    self.dataStartIdx = self.rowStartIdx * self.visibleColumns - self.visibleColumns + 1;
    self.dataEndIdx = self.dataStartIdx + totalVisibleCells;

    local dIdx = self.dataStartIdx;
    local pidx = 1;
    for r = 1, self.visibleRows, 1 do
        for c = 1, self.visibleColumns, 1 do
            local item = self.itemPool[pidx];

            if (self.data[dIdx]) then
                self.template.refreshItem(self.data[dIdx], item, dIdx);
            else
                item:Hide();
            end

            pidx = pidx + 1;
            dIdx = dIdx + 1;
        end
    end
end

PooledGridScrollList.__tostring = function(self)
	return string.format("PooledGridScrollList( %.3f, %.3f, %.3f, %.3f, %s )", self.x, self.y, self.w, self.h, self.parent);
end