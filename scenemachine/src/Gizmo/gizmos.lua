local Gizmos = SceneMachine.Gizmos;
local Renderer = SceneMachine.Renderer;
local Editor = SceneMachine.Editor;
local SM = Editor.SceneManager;
local OP = Editor.ObjectProperties;
local Camera = SceneMachine.Camera;
local Input = SceneMachine.Input;
local Math = SceneMachine.Math;
local CC = SceneMachine.CameraController;

local Vector3 = SceneMachine.Vector3;
local Quaternion = SceneMachine.Quaternion;
local Ray = SceneMachine.Ray;

Gizmos.isUsed = false;
Gizmos.isHighlighted = false;
Gizmos.selectedAxis = 1;            -- x = 1, y = 2, z = 3
Gizmos.activeTransformGizmo = 1;    -- select = 0, move = 1, rotate = 2, scale = 3
Gizmos.space = 1;                   -- world = 0, local = 1
Gizmos.pivot = 0;                   -- center = 0, base(original) = 1 (Only really affects rotation)
Gizmos.LMBPrevious = {};
Gizmos.frames = {};
Gizmos.forward = Vector3:New(1, 0, 0);
Gizmos.right = Vector3:New(0, 1, 0);
Gizmos.up = Vector3:New(0, 0, 1);
Gizmos.previousRotation = Vector3:New();
Gizmos.rotationIncrement = 0;

function Gizmos.Create()
    Gizmos.CreateSelectionGizmo();
    Gizmos.CreateMoveGizmo();
    Gizmos.CreateRotateGizmo();
    Gizmos.CreateScaleGizmo();
    Gizmos.CreateDebugGizmo();
end

function Gizmos.CreateLineProjectionFrame()
	local lineProjectionFrame = CreateFrame("Frame", "lineProjectionFrame", Renderer.projectionFrame)
	lineProjectionFrame:SetFrameStrata(Editor.MAIN_FRAME_STRATA);
	--lineProjectionFrame:SetWidth(Renderer.w);
	--lineProjectionFrame:SetHeight(Renderer.h);
	--lineProjectionFrame:SetPoint("TOPRIGHT", Renderer.projectionFrame, "TOPRIGHT", 0, 0);
    lineProjectionFrame:SetAllPoints(Renderer.projectionFrame);
	lineProjectionFrame.texture = lineProjectionFrame:CreateTexture("Renderer.lineProjectionFrame.texture", "ARTWORK")
	lineProjectionFrame.texture:SetColorTexture(0,0,0,0);
	lineProjectionFrame.texture:SetAllPoints(Renderer.lineProjectionFrame);
	lineProjectionFrame:SetFrameLevel(101);
    lineProjectionFrame:Hide();
    return lineProjectionFrame;
end

function Gizmos.Update()
    if (Gizmos.MoveGizmo == nil) then return end

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

