local UI = SceneMachine.UI;
UI.CollapsableList = {};

--- @class CollapsableList : Element
local CollapsableList = UI.CollapsableList;
CollapsableList.__index = CollapsableList;
setmetatable(CollapsableList, UI.Element)

--- Creates a new instance of the CollapsableList class.
--- @param x number (optional) - The x-coordinate of the list's position.
--- @param y number (optional) - The y-coordinate of the list's position.
--- @param w number (optional) - The width of the list.
--- @param h number (optional) - The height of the list.
--- @param parent table (optional) - The parent element of the list.
--- @param point string (optional) - The anchor point of the list.
--- @param parentPoint string (optional) - The anchor point of the parent element.
--- @param sizesY table (optional) - The sizes of the list items along the y-axis.
--- @param titles table (optional) - The titles of the list items.
--- @param R number (optional) - The red color component of the list.
--- @param G number (optional) - The green color component of the list.
--- @param B number (optional) - The blue color component of the list.
--- @param A number (optional) - The alpha (transparency) value of the list.
--- @return CollapsableList: The newly created CollapsableList instance.
function CollapsableList:New(x, y, w, h, parent, point, parentPoint, sizesY, titles, R, G, B, A)
    --- @class CollapsableList : Element
	local v = 
    {
        x = x or 0,
        y = y or 0,
        w = w or 20,
        h = h or 20,
        parent = parent or nil,
        point = point or "TOPLEFT",
        parentPoint = parentPoint or "TOPLEFT",
        sizesY = sizesY or nil,
        titles = titles or nil,
        R = R or 1,
        G = G or 1,
        B = B or 1,
        A = A or 1,
        visible = true,
    };

	setmetatable(v, CollapsableList);

	v.frame = CreateFrame("Frame", "SceneMachine.UI.CollapsableList.frame", v.parent);
	v.frame:SetPoint(v.point, v.parent, v.parentPoint, v.x, v.y);
	v.frame:SetSize(v.w, v.h);

    v:Build();
	return v;
end

--- Creates a new instance of the CollapsableList class.
--- @param xA number: The x-coordinate of the top-left corner of the list.
--- @param yA number: The y-coordinate of the top-left corner of the list.
--- @param xB number: The x-coordinate of the bottom-right corner of the list.
--- @param yB number: The y-coordinate of the bottom-right corner of the list.
--- @param parent table: The parent frame to attach the list to.
--- @param sizesY table: The sizes of the list items in the y-direction.
--- @param titles table: The titles of the list items.
--- @param R number: The red color component of the list background.
--- @param G number: The green color component of the list background.
--- @param B number: The blue color component of the list background.
--- @param A number: The alpha (transparency) value of the list background.
--- @return CollapsableList: The newly created CollapsableList instance.
function CollapsableList:NewTLBR(xA, yA, xB, yB, parent, sizesY, titles, R, G, B, A)
    local v =
    {
        parent = parent or nil,
        sizesY = sizesY or nil,
        titles = titles or nil,
        R = R or 1,
        G = G or 1,
        B = B or 1,
        A = A or 1,
        visible = true,
    };

    setmetatable(v, CollapsableList);

    v.frame = CreateFrame("Frame", "SceneMachine.UI.CollapsableList.frame", parent);
    v.frame:SetPoint("TOPLEFT", parent, "TOPLEFT", xA, yA);
    v.frame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", xB, yB);

    v:Build();
    return v;
end

--- Builds the collapsible list.
function CollapsableList:Build()
    self.frame:SetClipsChildren(true);
    
    self.list = UI.Rectangle:NewTLBR(self.x, self.y, -16, 0, self.frame, 0, 0, 0, 0);
    self.bars = {};
    for c = 1, #self.titles, 1 do
        self.bars[c] = UI.CollapsableBox:New(self.x, self.y, self.w, self.sizesY[c], self.list:GetFrame(),
                                            self.point, self.parentPoint, self.titles[c],
                                            self.R, self.G, self.B, self.A, self);
    end

    self.scrollbar = UI.Scrollbar:NewTRBR(0, 0, 0, 0, 16, self.frame, function(v) self:SetPosition(v); end);

    self.frame:SetScript("OnSizeChanged",
    function(_, width, height)
        self.viewportHeight = height;
        self.scrollbar:Resize(height, self:GetVisibleHeight());
    end);

    self:Sort();
end

--- Sets the position of the CollapsableList.
--- @param value number The value representing the position, ranging from 0 to 1.
function CollapsableList:SetPosition(value)
    local min = 0;
    local max = self:GetVisibleHeight() - self.frame:GetHeight();
    local pos = value * max;
    self.list:ClearAllPoints();
    self.list:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 0, pos);
    self.list:SetPoint("BOTTOMRIGHT", self.frame, "BOTTOMRIGHT", -16, pos + max);
end

--- Calculates and returns the visible height of the CollapsableList.
--- The visible height is the sum of the heights of all visible child frames plus 12 pixels of spacing between each frame.
--- @return number: The visible height of the CollapsableList.
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

--- Calculates the total height of the CollapsableList.
--- @return number: The total height of the CollapsableList.
function CollapsableList:GetTotalHeight()
    local h = 0;
    for c = 1, #self.sizesY, 1 do
        h = h + self.sizesY[c] + 12;
    end
    return h;
end

--- Sorts the collapsible list by adjusting the position and height of each bar.
function CollapsableList:Sort()
    local y = 0;

    for c = 1, #self.bars, 1 do
        local bar = self.bars[c];

        bar:ClearAllPoints();
        bar:SetPoint("TOPLEFT", bar:GetParent(), "TOPLEFT", bar.x, y);
        bar:SetPoint("TOPRIGHT", bar:GetParent(), "TOPRIGHT", bar.x, y);
        bar:SetHeight(12);

        local visible = bar:IsVisible();
        if (visible) then
            if (not bar.bar.isCollapsed) then
                y = y - (bar.panel:GetHeight() + 13);
            else
                y = y - 13;
            end
        end
    end
end

CollapsableList.__tostring = function(self)
	return string.format("CollapsableList( %.3f, %.3f, %.3f, %.3f, %s )", self.x, self.y, self.w, self.h, self.parent);
end