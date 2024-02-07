local Gizmos = SceneMachine.Gizmos;
local Vector3 = SceneMachine.Vector3;
local Resources = SceneMachine.Resources;

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
    local ch = 0.3;
    Gizmos.MoveGizmo = 
    {
        coneDetail = coneDetail;
        lineCount = 3 + 6 + (coneDetail * 3);
        scale = 10;
        vertices = 
        {
            {{0,0,0}, {1,0,0}}, -- X
            {{0,0,0}, {0,1,0}}, -- Y
            {{0,0,0}, {0,0,1}}, -- Z

            -- XY
            {{ch,0,0}, {ch,ch,0}},
            {{0,ch,0}, {ch,ch,0}},

            -- XZ
            {{ch,0,0}, {ch,0,ch}},
            {{0,0,ch}, {ch,0,ch}},

            -- YZ
            {{0,ch,0}, {0,ch,ch}},
            {{0,0,ch}, {0,ch,ch}},
        };
        transformedVertices = {};
        screenSpaceVertices = {};
        faceColors = 
        {
            {1,0,0,1},
            {0,1,0,1},
            {0,0,1,1},

            {1,1,0,1},
            {1,1,0,1},
            {1,1,0,1},
            {1,1,0,1},
            {1,1,0,1},
            {1,1,0,1},
        };
        lines = {};
        lineDepths = {};
    }

    local lineProjectionFrame = Gizmos.CreateLineProjectionFrame();
    Gizmos.frames["MoveGizmoFrame"] = lineProjectionFrame;

    -- Fill tables --
    for v = 1, #Gizmos.MoveGizmo.vertices, 1 do
        Gizmos.MoveGizmo.transformedVertices[v] = {{0,0,0}, {0,0,0}};
        Gizmos.MoveGizmo.screenSpaceVertices[v] = {{0,0}, {0,0}};
    end

    -- Lines --
    for t = 1, Gizmos.MoveGizmo.lineCount + 1, 1 do
        Gizmos.MoveGizmo.lines[t] = lineProjectionFrame:CreateLine(nil, nil, nil);
        Gizmos.MoveGizmo.lines[t]:SetThickness(2.5);
        Gizmos.MoveGizmo.lines[t]:SetTexture(Resources.textures["Line"], "REPEAT", "REPEAT", "NEAREST");
    end

    -- setting the axis on the main 3 lines
    Gizmos.MoveGizmo.lines[1].axis = 1;
    Gizmos.MoveGizmo.lines[2].axis = 2;
    Gizmos.MoveGizmo.lines[3].axis = 3;
    -- setting the axis on XY
    Gizmos.MoveGizmo.lines[4].axis = 4;
    Gizmos.MoveGizmo.lines[5].axis = 4;
    -- setting the axis on XZ
    Gizmos.MoveGizmo.lines[6].axis = 5;
    Gizmos.MoveGizmo.lines[7].axis = 5;
    -- setting the axis on YZ
    Gizmos.MoveGizmo.lines[8].axis = 6;
    Gizmos.MoveGizmo.lines[9].axis = 6;

    -- Create cone vertices --
    -- calculateCirclePoints(centerX, centerY, centerZ, radius, numPoints, axis)
    local radius = 0.02;

    local pointsX = calculateCirclePoints(0.9, 0, 0, radius, coneDetail, "x");
    local i = 1;
    local iOffs = 4 + 6;
    for c = iOffs, iOffs + coneDetail, 1 do
        Gizmos.MoveGizmo.vertices[c] = {{1,0,0},pointsX[i]};
        Gizmos.MoveGizmo.transformedVertices[c] = {{0,0,0}, {1,0,0}};
        Gizmos.MoveGizmo.screenSpaceVertices[c] = {{0,0}, {0,0}};
        Gizmos.MoveGizmo.faceColors[c] = {1,0,0,1};
        Gizmos.MoveGizmo.lines[c].axis = 1;
        i = i + 1;
    end

    local pointsY = calculateCirclePoints(0, 0.9, 0, radius, coneDetail, "y");
    i = 1;
    iOffs = iOffs + coneDetail;
    for c = iOffs, iOffs + coneDetail, 1 do
        Gizmos.MoveGizmo.vertices[c] = {{0,1,0},pointsY[i]};
        Gizmos.MoveGizmo.transformedVertices[c] = {{0,0,0}, {0,1,0}};
        Gizmos.MoveGizmo.screenSpaceVertices[c] = {{0,0}, {0,0}};
        Gizmos.MoveGizmo.faceColors[c] = {0,1,0,1};
        Gizmos.MoveGizmo.lines[c].axis = 2;
        i = i + 1;
    end

    local pointsZ = calculateCirclePoints(0, 0, 0.9, radius, coneDetail, "z");
    i = 1;
    iOffs = iOffs + coneDetail;
    for c = iOffs, iOffs + coneDetail, 1 do
        Gizmos.MoveGizmo.vertices[c] = {{0,0,1},pointsZ[i]};
        Gizmos.MoveGizmo.transformedVertices[c] = {{0,0,0}, {0,0,1}};
        Gizmos.MoveGizmo.screenSpaceVertices[c] = {{0,0}, {0,0}};
        Gizmos.MoveGizmo.faceColors[c] = {0,0,1,1};
        Gizmos.MoveGizmo.lines[c].axis = 3;
        i = i + 1;
    end
end
