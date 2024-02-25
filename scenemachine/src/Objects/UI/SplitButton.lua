local Resources = SceneMachine.Resources;
local UI = SceneMachine.UI;
UI.SplitButton = {};
local SplitButton = UI.SplitButton;
SplitButton.__index = SplitButton;
setmetatable(SplitButton, UI.Element)

UI.SplitButton.State = {
    Normal = 0,
    Highlight = 1,
    Pressed = 2
}

function SplitButton:New(x, y, w, h, parent, point, parentPoint, text, iconTexture, texcoords)
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

	setmetatable(v, SplitButton);
    v:Build();
	return v;
end

function SplitButton:Build()
    -- main SplitButton frame
	self.frame = CreateFrame("SplitButton", "SceneMachine.UI.SplitButton.frame", self.parent);
	self.frame:SetPoint(self.point, self.parent, self.parentPoint, self.x, self.y);
	self.frame:SetSize(self.w, self.h);

    -- normal texture
    self.ntex = self.frame:CreateTexture();
    self.ntex:SetColorTexture(0.1757, 0.1757, 0.1875, 1);
	self.ntex:SetAllPoints();
	self.frame:SetNormalTexture(self.ntex);
    
    -- highlight texture
    self.htex = self.frame:CreateTexture();
    self.htex:SetColorTexture(0.242, 0.242, 0.25, 1);
    self.htex:SetAllPoints();
    self.frame:SetHighlightTexture(self.htex);

    -- pressed texture
    self.ptex = self.frame:CreateTexture();
    self.ptex:SetColorTexture(0, 0.4765, 0.7968, 1);
    self.ptex:SetAllPoints();
	self.frame:SetPushedTexture(self.ptex);

	-- icon --
	if (self.iconTexture) then
		local iconSize = self.w - 4;    -- icon paddin 4
		self.icon = UI.ImageBox:New(0, 0, iconSize, iconSize, self.frame, "CENTER", "CENTER", self.iconTexture, self.texcoords);
	end

	-- text --
	if (self.text) then
		self.textField = self.frame:CreateFontString("Zee.WindowAPI.SplitButton.textField");
		self.textField:SetFont(Resources.defaultFont, 9, "NORMAL");
		self.textField:SetAllPoints(self.frame);
		self.textField:SetText(self.text);
	end
end

function SplitButton:SetText(text)
    self.text = text;

    if (not self.textField) then
		self.textField = self.frame:CreateFontString("Zee.WindowAPI.SplitButton.textField");
		self.textField:SetFont(Resources.defaultFont, 9, "NORMAL");
		self.textField:SetAllPoints(self.frame);
    end
    
    self.textField:SetText(text);
end

function SplitButton:SetColor(state, R, G, B, A)
    if (state == UI.SplitButton.State.Normal) then
        self.ntex:SetColorTexture(R, G, B, A);
    elseif (state == UI.SplitButton.State.Highlight) then
        self.htex:SetColorTexture(R, G, B, A);
    elseif (state == UI.SplitButton.State.Pressed) then
        self.ptex:SetColorTexture(R, G, B, A);
    end
end

function SplitButton:SetTexCoords(texcoords)
    self.texcoords = texcoords;
    self.icon:SetTexCoords(self.texcoords);
end

function SplitButton:GetText()
    return self.text;
end

function SplitButton:SetScript(handler, func)
    self.frame:SetScript(handler, func);
end

function SplitButton:HookScript(handler, func)
    self.frame:HookScript(handler, func);
end

function SplitButton:SetJustifyH(justifyH)
    self.textField:SetJustifyH(justifyH);
end

function SplitButton:EnableMouse(on)
    self.frame:EnableMouse(on);
end

SplitButton.__tostring = function(self)
	return string.format("SplitButton( %.3f, %.3f, %.3f, %.3f )", self.x, self.y, self.w, self.h);
end