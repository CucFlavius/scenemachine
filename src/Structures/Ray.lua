local Math = SceneMachine.Math;
local Vector3 = SceneMachine.Vector3;
local epsilon = 1e-6

SceneMachine.Ray = 
{
    origin = nil,
    direction = nil
}

local Ray = SceneMachine.Ray;

setmetatable(Ray, Ray)

local fields = {}

function Ray:New(origin, direction)
	local v = 
    {
        origin = origin or Vector3:New(),
        direction = direction or Vector3:New()
    };

	setmetatable(v, Ray)
	return v
end

function Ray:Set(origin, direction)
    self.origin.x = origin.x;
    self.origin.y = origin.y;
    self.origin.z = origin.z;

    self.direction.x = direction.x;
    self.direction.y = direction.y;
    self.direction.z = direction.z;
end

function Ray:SetRay(ray)
    self.origin.x = ray.origin.x;
    self.origin.y = ray.origin.y;
    self.origin.z = ray.origin.z;

    self.direction.x = ray.direction.x;
    self.direction.y = ray.direction.y;
    self.direction.z = ray.direction.z;
end

function Ray:Get()
    return self.origin, self.direction;
end

function Ray:PlaneIntersection(planePoint, planeNormal)
    -- Ensure that the ray and plane are not parallel
    local dotProduct = Vector3.DotProduct(planeNormal, self.direction);
    if math.abs(dotProduct) < epsilon then
        return nil  -- Ray and plane are parallel, no intersection
    end

    -- Calculate the parameter t for the intersection point
    local t = ((planeNormal.x * (planePoint.x - self.origin.x) +
                 planeNormal.y * (planePoint.y - self.origin.y) +
                 planeNormal.z * (planePoint.z - self.origin.z)) / dotProduct)

    -- Ensure the intersection point is in front of the ray origin
    if t < 0 then
        return nil  -- Intersection point is behind the ray origin
    end

    -- Calculate the intersection point
    local intersectionPoint = Vector3:New(
        self.origin.x + (t * self.direction.x),
        self.origin.y + (t * self.direction.y),
        self.origin.z + (t * self.direction.z)
    )

    return intersectionPoint;
end

Ray.__tostring = function(self)
	return string.format("Ray( O( %.3f, %.3f, %.3f ), D( %.3f, %.3f, %.3f ) )",
        self.origin.x, self.origin.y, self.origin.z,
        self.direction.x, self.direction.y, self.direction.z);
end

Ray.__eq = function(a,b)
    return a.origin.x == b.origin.x and a.origin.y == b.origin.x and a.origin.z == b.origin.z and
            a.direction.x == b.direction.x and a.direction.y == b.direction.x and a.direction.z == b.direction.z;
end

Ray.__index = function(t,k)
	local var = rawget(Ray, k)
		
	if var == nil then							
		var = rawget(fields, k)
		
		if var ~= nil then
			return var(t)	
		end
	end
	
	return var
end