local function indexOfSmallestValue(tbl)
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
            -- check against the rectangle XY
            -- <
            local aX = Gizmos.MoveGizmo.screenSpaceVertices[4][1][1];
            local aY = Gizmos.MoveGizmo.screenSpaceVertices[4][1][2];
            -- >
            local bX = Gizmos.MoveGizmo.screenSpaceVertices[5][1][1];
            local bY = Gizmos.MoveGizmo.screenSpaceVertices[5][1][2];
            -- v
            local cX = Gizmos.MoveGizmo.screenSpaceVertices[5][2][1];
            local cY = Gizmos.MoveGizmo.screenSpaceVertices[5][2][2];
            -- ^
            local dX = Gizmos.MoveGizmo.screenSpaceVertices[1][1][1];
            local dY = Gizmos.MoveGizmo.screenSpaceVertices[1][1][2];
            if (mouseX ~= nil and mouseY ~= nil and aX ~= nil and aY ~= nil and bX ~= nil and bY ~= nil) then
                local inTriangle = Math.isPointInPolygon(mouseX, mouseY, aX, aY, cX, cY, bX, bY, dX, dY);
                if (inTriangle) then
                    Gizmos.isHighlighted = true;
                    Gizmos.selectedAxis = 4;
                    Gizmos.highlightedAxis = 4;
                end
            end

            -- check against the rectangle XZ
            -- <
            local aX = Gizmos.MoveGizmo.screenSpaceVertices[6][1][1];
            local aY = Gizmos.MoveGizmo.screenSpaceVertices[6][1][2];
            -- >
            local bX = Gizmos.MoveGizmo.screenSpaceVertices[7][1][1];
            local bY = Gizmos.MoveGizmo.screenSpaceVertices[7][1][2];
            -- v
            local cX = Gizmos.MoveGizmo.screenSpaceVertices[7][2][1];
            local cY = Gizmos.MoveGizmo.screenSpaceVertices[7][2][2];
            -- ^
            local dX = Gizmos.MoveGizmo.screenSpaceVertices[1][1][1];
            local dY = Gizmos.MoveGizmo.screenSpaceVertices[1][1][2];
            if (mouseX ~= nil and mouseY ~= nil and aX ~= nil and aY ~= nil and bX ~= nil and bY ~= nil) then
                local inTriangle = Math.isPointInPolygon(mouseX, mouseY, aX, aY, cX, cY, bX, bY, dX, dY);
                if (inTriangle) then
                    Gizmos.isHighlighted = true;
                    Gizmos.selectedAxis = 5;
                    Gizmos.highlightedAxis = 5;
                end
            end

            -- check against the rectangle YZ
            -- <
            local aX = Gizmos.MoveGizmo.screenSpaceVertices[8][1][1];
            local aY = Gizmos.MoveGizmo.screenSpaceVertices[8][1][2];
            -- >
            local bX = Gizmos.MoveGizmo.screenSpaceVertices[9][1][1];
            local bY = Gizmos.MoveGizmo.screenSpaceVertices[9][1][2];
            -- v
            local cX = Gizmos.MoveGizmo.screenSpaceVertices[9][2][1];
            local cY = Gizmos.MoveGizmo.screenSpaceVertices[9][2][2];
            -- ^
            local dX = Gizmos.MoveGizmo.screenSpaceVertices[1][1][1];
            local dY = Gizmos.MoveGizmo.screenSpaceVertices[1][1][2];
            if (mouseX ~= nil and mouseY ~= nil and aX ~= nil and aY ~= nil and bX ~= nil and bY ~= nil) then
                local inTriangle = Math.isPointInPolygon(mouseX, mouseY, aX, aY, cX, cY, bX, bY, dX, dY);
                if (inTriangle) then
                    Gizmos.isHighlighted = true;
                    Gizmos.selectedAxis = 6;
                    Gizmos.highlightedAxis = 6;
                end
            end
            
            -- check against the line distances
            if (not Gizmos.isHighlighted) then
                local minDists = { 10000, 10000, 10000 };
                for t = 1, 3, 1 do
                    local aX = Gizmos.MoveGizmo.screenSpaceVertices[t][1][1];
                    local aY = Gizmos.MoveGizmo.screenSpaceVertices[t][1][2];
                    local bX = Gizmos.MoveGizmo.screenSpaceVertices[t][2][1];
                    local bY = Gizmos.MoveGizmo.screenSpaceVertices[t][2][2];

                    if (mouseX ~= nil and mouseY ~= nil and aX ~= nil and aY ~= nil and bX ~= nil and bY ~= nil) then
                        local dist = Math.distToSegment({mouseX, mouseY}, {aX, aY}, {bX, bY});
                        if (dist < 10) then
                            if (minDists[t] > dist) then
                                minDists[t] = dist;
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
                    local dist = Math.distToSegment({mouseX, mouseY}, {aX, aY}, {bX, bY});
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
                    local dist = Math.distToSegment({mouseX, mouseY}, {aX, aY}, {bX, bY});
                    if (dist < 30) then
                        Gizmos.isHighlighted = true;
                        Gizmos.selectedAxis = 1;
                        Gizmos.highlightedAxis = 1;
                    end
                end
            end
        end
    end
end

function Gizmos.VisibilityCheck()
    if (Gizmos.frames["SelectionGizmoFrame"] == nil) then
        return;
    end

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

