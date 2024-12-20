local UI = SceneMachine.UI;
local Editor = SceneMachine.Editor;
UI.Dropdown = {};

--- @class Dropdown : Element
local Dropdown = UI.Dropdown;
local Resources = SceneMachine.Resources;
Dropdown.__index = Dropdown;
setmetatable(Dropdown, UI.Element)

--- Creates a new Dropdown object.
--- @param x number? The x-coordinate of the dropdown's position.
--- @param y number? The y-coordinate of the dropdown's position.
--- @param w number? The width of the dropdown.
--- @param h number? The height of the dropdown.
--- @param parent table? The parent element of the dropdown.
--- @param point string? The anchor point of the dropdown relative to its parent.
--- @param parentPoint string? The anchor point of the parent element.
--- @param optionNames table? The names of the dropdown options.
--- @param onSelect function? The function to be called when an option is selected.
--- @param window table? The window object associated with the dropdown.
--- @return Dropdown: The newly created Dropdown object.
function Dropdown:New(x, y, w, h, parent, point, parentPoint, optionNames, onSelect, window)
	--- @class Dropdown : Element
	local v = 
	{
		x = x or 0,
		y = y or 0,
		w = w or 20,
		h = h or 20,
		parent = parent or nil,
		point = point or "TOPLEFT",
		parentPoint = parentPoint or "TOPLEFT",
		optionNames = optionNames or nil,
		onSelect = onSelect or nil,
		window = window or nil,
		visible = true,
		tooltip = nil,
		tooltipDetailed = nil,
	};

	setmetatable(v, Dropdown);
	v:Build();
	return v;
end

--- Builds the dropdown UI element.
function Dropdown:Build()
	self.frame = UI.Rectangle:New(self.x, self.y, self.w, self.h, self.parent, self.point, self.parentPoint, 0, 0, 0, 0);
	self.button = UI.Button:New(0, 0, self.w, self.h, self.frame:GetFrame(), "TOPLEFT", "TOPLEFT", "");
	self.button:SetJustifyH("LEFT");
	self.button:SetColor(UI.Button.State.Normal, 0.242, 0.242, 0.25, 1);

	local arrowSize = 8;
	local arrow = UI.ImageBox:New(-arrowSize / 2, 0, arrowSize, arrowSize, self.button:GetFrame(), "RIGHT", "RIGHT", Resources.textures["ArrowDown"]);
	arrow:SetFrameLevel(self.button:GetFrameLevel() + 2);

	self.options = {};

	for o = 1, #self.optionNames, 1 do
		self.options[o] = { ["Name"] = self.optionNames[o], ["Action"] = function() self.button:SetText("  " .. self.optionNames[o]); self.onSelect(o); end };
	end

	if (#self.optionNames > 0) then
		self.button:SetText("  " .. self.optionNames[1]);
	end

	self.button:SetScript("OnClick", function ()
		local rx = self.x + (self.parent:GetLeft() - SceneMachine.mainWindow:GetLeft());
		local ry = self.y + (self.parent:GetBottom() - SceneMachine.mainWindow:GetTop());
		local scale = SceneMachine.mainWindow:GetEffectiveScale();
		self.window:PopupWindowMenu(rx * scale, ry * scale, self.options);
	end);
	self.button:SetScript("OnEnter", function ()
		if (self.tooltip) then
			self.holdTimer = C_Timer.NewTimer(Editor.ui.tooltipDelay, function()
				Editor.ui:ShowTooltip(self.w / 2, 0, self.frame:GetFrame(), self.tooltip, self.tooltipDetailed);
			end);
		end
	end);
	self.button:SetScript("OnLeave", function ()
		if (self.holdTimer) then
			self.holdTimer:Cancel();
			Editor.ui:HideTooltip();
		end
	end);
end

--- Sets the options for the dropdown.
--- @param newOptions table The new options to set.
function Dropdown:SetOptions(newOptions)
	for o = 1, #newOptions, 1 do
		self.options[o] = {
			["Name"] = newOptions[o],
			["Action"] = function()
				self.button:SetText("  " .. newOptions[o])
				self.onSelect(o)
			end
		}
	end

	for o = #newOptions + 1, #self.options, 1 do
		self.options[o] = nil
	end
end

--- Sets the text of the dropdown button to the specified name.
--- @param name string The name to be displayed in the dropdown button.
function Dropdown:ShowSelectedName(name)
	self.button:SetText("  " .. name);
end

Dropdown.__tostring = function(self)
	return string.format("Dropdown( %.3f, %.3f, %.3f, %.3f )", self.x, self.y, self.w, self.h);
end