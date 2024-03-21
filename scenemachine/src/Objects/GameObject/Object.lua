local Math = SceneMachine.Math;
local Vector3 = SceneMachine.Vector3;
local Matrix = SceneMachine.Matrix;
local Quaternion = SceneMachine.Quaternion;
local Gizmos = SceneMachine.Gizmos;
local SH = SceneMachine.Editor.SceneHierarchy;

SceneMachine.GameObjects.Object = {}
local Object = SceneMachine.GameObjects.Object;

Object.Type = {};
Object.Type.Group = 0;
Object.Type.Model = 1;
Object.Type.Creature = 2;
Object.Type.Character = 3;
Object.Type.Camera = 4;

Object.TypeNames = {
    [Object.Type.Group] = "Group",
    [Object.Type.Model] = "Model",
    [Object.Type.Creature] = "Creature",
    [Object.Type.Character] = "Character",
    [Object.Type.Camera] = "Camera",
};

setmetatable(Object, Object);

local fields = {}

function Object:GetType()
    return self.type;
end

function Object:GetTypeName()
    return Object.TypeNames[self.type];
end

function Object:GetName()
    return self.name;
end

function Object:HasActor()
    return false;
end

function Object:GetGizmoType()
    return Gizmos.Type.Object;
end
--[[
function Object:SetPosition(x, y, z)

    self:CreateMatrix();
    local childObjects = SH.GetChildObjects(self.id);
    if (childObjects ~= nil) then
        for i = 1, #childObjects do
            childObjects[i]:CreateMatrix();
            childObjects[i].matrix:Multiply(self:GetMatrix());
            childObjects[i]:ApplyTransformation();
        end
    end
    self.position.x = x;
    self.position.y = y;
    self.position.z = z;
    
    -- apply to actor
    if (self.actor ~= nil) then
        local s = self.scale;
        self.actor:SetPosition(x / s, y / s, z / s);
    end
end
--]]

function Object:SetPosition(x, y, z)
    -- apply to children
    local oldPos = self:GetPosition();
    local oldPosX, oldPosY, oldPosZ = oldPos.x, oldPos.y, oldPos.z;
    self:SetPosition_internal(x, y, z);

    local childObjects = SH.GetChildObjects(self.id);
    if (childObjects ~= nil) then
        local diffX = x - oldPosX;
        local diffY = y - oldPosY;
        local diffZ = z - oldPosZ;

        for i = 1, #childObjects do
            local cPos = childObjects[i]:GetPosition();
            childObjects[i]:SetPosition(cPos.x + diffX, cPos.y + diffY, cPos.z + diffZ);
        end
    end
end

function Object:SetPosition_internal(x, y, z)
    self.position.x = x;
    self.position.y = y;
    self.position.z = z;
    
    -- apply to actor
    if (self.actor ~= nil) then
        local s = self.scale;
        self.actor:SetPosition(x / s, y / s, z / s);
    end
end

function Object:SetPositionVector3(pos)
    self:SetPosition(pos.x, pos.y, pos.z);
end

function Object:SetRotationQuaternion(rot)
    self.rotation = rot:ToEuler();

    self.rotation.x = math.max(-1000000, math.min(1000000, self.rotation.x));
    self.rotation.y = math.max(-1000000, math.min(1000000, self.rotation.y));
    self.rotation.z = math.max(-1000000, math.min(1000000, self.rotation.z));

    -- apply to actor
    if (self.actor ~= nil) then
        self.actor:SetRoll(self.rotation.x);
        self.actor:SetPitch(self.rotation.y);
        self.actor:SetYaw(self.rotation.z);
    end
end

function Object:GetPosition()
    return Vector3:New(self.position.x, self.position.y, self.position.z);
end

