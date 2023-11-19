local Editor = SceneMachine.Editor;
local MousePick = Editor.MousePick;
local Gizmos = SceneMachine.Gizmos;
local SM = Editor.SceneManager;
local SH = Editor.SceneHierarchy;
local Renderer = SceneMachine.Renderer;
local PM = Editor.ProjectManager;
local OP = Editor.ObjectProperties;

function MousePick.Initialize()
    local ch = 0.5;
    MousePick.bbVertices = 
    {
        {-ch, -ch, -ch},
        {ch, -ch, -ch},
        {ch, -ch, ch},
        {-ch, -ch, ch},
        {-ch, ch, -ch},
        {ch, ch, -ch},
        {ch, ch, ch},
        {-ch, ch, ch},
    };
    MousePick.bbTransVerts = 
    {
        {-ch, -ch, -ch},
        {ch, -ch, -ch},
        {ch, -ch, ch},
        {-ch, -ch, ch},
        {-ch, ch, -ch},
        {ch, ch, -ch},
        {ch, ch, ch},
        {-ch, ch, ch},
    };
    MousePick.ssbbVertices = 
    {
        {0,0},{0,0},{0,0},{0,0},{0,0},{0,0},{0,0},{0,0}
    };
end

function MousePick.Pick(x, y)
    local scene = PM.currentProject.scenes[SM.loadedSceneIndex];
    for i in pairs(scene.objects) do
        local object = scene.objects[i];

        local xMin, yMin, zMin, xMax, yMax, zMax = object:GetActiveBoundingBox();

        if (xMax == nil) then
            return;
        end
    
        local chX = (xMax - xMin) / 2;
        local chY = (yMax - yMin) / 2;
        local chZ = (zMax - zMin) / 2;

        MousePick.bbTransVerts = 
        {
            {-chX, -chY, -chZ},
            {chX, -chY, -chZ},
            {chX, -chY, chZ},
            {-chX, -chY, chZ},
            {-chX, chY, -chZ},
            {chX, chY, -chZ},
            {chX, chY, chZ},
            {-chX, chY, chZ},
        };
    
        local position = object:GetPosition();
        local scale = object:GetScale();

        for q = 1, 8, 1 do
            MousePick.bbTransVerts[q][1] = MousePick.bbTransVerts[q][1] * scale + position.x;
            MousePick.bbTransVerts[q][2] = MousePick.bbTransVerts[q][2] * scale + position.y;
            MousePick.bbTransVerts[q][3] = MousePick.bbTransVerts[q][3] * scale + position.z + (chZ * scale);
        end

        -- fix v --
        for q = 1, 8, 1 do
            local X, Y = Renderer.projectionFrame:Project3DPointTo2D(MousePick.bbTransVerts[q][1], MousePick.bbTransVerts[q][2], MousePick.bbTransVerts[q][3]);
            MousePick.ssbbVertices[q][1] = X;
            MousePick.ssbbVertices[q][2] = Y;
        end

        local convexVerts = MousePick.FindConvexHull(MousePick.ssbbVertices);
        local isInside = MousePick.IsPointInsidePolygon(x, y, convexVerts);

        if (isInside) then
            SM.selectedObject = object;
            SH.RefreshHierarchy();
            OP.Refresh();
            return;
        end

        SM.selectedObject = nil;
        SH.RefreshHierarchy();
        OP.Refresh();
    end
end

function MousePick.IsPointInsidePolygon(x, y, polygon)
    local oddNodes = false
    local j = #polygon

    for i = 1, #polygon do
        local xi, yi = polygon[i][1], polygon[i][2]
        local xj, yj = polygon[j][1], polygon[j][2]

        if ((yi < y and yj >= y or yj < y and yi >= y) and (xi <= x or xj <= x)) then
            if (xi + (y - yi) / (yj - yi) * (xj - xi) < x) then
                oddNodes = not oddNodes
            end
        end

        j = i
    end

    return oddNodes
end

function MousePick.FindConvexHull(points)
    local function orientation(p, q, r)
        local val = (q[2] - p[2]) * (r[1] - q[1]) - (q[1] - p[1]) * (r[2] - q[2])
        if val == 0 then return 0 end
        return (val > 0) and 1 or 2
    end

    local function distance(p1, p2)
        return (p1[1] - p2[1])^2 + (p1[2] - p2[2])^2
    end

    local function compare(p1, p2)
        local o = orientation(points[1], p1, p2)
        if o == 0 then
            return (distance(points[1], p2) >= distance(points[1], p1)) and -1 or 1
        end
        return (o == 2) and -1 or 1
    end

    local convexHull = {}
    local n = #points
    local minY = math.huge
    local minIdx

    for i = 1, n do
        if points[i][2] < minY or (points[i][2] == minY and points[i][1] < points[minIdx][1]) then
            minY = points[i][2]
            minIdx = i
        end
    end

    -- Put the pivot point at the beginning
    points[1], points[minIdx] = points[minIdx], points[1]

    table.sort(points, function(p1, p2)
        if (p1 ~= nil and p2 ~= nil) then
            return compare(p1, p2) == -1
        else
            return 1;
        end
    end)

    table.insert(convexHull, points[1])
    table.insert(convexHull, points[2])

    for i = 3, n do
        while (#convexHull >= 2 and orientation(convexHull[#convexHull - 1], convexHull[#convexHull], points[i]) ~= 2) do
            table.remove(convexHull, #convexHull)
        end
        table.insert(convexHull, points[i])
    end

    return convexHull
end