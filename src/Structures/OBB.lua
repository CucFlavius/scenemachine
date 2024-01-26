local Math = SceneMachine.Math;
local Vector3 = SceneMachine.Vector3;
local Quaternion = SceneMachine.Quaternion;

SceneMachine.OBB = 
{
    center = nil,
    rotation = nil,
    size = nil
}

local OBB = SceneMachine.OBB;

setmetatable(OBB, OBB)

local fields = {}

function OBB:New(center, rotation, size)
	local v = 
    {
        center = center or Vector3:New(),
        rotation = rotation or Quaternion:New(),
        size = size or Vector3:New(),
    };

	setmetatable(v, OBB)
	return v
end

function OBB:Set(center, rotation, size)
    self.center = center or Vector3:New();
    self.rotation = rotation or Quaternion:New();
    self.size = size or Vector3:New();
end

function OBB:SetOBB(v)
    self.center = v.center;
    self.rotation = v.rotation;
    self.size = v.size;
end

function OBB:Get()
    return self.center, self.rotation, self.size;
end

OBB.__tostring = function(self)
	return string.format("OBB( C(%.3f, %.3f, %.3f) R(%.3f, %.3f, %.3f, %.3f) S(%.3f, %.3f, %.3f)",
        self.center.x, self.center.y, self.center.z,
        self.rotation.x, self.rotation.y, self.rotation.z, self.rotation.w,
        self.size.x, self.size.y, self.size.z);
end

OBB.__eq = function(a,b)
    return a.center == b.center and a.rotation == b.rotation and a.size == a.size
end

OBB.__index = function(t,k)
	local var = rawget(OBB, k)
		
	if var == nil then							
		var = rawget(fields, k)
		
		if var ~= nil then
			return var(t)	
		end
	end
	
	return var
end