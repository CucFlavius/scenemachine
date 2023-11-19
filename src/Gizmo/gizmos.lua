local Gizmos = SceneMachine.Gizmos;
local Renderer = SceneMachine.Renderer;
local Editor = SceneMachine.Editor;
local SM = Editor.SceneManager;
local OP = Editor.ObjectProperties;
local Camera = SceneMachine.Camera;
local Input = SceneMachine.Input;

Gizmos.isUsed = false;
Gizmos.isHighlighted = false;
Gizmos.selectedAxis = 1;            -- x = 1, y = 2, z = 3
Gizmos.activeTransformGizmo = 2;    -- select = 0, move = 1, rotate = 2, scale = 3
Gizmos.space = 0;                   -- world = 0, local = 1
Gizmos.pivot = 0;                   -- center = 0, base(original) = 1 (Only really affects rotation)
Gizmos.LMBPrevious = {};
Gizmos.frames = {};
Gizmos.vectorX = {1,0,0};
Gizmos.vectorY = {0,1,0};
Gizmos.vectorZ = {0,0,1};
Gizmos.savedRotation = {0, 0, 0};
Gizmos.rotationIncrement = 0;

local function sqr(x)
    return x * x;
end

local function dist2(v, w)
    return sqr(v[1] - w[1]) + sqr(v[2] - w[2])
end

local function distToSegmentSquared(p, v, w)
    local l2 = dist2(v, w);
    if (l2 == 0) then
        return dist2(p, v);
    end
    local t = ((p[1] - v[1]) * (w[1] - v[1]) + (p[2] - v[2]) * (w[2] - v[2])) / l2;
    t = math.max(0, math.min(1, t));
    return dist2(p, { v[1] + t * (w[1] - v[1]), v[2] + t * (w[2] - v[2]) });
end

local function distToSegment(p, v, w) 
    return math.sqrt(distToSegmentSquared(p, v, w));
end

local function manhattanDistance3D(aX, aY, aZ, bX, bY, bZ)
    return math.abs(aX - bX) + math.abs(aY - bY) + math.abs(aZ - bZ)
end

function Gizmos.Create()
    Gizmos.CreateSelectionGizmo();
    Gizmos.CreateMoveGizmo();
    Gizmos.CreateRotateGizmo();
    Gizmos.CreateScaleGizmo();
end

function Gizmos.CreateLineProjectionFrame()
	local lineProjectionFrame = CreateFrame("Frame", "lineProjectionFrame", Renderer.projectionFrame)
	lineProjectionFrame:SetFrameStrata("BACKGROUND");
	lineProjectionFrame:SetWidth(Renderer.w);
	lineProjectionFrame:SetHeight(Renderer.h);
	lineProjectionFrame:SetPoint("TOPRIGHT", Renderer.projectionFrame, "TOPRIGHT", 0, 0);
	lineProjectionFrame.texture = lineProjectionFrame:CreateTexture("Renderer.lineProjectionFrame.texture", "ARTWORK")
	lineProjectionFrame.texture:SetColorTexture(0,0,0,0);
	lineProjectionFrame.texture:SetAllPoints(Renderer.lineProjectionFrame);
	lineProjectionFrame:SetFrameLevel(101);
    lineProjectionFrame:Hide();
    return lineProjectionFrame;
end

function Gizmos.Update()
    local mouseX, mouseY = Input.mouseX, Input.mouseY;

    Gizmos.highlightedAxis = 0;
    Gizmos.isHighlighted = false;

    -- Handle gizmo mouse highlight and selection --
    local highlighted = Gizmos.SelectionCheck(mouseX, mouseY);

    -- Handle gizmo visibility --
    Gizmos.VisibilityCheck();

    -- Handle gizmo motion to transformation --
    Gizmos.MotionToTransform();

    -- Update the gizmo transform --
    Gizmos.UpdateGizmoTransform();
end

function indexOfSmallestValue(tbl)
    if #tbl ~= 3 then
        error("Input table must have exactly 3 values.")
    end

    local minIndex = 1
    local minValue = tbl[1]

    for i = 2, 3 do
        if tbl[i] < minValue then
            minIndex = i
            minValue = tbl[i]
        end
    end

    return minIndex
end

