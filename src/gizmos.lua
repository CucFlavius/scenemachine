local Gizmos = SceneMachine.Gizmos;
local Renderer = SceneMachine.Renderer;
local Editor = SceneMachine.Editor;
local SM = Editor.SceneManager;

Gizmos.isUsed = false;
Gizmos.isHighlighted = false;
Gizmos.refresh = false;
Gizmos.selectedAxis = 1;
Gizmos.activeTransformGizmo = 1;
Gizmos.LMBPrevious = {};

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

local xOfs;
local yOfs;
local curX, curY;
local selected = false;
function Gizmos.Update()
    xOfs = Renderer.projectionFrame:GetLeft();
    yOfs = Renderer.projectionFrame:GetBottom();

    curX, curY = GetCursorPosition();
    curX = curX - xOfs;
    curY = curY - yOfs;

    -- Select --
    selected = false;
    
    if not Gizmos.isUsed then
        -- Position --
        if (Gizmos.activeTransformGizmo == 1) then
            for t = 1, Gizmos.MoveGizmo.lines, 1 do
                local aX = Gizmos.MoveGizmo.screenSpaceVertices[t][1][1];
                local aY = Gizmos.MoveGizmo.screenSpaceVertices[t][1][2];
                local bX = Gizmos.MoveGizmo.screenSpaceVertices[t][2][1];
                local bY = Gizmos.MoveGizmo.screenSpaceVertices[t][2][2];

                local dist = distToSegment({curX, curY}, {aX, aY}, {bX, bY});
                if (dist < 10) then
                    Gizmos.MoveGizmo.thickness[t] = 6;
                    selected = true;
                    Gizmos.selectedAxis = t;
                else
                    Gizmos.MoveGizmo.thickness[t] = 2;
                end
            end

        -- Rotation --
        elseif (Gizmos.activeTransformGizmo == 2) then

            -- X --
            for t = 1, Gizmos.RotateGizmoX.lines, 1 do
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

            for t = 1, Gizmos.RotateGizmoX.lines, 1 do
                if selected then
                    Gizmos.RotateGizmoX.thickness[t] = 6;
                else
                    Gizmos.RotateGizmoX.thickness[t] = 2;
                end
            end

            -- Y --
            for t = 1, Gizmos.RotateGizmoY.lines, 1 do
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

            for t = 1, Gizmos.RotateGizmoY.lines, 1 do
                if selected then
                    Gizmos.RotateGizmoY.thickness[t] = 6;
                else
                    Gizmos.RotateGizmoY.thickness[t] = 2;
                end
            end

            -- Z --
            for t = 1, Gizmos.RotateGizmoZ.lines, 1 do
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

            for t = 1, Gizmos.RotateGizmoZ.lines, 1 do
                if selected then
                    Gizmos.RotateGizmoZ.thickness[t] = 6;
                else
                    Gizmos.RotateGizmoZ.thickness[t] = 2;
                end
            end
        elseif(Gizmos.activeTransformGizmo == 3) then
            
        end
    end

    if (Gizmos.isUsed or Gizmos.refresh) then
		local x, y = GetCursorPosition();

        if (Gizmos.LMBPrevious.x == nil) then
            Gizmos.LMBPrevious.x = x;
            Gizmos.LMBPrevious.y = y;
        end
        
		local xDiff = x - Gizmos.LMBPrevious.x;
		local yDiff = y - Gizmos.LMBPrevious.y;
		Gizmos.LMBPrevious.x = x;
		Gizmos.LMBPrevious.y = y;

        local diff = ((xDiff + yDiff) / 2) / 100;

        if (Gizmos.refresh == true) then
            diff = 0;
        end

        if (SM.selectedObject ~= nil) then
            local position = SM.selectedObject:GetPosition();
            local x, y, z = position.x, position.y, position.z;
            
            Gizmos.transformToActorAABB(SceneMachine.Gizmos.WireBox, SM.selectedObject, { SM.selectedObject.position.x, SM.selectedObject.position.y, SM.selectedObject.position.z });
            
            if(Gizmos.activeTransformGizmo == 1) then
                if (Gizmos.selectedAxis == 1) then
                    y = y + diff;
                elseif (Gizmos.selectedAxis == 2) then
                    z = z + diff;
                else
                    x = x + diff;
                end

                SM.selectedObject:SetPosition(x, y, z);
                Gizmos.transformGizmo(SceneMachine.Gizmos.MoveGizmo, {x, y, z});
                Gizmos.transformGizmo(SceneMachine.Gizmos.RotateGizmoX, {x, y, z});
                Gizmos.transformGizmo(SceneMachine.Gizmos.RotateGizmoY, {x, y, z});
                Gizmos.transformGizmo(SceneMachine.Gizmos.RotateGizmoZ, {x, y, z});
            elseif(Gizmos.activeTransformGizmo == 2) then
                local x;
                if (Gizmos.selectedAxis == 1) then
                    x = SM.selectedObject:GetRoll() + diff;
                    SM.selectedObject:SetRoll(x);
                elseif (Gizmos.selectedAxis == 2) then
                    x = SM.selectedObject:GetPitch() + diff;
                    SM.selectedObject:SetPitch(x);
                else
                    x = SM.selectedObject:GetYaw() + diff;
                    SM.selectedObject:SetYaw(x);
                end
                -- rotate the gizmos
            elseif(Gizmos.activeTransformGizmo == 3) then

            end
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
    for q = 1, gizmo.lines, 1 do
        for v = 1, 2, 1 do
            gizmo.transformedVertices[q][v][1] = gizmo.vertices[q][v][1] + position[1];
            gizmo.transformedVertices[q][v][2] = gizmo.vertices[q][v][2] + position[2];
            gizmo.transformedVertices[q][v][3] = gizmo.vertices[q][v][3] + position[3];
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

    for q = 1, gizmo.lines, 1 do
        for v = 1, 2, 1 do
            gizmo.transformedVertices[q][v][1] = gizmo.transformedVertices[q][v][1] + position[1];
            gizmo.transformedVertices[q][v][2] = gizmo.transformedVertices[q][v][2] + position[2];
            gizmo.transformedVertices[q][v][3] = gizmo.transformedVertices[q][v][3] + position[3] + chZ;
        end
    end
