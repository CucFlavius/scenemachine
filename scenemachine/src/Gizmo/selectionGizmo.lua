local Gizmos = SceneMachine.Gizmos;
local Vector3 = SceneMachine.Vector3;
local Resources = SceneMachine.Resources;

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
        transformedVertices = {};
        screenSpaceVertices = {};
        faceColors = {};
        lines = {};
        lineDepths = {};
        dashedLine = true;
    }

    -- Frame --
    local lineProjectionFrame = Gizmos.CreateLineProjectionFrame();
    Gizmos.frames["SelectionGizmoFrame"] = lineProjectionFrame;

    -- Fill tables --
    for v = 1, #Gizmos.WireBox.vertices, 1 do
        Gizmos.WireBox.transformedVertices[v] = {{0,0,0}, {0,0,0}};
        Gizmos.WireBox.screenSpaceVertices[v] = {{0,0}, {0,0}};
        Gizmos.WireBox.faceColors[v] = {1,1,1,1};
    end

    -- Lines --
    for t = 1, Gizmos.WireBox.lineCount, 1 do
        Gizmos.WireBox.lines[t] = lineProjectionFrame:CreateLine(nil, nil, nil);
        Gizmos.WireBox.lines[t]:SetThickness(1.5);
        Gizmos.WireBox.lines[t]:SetTexture(Resources.textures["DashedLine"], "REPEAT", "REPEAT", "NEAREST");
    end
end