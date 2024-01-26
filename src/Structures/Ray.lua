local Math = SceneMachine.Math;
local Vector3 = SceneMachine.Vector3;
local Quaternion = SceneMachine.Quaternion;

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

function Ray:IntersectsOBB(obb)
    if (obb.rotation == Quaternion.identity) then
        -- AABB
        local tMin = obb:GetMin();
        tMin:Subtract(self.origin);
        tMin:Divide(self.direction);

        local tMax = obb:GetMax();
        tMax:Subtract(self.origin);
        tMax:Divide(self.direction);

        local t1 = Vector3:New(math.min(tMin.x, tMax.x), math.min(tMin.y, tMax.y), math.min(tMin.z, tMax.z));
        local t2 = Vector3:New(math.max(tMin.x, tMax.x), math.max(tMin.y, tMax.y), math.max(tMin.z, tMax.z));

        local tNear = math.max(math.max(t1.x, t1.y), t1.z);
        local tFar = math.min(math.min(t2.x, t2.y), t2.x);
        return tNear <= tFar;
        --local tMin = (this.min - ray.origin) / ray.direction;
        --local tMax = (this.max - ray.origin) / ray.direction;
        --local t1 = new Vector3(math.min(tMin.X, tMax.X), math.min(tMin.Y, tMax.Y), math.min(tMin.Z, tMax.Z));
        --local t2 = new Vector3(math.max(tMin.X, tMax.X), math.max(tMin.Y, tMax.Y), math.max(tMin.Z, tMax.Z));
        --float tNear = math.max(math.max(t1.X, t1.Y), t1.Z);
        --float tFar = math.min(math.min(t2.X, t2.Y), t2.Z);
        --return new Vector2(tNear, tFar);
    else
        -- OBB
        --[[
        -- Transform the ray into the local space of the OBB
        Vector3 rayOrigin = ray.origin - worldPosition;
        Vector3 rayDirection = ray.direction;
        Quaternion inverseOrientation = Quaternion.Invert(this.orientation);
        rayOrigin = inverseOrientation * rayOrigin;
        rayDirection = inverseOrientation * rayDirection;
        rayOrigin /= scale;

        var min = (this.center - ((this.size) * 0.5f));
        var max = (this.center + ((this.size) * 0.5f));

        Vector3 tMin = (min - rayOrigin) / rayDirection;
        Vector3 tMax = (max - rayOrigin) / rayDirection;
        Vector3 t1 = new Vector3(math.min(tMin.X, tMax.X), math.min(tMin.Y, tMax.Y), math.min(tMin.Z, tMax.Z));
        Vector3 t2 = new Vector3(math.max(tMin.X, tMax.X), math.max(tMin.Y, tMax.Y), math.max(tMin.Z, tMax.Z));
        float tNear = math.max(math.max(t1.X, t1.Y), t1.Z);
        float tFar = math.min(math.min(t2.X, t2.Y), t2.Z);
        return new Vector2(tNear, tFar);
        --]]
    end
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