end

Gizmos.MoveGizmo = 
{
	lines = 3;
    thickness = {2, 2, 2};
	vertices = 
	{
		{{0,0,0}, {0,1,0}}, -- X
        {{0,0,0}, {0,0,1}}, -- Y
		{{0,0,0}, {1,0,0}}, -- Z
	};
    transformedVertices =
    {
		{{0,0,0}, {0,1,0}}, -- X
        {{0,0,0}, {0,0,1}}, -- Y
		{{0,0,0}, {1,0,0}}, -- Z
    };
    screenSpaceVertices = 
    {
        {{0,0}, {0,0}},
        {{0,0}, {0,0}},
        {{0,0}, {0,0}},
    };
	faceColors = 
	{
		{1,0,0},
		{0,1,0},
		{0,0,1},
	};
}

local ch = 0.5;
local wireBoxThickness = 0.8;

Gizmos.WireBox = 
{
    lines = 12;
    thickness = { wireBoxThickness, wireBoxThickness, wireBoxThickness, wireBoxThickness, wireBoxThickness, wireBoxThickness,
                wireBoxThickness, wireBoxThickness, wireBoxThickness, wireBoxThickness, wireBoxThickness, wireBoxThickness };
    vertices = 
    {
        -- Bottom face
        {{-ch, -ch, -ch}, {ch, -ch, -ch}},
        {{ch, -ch, -ch}, {ch, -ch, ch}},
        {{ch, -ch, ch}, {-ch, -ch, ch}},
        {{-ch, -ch, ch}, {-ch, -ch, -ch}},

        -- Top face
        {{-ch, ch, -ch}, {ch, ch, -ch}},
        {{ch, ch, -ch}, {ch, ch, ch}},
        {{ch, ch, ch}, {-ch, ch, ch}},
        {{-ch, ch, ch}, {-ch, ch, -ch}},

        -- Connecting edges
        {{-ch, -ch, -ch}, {-ch, ch, -ch}},
        {{ch, -ch, -ch}, {ch, ch, -ch}},
        {{ch, -ch, ch}, {ch, ch, ch}},
        {{-ch, -ch, ch}, {-ch, ch, ch}}
    };
    transformedVertices =
    {
        -- Bottom face
        {{-ch, -ch, -ch}, {ch, -ch, -ch}},
        {{ch, -ch, -ch}, {ch, -ch, ch}},
        {{ch, -ch, ch}, {-ch, -ch, ch}},
        {{-ch, -ch, ch}, {-ch, -ch, -ch}},

        -- Top face
        {{-ch, ch, -ch}, {ch, ch, -ch}},
        {{ch, ch, -ch}, {ch, ch, ch}},
        {{ch, ch, ch}, {-ch, ch, ch}},
        {{-ch, ch, ch}, {-ch, ch, -ch}},

        -- Connecting edges
        {{-ch, -ch, -ch}, {-ch, ch, -ch}},
        {{ch, -ch, -ch}, {ch, ch, -ch}},
        {{ch, -ch, ch}, {ch, ch, ch}},
        {{-ch, -ch, ch}, {-ch, ch, ch}}
    };
    screenSpaceVertices = 
    {
        {{0,0}, {0,0}},
        {{0,0}, {0,0}},
        {{0,0}, {0,0}},
        {{0,0}, {0,0}},
        {{0,0}, {0,0}},
        {{0,0}, {0,0}},
        {{0,0}, {0,0}},
        {{0,0}, {0,0}},
        {{0,0}, {0,0}},
        {{0,0}, {0,0}},
        {{0,0}, {0,0}},
        {{0,0}, {0,0}},
    };
	faceColors = 
	{
		{1,1,1},
		{1,1,1},
		{1,1,1},
        {1,1,1},
		{1,1,1},
		{1,1,1},
        {1,1,1},
		{1,1,1},
		{1,1,1},
        {1,1,1},
		{1,1,1},
		{1,1,1},
	};
}

