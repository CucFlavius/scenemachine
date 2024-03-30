local Gizmo = SceneMachine.Gizmos.Gizmo;
SceneMachine.Gizmos.SelectionGizmo = {};

--- @class SelectionGizmo : Gizmo
local SelectionGizmo = SceneMachine.Gizmos.SelectionGizmo;
local Resources = SceneMachine.Resources;

SelectionGizmo.__index = SelectionGizmo;
setmetatable(SelectionGizmo, Gizmo)

--- Creates a new SelectionGizmo object.
--- @return SelectionGizmo: The new SelectionGizmo object.
function SelectionGizmo:New()
    local ch = 0.5;
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

    setmetatable(v, SelectionGizmo);

    v:Build();
    return v;
end

--- Builds the selection gizmo.
function SelectionGizmo:Build()
    -- Frame --
    self:CreateLineProjectionFrame();

    -- Fill tables --
    for v = 1, #self.vertices, 1 do
        self.transformedVertices[v] = {{0,0,0}, {0,0,0}};
        self.screenSpaceVertices[v] = {{0,0}, {0,0}};
        self.faceColors[v] = {1,1,1,1};
    end

    -- Lines --
    for t = 1, self.lineCount, 1 do
        self.lines[t] = self.lineProjectionFrame:CreateLine(nil, nil, nil);
        self.lines[t]:SetThickness(1.5);
        self.lines[t]:SetTexture(Resources.textures["DashedLine"], "REPEAT", "REPEAT", "NEAREST");
    end
end

--- Transforms the selection bounds to an axis-aligned bounding box (AABB) centered at the given boundsCenter.
--- @param boundsCenter table The center of the selection bounds.
function SelectionGizmo:TransformToAABB(boundsCenter)
    local chX = boundsCenter[1];
    local chY = boundsCenter[2];
    local chZ = boundsCenter[3];

    self.vertices[1][1] = {-chX, -chY, -chZ};
    self.vertices[1][2] = {chX, -chY, -chZ};
    self.vertices[2][1] = {chX, -chY, -chZ};
    self.vertices[2][2] = {chX, -chY, chZ};
    self.vertices[3][1] = {chX, -chY, chZ};
    self.vertices[3][2] = {-chX, -chY, chZ};
    self.vertices[4][1] = {-chX, -chY, chZ};
    self.vertices[4][2] = {-chX, -chY, -chZ};

    self.vertices[5][1] = {-chX, chY, -chZ};
    self.vertices[5][2] = {chX, chY, -chZ};
    self.vertices[6][1] = {chX, chY, -chZ};
    self.vertices[6][2] = {chX, chY, chZ};
    self.vertices[7][1] = {chX, chY, chZ};
    self.vertices[7][2] = {-chX, chY, chZ};
    self.vertices[8][1] = {-chX, chY, chZ};
    self.vertices[8][2] = {-chX, chY, -chZ};

    self.vertices[9][1] = {-chX, -chY, -chZ};
    self.vertices[9][2] = {-chX, chY, -chZ};
    self.vertices[10][1] = {chX, -chY, -chZ};
    self.vertices[10][2] = {chX, chY, -chZ};
    self.vertices[11][1] = {chX, -chY, chZ};
    self.vertices[11][2] = {chX, chY, chZ};
    self.vertices[12][1] = {-chX, -chY, chZ};
    self.vertices[12][2] = {-chX, chY, chZ};
end

--- Shades the selected lines of the selection gizmo
function SelectionGizmo:Shade()
    -- Create an array of indices
    local indices = {}
    for i = 1, #self.lineDepths do
        indices[i] = i
    end

    -- Sort the indices based on the values in the 'numbers' table
    table.sort(indices, function(a, b)
        if (self.lineDepths[a] ~= nil and self.lineDepths[b] ~= nil) then
            return self.lineDepths[a] < self.lineDepths[b];
        else
            return false;
        end
    end)

    -- Create sorted tables
    local sortedLineDepths = {}
    local sortedLines = {}
    for _, index in ipairs(indices) do
        table.insert(sortedLineDepths, self.lineDepths[index])
        table.insert(sortedLines, self.lines[index])
    end

    -- Shade the first three sorted lines
    for i = 1, 3 do
        if (sortedLines[i] ~= nil) then
            sortedLines[i]:SetVertexColor(1, 1, 1, 0.3);
        end
    end
end

--- Returns a string representation of the Gizmo object.
--- @return string The string representation of the Gizmo object.
SelectionGizmo.__tostring = function(self)
    return "SelectionGizmo";
end