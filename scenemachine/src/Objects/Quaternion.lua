local Math = SceneMachine.Math;
local Vector3 = SceneMachine.Vector3;

SceneMachine.Quaternion = 
{
    x = 0,
    y = 0,
    z = 0,
    w = 1
}

--- @class Quaternion
local Quaternion = SceneMachine.Quaternion;

setmetatable(Quaternion, Quaternion)

local fields = {}

--- Creates a new Quaternion object.
--- @param x? number (optional) The x component of the quaternion. Defaults to 0 if not provided.
--- @param y? number (optional) The y component of the quaternion. Defaults to 0 if not provided.
--- @param z? number (optional) The z component of the quaternion. Defaults to 0 if not provided.
--- @param w? number (optional) The w component of the quaternion. Defaults to 1 if not provided.
--- @return Quaternion v The new Quaternion object.
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

--- Sets the values of the quaternion.
--- @param x? number The x component of the quaternion. Defaults to 0 if not provided.
--- @param y? number The y component of the quaternion. Defaults to 0 if not provided.
--- @param z? number The z component of the quaternion. Defaults to 0 if not provided.
--- @param w? number The w component of the quaternion. Defaults to 1 if not provided.
function Quaternion:Set(x, y, z, w)
    self.x = x or 0;
    self.y = y or 0;
    self.z = z or 0;
    self.w = w or 1;
end

--- Sets the quaternion values based on the provided vector.
--- @param quaternion Quaternion The vector or quaternion containing the x, y, z, and w values.
function Quaternion:SetQuaternion(quaternion)
    self.x = quaternion.x;
    self.y = quaternion.y;
    self.z = quaternion.z;
    self.w = quaternion.w;
end

--- Get the components of the quaternion.
--- @return number x, number y, number z, number w The x, y, z, and w components of the quaternion.
function Quaternion:Get()
    return self.x, self.y, self.z, self.w;
end

--- Converts a quaternion to a direction vector.
--- If no forward vector is provided, the default forward vector is (0, 0, 1).
--- @param forward? Vector3 (optional) The forward vector to rotate.
--- @return Vector3 rotatedVector The rotated forward vector, normalized.
function Quaternion:ToDirectionVector(forward)
    local rotatedForward = self:MultiplyVector(forward)
    return rotatedForward:Normalize()
end

--- Converts the quaternion to Euler angles.
--- @return Vector3 rotation The Euler angles representation of the quaternion.
function Quaternion:ToEuler()
    local rx = math.atan2(2 * (self.w * self.x + self.y * self.z), 1 - 2 * (self.x^2 + self.y^2))
    local ry = math.asin(2 * (self.w * self.y - self.z * self.x))
    local rz = math.atan2(2 * (self.w * self.z + self.x * self.y), 1 - 2 * (self.y^2 + self.z^2))
    
    return Vector3:New(rx, ry, rz);
end

--- Sets the quaternion from Euler angles.
--- @param euler Vector3 The Euler angles as a Vector3 with x, y, and z components.
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

--- Linearly interpolates between two quaternions.
--- @param a Quaternion: The starting quaternion.
--- @param b Quaternion: The ending quaternion.
--- @param t number: The interpolation factor (between 0 and 1).
function Quaternion:Lerp(a, b, t)
    self.x = a.x * (1 - t) + b.x * t;
    self.y = a.y * (1 - t) + b.y * t;
    self.z = a.z * (1 - t) + b.z * t;
    self.w = a.w * (1 - t) + b.w * t;
end

--- Inverts the quaternion.
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

--- Multiplies the current quaternion with another quaternion.
--- @param q2 Quaternion The quaternion to multiply with.
function Quaternion:Multiply(q2)
    local w = self.w * q2.w - self.x * q2.x - self.y * q2.y - self.z * q2.z;
    local x = self.w * q2.x + self.x * q2.w - self.y * q2.z + self.z * q2.y;
    local y = self.w * q2.y + self.x * q2.z + self.y * q2.w - self.z * q2.x;
    local z = self.w * q2.z - self.x * q2.y + self.y * q2.x + self.z * q2.w;

    self.x = x;
    self.y = y;
    self.z = z;
    self.w = w;
end

