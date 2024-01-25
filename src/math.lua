local Math = SceneMachine.Math;

function Math.manhattanDistance(aX, aY, bX, bY)
    return math.abs(aX - bX) + math.abs(aY - bY)
end

function Math.manhattanDistance3D(aX, aY, aZ, bX, bY, bZ)
    return math.abs(aX - bX) + math.abs(aY - bY) + math.abs(aZ - bZ)
end

function Math.RotateObjectAroundPivot(object, pivot, rotation)
    -- Translate the object and pivot to the origin
    local translated_object = {
        object[1] - pivot[1],
        object[2] - pivot[2],
        object[3] - pivot[3]
    }

    -- Apply rotation around the x-axis
    local rx = rotation[1]
    local cos_rx = math.cos(rx)
    local sin_rx = math.sin(rx)
    local x_rotated = translated_object[1]
    local y_rotated = cos_rx * translated_object[2] - sin_rx * translated_object[3]
    local z_rotated = sin_rx * translated_object[2] + cos_rx * translated_object[3]

    -- Apply rotation around the y-axis
    local ry = rotation[2]
    local cos_ry = math.cos(ry)
    local sin_ry = math.sin(ry)
    local x_rotated_y = cos_ry * x_rotated + sin_ry * z_rotated
    local y_rotated_y = y_rotated
    local z_rotated_y = -sin_ry * x_rotated + cos_ry * z_rotated

    -- Apply rotation around the z-axis
    local rz = rotation[3]
    local cos_rz = math.cos(rz)
    local sin_rz = math.sin(rz)
    local x_rotated_z = cos_rz * x_rotated_y - sin_rz * y_rotated_y
    local y_rotated_z = sin_rz * x_rotated_y + cos_rz * y_rotated_y
    local z_rotated_z = z_rotated_y

    -- Translate the object back to its original position
    local rotated_object = {
        x_rotated_z + pivot[1],
        y_rotated_z + pivot[2],
        z_rotated_z + pivot[3]
    }

    return rotated_object
end

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

function Math.dotProduct(aX, aY, bX, bY)
    return aX * bX + aY * bY
end

function Math.rotatePoint(point, angles)
    local x, y, z = point[1], point[2], point[3]
    local rx, ry, rz = angles[1], angles[2], angles[3]

    -- Rotate around x-axis
    local cosRx = math.cos(rx)
    local sinRx = math.sin(rx)
    local newY = y * cosRx - z * sinRx
    local newZ = y * sinRx + z * cosRx

    -- Rotate around y-axis
    local cosRy = math.cos(ry)
    local sinRy = math.sin(ry)
    local newX = x * cosRy + newZ * sinRy
    newZ = -x * sinRy + newZ * cosRy

    -- Rotate around z-axis
    local cosRz = math.cos(rz)
    local sinRz = math.sin(rz)
    local finalX = newX * cosRz - newY * sinRz
    local finalY = newX * sinRz + newY * cosRz

    return {finalX, finalY, newZ}
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

function Math.vectorToQuaternion(rotation)
    local rx, ry, rz = rotation[1], rotation[2], rotation[3]

    local sx, sy, sz, cx, cy, cz = math.sin(rx/2), math.sin(ry/2), math.sin(rz/2), math.cos(rx/2), math.cos(ry/2), math.cos(rz/2)

    local quaternion = {
        cx * cy * cz + sx * sy * sz,
        sx * cy * cz - cx * sy * sz,
        cx * sy * cz + sx * cy * sz,
        cx * cy * sz - sx * sy * cz
    }

    return quaternion
end

-- Function to convert a quaternion to a rotation vector
function Math.quaternionToVector(quaternion)
    local qw, qx, qy, qz = quaternion[1], quaternion[2], quaternion[3], quaternion[4]

    local rx = math.atan2(2 * (qw * qx + qy * qz), 1 - 2 * (qx^2 + qy^2))
    local ry = math.asin(2 * (qw * qy - qz * qx))
    local rz = math.atan2(2 * (qw * qz + qx * qy), 1 - 2 * (qy^2 + qz^2))

    return {rx, ry, rz}
