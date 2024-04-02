local Gizmo = SceneMachine.Gizmos.Gizmo;
SceneMachine.Gizmos.MoveGizmo = {};

--- @class MoveGizmo : Gizmo
local MoveGizmo = SceneMachine.Gizmos.MoveGizmo;
local Resources = SceneMachine.Resources;
local Math = SceneMachine.Math;
local Camera = SceneMachine.Camera;
local GM = SceneMachine.Gizmos.GizmoManager;

MoveGizmo.__index = MoveGizmo;
setmetatable(MoveGizmo, Gizmo)

--- Creates a new instance of the MoveGizmo class.
--- @return MoveGizmo
function MoveGizmo:New()
    local coneDetail = 10;
    local ch = 0.3;

    --- @class MoveGizmo : Gizmo
    local v = 
    {
        coneDetail = coneDetail;
        lineCount = 3 + 6 + (coneDetail * 3);
        scale = 10;
        vertices = 
        {
            {{0,0,0}, {1,0,0}}, -- X
            {{0,0,0}, {0,1,0}}, -- Y
            {{0,0,0}, {0,0,1}}, -- Z

            -- XY
            {{ch,0,0}, {ch,ch,0}},
            {{0,ch,0}, {ch,ch,0}},

            -- XZ
            {{ch,0,0}, {ch,0,ch}},
            {{0,0,ch}, {ch,0,ch}},

            -- YZ
            {{0,ch,0}, {0,ch,ch}},
            {{0,0,ch}, {0,ch,ch}},
        };
        transformedVertices = {};
        screenSpaceVertices = {};
        faceColors = 
        {
            {1,0,0,1},
            {0,1,0,1},
            {0,0,1,1},

            {1,1,0,1},
            {1,1,0,1},
            {1,1,0,1},
            {1,1,0,1},
            {1,1,0,1},
            {1,1,0,1},
        };
        lines = {};
        lineDepths = {};
        axisVisibility = { true, true, true, true, true, true };
    };

    setmetatable(v, MoveGizmo);

    v:Build(coneDetail);
    return v;
end

--- Builds the MoveGizmo.
--- @param coneDetail number The level of detail for the cone vertices.
function MoveGizmo:Build(coneDetail)
    -- Frame --
    self:CreateLineProjectionFrame();

    -- Fill tables --
    for v = 1, #self.vertices, 1 do
        self.transformedVertices[v] = {{0,0,0}, {0,0,0}};
        self.screenSpaceVertices[v] = {{0,0}, {0,0}};
    end

    -- Lines --
    for t = 1, self.lineCount + 1, 1 do
        self.lines[t] = self.lineProjectionFrame:CreateLine(nil, nil, nil);
        self.lines[t]:SetThickness(2.5);
        self.lines[t]:SetTexture(Resources.textures["Line"], "REPEAT", "REPEAT", "NEAREST");
    end

    -- setting the axis on the main 3 lines
    self.lines[1].axis = 1;
    self.lines[2].axis = 2;
    self.lines[3].axis = 3;
    -- setting the axis on XY
    self.lines[4].axis = 4;
    self.lines[5].axis = 4;
    -- setting the axis on XZ
    self.lines[6].axis = 5;
    self.lines[7].axis = 5;
    -- setting the axis on YZ
    self.lines[8].axis = 6;
    self.lines[9].axis = 6;

    -- Create cone vertices --
    local radius = 0.02;

    local pointsX = self:CalculateCirclePoints(0.9, 0, 0, radius, coneDetail, Gizmo.Axis.X);
    local i = 1;
    local iOffs = 4 + 6;
    for c = iOffs, iOffs + coneDetail, 1 do
        self.vertices[c] = {{1,0,0},pointsX[i]};
        self.transformedVertices[c] = {{0,0,0}, {1,0,0}};
        self.screenSpaceVertices[c] = {{0,0}, {0,0}};
        self.faceColors[c] = {1,0,0,1};
        self.lines[c].axis = 1;
        i = i + 1;
    end

    local pointsY = self:CalculateCirclePoints(0, 0.9, 0, radius, coneDetail, Gizmo.Axis.Y);
    i = 1;
    iOffs = iOffs + coneDetail;
    for c = iOffs, iOffs + coneDetail, 1 do
        self.vertices[c] = {{0,1,0},pointsY[i]};
        self.transformedVertices[c] = {{0,0,0}, {0,1,0}};
        self.screenSpaceVertices[c] = {{0,0}, {0,0}};
        self.faceColors[c] = {0,1,0,1};
        self.lines[c].axis = 2;
        i = i + 1;
    end

    local pointsZ = self:CalculateCirclePoints(0, 0, 0.9, radius, coneDetail, Gizmo.Axis.Z);
    i = 1;
    iOffs = iOffs + coneDetail;
    for c = iOffs, iOffs + coneDetail, 1 do
        self.vertices[c] = {{0,0,1},pointsZ[i]};
        self.transformedVertices[c] = {{0,0,0}, {0,0,1}};
        self.screenSpaceVertices[c] = {{0,0}, {0,0}};
        self.faceColors[c] = {0,0,1,1};
        self.lines[c].axis = 3;
        i = i + 1;
    end
