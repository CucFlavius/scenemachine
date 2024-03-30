local UI = SceneMachine.UI;
UI.CollapsableBox = {};

--- @class CollapsableBox : Element
local CollapsableBox = UI.CollapsableBox;

CollapsableBox.__index = CollapsableBox;
setmetatable(CollapsableBox, UI.Element)

--- Creates a new instance of the CollapsableBox class.
--- @param x number (optional) - The x-coordinate of the box.
--- @param y number (optional) - The y-coordinate of the box.
--- @param w number (optional) - The width of the box.
--- @param h number (optional) - The height of the box.
--- @param parent table (optional) - The parent element of the box.
--- @param point string (optional) - The anchor point of the box.
--- @param parentPoint string (optional) - The anchor point of the parent element.
--- @param title string (optional) - The title of the box.
--- @param R number (optional) - The red color component of the box.
--- @param G number (optional) - The green color component of the box.
--- @param B number (optional) - The blue color component of the box.
--- @param A number (optional) - The alpha (transparency) value of the box.
--- @param list table (optional) - The list of items in the box.
--- @return CollapsableBox - The new instance of the CollapsableBox class.
function CollapsableBox:New(x, y, w, h, parent, point, parentPoint, title, R, G, B, A, list)
    --- @class CollapsableBox : Element
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

--- Builds the collapsible box UI element.
function CollapsableBox:Build()
    -- Create the bar button
    self.bar = UI.Button:NewTLTR(self.x, self.y, self.x, self.y, 12, self.parent, self.title, nil, nil);
    
    -- Create the panel rectangle
    self.panel = UI.Rectangle:NewTLTR(0, -12, 0, -12, self.h, self.bar.frame, self.R, self.G, self.B, self.A);
    
    -- Store references to local variables
    local list = self.list;
    local panel = self.panel;
    local bar = self.bar;
    
    -- Set the frame and collapsed state
    self.frame = self.bar.frame;
    self.isCollapsed = false;
    
    -- Set the bar justification and onClick behavior
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