function Gizmos.UpdateGizmoTransform()

    if (SceneMachine.Gizmos.DebugGizmo.active == true) then
        Gizmos.transformGizmo(SceneMachine.Gizmos.DebugGizmo, SceneMachine.Gizmos.DebugGizmo.position, SceneMachine.Gizmos.DebugGizmo.rotation, 1, {0, 0, 0}, 1, 0);
    end

    if (SM.selectedObject == nil) then
        return;
    end

    local position = SM.selectedObject:GetPosition();
    local rotation = SM.selectedObject:GetRotation();
    local scale = SM.selectedObject:GetScale();

    local xMin, yMin, zMin, xMax, yMax, zMax = SM.selectedObject:GetActiveBoundingBox();
    local bbCenter = {(xMax - xMin) / 2, (yMax - yMin) / 2, (zMax - zMin) / 2};

    Gizmos.transformToAABB(SceneMachine.Gizmos.WireBox, bbCenter);
    Gizmos.transformGizmo(SceneMachine.Gizmos.WireBox, position, rotation, scale, bbCenter, 1, 0);

    if (Gizmos.activeTransformGizmo == 1) then
        -- calculate a scale based on the gizmo distance from the camera (to keep it relatively the same size on screen)
        SceneMachine.Gizmos.MoveGizmo.scale = Vector3.ManhattanDistance(position, Camera.position) / 15;
        Gizmos.transformGizmo(SceneMachine.Gizmos.MoveGizmo, position, rotation, 1, bbCenter, Gizmos.space, Gizmos.pivot);
    elseif (Gizmos.activeTransformGizmo == 2) then
        -- calculate a scale based on the gizmo distance from the camera (to keep it relatively the same size on screen)
        SceneMachine.Gizmos.RotateGizmo.scale = Vector3.ManhattanDistance(position, Camera.position) / 10;
        Gizmos.transformGizmo(SceneMachine.Gizmos.RotateGizmo, position, rotation, 1, bbCenter, Gizmos.space, Gizmos.pivot);
    elseif (Gizmos.activeTransformGizmo == 3) then
        SceneMachine.Gizmos.ScaleGizmo.scale = Vector3.ManhattanDistance(position, Camera.position) / 15;
        Gizmos.transformGizmo(SceneMachine.Gizmos.ScaleGizmo, position, rotation, 1, bbCenter, Gizmos.space, Gizmos.pivot);
    end
end

