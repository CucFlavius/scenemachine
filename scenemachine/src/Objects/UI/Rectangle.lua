local UI = SceneMachine.UI;
UI.Rectangle = {};
local Rectangle = UI.Rectangle;
Rectangle.__index = Rectangle;
setmetatable(Rectangle, UI.Element)

function Rectangle:New(x, y, w, h, parent, point, parentPoint, R, G, B, A)
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
    v:Build();
	return v;
end

function Rectangle:Build()
	self.frame = CreateFrame("Frame", "SceneMachine.UI.Rectangle.frame", self.parent);
	self.frame:SetPoint(self.point, self.parent, self.parentPoint, self.x, self.y);
	self.frame:SetSize(self.w, self.h);
	self.frame.texture = self.frame:CreateTexture("Rectangle Frame Texture", "BACKGROUND");
	self.frame.texture:SetColorTexture(self.R, self.G, self.B, self.A);
	self.frame.texture:SetAllPoints(self.frame);
end

function Rectangle:SetVertexOffset(vertexIndex, offsetX, offsetY)
    self.frame.texture:SetVertexOffset(vertexIndex, offsetX, offsetY);
end

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