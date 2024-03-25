SceneMachine.Vector3 = 
{
    x = 0,
    y = 0,
    z = 0
}

--- @class Vector3
local Vector3 = SceneMachine.Vector3;

setmetatable(Vector3, Vector3)

local fields = {}

--- Creates a new Vector3 object with the specified coordinates.
--- @param x? number (optional) The x-coordinate of the vector. Defaults to 0 if not provided.
--- @param y? number (optional) The y-coordinate of the vector. Defaults to 0 if not provided.
--- @param z? number (optional) The z-coordinate of the vector. Defaults to 0 if not provided.
--- @return Vector3 v The newly created Vector3 object.
function Vector3:New(x, y, z)
    local v = 
    {
        x = x or 0,
        y = y or 0,
        z = z or 0
    };

    setmetatable(v, Vector3)
    return v
end

--- Sets the values of the Vector3 object.
--- @param x? number The x-coordinate value.
--- @param y? number The y-coordinate value.
--- @param z? number The z-coordinate value.
function Vector3:Set(x, y, z)
    self.x = x or 0;
    self.y = y or 0;
    self.z = z or 0;
end

--- Sets the values of the Vector3 object based on another Vector3 object.
--- @param vector Vector3 The Vector3 object to copy the values from.
function Vector3:SetVector3(vector)
    self.x = vector.x;
    self.y = vector.y;
    self.z = vector.z;
end

--- Retrieves the x, y, and z components of the vector.
--- @return number x, number y, number z The x, y, and z components of the vector.
function Vector3:Get()
    return self.x, self.y, self.z;
end

--- Scales the vector by the specified value.
--- @param value number The value to scale the vector by.
--- @return Vector3 self The scaled vector.
function Vector3:Scale(value)
    self.x = self.x * value;
    self.y = self.y * value;
    self.z = self.z * value;
    return self;
end

--- Adds the components of another vector to this vector.
---@param vector Vector3 The vector to add.
---@return Vector3 self The resulting vector after addition.
function Vector3:Add(vector)
    self.x = self.x + vector.x;
    self.y = self.y + vector.y;
    self.z = self.z + vector.z;
    return self
end

--- Subtracts the given vector from the current vector.
--- @param vector Vector3 The vector to subtract.
--- @return Vector3 self The resulting vector after subtraction.
function Vector3:Subtract(vector)
    self.x = self.x - vector.x;
    self.y = self.y - vector.y;
    self.z = self.z - vector.z;
    return self;
end

--- Multiplies the current vector by another vector.
--- @param vector Vector3 The vector to multiply with.
--- @return Vector3 self The resulting multiplied vector.
function Vector3:Multiply(vector)
    self.x = self.x * vector.x;
    self.y = self.y * vector.y;
    self.z = self.z * vector.z;
    return self;
end

--- Divides the current vector by another vector.
--- @param vector Vector3 The vector to divide by.
--- @return Vector3 self The current vector after division.
function Vector3:Divide(vector)
    self.x = self.x / vector.x;
    self.y = self.y / vector.y;
    self.z = self.z / vector.z;
    return self;
end

--- Multiplies the vector by a quaternion.
--- @param q Quaternion to multiply by
--- @return Vector3 self The current vector after quaternion multiplied.
function Vector3:MultiplyQuaternion(q)
    local ix = q.w * self.x + q.y * self.z - q.z * self.y;
    local iy = q.w * self.y + q.z * self.x - q.x * self.z;
    local iz = q.w * self.z + q.x * self.y - q.y * self.x;
    local iw = -q.x * self.x - q.y * self.y - q.z * self.z;

    local x = ix * q.w + iw * -q.x + iy * -q.z - iz * -q.y;
    local y = iy * q.w + iw * -q.y + iz * -q.x - ix * -q.z;
    local z = iz * q.w + iw * -q.z + ix * -q.y - iy * -q.x;
    
    self.x = x;
    self.y = y;
    self.z = z;

    return self;
end

--- Multiplies the vector by the given matrix.
--- @param mat Matrix The matrix to multiply the vector by.
--- @return table self The updated vector.
function Vector3:MultiplyMatrix(mat)
    local x = (mat.m00 * self.x) + (mat.m01 * self.y) + (mat.m02 * self.z);
    local y = (mat.m10 * self.x) + (mat.m11 * self.y) + (mat.m12 * self.z);
    local z = (mat.m20 * self.x) + (mat.m21 * self.y) + (mat.m22 * self.z);

    self.x = x;
    self.y = y;
    self.z = z;

    return self;
