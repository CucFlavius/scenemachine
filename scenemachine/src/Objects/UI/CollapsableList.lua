local UI = SceneMachine.UI;
UI.CollapsableList = {};
local CollapsableList = UI.CollapsableList;
CollapsableList.__index = CollapsableList;
setmetatable(CollapsableList, UI.Element)

function CollapsableList:New(x, y, w, sizesY, parent, point, parentPoint, titles, R, G, B, A)
	local v = 
    {
        x = x or 0,
        y = y or 0,
        w = w or 20,
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
    self.bars = {};
    for c = 1, #self.titles, 1 do
        self.bars[c] = UI.CollapsableBox:New(self.x, self.y, self.w, self.sizesY[c], self.parent,
                                            self.point, self.parentPoint, self.titles[c],
                                            self.R, self.G, self.B, self.A, self);
    end

    self:Sort();
end

CollapsableList.__tostring = function(self)
	return string.format("CollapsableList( %.3f, %.3f, %.3f, %.3f, %s )", self.x, self.y, self.w, self.h, self.parent);
end

function CollapsableList:Sort()
    local y = 0;

    for c = 1, #self.bars, 1 do
        local bar = self.bars[c];

        bar:ClearAllPoints();
        bar:SetPoint("TOP", bar:GetParent(), "TOP", bar.x, y);
        bar:SetHeight(12);

        if (not bar.bar.isCollapsed) then
            y = y - (bar.panel:GetHeight() + 13);
        else
            y = y - 13;
        end
    end
end