function Gizmos.MotionToTransform()
    if (Gizmos.isUsed) then
        -- when using the gizmo (clicked), keep it highlighted even if the mouse moves away
        Gizmos.highlightedAxis = Gizmos.selectedAxis;

        local mouseRay = Camera.GetMouseRay();

        if (Gizmos.LMBPrevious.x == nil) then
            Gizmos.LMBPrevious.x = Input.mouseXRaw;
            Gizmos.LMBPrevious.y = Input.mouseYRaw;
        end
        
		local xDiff = Input.mouseXRaw - Gizmos.LMBPrevious.x;
		local yDiff = Input.mouseYRaw - Gizmos.LMBPrevious.y;
        local diff = ((xDiff + yDiff) / 2) / 100;

        if (SM.selectedObject ~= nil) then
            local position = SM.selectedObject:GetPosition();
            local px, py, pz = position.x, position.y, position.z;
            local rotation = SM.selectedObject:GetRotation();
            local rx, ry, rz = rotation.x, rotation.y, rotation.z;
            local s = SM.selectedObject:GetScale();
            local iPoint;
            local axisMoveSpeed = 0.02;
            if (Gizmos.activeTransformGizmo == 1) then
                if (Gizmos.selectedAxis == 1) then
                    -- X --
                    local ssX = Gizmos.MoveGizmo.screenSpaceVertices[1][2][1] - Gizmos.MoveGizmo.screenSpaceVertices[1][1][1];
                    local ssY = Gizmos.MoveGizmo.screenSpaceVertices[1][2][2] - Gizmos.MoveGizmo.screenSpaceVertices[1][1][2];
                    local ssMag = math.sqrt(ssX^2 + ssY^2);
                    if (ssMag == 0) then
                        ssX = 0;
                        ssY = 0;
                    else
                        ssX = ssX / ssMag;
                        ssY = ssY / ssMag;
                    end
                    local dot = Math.dotProduct(xDiff, yDiff, ssX, ssY);
                    local gscale = dot * axisMoveSpeed * Gizmos.MoveGizmo.scale;
                    if (Gizmos.space == 0) then
                        px = px + gscale;
                    elseif (Gizmos.space == 1) then
                        px = px + (gscale * Gizmos.forward.x);
                        py = py + (gscale * Gizmos.forward.y);
                        pz = pz + (gscale * Gizmos.forward.z);
                    end
                elseif (Gizmos.selectedAxis == 2) then
                    -- Y --
                    local ssX = Gizmos.MoveGizmo.screenSpaceVertices[2][2][1] - Gizmos.MoveGizmo.screenSpaceVertices[2][1][1];
                    local ssY = Gizmos.MoveGizmo.screenSpaceVertices[2][2][2] - Gizmos.MoveGizmo.screenSpaceVertices[2][1][2];
                    local ssMag = math.sqrt(ssX^2 + ssY^2);
                    if (ssMag == 0) then
                        ssX = 0;
                        ssY = 0;
                    else
                        ssX = ssX / ssMag;
                        ssY = ssY / ssMag;
                    end
                    local dot = Math.dotProduct(xDiff, yDiff, ssX, ssY);
                    local gscale = dot * axisMoveSpeed * Gizmos.MoveGizmo.scale;
                    if (Gizmos.space == 0) then
                        py = py + gscale;
                    elseif (Gizmos.space == 1) then                    
                        px = px + (gscale * Gizmos.right.x);
                        py = py + (gscale * Gizmos.right.y);
                        pz = pz + (gscale * Gizmos.right.z);
                    end
                elseif (Gizmos.selectedAxis == 3) then
                    -- Z --
                    local ssX = Gizmos.MoveGizmo.screenSpaceVertices[3][2][1] - Gizmos.MoveGizmo.screenSpaceVertices[3][1][1];
                    local ssY = Gizmos.MoveGizmo.screenSpaceVertices[3][2][2] - Gizmos.MoveGizmo.screenSpaceVertices[3][1][2];
                    local ssMag = math.sqrt(ssX^2 + ssY^2);
                    if (ssMag == 0) then
                        ssX = 0;
                        ssY = 0;
                    else
                        ssX = ssX / ssMag;
                        ssY = ssY / ssMag;
                    end
                    local dot = Math.dotProduct(xDiff, yDiff, ssX, ssY);
                    local gscale = dot * axisMoveSpeed * Gizmos.MoveGizmo.scale;
                    if (Gizmos.space == 0) then
                        pz = pz + gscale;
                    elseif (Gizmos.space == 1) then
                        px = px + (gscale * Gizmos.up.x);
                        py = py + (gscale * Gizmos.up.y);
                        pz = pz + (gscale * Gizmos.up.z);
                    end
                elseif (Gizmos.selectedAxis == 4) then
                    -- XY --
                    iPoint = mouseRay:PlaneIntersection(Vector3.zero, Gizmos.up);
                    if (iPoint ~= nil) then
                        px = px + (iPoint.x - Gizmos.previousIPoint.x)
                        py = py + (iPoint.y - Gizmos.previousIPoint.y)
                        pz = pz + (iPoint.z - Gizmos.previousIPoint.z)
                    end
                elseif (Gizmos.selectedAxis == 5) then
                    -- XZ --
                    iPoint = mouseRay:PlaneIntersection(Vector3.zero, Gizmos.right);
                    if (iPoint ~= nil) then
                        px = px + (iPoint.x - Gizmos.previousIPoint.x)
                        py = py + (iPoint.y - Gizmos.previousIPoint.y)
                        pz = pz + (iPoint.z - Gizmos.previousIPoint.z)
                    end
                elseif (Gizmos.selectedAxis == 6) then
                    -- YZ --
                    iPoint = mouseRay:PlaneIntersection(Vector3.zero, Gizmos.forward);
                    if (iPoint ~= nil) then
                        px = px + (iPoint.x - Gizmos.previousIPoint.x)
                        py = py + (iPoint.y - Gizmos.previousIPoint.y)
                        pz = pz + (iPoint.z - Gizmos.previousIPoint.z)
                    end
                end

                if (iPoint and Gizmos.previousIPoint) then
                    Gizmos.previousIPoint.x = iPoint.x;
                    Gizmos.previousIPoint.y = iPoint.y;
                    Gizmos.previousIPoint.z = iPoint.z;
                end

                SM.selectedObject:SetPosition(px, py, pz);
            elseif (Gizmos.activeTransformGizmo == 2) then
                Gizmos.rotationIncrement = Gizmos.rotationIncrement + diff;
                if (Gizmos.selectedAxis == 1) then
                    if (Gizmos.space == 0) then
                        rx = rx + diff;
                    elseif (Gizmos.space == 1) then
                        local rot = Math.multiplyRotations(Gizmos.previousRotation, Vector3:New(Gizmos.rotationIncrement, 0, 0));
                        rx = rot.x;
                        ry = rot.y;
                        rz = rot.z;
                    end
                elseif (Gizmos.selectedAxis == 2) then
                    if (Gizmos.space == 0) then
                        ry = ry + diff;
                        
                        ------------------ TODO: This needs work ----------------
                        --[[
                        if (Gizmos.pivot == 1) then
                            local scale = SM.selectedObject:GetScale();
                            local xMin, yMin, zMin, xMax, yMax, zMax = SM.selectedObject:GetActiveBoundingBox();
                            local bbCenter = {(xMax - xMin) / 2, (yMax - yMin) / 2, (zMax - zMin) / 2};
                            local boundsCenterOffset = bbCenter[3] * scale;
                            local pivotOffset = Vector3:New(0, 0, -boundsCenterOffset);
                            pivotOffset:RotateAroundPivot(Vector3:New(0, 0, 0), Vector3:New(0, diff, 0));

                            --local xMin, yMin, zMin, xMax, yMax, zMax = SM.selectedObject:GetActiveBoundingBox();
                            --local bbCenter = ((zMax - zMin) / 2);
                            --local ppoint = Vector3:New(0, 0, bbCenter);
                            --ppoint:RotateAroundPivot(Vector3:New(0,0,0), Vector3:New(0, diff, 0));
                            --print(zMin .. " " .. zMax)
                            px = px + pivotOffset.x;
                            py = py + pivotOffset.y;
                            pz = pz + pivotOffset.z + bbCenter[3] - diff;
                            SM.selectedObject:SetPosition(px, py, pz);
                        end
                        --]]
                        --[[
                        if (Gizmos.pivot == 1) then
                            local xMin, yMin, zMin, xMax, yMax, zMax = SM.selectedObject:GetActiveBoundingBox();
                            local bbCenter = ((zMax - zMin) / 2) * s;
                            local ppoint = Math.RotateObjectAroundPivot({0, 0, bbCenter}, {0, 0, 0}, {0, diff, 0});
                            px = px + ppoint[1];
                            py = py + ppoint[2];
                            pz = pz + ppoint[3] - bbCenter;
                            SM.selectedObject:SetPosition(px, py, pz);
                        end
                        --]]
                        ---------------------------------------------------------
                    elseif (Gizmos.space == 1) then
                        local rot = Math.multiplyRotations(Gizmos.previousRotation, Vector3:New(0, Gizmos.rotationIncrement, 0));
                        rx = rot.x;
                        ry = rot.y;
                        rz = rot.z;
                    end
                elseif (Gizmos.selectedAxis == 3) then
                    if (Gizmos.space == 0) then
                        rz = rz + diff;
                    elseif (Gizmos.space == 1) then
                        local rot = Math.multiplyRotations(Gizmos.previousRotation, Vector3:New(0, 0, Gizmos.rotationIncrement));
                        rx = rot.x;
                        ry = rot.y;
                        rz = rot.z;
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

        Gizmos.LMBPrevious.x = Input.mouseXRaw;
		Gizmos.LMBPrevious.y = Input.mouseYRaw;
    end

