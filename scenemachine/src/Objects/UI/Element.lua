SceneMachine.UI.Element = {};

--- @class Element
local Element = SceneMachine.UI.Element;

Element.__index = Element;

function Element:GetFrameType()
    return "Frame";
end

function Element:Build()
end

--- Creates a new Element object.
--- @param x number? The x-coordinate of the Element's position.
--- @param y number? The y-coordinate of the Element's position.
--- @param w number? The width of the Element.
--- @param h number? The height of the Element.
--- @param parent table? The parent frame of the Element.
--- @param point string? The anchor point of the Element relative to its parent.
--- @param parentPoint string? The anchor point of the parent object.
--- @return Element: The newly created Element object.
function Element:New(x, y, w, h, parent, point, parentPoint, ...)
    --- @class Element
    local v = 
    {
        x = x or 0,
        y = y or 0,
        w = w or 20,
        h = h or 20,
        parent = parent or nil,
        point = point or "TOPLEFT",
        parentPoint = parentPoint or "TOPLEFT",
        values = {...},
        visible = true,
        tooltip = nil,
        detailedTooltip = nil,
    };

    setmetatable(v, self);

	v.frame = CreateFrame(self:GetFrameType(), nil, v.parent);
	v.frame:SetPoint(v.point, v.parent, v.parentPoint, v.x, v.y);
	v.frame:SetSize(v.w, v.h);

    v:Build();
    return v;
end

--- Creates a new instance of the Element class given left and right coordinates.
--- @param xA number The x-coordinate of the left anchor point.
--- @param yA number The y-coordinate of the left anchor point.
--- @param xB number The x-coordinate of the right anchor point.
--- @param yB number The y-coordinate of the right anchor point.
--- @param h number The height of the Element.
--- @param parent table? The parent element to attach the Element to.
--- @return Element: The newly created Element instance.
function Element:NewLR(xA, yA, xB, yB, h, parent, ...)
    --- @class Element
    local v =
    {
        parent = parent or nil,
        values = {...},
        visible = true,
    };

    setmetatable(v, self);

    v.frame = CreateFrame("Frame", nil, v.parent);
    v.frame:SetPoint("LEFT", parent, "LEFT", xA, yA);
    v.frame:SetPoint("RIGHT", parent, "RIGHT", xB, yB);
    v.frame:SetHeight(h);

    v:Build();
    return v;
end

--- Creates a new instance of the Element class, given top and bottom coordinates.
--- @param xA number The x-coordinate of the top anchor point.
--- @param yA number The y-coordinate of the top anchor point.
--- @param xB number The x-coordinate of the bottom anchor point.
--- @param yB number The y-coordinate of the bottom anchor point.
--- @param w number The width of the Element.
--- @param parent table? The parent element of the Element.
--- @return Element: The newly created Element instance.
function Element:NewTB(xA, yA, xB, yB, w, parent, ...)
    --- @class Element
    local v =
    {
        parent = parent or nil,
        values = {...},
        visible = true,
    };

    setmetatable(v, self);

    v.frame = CreateFrame("Frame", nil, v.parent);
    v.frame:SetPoint("TOP", parent, "TOP", xA, yA);
    v.frame:SetPoint("BOTTOM", parent, "BOTTOM", xB, yB);
    v.frame:SetWidth(w);

    v:Build();
    return v;
end

--- Creates a new instance of the Element class.
--- @param xA number The x-coordinate of the top-left corner of the Element.
--- @param yA number The y-coordinate of the top-left corner of the Element.
--- @param xB number The x-coordinate of the top-right corner of the Element.
--- @param yB number The y-coordinate of the top-right corner of the Element.
--- @param h number The height of the Element.
--- @param parent table The parent element to attach the Element to.
--- @return Element: The newly created Element instance.
function Element:NewTLTR(xA, yA, xB, yB, h, parent, ...)
    local v =
    {
        parent = parent or nil,
        values = {...},
        visible = true,
    };

    setmetatable(v, self);

    v.frame = CreateFrame(self:GetFrameType(), nil, parent);
    v.frame:SetPoint("TOPLEFT", parent, "TOPLEFT", xA, yA);
    v.frame:SetPoint("TOPRIGHT", parent, "TOPRIGHT", xB, yB);
    v.frame:SetHeight(h);

    v:Build();
    return v;
end

