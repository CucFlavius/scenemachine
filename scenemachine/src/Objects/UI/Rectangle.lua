local UI = SceneMachine.UI;
UI.Rectangle = {};

--- @class Rectangle : Element
local Rectangle = UI.Rectangle;

Rectangle.__index = Rectangle;
setmetatable(Rectangle, UI.Element)

--- Builds the rectangle by creating and configuring a texture for the frame.
function Rectangle:Build()
    self.R = self.values[1] or 1;
    self.G = self.values[2] or 1;
    self.B = self.values[3] or 1;
    self.A = self.values[4] or 1;
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