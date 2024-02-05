local Editor = SceneMachine.Editor;
local UI = SceneMachine.UI;
UI.Button = {};
local Button = UI.Button;
Button.__index = Button;
setmetatable(Button, UI.Element)

UI.Button.State = {
    Normal = 0,
    Highlight = 1,
    Pressed = 2
}

function Button:New(x, y, w, h, parent, point, parentPoint, text, iconTexture, texcoords)
	local v = 
    {
        x = x or 0,
        y = y or 0,
        w = w or 20,
        h = h or 20,
        parent = parent or nil,
        point = point or "TOPLEFT",
        parentPoint = parentPoint or "TOPLEFT",
        text = text or nil,
        iconTexture = iconTexture or nil,
        texcoords = texcoords or {0, 1, 0, 1},
        visible = true,
    };

	setmetatable(v, Button);
    v:Build();
	return v;
end

function Button:Build()
    -- main button frame
	self.frame = CreateFrame("Button", "SceneMachine.UI.Button.frame", self.parent);
	self.frame:SetPoint(self.point, self.parent, self.parentPoint, self.x, self.y);
	self.frame:SetSize(self.w, self.h);

    -- normal texture
    self.ntex = self.frame:CreateTexture();
    self.ntex:SetColorTexture(0.1757, 0.1757, 0.1875 ,1);
	self.ntex:SetAllPoints();
	self.frame:SetNormalTexture(self.ntex);
    
    -- highlight texture
    self.htex = self.frame:CreateTexture();
    self.htex:SetColorTexture(0.242, 0.242, 0.25,1);
    self.htex:SetAllPoints();
    self.frame:SetHighlightTexture(self.htex);

    -- pressed texture
    self.ptex = self.frame:CreateTexture();
    self.ptex:SetColorTexture(0, 0.4765, 0.7968,1);
    self.ptex:SetAllPoints();
	self.frame:SetPushedTexture(self.ptex);

	-- icon --
	if (self.iconTexture) then
		local iconSize = self.w - 4;    -- icon paddin 4
		self.icon = UI.ImageBox:New(0, 0, iconSize, iconSize, self.frame, "CENTER", "CENTER", self.iconTexture, self.texcoords);
	end

	-- text --
	if (self.text) then
		self.textField = self.frame:CreateFontString("Zee.WindowAPI.Button.textField");
		self.textField:SetFont(Editor.ui.defaultFont, 9, "NORMAL");
		self.textField:SetAllPoints(self.frame);
		self.textField:SetText(self.text);
	end
end

function Button:SetText(text)
    self.text = text;

    if (not self.textField) then
		self.textField = self.frame:CreateFontString("Zee.WindowAPI.Button.textField");
		self.textField:SetFont(Editor.ui.defaultFont, 9, "NORMAL");
		self.textField:SetAllPoints(self.frame);
    end
    
    self.textField:SetText(text);
end

function Button:SetColor(state, R, G, B, A)
    if (state == UI.Button.State.Normal) then
        self.ntex:SetColorTexture(R, G, B, A);
    elseif (state == UI.Button.State.Highlight) then
        self.htex:SetColorTexture(R, G, B, A);
    elseif (state == UI.Button.State.Pressed) then
        self.ptex:SetColorTexture(R, G, B, A);
    end
end

function Button:SetTexCoords(left, right, top, bottom)
    self.texcoords = { left, right, top, bottom };
    self.icon:SetTexCoords(self.texcoords[1], self.texcoords[2], self.texcoords[3], self.texcoords[4]);
end

function Button:GetText()
    return self.text;
end

function Button:SetScript(handler, func)
    self.frame:SetScript(handler, func);
end

function Button:HookScript(handler, func)
    self.frame:HookScript(handler, func);
end

function Button:SetJustifyH(justifyH)
    self.textField:SetJustifyH(justifyH);
end

function Button:EnableMouse(on)
    self.frame:EnableMouse(on);
end

Button.__tostring = function(self)
	return string.format("Button( %.3f, %.3f, %.3f, %.3f, %s )", self.x, self.y, self.w, self.h, self.parent);
end