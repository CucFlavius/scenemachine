local Math = SceneMachine.Math;
local Vector3 = SceneMachine.Vector3;
local Matrix = SceneMachine.Matrix;
local Quaternion = SceneMachine.Quaternion;
local Gizmos = SceneMachine.Gizmos;

SceneMachine.ObjectType = {};
SceneMachine.ObjectType.Group = 0;
SceneMachine.ObjectType.Model = 1;
SceneMachine.ObjectType.Creature = 2;
SceneMachine.ObjectType.Character = 3;
SceneMachine.ObjectType.Camera = 4;

SceneMachine.Object = 
{
    fileID = 0,
    displayID = 0,
    name = "",
    position = Vector3:New(),
    rotation = Vector3:New(),
    scale = 1,
    alpha = 1,
    desaturation = 0,
	actor = nil,
	class = "Object",
    type = SceneMachine.ObjectType.Model,
    id = 0,
    visible = true,
    frozen = false,
    isRenamed = false,  -- toggle this bool on when a user renames the object (NYI)
}

local Object = SceneMachine.Object;

setmetatable(Object, Object)

local fields = {}

function Object:New(name, fileID, position, rotation, scale)
	local v = 
    {
        fileID = fileID or 0,
        name = name or "NewObject",
        position = position or Vector3:New(),
        rotation = rotation or Vector3:New(),
        scale = scale or 1,
        alpha = 1,
        desaturation = 0,
        actor = nil,
        class = "Object",
        id = math.random(99999999);
        visible = true,
        frozen = false, -- could check here if path is skybox and freeze automagically
        isRenamed = false,
        type = SceneMachine.ObjectType.Model,
    };

	setmetatable(v, Object)
	return v
end

function Object:NewCreature(name, displayID, position, rotation, scale)
	local v = 
    {
        fileID = 0,
        displayID = displayID or 0,
        name = name or "NewObject",
        position = position or Vector3:New(),
        rotation = rotation or Vector3:New(),
        scale = scale or 1,	
        alpha = 1,
        desaturation = 0,
        actor = nil,
        class = "Object",
        id = math.random(99999999);
        visible = true,
        frozen = false,
        isRenamed = false,
        type = SceneMachine.ObjectType.Creature,
    };

	setmetatable(v, Object)
	return v
end

function Object:NewCharacter(name, position, rotation, scale)
	local v = 
    {
        fileID = -1,
        displayID = -1,
        name = name or "Character",
        position = position or Vector3:New(),
        rotation = rotation or Vector3:New(),
        scale = scale or 1,	
        alpha = 1,
        desaturation = 0,
        actor = nil,
        class = "Object",
        id = math.random(99999999);
        visible = true,
        frozen = false,
        isRenamed = false,
        type = SceneMachine.ObjectType.Character,
    };

	setmetatable(v, Object)
	return v
end

function Object:NewCamera(name, position, rotation, fov, nearClip, farClip)
    local v = 
    {
        name = name or "NewObject",
        position = position or Vector3:New(),
        rotation = rotation or Vector3:New(),
        scale = scale or 1,
        alpha = 1,
        desaturation = 0,
        actor = nil,
        class = "Object",
        id = math.random(99999999);
        visible = true,
        frozen = false,
        isRenamed = false,
        type = SceneMachine.ObjectType.Camera,
        fov = fov,
        nearClip = nearClip,
        farClip = farClip,
    };

	setmetatable(v, Object)
	return v
end

function Object:GetFileID()
    return self.fileID;
end

function Object:GetDisplayID()
    return self.displayID;
end

function Object:GetType()
    return self.type;
end

function Object:GetName()
    return self.name;
end

function Object:SetActor(actor)
    self.actor = actor;

    -- also set all properties
    local s = 1.0;
    if (type(self.scale) == "number") then
        s = self.scale;
    end

    self.actor:SetPosition(self.position.x / s, self.position.y / s, self.position.z / s);
    self.actor:SetRoll(self.rotation.x);
    self.actor:SetPitch(self.rotation.y);
    self.actor:SetYaw(self.rotation.z);
    self.actor:SetAlpha(self.alpha);
    self.actor:SetDesaturation(self.desaturation);
    self.actor:SetScale(s);
end

function Object:GetActor()
    return self.actor;
end

function Object:HasActor()
    if (self.type == SceneMachine.ObjectType.Model or
        self.type == SceneMachine.ObjectType.Creature or
        self.type == SceneMachine.ObjectType.Character) then
        return true;
    end

    if (self.type == SceneMachine.ObjectType.Group or
        self.type == SceneMachine.ObjectType.Camera) then
        return false;
    end

    print("Object:HasActor() undefined type " .. self.type);
    return false;
end

function Object:GetGizmoType()
    if (self.type == SceneMachine.ObjectType.Model or
        self.type == SceneMachine.ObjectType.Creature or
        self.type == SceneMachine.ObjectType.Character or
        self.type == SceneMachine.ObjectType.Group) then
        return Gizmos.Type.Object;
    end

    if (self.type == SceneMachine.ObjectType.Camera) then
        return Gizmos.Type.Camera;
    end

    print("Object:GetGizmoType() undefined type " .. self.type);
    return Gizmos.Type.None;
end

