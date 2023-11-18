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
    Gizmos.RotateGizmoX = {}
    Gizmos.RotateGizmoY = {}
    Gizmos.RotateGizmoZ = {}

    local segments = 40;
    local radius = 1;
    local rad;
    local pointCount = segments + 1;
    local points = {}

    -- X
    for i = 1, pointCount, 1 do
        rad = math.rad(i * 360 / segments);
        points[i] = {0, math.sin(rad) * radius, math.cos(rad) * radius};
    end
    Gizmos.RotateGizmoX.lineCount = (pointCount - 1);
    Gizmos.RotateGizmoX.vertices = {};
    Gizmos.RotateGizmoX.scale = 4;
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
    Gizmos.RotateGizmoY.scale = 4;
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
    Gizmos.RotateGizmoZ.scale = 4;
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
