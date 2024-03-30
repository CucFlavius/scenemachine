local UI = SceneMachine.UI;
UI.Rectangle = {};

--- @class Rectangle : Element
local Rectangle = UI.Rectangle;

Rectangle.__index = Rectangle;
setmetatable(Rectangle, UI.Element)

--- Creates a new instance of the Rectangle class.
---@param x number? The x-coordinate of the rectangle's position. Defaults to 0.
---@param y number? The y-coordinate of the rectangle's position. Defaults to 0.
---@param w number? The width of the rectangle. Defaults to 20.
---@param h number? The height of the rectangle. Defaults to 20.
---@param parent table? The parent element of the rectangle. Defaults to nil.
---@param point string? The anchor point of the rectangle relative to its parent. Defaults to "TOPLEFT".
---@param parentPoint string? The anchor point of the parent element that the rectangle is attached to. Defaults to "TOPLEFT".
---@param R number? The red color component of the rectangle. Defaults to 1.
---@param G number? The green color component of the rectangle. Defaults to 1.
---@param B number? The blue color component of the rectangle. Defaults to 1.
---@param A number? The alpha (transparency) value of the rectangle. Defaults to 1.
---@return Rectangle: The newly created Rectangle object.
function Rectangle:New(x, y, w, h, parent, point, parentPoint, R, G, B, A)
    --- @class Rectangle : Element
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
        visible = true,
    };

	setmetatable(v, Rectangle);

    v.frame = CreateFrame("Frame", "SceneMachine.UI.Rectangle.frame", v.parent);
	v.frame:SetPoint(v.point, v.parent, v.parentPoint, v.x, v.y);
	v.frame:SetSize(v.w, v.h);
    v:Build();

	return v;
end

--- Creates a new instance of the Rectangle class.
--- @param xA number The x-coordinate of the top-left corner of the rectangle.
--- @param yA number The y-coordinate of the top-left corner of the rectangle.
--- @param xB number The x-coordinate of the top-right corner of the rectangle.
--- @param yB number The y-coordinate of the top-right corner of the rectangle.
--- @param h number The height of the rectangle.
--- @param parent table The parent element to attach the rectangle to.
--- @param R number? The red color component of the rectangle (0-1).
--- @param G number? The green color component of the rectangle (0-1).
--- @param B number? The blue color component of the rectangle (0-1).
--- @param A number? The alpha (transparency) value of the rectangle (0-1).
--- @return Rectangle: The newly created Rectangle instance.
function Rectangle:NewTLTR(xA, yA, xB, yB, h, parent, R, G, B, A)
    local v =
    {
        parent = parent or nil,
        R = R or 1,
        G = G or 1,
        B = B or 1,
        A = A or 1,
        visible = true,
    };

    setmetatable(v, Rectangle);

    v.frame = CreateFrame("Frame", "SceneMachine.UI.Rectangle.frame", parent);
    v.frame:SetPoint("TOPLEFT", parent, "TOPLEFT", xA, yA);
    v.frame:SetPoint("TOPRIGHT", parent, "TOPRIGHT", xB, yB);
    v.frame:SetHeight(h);

    v:Build();
    return v;
end

--- Creates a new instance of the Rectangle class.
--- @param xA number The x-coordinate of the top-right corner of the rectangle.
--- @param yA number The y-coordinate of the top-right corner of the rectangle.
--- @param xB number The x-coordinate of the bottom-right corner of the rectangle.
--- @param yB number The y-coordinate of the bottom-right corner of the rectangle.
--- @param w number The width of the rectangle.
--- @param parent table The parent element of the rectangle (optional).
--- @param R number? The red color component of the rectangle (optional).
--- @param G number? The green color component of the rectangle (optional).
--- @param B number? The blue color component of the rectangle (optional).
--- @param A number? The alpha (transparency) value of the rectangle (optional).
--- @return Rectangle: The newly created Rectangle instance.
function Rectangle:NewTRBR(xA, yA, xB, yB, w, parent, R, G, B, A)
    local v =
    {
        parent = parent or nil,
        R = R or 1,
        G = G or 1,
        B = B or 1,
        A = A or 1,
        visible = true,
    };

    setmetatable(v, Rectangle);

    v.frame = CreateFrame("Frame", "SceneMachine.UI.Rectangle.frame", parent);
    v.frame:SetPoint("TOPRIGHT", parent, "TOPRIGHT", xA, yA);
    v.frame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", xB, yB);
    v.frame:SetWidth(w);

    v:Build();
    return v;
end

--- Creates a new instance of the Rectangle class.
--- @param xA number The x-coordinate of the top-left corner.
--- @param yA number The y-coordinate of the top-left corner.
--- @param xB number The x-coordinate of the bottom-left corner.
--- @param yB number The y-coordinate of the bottom-left corner.
--- @param w number The width of the rectangle.
--- @param parent table The parent frame to attach the rectangle to. If not provided, the rectangle will have no parent.
--- @param R number? The red color component of the rectangle (0-1). Defaults to 1.
--- @param G number? The green color component of the rectangle (0-1). Defaults to 1.
--- @param B number? The blue color component of the rectangle (0-1). Defaults to 1.
--- @param A number? The alpha (transparency) value of the rectangle (0-1). Defaults to 1.
--- @return Rectangle: The newly created Rectangle object.
function Rectangle:NewTLBL(xA, yA, xB, yB, w, parent, R, G, B, A)
    --- @class Rectangle : Element
    local v =
    {
        parent = parent or nil,
        R = R or 1,
        G = G or 1,
        B = B or 1,
        A = A or 1,
        visible = true,
    };

    setmetatable(v, Rectangle);

    v.frame = CreateFrame("Frame", "SceneMachine.UI.Rectangle.frame", parent);
    v.frame:SetPoint("TOPLEFT", parent, "TOPLEFT", xA, yA);
    v.frame:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", xB, yB);
    v.frame:SetWidth(w);

    v:Build();
    return v;
