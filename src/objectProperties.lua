local Win = ZWindowAPI;
local Editor = SceneMachine.Editor;
local PM = Editor.ProjectManager;
local SM = Editor.SceneManager;
local SH = Editor.SceneHierarchy;
local Gizmos = SceneMachine.Gizmos;
local OP = Editor.ObjectProperties;

function OP.CreatePanel(x, y, w, h, c1, c2, c3, c4)
    local leftPanel = Win.CreateRectangle(x, y, w, h, SceneMachine.mainWindow, "TOPLEFT", "TOPLEFT", c4[1], c4[2], c4[3], 1);
    local group = Editor.CreateGroup("Properties", h, leftPanel);

    local collapseList = Win.CreateCollapsableList(0, -1, w - 2, { 60, 80, 100 }, group, "TOP", "TOP", { "Transform", "Test Property A", "Test Property B" }, c1[1], c1[2], c1[3], 1);

    OP.CreateTransformProperties(0, 0, w - 2, 60, collapseList[1].panel);

    OP.Refresh();
end

function OP.CreateTransformProperties(x, y, w, h, parent)
    OP.Transform = {};
    local editBoxTitleW = 85;
    local h = 16;
    local hPad = h + 2;
    local y = -5;
    Win.CreateTextBoxSimple(10, y, editBoxTitleW, h, parent, "TOPLEFT", "TOPLEFT", "Position", 9);
    OP.Transform.posX = OP.CreateTransformField(editBoxTitleW + 10, y, 45, h, parent, "x", OP.SetPosX, 0);
    OP.Transform.posY = OP.CreateTransformField(editBoxTitleW + 10 + 55 + 2, y, 45, h,parent, "y", OP.SetPosY, 0);
    OP.Transform.posZ = OP.CreateTransformField(editBoxTitleW + 10 + (55 * 2) + (2 * 2), y, 45, h,parent, "z", OP.SetPosZ, 0);
    local resetPosButton = Win.CreateButton(editBoxTitleW + 10 + (55 * 3) + (2 * 2), y, h, h, parent, "TOPLEFT", "TOPLEFT", "R", nil, "BUTTON_VS");
    resetPosButton:SetScript("OnClick", function(self)
        if (SM.selectedObject ~= nil) then
            SM.selectedObject:SetPosition(0, 0, 0);
            OP.Refresh();
        end
    end);

    y = y - hPad;
    Win.CreateTextBoxSimple(10, y, editBoxTitleW, h, parent, "TOPLEFT", "TOPLEFT", "Rotation", 9);
    OP.Transform.rotX = OP.CreateTransformField(editBoxTitleW + 10, y, 45, h,parent, "x", OP.SetRotX, 0);
    OP.Transform.rotY = OP.CreateTransformField(editBoxTitleW + 10 + 55 + 2, y, 45, h,parent, "y", OP.SetRotY, 0);
    OP.Transform.rotZ = OP.CreateTransformField(editBoxTitleW + 10 + (55 * 2) + (2 * 2), y, 45, h,parent, "z", OP.SetRotZ, 0);
    local resetRotButton = Win.CreateButton(editBoxTitleW + 10 + (55 * 3) + (2 * 2), y, h, h, parent, "TOPLEFT", "TOPLEFT", "R", nil, "BUTTON_VS");
    resetRotButton:SetScript("OnClick", function(self)
        if (SM.selectedObject ~= nil) then
            SM.selectedObject:SetRotation(0, 0, 0);
            OP.Refresh();
        end
    end);

    y = y - hPad;
    Win.CreateTextBoxSimple(10, y, editBoxTitleW, h, parent, "TOPLEFT", "TOPLEFT", "Scale", 9);
    OP.Transform.scale = Win.CreateEditBox(editBoxTitleW + 10 + 8, y, 159, h, parent, "TOPLEFT", "TOPLEFT", "0");
    OP.Transform.scale:SetScript('OnEscapePressed', function(self1) 
        -- restore value
        self1:SetText(tostring(self1.value));
        self1:ClearFocus();
        Win.focused = false;
    end);
    OP.Transform.scale:SetScript('OnEnterPressed', function(self1)
        -- set value
        local valText = self1:GetText();
        if (valText == nil or valText == "") then
            valText = "1";
        end
        local val = tonumber(valText);
        if (val ~= nil) then
            self1.value = val;
        end
        OP.SetScale(self1);
        self1:ClearFocus();
        Win.focused = false;
    end);
    OP.Transform.scale:SetScript('OnEditFocusLost', function(self1) 
        -- set value
        local valText = self1:GetText();
        if (valText == nil or valText == "") then
            valText = "1";
        end
        local val = tonumber(valText);
        if (val ~= nil) then
            self1.value = val;
        end
        OP.SetScale(self1);
        Win.focused = false;
    end);
    local resetScaleButton = Win.CreateButton(editBoxTitleW + 10 + (55 * 3) + (2 * 2), y, h, h, parent, "TOPLEFT", "TOPLEFT", "R", nil, "BUTTON_VS");
    resetScaleButton:SetScript("OnClick", function(self)
        if (SM.selectedObject ~= nil) then
            SM.selectedObject:SetScale(1);
            OP.Refresh();
        end
    end);
