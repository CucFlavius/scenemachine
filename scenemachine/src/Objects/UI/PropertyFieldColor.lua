local UI = SceneMachine.UI;
local ColorPicker = SceneMachine.Editor.ColorPicker;
UI.PropertyFieldColor = {};
local PropertyFieldColor = UI.PropertyFieldColor;
PropertyFieldColor.__index = PropertyFieldColor;
setmetatable(PropertyFieldColor, UI.PropertyField)

function PropertyFieldColor:New(y, h, parent, title, R, G, B, A, onSetColor, onStartAction, onFinishAction)
	local v = 
    {
        y = y or 0,
        h = h or 20,
        parent = parent or nil,
        title = title or nil,
        R = R or 0,
        G = G or 0,
        B = B or 0,
        A = A or 1,
        onSetColor = onSetColor or nil,
        onStartAction = onStartAction or nil,
        onFinishAction = onFinishAction or nil,
        visible = true,
    };

	setmetatable(v, PropertyFieldColor);
    v:BuildBase();
    v:Build();
	return v;
end

function PropertyFieldColor:Build()
    self.colorField = CreateFrame("Button", "self.colorField", self.parent);
	self.colorField:SetPoint("TOPRIGHT", self.parent, "TOPRIGHT", -20, self.y);
    self.colorField:SetWidth(80);
    self.colorField:SetHeight(self.h);
    self.colorField.ntex = self.colorField:CreateTexture();
    self.colorField.ntex:SetColorTexture(1,1,1,1);
    self.colorField.ntex:SetAllPoints();
    self.colorField:SetNormalTexture(self.colorField.ntex);
    self.colorField.ntex:SetVertexColor(self.R, self.G, self.B, self.A);

    self.colorField:SetScript("OnClick", function(_, button, up)
        ColorPicker.Open(self.R, self.G, self.B, self.A, function(r, g, b, a)
            self:Set(r, g, b, a);
            self.onSetColor(self.R, self.G, self.B, self.A);
        end, self.onStartAction, self.onFinishAction);
    end);
end

function PropertyFieldColor:Set(r, g, b, a)
    self.R = r;
    self.G = g;
    self.B = b;
    self.A = a;
    self.colorField.ntex:SetVertexColor(self.R, self.G, self.B, self.A);
end

function PropertyFieldColor:SetEnabled(enabled)
    --[[
    local c = 0.5;
    if (enabled) then
        c = 1;
    end

    self.xField:SetEnabled(enabled);
    self.xField:SetTextColor(1, 1, 1, c);
    self.yField:SetEnabled(enabled);
    self.yField:SetTextColor(1, 1, 1, c);
    self.zField:SetEnabled(enabled);
    self.zField:SetTextColor(1, 1, 1, c);
    --]]
end