local Gizmos = SceneMachine.Gizmos;

function Gizmos.CreateSelectionGizmo()
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