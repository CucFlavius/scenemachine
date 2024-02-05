local UI = SceneMachine.UI;
UI.Dropdown = {};
local Dropdown = UI.Dropdown;
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
	local pad = 5;
	local height = self.h - (pad * 2);

	self.frame = UI.Rectangle:New(self.x, self.y, self.w, self.h, self.parent, self.point, self.parentPoint, 0, 0, 0, 0);
	self.button = UI.Button:New(pad, -pad, self.w - pad, height, self.frame:GetFrame(), "TOPLEFT", "TOPLEFT", "");
	self.button:SetJustifyH("LEFT");
	self.button:SetColor(UI.Button.State.Normal, 0.242, 0.242, 0.25, 1);

	local arrowSize = 4.0;
	local arrow = UI.Rectangle:New(-8, -8, arrowSize, arrowSize, self.button:GetFrame(), "TOPRIGHT", "TOPRIGHT", 0.9, 0.9, 0.9, 1);
	arrow:SetVertexOffset(LOWER_LEFT_VERTEX, arrowSize / 2, 0);
	arrow:SetVertexOffset(UPPER_LEFT_VERTEX, -arrowSize / 8, 0);
	arrow:SetVertexOffset(LOWER_RIGHT_VERTEX, -arrowSize / 2, 0);
	arrow:SetVertexOffset(UPPER_RIGHT_VERTEX, arrowSize / 8, 0);

	self.options = {};

	for o = 1, #self.optionNames, 1 do
		self.options[o] = { ["Name"] = self.optionNames[o], ["Action"] = function() onSelect(o); end };
	end

    local dropdown = self;
    self.button:SetScript("OnClick", function ()
	    self.window:PopupWindowMenu(dropdown.x, dropdown.y - dropdown.h, dropdown.options);
	end);
end

function Dropdown:SetOptions(newOptions)
    for o = 1, #newOptions, 1 do
        self.options[o] = { ["Name"] = newOptions[o], ["Action"] = function() self.onSelect(o); end };
    end
end

function Dropdown:ShowSelectedName(name)
    self.button:SetText("  " .. name);
end

Dropdown.__tostring = function(self)
	return string.format("Dropdown( %.3f, %.3f, %.3f, %.3f, %s )", self.x, self.y, self.w, self.h, self.parent);
end