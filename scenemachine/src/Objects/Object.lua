local Math = SceneMachine.Math;
local Vector3 = SceneMachine.Vector3;

SceneMachine.ObjectType = {};
SceneMachine.ObjectType.Group = 0;
SceneMachine.ObjectType.Model = 1;
SceneMachine.ObjectType.Creature = 2;
SceneMachine.ObjectType.Character = 3;

SceneMachine.Object = 
{
    fileID = 0,
    displayID = 0,
    name = "",
    position = Vector3:New(),
    rotation = Vector3:New(),
    scale = 1,
    alpha = 1,
	actor = nil,
	class = "Object",
    type = SceneMachine.ObjectType.Model,
    id = 0,
    visible = true,
    frozen = false,
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
        actor = nil,
        class = "Object",
        id = math.random(99999999);
        visible = true,
        frozen = false, -- could check here if path is skybox and freeze automagically
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
        actor = nil,
        class = "Object",
        id = math.random(99999999);
        visible = true,
        frozen = false,
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
        actor = nil,
        class = "Object",
        id = math.random(99999999);
        visible = true,
        frozen = false,
        type = SceneMachine.ObjectType.Character,
    };

	setmetatable(v, Object)
	return v
end

function Object:GetFileID()
    return self.fileID;
end

function Object:GetName()
    return self.name;
end

function Object:SetActor(actor)
    self.actor = actor;

    -- also set all properties
    local s = self.scale;
    self.actor:SetPosition(self.position.x / s, self.position.y / s, self.position.z / s);
    self.actor:SetRoll(self.rotation.x);
    self.actor:SetPitch(self.rotation.y);
    self.actor:SetYaw(self.rotation.z);
    self.actor:SetScale(self.scale);
    self.actor:SetAlpha(self.alpha);
end

function Object:GetActor()
    return self.actor;
end

function Object:GetActiveBoundingBox()
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

function Object:SetRotation(x, y, z, pivot)
    pivot = pivot or 0;

    if (pivot == 1) then
        local angleDiff = Vector3:New( x - object.rotation.x, y - object.rotation.y, z - object.rotation.z );
        local xMin, yMin, zMin, xMax, yMax, zMax = self:GetActiveBoundingBox();
        local bbCenter = ((zMax - zMin) / 2) * self:GetScale();
        local ppoint = Vector3:New();
        ppoint:RotateAroundPivot(Vector3:New(0, 0, 0), angleDiff);
        local position = self:GetPosition();
        local px, py, pz = position.x, position.y, position.z;
        px = px + ppoint.x;
        py = py + ppoint.y;
        pz = (pz + ppoint.z) - bbCenter;
        self:SetPosition(px, py, pz);
    end

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

function Object:ToggleVisibility()
    self.visible = not self.visible;
    if (self.visible) then
        --self.actor:Show();
        self.actor:SetAlpha(1);
    else
        --self.actor:Hide();
        self.actor:SetAlpha(0);
    end
end

function Object:SetAlpha(alpha)
    self.alpha = alpha;
    self.actor:SetAlpha(alpha);
end

function Object:GetAlpha()
    return self.alpha;
end

function Object:ToggleFrozen()
    self.frozen = not self.frozen;
end

function Object:PlayAnimID(id)
    self.actor:SetAnimation(id);
end

function Object:PlayAnimKitID(id)
    self.actor:PlayAnimationKit(id)
end

function Object:ExportPacked()
    local data = {
        fileID = self.fileID;
        displayID = self.displayID;
        type = self.type;
        name = self.name;
        position = { self.position.x,  self.position.y, self.position.z };
        rotation = { self.rotation.x,  self.rotation.y, self.rotation.z };
        scale = self.scale;
        id = self.id;
        visible = self.visible;
        frozen = self.frozen;
    };

    return data;
end

function Object:Export()
    local data = {
        fileID = self.fileID;
        displayID = self.displayID;
        type = self.type;
        name = self.name;
        position = self.position:Export();
        rotation = self.rotation:Export();
        scale = self.scale;
        id = self.id;
        visible = self.visible;
        frozen = self.frozen;
    };

    return data;
end

function Object:ImportPacked(data)
    if (data == nil) then
        print("Object:ImportPacked() data was nil.");
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
        self.position = Vector3:New(data.position[1], data.position[2], data.position[3]);
    end

    if (data.rotation ~= nil) then
        self.rotation = Vector3:New(data.rotation[1], data.rotation[2], data.rotation[3]);
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

    self.id = data.id or math.random(99999999);
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

    self.id = data.id or math.random(99999999);
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