function Gizmos.SelectionCheck(mouseX, mouseY)
    if not Gizmos.isUsed then
        -- Position --
        if (Gizmos.activeTransformGizmo == 1) then
            for t = 1, 3, 1 do
                local aX = Gizmos.MoveGizmo.screenSpaceVertices[t][1][1];
                local aY = Gizmos.MoveGizmo.screenSpaceVertices[t][1][2];
                local bX = Gizmos.MoveGizmo.screenSpaceVertices[t][2][1];
                local bY = Gizmos.MoveGizmo.screenSpaceVertices[t][2][2];

                if (mouseX ~= nil and mouseY ~= nil and aX ~= nil and aY ~= nil and bX ~= nil and bY ~= nil) then
                    local dist = distToSegment({mouseX, mouseY}, {aX, aY}, {bX, bY});
                    if (dist < 10) then
                        Gizmos.isHighlighted = true;
                        Gizmos.selectedAxis = t;
                        Gizmos.highlightedAxis = t;
                    end
                end
            end

        -- Rotation --
        elseif (Gizmos.activeTransformGizmo == 2) then
            local minDists = { 10000, 10000, 10000 };
            for t = 1, Gizmos.RotateGizmo.lineCount, 1 do
                local aX = Gizmos.RotateGizmo.screenSpaceVertices[t][1][1];
                local aY = Gizmos.RotateGizmo.screenSpaceVertices[t][1][2];
                local bX = Gizmos.RotateGizmo.screenSpaceVertices[t][2][1];
                local bY = Gizmos.RotateGizmo.screenSpaceVertices[t][2][2];

                if (mouseX ~= nil and mouseY ~= nil and aX ~= nil and aY ~= nil and bX ~= nil and bY ~= nil) then
                    local dist = distToSegment({mouseX, mouseY}, {aX, aY}, {bX, bY});
                    local line = Gizmos.RotateGizmo.lines[t];
                    if (dist < 10 and line.alpha > 0.2) then
                        local ax = line.axis;
                        if (minDists[ax] > dist) then
                            minDists[ax] = dist;
                        end
                    end
                end
            end

            local smallest = indexOfSmallestValue(minDists);
            if (minDists[smallest] < 10) then
                Gizmos.isHighlighted = true;
                Gizmos.selectedAxis = smallest;
                Gizmos.highlightedAxis = smallest;
            end

        -- Scale --
        elseif(Gizmos.activeTransformGizmo == 3) then
            for t = 1, Gizmos.ScaleGizmo.lineCount, 1 do
                local aX = Gizmos.ScaleGizmo.screenSpaceVertices[t][1][1];
                local aY = Gizmos.ScaleGizmo.screenSpaceVertices[t][1][2];
                local bX = Gizmos.ScaleGizmo.screenSpaceVertices[t][2][1];
                local bY = Gizmos.ScaleGizmo.screenSpaceVertices[t][2][2];

                if (mouseX ~= nil and mouseY ~= nil and aX ~= nil and aY ~= nil and bX ~= nil and bY ~= nil) then
                    local dist = distToSegment({mouseX, mouseY}, {aX, aY}, {bX, bY});
                    if (dist < 30) then
                        Gizmos.isHighlighted = true;
                        Gizmos.selectedAxis = 1;
                        Gizmos.highlightedAxis = 1;
                    end
                end
            end
        end
    end

    return selected;
end

function Gizmos.VisibilityCheck()
    if (SM.selectedObject ~= nil) then
        Gizmos.frames["SelectionGizmoFrame"]:Show();

        if(Gizmos.activeTransformGizmo == 1) then
            Gizmos.frames["MoveGizmoFrame"]:Show();
            Gizmos.frames["RotateGizmoFrame"]:Hide();
            Gizmos.frames["ScaleGizmoFrame"]:Hide();
        elseif (Gizmos.activeTransformGizmo == 2) then
            Gizmos.frames["MoveGizmoFrame"]:Hide();
            Gizmos.frames["RotateGizmoFrame"]:Show();
            Gizmos.frames["ScaleGizmoFrame"]:Hide();
        elseif (Gizmos.activeTransformGizmo == 3) then
            Gizmos.frames["MoveGizmoFrame"]:Hide();
            Gizmos.frames["RotateGizmoFrame"]:Hide();
            Gizmos.frames["ScaleGizmoFrame"]:Show();
        else
            Gizmos.frames["MoveGizmoFrame"]:Hide();
            Gizmos.frames["RotateGizmoFrame"]:Hide();
            Gizmos.frames["ScaleGizmoFrame"]:Hide();
        end
    else
        Gizmos.frames["SelectionGizmoFrame"]:Hide();
        Gizmos.frames["MoveGizmoFrame"]:Hide();
        Gizmos.frames["RotateGizmoFrame"]:Hide();
        Gizmos.frames["ScaleGizmoFrame"]:Hide();
    end
