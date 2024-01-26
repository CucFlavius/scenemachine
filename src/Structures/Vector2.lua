local Math = SceneMachine.Math;

SceneMachine.Vector2 = 
{
    x = 0,
    y = 0
}

local Vector2 = SceneMachine.Vector2;

setmetatable(Vector2, Vector2)

local fields = {}

function Vector2:New(x, y)
	local v = 
    {
        x = x or 0,
        y = y or 0
    };

	setmetatable(v, Vector2)
	return v
end

function Vector2:Set(x, y)
    self.x = x or 0;
    self.y = y or 0;
end

function Vector2:SetVector2(v)
    self.x = v.x;
    self.y = v.y;
end

function Vector2:Get()
    return self.x, self.y;
end

-- Vector2 * float
function Vector2:Scale(f)
    self.x = self.x * f;
    self.y = self.y * f;
end

function Vector2:Add(v)
    self.x = self.x + v.x;
    self.y = self.y + v.y;
end

function Vector2:Subtract(v)
    self.x = self.x - v.x;
    self.y = self.y - v.y;
end

function Vector2:Multiply(v)
    self.x = self.x * v.x;
    self.y = self.y * v.y;
end

function Vector2:Divide(v)
    self.x = self.x / v.x;
    self.y = self.y / v.y;
end

function Vector2:MultiplyMatrix(mat)

    local x = (mat.m00 * self.x) + (mat.m01 * self.y);
    local y = (mat.m10 * self.x) + (mat.m11 * self.y);

    self.x = x;
    self.y = y;

    return self;
end

function Vector2.ManhattanDistance(a, b)
    return math.abs(a.x - b.x) + math.abs(a.y - b.y);
end

function Vector2.ManhattanDistanceP(aX, aY, bX, bY)
    return math.abs(aX - bX) + math.abs(aY - bY);
end

function Vector2.DotProduct(a, b)
    return a.x * b.x + a.y * b.y;
end

function Vector2:Lerp(a, b, t)
    self.x = a.x * (1 - t) + b.x * t;
    self.y = a.y * (1 - t) + b.y * t;
end

Vector2.__tostring = function(self)
	return string.format("Vector2( %.3f, %.3f )", self.x, self.y);
end

Vector2.__eq = function(a,b)
    return a.x == b.x and a.y == b.y;
end

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

Vector2.zero = Vector2:New(0, 0);