function Object:GetActiveBoundingBox()
    if (not self:HasActor()) then
        return nil;
    end

    local xMin, yMin, zMin, xMax, yMax, zMax = self.actor:GetActiveBoundingBox();

    if (xMin == nil or yMin == nil or zMin == nil) then
        xMin, yMin, zMin, xMax, yMax, zMax = -1, -1, -1, 1, 1, 1;
    end

    return xMin, yMin, zMin, xMax, yMax, zMax;
end

function Object:SetPosition(x, y, z)
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
    self.position.x = pos.x;
    self.position.y = pos.y;
    self.position.z = pos.z;

    -- apply to actor
    if (self.actor ~= nil) then
        local s = self.scale;
        self.actor:SetPosition(pos.x / s, pos.y / s, pos.z / s);
    end
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
    return self.position;
end

function Object:SetRotation(x, y, z)
    x = math.max(-1000000, math.min(1000000, x));
    y = math.max(-1000000, math.min(1000000, y));
    z = math.max(-1000000, math.min(1000000, z));

    self.rotation:Set(x, y, z);

    -- apply to actor
    if (self.actor ~= nil) then
        self.actor:SetRoll(x);
        self.actor:SetPitch(y);
        self.actor:SetYaw(z);
    end
end

function Object:GetRotation()
    return self.rotation;
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

    --[[
    self.matrix = Matrix:New();
    self.matrix:SetIdentity();
    --self.matrix:RotateEuler(self.rotation.x, self.rotation.y, self.rotation.z);
    local q = Quaternion:New();
    q:SetFromEuler(self.rotation);
    self.matrix:CreateFromQuaternion(q);
    self.matrix:Translate(self.position.x, self.position.y, self.position.z);
    --]]
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
    self.actor:SetAlpha(1);
end

function Object:Hide()
    --self.actor:Hide();
    self.visible = false;
    self.actor:SetAlpha(0);
end

function Object:Hidden()
    return not self.visible;
end

function Object:Visible()
    return self.visible;
end

function Object:SetAlpha(alpha)
    self.alpha = alpha;
    if (self.actor) then
        self.actor:SetAlpha(alpha);
    end
end

function Object:GetAlpha()
    return self.alpha;
end

function Object:SetDesaturation(desaturation)
    self.desaturation = desaturation;
    self.actor:SetDesaturation(desaturation);
end

function Object:GetDesaturation()
    return self.desaturation;
end

function Object:ToggleFrozen()
    self.frozen = not self.frozen;
end

function Object:PlayAnimID(id, variation)
    self.actor:SetAnimation(id, variation);
end

function Object:PlayAnimKitID(id)
    self.actor:PlayAnimationKit(id);
end

function Object:SetSpellVisualKitID(id, oneShot)
    if (self:HasActor()) then 
        self.actor:SetSpellVisualKit(id, oneShot);
        self.spellVisualKitID = id;
    end
end

function Object:ClearSpellVisualKits()
    if (self:HasActor()) then 
        self:SetSpellVisualKitID(-1);

        if (self.type == SceneMachine.ObjectType.Model) then
            self.actor:SetModelByFileID(self.fileID);
        elseif (self.type == SceneMachine.ObjectType.Creature) then
            self.actor:SetModelByCreatureDisplayID(self.displayID);
        elseif (self.type == SceneMachine.ObjectType.Character) then
            self.actor:SetModelByUnit("player");
        end
        
        self.spellVisualKitID = nil;
    end
end

function Object:Select()
    if (not self.selected) then
        self:SetSpellVisualKitID(70682);
        self.selected = true;
    end
end

function Object:Deselect()
    if (self.selected) then
        self:ClearSpellVisualKits();
        self.selected = false;
    end
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
        self.type = SceneMachine.ObjectType.Model;
    end

    if (data[4] ~= nil and data[4] ~= "") then
        self.name = data[4];
        self.isRenamed = true;
    else
        -- fetch name from displayID
        if (self.type == SceneMachine.ObjectType.Creature and self.displayID ~= 0) then
            local found = false;
            for creatureID, displayID in pairs(SceneMachine.creatureToDisplayID) do
                if (displayID == self.displayID) then
                    self.name = SceneMachine.creatureData[creatureID];
                end
            end
        end

        -- fetch name from fileID
        if (self.type == SceneMachine.ObjectType.Model and self.fileID ~= 0) then
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

function Object:GetFileName(fileID)
    return self:GetFileNameRecursive(fileID, SceneMachine.modelData[1]);
end

function Object:GetFileNameRecursive(value, dir)
    -- File Scan
    if (not dir) then return nil; end

    if (dir["FN"] ~= nil) then
        local fileCount = #dir["FN"];
        for i = 1, fileCount, 1 do
            local fileID = dir["FI"][i];
            if (fileID == value) then
                local fileName = dir["FN"][i];
                return fileName;
            end
        end
    end

    -- Directory scan
    if (dir["D"] ~= nil) then
        local directoryCount = #dir["D"];
        for i = 1, directoryCount, 1 do
            local n = self:GetFileNameRecursive(value, dir["D"][i]);
            if (n) then return n; end
        end
    end

    return nil;
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
        self.type = SceneMachine.ObjectType.Model;
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

function Object:GetFoV()
    return self.fov;
end

function Object:SetFoV(fov)
    self.fov = fov;
end

function Object:GetNearClip()
    return self.nearClip;
end

function Object:SetNearClip(near)
    self.nearClip = near;
end

function Object:GetFarClip()
    return self.farClip;
end

function Object:SetFarClip(far)
    self.farClip = far;
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