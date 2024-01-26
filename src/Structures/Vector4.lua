local Math = SceneMachine.Math;

SceneMachine.Vector4 = 
{
    x = 0,
    y = 0,
    z = 0,
    w = 0
}

local Vector4 = SceneMachine.Vector4;

setmetatable(Vector4, Vector4)

local fields = {}

function Vector4:New(x, y, z)
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

function Vector4:Set(x, y, z, w)
    self.x = x or 0;
    self.y = y or 0;
    self.z = z or 0;
    self.w = w or 0;
end

function Vector4:SetVector4(v)
    self.x = v.x;
    self.y = v.y;
    self.z = v.z;
    self.w = v.w;
end

function Vector4:Get()
    return self.x, self.y, self.z, self.w;
end

-- Vector4 * float
function Vector4:Scale(f)
    self.x = self.x * f;
    self.y = self.y * f;
    self.z = self.z * f;
    self.w = self.w * f;
end

function Vector4:Add(v)
    self.x = self.x + v.x;
    self.y = self.y + v.y;
    self.z = self.z + v.z;
    self.w = self.w + v.w;
end

function Vector4:Subtract(v)
    self.x = self.x - v.x;
    self.y = self.y - v.y;
    self.z = self.z - v.z;
    self.w = self.w - v.w;
end

function Vector4:Multiply(v)
    self.x = self.x * v.x;
    self.y = self.y * v.y;
    self.z = self.z * v.z;
    self.w = self.w * v.w;
end

function Vector4:Divide(v)
    self.x = self.x / v.x;
    self.y = self.y / v.y;
    self.z = self.z / v.z;
    self.w = self.w / v.w;
end

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

function Vector4.DotProduct(a, b)
    return a.x * b.x + a.y * b.y + a.z * b.z + a.w * b.w;
end

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

function Vector4:Lerp(a, b, t)
    self.x = a.x * (1 - t) + b.x * t;
    self.y = a.y * (1 - t) + b.y * t;
    self.z = a.z * (1 - t) + b.z * t;
    self.w = a.w * (1 - t) + b.w * t;
end

Vector4.__tostring = function(self)
	return string.format("Vector4( %.3f, %.3f, %.3f )", self.x, self.y, self.z);
end

Vector4.__eq = function(a,b)
    return a.x == b.x and a.y == b.x and a.z == b.z and a.w == b.w;
end

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

Vector4.zero = Vector4:New(0, 0, 0, 0);