--- Creates a new instance of the Element class.
--- @param xA number The x-coordinate of the top-right corner of the Element.
--- @param yA number The y-coordinate of the top-right corner of the Element.
--- @param xB number The x-coordinate of the bottom-right corner of the Element.
--- @param yB number The y-coordinate of the bottom-right corner of the Element.
--- @param w number The width of the Element.
--- @param parent table The parent element of the Element (optional).
--- @return Element: The newly created Element instance.
function Element:NewTRBR(xA, yA, xB, yB, w, parent, ...)
    local v =
    {
        parent = parent or nil,
        values = {...},
        visible = true,
    };

    setmetatable(v, self);

    v.frame = CreateFrame(self:GetFrameType(), nil, parent);
    v.frame:SetPoint("TOPRIGHT", parent, "TOPRIGHT", xA, yA);
    v.frame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", xB, yB);
    v.frame:SetWidth(w);

    v:Build();
    return v;
end

--- Creates a new instance of the Element class.
--- @param xA number The x-coordinate of the top-left corner.
--- @param yA number The y-coordinate of the top-left corner.
--- @param xB number The x-coordinate of the bottom-left corner.
--- @param yB number The y-coordinate of the bottom-left corner.
--- @param w number The width of the Element.
--- @param parent table The parent frame to attach the Element to. If not provided, the Element will have no parent.
--- @return Element: The newly created Element object.
function Element:NewTLBL(xA, yA, xB, yB, w, parent, ...)
    --- @class Element
    local v =
    {
        parent = parent or nil,
        values = {...},
        visible = true,
    };

    setmetatable(v, self);

    v.frame = CreateFrame(self:GetFrameType(), nil, parent);
    v.frame:SetPoint("TOPLEFT", parent, "TOPLEFT", xA, yA);
    v.frame:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", xB, yB);
    v.frame:SetWidth(w);

    v:Build();
    return v;
end

--- Creates a new instance of the Element class.
--- @param xA number The x-coordinate of the bottom-left corner of the Element.
--- @param yA number The y-coordinate of the bottom-left corner of the Element.
--- @param xB number The x-coordinate of the bottom-right corner of the Element.
--- @param yB number The y-coordinate of the bottom-right corner of the Element.
--- @param h number The height of the Element.
--- @param parent table The parent frame to attach the Element to.
--- @return Element: The newly created Element instance.
function Element:NewBLBR(xA, yA, xB, yB, h, parent, ...)
    local v =
    {
        parent = parent or nil,
        values = {...},
        visible = true,
    };

    setmetatable(v, self);

    v.frame = CreateFrame(self:GetFrameType(), nil, parent);
    v.frame:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", xA, yA);
    v.frame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", xB, yB);
    v.frame:SetHeight(h);

    v:Build();
    return v;
end

--- Creates a new instance of the Element class.
--- @param xA number The x-coordinate of the top-left corner of the Element.
--- @param yA number The y-coordinate of the top-left corner of the Element.
--- @param xB number The x-coordinate of the bottom-right corner of the Element.
--- @param yB number The y-coordinate of the bottom-right corner of the Element.
--- @param parent table The parent frame to attach the Element to. Defaults to nil.
--- @return Element: The newly created Element instance.
function Element:NewTLBR(xA, yA, xB, yB, parent, ...)
    local v =
    {
        parent = parent or nil,
        values = {...},
        visible = true,
    };

    setmetatable(v, self);

    v.frame = CreateFrame(self:GetFrameType(), nil, parent);
    v.frame:SetPoint("TOPLEFT", parent, "TOPLEFT", xA, yA);
    v.frame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", xB, yB);

    v:Build();
    return v;
end

--- Creates a new instance of the Element class.
--- @param parent table The parent element.
--- @return Element: The newly created Element instance.
function Element:NewAP(parent, ...)
    --- @class Element
    local v =
    {
        parent = parent or nil,
        values = {...},
        visible = true,
    };

    setmetatable(v, self);

    v.frame = CreateFrame(self:GetFrameType(), nil, parent);
    v.frame:SetAllPoints(v.parent);

    v:Build();
    return v;
end


--- Shows the UI element
function Element:Show()
    self.visible = true;
    self.frame:Show();
end

--- Hides the UI element
function Element:Hide()
    self.visible = false;
    self.frame:Hide();
end

--- Checks if the element is visible.
--- @return boolean: True if the element is visible, false otherwise.
function Element:IsVisible()
    return self.visible;
end

--- Sets the frame level of the UI element.
--- @param level number The new frame level.
function Element:SetFrameLevel(level)
    self.frame:SetFrameLevel(level);
end

--- Retrieves the frame level of the element.
--- @return number: The frame level of the element.
function Element:GetFrameLevel()
    return self.frame:GetFrameLevel();