end

local function dotProduct(aX, aY, bX, bY)
    return aX * bX + aY * bY
end

local function rotatePoint(point, angles)
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

function rotateVector(rx, ry, rz, vx, vy, vz)
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

function Gizmos.UpdateGizmoTransform()
    if (SM.selectedObject == nil) then
        return;
    end

    local position = SM.selectedObject:GetPosition();
    local px, py, pz = position.x, position.y, position.z;
    local rotation = SM.selectedObject:GetRotation();
    local rx, ry, rz = rotation.x, rotation.y, rotation.z;
    local scale = SM.selectedObject:GetScale();

    local xMin, yMin, zMin, xMax, yMax, zMax = SM.selectedObject:GetActiveBoundingBox();
    local bbCenter = {(xMax - xMin) / 2, (yMax - yMin) / 2, (zMax - zMin) / 2};

    Gizmos.transformToAABB(SceneMachine.Gizmos.WireBox, bbCenter);
    Gizmos.transformGizmo(SceneMachine.Gizmos.WireBox, {px, py, pz}, {rx, ry, rz}, scale, bbCenter, 1, 0);

    if (Gizmos.activeTransformGizmo == 1) then
        -- calculate a scale based on the gizmo distance from the camera (to keep it relatively the same size on screen)
        SceneMachine.Gizmos.MoveGizmo.scale = manhattanDistance3D(px, py, pz, Camera.X, Camera.Y, Camera.Z) / 15;
        Gizmos.transformGizmo(SceneMachine.Gizmos.MoveGizmo, {px, py, pz}, {rx, ry, rz}, 1, bbCenter, Gizmos.space, Gizmos.pivot);
    elseif (Gizmos.activeTransformGizmo == 2) then
        -- calculate a scale based on the gizmo distance from the camera (to keep it relatively the same size on screen)
        SceneMachine.Gizmos.RotateGizmo.scale = manhattanDistance3D(px, py, pz, Camera.X, Camera.Y, Camera.Z) / 10;
        Gizmos.transformGizmo(SceneMachine.Gizmos.RotateGizmo, {px, py, pz}, {rx, ry, rz}, 1, bbCenter, Gizmos.space, Gizmos.pivot);
    elseif (Gizmos.activeTransformGizmo == 3) then
        SceneMachine.Gizmos.ScaleGizmo.scale = manhattanDistance3D(px, py, pz, Camera.X, Camera.Y, Camera.Z) / 15;
        Gizmos.transformGizmo(SceneMachine.Gizmos.ScaleGizmo, {px, py, pz}, {rx, ry, rz}, 1, bbCenter, Gizmos.space, Gizmos.pivot);
    end
end

function vectorToQuaternion(rotation)
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
function quaternionToVector(quaternion)
    local qw, qx, qy, qz = quaternion[1], quaternion[2], quaternion[3], quaternion[4]

    local rx = math.atan2(2 * (qw * qx + qy * qz), 1 - 2 * (qx^2 + qy^2))
    local ry = math.asin(2 * (qw * qy - qz * qx))
    local rz = math.atan2(2 * (qw * qz + qx * qy), 1 - 2 * (qy^2 + qz^2))

    return {rx, ry, rz}
end

