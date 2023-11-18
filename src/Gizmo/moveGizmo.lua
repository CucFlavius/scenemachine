local Gizmos = SceneMachine.Gizmos;

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
            {{0,0,0}, {1,0,0}}, -- X
            {{0,0,0}, {0,1,0}}, -- Y
            {{0,0,0}, {0,0,1}}, -- Z
        };
        transformedVertices =
        {
            {{0,0,0}, {1,0,0}}, -- X
            {{0,0,0}, {0,1,0}}, -- Y
            {{0,0,0}, {0,0,1}}, -- Z
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

    local pointsX = calculateCirclePoints(0.9, 0, 0, radius, coneDetail, "x");
    local i = 1;
    for c = 4, 4 + coneDetail, 1 do
        Gizmos.MoveGizmo.vertices[c] = {{1,0,0},pointsX[i]};
        Gizmos.MoveGizmo.transformedVertices[c] = {{0,0,0}, {1,0,0}};
        Gizmos.MoveGizmo.screenSpaceVertices[c] = {{0,0}, {0,0}};
        Gizmos.MoveGizmo.faceColors[c] = {1,0,0,1};
        i = i + 1;
    end

    local pointsY = calculateCirclePoints(0, 0.9, 0, radius, coneDetail, "y");
    i = 1;
    for c = 4 + coneDetail, 4 + (coneDetail * 2), 1 do
        Gizmos.MoveGizmo.vertices[c] = {{0,1,0},pointsY[i]};
        Gizmos.MoveGizmo.transformedVertices[c] = {{0,0,0}, {0,1,0}};
        Gizmos.MoveGizmo.screenSpaceVertices[c] = {{0,0}, {0,0}};
        Gizmos.MoveGizmo.faceColors[c] = {0,1,0,1};
        i = i + 1;
    end

    local pointsZ = calculateCirclePoints(0, 0, 0.9, radius, coneDetail, "z");
    i = 1;
    for c = 4 + (coneDetail * 2), 4 + (coneDetail * 3), 1 do
        Gizmos.MoveGizmo.vertices[c] = {{0,0,1},pointsZ[i]};
        Gizmos.MoveGizmo.transformedVertices[c] = {{0,0,0}, {0,0,1}};
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
