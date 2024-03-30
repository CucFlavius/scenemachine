SceneMachine.UI.ImageBox = {};

--- @class ImageBox : Element
local ImageBox = SceneMachine.UI.ImageBox;

ImageBox.__index = ImageBox;
setmetatable(ImageBox, SceneMachine.UI.Element)

--- Creates a new instance of the ImageBox class.
--- @param x number? The x-coordinate of the ImageBox's position.
--- @param y number? The y-coordinate of the ImageBox's position.
--- @param w number? The width of the ImageBox.
--- @param h number? The height of the ImageBox.
--- @param parent table? The parent frame of the ImageBox.
--- @param point string? The anchor point of the ImageBox relative to its parent.
--- @param parentPoint string? The anchor point of the parent element relative to the ImageBox.
--- @param texture string? The path to the texture file for the ImageBox.
--- @param texcoords table? The texture coordinates for the ImageBox.
--- @return ImageBox - The newly created ImageBox instance.
function ImageBox:New(x, y, w, h, parent, point, parentPoint, texture, texcoords)
    --- @class ImageBox : Element
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

	v.frame = CreateFrame("Frame", "SceneMachine.UI.ImageBox.frame", v.parent);
	v.frame:SetPoint(v.point, v.parent, v.parentPoint, v.x, v.y);
	v.frame:SetSize(v.w, v.h);

    v:Build();
	return v;
end

--- Creates a new ImageBox object with specified top-left and bottom-right coordinates, parent frame, texture, and texture coordinates.
--- @param xA number The x-coordinate of the top-left corner.
--- @param yA number The y-coordinate of the top-left corner.
--- @param xB number The x-coordinate of the bottom-right corner.
--- @param yB number The y-coordinate of the bottom-right corner.
--- @param parent table The parent frame to attach the ImageBox to. Defaults to nil.
--- @param texture string? The path to the texture file to be used for the ImageBox. Defaults to nil.
--- @param texcoords table? The texture coordinates to be used for the ImageBox. Defaults to nil.
--- @return ImageBox: The newly created ImageBox object.
function ImageBox:NewTLBR(xA, yA, xB, yB, parent, texture, texcoords)
    local v =
    {
        parent = parent or nil,
        texture = texture or nil,
        texcoords = texcoords or nil,
        visible = true,
    };

    setmetatable(v, ImageBox);

    v.frame = CreateFrame("Frame", "SceneMachine.UI.ImageBox.frame", parent);
    v.frame:SetPoint("TOPLEFT", parent, "TOPLEFT", xA, yA);
    v.frame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", xB, yB);

    v:Build();
    return v;
end

--- Creates a new instance of the ImageBox class given left and right coordinates.
--- @param xA number The x-coordinate of the left anchor point.
--- @param yA number The y-coordinate of the left anchor point.
--- @param xB number The x-coordinate of the right anchor point.
--- @param yB number The y-coordinate of the right anchor point.
--- @param h number The height of the ImageBox.
--- @param parent table? The parent element to attach the ImageBox to.
--- @param texture string? The texture path for the ImageBox.
--- @param texcoords table? The texture coordinates for the ImageBox.
--- @return ImageBox: The newly created ImageBox instance.
function ImageBox:NewLR(xA, yA, xB, yB, h, parent, texture, texcoords)
    --- @class ImageBox : Element
    local v =
    {
        parent = parent or nil,
        texture = texture or nil,
        texcoords = texcoords or nil,
        visible = true,
    };

    setmetatable(v, ImageBox);

    v.frame = CreateFrame("Frame", "SceneMachine.UI.ImageBox.frame", parent);
    v.frame:SetPoint("LEFT", parent, "LEFT", xA, yA);
    v.frame:SetPoint("RIGHT", parent, "RIGHT", xB, yB);
    v.frame:SetHeight(h);

    v:Build();
    return v;
end

--- Creates a new instance of the ImageBox class, given top and bottom coordinates.
--- @param xA number The x-coordinate of the top anchor point.
--- @param yA number The y-coordinate of the top anchor point.
--- @param xB number The x-coordinate of the bottom anchor point.
--- @param yB number The y-coordinate of the bottom anchor point.
--- @param w number The width of the ImageBox.
--- @param parent table? The parent element of the ImageBox.
--- @param texture string? The texture path for the ImageBox.
--- @param texcoords table? The texture coordinates for the ImageBox.
--- @return ImageBox: The newly created ImageBox instance.
function ImageBox:NewTB(xA, yA, xB, yB, w, parent, texture, texcoords)
    --- @class ImageBox : Element
    local v =
    {
        parent = parent or nil,
        texture = texture or nil,
        texcoords = texcoords or nil,
        visible = true,
    };

    setmetatable(v, ImageBox);

    v.frame = CreateFrame("Frame", "SceneMachine.UI.ImageBox.frame", parent);
    v.frame:SetPoint("TOP", parent, "TOP", xA, yA);
    v.frame:SetPoint("BOTTOM", parent, "BOTTOM", xB, yB);
    v.frame:SetWidth(w);

    v:Build();
    return v;
end

--- Creates a new instance of the ImageBox class that wraps to fit the parent frame.
--- @param parent table? The parent frame.
--- @param texture string? The texture path to be displayed on the ImageBox.
--- @param texcoords table? The texture coordinates for mapping the texture onto the ImageBox.
--- @return ImageBox The newly created ImageBox instance.
function ImageBox:NewAP(parent, texture, texcoords)
    --- @class ImageBox : Element
    local v =
    {
        parent = parent or nil,
        texture = texture or nil,
        texcoords = texcoords or {0, 1, 0, 1},
        visible = true,
        tooltip = nil,
    };

    setmetatable(v, ImageBox);

    v.frame = CreateFrame("Frame", "SceneMachine.UI.ImageBox.frame", parent);
    v.frame:SetAllPoints(v.parent);

    v:Build();
    return v;
end

--- Builds the ImageBox by creating and setting the texture.
function ImageBox:Build()
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