-- Function to multiply two rotation vectors
function multiplyRotations(rotation1, rotation2)
    local quaternion1 = vectorToQuaternion(rotation1)
    local quaternion2 = vectorToQuaternion(rotation2)

    -- Quaternion multiplication
    local resultQuaternion = {
        quaternion1[1]*quaternion2[1] - quaternion1[2]*quaternion2[2] - quaternion1[3]*quaternion2[3] - quaternion1[4]*quaternion2[4],
        quaternion1[1]*quaternion2[2] + quaternion1[2]*quaternion2[1] + quaternion1[3]*quaternion2[4] - quaternion1[4]*quaternion2[3],
        quaternion1[1]*quaternion2[3] - quaternion1[2]*quaternion2[4] + quaternion1[3]*quaternion2[1] + quaternion1[4]*quaternion2[2],
        quaternion1[1]*quaternion2[4] + quaternion1[2]*quaternion2[3] - quaternion1[3]*quaternion2[2] + quaternion1[4]*quaternion2[1]
    }

    return quaternionToVector(resultQuaternion)
end

function multiplyVectorByQuaternion(vector, quaternion)
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

function RotatePointAroundPivot(point, pivot, angles)
    local dir = { point[1] - pivot[1], point[2] - pivot[2], point[3] - pivot[3] }; -- get point direction relative to pivot
    local qAngles = vectorToQuaternion(angles);
    local vDir = multiplyVectorByQuaternion(dir, qAngles); -- rotate it
    local transformedPoint = { vDir[1] + pivot[1], vDir[2] + pivot[2], vDir[3] + pivot[3] }; -- calculate rotated point
    return transformedPoint; -- return it
end

function rotate_object_around_pivot(object, pivot, rotation)
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