end

--- Calculates the Manhattan distance between two Vector3 points.
--- @param a Vector3 The first Vector3 point.
--- @param b Vector3 The second Vector3 point.
--- @return number distance The Manhattan distance between the two points.
function Vector3.ManhattanDistance(a, b)
    return math.abs(a.x - b.x) + math.abs(a.y - b.y) + math.abs(a.z - b.z);
end

--- Calculates the Manhattan distance between two points in 3D space.
--- @param aX number The x-coordinate of the first point.
--- @param aY number The y-coordinate of the first point.
--- @param aZ number The z-coordinate of the first point.
--- @param bX number The x-coordinate of the second point.
--- @param bY number The y-coordinate of the second point.
--- @param bZ number The z-coordinate of the second point.
--- @return number distance The Manhattan distance between the two points.
function Vector3.ManhattanDistanceP(aX, aY, aZ, bX, bY, bZ)
    return math.abs(aX - bX) + math.abs(aY - bY) + math.abs(aZ - bZ);
end

--- Calculates the dot product of two vectors.
--- @param a Vector3 The first vector.
--- @param b Vector3 The second vector.
--- @return number dotproduct The dot product of the two vectors.
function Vector3.DotProduct(a, b)
    return a.x * b.x + a.y * b.y + a.z * b.z;
end

--- Interpolates between two Vector3 values.
--- @param a Vector3 The starting Vector3.
--- @param b Vector3 The ending Vector3.
--- @param t number The interpolation factor (between 0 and 1).
--- @return Vector3 output The interpolated Vector3.
function Vector3.Interpolate(a, b, t)
    local output = Vector3:New();
    local ax = a.x;
    local ay = a.y;
    local az = a.z;
    output.x = ax + t * (b.x - ax);
    output.y = ay + t * (b.y - ay);
    output.z = az + t * (b.z - az);
    return output;
end

--- Rotates the Vector3 object around a specified pivot point.
--- @param pivot Vector3 The pivot point to rotate around.
--- @param rotation Vector3 The rotation angles around the x, y, and z axes.
--- @return Vector3 self The rotated Vector3 object.
function Vector3:RotateAroundPivot(pivot, rotation)
    -- Translate the object and pivot to the origin
    self.x = self.x - pivot.x;
    self.y = self.y - pivot.y;
    self.z = self.z - pivot.z;

    -- Apply rotation around the x-axis
    local rx = rotation.x;
    local cos_rx = math.cos(rx);
    local sin_rx = math.sin(rx);
    local x_rotated = self.x;
    local y_rotated = cos_rx * self.y - sin_rx * self.z;
    local z_rotated = sin_rx * self.y + cos_rx * self.z;

    -- Apply rotation around the y-axis
    local ry = rotation.y;
    local cos_ry = math.cos(ry);
    local sin_ry = math.sin(ry);
    local x_rotated_y = cos_ry * x_rotated + sin_ry * z_rotated;
    local y_rotated_y = y_rotated;
    local z_rotated_y = -sin_ry * x_rotated + cos_ry * z_rotated;

    -- Apply rotation around the z-axis
    local rz = rotation.z;
    local cos_rz = math.cos(rz);
    local sin_rz = math.sin(rz);
    local x_rotated_z = cos_rz * x_rotated_y - sin_rz * y_rotated_y;
    local y_rotated_z = sin_rz * x_rotated_y + cos_rz * y_rotated_y;
    local z_rotated_z = z_rotated_y;

    -- Translate the object back to its original position
    self.x = x_rotated_z + pivot.x;
    self.y = y_rotated_z + pivot.y;
    self.z = z_rotated_z + pivot.z;

    return self;
end

--- Calculates the direction vector between two vectors.
--- @param a Vector3 The starting vector.
--- @param b Vector3 The ending vector.
--- @return Vector3 direction The direction vector from `a` to `b`.
function Vector3.GetDirectionVectorBetweenVectors(a, b)
    local direction = Vector3:New(b.x - a.x, b.y - a.y, b.z - a.z);
    direction:Normalize();
    return direction;
end

--- Inverts the values of the Vector3 object.
--- @return Vector3 self The inverted Vector3 object.
function Vector3:Invert()
    self.x = -self.x;
    self.y = -self.y;
    self.z = -self.z;
    return self;
end

--- Converts Euler angles to a direction vector.
--- @return Vector3 self The updated Vector3 object converted to direction vector.
function Vector3:EulerToDirection()
    -- Calculate direction vector components
    local vx = math.sin(self.y) * math.cos(self.x)
    local vy = math.sin(self.x)
    local vz = math.cos(self.y) * math.cos(self.x)

    self.x = vx;
    self.y = vy;
    self.z = vz;

    return self;
