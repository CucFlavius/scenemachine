SceneMachine.UI.ImageBox = {};
local ImageBox = SceneMachine.UI.ImageBox;
ImageBox.__index = ImageBox;
setmetatable(ImageBox, SceneMachine.UI.Element)

function ImageBox:New(x, y, w, h, parent, point, parentPoint, texture, texcoords)
	local v = 
    {
        x = x or 0,
        y = y or 0,
        w = w or 20,
        h = h or 20,
        parent = parent or nil,
        point = point or "TOPLEFT",
        parentPoint = parentPoint or "TOPLEFT",
        texture = texture or nil,
        texcoords = texcoords or nil,
        visible = true,
    };

	setmetatable(v, ImageBox);
    v:Build();
	return v;
end

function ImageBox:Build()
	self.frame = CreateFrame("Frame", "SceneMachine.UI.ImageBox.frame", self.parent);
	self.frame:SetPoint(self.point, self.parent, self.parentPoint, self.x, self.y);
	self.frame:SetSize(self.w, self.h);
    if (self.texture) then
        self.frame.texture = self.frame:CreateTexture("ImageBox Frame Texture", "BACKGROUND");
        self.frame.texture:SetTexture(self.texture);
        self.frame.texture:SetAllPoints(self.frame);
        if (self.texcoords ~= nil) then
            self.frame.texture:SetTexCoord(self.texcoords[1], self.texcoords[2], self.texcoords[3], self.texcoords[4]);
        end
    end
end

function ImageBox:SetVertexColor(R, G, B, A)
    if (self.frame.texture) then
        self.frame.texture:SetVertexColor(R, G, B, A);
    end
end

function ImageBox:GetVertexColor()
    return self.frame.texture:GetVertexColor();
end

function ImageBox:SetTexture(texture)
    self.texture = texture;
    if (not self.frame.texture) then
        self.frame.texture = self.frame:CreateTexture("ImageBox Frame Texture", "BACKGROUND");
        self.frame.texture:SetAllPoints(self.frame);
    end
    self.frame.texture:SetTexture(self.texture);
end

function ImageBox:SetTexCoords(texcoords)
    self.texcoords = texcoords;
    self.frame.texture:SetTexCoord(self.texcoords[1], self.texcoords[2], self.texcoords[3], self.texcoords[4]);
end

function ImageBox:GetTexCoords()
    return self.texcoords;
end

function ImageBox:SetBlendMode(mode)
    self.frame.texture:SetBlendMode(mode);
end

ImageBox.__tostring = function(self)
	return string.format("ImageBox( %.3f, %.3f, %.3f, %.3f, %s )", self.x, self.y, self.w, self.h, self.parent);
end