function Gizmos.MotionToTransform()
    if (Gizmos.isUsed) then
        -- when using the gizmo (clicked), keep it highlighted even if the mouse moves away
        Gizmos.highlightedAxis = Gizmos.selectedAxis;

		local curX, curY = GetCursorPosition();

        if (Gizmos.LMBPrevious.x == nil) then
            Gizmos.LMBPrevious.x = curX;
            Gizmos.LMBPrevious.y = curY;
        end
        
		local xDiff = curX - Gizmos.LMBPrevious.x;
		local yDiff = curY - Gizmos.LMBPrevious.y;
        local diff = ((xDiff + yDiff) / 2) / 100;

        if (SM.selectedObject ~= nil) then
            local position = SM.selectedObject:GetPosition();
            local px, py, pz = position.x, position.y, position.z;
            local rotation = SM.selectedObject:GetRotation();
            local rx, ry, rz = rotation.x, rotation.y, rotation.z;
            local s = SM.selectedObject:GetScale();
            
            if (Gizmos.activeTransformGizmo == 1) then
                if (Gizmos.selectedAxis == 1) then
                    local dot = dotProduct(
                        xDiff,
                        yDiff,
                        Gizmos.MoveGizmo.screenSpaceVertices[1][2][1] - Gizmos.MoveGizmo.screenSpaceVertices[1][1][1],
                        Gizmos.MoveGizmo.screenSpaceVertices[1][2][2] - Gizmos.MoveGizmo.screenSpaceVertices[1][1][2]
                    );
                    local gscale = dot * 0.0001 * Gizmos.MoveGizmo.scale;
                    if (Gizmos.space == 0) then
                        px = px + gscale;
                    elseif (Gizmos.space == 1) then
                        px = px + (gscale * Gizmos.vectorX[1]);
                        py = py + (gscale * Gizmos.vectorX[2]);
                        pz = pz + (gscale * Gizmos.vectorX[3]);
                    end
                elseif (Gizmos.selectedAxis == 2) then
                    local dot = dotProduct(
                        xDiff,
                        yDiff,
                        Gizmos.MoveGizmo.screenSpaceVertices[2][2][1] - Gizmos.MoveGizmo.screenSpaceVertices[2][1][1],
                        Gizmos.MoveGizmo.screenSpaceVertices[2][2][2] - Gizmos.MoveGizmo.screenSpaceVertices[2][1][2]
                    );
                    local gscale = dot * 0.0001 * Gizmos.MoveGizmo.scale;
                    if (Gizmos.space == 0) then
                        py = py + gscale;
                    elseif (Gizmos.space == 1) then                    
                        px = px + (gscale * Gizmos.vectorY[1]);
                        py = py + (gscale * Gizmos.vectorY[2]);
                        pz = pz + (gscale * Gizmos.vectorY[3]);
                    end
                elseif (Gizmos.selectedAxis == 3) then
                    local dot = dotProduct(
                        xDiff,
                        yDiff,
                        Gizmos.MoveGizmo.screenSpaceVertices[3][2][1] - Gizmos.MoveGizmo.screenSpaceVertices[3][1][1],
                        Gizmos.MoveGizmo.screenSpaceVertices[3][2][2] - Gizmos.MoveGizmo.screenSpaceVertices[3][1][2]
                    );
                    local gscale = dot * 0.0001 * Gizmos.MoveGizmo.scale;
                    if (Gizmos.space == 0) then
                        pz = pz + gscale;
                    elseif (Gizmos.space == 1) then
                        px = px + (gscale * Gizmos.vectorZ[1]);
                        py = py + (gscale * Gizmos.vectorZ[2]);
                        pz = pz + (gscale * Gizmos.vectorZ[3]);
                    end
                end
                SM.selectedObject:SetPosition(px, py, pz);
            elseif (Gizmos.activeTransformGizmo == 2) then
                Gizmos.rotationIncrement = Gizmos.rotationIncrement + diff;
                if (Gizmos.selectedAxis == 1) then
                    if (Gizmos.space == 0) then
                        rx = rx + diff;
                    elseif (Gizmos.space == 1) then
                        local rot = multiplyRotations(Gizmos.savedRotation, {Gizmos.rotationIncrement, 0, 0});
                        rx = rot[1];
                        ry = rot[2];
                        rz = rot[3];
                    end
                elseif (Gizmos.selectedAxis == 2) then
                    if (Gizmos.space == 0) then
                        ry = ry + diff;
                        ------------------ TODO: This needs work ----------------
                        if (Gizmos.pivot == 1) then
                            local xMin, yMin, zMin, xMax, yMax, zMax = SM.selectedObject:GetActiveBoundingBox();
                            local bbCenter = ((zMax - zMin) / 2) * s;
                            local ppoint = rotate_object_around_pivot({0, 0, bbCenter}, {0, 0, 0}, {0, diff, 0});
                            px = px + ppoint[1];
                            py = py + ppoint[2];
                            pz = pz + ppoint[3] - bbCenter;
                            SM.selectedObject:SetPosition(px, py, pz);
                        end
                        ---------------------------------------------------------
                    elseif (Gizmos.space == 1) then
                        local rot = multiplyRotations(Gizmos.savedRotation, {0, Gizmos.rotationIncrement, 0});
                        rx = rot[1];
                        ry = rot[2];
                        rz = rot[3];
                    end
                elseif (Gizmos.selectedAxis == 3) then
                    if (Gizmos.space == 0) then
                        rz = rz + diff;
                    elseif (Gizmos.space == 1) then
                        local rot = multiplyRotations(Gizmos.savedRotation, {0, 0, Gizmos.rotationIncrement});
                        rx = rot[1];
                        ry = rot[2];
                        rz = rot[3];
                    end
                end
                SM.selectedObject:SetRotation(rx, ry, rz);
            elseif (Gizmos.activeTransformGizmo == 3) then
                s = s + diff;
                s = math.max(0.0001, s);
                SM.selectedObject:SetScale(s, s, s);
            end

            OP.Refresh();
        end

        Gizmos.LMBPrevious.x = curX;
		Gizmos.LMBPrevious.y = curY;
    end

end

local function normalize(vector)
    local magnitude = math.sqrt(vector[1]^2 + vector[2]^2 + vector[3]^2)
    
    if magnitude ~= 0 then
      return {vector[1] / magnitude, vector[2] / magnitude, vector[3] / magnitude}
    else
      -- Handle the case where the vector is a zero vector (magnitude is zero)
      return {0, 0, 0}
    end
end

function Gizmos.OnLMBDown(x, y)
	Gizmos.LMBPrevious.x = x;
	Gizmos.LMBPrevious.y = y;
    Gizmos.isUsed = true;
    Gizmos.rotationIncrement = 0;

    -- store rotation vector
    if (SM.selectedObject ~= nil) then
        local rotation = SM.selectedObject:GetRotation();
        local rx, ry, rz = rotation.x, rotation.y, rotation.z;
        Gizmos.vectorX = normalize(rotateVector(rx, ry, rz, 1, 0, 0));
        Gizmos.vectorY = normalize(rotateVector(rx, ry, rz, 0, 1, 0));
        Gizmos.vectorZ = normalize(rotateVector(rx, ry, rz, 0, 0, 1));
        Gizmos.savedRotation = {rx, ry, rz};
    else
        Gizmos.vectorX = {1,0,0};
        Gizmos.vectorY = {0,1,0};
        Gizmos.vectorZ = {0,0,1};
        Gizmos.savedRotation = {0, 0, 0};
    end