function Object:SetRotation(x, y, z)
    x = math.max(-1000000, math.min(1000000, x));
    y = math.max(-1000000, math.min(1000000, y));
    z = math.max(-1000000, math.min(1000000, z));

    local oldRotX = self.rotation.x;
    local oldRotY = self.rotation.y;
    local oldRotZ = self.rotation.z;

    self.rotation:Set(x, y, z);

    -- apply to actor
    if (self.actor ~= nil) then
        self.actor:SetRoll(x);
        self.actor:SetPitch(y);
        self.actor:SetYaw(z);
    end

    -- apply to children
    local childObjects = SH.GetChildObjects(self.id);
    if (childObjects ~= nil) then

        local rotationQ = self:GetQuaternionRotation();
        local rotationQInv = self:GetQuaternionRotation();
        rotationQInv:Invert();

        local diffX = self.rotation.x - oldRotX;
        local diffY = self.rotation.y - oldRotY;
        local diffZ = self.rotation.z - oldRotZ;
        local pivotCenter = self:GetPosition();

        for i = 1, #childObjects, 1 do
            -- Rotate
            local cRotationQ = childObjects[i]:GetQuaternionRotation();
            local newRotationQ = Quaternion:New();
            newRotationQ:SetFromEuler(Vector3:New(diffX, diffY, diffZ));
            cRotationQ:Multiply(rotationQInv);
            cRotationQ:Multiply(newRotationQ);
            cRotationQ:Multiply(rotationQ);
            local cRotation = cRotationQ:ToEuler();
            childObjects[i]:SetRotation(cRotation.x, cRotation.y, cRotation.z);
            --childObjects[i]:SetRotationQuaternion(cRotationQ);

            -- Move
            local pivotOffset = childObjects[i]:GetPosition();
            pivotOffset:Subtract(pivotCenter);
            local distance = Vector3.Distance(Vector3.zero, pivotOffset);

            --local forward = Vector3.GetDirectionVectorBetweenVectors(pivotCenter, childObjects[i]:GetPosition());
            --print(forward);
            local rotationQInv2 = Quaternion:New();
            rotationQInv2:SetQuaternion(rotationQInv);
            local direction = rotationQInv2:ToDirectionVector();  -- TODO: forward is an issue
            local newDir = Vector3:New();
            newDir:SetVector3(direction);
            newDir:Scale(distance);

            newDir:Add(pivotCenter);
            childObjects[i]:SetPosition_internal(newDir.x, newDir.y, newDir.z);
        end
    end
end

function Object:GetRotation()
    return Vector3:New(self.rotation.x, self.rotation.y, self.rotation.z);
end

function Object:SetScale(value)
    self.scale = value;

    -- apply to actor
    if (self.actor ~= nil) then
        self.actor:SetPosition(self.position.x / value, self.position.y / value, self.position.z / value);
        self.actor:SetScale(value);
    end
end

function Object:GetScale()
    return self.scale;
end

function Object:GetVector3Scale()
    local s = self:GetScale();
    return Vector3:New(s, s, s);
end

function Object:GetQuaternionRotation()
    local qRotation = Quaternion:New();
    qRotation:SetFromEuler(self:GetRotation());
    return qRotation;
end

function Object:CreateMatrix()
    if (not self.matrix) then
        self.matrix = Matrix:New();
    end
    self.matrix:TRS(self:GetPosition(), self:GetQuaternionRotation(), self:GetVector3Scale());
end

function Object:GetMatrix()
    if (not self.matrix) then
        self:CreateMatrix();
    end

    return self.matrix;
end

function Object:ApplyTransformation()
    local pos, rot, scale = self.matrix:Decompose();
    local rotE = rot:ToEuler();

    self:SetPosition(pos.x, pos.y, pos.z);
    self:SetRotation(rotE.x, rotE.y, rotE.z);
    self:SetScale(scale);
end

function Object:ToggleVisibility()
    self.visible = not self.visible;
    if (self.visible) then
        self:Show();
    else
        self:Hide();
    end
end

function Object:Show()
    --self.actor:Show();
    self.visible = true;
    if (self.actor) then
        self.actor:SetAlpha(1);
    end
end

function Object:Hide()
    --self.actor:Hide();
    self.visible = false;
    if (self.actor) then
        self.actor:SetAlpha(0);
    end
end

function Object:IsHidden()
    return not self.visible;
end

function Object:IsVisible()
    return self.visible;
end

function Object:ToggleFrozen()
    self.frozen = not self.frozen;
end

function Object:IsFrozen()
    return self.frozen;
end

function Object:Freeze()
    self.frozen = true;
end

function Object:Unfreeze()
    self.frozen = false;
end

function Object:Rename(newName)
    self.isRenamed = true;
    self.name = newName;
end

function Object:PackRotation(rotation)
    -- packing to 0, 360 range
    local rotX = math.floor(math.deg(rotation.x) + 180);
    local rotY = math.floor(math.deg(rotation.y) + 180);
    local rotZ = math.floor(math.deg(rotation.z) + 180);
    return rotX, rotY, rotZ;
end

function Object:UnpackRotation(X, Y, Z)
    local rotX = math.rad(X - 180);
    local rotY = math.rad(Y - 180);
    local rotZ = math.rad(Z - 180);
    return rotX, rotY, rotZ;
end

function Object:ExportPacked()
    local name = nil;
    if (self.isRenamed) then
        name = self.name;
    end

    --local pRotX, pRotY, pRotZ = self:PackRotation(self.rotation);

    return {
        self.fileID,
        self.displayID,
        self.type,
        name,
        self.position.x, self.position.y, self.position.z,
        self.rotation.x, self.rotation.y, self.rotation.z,
        --pRotX, pRotY, pRotZ,
        self.scale,
        self.id,
        self.visible,
        self.frozen,
        self.alpha,
        self.desaturation,
    }
end

function Object:Export()
    local data = {
        fileID = self.fileID,
        displayID = self.displayID,
        type = self.type,
        name = self.name,
        position = self.position:Export(),
        rotation = self.rotation:Export(),
        scale = self.scale,
        id = self.id,
        visible = self.visible,
        frozen = self.frozen,
        alpha = self.alpha,
        desaturation = self.desaturation,
        isRenamed = self.isRenamed,
        fov = self.fov,
        nearClip = self.nearClip,
        farClip = self.farClip,
    };

    return data;
