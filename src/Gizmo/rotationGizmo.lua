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

function Gizmos.CreateRotateGizmo()
    local circleDetail = 40;

    Gizmos.RotateGizmo = 
    {
        lineCount = circleDetail * 3;
        scale = 10;
        vertices = {};
        transformedVertices = {};
        screenSpaceVertices = {};
        faceColors = {};
        lines = {};
        lineDepths = {};
    }

    local radius = 0.5;

    local pointsX = calculateCirclePoints(0, 0, 0, radius, circleDetail, "x");
    local i = 1;
    for c = 1, circleDetail, 1 do
        local a = pointsX[i];
        local b = pointsX[i + 1];
        if (i == circleDetail) then
            b = pointsX[1];
        end
        Gizmos.RotateGizmo.vertices[c] = { a, b };
        Gizmos.RotateGizmo.transformedVertices[c] = {{0,0,0}, {1,0,0}};
        Gizmos.RotateGizmo.screenSpaceVertices[c] = {{0,0}, {0,0}};
        Gizmos.RotateGizmo.faceColors[c] = {1,0,0,1};
        Gizmos.RotateGizmo.lines[c] = lineProjectionFrame:CreateLine(nil, nil, nil);
        Gizmos.RotateGizmo.lines[c].axis = 1;
        i = i + 1;
    end

    local pointsY = calculateCirclePoints(0, 0, 0, radius, circleDetail, "y");
    i = 1;
    for c = 1 + circleDetail, 1 + circleDetail * 2, 1 do
        local a = pointsY[i];
        local b = pointsY[i + 1];
        if (i == circleDetail) then
            b = pointsY[1];
        end
        Gizmos.RotateGizmo.vertices[c] = { a, b };
        Gizmos.RotateGizmo.transformedVertices[c] = {{0,0,0}, {0,1,0}};
        Gizmos.RotateGizmo.screenSpaceVertices[c] = {{0,0}, {0,0}};
        Gizmos.RotateGizmo.faceColors[c] = {0,1,0,1};
        Gizmos.RotateGizmo.lines[c] = lineProjectionFrame:CreateLine(nil, nil, nil);
        Gizmos.RotateGizmo.lines[c].axis = 2;
        i = i + 1;
    end

    local pointsZ = calculateCirclePoints(0, 0, 0, radius, circleDetail, "z");
    i = 1;
    for c = 1 + (circleDetail * 2), 1 + (circleDetail * 3), 1 do
        local a = pointsZ[i];
        local b = pointsZ[i + 1];
        if (i == circleDetail) then
            b = pointsZ[1];
        end
        Gizmos.RotateGizmo.vertices[c] = { a, b };
        Gizmos.RotateGizmo.transformedVertices[c] = {{0,0,0}, {0,0,1}};
        Gizmos.RotateGizmo.screenSpaceVertices[c] = {{0,0}, {0,0}};
        Gizmos.RotateGizmo.faceColors[c] = {0,0,1,1};
        Gizmos.RotateGizmo.lines[c] = lineProjectionFrame:CreateLine(nil, nil, nil);
        Gizmos.RotateGizmo.lines[c].axis = 3;
        i = i + 1;
    end

    -- Frame --
    local lineProjectionFrame = Gizmos.CreateLineProjectionFrame();
    Gizmos.frames["RotateGizmoFrame"] = lineProjectionFrame;

    -- Lines --
    for t = 1, Gizmos.RotateGizmo.lineCount, 1 do
        Gizmos.RotateGizmo.lines[t]:SetThickness(2.5);
        Gizmos.RotateGizmo.lines[t]:SetTexture("Interface\\Addons\\scenemachine\\static\\textures\\line.png", "REPEAT", "REPEAT", "NEAREST");
    end
end