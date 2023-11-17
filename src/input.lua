SceneMachine.Input = SceneMachine.Input or {}
SceneMachine.CameraController = SceneMachine.CameraController or {}
SceneMachine.Gizmos = SceneMachine.Gizmos or {};
local Editor = SceneMachine.Editor;
Editor.SceneManager = Editor.SceneManager or {};
local SM = Editor.SceneManager;
Editor.ProjectManager = Editor.ProjectManager or {};
local PM = Editor.ProjectManager;
local Input = SceneMachine.Input;
local CC = SceneMachine.CameraController;
local Renderer = SceneMachine.Renderer;
local Gizmos = SceneMachine.Gizmos;
local Camera = SceneMachine.Camera;

Input.Keys = {}

function Input.AddKeyBind(key, downAction, upAction)
	Input.Keys[key] = {};
	Input.Keys[key].OnKeyUp = upAction;
	Input.Keys[key].OnKeyDown = downAction;
end

function Input.Initialize()
    Input.KeyboardListener = SceneMachine.Input.KeyboardListener or CreateFrame("Frame","SceneMachine.Input.KeyboardListener",UIParent);
    Input.KeyboardListener:EnableKeyboard(true);
    Input.KeyboardListener:SetPropagateKeyboardInput(true);
    Input.KeyboardListener:SetScript("OnKeyDown", function(self, key)
			if Input.Keys[key] ~= nil then
				Input.Keys[key].OnKeyDown();
                self:SetPropagateKeyboardInput(false);
			end
        end);
		Input.KeyboardListener:SetScript("OnKeyUp", function(self, key)
			if Input.Keys[key] ~= nil then
				Input.Keys[key].OnKeyUp();
                self:SetPropagateKeyboardInput(true);
            end
        end);

    Input.CreateMouseInputFrame();
    Input.MousePickInitialize();
end

function Input.CreateMouseInputFrame()
    local uiScale, x, y = UIParent:GetEffectiveScale();
    Input.mouseInputFrame = CreateFrame("Button", "Input.mouseInputFrame", SM.groupBG);
    --Input.mouseInputFrame:SetAllPoints(SM.groupBG);
	Input.mouseInputFrame:SetPoint("CENTER", SM.groupBG, "CENTER", 0, 0);
    local w, h = SM.groupBG:GetSize();
	Input.mouseInputFrame:SetWidth(w);
	Input.mouseInputFrame:SetHeight(h);
	Input.mouseInputFrame:EnableMouse(true);
	Input.mouseInputFrame:RegisterForDrag("RightButton", "LeftButton");
    Input.mouseInputFrame:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	Input.mouseInputFrame:SetScript("OnDragStart", Input.OnDragStart);
	Input.mouseInputFrame:SetScript("OnDragStop", Input.OnDragStop);
    Input.mouseInputFrame:SetScript("OnClick", Input.OnClick);
end

function Input.OnDragStart(info)
    local LMB = IsMouseButtonDown("LeftButton");
    local RMB = IsMouseButtonDown("RightButton");

    if LMB and RMB then return end

    if RMB then
        CC.OnRMBDown();
    elseif LMB then
        if Gizmos.isHighlighted then
            local x, y = GetCursorPosition();
            Gizmos.OnLMBDown(x, y);
            return;
        end
    end
end

function Input.OnDragStop()
    CC.OnRMBUp();

    if (Gizmos.isUsed) then
        Gizmos.OnLMBUp();
        return;
    end
end

function Input.OnClick(self, button, down)
    if (button == "LeftButton") then
        -- mouse pick --
        Input.MousePick();
    elseif (button == "RightButton") then
        -- open RMB context menu --
    end
end

function Input.MousePickInitialize()
    local ch = 0.5;
    Input.mousePickVertices = 
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
    Input.transformedPickVertices = 
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
    Input.mousePickScreenSpaceVertices = 
    {
        {0,0},{0,0},{0,0},{0,0},{0,0},{0,0},{0,0},{0,0}
    };
end

function Input.MousePick()
    local mouseX, mouseY = GetCursorPosition();
    -- calculate mouse relative to frame
    local xOfs = Renderer.projectionFrame:GetLeft();
    local yOfs = Renderer.projectionFrame:GetBottom();

    local relativeMouseX = mouseX - xOfs;
    local relativeMouseY = mouseY - yOfs;

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

        Input.transformedPickVertices = 
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

        for q = 1, 8, 1 do
            Input.transformedPickVertices[q][1] = Input.transformedPickVertices[q][1] + position.x;
            Input.transformedPickVertices[q][2] = Input.transformedPickVertices[q][2] + position.y;
            Input.transformedPickVertices[q][3] = Input.transformedPickVertices[q][3] + position.z + chZ;
        end

        -- fix v --
        for q = 1, 8, 1 do
            local X, Y = Renderer.projectionFrame:Project3DPointTo2D(Input.transformedPickVertices[q][1],Input.transformedPickVertices[q][2],Input.transformedPickVertices[q][3]);
            Input.mousePickScreenSpaceVertices[q][1] = X;
            Input.mousePickScreenSpaceVertices[q][2] = Y;
        end

        local isInside = isPointInsidePolygon(relativeMouseX, relativeMouseY, findConvexHull(Input.mousePickScreenSpaceVertices))

        if (isInside) then
            SM.selectedObject = object;
            Gizmos.refresh = true;
            return;
        end

        SM.selectedObject = nil;
        Gizmos.refresh = true;
    end
end

function isPointInsidePolygon(x, y, polygon)
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

function findConvexHull(points)
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
        return compare(p1, p2) == -1
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