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

function Gizmos.MotionToTransform()
    if (Gizmos.isUsed or Gizmos.refresh) then
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
            Gizmos.transformToActorAABB(SceneMachine.Gizmos.WireBox, SM.selectedObject, { SM.selectedObject.position.x, SM.selectedObject.position.y, SM.selectedObject.position.z });
            
            local xMin, yMin, zMin, xMax, yMax, zMax = SM.selectedObject:GetActiveBoundingBox();
            local bbCenter = {(xMax - xMin) / 2, (yMax - yMin) / 2, (zMax - zMin) / 2};

            local position = SM.selectedObject:GetPosition();
            local px, py, pz = position.x, position.y, position.z;
            local rotation = SM.selectedObject:GetRotation();
            local rx, ry, rz = rotation.x, rotation.y, rotation.z;

            if (Gizmos.activeTransformGizmo == 1) then
                if (Gizmos.selectedAxis == 1) then
                    local dot = dotProduct(
                        curX - Gizmos.LMBPrevious.x,
                        curY - Gizmos.LMBPrevious.y,
                        Gizmos.MoveGizmo.screenSpaceVertices[1][2][1] - Gizmos.MoveGizmo.screenSpaceVertices[1][1][1],
                        Gizmos.MoveGizmo.screenSpaceVertices[1][2][2] - Gizmos.MoveGizmo.screenSpaceVertices[1][1][2]
                    );
                    px = px + (dot / 2000); -- TODO : this divide needs to be based on how close the camera is to the object, or better yet the gizmo scale (when that works)
                elseif (Gizmos.selectedAxis == 2) then
                    local dot = dotProduct(
                        curX - Gizmos.LMBPrevious.x,
                        curY - Gizmos.LMBPrevious.y,
                        Gizmos.MoveGizmo.screenSpaceVertices[2][2][1] - Gizmos.MoveGizmo.screenSpaceVertices[2][1][1],
                        Gizmos.MoveGizmo.screenSpaceVertices[2][2][2] - Gizmos.MoveGizmo.screenSpaceVertices[2][1][2]
                    );
                    py = py + (dot / 2000);
                elseif (Gizmos.selectedAxis == 3) then
                    local dot = dotProduct(
                        curX - Gizmos.LMBPrevious.x,
                        curY - Gizmos.LMBPrevious.y,
                        Gizmos.MoveGizmo.screenSpaceVertices[3][2][1] - Gizmos.MoveGizmo.screenSpaceVertices[3][1][1],
                        Gizmos.MoveGizmo.screenSpaceVertices[3][2][2] - Gizmos.MoveGizmo.screenSpaceVertices[3][1][2]
                    );
                    pz = pz + (dot / 2000);
                end

                if (Gizmos.refresh ~= true) then
                    SM.selectedObject:SetPosition(px, py, pz);
                end
                -- TODO: This needs to be done outside of Gizmos.isUsed
                -- calculate a scale based on the gizmo distance from the camera (to keep it relatively the same size on screen)
                --SceneMachine.Gizmos.MoveGizmo.scale = manhattanDistance3D(x, y, z, Camera.X, Camera.Y, Camera.Z) / 10;
                Gizmos.transformGizmo(SceneMachine.Gizmos.MoveGizmo, {px, py, pz}, {rx, ry, rz}, bbCenter);
            elseif (Gizmos.activeTransformGizmo == 2) then

                if (Gizmos.selectedAxis == 1) then
                    rx = rx + diff;
                elseif (Gizmos.selectedAxis == 2) then
                    ry = ry + diff;
                elseif (Gizmos.selectedAxis == 3) then
                    rz = rz + diff;
                end

                if (Gizmos.refresh ~= true) then
                    SM.selectedObject:SetRotation(rx, ry, rz);
                end
                Gizmos.transformGizmo(SceneMachine.Gizmos.RotateGizmo, {px, py, pz}, {rx, ry, rz}, bbCenter);
            elseif (Gizmos.activeTransformGizmo == 3) then

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
end

function Gizmos.OnLMBUp()
    Gizmos.isUsed = false;
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

function Gizmos.transformGizmo(gizmo, position, rotation, boundsCenter)
    for q = 1, gizmo.lineCount, 1 do
        for v = 1, 2, 1 do
            local rotated = rotatePoint(gizmo.vertices[q][v], rotation);
            gizmo.transformedVertices[q][v][1] = rotated[1] * gizmo.scale + position[1];
            gizmo.transformedVertices[q][v][2] = rotated[2] * gizmo.scale + position[2];
            gizmo.transformedVertices[q][v][3] = rotated[3] * gizmo.scale + position[3] + boundsCenter[3];
        end
    end
end

function Gizmos.transformToActorAABB(gizmo, object, position)

    xMin, yMin, zMin, xMax, yMax, zMax = object:GetActiveBoundingBox();

    if (xMax == nil) then return; end

    local chX = (xMax - xMin) / 2;
    local chY = (yMax - yMin) / 2;
    local chZ = (zMax - zMin) / 2;

    -- TODO : recreating this every frame is a bad idea
    -- Should have it only update this bit when the gizmo is set active on an actor
    gizmo.transformedVertices =
    {
        {{-chX, -chY, -chZ}, {chX, -chY, -chZ}},
        {{chX, -chY, -chZ}, {chX, -chY, chZ}},
        {{chX, -chY, chZ}, {-chX, -chY, chZ}},
        {{-chX, -chY, chZ}, {-chX, -chY, -chZ}},
    
        -- Top face
        {{-chX, chY, -chZ}, {chX, chY, -chZ}},
        {{chX, chY, -chZ}, {chX, chY, chZ}},
        {{chX, chY, chZ}, {-chX, chY, chZ}},
        {{-chX, chY, chZ}, {-chX, chY, -chZ}},
    
        -- Connecting edges
        {{-chX, -chY, -chZ}, {-chX, chY, -chZ}},
        {{chX, -chY, -chZ}, {chX, chY, -chZ}},
        {{chX, -chY, chZ}, {chX, chY, chZ}},
        {{-chX, -chY, chZ}, {-chX, chY, chZ}}
    }

    for q = 1, gizmo.lineCount, 1 do
        for v = 1, 2, 1 do
            gizmo.transformedVertices[q][v][1] = gizmo.transformedVertices[q][v][1] + position[1];
            gizmo.transformedVertices[q][v][2] = gizmo.transformedVertices[q][v][2] + position[2];
            gizmo.transformedVertices[q][v][3] = gizmo.transformedVertices[q][v][3] + position[3] + chZ;
        end
    end
end