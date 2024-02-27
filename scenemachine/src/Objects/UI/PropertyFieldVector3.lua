local UI = SceneMachine.UI;
local L = SceneMachine.Editor.localization;
UI.PropertyFieldVector3 = {};
local PropertyFieldVector3 = UI.PropertyFieldVector3;
local Resources = SceneMachine.Resources;
PropertyFieldVector3.__index = PropertyFieldVector3;
setmetatable(PropertyFieldVector3, UI.PropertyField)

function PropertyFieldVector3:New(y, h, parent, title, default, onSetValueX, onSetValueY, onSetValueZ)
	local v = 
    {
        y = y or 0,
        h = h or 20,
        parent = parent or nil,
        title = title or nil,
        default = default or { 0, 0, 0 },
        onSetValueX = onSetValueX or nil,
        onSetValueY = onSetValueY or nil,
        onSetValueZ = onSetValueZ or nil,
        visible = true,
    };

	setmetatable(v, PropertyFieldVector3);
    v:BuildBase();
    v:Build();
	return v;
end

function PropertyFieldVector3:Build()
    local fieldPad = 2;

    self.xField = self:BuildFloatField(self.onSetValueX, self.default[1]);
    self.xField.tooltip = L["OP_TT_X_FIELD"];
    self.yField = self:BuildFloatField(self.onSetValueY, self.default[2]);
    self.yField.tooltip = L["OP_TT_Y_FIELD"];
    self.zField = self:BuildFloatField(self.onSetValueZ, self.default[3]);
    self.zField.tooltip = L["OP_TT_Z_FIELD"];

    self.fieldGroup:SetScript("OnSizeChanged", function(_, width, height)
        local sizeW = ((width - 20) - (fieldPad * 3)) / 3;
        self.xField:SetPoint("TOPLEFT", self.fieldGroup, "TOPLEFT", 0, 0);
        self.xField:SetWidth(sizeW);
        self.yField:SetPoint("TOPLEFT", self.fieldGroup, "TOPLEFT", sizeW + fieldPad, 0);
        self.yField:SetWidth(sizeW);
        self.zField:SetPoint("TOPLEFT", self.fieldGroup, "TOPLEFT", (sizeW + fieldPad) * 2, 0);
        self.zField:SetWidth(sizeW);
    end);

    local resetButton = UI.Button:New(0, 0, 20, 20, self.fieldGroup, "TOPRIGHT", "TOPRIGHT", nil,  Resources.textures["ResetIcon"]);
    resetButton:SetScript("OnClick", function(_)
        self.xField:SetText(tostring(self.default[1]));
        self.yField:SetText(tostring(self.default[2]));
        self.zField:SetText(tostring(self.default[3]));
        self.onSetValueX(self.default[1]);
        self.onSetValueY(self.default[2]);
        self.onSetValueZ(self.default[3]);
    end);
    resetButton.tooltip = L["OP_TT_RESET_VALUE"];
end

function PropertyFieldVector3:Set(x, y, z)
    self.xField:SetText(tostring(x));
    self.yField:SetText(tostring(y));
    self.zField:SetText(tostring(z));
end

function PropertyFieldVector3:SetEnabled(enabled)
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
end