end

function Gizmos.OnLMBUp()
    Gizmos.isUsed = false;
end

function Gizmos.transformGizmo(gizmo, position, rotation, scale, boundsCenter, space, pivot)
    local pivotOffset;
    local boundsCenterOffset = boundsCenter[3] * scale;
    if (pivot == 0) then
        -- center
        pivotOffset = { 0, 0, boundsCenterOffset };
    elseif (pivot == 1) then
        -- base
        local point = RotatePointAroundPivot({0, 0, -boundsCenterOffset}, {0, 0, 0}, {rotation[1], rotation[2], rotation[3]});
        pivotOffset = { point[1], point[2], point[3] + boundsCenterOffset};
    end

    for q = 1, gizmo.lineCount, 1 do
        for v = 1, 2, 1 do
            if (space == 1) then
                -- local space --
                local rotated = rotatePoint(gizmo.vertices[q][v], rotation, scale);
                gizmo.transformedVertices[q][v][1] = rotated[1] * gizmo.scale * scale + position[1] + pivotOffset[1];
                gizmo.transformedVertices[q][v][2] = rotated[2] * gizmo.scale * scale + position[2] + pivotOffset[2];
                gizmo.transformedVertices[q][v][3] = rotated[3] * gizmo.scale * scale + position[3] + pivotOffset[3];
            elseif (space == 0) then
                -- world space --
                gizmo.transformedVertices[q][v][1] = gizmo.vertices[q][v][1] * gizmo.scale * scale + position[1] + pivotOffset[1];
                gizmo.transformedVertices[q][v][2] = gizmo.vertices[q][v][2] * gizmo.scale * scale + position[2] + pivotOffset[2];
                gizmo.transformedVertices[q][v][3] = gizmo.vertices[q][v][3] * gizmo.scale * scale + position[3] + pivotOffset[3];
            end
        end
    end
end

function Gizmos.transformToAABB(gizmo, boundsCenter)
    local chX = boundsCenter[1];
    local chY = boundsCenter[2];
    local chZ = boundsCenter[3];

    gizmo.vertices[1][1] = {-chX, -chY, -chZ};
    gizmo.vertices[1][2] = {chX, -chY, -chZ};
    gizmo.vertices[2][1] = {chX, -chY, -chZ};
    gizmo.vertices[2][2] = {chX, -chY, chZ};
    gizmo.vertices[3][1] = {chX, -chY, chZ};
    gizmo.vertices[3][2] = {-chX, -chY, chZ};
    gizmo.vertices[4][1] = {-chX, -chY, chZ};
    gizmo.vertices[4][2] = {-chX, -chY, -chZ};

    gizmo.vertices[5][1] = {-chX, chY, -chZ};
    gizmo.vertices[5][2] = {chX, chY, -chZ};
    gizmo.vertices[6][1] = {chX, chY, -chZ};
    gizmo.vertices[6][2] = {chX, chY, chZ};
    gizmo.vertices[7][1] = {chX, chY, chZ};
    gizmo.vertices[7][2] = {-chX, chY, chZ};
    gizmo.vertices[8][1] = {-chX, chY, chZ};
    gizmo.vertices[8][2] = {-chX, chY, -chZ};

    gizmo.vertices[9][1] = {-chX, -chY, -chZ};
    gizmo.vertices[9][2] = {-chX, chY, -chZ};
    gizmo.vertices[10][1] = {chX, -chY, -chZ};
    gizmo.vertices[10][2] = {chX, chY, -chZ};
    gizmo.vertices[11][1] = {chX, -chY, chZ};
    gizmo.vertices[11][2] = {chX, chY, chZ};
    gizmo.vertices[12][1] = {-chX, -chY, chZ};
    gizmo.vertices[12][2] = {-chX, chY, chZ};
end