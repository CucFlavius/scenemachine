local Gizmo = SceneMachine.Gizmos.Gizmo;
SceneMachine.Gizmos.CameraGizmo = {};

--- @class CameraGizmo : Gizmo
local CameraGizmo = SceneMachine.Gizmos.CameraGizmo;
local Resources = SceneMachine.Resources;

CameraGizmo.__index = CameraGizmo;
setmetatable(CameraGizmo, Gizmo)

--- Creates a new instance of the CameraGizmo class.
--- @return CameraGizmo
function CameraGizmo:New()
    local ch = 0.5;
    --- @class CameraGizmo : Gizmo
    local v = 
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
    };

    setmetatable(v, CameraGizmo);

    v:Build();
    return v;
end

--- Builds the CameraGizmo object.
function CameraGizmo:Build()
    -- Frame --
    self:CreateLineProjectionFrame();

    -- Fill tables --
    for v = 1, #self.vertices, 1 do
        self.transformedVertices[v] = {{0,0,0}, {0,0,0}};
        self.screenSpaceVertices[v] = {{0,0}, {0,0}};
        self.faceColors[v] = {1,1,1,0.5};
    end

    -- Lines --
    for t = 1, self.lineCount, 1 do
        self.lines[t] = self.lineProjectionFrame:CreateLine(nil, nil, nil);
        self.lines[t]:SetThickness(1.5);
        self.lines[t]:SetTexture(Resources.textures["Line"], "REPEAT", "REPEAT", "NEAREST");
    end
end

--- Generates the vertices of a camera frustum based on the given parameters.
--- @param fov number The field of view angle in radians.
--- @param aspectRatio number The aspect ratio of the camera.
--- @param near number The distance to the near plane.
--- @param far number The distance to the far plane.
function CameraGizmo:GenerateCameraFrustumVertices(fov, aspectRatio, near, far)
    local halfHeight = math.tan(fov / 2)
    local halfWidth = halfHeight * aspectRatio
    local vertices = self.vertices;

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

--- Shades the camera gizmo. (Unused)
function CameraGizmo:Shade()

end

--- Returns a string representation of the Gizmo object.
--- @return string The string representation of the Gizmo object.
CameraGizmo.__tostring = function(self)
    return "CameraGizmo";
end