local UI = SceneMachine.UI;
UI.CollapsableList = {};
local CollapsableList = UI.CollapsableList;
CollapsableList.__index = CollapsableList;
setmetatable(CollapsableList, UI.Element)

function CollapsableList:New(x, y, w, h, sizesY, parent, point, parentPoint, titles, R, G, B, A)
	local v = 
    {
        x = x or 0,
        y = y or 0,
        w = w or 20,
        h = h or 20,
        sizesY = sizesY or nil,
        parent = parent or nil,
        point = point or "TOPLEFT",
        parentPoint = parentPoint or "TOPLEFT",
        titles = titles or nil,
        R = R or 1,
        G = G or 1,
        B = B or 1,
        A = A or 1,
        visible = true,
    };

	setmetatable(v, CollapsableList);
    v:Build();
	return v;
end

function CollapsableList:Build()
    self.frame = UI.Rectangle:New(self.x, self.y, self.w, self.h, self.parent, self.point, self.parentPoint, 0, 0, 0, 0);   -- viewport
    self.frame:SetClipsChildren(true);

    self.list = UI.Rectangle:New(self.x, self.y, self.w, self:GetTotalHeight(), self.frame:GetFrame(), self.point, self.parentPoint, 0, 0, 0, 0);
    self.list:SetPoint("BOTTOMRIGHT", self.frame:GetFrame(), "BOTTOMRIGHT", -16, 0);
    self.bars = {};
    for c = 1, #self.titles, 1 do
        self.bars[c] = UI.CollapsableBox:New(self.x, self.y, self.w, self.sizesY[c], self.list:GetFrame(),
                                            self.point, self.parentPoint, self.titles[c],
                                            self.R, self.G, self.B, self.A, self);
    end

    self.scrollbar = UI.Scrollbar:New(0, 0, 16, self.h, self.frame:GetFrame(), function(v) self:SetPosition(v); end);
    self.scrollbar:SetPoint("BOTTOMRIGHT", self.frame:GetFrame(), "BOTTOMRIGHT", 0, 0);

    self.frame:GetFrame():SetScript("OnSizeChanged",
    function(_, width, height)
        self.viewportHeight = height;
        self.scrollbar:Resize(height, self:GetVisibleHeight());
    end);

    self:Sort();
end

function CollapsableList:SetPosition(value)
    local min = 0;
    local max = self:GetVisibleHeight() - self.frame:GetHeight();
    local pos = value * max;
    self.list:ClearAllPoints();
    self.list:SetPoint("TOPLEFT", self.frame:GetFrame(), "TOPLEFT", 0, pos);
    self.list:SetPoint("BOTTOMRIGHT", self.frame:GetFrame(), "BOTTOMRIGHT", -16, pos + max);
end

function CollapsableList:GetVisibleHeight()
    
    local h = 0;
    for _, childFrame in ipairs({ self.list:GetFrame():GetChildren() }) do
        local ch = childFrame:GetChildren();
        local visible = ch:IsVisible();
        local height = ch:GetHeight();
        if (visible) then
            h = h + height + 12;
        else
            h = h + 12;
        end
    end

    return h;
end

function CollapsableList:GetTotalHeight()
    local h = 0;
    for c = 1, #self.sizesY, 1 do
        h = h + self.sizesY[c] + 12;
    end
    return h;
end

CollapsableList.__tostring = function(self)
	return string.format("CollapsableList( %.3f, %.3f, %.3f, %.3f, %s )", self.x, self.y, self.w, self.h, self.parent);
end

function CollapsableList:Sort()
    local y = 0;

    for c = 1, #self.bars, 1 do
        local bar = self.bars[c];

        bar:ClearAllPoints();
        bar:SetPoint("TOPLEFT", bar:GetParent(), "TOPLEFT", bar.x, y);
        bar:SetPoint("TOPRIGHT", bar:GetParent(), "TOPRIGHT", bar.x, y);
        bar:SetHeight(12);

        if (not bar.bar.isCollapsed) then
            y = y - (bar.panel:GetHeight() + 13);
        else
            y = y - 13;
        end
    end
end