end

--- Calculates the Euclidean distance between two 3D vectors.
--- @param vecA Vector3 The first vector.
--- @param vecB Vector3 The second vector.
--- @return number distance The distance between the two vectors.
function Vector3.Distance(vecA, vecB)
    local dx = vecB.x - vecA.x;
    local dy = vecB.y - vecA.y;
    local dz = vecB.z - vecA.z;
    return math.sqrt(dx^2 + dy^2 + dz^2);
end

--- Calculates the length of the vector.
--- @return number length The length of the vector.
function Vector3:Length()
    return math.sqrt(self.x^2 + self.y^2 + self.z^2);
end

--- Normalizes the vector, making it a unit vector.
--- If the magnitude is zero, the vector will be set to a zero vector.
--- @return Vector3 self The normalized vector.
function Vector3:Normalize()
    local magnitude = math.sqrt(self.x^2 + self.y^2 + self.z^2)
    
    if (magnitude ~= 0) then
        self.x = self.x / magnitude;
        self.y = self.y / magnitude;
        self.z = self.z / magnitude;
    else
        -- Handle the case where the vector is a zero vector (magnitude is zero)
        self.x = 0;
        self.y = 0;
        self.z = 0;
    end

    return self;
end

--- Projects a vector onto another vector.
--- @param vector Vector3 The vector to be projected.
--- @param onto Vector3 The vector onto which the projection is performed.
--- @return Vector3 p The projected vector.
function Vector3.Project(vector, onto)
    --b * a.dot(b)
    local sqrMag = Vector3.DotProduct(onto, onto);
    if sqrMag < 0.000001 then
        return Vector3:New(0, 0, 0);
    else
        local p = Vector3:New();
        p:SetVector3(onto);
        p:Scale(Vector3.DotProduct(vector, onto) / sqrMag);
        return p;
    end
end

--- Calculates the cross product of two vectors and updates the current vector with the result.
--- @param v Vector3 The vector to calculate the cross product with.
function Vector3:CrossProduct(v)
    local x = self.y * v.z - self.z * v.y;
    local y = self.z * v.x - self.x * v.z;
    local z = self.x * v.y - self.y * v.x;

    self.x = x;
    self.y = y;
    self.z = z;
end

--- Linearly interpolates between two Vector3 values.
---@param a Vector3: The starting Vector3.
---@param b Vector3: The ending Vector3.
---@param t number: The interpolation factor (between 0 and 1).
function Vector3:Lerp(a, b, t)
    self.x = a.x * (1 - t) + b.x * t;
    self.y = a.y * (1 - t) + b.y * t;
    self.z = a.z * (1 - t) + b.z * t;
end

--- Returns a string representation of the Vector3 object.
--- @return string string The string representation of the Vector3 object.
Vector3.__tostring = function(self)
    return string.format("Vector3( %.3f, %.3f, %.3f )", self.x, self.y, self.z);
end


--- Checks if two Vector3 objects are equal.
--- @param a Vector3 The first Vector3 object.
--- @param b Vector3 The second Vector3 object.
--- @return boolean equal if the Vector3 objects are equal, false otherwise.
Vector3.__eq = function(a,b)
    return a.x == b.x and a.y == b.y and a.z == b.z;
end


--- Adds two Vector3 objects together and returns a new Vector3 object.
--- @param v1 Vector3 The first Vector3 object.
--- @param v2 Vector3 The second Vector3 object.
--- @return Vector3 result The resulting Vector3 object.
Vector3.__add = function(v1, v2)
	return Vector3:New(v1.x + v2.x, v1.y + v2.y, v1.z + v2.z);
end

-- This function is used as the __index metamethod for the Vector3 table.
-- It is called when a key is not found in the Vector3 table.
Vector3.__index = function(t,k)
    local var = rawget(Vector3, k)
        
    if var == nil then							
        var = rawget(fields, k)
        
        if var ~= nil then
            return var(t)	
        end
    end
    
    return var
end

--- Up Vector (0, 0, 1)
Vector3.up = Vector3:New(0, 0, 1);

--- Forward Vector (1, 0, 0)
Vector3.forward = Vector3:New(1, 0, 0);

--- Right Vector (0, 1, 0)
Vector3.right = Vector3:New(0, 1, 0);

--- Zero Vector (0, 0, 0)
Vector3.zero = Vector3:New(0, 0, 0);