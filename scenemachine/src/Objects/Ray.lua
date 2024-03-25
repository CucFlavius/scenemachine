local Vector3 = SceneMachine.Vector3;
local Quaternion = SceneMachine.Quaternion;

local epsilon = 1e-6

SceneMachine.Ray =
{
    origin = nil,
    direction = nil
}

--- @class Ray
local Ray = SceneMachine.Ray;

setmetatable(Ray, Ray)

local fields = {}

--- Creates a new Ray object.
--- @param origin? Vector3 (optional) The origin point of the ray.
--- @param direction? Vector3 (optional) The direction of the ray.
--- @return Ray v The new Ray object.
function Ray:New(origin, direction)
    local v = 
    {
        origin = origin or Vector3:New(),
        direction = direction or Vector3:New()
    };

    setmetatable(v, Ray)
    return v
end

--- Sets the origin and direction of the ray.
--- @param origin Vector3 The origin of the ray.
--- @param direction Vector3 The direction of the ray.
function Ray:Set(origin, direction)
    if (not self.origin) then
        self.origin = Vector3:New();
    end
    if (not self.direction) then
        self.direction = Vector3:New();
    end

    self.origin.x = origin.x;
    self.origin.y = origin.y;
    self.origin.z = origin.z;

    self.direction.x = direction.x;
    self.direction.y = direction.y;
    self.direction.z = direction.z;
end

--- Sets the properties of the Ray object.
--- @param ray Ray The ray object containing the origin and direction.
function Ray:SetRay(ray)
    self.origin.x = ray.origin.x;
    self.origin.y = ray.origin.y;
    self.origin.z = ray.origin.z;

    self.direction.x = ray.direction.x;
    self.direction.y = ray.direction.y;
    self.direction.z = ray.direction.z;
end

--- Returns the origin and direction of the ray.
--- @return Vector3 origin, Vector3 direction The origin and direction of the ray.
function Ray:Get()
    return self.origin, self.direction;
end

--- Calculates the intersection point between a ray and a plane.
--- @param planePoint Vector3 The point on the plane.
--- @param planeNormal Vector3 The normal vector of the plane.
--- @return Vector3 intersectionPoint The intersection point, or nil if there is no intersection.
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

--- Calculates the closest approach point between a ray and a line.
--- The algorithm used is based on the closest points between two lines.
--- https://math.stackexchange.com/questions/1993953/closest-points-between-two-lines
--- @param line_position Vector3 The position of a point on the line.
--- @param line_normal Vector3 The normal vector of the line.
--- @return Vector3 closest_approach The closest approach point between the ray and the line.
function Ray:LineIntersection(line_position, line_normal)
    local pos_diff = Vector3:New();
    pos_diff:SetVector3(line_position);
    pos_diff:Subtract(self.origin);

    local cross_normal = Vector3:New();
    cross_normal:SetVector3(line_normal);
    cross_normal:CrossProduct(self.direction);
    cross_normal:Normalize();

    local rejection = Vector3:New();
    rejection:SetVector3(pos_diff);
    rejection:Subtract(Vector3.Project(pos_diff, self.direction));
    rejection:Subtract(Vector3.Project(pos_diff, cross_normal));

    local rejectionNorm = Vector3:New();
    rejectionNorm:SetVector3(rejection);
    rejectionNorm:Normalize();

    local distance_to_line_pos = rejection:Length() / Vector3.DotProduct(line_normal, rejectionNorm);
    local closest_approach = Vector3:New();
    closest_approach:SetVector3(line_position);
    line_normal:Scale(distance_to_line_pos);
    closest_approach:Subtract(line_normal);

    return closest_approach
end

--- Checks if the ray intersects with a bounding box in local space.
--- @param bb BoundingBox The bounding box to check intersection with.
--- @param position Vector3 The position of the bounding box in world space.
--- @param rotation Vector3 The rotation of the bounding box in world space.
--- @param scale Vector3 The scale of the bounding box in world space.
--- @return number tNear, number tFar The distances along the ray where the intersection occurs (tNear, tFar).
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

--- Returns a string representation of the Ray object.
--- @return string string The string representation of the Ray object.
Ray.__tostring = function(self)
    return string.format("Ray( O( %.3f, %.3f, %.3f ), D( %.3f, %.3f, %.3f ) )",
        self.origin.x, self.origin.y, self.origin.z,
        self.direction.x, self.direction.y, self.direction.z);
end

--- Checks if two Ray objects are equal.
--- @param a Ray The first Ray object.
--- @param b Ray The second Ray object.
--- @return boolean True if the Ray objects are equal, false otherwise.
Ray.__eq = function(a,b)
    return a.origin.x == b.origin.x and a.origin.y == b.origin.x and a.origin.z == b.origin.z and
            a.direction.x == b.direction.x and a.direction.y == b.direction.x and a.direction.z == b.direction.z;
end

--- This function is a custom index metamethod for the Ray object.
--- It is used to handle the indexing of fields in the Ray object.
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