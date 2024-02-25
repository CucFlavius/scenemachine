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

function SplitButton:New(x, y, w, h, parent, point, parentPoint, iconTextures, texcoords, splitaction, action)
	local v = 
    {
        x = x or 0,
        y = y or 0,
        w = w or 20,
        h = h or 20,
        parent = parent or nil,
        point = point or "TOPLEFT",
        parentPoint = parentPoint or "TOPLEFT",
        iconTextures = iconTextures or {},
        texcoords = texcoords or {},
        visible = true,
        splitaction = splitaction,
        action = action,
        currentOption = 1,
    };

	setmetatable(v, SplitButton);
    v:Build();
	return v;
end

function SplitButton:Build()
    -- main SplitButton frame

    self.splitButton = UI.Button:New(self.x, self.y, self.w, self.h, self.parent, self.point, self.parentPoint, nil, self.iconTextures[1], self.texcoords[1]);
    self.frame = self.splitButton:GetFrame();

    local corner = UI.Rectangle:New(-2, 2, 5, 5, self.frame, "BOTTOMRIGHT", "BOTTOMRIGHT", 1, 1, 1, 1);
    corner:SetFrameLevel(self.frame:GetFrameLevel() + 2);
    corner:SetVertexOffset(1, 5, 0);

    self.popup = UI.Rectangle:New(self.x, 0, self.w, self.h * #self.iconTextures, self.parent:GetParent(), "TOPLEFT", "BOTTOMLEFT", 0, 0, 0, 1);
    self.popup:SetFrameLevel(self.frame:GetFrameLevel() + 100);
    self.popup:Hide();

    self.options = {};
    for b = 1, #self.iconTextures, 1 do
        self.options[b] = UI.Button:New(0, -(b - 1) * self.h, self.w, self.h, self.popup:GetFrame(), "TOPLEFT", "TOPLEFT", nil, self.iconTextures[b], self.texcoords[b]);
    end

    self.splitButton:SetScript("OnMouseDown", function()
        self.holdTimer = C_Timer.NewTimer(0.5, function()
            self.popup:ClearAllPoints();
            self.popup:SetPoint("TOPLEFT", self.parent:GetParent(), "BOTTOMLEFT", self.x, 0);
            self.popup:Show();
        end);
    end);

    self.splitButton:SetScript("OnMouseUp", function()
        if (self.holdTimer) then
            self.holdTimer:Cancel();
            for b = 1, #self.iconTextures, 1 do
                if (MouseIsOver(self.options[b]:GetFrame())) then
                    self.splitButton.icon:SetTexCoords(self.texcoords[b]);
                    self.currentOption = b;
                    self.popup:Hide();
                    self.splitaction(self.currentOption);
                    return;
                end
            end
        end
        
        self.popup:Hide();
        self.action(self.currentOption);
    end);
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