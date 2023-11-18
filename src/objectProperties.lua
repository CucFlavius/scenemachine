local Win = ZWindowAPI;
local Editor = SceneMachine.Editor;
local PM = Editor.ProjectManager;
local SM = Editor.SceneManager;
local SH = Editor.SceneHierarchy;
local Gizmos = SceneMachine.Gizmos;
local OP = Editor.ObjectProperties;

function OP.CreatePanel(x, y, w, h, c4)
    local leftPanel = Win.CreateRectangle(x, y, w, h, SceneMachine.mainWindow, "TOPLEFT", "TOPLEFT", c4[1], c4[2], c4[3], 1);
    local group = Editor.CreateGroup("Properties", h, leftPanel);

    OP.CreateTransformProperties(1, -1, w - 2, 100, group);
end

function OP.CreateTransformProperties(x, y, w, h, parent)
    OP.Transform = {};
    local transformRect = Win.CreateRectangle(x, y, w, h, parent, "TOPLEFT", "TOPLEFT", 0, 0, 0, 0);

    local editBoxTitleW = 100;
    Win.CreateTextBoxSimple(10, 0, editBoxTitleW, 20, transformRect, "TOPLEFT", "TOPLEFT", "Position", 9);
    OP.Transform.posX = OP.CreateTransformField(110, 0, transformRect, "x", OP.SetPosX, 0);
    OP.Transform.posY = OP.CreateTransformField(110 + 55 + 2, 0, transformRect, "y", OP.SetPosY, 0);
    OP.Transform.posZ = OP.CreateTransformField(110 + (55 * 2) + (2 * 2), 0, transformRect, "z", OP.SetPosZ, 0);

    Win.CreateTextBoxSimple(10, -22, editBoxTitleW, 20, transformRect, "TOPLEFT", "TOPLEFT", "Rotation", 9);
    OP.Transform.rotX = OP.CreateTransformField(110, -22, transformRect, "x", OP.SetRotX, 0);
    OP.Transform.rotY = OP.CreateTransformField(110 + 55 + 2, -22, transformRect, "y", OP.SetRotY, 0);
    OP.Transform.rotZ = OP.CreateTransformField(110 + (55 * 2) + (2 * 2), -22, transformRect, "z", OP.SetRotZ, 0);

    Win.CreateTextBoxSimple(10, -44, editBoxTitleW, 20, transformRect, "TOPLEFT", "TOPLEFT", "Scale", 9);
    OP.Transform.scale = Win.CreateEditBox(110 + 8, -44, 160, 20, transformRect, "TOPLEFT", "TOPLEFT", "0");
    OP.Transform.scale:SetScript('OnEscapePressed', function(self1) 
        -- restore value
        self1:SetText(tostring(self1.value));
        self1:ClearFocus();
    end);
    OP.Transform.scale:SetScript('OnEnterPressed', function(self1)
        -- set value
        local valText = self1:GetText();
        if (valText == nil or valText == "") then
            valText = "1";
        end
        self1.value = tonumber(valText);
        OP.SetScale(self1);
    end);
    OP.Transform.scale:SetScript('OnEditFocusLost', function(self1) 
        -- set value
        local valText = self1:GetText();
        if (valText == nil or valText == "") then
            valText = "1";
        end
        self1.value = tonumber(valText);
        OP.SetScale(self1);
    end);
end

function OP.CreateTransformField(x, y, parent, axisName, setValue, defaultValue)
    local editBoxW = 45;
    local editBoxH = 20;
    Win.CreateTextBoxSimple(x, y, 10, 20, parent, "TOPLEFT", "TOPLEFT", axisName, 9);
    local transform = Win.CreateEditBox(x + 8, y, editBoxW, editBoxH, parent, "TOPLEFT", "TOPLEFT", "0");
    transform:SetScript('OnEscapePressed', function(self1) 
        -- restore value
        self1:SetText(tostring(self1.value));
        self1:ClearFocus();
    end);
    transform:SetScript('OnEnterPressed', function(self1)
        -- set value
        local valText = self1:GetText();
        if (valText == nil or valText == "") then
            valText = tostring(defaultValue);
        end
        self1.value = tonumber(valText);
        setValue(self1);
    end);
    transform:SetScript('OnEditFocusLost', function(self1) 
        -- set value
        local valText = self1:GetText();
        if (valText == nil or valText == "") then
            valText = tostring(defaultValue);
        end
        self1.value = tonumber(valText);
        setValue(self1);
    end);

    return transform;
end

function OP.Refresh()
    local pos, rot, scale;

    if (SM.selectedObject == nil) then
        pos = { x=0, y=0, z=0 };
        rot = { x=0, y=0, z=0 };
        scale = 1;
        return;
    else
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

function OP.SetPosX(self)
    if (SM.selectedObject == nil) then
        return;
    end
    local pos = SM.selectedObject:GetPosition();
    SM.selectedObject:SetPosition(self.value, pos.y, pos.z);
    Gizmos.refresh = true;
end

function OP.SetPosY(self)
    if (SM.selectedObject == nil) then
        return;
    end
    local pos = SM.selectedObject:GetPosition();
    SM.selectedObject:SetPosition(pos.x, self.value, pos.z);
    Gizmos.refresh = true;
end

function OP.SetPosZ(self)
    if (SM.selectedObject == nil) then
        return;
    end
    local pos = SM.selectedObject:GetPosition();
    SM.selectedObject:SetPosition(pos.x, pos.y, self.value);
    Gizmos.refresh = true;
end

function OP.SetRotX(self)
    if (SM.selectedObject == nil) then
        return;
    end
    local rot = SM.selectedObject:GetRotation();
    SM.selectedObject:SetRotation(rad(self.value), rot.y, rot.z);
    Gizmos.refresh = true;
end

function OP.SetRotY(self)
    if (SM.selectedObject == nil) then
        return;
    end
    local rot = SM.selectedObject:GetRotation();
    SM.selectedObject:SetRotation(rot.x, rad(self.value), rot.z);
    Gizmos.refresh = true;
end

function OP.SetRotZ(self)
    if (SM.selectedObject == nil) then
        return;
    end
    local rot = SM.selectedObject:GetRotation();
    SM.selectedObject:SetRotation(rot.x, rot.y, rad(self.value));
    Gizmos.refresh = true;
end

function OP.SetScale(self)
    if (SM.selectedObject == nil) then
        return;
    end
    SM.selectedObject:SetScale(self.value);
    Gizmos.refresh = true;
end

function OP.Truncate(num, digits)
    local mult = 10^(digits)
    return math.modf(num*mult)/mult
  end