end

-- Function to multiply two rotation vectors
function Math.multiplyRotations(rotation1, rotation2)
    local quaternion1 = Math.vectorToQuaternion(rotation1)
    local quaternion2 = Math.vectorToQuaternion(rotation2)

    -- Quaternion multiplication
    local resultQuaternion = {
        quaternion1[1]*quaternion2[1] - quaternion1[2]*quaternion2[2] - quaternion1[3]*quaternion2[3] - quaternion1[4]*quaternion2[4],
        quaternion1[1]*quaternion2[2] + quaternion1[2]*quaternion2[1] + quaternion1[3]*quaternion2[4] - quaternion1[4]*quaternion2[3],
        quaternion1[1]*quaternion2[3] - quaternion1[2]*quaternion2[4] + quaternion1[3]*quaternion2[1] + quaternion1[4]*quaternion2[2],
        quaternion1[1]*quaternion2[4] + quaternion1[2]*quaternion2[3] - quaternion1[3]*quaternion2[2] + quaternion1[4]*quaternion2[1]
    }

    return Math.quaternionToVector(resultQuaternion)
end

function Math.multiplyVectorByQuaternion(vector, quaternion)
    local qv = {quaternion[2], quaternion[3], quaternion[4]}
    local uv = {
        qv[2]*vector[3] - qv[3]*vector[2],
        qv[3]*vector[1] - qv[1]*vector[3],
        qv[1]*vector[2] - qv[2]*vector[1]
    }

    local uuv = {
        qv[2]*uv[3] - qv[3]*uv[2],
        qv[3]*uv[1] - qv[1]*uv[3],
        qv[1]*uv[2] - qv[2]*uv[1]
    }

    local scaledVector = {
        vector[1] + 2*(quaternion[1]*uv[1] + uuv[1]),
        vector[2] + 2*(quaternion[1]*uv[2] + uuv[2]),
        vector[3] + 2*(quaternion[1]*uv[3] + uuv[3])
    }

    return scaledVector
end

function Math.RotatePointAroundPivot(point, pivot, angles)
    local dir = { point[1] - pivot[1], point[2] - pivot[2], point[3] - pivot[3] }; -- get point direction relative to pivot
    local qAngles = Math.vectorToQuaternion(angles);
    local vDir = Math.multiplyVectorByQuaternion(dir, qAngles); -- rotate it
    local transformedPoint = { vDir[1] + pivot[1], vDir[2] + pivot[2], vDir[3] + pivot[3] }; -- calculate rotated point
    return transformedPoint; -- return it
end

function Math.normalize(vector)
    local magnitude = math.sqrt(vector[1]^2 + vector[2]^2 + vector[3]^2)
    
    if magnitude ~= 0 then
      return {vector[1] / magnitude, vector[2] / magnitude, vector[3] / magnitude}
    else
      -- Handle the case where the vector is a zero vector (magnitude is zero)
      return {0, 0, 0}
    end
end

function Math.normalize2D(x, y)
    local magnitude = math.sqrt(x^2 + y^2)
    if magnitude ~= 0 then
        return { x / magnitude, y / magnitude }
    else
        return { x = 0, y = 0 }
    end
end

function Math.abs3D(x, y, z)
	return { math.abs[x], math.abs[y], math.abs[z] };
end

function Math.lerp(start, finish, t)
    return start * (1 - t) + finish * t
end

function Math.eulerToDirection(rx, ry, rz)
    -- Calculate direction vector components
    local vx = math.cos(ry) * math.cos(rz)
    local vy = math.sin(rz)
    local vz = math.sin(ry) * math.cos(rz)

    return { vx, vy, vz }
end

