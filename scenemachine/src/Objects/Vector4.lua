SceneMachine.Vector4 = 
{
    x = 0,
    y = 0,
    z = 0,
    w = 0
}

--- @class Vector4
local Vector4 = SceneMachine.Vector4;

setmetatable(Vector4, Vector4)

local fields = {}

--- Creates a new Vector4 object.
--- @param x? number (optional) The x component of the vector. Defaults to 0 if not provided.
--- @param y? number (optional) The y component of the vector. Defaults to 0 if not provided.
--- @param z? number (optional) The z component of the vector. Defaults to 0 if not provided.
--- @param w? number (optional) The w component of the vector. Defaults to 0 if not provided.
--- @return Vector3 v The newly created Vector4 object.
function Vector4:New(x, y, z, w)
    local v = 
    {
        x = x or 0,
        y = y or 0,
        z = z or 0,
        w = w or 0,
    };

    setmetatable(v, Vector4)
    return v
end

--- Sets the values of the Vector4.
--- @param x? number The x component of the Vector4.
--- @param y? number The y component of the Vector4.
--- @param z? number The z component of the Vector4.
--- @param w? number The w component of the Vector4.
function Vector4:Set(x, y, z, w)
    self.x = x or 0;
    self.y = y or 0;
    self.z = z or 0;
    self.w = w or 0;
end

--- Sets the values of the current Vector4 object to match the values of another Vector4 object.
--- @param vector Vector4 The Vector4 object to copy the values from.
function Vector4:SetVector4(vector)
    self.x = vector.x;
    self.y = vector.y;
    self.z = vector.z;
    self.w = vector.w;
end

--- Retrieves the components of the vector.
--- @return number x, number y, number z, number w The x, y, z, and w components of the vector.
function Vector4:Get()
    return self.x, self.y, self.z, self.w;
end

--- Scales the vector by a given factor.
--- @param f number The scaling factor.
function Vector4:Scale(factor)
    self.x = self.x * factor;
    self.y = self.y * factor;
    self.z = self.z * factor;
    self.w = self.w * factor;
end

--- Adds the components of another vector to this vector.
--- @param vector Vector4 The vector to add.
function Vector4:Add(vector)
    self.x = self.x + vector.x;
    self.y = self.y + vector.y;
    self.z = self.z + vector.z;
    self.w = self.w + vector.w;
end

--- Subtracts the components of the given vector from this vector.
--- @param vector Vector4 The vector to subtract from this vector.
function Vector4:Subtract(vector)
    self.x = self.x - vector.x;
    self.y = self.y - vector.y;
    self.z = self.z - vector.z;
    self.w = self.w - vector.w;
end

--- Multiplies the current vector by another vector.
--- @param vector Vector4 The vector to multiply with.
function Vector4:Multiply(vector)
    self.x = self.x * vector.x;
    self.y = self.y * vector.y;
    self.z = self.z * vector.z;
    self.w = self.w * vector.w;
end

--- Divides the current vector by another vector.
--- @param vector Vector4 The vector to divide by.
function Vector4:Divide(vector)
    self.x = self.x / vector.x;
    self.y = self.y / vector.y;
    self.z = self.z / vector.z;
    self.w = self.w / vector.w;
end

--- Multiplies the vector by a matrix.
--- @param mat Matrix The matrix to multiply the vector by.
--- @return Vector4 self The modified vector.
function Vector4:MultiplyMatrix(mat)
    local x = (mat.m00 * self.x) + (mat.m01 * self.y) + (mat.m02 * self.z) + (mat.m03 * self.w);
    local y = (mat.m10 * self.x) + (mat.m11 * self.y) + (mat.m12 * self.z) + (mat.m13 * self.w);
    local z = (mat.m20 * self.x) + (mat.m21 * self.y) + (mat.m22 * self.z) + (mat.m23 * self.w);
    local w = (mat.m30 * self.x) + (mat.m31 * self.y) + (mat.m32 * self.z) + (mat.m33 * self.w);

    self.x = x;
    self.y = y;
    self.z = z;
    self.w = w;

    return self;
end

--- Calculates the dot product of two Vector4 objects.
---@param a Vector4 The first Vector4 object.
---@param b Vector4 The second Vector4 object.
---@return number dotproduct The dot product of the two Vector4 objects.
function Vector4.DotProduct(a, b)
    return a.x * b.x + a.y * b.y + a.z * b.z + a.w * b.w;
end

--- Normalizes the vector, making it a unit vector with a magnitude of 1.
--- If the vector is a zero vector (magnitude is zero), it remains unchanged.
--- @return Vector4 self The normalized vector.
function Vector4:Normalize()
    local magnitude = math.sqrt(self.x^2 + self.y^2 + self.z^2 + self.w^2)
    
    if (magnitude ~= 0) then
        self.x = self.x / magnitude;
        self.y = self.y / magnitude;
        self.z = self.z / magnitude;
        self.w = self.w / magnitude;
    else
        -- Handle the case where the vector is a zero vector (magnitude is zero)
        self.x = 0;
        self.y = 0;
        self.z = 0;
        self.w = 0;
    end

    return self;
end

--- Linearly interpolates between two Vector4 values.
--- @param a Vector4 The starting Vector4.
--- @param b Vector4 The ending Vector4.
--- @param t number The interpolation factor (between 0 and 1).
function Vector4:Lerp(a, b, t)
    self.x = a.x * (1 - t) + b.x * t;
    self.y = a.y * (1 - t) + b.y * t;
    self.z = a.z * (1 - t) + b.z * t;
    self.w = a.w * (1 - t) + b.w * t;
end

--- Returns a string representation of the Vector4 object.
--- @return string string The string representation of the Vector4 object.
Vector4.__tostring = function(self)
	return string.format("Vector4( %.3f, %.3f, %.3f, %.3f )", self.x, self.y, self.z, self.w);
end

--- Checks if two Vector4 objects are equal.
--- @param a Vector4 The first Vector4 object.
--- @param b Vector4 The second Vector4 object.
--- @return boolean equal if the Vector4 objects are equal, false otherwise.
Vector4.__eq = function(a,b)
    return a.x == b.x and a.y == b.y and a.z == b.z and a.w == b.w;
end

-- This function is used as the __index metamethod for the Vector4 table.
-- It is called when a key is not found in the Vector4 table.
-- It first checks if the key exists in the Vector4 table itself.
-- If not, it checks if the key exists in the 'fields' table.
-- If the key exists in the 'fields' table, it returns the corresponding value as a function call with 't' as the argument.
-- If the key is not found in either table, it returns nil.
Vector4.__index = function(t,k)
	local var = rawget(Vector4, k)
		
	if var == nil then							
		var = rawget(fields, k)
		
		if var ~= nil then
			return var(t)	
		end
	end
	
	return var
end

--- Zero Vector (0, 0, 0, 0)
Vector4.zero = Vector4:New(0, 0, 0, 0);