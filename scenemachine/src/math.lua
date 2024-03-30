local Math = SceneMachine.Math;
local Vector3 = SceneMachine.Vector3;
local Quaternion = SceneMachine.Quaternion;

function Math.sqr(x)
    return x * x;
end

function Math.dist2(v, w)
    return Math.sqr(v[1] - w[1]) + Math.sqr(v[2] - w[2])
end

function Math.distToSegmentSquared(p, v, w)
    local l2 = Math.dist2(v, w);
    if (l2 == 0) then
        return Math.dist2(p, v);
    end
    local t = ((p[1] - v[1]) * (w[1] - v[1]) + (p[2] - v[2]) * (w[2] - v[2])) / l2;
    t = math.max(0, math.min(1, t));
    return Math.dist2(p, { v[1] + t * (w[1] - v[1]), v[2] + t * (w[2] - v[2]) });
end

function Math.distToSegment(p, v, w) 
    return math.sqrt(Math.distToSegmentSquared(p, v, w));
end

function Math.rotateVector(rx, ry, rz, vx, vy, vz)
    -- Rotation around the x-axis
    local rotatedX = vx
    local rotatedY = vy * math.cos(rx) - vz * math.sin(rx)
    local rotatedZ = vy * math.sin(rx) + vz * math.cos(rx)

    -- Rotation around the y-axis
    local tempX = rotatedX * math.cos(ry) + rotatedZ * math.sin(ry)
    local tempY = rotatedY
    local tempZ = -rotatedX * math.sin(ry) + rotatedZ * math.cos(ry)

    -- Rotation around the z-axis
    local finalX = tempX * math.cos(rz) - tempY * math.sin(rz)
    local finalY = tempX * math.sin(rz) + tempY * math.cos(rz)
    local finalZ = tempZ

    return {finalX, finalY, finalZ}
end

function Math.dotProduct(aX, aY, bX, bY)
    return aX * bX + aY * bY
end

-- Function to multiply two rotation vectors
function Math.multiplyRotations(rotation1, rotation2)
    
    local q1 = Quaternion:New();
    q1:SetFromEuler(rotation1);

    local q2 = Quaternion:New();
    q2:SetFromEuler(rotation2);
    
    q1:Multiply(q2);

    return q1:ToEuler();
end


function Math.normalize(value, min, max)
    return (value - min) / (max - min)
end

function Math.clamp(value, min, max)
    return math.min(math.max(value, min), max);
end
function Math.normalizeVector(vector)
    local magnitude = math.sqrt(vector[1]^2 + vector[2]^2 + vector[3]^2)
    
    if magnitude ~= 0 then
      return {vector[1] / magnitude, vector[2] / magnitude, vector[3] / magnitude}
    else
      -- Handle the case where the vector is a zero vector (magnitude is zero)
      return {0, 0, 0}
    end
end

function Math.isPointInPolygon(px, py, x1, y1, x2, y2, x3, y3, x4, y4)
    local function isLeft(p1, p2, p)
        return (p2[1] - p1[1]) * (p[2] - p1[2]) - (p[1] - p1[1]) * (p2[2] - p1[2])
    end

    local function isPointOnSegment(p1, p2, p)
        return math.min(p1[1], p2[1]) <= p[1] and p[1] <= math.max(p1[1], p2[1]) and
               math.min(p1[2], p2[2]) <= p[2] and p[2] <= math.max(p1[2], p2[2])
    end

    local function doIntersect(p1, q1, p2, q2)
        local o1 = isLeft(p1, q1, p2)
        local o2 = isLeft(p1, q1, q2)
        local o3 = isLeft(p2, q2, p1)
        local o4 = isLeft(p2, q2, q1)

        if o1 * o2 < 0 and o3 * o4 < 0 then
            return true
        end

        if o1 == 0 and isPointOnSegment(p1, q1, p2) then
            return true
        end

        if o2 == 0 and isPointOnSegment(p1, q1, q2) then
            return true
        end

        if o3 == 0 and isPointOnSegment(p2, q2, p1) then
            return true
        end

        if o4 == 0 and isPointOnSegment(p2, q2, q1) then
            return true
        end

        return false
    end

    local vertices = {{x1, y1}, {x2, y2}, {x3, y3}, {x4, y4}}

    -- Check if the point is inside the polygon
    local count = 0
    for i = 1, #vertices do
        local nextVertex = i % #vertices + 1
        if doIntersect(vertices[i], vertices[nextVertex], {px, py}, {math.huge, py}) then
            count = count + 1
        end
    end

    return count % 2 == 1
end