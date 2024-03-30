local Gizmo = SceneMachine.Gizmos.Gizmo;
SceneMachine.Gizmos.RotateGizmo = {};

--- @class RotateGizmo : Gizmo
local RotateGizmo = SceneMachine.Gizmos.RotateGizmo;
local Resources = SceneMachine.Resources;
local Math = SceneMachine.Math;

RotateGizmo.__index = RotateGizmo;
setmetatable(RotateGizmo, Gizmo)

--- Creates a new instance of the RotateGizmo class.
--- @return RotateGizmo
function RotateGizmo:New()
    local circleDetail = 40;

    --- @class RotateGizmo : Gizmo
    local v = 
    {
        lineCount = circleDetail * 3;
        scale = 10;
        vertices = {};
        transformedVertices = {};
        screenSpaceVertices = {};
        faceColors = {};
        lines = {};
        lineDepths = {};
    };

    setmetatable(v, RotateGizmo);

    v:Build(circleDetail);
    return v;
end

--- Builds the rotate gizmo with the specified circle detail.
--- @param circleDetail number The number of points to use for each circle.
function RotateGizmo:Build(circleDetail)
    -- Frame --
    self:CreateLineProjectionFrame();

    local radius = 0.5;
    local pointsX = self:CalculateCirclePoints(0, 0, 0, radius, circleDetail, Gizmo.Axis.X);
    local i = 1;
    for c = 1, circleDetail, 1 do
        local a = pointsX[i];
        local b = pointsX[i + 1];
        if (i == circleDetail) then
            b = pointsX[1];
        end
        self.vertices[c] = { a, b };
        self.transformedVertices[c] = {{0,0,0}, {1,0,0}};
        self.screenSpaceVertices[c] = {{0,0}, {0,0}};
        self.faceColors[c] = {1,0,0,1};
        self.lines[c] = self.lineProjectionFrame:CreateLine(nil, nil, nil);
        self.lines[c].axis = 1;
        i = i + 1;
    end

    local pointsY = self:CalculateCirclePoints(0, 0, 0, radius, circleDetail, Gizmo.Axis.Y);
    i = 1;
    for c = 1 + circleDetail, 1 + circleDetail * 2, 1 do
        local a = pointsY[i];
        local b = pointsY[i + 1];
        if (i == circleDetail) then
            b = pointsY[1];
        end
        self.vertices[c] = { a, b };
        self.transformedVertices[c] = {{0,0,0}, {0,1,0}};
        self.screenSpaceVertices[c] = {{0,0}, {0,0}};
        self.faceColors[c] = {0,1,0,1};
        self.lines[c] = self.lineProjectionFrame:CreateLine(nil, nil, nil);
        self.lines[c].axis = 2;
        i = i + 1;
    end

    local pointsZ = self:CalculateCirclePoints(0, 0, 0, radius, circleDetail, Gizmo.Axis.Z);
    i = 1;
    for c = 1 + (circleDetail * 2), 1 + (circleDetail * 3), 1 do
        local a = pointsZ[i];
        local b = pointsZ[i + 1];
        if (i == circleDetail) then
            b = pointsZ[1];
        end
        self.vertices[c] = { a, b };
        self.transformedVertices[c] = {{0,0,0}, {0,0,1}};
        self.screenSpaceVertices[c] = {{0,0}, {0,0}};
        self.faceColors[c] = {0,0,1,1};
        self.lines[c] = self.lineProjectionFrame:CreateLine(nil, nil, nil);
        self.lines[c].axis = 3;
        i = i + 1;
    end

    -- Lines --
    for t = 1, self.lineCount, 1 do
        self.lines[t]:SetThickness(2.5);
        self.lines[t]:SetTexture(Resources.textures["Line"], "REPEAT", "REPEAT", "NEAREST");
    end
end

--- Checks if the mouse is within the RotateGizmo and determines the selected and highlighted axis.
--- @param mouseX number The x-coordinate of the mouse position.
--- @param mouseY number The y-coordinate of the mouse position.
--- @return boolean isHighlighted True if the mouse selection is within the RotateGizmo, false otherwise.
--- @return Gizmo.Axis selectedAxis The selected axis (Gizmo.Axis.XY, Gizmo.Axis.XZ, Gizmo.Axis.YZ) if the mouse selection is within the RotateGizmo, 0 otherwise.
--- @return Gizmo.Axis highlightedAxis The highlighted axis (Gizmo.Axis.XY, Gizmo.Axis.XZ, Gizmo.Axis.YZ) if the mouse selection is within the RotateGizmo, 0 otherwise.
function RotateGizmo:SelectionCheck(mouseX, mouseY)
    self.isHighlighted = false;
    self.selectedAxis = 0;
    self.highlightedAxis = 0;

    local minDists = { 10000, 10000, 10000 };
    for t = 1, self.lineCount, 1 do
        local aX = self.screenSpaceVertices[t][1][1];
        local aY = self.screenSpaceVertices[t][1][2];
        local bX = self.screenSpaceVertices[t][2][1];
        local bY = self.screenSpaceVertices[t][2][2];

        if (mouseX and mouseY and aX and aY and bX and bY) then
            local dist = Math.distToSegment({mouseX, mouseY}, {aX, aY}, {bX, bY});
            local line = self.lines[t];
            if (dist < 10 and line.alpha > 0.2) then
                local ax = line.axis;
                if (minDists[ax] > dist) then
                    minDists[ax] = dist;
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

    return self.isHighlighted, self.selectedAxis, self.highlightedAxis;
end

--- Shades the rotate gizmo based on the axis color and depth of its lines
function RotateGizmo:Shade()
    local minD = 10000000;
    local maxD = -10000000;

    -- find min max depth
    for i = 1, #self.lineDepths do
        if (self.lineDepths[i] > maxD) then
            maxD = self.lineDepths[i];
        end
        if (self.lineDepths[i] < minD) then
            minD = self.lineDepths[i];
        end
    end

    -- fade alpha
    for i = 1, #self.lineDepths do
        -- get an alpha value between 0 and 1
        local alpha = Math.normalize(self.lineDepths[i], minD, maxD);

        -- make non linear
        alpha = alpha ^ 2.2;

        self.lines[i].alpha = alpha;

        -- clamp
        if (self.lines[i].axis == self.highlightedAxis) then
            alpha = Math.clamp(alpha, 0.5, 1);
        else
            alpha = Math.clamp(alpha, 0, 0.3);
        end

        local faceColor = self.faceColors[i];
        self.lines[i]:SetVertexColor(faceColor[1], faceColor[2], faceColor[3], alpha);
    end
end

--- Returns a string representation of the Gizmo object.
--- @return string The string representation of the Gizmo object.
RotateGizmo.__tostring = function(self)
    return "RotateGizmo";
end