local Gizmos = SceneMachine.Gizmos;
local Renderer = SceneMachine.Renderer;
local Editor = SceneMachine.Editor;
local SM = Editor.SceneManager;
local OP = Editor.ObjectProperties;
local Camera = SceneMachine.Camera;

Gizmos.isUsed = false;
Gizmos.isHighlighted = false;
Gizmos.refresh = false;
Gizmos.selectedAxis = 1;
Gizmos.activeTransformGizmo = 2;
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
    return lineProjectionFrame;
end

local xOfs;
local yOfs;
local selected = false;
function Gizmos.Update()
    local mouseX, mouseY = GetCursorPosition();
    -- calculate mouse relative to frame
    local xOfs = Renderer.projectionFrame:GetLeft();
    local yOfs = Renderer.projectionFrame:GetBottom();

    local curX = mouseX - xOfs;
    local curY = mouseY - yOfs;

    -- Select --
    selected = false;
    
    if not Gizmos.isUsed then
        -- Position --
        if (Gizmos.activeTransformGizmo == 1) then
            for t = 1, 3, 1 do
                local aX = Gizmos.MoveGizmo.screenSpaceVertices[t][1][1];
                local aY = Gizmos.MoveGizmo.screenSpaceVertices[t][1][2];
                local bX = Gizmos.MoveGizmo.screenSpaceVertices[t][2][1];
                local bY = Gizmos.MoveGizmo.screenSpaceVertices[t][2][2];

                local dist = distToSegment({curX, curY}, {aX, aY}, {bX, bY});
                local coneDetail = (Gizmos.MoveGizmo.lineCount - 3) / 3;
                if (dist < 10) then
                    Gizmos.MoveGizmo.faceColors[t][4] = 1.0;
                    for c = 4 + (coneDetail * (t-1)), 4 + (coneDetail * (t)), 1 do
                        Gizmos.MoveGizmo.faceColors[c][4] = 1.0;
                    end
                    selected = true;
                    Gizmos.selectedAxis = t;
                else
                    Gizmos.MoveGizmo.faceColors[t][4] = 0.3;
                    for c = 4 + (coneDetail * (t-1)), 4 + (coneDetail * (t)), 1 do
                        Gizmos.MoveGizmo.faceColors[c][4] = 0.3;
                    end
                end
            end

        -- Rotation --
        elseif (Gizmos.activeTransformGizmo == 2) then

            -- X --
            for t = 1, Gizmos.RotateGizmoX.lineCount, 1 do
                local aX = Gizmos.RotateGizmoX.screenSpaceVertices[t][1][1];
                local aY = Gizmos.RotateGizmoX.screenSpaceVertices[t][1][2];
                local bX = Gizmos.RotateGizmoX.screenSpaceVertices[t][2][1];
                local bY = Gizmos.RotateGizmoX.screenSpaceVertices[t][2][2];

                local dist = distToSegment({curX, curY}, {aX, aY}, {bX, bY});
                if (dist < 10) then
                    selected = true;
                    Gizmos.selectedAxis = 1;
                end
            end

            for t = 1, Gizmos.RotateGizmoX.lineCount, 1 do
                if selected then
                    Gizmos.RotateGizmoX.thickness[t] = 6;
                else
                    Gizmos.RotateGizmoX.thickness[t] = 2;
                end
            end

            -- Y --
            for t = 1, Gizmos.RotateGizmoY.lineCount, 1 do
                local aX = Gizmos.RotateGizmoY.screenSpaceVertices[t][1][1];
                local aY = Gizmos.RotateGizmoY.screenSpaceVertices[t][1][2];
                local bX = Gizmos.RotateGizmoY.screenSpaceVertices[t][2][1];
                local bY = Gizmos.RotateGizmoY.screenSpaceVertices[t][2][2];

                local dist = distToSegment({curX, curY}, {aX, aY}, {bX, bY});
                if (dist < 10) then
                    selected = true;
                    Gizmos.selectedAxis = 2;
                end
            end

            for t = 1, Gizmos.RotateGizmoY.lineCount, 1 do
                if selected then
                    Gizmos.RotateGizmoY.thickness[t] = 6;
                else
                    Gizmos.RotateGizmoY.thickness[t] = 2;
                end
            end

            -- Z --
            for t = 1, Gizmos.RotateGizmoZ.lineCount, 1 do
                local aX = Gizmos.RotateGizmoZ.screenSpaceVertices[t][1][1];
                local aY = Gizmos.RotateGizmoZ.screenSpaceVertices[t][1][2];
                local bX = Gizmos.RotateGizmoZ.screenSpaceVertices[t][2][1];
                local bY = Gizmos.RotateGizmoZ.screenSpaceVertices[t][2][2];

                local dist = distToSegment({curX, curY}, {aX, aY}, {bX, bY});
                if (dist < 10) then
                    selected = true;
                    Gizmos.selectedAxis = 3;
                end
            end

            for t = 1, Gizmos.RotateGizmoZ.lineCount, 1 do
                if selected then
                    Gizmos.RotateGizmoZ.thickness[t] = 6;
                else
                    Gizmos.RotateGizmoZ.thickness[t] = 2;
                end
            end

        -- Scale --
        elseif(Gizmos.activeTransformGizmo == 3) then
            
        end
    end

    if (Gizmos.isUsed or Gizmos.refresh) then
		local curX, curY = GetCursorPosition();

        if (Gizmos.LMBPrevious.x == nil) then
            Gizmos.LMBPrevious.x = curX;
            Gizmos.LMBPrevious.y = curY;
        end
        
		local xDiff = curX - Gizmos.LMBPrevious.x;
		local yDiff = curY - Gizmos.LMBPrevious.y;
		Gizmos.LMBPrevious.x = curX;
		Gizmos.LMBPrevious.y = curY;

        local diff = ((xDiff + yDiff) / 2) / 100;

        if (Gizmos.refresh == true) then
            diff = 0;
        end

        if (SM.selectedObject ~= nil) then
            Gizmos.frames["SelectionGizmoFrame"]:Show();
            if(Gizmos.activeTransformGizmo == 1) then
                Gizmos.frames["MoveGizmoFrame"]:Show();
            end
        else
            Gizmos.frames["SelectionGizmoFrame"]:Hide();
            Gizmos.frames["MoveGizmoFrame"]:Hide();
        end

        if (SM.selectedObject ~= nil) then
            local position = SM.selectedObject:GetPosition();
            local x, y, z = position.x, position.y, position.z;
            
            Gizmos.transformToActorAABB(SceneMachine.Gizmos.WireBox, SM.selectedObject, { SM.selectedObject.position.x, SM.selectedObject.position.y, SM.selectedObject.position.z });
            
            if (Gizmos.activeTransformGizmo == 1) then
                if (Gizmos.selectedAxis == 1) then
                    x = x + diff;
                elseif (Gizmos.selectedAxis == 2) then
                    y = y + diff;
                elseif (Gizmos.selectedAxis == 3) then
                    z = z + diff;
                end

                SM.selectedObject:SetPosition(x, y, z);
                -- TODO: This needs to be done outside of Gizmos.isUsed
                -- calculate a scale based on the gizmo distance from the camera (to keep it relatively the same size on screen)
                --SceneMachine.Gizmos.MoveGizmo.scale = manhattanDistance3D(x, y, z, Camera.X, Camera.Y, Camera.Z) / 10;
                Gizmos.transformGizmo(SceneMachine.Gizmos.MoveGizmo, {x, y, z});
            elseif (Gizmos.activeTransformGizmo == 2) then
                local value;
                local rotation = SM.selectedObject:GetRotation();
                if (Gizmos.selectedAxis == 1) then
                    value = rotation.x + diff;
                    SM.selectedObject:SetRotation(value, rotation.y, rotation.z);
                elseif (Gizmos.selectedAxis == 2) then
                    value = rotation.y + diff;
                    SM.selectedObject:SetRotation(rotation.x, value, rotation.z);
                else
                    value = rotation.z + diff;
                    SM.selectedObject:SetRotation(rotation.x, rotation.y, value);
                end
                Gizmos.transformGizmo(SceneMachine.Gizmos.RotateGizmoX, {x, y, z});
                Gizmos.transformGizmo(SceneMachine.Gizmos.RotateGizmoY, {x, y, z});
                Gizmos.transformGizmo(SceneMachine.Gizmos.RotateGizmoZ, {x, y, z});
                -- rotate the gizmos
            elseif (Gizmos.activeTransformGizmo == 3) then

            end

            OP.Refresh();
        end
    end

    Gizmos.isHighlighted = selected;
    Gizmos.refresh = false;
end

function Gizmos.OnLMBDown(x, y)
	Gizmos.LMBPrevious.x = x;
	Gizmos.LMBPrevious.y = y;
    --local x, y, z = Renderer.selectedActor:GetPosition();
    --Gizmos.previousPosition = {x, y, z};
    Gizmos.isUsed = true;
end

function Gizmos.OnLMBUp()
    Gizmos.isUsed = false;
end

function Gizmos.transformGizmo(gizmo, position)
    for q = 1, gizmo.lineCount, 1 do
        for v = 1, 2, 1 do
            gizmo.transformedVertices[q][v][1] = (gizmo.vertices[q][v][1] * gizmo.scale) + position[1];
            gizmo.transformedVertices[q][v][2] = (gizmo.vertices[q][v][2] * gizmo.scale) + position[2];
            gizmo.transformedVertices[q][v][3] = (gizmo.vertices[q][v][3] * gizmo.scale) + position[3];
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