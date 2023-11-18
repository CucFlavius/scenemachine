local Gizmos = SceneMachine.Gizmos;
local Renderer = SceneMachine.Renderer;
local Editor = SceneMachine.Editor;
local SM = Editor.SceneManager;
local OP = Editor.ObjectProperties;
local Camera = SceneMachine.Camera;
local Input = SceneMachine.Input;

Gizmos.isUsed = false;
Gizmos.isHighlighted = false;
Gizmos.refresh = false;
Gizmos.selectedAxis = 1;
Gizmos.activeTransformGizmo = 1;
Gizmos.LMBPrevious = {};
Gizmos.frames = {};
Gizmos.vectorX = {1,0,0};
Gizmos.vectorY = {0,1,0};
Gizmos.vectorZ = {0,0,1};
Gizmos.savedRotation = {0, 0, 0};
Gizmos.increment = 0;
Gizmos.space = 1;   -- 0 = world, 1 = local

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

    Gizmos.refresh = false;
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
            for t = 1, Gizmos.RotateGizmo.lineCount, 1 do
                local aX = Gizmos.RotateGizmo.screenSpaceVertices[t][1][1];
                local aY = Gizmos.RotateGizmo.screenSpaceVertices[t][1][2];
                local bX = Gizmos.RotateGizmo.screenSpaceVertices[t][2][1];
                local bY = Gizmos.RotateGizmo.screenSpaceVertices[t][2][2];

                if (mouseX ~= nil and mouseY ~= nil and aX ~= nil and aY ~= nil and bX ~= nil and bY ~= nil) then
                    local dist = distToSegment({mouseX, mouseY}, {aX, aY}, {bX, bY});
                    if (dist < 10 and Gizmos.RotateGizmo.lines[t].alpha > 0.3) then
                        Gizmos.isHighlighted = true;
                        Gizmos.selectedAxis = Gizmos.RotateGizmo.lines[t].axis;
                        Gizmos.highlightedAxis = Gizmos.RotateGizmo.lines[t].axis;
                    end
                end
            end

        -- Scale --
        elseif(Gizmos.activeTransformGizmo == 3) then
            
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
        elseif (Gizmos.activeTransformGizmo == 2) then
            Gizmos.frames["MoveGizmoFrame"]:Hide();
            Gizmos.frames["RotateGizmoFrame"]:Show();
        else
            Gizmos.frames["MoveGizmoFrame"]:Hide();
            Gizmos.frames["RotateGizmoFrame"]:Hide();
        end
    else
        Gizmos.frames["SelectionGizmoFrame"]:Hide();
        Gizmos.frames["MoveGizmoFrame"]:Hide();
        Gizmos.frames["RotateGizmoFrame"]:Hide();
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

    local xMin, yMin, zMin, xMax, yMax, zMax = SM.selectedObject:GetActiveBoundingBox();
    local bbCenter = {(xMax - xMin) / 2, (yMax - yMin) / 2, (zMax - zMin) / 2};

    Gizmos.transformToAABB(SceneMachine.Gizmos.WireBox, bbCenter);
    Gizmos.transformGizmo(SceneMachine.Gizmos.WireBox, {px, py, pz}, {rx, ry, rz}, bbCenter, 1);

    if (Gizmos.activeTransformGizmo == 1) then
        -- calculate a scale based on the gizmo distance from the camera (to keep it relatively the same size on screen)
        SceneMachine.Gizmos.MoveGizmo.scale = manhattanDistance3D(px, py, pz, Camera.X, Camera.Y, Camera.Z) / 15;
        Gizmos.transformGizmo(SceneMachine.Gizmos.MoveGizmo, {px, py, pz}, {rx, ry, rz}, bbCenter, Gizmos.space);
    elseif (Gizmos.activeTransformGizmo == 2) then
        -- calculate a scale based on the gizmo distance from the camera (to keep it relatively the same size on screen)
        SceneMachine.Gizmos.RotateGizmo.scale = manhattanDistance3D(px, py, pz, Camera.X, Camera.Y, Camera.Z) / 10;
        Gizmos.transformGizmo(SceneMachine.Gizmos.RotateGizmo, {px, py, pz}, {rx, ry, rz}, bbCenter, Gizmos.space);
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