end

--- Checks if the mouse is within the MoveGizmo and determines the selected and highlighted axis.
--- @param mouseX number The x-coordinate of the mouse position.
--- @param mouseY number The y-coordinate of the mouse position.
--- @return boolean isHighlighted True if the mouse selection is within the MoveGizmo, false otherwise.
--- @return Gizmo.Axis selectedAxis The selected axis (Gizmo.Axis.XY, Gizmo.Axis.XZ, Gizmo.Axis.YZ) if the mouse selection is within the MoveGizmo, 0 otherwise.
--- @return Gizmo.Axis highlightedAxis The highlighted axis (Gizmo.Axis.XY, Gizmo.Axis.XZ, Gizmo.Axis.YZ) if the mouse selection is within the MoveGizmo, 0 otherwise.
function MoveGizmo:SelectionCheck(mouseX, mouseY)
    self.isHighlighted = false;
    self.selectedAxis = 0;
    self.highlightedAxis = 0;
    
    -- check against the rectangle XY
    if (self.axisVisibility[4]) then
        -- <
        local aX = self.screenSpaceVertices[4][1][1];
        local aY = self.screenSpaceVertices[4][1][2];
        -- >
        local bX = self.screenSpaceVertices[5][1][1];
        local bY = self.screenSpaceVertices[5][1][2];
        -- v
        local cX = self.screenSpaceVertices[5][2][1];
        local cY = self.screenSpaceVertices[5][2][2];
        -- ^
        local dX = self.screenSpaceVertices[1][1][1];
        local dY = self.screenSpaceVertices[1][1][2];
        local inTriangle = Math.isPointInPolygon(mouseX, mouseY, aX, aY, cX, cY, bX, bY, dX, dY);
        if (inTriangle) then
            self.isHighlighted = true;
            self.selectedAxis = Gizmo.Axis.XY;
            self.highlightedAxis = Gizmo.Axis.XY;
        end
    end

    -- check against the rectangle XZ
    if (self.axisVisibility[5]) then
        -- <
        local aX = self.screenSpaceVertices[6][1][1];
        local aY = self.screenSpaceVertices[6][1][2];
        -- >
        local bX = self.screenSpaceVertices[7][1][1];
        local bY = self.screenSpaceVertices[7][1][2];
        -- v
        local cX = self.screenSpaceVertices[7][2][1];
        local cY = self.screenSpaceVertices[7][2][2];
        -- ^
        local dX = self.screenSpaceVertices[1][1][1];
        local dY = self.screenSpaceVertices[1][1][2];
        if (mouseX and mouseY and aX and aY and bX and bY) then
            local inTriangle = Math.isPointInPolygon(mouseX, mouseY, aX, aY, cX, cY, bX, bY, dX, dY);
            if (inTriangle) then
                self.isHighlighted = true;
                self.selectedAxis = Gizmo.Axis.XZ;
                self.highlightedAxis = Gizmo.Axis.XZ;
            end
        end
    end

    -- check against the rectangle YZ
    if (self.axisVisibility[6]) then
        -- <
        local aX = self.screenSpaceVertices[8][1][1];
        local aY = self.screenSpaceVertices[8][1][2];
        -- >
        local bX = self.screenSpaceVertices[9][1][1];
        local bY = self.screenSpaceVertices[9][1][2];
        -- v
        local cX = self.screenSpaceVertices[9][2][1];
        local cY = self.screenSpaceVertices[9][2][2];
        -- ^
        local dX = self.screenSpaceVertices[1][1][1];
        local dY = self.screenSpaceVertices[1][1][2];
        if (mouseX and mouseY and aX and aY and bX and bY) then
            local inTriangle = Math.isPointInPolygon(mouseX, mouseY, aX, aY, cX, cY, bX, bY, dX, dY);
            if (inTriangle) then
                self.isHighlighted = true;
                self.selectedAxis = Gizmo.Axis.YZ;
                self.highlightedAxis = Gizmo.Axis.YZ;
            end
        end
    end

    -- check if the lines are points, to hide axes that are parallel to the camera
    for t = 1, 3, 1 do
        local aX = self.screenSpaceVertices[t][1][1];
        local aY = self.screenSpaceVertices[t][1][2];
        local bX = self.screenSpaceVertices[t][2][1];
        local bY = self.screenSpaceVertices[t][2][2];

        if (aX and aY and bX and bY) then
            local dist = Math.manhattanDistance2D(aX, aY, bX, bY);
            self.axisVisibility[t] = dist > 10;
        end
    end
    
    -- check against the line distances
    if (not self.isHighlighted) then
        local minDists = { 10000, 10000, 10000 };
        for t = 1, 3, 1 do
            if (self.axisVisibility[t]) then
                local aX = self.screenSpaceVertices[t][1][1];
                local aY = self.screenSpaceVertices[t][1][2];
                local bX = self.screenSpaceVertices[t][2][1];
                local bY = self.screenSpaceVertices[t][2][2];

                if (mouseX and mouseY and aX and aY and bX and bY) then
                    local dist = Math.distToSegment({mouseX, mouseY}, {aX, aY}, {bX, bY});
                    if (dist < 10) then
                        if (minDists[t] > dist) then
                            minDists[t] = dist;
                        end
                    end
                end
            end
        end

        local smallest = self:IndexOfSmallestAxis(minDists);
        if (minDists[smallest] < 10) then
            self.isHighlighted = true;
            self.selectedAxis = smallest;
            self.highlightedAxis = smallest;
        end
    end

    return self.isHighlighted, self.selectedAxis, self.highlightedAxis;
