local UI = SceneMachine.UI;
UI.CollapsableBox = {};
local CollapsableBox = UI.CollapsableBox;
CollapsableBox.__index = CollapsableBox;
setmetatable(CollapsableBox, UI.Element)

function CollapsableBox:New(x, y, w, h, parent, point, parentPoint, title, R, G, B, A, list)
	local v = 
    {
        x = x or 0,
        y = y or 0,
        w = w or 20,
        h = h or 20,
        parent = parent or nil,
        point = point or "TOPLEFT",
        parentPoint = parentPoint or "TOPLEFT",
        R = R or 1,
        G = G or 1,
        B = B or 1,
        A = A or 1,
        title = title or nil,
        list = list or nil,
        visible = true,
    };

	setmetatable(v, CollapsableBox);
    v:Build();
	return v;
end

function CollapsableBox:Build()
    self.bar = UI.Button:New(self.x, self.y, self.w, 12, self.parent, "TOPLEFT", "TOPLEFT", self.title);
    self.bar:SetPoint("TOPRIGHT", self.parent, "TOPRIGHT", self.x, self.y);
    self.panel = UI.Rectangle:New(0, -12, self.w, self.h, self.bar.frame, "TOPLEFT", "TOPLEFT", self.R, self.G, self.B, self.A);
    self.panel:SetPoint("TOPRIGHT", self.bar.frame, "TOPRIGHT", 0, -12);
    local list = self.list;
    local panel = self.panel;
    local bar = self.bar;
    self.frame = self.bar.frame;
    self.isCollapsed = false;
    self.bar:SetJustifyH("CENTER");
    self.bar:SetScript("OnClick", function (self, button, down)
        bar.isCollapsed = not bar.isCollapsed;
        if (bar.isCollapsed) then
            list:Sort();
            panel:Hide();
            list.scrollbar:Resize(list.viewportHeight, list:GetVisibleHeight());
        else
            list:Sort();
            panel:Show();
            list.scrollbar:Resize(list.viewportHeight, list:GetVisibleHeight());
        end
    end);

end

CollapsableBox.__tostring = function(self)
	return string.format("CollapsableBox( %.3f, %.3f, %.3f, %.3f, %s )", self.x, self.y, self.w, self.h, self.parent);
end