end

--- Creates a new instance of the Rectangle class.
--- @param xA number The x-coordinate of the bottom-left corner of the rectangle.
--- @param yA number The y-coordinate of the bottom-left corner of the rectangle.
--- @param xB number The x-coordinate of the bottom-right corner of the rectangle.
--- @param yB number The y-coordinate of the bottom-right corner of the rectangle.
--- @param h number The height of the rectangle.
--- @param parent table The parent frame to attach the rectangle to.
--- @param R number? The red color component of the rectangle (0-1).
--- @param G number? The green color component of the rectangle (0-1).
--- @param B number? The blue color component of the rectangle (0-1).
--- @param A number? The alpha (transparency) value of the rectangle (0-1).
--- @return Rectangle: The newly created Rectangle instance.
function Rectangle:NewBLBR(xA, yA, xB, yB, h, parent, R, G, B, A)
    local v =
    {
        parent = parent or nil,
        R = R or 1,
        G = G or 1,
        B = B or 1,
        A = A or 1,
        visible = true,
    };

    setmetatable(v, Rectangle);

    v.frame = CreateFrame("Frame", "SceneMachine.UI.Rectangle.frame", parent);
    v.frame:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", xA, yA);
    v.frame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", xB, yB);
    v.frame:SetHeight(h);

    v:Build();
    return v;
end

--- Creates a new instance of the Rectangle class.
--- @param xA number The x-coordinate of the top-left corner of the rectangle.
--- @param yA number The y-coordinate of the top-left corner of the rectangle.
--- @param xB number The x-coordinate of the bottom-right corner of the rectangle.
--- @param yB number The y-coordinate of the bottom-right corner of the rectangle.
--- @param parent table The parent frame to attach the rectangle to. Defaults to nil.
--- @param R number? The red color component of the rectangle. Defaults to 1.
--- @param G number? The green color component of the rectangle. Defaults to 1.
--- @param B number? The blue color component of the rectangle. Defaults to 1.
--- @param A number? The alpha (transparency) value of the rectangle. Defaults to 1.
--- @return Rectangle: The newly created Rectangle instance.
function Rectangle:NewTLBR(xA, yA, xB, yB, parent, R, G, B, A)
    local v =
    {
        parent = parent or nil,
        R = R or 1,
        G = G or 1,
        B = B or 1,
        A = A or 1,
        visible = true,
    };

    setmetatable(v, Rectangle);

    v.frame = CreateFrame("Frame", "SceneMachine.UI.Rectangle.frame", parent);
    v.frame:SetPoint("TOPLEFT", parent, "TOPLEFT", xA, yA);
    v.frame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", xB, yB);

    v:Build();
    return v;
end

--- Creates a new instance of the Rectangle class.
--- @param parent table The parent element.
--- @param R number? The red color component (0-1).
--- @param G number? The green color component (0-1).
--- @param B number? The blue color component (0-1).
--- @param A number? The alpha (transparency) value (0-1).
--- @return Rectangle: The newly created Rectangle instance.
function Rectangle:NewAP(parent, R, G, B, A)
    --- @class Rectangle : Element
    local v =
    {
        parent = parent or nil,
        R = R or 1,
        G = G or 1,
        B = B or 1,
        A = A or 1,
        visible = true,
    };

    setmetatable(v, Rectangle);

    v.frame = CreateFrame("Frame", "SceneMachine.UI.Rectangle.frame", parent);
    v.frame:SetAllPoints(v.parent);

    v:Build();
    return v;
end

--- Builds the rectangle by creating and configuring a texture for the frame.
function Rectangle:Build()
    self.frame.texture = self.frame:CreateTexture("Rectangle Frame Texture", "BACKGROUND");
    self.frame.texture:SetColorTexture(self.R, self.G, self.B, self.A);
    self.frame.texture:SetAllPoints(self.frame);
end

--- Sets the vertex offset of the rectangle's texture.
--- @param vertexIndex number The index of the vertex to set the offset for.
--- @param offsetX number The horizontal offset.
--- @param offsetY number The vertical offset.
function Rectangle:SetVertexOffset(vertexIndex, offsetX, offsetY)
    self.frame.texture:SetVertexOffset(vertexIndex, offsetX, offsetY);
end

--- Sets the color of the rectangle.
--- @param R number The red component of the color (0-1).
--- @param G number The green component of the color (0-1).
--- @param B number The blue component of the color (0-1).
--- @param A number The alpha component of the color (0-1).
function Rectangle:SetColor(R, G, B, A)
    self.R = R;
    self.G = G;
    self.B = B;
    self.A = A;
    self.frame.texture:SetColorTexture(self.R, self.G, self.B, self.A);
end

Rectangle.__tostring = function(self)
	return string.format("Rectangle( %.3f, %.3f, %.3f, %.3f )", self.x, self.y, self.w, self.h);
end