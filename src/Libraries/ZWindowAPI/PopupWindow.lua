-------------------------- Zee's Window API ---------------------------
-- Developed it for use in my addons, but feel free to use in yours ---
-----------------------------------------------------------------------

--Window--
local Win = ZWindowAPI;

--- Create a new Window
---@param posX number Window X position (horizontal)
---@param posY number Window Y position (vertical)
---@param sizeX number Window width
---@param sizeY number Window height
---@param parent table Parent frame
---@param windowPoint string Pivot point of the current window
---@param parentPoint string Pivot point of the parent
---@param title string Title text
---@return table windowFrame Wow Frame that contains all of the window elements
function Win.CreatePopupWindow(posX, posY, sizeX, sizeY, parent, windowPoint, parentPoint, title)
	local win = Win.CreateWindow(posX, posY, sizeX, sizeY, parent, windowPoint, parentPoint, title);
	win:SetFrameStrata("HIGH");
	win.TitleBar.text:SetText(title);
	return win;
end