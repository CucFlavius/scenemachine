SceneMachine.UI.ImageBox = {};

--- @class ImageBox : Element
local ImageBox = SceneMachine.UI.ImageBox;
local UI = SceneMachine.UI;

ImageBox.__index = ImageBox;
setmetatable(ImageBox, UI.Element)

--- Builds the ImageBox by creating and setting the texture.
function ImageBox:Build()
    self.texture = self.values[1];
    self.texcoords = self.values[2];

    if (self.texture) then
        self.frame.texture = self.frame:CreateTexture("ImageBox Frame Texture", "BACKGROUND");
        self.frame.texture:SetTexture(self.texture);
        self.frame.texture:SetAllPoints(self.frame);
        if (self.texcoords ~= nil) then
            self.frame.texture:SetTexCoord(self.texcoords[1], self.texcoords[2], self.texcoords[3], self.texcoords[4]);
        end
    end
end

--- Sets the vertex color of the ImageBox.
--- @param R number The red component of the color (0-1).
--- @param G number The green component of the color (0-1).
--- @param B number The blue component of the color (0-1).
--- @param A number The alpha component of the color (0-1).
function ImageBox:SetVertexColor(R, G, B, A)
    if (self.frame.texture) then
        self.frame.texture:SetVertexColor(R, G, B, A);
    end
end

--- Retrieves the vertex color of the ImageBox.
--- @return number R, number G, number B, number A - The red, green, blue, and alpha components of the color.
function ImageBox:GetVertexColor()
    return self.frame.texture:GetVertexColor();
end

--- Sets the texture for the ImageBox.
--- @param texture string The path to the texture file.
function ImageBox:SetTexture(texture)
    self.texture = texture;
    if (not self.frame.texture) then
        self.frame.texture = self.frame:CreateTexture("ImageBox Frame Texture", "BACKGROUND");
        self.frame.texture:SetAllPoints(self.frame);
    end
    self.frame.texture:SetTexture(self.texture);
end

--- Sets the texture coordinates for the ImageBox.
--- @param texcoords table The table containing the texture coordinates.
function ImageBox:SetTexCoords(texcoords)
    self.texcoords = texcoords;
    self.frame.texture:SetTexCoord(self.texcoords[1], self.texcoords[2], self.texcoords[3], self.texcoords[4]);
end

--- Retrieves the texture coordinates of the ImageBox.
--- @return table: The texture coordinates of the ImageBox.
function ImageBox:GetTexCoords()
    return self.texcoords;
end

--- Sets the blend mode for the ImageBox.
--- @param mode number The blend mode to set.
function ImageBox:SetBlendMode(mode)
    self.frame.texture:SetBlendMode(mode);
end

ImageBox.__tostring = function(self)
	return string.format("ImageBox( %.3f, %.3f, %.3f, %.3f, %s )", self.x, self.y, self.w, self.h, self.parent);
end