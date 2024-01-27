local Math = SceneMachine.Math;
local Vector3 = SceneMachine.Vector3;
local Quaternion = SceneMachine.Quaternion;

SceneMachine.BoundingBox = 
{
    center = nil,
    size = nil,
}

local BoundingBox = SceneMachine.BoundingBox;

setmetatable(BoundingBox, BoundingBox)

local fields = {}

function BoundingBox:New(center, size)
	local v = 
    {
        center = center or Vector3:New(),
        size = size or Vector3:New(),
    };

	setmetatable(v, BoundingBox)
	return v
end

function BoundingBox:Set(center, rotation, size)
    self.center = center or Vector3:New();
    self.size = size or Vector3:New();
end

function BoundingBox:SetBoundingBox(v)
    self.center = v.center;
    self.size = v.size;
end

function BoundingBox:SetFromMinMaxAABB(xMin, yMin, zMin, xMax, yMax, zMax)
    self.size.x = xMax - xMin;
    self.size.y = yMax - yMin;
    self.size.z = zMax - zMin;
    self.center.x = (xMax - xMin) / 2.0 + xMin;
    self.center.y = (yMax - yMin) / 2.0 + yMin;
    self.center.z = 0;
end

function BoundingBox:Get()
    return self.center, self.size;
end

function BoundingBox:GetMin()
    -- center - (size / 2)
    local mx = self.center.x - (self.size.x / 2.0);
    local my = self.center.y - (self.size.y / 2.0);
    local mz = self.center.z - (self.size.z / 2.0);
    return Vector3:New(mx, my, mz);
end

function BoundingBox:GetMax()
    -- center + (size / 2)
    local mx = self.center.x + (self.size.x / 2.0);
    local my = self.center.y + (self.size.y / 2.0);
    local mz = self.center.z + (self.size.z / 2.0);
    return Vector3:New(mx, my, mz);
end

BoundingBox.__tostring = function(self)
	return string.format("BoundingBox( C(%.3f, %.3f, %.3f) S(%.3f, %.3f, %.3f)",
        self.center.x, self.center.y, self.center.z,
        self.size.x, self.size.y, self.size.z);
end

BoundingBox.__eq = function(a,b)
    return a.center == b.center and a.size == a.size
end

BoundingBox.__index = function(t,k)
	local var = rawget(BoundingBox, k)
		
	if var == nil then							
		var = rawget(fields, k)
		
		if var ~= nil then
			return var(t)	
		end
	end
	
	return var
end