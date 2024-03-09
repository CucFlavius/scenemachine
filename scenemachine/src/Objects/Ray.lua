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

-- NOT TESTED --
function Ray:NearestPointOnLine(linePoint, lineDirection)
    local t = Vector3.DotProduct(lineDirection, self.direction)

    -- Check if the line and ray are not parallel
    if math.abs(t) > 1e-6 then
        local lineToRay = Vector3:New();
        lineToRay:SetVector3(self.origin);
        lineToRay:Subtract(linePoint);
        local u = Vector3.DotProduct(lineToRay, lineDirection) / t

        -- Ensure that the point is along the ray (u >= 0)
        if u >= 0 then
            local intersectionPoint = Vector3:New();
            intersectionPoint:SetVector3(lineDirection);
            intersectionPoint:Scale(u);
            intersectionPoint:Add(linePoint);

            return intersectionPoint
        end
    end

    -- If the line and ray are parallel or the intersection point is behind the ray origin, return the ray origin
    return self.origin
end

-- NOT TESTED --
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
    --t = abs(t);

    -- Calculate the intersection point
    local intersectionPoint = Vector3:New(
        self.origin.x + (t * self.direction.x),
        self.origin.y + (t * self.direction.y),
        self.origin.z + (t * self.direction.z)
    )

    return intersectionPoint;
end

function Ray:IntersectsBoundingBox(bb, position, rotation, scale)
    -- Transform ray to local space
    local inverseOrientation = Quaternion:New();
    inverseOrientation:SetFromEuler(rotation);
    inverseOrientation:Invert();

    local rayOrigin = Vector3:New();
    rayOrigin:SetVector3(self.origin);
    rayOrigin:Subtract(position);
    rayOrigin:MultiplyQuaternion(inverseOrientation);
    rayOrigin:Scale(1.0/scale);

    local rayDirection = Vector3:New();
    rayDirection:SetVector3(self.direction);
    rayDirection:MultiplyQuaternion(inverseOrientation);

    -- Check for regular AABB intersection
    local tMin = bb:GetMin();
    tMin:Subtract(rayOrigin);
    tMin:Divide(rayDirection);

    local tMax = bb:GetMax();
    tMax:Subtract(rayOrigin);
    tMax:Divide(rayDirection);
    local t1 = Vector3:New(math.min(tMin.x, tMax.x), math.min(tMin.y, tMax.y), math.min(tMin.z, tMax.z));
    local t2 = Vector3:New(math.max(tMin.x, tMax.x), math.max(tMin.y, tMax.y), math.max(tMin.z, tMax.z));
    local tNear = math.max(math.max(t1.x, t1.y), t1.z);
    local tFar = math.min(math.min(t2.x, t2.y), t2.z);

    return tNear, tFar;
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