function Gizmos.MotionToTransform()
    if (Gizmos.isUsed) then
        -- when using the gizmo (clicked), keep it highlighted even if the mouse moves away
        if (not Gizmos.refresh) then
            Gizmos.highlightedAxis = Gizmos.selectedAxis;
        end

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

            if (Gizmos.activeTransformGizmo == 1) then
                if (Gizmos.selectedAxis == 1) then
                    local dot = dotProduct(
                        xDiff,
                        yDiff,
                        Gizmos.MoveGizmo.screenSpaceVertices[1][2][1] - Gizmos.MoveGizmo.screenSpaceVertices[1][1][1],
                        Gizmos.MoveGizmo.screenSpaceVertices[1][2][2] - Gizmos.MoveGizmo.screenSpaceVertices[1][1][2]
                    );
                    local scale = dot * 0.0001 * Gizmos.MoveGizmo.scale;
                    if (Gizmos.space == 0) then
                        px = px + scale;
                    elseif (Gizmos.space == 1) then
                        px = px + (scale * Gizmos.vectorX[1]);
                        py = py + (scale * Gizmos.vectorX[2]);
                        pz = pz + (scale * Gizmos.vectorX[3]);
                    end
                elseif (Gizmos.selectedAxis == 2) then
                    local dot = dotProduct(
                        xDiff,
                        yDiff,
                        Gizmos.MoveGizmo.screenSpaceVertices[2][2][1] - Gizmos.MoveGizmo.screenSpaceVertices[2][1][1],
                        Gizmos.MoveGizmo.screenSpaceVertices[2][2][2] - Gizmos.MoveGizmo.screenSpaceVertices[2][1][2]
                    );
                    local scale = dot * 0.0001 * Gizmos.MoveGizmo.scale;
                    if (Gizmos.space == 0) then
                        py = py + scale;
                    elseif (Gizmos.space == 1) then                    
                        px = px + (scale * Gizmos.vectorY[1]);
                        py = py + (scale * Gizmos.vectorY[2]);
                        pz = pz + (scale * Gizmos.vectorY[3]);
                    end
                elseif (Gizmos.selectedAxis == 3) then
                    local dot = dotProduct(
                        xDiff,
                        yDiff,
                        Gizmos.MoveGizmo.screenSpaceVertices[3][2][1] - Gizmos.MoveGizmo.screenSpaceVertices[3][1][1],
                        Gizmos.MoveGizmo.screenSpaceVertices[3][2][2] - Gizmos.MoveGizmo.screenSpaceVertices[3][1][2]
                    );
                    local scale = dot * 0.0001 * Gizmos.MoveGizmo.scale;
                    if (Gizmos.space == 0) then
                        pz = pz + scale;
                    elseif (Gizmos.space == 1) then
                        px = px + (scale * Gizmos.vectorZ[1]);
                        py = py + (scale * Gizmos.vectorZ[2]);
                        pz = pz + (scale * Gizmos.vectorZ[3]);
                    end
                end

                if (Gizmos.refresh ~= true) then
                    SM.selectedObject:SetPosition(px, py, pz);
                end
            elseif (Gizmos.activeTransformGizmo == 2) then
                Gizmos.increment = Gizmos.increment + diff;
                if (Gizmos.selectedAxis == 1) then
                    if (Gizmos.space == 0) then
                        rx = rx + diff;
                    elseif (Gizmos.space == 1) then
                        local rot = multiplyRotations(Gizmos.savedRotation, {Gizmos.increment, 0, 0});
                        rx = rot[1];
                        ry = rot[2];
                        rz = rot[3];
                    end
                elseif (Gizmos.selectedAxis == 2) then
                    if (Gizmos.space == 0) then
                        ry = ry + diff;
                    elseif (Gizmos.space == 1) then
                        local rot = multiplyRotations(Gizmos.savedRotation, {0, Gizmos.increment, 0});
                        rx = rot[1];
                        ry = rot[2];
                        rz = rot[3];
                    end
                elseif (Gizmos.selectedAxis == 3) then
                    if (Gizmos.space == 0) then
                        rz = rz + diff;
                    elseif (Gizmos.space == 1) then
                        local rot = multiplyRotations(Gizmos.savedRotation, {0, 0, Gizmos.increment});
                        rx = rot[1];
                        ry = rot[2];
                        rz = rot[3];
                    end
                end

                if (Gizmos.refresh ~= true) then
                    SM.selectedObject:SetRotation(rx, ry, rz);
                end
            elseif (Gizmos.activeTransformGizmo == 3) then

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
    Gizmos.increment = 0;

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

function Gizmos.transformGizmo(gizmo, position, rotation, boundsCenter, space)
    for q = 1, gizmo.lineCount, 1 do
        for v = 1, 2, 1 do
            if (space == 1) then
                -- local space --
                local rotated = rotatePoint(gizmo.vertices[q][v], rotation);
                gizmo.transformedVertices[q][v][1] = rotated[1] * gizmo.scale + position[1];
                gizmo.transformedVertices[q][v][2] = rotated[2] * gizmo.scale + position[2];
                gizmo.transformedVertices[q][v][3] = rotated[3] * gizmo.scale + position[3] + boundsCenter[3];
            elseif (space == 0) then
                -- world space --
                gizmo.transformedVertices[q][v][1] = gizmo.vertices[q][v][1] * gizmo.scale + position[1];
                gizmo.transformedVertices[q][v][2] = gizmo.vertices[q][v][2] * gizmo.scale + position[2];
                gizmo.transformedVertices[q][v][3] = gizmo.vertices[q][v][3] * gizmo.scale + position[3] + boundsCenter[3];
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