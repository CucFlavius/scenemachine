local Math = SceneMachine.Math;
local Vector3 = SceneMachine.Vector3;

SceneMachine.Object = 
{
    fileID = 0,
    name = "",
    position = Vector3:New(),
    rotation = Vector3:New(),
    scale = 1,	
	actor = nil,
	class = "Object",
    id = 0,
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
        actor = nil,
        class = "Object",
        id = math.random(99999999);
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

function Object:GetPosition()
    return self.position;
end

function Object:SetRotation(x, y, z, pivot)
    if (not pivot) then
        pivot = 0;
    end

    if (pivot == 1) then
        local angleDiff = { x - object.rotation.x, y - object.rotation.y, z - object.rotation.z };
        local xMin, yMin, zMin, xMax, yMax, zMax = self:GetActiveBoundingBox();
        local bbCenter = ((zMax - zMin) / 2) * self:GetScale();
        local ppoint = Math.RotateObjectAroundPivot({0, 0, bbCenter}, {0, 0, 0}, angleDiff);
        local position = self:GetPosition();
        local px, py, pz = position.x, position.y, position.z;
        px = px + ppoint[1];
        py = py + ppoint[2];
        pz = (pz + ppoint[3]) - bbCenter;
        self:SetPosition(px, py, pz);
    end

    self.rotation.x = x;
    self.rotation.y = y;
    self.rotation.z = z;

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

function Object:ExportData()
    local data = {
        fileID = self.fileID;
        name = self.name;
        position = self.position;
        rotation = self.rotation;
        scale = self.scale;
        id = self.id;
    };

    return data;
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

    if (data.name ~= nil and data.name ~= "") then
        self.name = data.name;
    end

    if (data.position ~= nil) then
        if (data.position.x ~= nil) then
            self.position.x = data.position.x;
        end
        if (data.position.y ~= nil) then
            self.position.y = data.position.y;
        end
        if (data.position.z ~= nil) then
            self.position.z = data.position.z;
        end
    end

    if (data.rotation ~= nil) then
        if (data.rotation.x ~= nil) then
            self.rotation.x = data.rotation.x;
        end
        if (data.rotation.y ~= nil) then
            self.rotation.y = data.rotation.y;
        end
        if (data.rotation.z ~= nil) then
            self.rotation.z = data.rotation.z;
        end
    end

    if (data.scale ~= nil and data.scale ~= 0) then
        self.scale = data.scale;
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