function Math.pointOnSphere(yaw, pitch, roll, distance)
    -- Convert degrees to radians
    yaw = math.rad(yaw)
    pitch = math.rad(pitch)
    roll = math.rad(roll)

    -- Calculate Cartesian coordinates
    local x = distance * math.cos(pitch) * math.cos(yaw)
    local y = distance * math.cos(pitch) * math.sin(yaw)
    local z = distance * math.sin(pitch)

    return { x, y, z }
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

--[[
function Math.calculateMouseRay(cameraRotation, screenWidth, screenHeight, fieldOfView, mouseX, mouseY)
    local aspectRatio = screenWidth / screenHeight

    -- Calculate the normalized device coordinates (NDC) from screen coordinates
    local ndcX = --(2 * mouseX / screenWidth - 1) * aspectRatio
    local ndcY = --1 - 2 * mouseY / screenHeight

    -- Calculate the tan of half the field of view
    local tanHalfFOV = math.tan(math.rad(fieldOfView / 2))

    -- Calculate the camera space coordinates (unprojecting from NDC)
    local cameraSpaceX = ndcX * tanHalfFOV
    local cameraSpaceY = ndcY * tanHalfFOV

    -- The ray direction in camera space
    local rayDirectionCamera = { x = cameraSpaceX, y = cameraSpaceY, z = -1 }

    -- Normalize the ray direction
    local length = math.sqrt(rayDirectionCamera.x^2 + rayDirectionCamera.y^2 + rayDirectionCamera.z^2)
    rayDirectionCamera.x = rayDirectionCamera.x / length
    rayDirectionCamera.y = rayDirectionCamera.y / length
    rayDirectionCamera.z = rayDirectionCamera.z / length

    return rayDirectionCamera
end
--]]

function Math.calculateMouseRay(cameraRotation, screenWidth, screenHeight, fieldOfView, mouseX, mouseY)
    local aspectRatio = screenWidth / screenHeight

    -- Calculate the normalized device coordinates (NDC) from screen coordinates
    --local ndcX = (2 * mouseX / screenWidth - 1) * aspectRatio
    --local ndcY = 1 - 2 * mouseY / screenHeight
    local ndcX = 0.5 - (mouseX / screenWidth);
    local ndcY = mouseY / screenHeight;
    --float ndc_x = screen_x / width * 2 - 1;
    --float ndc_y = screen_y / height * 2 - 1;
    
    -- Calculate the tan of half the field of view
    local tanHalfFOV = math.tan(math.rad(fieldOfView / 2.0))
    
    -- Calculate the camera space coordinates (unprojecting from NDC)
    local cameraSpaceX = ndcY * tanHalfFOV
    local cameraSpaceY = ndcX * tanHalfFOV
    local cameraSpaceZ = -1  -- This is the direction along the negative z-axis in camera space
    
    -- Rotate the camera space coordinates based on camera rotation
    local cosYaw = math.cos(cameraRotation.x)
    local sinYaw = math.sin(cameraRotation.x)
    local cosPitch = math.cos(cameraRotation.y)
    local sinPitch = math.sin(cameraRotation.y)

    --print(cameraSpaceX .. " " ..cameraSpaceY);
    
    local rotatedCameraSpaceX = cosYaw * cameraSpaceX - sinYaw * cameraSpaceY
    local rotatedCameraSpaceY = sinYaw * cameraSpaceX + cosYaw * cameraSpaceY
    local rotatedCameraSpaceZ = cosPitch * cameraSpaceZ
    
    -- The ray direction in camera space
    local rayDirectionCamera = {
        x = rotatedCameraSpaceX,
        y = rotatedCameraSpaceY,
        z = rotatedCameraSpaceZ
    }

    -- Rotate the camera space coordinates based on camera rotation
    --local rotated = Math.multiplyRotations( { cameraRotation.x, cameraRotation.y, cameraRotation.z} , { cameraSpaceX, cameraSpaceY, cameraSpaceZ } );

    -- The ray direction in camera space
    --local rayDirectionCamera = {
    --    x = rotated[1],
    --    y = rotated[2],
    --    z = rotated[3]
    --}

    -- Normalize the ray direction
    local length = math.sqrt(rayDirectionCamera.x^2 + rayDirectionCamera.y^2 + rayDirectionCamera.z^2)
    rayDirectionCamera.x = rayDirectionCamera.x / length
    rayDirectionCamera.y = rayDirectionCamera.y / length
    rayDirectionCamera.z = rayDirectionCamera.z / length

    return { rayDirectionCamera.x, rayDirectionCamera.y, rayDirectionCamera.z }