end

function Object:ImportPacked(data)
    if (data == nil) then
        print("Object:ImportPacked() data was nil.");
        return;
    end

    -- verifying all elements upon import because sometimes the saved variables get corrupted --
    if (data[1] ~= nil) then
        self.fileID = data[1];
    end

    if (data[2] ~= nil) then
        self.displayID = data[2];
    else
        self.displayID = 0;
    end

    if (data[3] ~= nil) then
        self.type = data[3];
    else
        self.type = Object.Type.Model;
    end

    if (data[4] ~= nil and data[4] ~= "") then
        self.name = data[4];
        self.isRenamed = true;
    else
        -- fetch name from displayID
        if (self.type == Object.Type.Creature and self.displayID ~= 0) then
            local found = false;
            for creatureID, displayID in pairs(SceneMachine.creatureToDisplayID) do
                if (displayID == self.displayID) then
                    self.name = SceneMachine.creatureData[creatureID];
                end
            end
        end

        -- fetch name from fileID
        if (self.type == Object.Type.Model and self.fileID ~= 0) then
            self.name = self:GetFileName(self.fileID);
        end

        self.isRenamed = false;
    end

    if (data[5] ~= nil and data[6] ~= nil and data[7] ~= nil) then
        self.position = Vector3:New(data[5], data[6], data[7]);
    end

    if (data[8] ~= nil and data[9] ~= nil and data[10] ~= nil) then
        --self.rotation = Vector3:New(self:UnpackRotation(data[8], data[9], data[10]));
        self.rotation = Vector3:New(data[8], data[9], data[10]);
    end

    if (data[11] ~= nil and data[11] ~= 0) then
        self.scale = data[11];
    end
    
    self.id = data[12] or math.random(99999999);

    if (data[13] ~= nil) then
        self.visible = data[13];
    else
        self.visible = true;
    end
    
    if (data[14] ~= nil) then
        self.frozen = data[14];
    else
        self.frozen = false;
    end

    if(data[15] ~= nil) then
        self.alpha = data[15];
    else
        self.alpha = 1.0;
    end

    if(data[16] ~= nil) then
        self.desaturation = data[16];
    else
        self.desaturation = 0.0;
    end
end

function Object:ImportData(data)
    if (data == nil) then
        print("Object:ImportData() data was nil.");
        return;
    end

    -- verifying all elements upon import because sometimes the saved variables get corrupted --
    if (data.fileID ~= nil) then
        self.fileID = data.fileID;
    end

    if (data.displayID ~= nil) then
        self.displayID = data.displayID;
    else
        self.displayID = 0;
    end

    if (data.type ~= nil) then
        self.type = data.type;
    else
        self.type = Object.Type.Model;
    end

    if (data.name ~= nil and data.name ~= "") then
        self.name = data.name;
    end

    if (data.position ~= nil) then
        self.position = Vector3:New(data.position.x, data.position.y, data.position.z);
    end

    if (data.rotation ~= nil) then
        self.rotation = Vector3:New(data.rotation.x, data.rotation.y, data.rotation.z);
    end

    if (data.scale ~= nil and data.scale ~= 0) then
        self.scale = data.scale;
    end
    
    if (data.visible ~= nil) then
        self.visible = data.visible;
    else
        self.visible = true;
    end
    
    if (data.frozen ~= nil) then
        self.frozen = data.frozen;
    else
        self.frozen = false;
    end

    if(data.alpha ~= nil) then
        self.alpha = data.alpha;
    else
        self.alpha = 1.0;
    end

    if(data.desaturation ~= nil) then
        self.desaturation = data.desaturation;
    else
        self.desaturation = 0.0;
    end

    if (data.isRenamed ~= nil) then
        self.isRenamed = data.isRenamed;
    end

    if (data.fov ~= nil) then
        self.fov = data.fov;
    end

    if (data.nearClip ~= nil) then
        self.nearClip = data.nearClip;
    end

    if (data.farClip ~= nil) then
        self.farClip = data.farClip;
    end

    self.id = data.id or math.random(99999999);
end

function Object:Select()
    print("Select() not implemented for type " .. self:GetTypeName());
end

function Object:Deselect()
    print("Deselect() not implemented for type " .. self:GetTypeName());
end

Object.__tostring = function(self)
	return string.format("%s %i p(%f,%f,%f)", self.name, self.fileID, self.position.x, self.position.y, self.position.z);
end

Object.__eq = function(a,b)
    return a.id == b.id;
end

Object.__index = function(t,k)
	local var = rawget(Object, k)
		
	if var == nil then							
		var = rawget(fields, k)
		
		if var ~= nil then
			return var(t)	
		end
	end
	
	return var
end