end

--- Shades the move gizmo based on the highlighted axis.
function MoveGizmo:Shade()
    local normalAlpha;
    local mouseOverAlpha;

    for t = 1, 3, 1 do
        if (self.lines[t].axis == self.highlightedAxis) then
            self.faceColors[t][4] = 1.0;
            for c = 4 + 2 + (self.coneDetail * (t-1)), 4 + 2 + (self.coneDetail * (t)), 1 do
                self.faceColors[c][4] = 1.0;
            end
        else
            self.faceColors[t][4] = 0.3;
            for c = 4 + 2 + (self.coneDetail * (t-1)), 4 + 2 + (self.coneDetail * (t)), 1 do
                self.faceColors[c][4] = 0.3;
            end
        end
    end

    for t = 4, 4 + 6, 1 do
        if (self.lines[t].axis == self.highlightedAxis) then
            self.faceColors[t][4] = 1.0;
        else
            self.faceColors[t][4] = 0.3;
        end
    end

    for t = 1, self.lineCount, 1 do
        if (not self.axisVisibility[self.lines[t].axis]) then
            self.faceColors[t][4] = 0;
        end
    end
end

function MoveGizmo:HideAxis(axis)
    self.axisVisibility[axis] = false;
end

function MoveGizmo:ShowAxis(axis)
    self.axisVisibility[axis] = true;
end

--- Returns a string representation of the Gizmo object.
--- @return string The string representation of the Gizmo object.
MoveGizmo.__tostring = function(self)
    return "MoveGizmo";
end