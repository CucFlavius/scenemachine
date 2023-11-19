local Gizmos = SceneMachine.Gizmos;

function Gizmos.CreateScaleGizmo()
    local ch = 0.5;
    Gizmos.ScaleGizmo = 
    {
        lineCount = 9;
        scale = 10;
        vertices = 
        {
            {{0,1,0}, {1,0,0}},
            {{0,0,1}, {0,1,0}},
            {{1,0,0}, {0,0,1}},

            {{0,ch,0}, {ch,0,0}},
            {{0,0,ch}, {0,ch,0}},
            {{ch,0,0}, {0,0,ch}},

            {{0,0,0}, {1,0,0}},
            {{0,0,0}, {0,1,0}},
            {{0,0,0}, {0,0,1}},
        };
        transformedVertices = {};
        screenSpaceVertices = {};
        faceColors = {};
        lines = {};
        lineDepths = {};
    }

    local lineProjectionFrame = Gizmos.CreateLineProjectionFrame();
    Gizmos.frames["ScaleGizmoFrame"] = lineProjectionFrame;

    -- Fill tables --
    for v = 1, #Gizmos.ScaleGizmo.vertices, 1 do
        Gizmos.ScaleGizmo.transformedVertices[v] = {{0,0,0}, {0,0,0}};
        Gizmos.ScaleGizmo.screenSpaceVertices[v] = {{0,0}, {0,0}};
        Gizmos.ScaleGizmo.faceColors[v] = {1,1,0,1};
    end

    -- Lines --
    for t = 1, Gizmos.ScaleGizmo.lineCount + 1, 1 do
        Gizmos.ScaleGizmo.lines[t] = lineProjectionFrame:CreateLine(nil, nil, nil);
        Gizmos.ScaleGizmo.lines[t]:SetThickness(2.5);
        Gizmos.ScaleGizmo.lines[t]:SetTexture("Interface\\Addons\\scenemachine\\static\\textures\\line.png", "REPEAT", "REPEAT", "NEAREST");
    end
end