end

function Math.UnprojectMouse(mouseX, mouseY, screenWidth, screenHeight, cameraProjection, cameraView)
    local ndc = Math.MouseToNormalizedDeviceCoords(mouseX, mouseY, screenWidth, screenHeight);
    local clip = Math.NDCToClipCoords(ndc);
    local eye = Math.ClipToEye(clip, cameraProjection);
    local rayvec = Math.EyeToRayVector(eye, cameraView);
    return rayvec;
end

function Math.MouseToNormalizedDeviceCoords(mouseX, mouseY, width, height)
    local x = 0.5 - mouseX / width;
    local y = mouseY / height - 0.5;
    return { x, y };
end

function Math.NDCToClipCoords(ray_nds)
    return { ray_nds[1], ray_nds[2], -1.0, 1.0 };
end

function Math.ClipToEye(ray_clip, projection_matrix)
    projection_matrix:Invert();
    local ray_eye = projection_matrix:MultiplyVector4(ray_clip);
    return { ray_eye[1], ray_eye[2], -1.0, 0.0 };
end

function Math.EyeToRayVector(ray_eye, view_matrix)
    view_matrix:Invert()
    local ray_wor = view_matrix:MultiplyVector4(ray_eye)
    --Vector3 ray_wor = (ray_eye * view_matrix.Inverted()).Xyz;
    --ray_wor.Normalize();
    ray_wor = Math.normalizeVector3(ray_wor);
    return ray_wor;
end

function Math.normalizeVector3(vector)
    local magnitude = math.sqrt((vector[1] * vector[1]) + (vector[2] * vector[2]) + (vector[3] * vector[3]));

    if magnitude ~= 0 then
        return {
            vector[1] / magnitude,
            vector[2] / magnitude,
            vector[3] / magnitude
        }
    else
        return {0, 0, 0}  -- Avoid division by zero if the vector is a zero vector
    end
end

function Math.crossProduct(a, b)
    return {
        a[2] * b[3] - a[3] * b[2],
        a[3] * b[1] - a[1] * b[3],
        a[1] * b[2] - a[2] * b[1]
    }
end

function Math.dotProductVec3(a, b)
    return a[1] * b[1] + a[2] * b[2] + a[3] * b[3]
end

function Math.intersectRayPlane(rayOrigin, rayDirection, planeNormal, planePoint)
    local epsilon = 1e-6

    -- Ensure that the ray and plane are not parallel
    local dotProduct = (planeNormal.x * rayDirection[1]) + (planeNormal.y * rayDirection[2]) + (planeNormal.z * rayDirection[3])
    if math.abs(dotProduct) < epsilon then
        return nil  -- Ray and plane are parallel, no intersection
    end

    -- Calculate the parameter t for the intersection point
    local t = ((planeNormal.x * (planePoint.x - rayOrigin.x) +
                 planeNormal.y * (planePoint.y - rayOrigin.y) +
                 planeNormal.z * (planePoint.z - rayOrigin.z)) / dotProduct)

    -- Ensure the intersection point is in front of the ray origin
    if t < 0 then
        return nil  -- Intersection point is behind the ray origin
    end

    -- Calculate the intersection point
    local intersectionPoint = {
        x = rayOrigin.x + (t * rayDirection[1]),
        y = rayOrigin.y + (t * rayDirection[2]),
        z = rayOrigin.z + (t * rayDirection[3])
    }

    return intersectionPoint
end