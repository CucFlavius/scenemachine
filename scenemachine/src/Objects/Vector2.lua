SceneMachine.Vector2 = 
{
    x = 0,
    y = 0
}

--- @class Vector2
local Vector2 = SceneMachine.Vector2;

setmetatable(Vector2, Vector2)

local fields = {}

--- Creates a new Vector2 object with the specified x and y coordinates.
--- @param x? number (optional) The x coordinate of the vector. Defaults to 0 if not provided.
--- @param y? number (optional) The y coordinate of the vector. Defaults to 0 if not provided.
--- @return Vector2 v The newly created Vector2 object.
function Vector2:New(x, y)
    local v = 
    {
        x = x or 0,
        y = y or 0
    };

    setmetatable(v, Vector2)
    return v
end

--- Sets the x and y components of the vector.
--- @param x? number The x component of the vector.
--- @param y? number The y component of the vector.
function Vector2:Set(x, y)
    self.x = x or 0;
    self.y = y or 0;
end

--- Sets the values of the Vector2 object to the values of another Vector2 object.
--- @param vector Vector2 The Vector2 object to copy the values from.
function Vector2:SetVector2(vector)
    self.x = vector.x;
    self.y = vector.y;
end

--- Retrieves the x and y components of the vector.
--- @return number x, number y The x and y components of the vector.
function Vector2:Get()
    return self.x, self.y;
end

--- Scales the Vector2 by a given factor.
--- @param f number The scaling factor.
function Vector2:Scale(f)
    self.x = self.x * f;
    self.y = self.y * f;
end

--- Adds the components of another vector to this vector.
--- @param vector Vector2 The vector to add.
function Vector2:Add(vector)
    self.x = self.x + vector.x;
    self.y = self.y + vector.y;
end

--- Subtracts the given vector from the current vector.
--- @param vector Vector2 The vector to subtract.
function Vector2:Subtract(vector)
    self.x = self.x - vector.x;
    self.y = self.y - vector.y;
end

--- Multiplies the current vector by another vector.
--- @param vector Vector2 The vector to multiply by.
function Vector2:Multiply(vector)
    self.x = self.x * vector.x;
    self.y = self.y * vector.y;
end

--- Divides the current vector by another vector.
--- @param vector Vector2 The vector to divide by.
function Vector2:Divide(vector)
    self.x = self.x / vector.x;
    self.y = self.y / vector.y;
end

--- Multiplies the vector by a matrix.
---@param mat Matrix The matrix to multiply the vector by.
---@return Vector2 self The modified vector.
function Vector2:MultiplyMatrix(mat)
    local x = (mat.m00 * self.x) + (mat.m01 * self.y);
    local y = (mat.m10 * self.x) + (mat.m11 * self.y);

    self.x = x;
    self.y = y;

    return self;
end

--- Calculates the Manhattan distance between two Vector2 points.
--- @param a Vector2 The first Vector2 point.
--- @param b Vector2 The second Vector2 point.
--- @return number distance The Manhattan distance between the two points.
function Vector2.ManhattanDistance(a, b)
    return math.abs(a.x - b.x) + math.abs(a.y - b.y);
end

--- Calculates the Manhattan distance between two points in a 2D space.
--- @param aX number The x-coordinate of the first point.
--- @param aY number The y-coordinate of the first point.
--- @param bX number The x-coordinate of the second point.
--- @param bY number The y-coordinate of the second point.
--- @return number distance The Manhattan distance between the two points.
function Vector2.ManhattanDistanceP(aX, aY, bX, bY)
    return math.abs(aX - bX) + math.abs(aY - bY);
end

--- Calculates the dot product of two vectors.
--- @param a Vector2 The first vector.
--- @param b Vector2 The second vector.
--- @return number dotproduct The dot product of the two vectors.
function Vector2.DotProduct(a, b)
    return a.x * b.x + a.y * b.y;
end

--- Linearly interpolates between two vectors.
--- @param a Vector2: The starting vector.
--- @param b Vector2: The ending vector.
--- @param t number: The interpolation factor (between 0 and 1).
function Vector2:Lerp(a, b, t)
    self.x = a.x * (1 - t) + b.x * t;
    self.y = a.y * (1 - t) + b.y * t;
end

--- Returns a string representation of the Vector2 object.
--- @return string string The string representation of the Vector2 object.
Vector2.__tostring = function(self)
	return string.format("Vector2( %.3f, %.3f )", self.x, self.y);
end

--- Checks if two Vector2 objects are equal.
--- @param a Vector2 The first Vector2 object.
--- @param b Vector2 The second Vector2 object.
--- @return boolean equal if the Vector2 objects are equal, false otherwise.
Vector2.__eq = function(a,b)
    return a.x == b.x and a.y == b.y;
end

-- This function is used as the __index metamethod for the Vector2 table.
-- It is called when a key is not found in the Vector2 table.
-- It first checks if the key exists in the Vector2 table itself.
-- If not, it checks if the key exists in the 'fields' table.
-- If the key exists in the 'fields' table, it returns the corresponding value as a function call with 't' as the argument.
-- If the key is not found in either table, it returns nil.
Vector2.__index = function(t,k)
	local var = rawget(Vector2, k)
		
	if var == nil then							
		var = rawget(fields, k)
		
		if var ~= nil then
			return var(t)	
		end
	end
	
	return var
end

--- Zero Vector (0, 0)
Vector2.zero = Vector2:New(0, 0);