end

--- Sets the frame strata for the element.
--- @param strata string The frame strata to set.
function Element:SetFrameStrata(strata)
    self.frame:SetFrameStrata(strata);
end

--- Retrieves the frame strata of the element.
--- @return string: The frame strata of the element.
function Element:GetFrameStrata()
    return self.frame:GetFrameStrata();
end

--- Sets the parent frame of the element.
--- @param parent table The parent frame to set.
function Element:SetParent(parent)
    self.parent = parent;
    self.frame:SetParent(parent);
end

--- Retrieves the parent frame of the element.
--- @return table: The parent frame of the element.
function Element:GetParent()
    return self.parent;
end

--- Sets a single point position for the frame, clearing all other points.
--- @param point string The anchor point for the element.
--- @param ofsx number The horizontal offset from the anchor point.
--- @param ofsy number The vertical offset from the anchor point.
function Element:SetSinglePoint(point, ofsx, ofsy)
    self.frame:ClearAllPoints();
    self.frame:SetPoint(point, ofsx, ofsy);
end

--- Sets the position of the element's frame relative to another frame.
---@param point string The anchor point of the element's frame.
---@param relativeFrame table The frame to which the element's frame will be positioned relative to.
---@param relativePoint string The anchor point of the relative frame.
---@param ofsx number The horizontal offset from the anchor point.
---@param ofsy number The vertical offset from the anchor point.
function Element:SetPoint(point, relativeFrame, relativePoint, ofsx, ofsy)
    self.frame:SetPoint(point, relativeFrame, relativePoint, ofsx, ofsy);
end

--- Retrieves the position of a point on the element.
--- @param index number The index of the point to retrieve.
--- @return table: The position of the point as a table with x and y coordinates.
function Element:GetPoint(index)
    return self.frame:GetPoint(index);
end

--- Clears all anchor points from the element.
function Element:ClearAllPoints()
    self.frame:ClearAllPoints();
end

--- Sets the position and size of the element's frame to match another frame.
--- @param frame table The frame to match the position and size to.
function Element:SetAllPoints(frame)
    self.frame:SetAllPoints(frame);
end

--- Sets the width of the element.
--- @param w number The new width of the element.
function Element:SetWidth(w)
    self.w = w;
    self.frame:SetWidth(w);
end

--- Sets the height of the UI element.
--- @param h number The new height value.
function Element:SetHeight(h)
    self.h = h;
    self.frame:SetHeight(h);
end

--- Sets the size of the element.
--- @param w number The width of the element.
--- @param h number The height of the element.
function Element:SetSize(w, h)
    self.frame:SetSize(w, h);
end

--- Retrieves the width of the element.
--- @return number: The width of the element.
function Element:GetWidth()
    return self.frame:GetWidth();
end

--- Retrieves the height of the element.
--- @return number: The height of the element.
function Element:GetHeight()
    return self.frame:GetHeight();
end

--- Retrieves the frame of the element.
--- @return table: The frame of the element.
function Element:GetFrame()
    return self.frame;
end

--- Sets the alpha value of the element.
--- @param alpha number The new alpha value (0-1).
function Element:SetAlpha(alpha)
    self.frame:SetAlpha(alpha);
end

--- Retrieves the alpha value of the element.
--- @return number: The alpha value of the element.
function Element:GetAlpha()
    return self.frame:GetAlpha();
end

--- Retrieves the left position of the element.
--- @return number: The left position of the element.
function Element:GetLeft()
    return self.frame:GetLeft();
end

--- Retrieves the right coordinate of the element.
--- @return number: The right coordinate of the element.
function Element:GetRight()
    return self.frame:GetRight();
end

--- Retrieves the top position of the element's frame.
--- @return number: The top position of the frame.
function Element:GetTop()
    return self.frame:GetTop();
end

--- Retrieves the bottom position of the element.
--- @return number: The bottom position of the element.
function Element:GetBottom()
    return self.frame:GetBottom();
end

--- Sets the scale of the element.
--- @param scale: number The scale value to set.
function Element:SetScale(scale)
    self.frame:SetScale(scale);
end

--- Retrieves the effective scale of the UI element.
--- @return number: The effective scale of the element.
function Element:GetEffectiveScale()
    return self.frame:GetEffectiveScale();
end

--- Sets whether the element should clip its children.
---@param on boolean Whether to clip the children or not.
function Element:SetClipsChildren(on)
    self.frame:SetClipsChildren(on);
end