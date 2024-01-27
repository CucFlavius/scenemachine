local Math = SceneMachine.Math;
local Vector3 = SceneMachine.Vector3;

SceneMachine.Quaternion = 
{
    x = 0,
    y = 0,
    z = 0,
    w = 1
}

local Quaternion = SceneMachine.Quaternion;

setmetatable(Quaternion, Quaternion)

local fields = {}

function Quaternion:New(x, y, z, w)
	local v = 
    {
        x = x or 0,
        y = y or 0,
        z = z or 0,
        w = w or 1
    };

	setmetatable(v, Quaternion)
	return v
end

function Quaternion:Set(x, y, z, w)
    self.x = x or 0;
    self.y = y or 0;
    self.z = z or 0;
    self.w = w or 1;
end

function Quaternion:SetQuaternion(v)
    self.x = v.x;
    self.y = v.y;
    self.z = v.z;
    self.w = v.w;
end

function Quaternion:Get()
    return self.x, self.y, self.z, self.w;
end

function Quaternion:ToEuler()
    local rx = math.atan2(2 * (self.w * self.x + self.y * self.z), 1 - 2 * (self.x^2 + self.y^2))
    local ry = math.asin(2 * (self.w * self.y - self.z * self.x))
    local rz = math.atan2(2 * (self.w * self.z + self.x * self.y), 1 - 2 * (self.y^2 + self.z^2))
    
    return Vector3:New(rx, ry, rz);
end

function Quaternion:SetFromEuler(euler)
    local sx = math.sin(euler.x / 2.0);
    local sy = math.sin(euler.y / 2.0);
    local sz = math.sin(euler.z / 2.0);
    local cx = math.cos(euler.x / 2.0);
    local cy = math.cos(euler.y / 2.0);
    local cz = math.cos(euler.z / 2.0);

    self.w = cx * cy * cz + sx * sy * sz;
    self.x = sx * cy * cz - cx * sy * sz;
    self.y = cx * sy * cz + sx * cy * sz;
    self.z = cx * cy * sz - sx * sy * cz;
end

function Quaternion:Lerp(a, b, t)
    self.x = a.x * (1 - t) + b.x * t;
    self.y = a.y * (1 - t) + b.y * t;
    self.z = a.z * (1 - t) + b.z * t;
    self.w = a.w * (1 - t) + b.w * t;
end

function Quaternion:Invert()
    -- Calculate the norm squared
    local norm_squared = self.w^2 + self.x^2 + self.y^2 + self.z^2

    -- Check if the quaternion is non-zero before computing the inverse
    if (norm_squared == 0) then
        return;
    end

    -- Calculate the inverse quaternion
    self.w = self.w / norm_squared;
    self.x = -self.x / norm_squared;
    self.y = -self.y / norm_squared;
    self.z = -self.z / norm_squared;
end

function Quaternion:Multiply(q2)
    local w = self.w * q2.w - self.x * q2.x - self.y * q2.y - self.z * q2.z;
    local x = self.w * q2.x + self.x * q2.w + self.y * q2.z - self.z * q2.y;
    local y = self.w * q2.y - self.x * q2.z + self.y * q2.w + self.z * q2.x;
    local z = self.w * q2.z + self.x * q2.y - self.y * q2.x + self.z * q2.w;

    self.x = x;
    self.y = y;
    self.z = z;
    self.w = w;
end

Quaternion.__tostring = function(self)
	return string.format("Quaternion( %.3f, %.3f, %.3f, %.3f )", self.x, self.y, self.z, self.w);
end

Quaternion.__eq = function(a,b)
    return a.x == b.x and a.y == b.x and a.z == b.z and a.w == b.w;
end

Quaternion.__index = function(t,k)
	local var = rawget(Quaternion, k)
		
	if var == nil then							
		var = rawget(fields, k)
		
		if var ~= nil then
			return var(t)	
		end
	end
	
	return var
end

Quaternion.identity = Quaternion:New(0, 0, 0, 1);