Gizmos.RotateGizmoX = {}
Gizmos.RotateGizmoY = {}
Gizmos.RotateGizmoZ = {}
local segments = 40;
local radius = 1;
local rad;
function Gizmos.buildRotateGizmo()
    local pointCount = segments + 1;
    local points = {}

    -- X
    for i = 1, pointCount, 1 do
        rad = math.rad(i * 360 / segments);
        points[i] = {0, math.sin(rad) * radius, math.cos(rad) * radius};
    end
    Gizmos.RotateGizmoX.lines = (pointCount - 1);
    Gizmos.RotateGizmoX.vertices = {};
    Gizmos.RotateGizmoX.transformedVertices = {};
    Gizmos.RotateGizmoX.screenSpaceVertices = {};
    Gizmos.RotateGizmoX.faceColors = {};
    Gizmos.RotateGizmoX.thickness = {};

    for v = 1, pointCount, 1 do
        if (v == pointCount - 1) then
            Gizmos.RotateGizmoX.vertices[v] = {points[v], points[1]};
            Gizmos.RotateGizmoX.transformedVertices[v] = {points[v], points[1]};
        else
            Gizmos.RotateGizmoX.vertices[v] = {points[v], points[v + 1]};
            Gizmos.RotateGizmoX.transformedVertices[v] = {points[v], points[v + 1]};
        end
        Gizmos.RotateGizmoX.screenSpaceVertices[v] = {{0, 0}, {0, 0}};
        Gizmos.RotateGizmoX.faceColors[v] = {1, 0, 0};
        Gizmos.RotateGizmoX.thickness[v] = 1;
    end

    -- Y
    for i = 1, pointCount, 1 do
        rad = math.rad(i * 360 / segments);
        points[i] = {math.sin(rad) * radius, 0, math.cos(rad) * radius};
    end
    Gizmos.RotateGizmoY.lines = (pointCount - 1);
    Gizmos.RotateGizmoY.vertices = {};
    Gizmos.RotateGizmoY.transformedVertices = {};
    Gizmos.RotateGizmoY.screenSpaceVertices = {};
    Gizmos.RotateGizmoY.faceColors = {};
    Gizmos.RotateGizmoY.thickness = {};

    for v = 1, pointCount, 1 do
        if (v == pointCount - 1) then
            Gizmos.RotateGizmoY.vertices[v] = {points[v], points[1]};
            Gizmos.RotateGizmoY.transformedVertices[v] = {points[v], points[1]};
        else
            Gizmos.RotateGizmoY.vertices[v] = {points[v], points[v + 1]};
            Gizmos.RotateGizmoY.transformedVertices[v] = {points[v], points[v + 1]};
        end
        Gizmos.RotateGizmoY.screenSpaceVertices[v] = {{0, 0}, {0, 0}};
        Gizmos.RotateGizmoY.faceColors[v] = {0, 1, 0};
        Gizmos.RotateGizmoY.thickness[v] = 1;
    end

    -- Z
    for i = 1, pointCount, 1 do
        rad = math.rad(i * 360 / segments);
        points[i] = {math.sin(rad) * radius, math.cos(rad) * radius, 0};
    end
    Gizmos.RotateGizmoZ.lines = (pointCount - 1);
    Gizmos.RotateGizmoZ.vertices = {};
    Gizmos.RotateGizmoZ.transformedVertices = {};
    Gizmos.RotateGizmoZ.screenSpaceVertices = {};
    Gizmos.RotateGizmoZ.faceColors = {};
    Gizmos.RotateGizmoZ.thickness = {};

    for v = 1, pointCount, 1 do
        if (v == pointCount - 1) then
            Gizmos.RotateGizmoZ.vertices[v] = {points[v], points[1]};
            Gizmos.RotateGizmoZ.transformedVertices[v] = {points[v], points[1]};
        else
            Gizmos.RotateGizmoZ.vertices[v] = {points[v], points[v + 1]};
            Gizmos.RotateGizmoZ.transformedVertices[v] = {points[v], points[v + 1]};
        end
        Gizmos.RotateGizmoZ.screenSpaceVertices[v] = {{0, 0}, {0, 0}};
        Gizmos.RotateGizmoZ.faceColors[v] = {0, 0, 1};
        Gizmos.RotateGizmoZ.thickness[v] = 1;
    end
end

Gizmos.buildRotateGizmo();