local UI = SceneMachine.UI;
UI.Dropdown = {};
local Dropdown = UI.Dropdown;
local Resources = SceneMachine.Resources;
Dropdown.__index = Dropdown;
setmetatable(Dropdown, UI.Element)

function Dropdown:New(x, y, w, h, parent, point, parentPoint, optionNames, onSelect, window)
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
    };

	setmetatable(v, Dropdown);
    v:Build();
	return v;
end

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
	    self.window:PopupWindowMenu(rx, ry, self.options);
	end);
end

function Dropdown:SetOptions(newOptions)
    for o = 1, #newOptions, 1 do
        self.options[o] = { ["Name"] = newOptions[o], ["Action"] = function() self.button:SetText("  " .. self.optionNames[o]); self.onSelect(o); end };
    end
end

function Dropdown:ShowSelectedName(name)
    self.button:SetText("  " .. name);
end

Dropdown.__tostring = function(self)
	return string.format("Dropdown( %.3f, %.3f, %.3f, %.3f )", self.x, self.y, self.w, self.h);
end