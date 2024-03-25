local Math = SceneMachine.Math;
local Vector3 = SceneMachine.Vector3;
local Quaternion = SceneMachine.Quaternion;

SceneMachine.BoundingBox = 
{
    center = nil,
    size = nil,
}

--- @class BoundingBox
local BoundingBox = SceneMachine.BoundingBox;

setmetatable(BoundingBox, BoundingBox)

local fields = {}

--- Creates a new BoundingBox object.
--- @param center? Vector3 (optional) The center of the bounding box. Defaults to a new Vector3.
--- @param size? Vector3 (optional) The size of the bounding box. Defaults to a new Vector3.
--- @return BoundingBox v The newly created BoundingBox object.
function BoundingBox:New(center, size)
    local v = 
    {
        center = center or Vector3:New(),
        size = size or Vector3:New(),
    };

    setmetatable(v, BoundingBox)
    return v
end

--- Sets the center, rotation, and size of the bounding box.
--- @param center? Vector3 (optional) The center of the bounding box.
--- @param rotation? Quaternion (optional) The rotation of the bounding box.
--- @param size? Vector3 (optional) The size of the bounding box.
function BoundingBox:Set(center, rotation, size)
    self.center = center or Vector3:New();
    self.size = size or Vector3:New();
end

--- Sets the bounding box of the object.
--- @param v BoundingBox The BoundingBox containing the center and size of the bounding box.
function BoundingBox:SetBoundingBox(v)
    self.center = v.center;
    self.size = v.size;
end

--- Sets the bounding box dimensions based on the minimum and maximum coordinates.
--- @param xMin number The minimum x-coordinate.
--- @param yMin number The minimum y-coordinate.
--- @param zMin number The minimum z-coordinate.
--- @param xMax number The maximum x-coordinate.
--- @param yMax number The maximum y-coordinate.
--- @param zMax number The maximum z-coordinate.
function BoundingBox:SetFromMinMaxAABB(xMin, yMin, zMin, xMax, yMax, zMax)
    self.size.x = math.abs(xMax - xMin);
    self.size.y = math.abs(yMax - yMin);
    self.size.z = math.abs(zMax - zMin);
    self.center.x = 0;--math.abs(xMax - xMin) / 2.0 + xMin;
    self.center.y = 0;--math.abs(yMax - yMin) / 2.0 + yMin;
    self.center.z = 0;
end

--- Retrieves the center and size of the bounding box.
--- @return Vector3 center, Vector3 size: The center and size of the bounding box.
function BoundingBox:Get()
    return self.center, self.size;
end

--- Returns the minimum point of the bounding box.
--- The minimum point is calculated as the center point minus half of the size in each dimension.
--- @return Vector3 min The minimum point of the bounding box.
function BoundingBox:GetMin()
    -- center - (size / 2)
    local mx = self.center.x - (self.size.x / 2.0);
    local my = self.center.y - (self.size.y / 2.0);
    local mz = self.center.z - (self.size.z / 2.0);
    return Vector3:New(mx, my, mz);
end

--- Returns the maximum point of the bounding box.
--- The maximum point is calculated by adding half of the size to the center of the bounding box.
--- @return Vector3 max The maximum point of the bounding box.
function BoundingBox:GetMax()
    -- center + (size / 2)
    local mx = self.center.x + (self.size.x / 2.0);
    local my = self.center.y + (self.size.y / 2.0);
    local mz = self.center.z + (self.size.z / 2.0);
    return Vector3:New(mx, my, mz);
end

--- Returns a string representation of the BoundingBox object.
--- @return string string The string representation of the BoundingBox object.
BoundingBox.__tostring = function(self)
    return string.format("BoundingBox( C(%.3f, %.3f, %.3f) S(%.3f, %.3f, %.3f)",
        self.center.x, self.center.y, self.center.z,
        self.size.x, self.size.y, self.size.z);
end

--- Checks if two bounding boxes are equal.
--- @param a BoundingBox The first bounding box.
--- @param b BoundingBox The second bounding box.
--- @return boolean True if the bounding boxes are equal, false otherwise.
BoundingBox.__eq = function(a,b)
    return a.center == b.center and a.size == a.size
end

-- This function is used as the __index metamethod for the BoundingBox table.
-- It is called when a key is not found in the BoundingBox table.
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