local Gizmos = SceneMachine.Gizmos;
local Vector3 = SceneMachine.Vector3;
local Resources = SceneMachine.Resources;

function Gizmos.CreateCameraGizmo()
    local ch = 0.5;

    Gizmos.CameraGizmo = 
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

    --Gizmos.GenerateCameraFrustumVertices(math.rad(60), 1/2, 1, 20);

    -- Frame --
    local lineProjectionFrame = Gizmos.CreateLineProjectionFrame();
    Gizmos.frames["CameraGizmoFrame"] = lineProjectionFrame;

    -- Fill tables --
    for v = 1, #Gizmos.CameraGizmo.vertices, 1 do
        Gizmos.CameraGizmo.transformedVertices[v] = {{0,0,0}, {0,0,0}};
        Gizmos.CameraGizmo.screenSpaceVertices[v] = {{0,0}, {0,0}};
        Gizmos.CameraGizmo.faceColors[v] = {1,1,1,0.5};
    end

    -- Lines --
    for t = 1, Gizmos.CameraGizmo.lineCount, 1 do
        Gizmos.CameraGizmo.lines[t] = lineProjectionFrame:CreateLine(nil, nil, nil);
        Gizmos.CameraGizmo.lines[t]:SetThickness(1.5);
        Gizmos.CameraGizmo.lines[t]:SetTexture(Resources.textures["Line"], "REPEAT", "REPEAT", "NEAREST");
    end
end

function Gizmos.GenerateCameraFrustumVertices(fov, aspectRatio, near, far)
    local halfHeight = math.tan(fov / 2)
    local halfWidth = halfHeight * aspectRatio
    local vertices = Gizmos.CameraGizmo.vertices;

    -- Near plane
    vertices[1][1] = {near, -halfHeight * near, -halfWidth * near}
    vertices[1][2] = {near, -halfHeight * near, halfWidth * near}
    vertices[2][1] = {near, -halfHeight * near, halfWidth * near}
    vertices[2][2] = {near, halfHeight * near, halfWidth * near}
    vertices[3][1] = {near, halfHeight * near, halfWidth * near}
    vertices[3][2] = {near, halfHeight * near, -halfWidth * near}
    vertices[4][1] = {near, halfHeight * near, -halfWidth * near}
    vertices[4][2] = {near, -halfHeight * near, -halfWidth * near}

    -- Far plane
    vertices[5][1] = {far, -halfHeight * far, -halfWidth * far}
    vertices[5][2] = {far, -halfHeight * far, halfWidth * far}
    vertices[6][1] = {far, -halfHeight * far, halfWidth * far}
    vertices[6][2] = {far, halfHeight * far, halfWidth * far}
    vertices[7][1] = {far, halfHeight * far, halfWidth * far}
    vertices[7][2] = {far, halfHeight * far, -halfWidth * far}
    vertices[8][1] = {far, halfHeight * far, -halfWidth * far}
    vertices[8][2] = {far, -halfHeight * far, -halfWidth * far}

    -- Connecting edges
    vertices[9][1] = {near, -halfHeight * near, -halfWidth * near}
    vertices[9][2] = {far, -halfHeight * far, -halfWidth * far}
    vertices[10][1] = {near, -halfHeight * near, halfWidth * near}
    vertices[10][2] = {far, -halfHeight * far, halfWidth * far}
    vertices[11][1] = {near, halfHeight * near, halfWidth * near}
    vertices[11][2] = {far, halfHeight * far, halfWidth * far}
    vertices[12][1] = {near, halfHeight * near, -halfWidth * near}
    vertices[12][2] = {far, halfHeight * far, -halfWidth * far}
end
