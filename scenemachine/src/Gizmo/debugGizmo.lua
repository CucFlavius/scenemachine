local Gizmos = SceneMachine.Gizmos;
local Vector3 = SceneMachine.Vector3;

function Gizmos.CreateDebugGizmo()
    local coneDetail = 10;
    local emptySSVertex = {{0,0}, {0,0}};
    local emptyVertex = {{0,0,0}, {0,0,0}};
    local ch = 0.3;
    Gizmos.DebugGizmo = 
    {
        active = false;
        lineCount = 3;
        position = Vector3:New();
        rotation = Vector3:New();
        scale = 10;
        vertices = 
        {
            {{0,0,0}, {1,0,0}}, -- X
            {{0,0,0}, {0,1,0}}, -- Y
            {{0,0,0}, {0,0,1}}, -- Z
        };
        transformedVertices = {};
        screenSpaceVertices = {};
        faceColors = 
        {
            {1,1,1,1},
            {1,1,1,1},
            {1,1,1,1},
        };
        lines = {};
        lineDepths = {};
    }

    local lineProjectionFrame = Gizmos.CreateLineProjectionFrame();
    Gizmos.frames["DebugGizmoFrame"] = lineProjectionFrame;
    Gizmos.frames["DebugGizmoFrame"]:Show();
    -- Fill tables --
    for v = 1, #Gizmos.DebugGizmo.vertices, 1 do
        Gizmos.DebugGizmo.transformedVertices[v] = {{0,0,0}, {0,0,0}};
        Gizmos.DebugGizmo.screenSpaceVertices[v] = {{0,0}, {0,0}};
    end

    -- Lines --
    for t = 1, Gizmos.DebugGizmo.lineCount, 1 do
        Gizmos.DebugGizmo.lines[t] = lineProjectionFrame:CreateLine(nil, nil, nil);
        Gizmos.DebugGizmo.lines[t]:SetThickness(2.5);
        Gizmos.DebugGizmo.lines[t]:Show();
        Gizmos.DebugGizmo.lines[t]:SetTexture("Interface\\Addons\\scenemachine\\static\\textures\\line.png", "REPEAT", "REPEAT", "NEAREST");
    end
end
