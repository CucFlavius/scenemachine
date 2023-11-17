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

function Gizmos.CreateSelectionGizmo()
    -- Frame --
    local lineProjectionFrame = Gizmos.CreateLineProjectionFrame();
    Gizmos.frames["SelectionGizmoFrame"] = lineProjectionFrame;

    -- Lines --
    Gizmos.WireBox.lines = {};
    for t = 1, Gizmos.WireBox.lineCount, 1 do
        Gizmos.WireBox.lines[t] = lineProjectionFrame:CreateLine(nil, nil, nil);
        Gizmos.WireBox.lines[t]:SetThickness(1.5);
        Gizmos.WireBox.lines[t]:SetTexture("Interface\\Addons\\scenemachine\\static\\textures\\dashedLine.png", "REPEAT", "REPEAT", "NEAREST");
    end
end

local function calculateCirclePoints(centerX, centerY, centerZ, radius, numPoints, axis)
    local points = {}

    for i = 1, numPoints do
        local theta = (i - 1) * (2 * math.pi) / numPoints
        local x, y, z;

        if axis == "x" then
            x = centerX;
            y = centerY + radius * math.cos(theta);
            z = centerZ + radius * math.sin(theta);
        elseif axis == "y" then
            x = centerX + radius * math.cos(theta);
            y = centerY;
            z = centerZ + radius * math.sin(theta);
        elseif axis == "z" then
            x = centerX + radius * math.cos(theta);
            y = centerY + radius * math.sin(theta);
            z = centerZ;
        else
            error("Invalid axis. Choose 'x', 'y', or 'z'.");
        end

        table.insert(points, {x, y, z});
    end

    return points
end

function Gizmos.CreateMoveGizmo()
    local coneDetail = 10;
    local emptySSVertex = {{0,0}, {0,0}};
    local emptyVertex = {{0,0,0}, {0,0,0}};
    Gizmos.MoveGizmo = 
    {
        lineCount = 3 + (coneDetail * 3);
        scale = 10;
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
            {1,0,0,1},
            {0,1,0,1},
            {0,0,1,1},
        };
        lineRefs = {};
        lineDepths = {};
    }

    -- Create cone vertices --
    -- calculateCirclePoints(centerX, centerY, centerZ, radius, numPoints, axis)
    local radius = 0.02;
    local pointsY = calculateCirclePoints(0, 0.9, 0, radius, coneDetail, "y");
    local i = 1;
    for c = 4, 4 + coneDetail, 1 do
        Gizmos.MoveGizmo.vertices[c] = {{0,1,0},pointsY[i]};
        Gizmos.MoveGizmo.transformedVertices[c] = {{0,0,0}, {0,1,0}}; -- X
        Gizmos.MoveGizmo.screenSpaceVertices[c] = {{0,0}, {0,0}};
        Gizmos.MoveGizmo.faceColors[c] = {1,0,0,1};
        i = i + 1;

    end
    local pointsZ = calculateCirclePoints(0, 0, 0.9, radius, coneDetail, "z");
    i = 1;
    for c = 4 + coneDetail, 4 + (coneDetail * 2), 1 do
        Gizmos.MoveGizmo.vertices[c] = {{0,0,1},pointsZ[i]};
        Gizmos.MoveGizmo.transformedVertices[c] = {{0,0,0}, {0,0,1}}; -- Y
        Gizmos.MoveGizmo.screenSpaceVertices[c] = {{0,0}, {0,0}};
        Gizmos.MoveGizmo.faceColors[c] = {0,1,0,1};
        i = i + 1;
        
    end
    local pointsX = calculateCirclePoints(0.9, 0, 0, radius, coneDetail, "x");
    i = 1;
    for c = 4 + (coneDetail * 2), 4 + (coneDetail * 3), 1 do
        Gizmos.MoveGizmo.vertices[c] = {{1,0,0},pointsX[i]};
        Gizmos.MoveGizmo.transformedVertices[c] = {{0,0,0}, {1,0,0}}; -- Z
        Gizmos.MoveGizmo.screenSpaceVertices[c] = {{0,0}, {0,0}};
        Gizmos.MoveGizmo.faceColors[c] = {0,0,1,1};
        i = i + 1;
    end

    -- Frame --
    local lineProjectionFrame = Gizmos.CreateLineProjectionFrame();
    Gizmos.frames["MoveGizmoFrame"] = lineProjectionFrame;

    -- Lines --
    Gizmos.MoveGizmo.lines = {};
    for t = 1, Gizmos.MoveGizmo.lineCount, 1 do
        Gizmos.MoveGizmo.lines[t] = lineProjectionFrame:CreateLine(nil, nil, nil);
        Gizmos.MoveGizmo.lines[t]:SetThickness(2.5);
        Gizmos.MoveGizmo.lines[t]:SetTexture("Interface\\Addons\\scenemachine\\static\\textures\\line.png", "REPEAT", "REPEAT", "NEAREST");
    end
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
                    y = y + diff;
                elseif (Gizmos.selectedAxis == 2) then
                    z = z + diff;
                elseif (Gizmos.selectedAxis == 3) then
                    x = x + diff;
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

local ch = 0.5;

Gizmos.WireBox = 
{
    lineCount = 12;
    scale = 1;
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
    lineRefs = {};
    lineDepths = {};
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
    Gizmos.RotateGizmoX.lineCount = (pointCount - 1);
    Gizmos.RotateGizmoX.vertices = {};
    Gizmos.RotateGizmoX.scale = 1;
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
    Gizmos.RotateGizmoY.lineCount = (pointCount - 1);
    Gizmos.RotateGizmoY.vertices = {};
    Gizmos.RotateGizmoY.scale = 1;
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
    Gizmos.RotateGizmoZ.lineCount = (pointCount - 1);
    Gizmos.RotateGizmoZ.vertices = {};
    Gizmos.RotateGizmoZ.scale = 1;
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