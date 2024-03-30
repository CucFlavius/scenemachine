local Gizmo = SceneMachine.Gizmos.Gizmo;
SceneMachine.Gizmos.ScaleGizmo = {};

--- @class ScaleGizmo : Gizmo
local ScaleGizmo = SceneMachine.Gizmos.ScaleGizmo;
local Resources = SceneMachine.Resources;
local Math = SceneMachine.Math;

ScaleGizmo.__index = ScaleGizmo;
setmetatable(ScaleGizmo, Gizmo)

--- Creates a new instance of the ScaleGizmo class.
--- @return ScaleGizmo - The newly created ScaleGizmo instance.
function ScaleGizmo:New()
    local ch = 0.5;
    --- @class ScaleGizmo : Gizmo
    local v = 
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
    };

    setmetatable(v, ScaleGizmo);

    v:Build();
    return v;
end

--- Builds the scale gizmo.
function ScaleGizmo:Build()
    -- Frame --
    self:CreateLineProjectionFrame();

    -- Fill tables --
    for v = 1, #self.vertices, 1 do
        self.transformedVertices[v] = {{0,0,0}, {0,0,0}};
        self.screenSpaceVertices[v] = {{0,0}, {0,0}};
        self.faceColors[v] = {1,1,0,1};
    end

    -- Lines --
    for t = 1, self.lineCount + 1, 1 do
        self.lines[t] = self.lineProjectionFrame:CreateLine(nil, nil, nil);
        self.lines[t]:SetThickness(2.5);
        self.lines[t]:SetTexture(Resources.textures["Line"], "REPEAT", "REPEAT", "NEAREST");
    end
end

--- Checks if the mouse is within the ScaleGizmo and determines the selected and highlighted axis.
--- @param mouseX number The x-coordinate of the mouse position.
--- @param mouseY number The y-coordinate of the mouse position.
--- @return boolean isHighlighted True if the mouse selection is within the ScaleGizmo, false otherwise.
--- @return Gizmo.Axis selectedAxis The selected axis (Gizmo.Axis.XY, Gizmo.Axis.XZ, Gizmo.Axis.YZ) if the mouse selection is within the ScaleGizmo, 0 otherwise.
--- @return Gizmo.Axis highlightedAxis The highlighted axis (Gizmo.Axis.XY, Gizmo.Axis.XZ, Gizmo.Axis.YZ) if the mouse selection is within the ScaleGizmo, 0 otherwise.
function ScaleGizmo:SelectionCheck(mouseX, mouseY)
    self.isHighlighted = false;
    self.selectedAxis = 0;
    self.highlightedAxis = 0;

    for t = 1, self.lineCount, 1 do
        local aX = self.screenSpaceVertices[t][1][1];
        local aY = self.screenSpaceVertices[t][1][2];
        local bX = self.screenSpaceVertices[t][2][1];
        local bY = self.screenSpaceVertices[t][2][2];

        if (mouseX ~= nil and mouseY ~= nil and aX ~= nil and aY ~= nil and bX ~= nil and bY ~= nil) then
            local dist = Math.distToSegment({mouseX, mouseY}, {aX, aY}, {bX, bY});
            if (dist < 30) then
                self.isHighlighted = true;
                self.selectedAxis = Gizmo.Axis.X;
                self.highlightedAxis = Gizmo.Axis.X;
            end
        end
    end

    return self.isHighlighted, self.selectedAxis, self.highlightedAxis;
end

--- Shades the scale gizmo based on if the mouse is over it or not.
function ScaleGizmo:Shade()
    for t = 1, self.lineCount, 1 do
        if (self.highlightedAxis ~= 0) then
            self.faceColors[t][4] = 1.0;
        else
            self.faceColors[t][4] = 0.3;
        end
    end
end

--- Returns a string representation of the Gizmo object.
--- @return string The string representation of the Gizmo object.
ScaleGizmo.__tostring = function(self)
    return "ScaleGizmo";
end