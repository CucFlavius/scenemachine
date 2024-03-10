local Math = SceneMachine.Math;

SceneMachine.Vector3 = 
{
    x = 0,
    y = 0,
    z = 0
}

local Vector3 = SceneMachine.Vector3;

setmetatable(Vector3, Vector3)

local fields = {}

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

function Vector3:Set(x, y, z)
    self.x = x or 0;
    self.y = y or 0;
    self.z = z or 0;
end

function Vector3:SetVector3(v)
    self.x = v.x;
    self.y = v.y;
    self.z = v.z;
end

function Vector3:Get()
    return self.x, self.y, self.z;
end

-- Vector3 * float
function Vector3:Scale(f)
    self.x = self.x * f;
    self.y = self.y * f;
    self.z = self.z * f;
    return self;
end

function Vector3:Add(v)
    self.x = self.x + v.x;
    self.y = self.y + v.y;
    self.z = self.z + v.z;
    return self
end

function Vector3:Subtract(v)
    self.x = self.x - v.x;
    self.y = self.y - v.y;
    self.z = self.z - v.z;
    return self;
end

function Vector3:Multiply(v)
    self.x = self.x * v.x;
    self.y = self.y * v.y;
    self.z = self.z * v.z;
    return self;
end

function Vector3:Divide(v)
    self.x = self.x / v.x;
    self.y = self.y / v.y;
    self.z = self.z / v.z;
    return self;
end

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

function Vector3:MultiplyMatrix(mat)

    local x = (mat.m00 * self.x) + (mat.m01 * self.y) + (mat.m02 * self.z);
    local y = (mat.m10 * self.x) + (mat.m11 * self.y) + (mat.m12 * self.z);
    local z = (mat.m20 * self.x) + (mat.m21 * self.y) + (mat.m22 * self.z);

    self.x = x;
    self.y = y;
    self.z = z;

    return self;
end

function Vector3.ManhattanDistance(a, b)
    return math.abs(a.x - b.x) + math.abs(a.y - b.y) + math.abs(a.z - b.z);
end

function Vector3.ManhattanDistanceP(aX, aY, aZ, bX, bY, bZ)
    return math.abs(aX - bX) + math.abs(aY - bY) + math.abs(aZ - bZ);
end

function Vector3.DotProduct(a, b)
    return a.x * b.x + a.y * b.y + a.z * b.z;
end

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

function Vector3:EulerToDirection()
    -- Calculate direction vector components
    local vx = math.cos(self.x) * math.cos(self.y)
    local vy = math.sin(self.x)
    local vz = math.cos(self.x) * math.sin(self.y)

    --local vx = math.cos(self.x) * math.cos(self.y)
    --local vy = math.sin(self.y)
    --local vz = math.sin(self.x) * math.cos(self.y)

    self.x = vx;
    self.y = vy;
    self.z = vz;

    return self;
end

function Vector3:Length()
    return math.sqrt(self.x^2 + self.y^2 + self.z^2);
end

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

function Vector3:CrossProduct(v)
    local x = self.y * v.z - self.z * v.y;
    local y = self.z * v.x - self.x * v.z;
    local z = self.x * v.y - self.y * v.x;

    self.x = x;
    self.y = y;
    self.z = z;
end

function Vector3:Lerp(a, b, t)
    self.x = a.x * (1 - t) + b.x * t;
    self.y = a.y * (1 - t) + b.y * t;
    self.z = a.z * (1 - t) + b.z * t;
end

Vector3.__tostring = function(self)
	return string.format("Vector3( %.3f, %.3f, %.3f )", self.x, self.y, self.z);
end

Vector3.__eq = function(a,b)
    return a.x == b.x and a.y == b.y and a.z == b.z;
end

-- Set add "+" behaviour
Vector3.__add = function( v1,v2 )
	return Vector3:New(v1.x + v2.x, v1.y + v2.y, v1.z + v2.z);
end

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

Vector3.up = Vector3:New(0, 0, 1);
Vector3.forward = Vector3:New(1, 0, 0);
Vector3.right = Vector3:New(0, 1, 0);
Vector3.zero = Vector3:New(0, 0, 0);