end

function OP.CreateTransformField(x, y, w, h, parent, axisName, setValue, defaultValue)
    Win.CreateTextBoxSimple(x, y, 10, h, parent, "TOPLEFT", "TOPLEFT", axisName, 9);
    local transform = Win.CreateEditBox(x + 8, y, w, h, parent, "TOPLEFT", "TOPLEFT", "0");
    transform:SetScript('OnEscapePressed', function(self1) 
        -- restore value
        self1:SetText(tostring(self1.value));
        self1:ClearFocus();
        Win.focused = false;
    end);
    transform:SetScript('OnEnterPressed', function(self1)
        -- set value
        local valText = self1:GetText();
        if (valText == nil or valText == "") then
            valText = tostring(defaultValue);
        end
        local val = tonumber(valText);
        if (val ~= nil) then
            self1.value = val;
        end
        setValue(self1);
        self1:ClearFocus();
        Win.focused = false;
    end);
    transform:SetScript('OnEditFocusLost', function(self1) 
        -- set value
        local valText = self1:GetText();
        if (valText == nil or valText == "") then
            valText = tostring(defaultValue);
        end
        local val = tonumber(valText);
        if (val ~= nil) then
            self1.value = val;
        end
        setValue(self1);
        Win.focused = false;
    end);

    return transform;
end

function OP.Refresh()
    local pos, rot, scale;

    if (SM.selectedObject == nil) then
        pos = { x=0, y=0, z=0 };
        rot = { x=0, y=0, z=0 };
        scale = 1;
        OP.ToggleTransformFields(false);
    else
        OP.ToggleTransformFields(true);
        pos = SM.selectedObject:GetPosition();
        rot = SM.selectedObject:GetRotation();
        scale = SM.selectedObject:GetScale();
    end

    OP.Transform.posX:SetText(tostring(OP.Truncate(pos.x, 3)));
    OP.Transform.posY:SetText(tostring(OP.Truncate(pos.y, 3)));
    OP.Transform.posZ:SetText(tostring(OP.Truncate(pos.z, 3)));

    OP.Transform.rotX:SetText(tostring(OP.Truncate(deg(rot.x), 3)));
    OP.Transform.rotY:SetText(tostring(OP.Truncate(deg(rot.y), 3)));
    OP.Transform.rotZ:SetText(tostring(OP.Truncate(deg(rot.z), 3)));

    OP.Transform.scale:SetText(tostring(OP.Truncate(scale, 3)));
end

function OP.ToggleTransformFields(on)
    local c = 0.5;
    if (on) then
        c = 1;
    end

    OP.Transform.posX:SetEnabled(on);
    OP.Transform.posX:SetTextColor(1, 1, 1, c);
    OP.Transform.posY:SetEnabled(on);
    OP.Transform.posY:SetTextColor(1, 1, 1, c);
    OP.Transform.posZ:SetEnabled(on);
    OP.Transform.posZ:SetTextColor(1, 1, 1, c);

    OP.Transform.rotX:SetEnabled(on);
    OP.Transform.rotX:SetTextColor(1, 1, 1, c);
    OP.Transform.rotY:SetEnabled(on);
    OP.Transform.rotY:SetTextColor(1, 1, 1, c);
    OP.Transform.rotZ:SetEnabled(on);
    OP.Transform.rotZ:SetTextColor(1, 1, 1, c);

    OP.Transform.scale:SetEnabled(on);
    OP.Transform.scale:SetTextColor(1, 1, 1, c);
end

function OP.SetPosX(self)
    if (SM.selectedObject == nil) then
        return;
    end
    local pos = SM.selectedObject:GetPosition();
    SM.selectedObject:SetPosition(self.value, pos.y, pos.z);
end

function OP.SetPosY(self)
    if (SM.selectedObject == nil) then
        return;
    end
    local pos = SM.selectedObject:GetPosition();
    SM.selectedObject:SetPosition(pos.x, self.value, pos.z);
end

function OP.SetPosZ(self)
    if (SM.selectedObject == nil) then
        return;
    end
    local pos = SM.selectedObject:GetPosition();
    SM.selectedObject:SetPosition(pos.x, pos.y, self.value);
end

function OP.SetRotX(self)
    if (SM.selectedObject == nil) then
        return;
    end
    local rot = SM.selectedObject:GetRotation();
    SM.selectedObject:SetRotation(rad(self.value), rot.y, rot.z);
end

function OP.SetRotY(self)
    if (SM.selectedObject == nil) then
        return;
    end
    local rot = SM.selectedObject:GetRotation();
    SM.selectedObject:SetRotation(rot.x, rad(self.value), rot.z);
end

function OP.SetRotZ(self)
    if (SM.selectedObject == nil) then
        return;
    end
    local rot = SM.selectedObject:GetRotation();
    SM.selectedObject:SetRotation(rot.x, rot.y, rad(self.value));
end

function OP.SetScale(self)
    if (SM.selectedObject == nil) then
        return;
    end
    SM.selectedObject:SetScale(self.value);
end

function OP.Truncate(num, digits)
    local mult = 10^(digits)
    return math.modf(num*mult)/mult
  end