end

function Gizmos.OnLMBDown(x, y)
	Gizmos.LMBPrevious.x = x;
	Gizmos.LMBPrevious.y = y;
    Gizmos.isUsed = true;
    Gizmos.rotationIncrement = 0;

    -- Store initial values so they can be diffed during mouse movement
    -- in order to get smooth transition

    -- store rotation vector
    if (SM.selectedObject ~= nil) then
        local rotation = SM.selectedObject:GetRotation();
        local rx, ry, rz = rotation.x, rotation.y, rotation.z;
        local forward = Math.normalize(Math.rotateVector(rx, ry, rz, 1, 0, 0));
        local right = Math.normalize(Math.rotateVector(rx, ry, rz, 0, 1, 0));
        local up = Math.normalize(Math.rotateVector(rx, ry, rz, 0, 0, 1));
        Gizmos.forward:Set(forward[1], forward[2], forward[3]);
        Gizmos.right:Set(right[1], right[2], right[3]);
        Gizmos.up:Set(up[1], up[2], up[3]);
        Gizmos.previousRotation:Set(rx, ry, rz);
    else
        Gizmos.forward:SetVector3(Vector3.forward);
        Gizmos.right:SetVector3(Vector3.right);
        Gizmos.up:SetVector3(Vector3.up);
        Gizmos.previousRotation:Set(0, 0, 0);
    end

    -- store initial ray intersection
    if (SM.selectedObject ~= nil) then
        local position = SM.selectedObject:GetPosition();
        local mouseRay = Camera.GetMouseRay();
        if (Gizmos.activeTransformGizmo == 1) then
            if (Gizmos.selectedAxis == 1) then
                -- X --
                Gizmos.previousIPoint = mouseRay:PlaneIntersection(Vector3.zero, Gizmos.up) or Gizmos.previousIPoint;
            elseif (Gizmos.selectedAxis == 2) then
                -- Y --
                Gizmos.previousIPoint = mouseRay:PlaneIntersection(Vector3.zero, Gizmos.up) or Gizmos.previousIPoint;
            elseif (Gizmos.selectedAxis == 3) then
                -- Z --
                Gizmos.previousIPoint = mouseRay:PlaneIntersection(Vector3.zero, Gizmos.right) or Gizmos.previousIPoint;
            elseif (Gizmos.selectedAxis == 4) then
                -- XY --
                Gizmos.previousIPoint = mouseRay:PlaneIntersection(Vector3.zero, Gizmos.up);
            elseif (Gizmos.selectedAxis == 5) then
                -- XZ --
                Gizmos.previousIPoint = mouseRay:PlaneIntersection(Vector3.zero, Gizmos.right);
            elseif (Gizmos.selectedAxis == 6) then
                -- YZ --
                Gizmos.previousIPoint = mouseRay:PlaneIntersection(Vector3.zero, Gizmos.forward);
            end
        end

        if (not Gizmos.previousIPoint) then
            Gizmos.previousIPoint = { x = 0, y = 0, z = 0 };
        end
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
        pivotOffset = Vector3:New( 0, 0, 0 );
    elseif (pivot == 1) then
        -- base
        pivotOffset = Vector3:New(0, 0, -boundsCenterOffset);
        pivotOffset:RotateAroundPivot(Vector3:New(0, 0, 0), rotation);
    end

    for q = 1, gizmo.lineCount, 1 do
        for v = 1, 2, 1 do
            if (space == 1) then
                -- local space --
                local rotated = Vector3:New(gizmo.vertices[q][v][1], gizmo.vertices[q][v][2], gizmo.vertices[q][v][3]);
                rotated:RotateAroundPivot(Vector3:New(0, 0, 0), rotation);
                gizmo.transformedVertices[q][v][1] = rotated.x * gizmo.scale * scale + position.x + pivotOffset.x;
                gizmo.transformedVertices[q][v][2] = rotated.y * gizmo.scale * scale + position.y + pivotOffset.y;
                gizmo.transformedVertices[q][v][3] = rotated.z * gizmo.scale * scale + position.z + pivotOffset.z;
            elseif (space == 0) then
                -- world space --
                gizmo.transformedVertices[q][v][1] = gizmo.vertices[q][v][1] * gizmo.scale * scale + position.x + pivotOffset.x;
                gizmo.transformedVertices[q][v][2] = gizmo.vertices[q][v][2] * gizmo.scale * scale + position.y + pivotOffset.y;
                gizmo.transformedVertices[q][v][3] = gizmo.vertices[q][v][3] * gizmo.scale * scale + position.z + pivotOffset.z;
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