--- Normalizes the quaternion.
function Quaternion:Normalize()
    local magnitude = math.sqrt(self.x ^ 2 + self.y ^ 2 + self.z ^ 2 + self.w ^ 2);
    self.x = self.x / magnitude;
    self.y = self.y / magnitude;
    self.z = self.z / magnitude;
    self.w = self.w / magnitude;
end

--- Rotate the quaternion around a specified axis by a given angle.
--- @param axis Vector3 The axis to rotate around (a Vector3).
--- @param angle number The angle of rotation in radians (a number).
function Quaternion:RotateAroundAxis(axis, angle)

    -- Calculate half angle
    local halfAngle = angle * 0.5

    -- Calculate sine and cosine of half angle
    local sinHalfAngle = math.sin(halfAngle)
    local cosHalfAngle = math.cos(halfAngle)

    -- Construct the quaternion
    local rotationQuat = Quaternion:New(axis.x * sinHalfAngle, axis.y * sinHalfAngle, axis.z * sinHalfAngle, cosHalfAngle)
    self:Multiply(rotationQuat);
end

--- Returns the conjugate of the quaternion.
---@return Quaternion conjugated The conjugate of the quaternion.
function Quaternion:Conjugate()
    return Quaternion:New(-self.x, -self.y, -self.z, self.w)
end

--- Multiplies the quaternion with a vector.
--- This operation is equivalent to Quat * V * Quat^-1.
--- @param vector Vector3 The vector to be multiplied.
--- @return Vector3 multipliedVector The resulting vector.
function Quaternion:MultiplyVector(vector)
    local u = Quaternion:New(vector.x, vector.y, vector.z, 0);
    local conjugate = self:Conjugate();
    u:Multiply(conjugate);
    local result = Quaternion:New();
    result:SetQuaternion(self);
    result:Multiply(u);
    return Vector3:New(result.x, result.y, result.z);
end

--- Interpolates between two quaternions.
--- http://jsperf.com/quaternion-slerp-implementations
--- @param a Quaternion The starting quaternion.
--- @param b Quaternion The ending quaternion.
--- @param t number The interpolation factor (between 0 and 1).
--- @return Quaternion The interpolated quaternion.
function Quaternion.Interpolate(a, b, t)
    local output = Quaternion:New();
    local ax = a.x;
    local ay = a.y;
    local az = a.z;
    local aw = a.w;
    local bx = b.x;
    local by = b.y;
    local bz = b.z;
    local bw = b.w;
    local omega, cosom, sinom, scale0, scale1;

    -- calc cosine
    cosom = ax * bx + ay * by + az * bz + aw * bw;

    -- adjust signs (if necessary)
    if (cosom < 0.0) then
        cosom = -cosom;
        bx = -bx;
        by = -by;
        bz = -bz;
        bw = -bw;
    end

    -- calculate coefficients
    if ((1.0 - cosom) > 0.000001) then
        -- standard case (slerp)
        omega = math.acos(cosom);
        sinom = math.sin(omega);
        scale0 = math.sin((1.0 - t) * omega) / sinom;
        scale1 = math.sin(t * omega) / sinom;
    else
        -- "from" and "to" quaternions are very close 
        --  ... so we can do a linear interpolation
        scale0 = 1.0 - t;
        scale1 = t;
    end

    -- calculate final values
    output.x = scale0 * ax + scale1 * bx;
    output.y = scale0 * ay + scale1 * by;
    output.z = scale0 * az + scale1 * bz;
    output.w = scale0 * aw + scale1 * bw;

    return output;
end

--- Converts the Quaternion object to a string representation.
--- @return string string The string representation of the Quaternion object.
Quaternion.__tostring = function(self)
    return string.format("Quaternion( %.3f, %.3f, %.3f, %.3f )", self.x, self.y, self.z, self.w);
end

--- Checks if two Quaternions are equal.
--- @param a Quaternion The first Quaternion.
--- @param b Quaternion The second Quaternion.
--- @return boolean True if the Quaternions are equal, false otherwise.
Quaternion.__eq = function(a,b)
    return a.x == b.x and a.y == b.x and a.z == b.z and a.w == b.w;
end

-- This function is used as the __index metamethod for the Quaternion table.
-- It is called when a key is not found in the Quaternion table.
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

--- Identity Quaternion (0, 0, 0, 1)
Quaternion.identity = Quaternion:New(0, 0, 0, 1);