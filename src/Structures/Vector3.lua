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
end

function Vector3:Add(v)
    self.x = self.x + v.x;
    self.y = self.y + v.y;
    self.z = self.z + v.z;
end

function Vector3:Subtract(v)
    self.x = self.x - v.x;
    self.y = self.y - v.y;
    self.z = self.z - v.z;
end

function Vector3.ManhattanDistance(a, b)
    return math.abs(a.x - b.x) + math.abs(a.y - b.y) + math.abs(a.z - b.z);
end

function Vector3.ManhattanDistanceP(aX, aY, aZ, bX, bY, bZ)
    return math.abs(aX - bX) + math.abs(aY - bY) + math.abs(aZ - bZ);
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

function Vector3:Lerp(a, b, t)
    self.x = a.x * (1 - t) + b.x * t;
    self.y = a.y * (1 - t) + b.y * t;
    self.z = a.z * (1 - t) + b.z * t;
end

Vector3.__tostring = function(self)
	return string.format("Vector3( %.3f, %.3f, %.3f )", self.x, self.y, self.z);
end

Vector3.__eq = function(a,b)
    return a.x == b.x and a.y == b.x and a.z == b.z;
end

-- Set multiply "*" behaviour
--Vector3.__mul = function( m1,m2 )
--	if getmetatable( m1 ) ~= matrix_meta then
--		return matrix.mulnum( m2,m1 )
--	elseif getmetatable( m2 ) ~= matrix_meta then
--		return matrix.mulnum( m1,m2 )
--	end
--	return matrix.mul( m1,m2 )
--end

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