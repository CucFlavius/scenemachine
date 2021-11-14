-------------------------- Zee's Window API ---------------------------
-- Developed it for use in my addons, but feel free to use in yours ---
-----------------------------------------------------------------------

--ImageBox--
local Win = ZWindowAPI;

function Win.CreateImageBox(posX, posY, sizeX, sizeY, parent, windowPoint, parentPoint, texture)

	-- defaults --
	if posX == nil then posX = 0; end
	if posY == nil then posY = 0; end
	if sizeX == nil or sizeX == 0 then sizeX = 50; end
	if sizeY == nil or sizeY == 0 then sizeY = 50; end	
	if parent == nil then parent = UIParent; end
	if windowPoint == nil then windowPoint = "CENTER"; end
	if parentPoint == nil then parentPoint = "CENTER"; end

	-- text box frame --
	local ImageBox = CreateFrame("Frame", "Zee.WindowAPI.ImageBox", parent);
	ImageBox:SetPoint(windowPoint, parent, parentPoint, posX, posY);
	ImageBox:SetSize(sizeX, sizeY);
	ImageBox.texture = ImageBox:CreateTexture("Zee.WindowAPI.ImageBox texture", "BACKGROUND");
	ImageBox.texture:SetTexture(texture)
	ImageBox.texture:SetAllPoints(ImageBox);

	return ImageBox;

end