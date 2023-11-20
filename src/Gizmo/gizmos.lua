local Gizmos = SceneMachine.Gizmos;
local Renderer = SceneMachine.Renderer;
local Editor = SceneMachine.Editor;
local SM = Editor.SceneManager;
local OP = Editor.ObjectProperties;
local Camera = SceneMachine.Camera;
local Input = SceneMachine.Input;
local Math = SceneMachine.Math;

Gizmos.isUsed = false;
Gizmos.isHighlighted = false;
Gizmos.selectedAxis = 1;            -- x = 1, y = 2, z = 3
Gizmos.activeTransformGizmo = 1;    -- select = 0, move = 1, rotate = 2, scale = 3
Gizmos.space = 1;                   -- world = 0, local = 1
Gizmos.pivot = 0;                   -- center = 0, base(original) = 1 (Only really affects rotation)
Gizmos.LMBPrevious = {};
Gizmos.frames = {};
Gizmos.vectorX = {1,0,0};
Gizmos.vectorY = {0,1,0};
Gizmos.vectorZ = {0,0,1};
Gizmos.savedRotation = {0, 0, 0};
Gizmos.rotationIncrement = 0;

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

    return selected;
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
        SceneMachine.Gizmos.MoveGizmo.scale = Math.manhattanDistance3D(px, py, pz, Camera.X, Camera.Y, Camera.Z) / 15;
        Gizmos.transformGizmo(SceneMachine.Gizmos.MoveGizmo, {px, py, pz}, {rx, ry, rz}, 1, bbCenter, Gizmos.space, Gizmos.pivot);
    elseif (Gizmos.activeTransformGizmo == 2) then
        -- calculate a scale based on the gizmo distance from the camera (to keep it relatively the same size on screen)
        SceneMachine.Gizmos.RotateGizmo.scale = Math.manhattanDistance3D(px, py, pz, Camera.X, Camera.Y, Camera.Z) / 10;
        Gizmos.transformGizmo(SceneMachine.Gizmos.RotateGizmo, {px, py, pz}, {rx, ry, rz}, 1, bbCenter, Gizmos.space, Gizmos.pivot);
    elseif (Gizmos.activeTransformGizmo == 3) then
        SceneMachine.Gizmos.ScaleGizmo.scale = Math.manhattanDistance3D(px, py, pz, Camera.X, Camera.Y, Camera.Z) / 15;
        Gizmos.transformGizmo(SceneMachine.Gizmos.ScaleGizmo, {px, py, pz}, {rx, ry, rz}, 1, bbCenter, Gizmos.space, Gizmos.pivot);
    end
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
                    -- X --
                    local dot = Math.dotProduct(
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
                    -- Y --
                    local dot = Math.dotProduct(
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
                    -- Z --
                    local dot = Math.dotProduct(
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
                elseif (Gizmos.selectedAxis == 4) then
                    -- XY --
                    local xVec = { Gizmos.MoveGizmo.screenSpaceVertices[1][2][1] - Gizmos.MoveGizmo.screenSpaceVertices[1][1][1],
                                    Gizmos.MoveGizmo.screenSpaceVertices[1][2][2] - Gizmos.MoveGizmo.screenSpaceVertices[1][1][2] }
                    local dot = Math.dotProduct(
                        xDiff,
                        yDiff,
                        xVec[1],
                        xVec[2]
                    );
                    local gscale = dot * 0.0001 * Gizmos.MoveGizmo.scale;
                    if (Gizmos.space == 0) then
                        px = px + gscale;
                    elseif (Gizmos.space == 1) then
                        px = px + (gscale * Gizmos.vectorX[1]);
                        py = py + (gscale * Gizmos.vectorX[2]);
                        pz = pz + (gscale * Gizmos.vectorX[3]);
                    end

                    local yVec = { Gizmos.MoveGizmo.screenSpaceVertices[2][2][1] - Gizmos.MoveGizmo.screenSpaceVertices[2][1][1],
                                    Gizmos.MoveGizmo.screenSpaceVertices[2][2][2] - Gizmos.MoveGizmo.screenSpaceVertices[2][1][2] }
                    local dot = Math.dotProduct(
                        xDiff,
                        yDiff,
                        yVec[1],
                        yVec[2]
                    );
                    local gscale = dot * 0.0001 * Gizmos.MoveGizmo.scale;
                    if (Gizmos.space == 0) then
                        py = py + gscale;
                    elseif (Gizmos.space == 1) then                    
                        px = px + (gscale * Gizmos.vectorY[1]);
                        py = py + (gscale * Gizmos.vectorY[2]);
                        pz = pz + (gscale * Gizmos.vectorY[3]);
                    end

                    local halfwayVec = { (Gizmos.MoveGizmo.screenSpaceVertices[2][2][1] - Gizmos.MoveGizmo.screenSpaceVertices[2][1][1]) + (Gizmos.MoveGizmo.screenSpaceVertices[1][2][1] - Gizmos.MoveGizmo.screenSpaceVertices[1][1][1]),
                                            (Gizmos.MoveGizmo.screenSpaceVertices[2][2][2] - Gizmos.MoveGizmo.screenSpaceVertices[2][1][2]) + (Gizmos.MoveGizmo.screenSpaceVertices[1][2][2] - Gizmos.MoveGizmo.screenSpaceVertices[1][1][2]) }
                    local dot = Math.dotProduct(
                        xDiff,
                        yDiff,
                        halfwayVec[1],
                        halfwayVec[2]
                    );
                    local gscale = dot * 0.0001 * Gizmos.MoveGizmo.scale;
                    if (Gizmos.space == 0) then
                        px = px + gscale;
                        py = py + gscale;
                    elseif (Gizmos.space == 1) then    
                        px = px + (gscale * Gizmos.vectorX[1]);
                        py = py + (gscale * Gizmos.vectorX[2]);
                        pz = pz + (gscale * Gizmos.vectorX[3]);                
                        px = px + (gscale * Gizmos.vectorY[1]);
                        py = py + (gscale * Gizmos.vectorY[2]);
                        pz = pz + (gscale * Gizmos.vectorY[3]);
                    end
                elseif (Gizmos.selectedAxis == 5) then
                    -- XZ --
                    local dot = Math.dotProduct(
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
                    local dot = Math.dotProduct(
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
                elseif (Gizmos.selectedAxis == 6) then
                    -- YZ --
                    local dot = Math.dotProduct(
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
                    local dot = Math.dotProduct(
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
                        local rot = Math.multiplyRotations(Gizmos.savedRotation, {Gizmos.rotationIncrement, 0, 0});
                        rx = rot[1];
                        ry = rot[2];
                        rz = rot[3];
                    end
                elseif (Gizmos.selectedAxis == 2) then
                    if (Gizmos.space == 0) then
                        ry = ry + diff;
                        ------------------ TODO: This needs work ----------------
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
                        local rot = Math.multiplyRotations(Gizmos.savedRotation, {0, Gizmos.rotationIncrement, 0});
                        rx = rot[1];
                        ry = rot[2];
                        rz = rot[3];
                    end
                elseif (Gizmos.selectedAxis == 3) then
                    if (Gizmos.space == 0) then
                        rz = rz + diff;
                    elseif (Gizmos.space == 1) then
                        local rot = Math.multiplyRotations(Gizmos.savedRotation, {0, 0, Gizmos.rotationIncrement});
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

function Gizmos.OnLMBDown(x, y)
	Gizmos.LMBPrevious.x = x;
	Gizmos.LMBPrevious.y = y;
    Gizmos.isUsed = true;
    Gizmos.rotationIncrement = 0;

    -- store rotation vector
    if (SM.selectedObject ~= nil) then
        local rotation = SM.selectedObject:GetRotation();
        local rx, ry, rz = rotation.x, rotation.y, rotation.z;
        Gizmos.vectorX = Math.normalize(Math.rotateVector(rx, ry, rz, 1, 0, 0));
        Gizmos.vectorY = Math.normalize(Math.rotateVector(rx, ry, rz, 0, 1, 0));
        Gizmos.vectorZ = Math.normalize(Math.rotateVector(rx, ry, rz, 0, 0, 1));
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
        pivotOffset = { 0, 0, 0 };
    elseif (pivot == 1) then
        -- base
        local point = Math.RotatePointAroundPivot({0, 0, -boundsCenterOffset}, {0, 0, 0}, {rotation[1], rotation[2], rotation[3]});
        pivotOffset = { point[1], point[2], point[3] };
    end

    for q = 1, gizmo.lineCount, 1 do
        for v = 1, 2, 1 do
            if (space == 1) then
                -- local space --
                local rotated = Math.rotatePoint(gizmo.vertices[q][v], rotation, scale);
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