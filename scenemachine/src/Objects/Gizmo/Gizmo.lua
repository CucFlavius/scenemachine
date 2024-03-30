SceneMachine.Gizmos.Gizmo = {}

--- @class Gizmo
--- @field vertices table[]
--- @field transformedVertices table[]
--- @field screenSpaceVertices table[]
--- @field faceColors table[]
--- @field lines table[]
--- @field lineDepths table[]
--- @field lineCount number
--- @field scale number
--- @field dashedLine boolean
local Gizmo = SceneMachine.Gizmos.Gizmo;
local Vector3 = SceneMachine.Vector3;
local Renderer = SceneMachine.Renderer;
local Camera = SceneMachine.Camera;

--- @enum Gizmo.Space
Gizmo.Space = {
    World = 0,
    Local = 1,
};

--- @enum Gizmo.Pivot
Gizmo.Pivot = {
    Center = 0,
    Base = 1,
};

--- @enum Gizmo.Axis
Gizmo.Axis = {
    None = 0,
    X = 1,
    Y = 2,
    Z = 3,
    XY = 4,
    XZ = 5,
    YZ = 6,
};

--- @enum Gizmo.TransformType
Gizmo.TransformType = {
    Select = 0,
    Move = 1,
    Rotate = 2,
    Scale = 3,
};

--- @enum Gizmo.MultiTransform
Gizmo.MultiTransform = {
    Together = 0,
    Individual = 1,
};

setmetatable(Gizmo, Gizmo)

local fields = {}

--- Creates a line projection frame for the Gizmo object that is used for rendering the gizmo lines.
function Gizmo:CreateLineProjectionFrame()
    self.lineProjectionFrame = CreateFrame("Frame", "lineProjectionFrame", Renderer.projectionFrame)
    self.lineProjectionFrame:SetFrameStrata("HIGH");
    self.lineProjectionFrame:SetAllPoints(Renderer.projectionFrame);
    self.lineProjectionFrame.texture = self.lineProjectionFrame:CreateTexture("Renderer.lineProjectionFrame.texture", "ARTWORK")
    self.lineProjectionFrame.texture:SetColorTexture(0,0,0,0);
    self.lineProjectionFrame.texture:SetAllPoints(Renderer.lineProjectionFrame);
    self.lineProjectionFrame:SetFrameLevel(101);
    self.lineProjectionFrame:Hide();
end

--- Shows the Gizmo by displaying the line projection frame.
function Gizmo:Show()
    if (not self.lineProjectionFrame) then
        return;
    end

    self.lineProjectionFrame:Show();
end

--- Hides the Gizmo by hiding the line projection frame.
function Gizmo:Hide()
    if (not self.lineProjectionFrame) then
        return;
    end

    self.lineProjectionFrame:Hide();
end

--- Checks if the Gizmo is visible.
--- @return boolean: True if the Gizmo is visible, false otherwise.
function Gizmo:IsVisible()
    if (not self.lineProjectionFrame) then
        return false;
    end

    return self.lineProjectionFrame:IsVisible();
end

--- Transforms the Gizmo based on the given parameters.
--- @param position Vector3 The position of the Gizmo.
--- @param rotation Vector3 The rotation of the Gizmo.
--- @param scale number The scale of the Gizmo.
--- @param centerH number The center height of the bounding box.
--- @param space Gizmo.Space The space in which the transformation is applied (0 for world space, 1 for local space).
--- @param pivot Gizmo.Pivot The pivot point of the Gizmo (0 for center, 1 for base).
function Gizmo:TransformGizmo(position, rotation, scale, centerH, space, pivot)
    local pivotOffset;
    if (pivot == Gizmo.Pivot.Center) then
        pivotOffset = Vector3:New( 0, 0, 0 );
    elseif (pivot == Gizmo.Pivot.Base) then
        pivotOffset = Vector3:New(0, 0, centerH);
        pivotOffset:RotateAroundPivot(Vector3:New(0, 0, 0), rotation);
    end

    for q = 1, self.lineCount, 1 do
        for v = 1, 2, 1 do
            if (space == 1) then
                -- local space --
                local rotated = Vector3:New(self.vertices[q][v][1], self.vertices[q][v][2], self.vertices[q][v][3]);
                rotated:RotateAroundPivot(Vector3:New(0, 0, 0), rotation);
                self.transformedVertices[q][v][1] = rotated.x * self.scale * scale + position.x + pivotOffset.x;
                self.transformedVertices[q][v][2] = rotated.y * self.scale * scale + position.y + pivotOffset.y;
                self.transformedVertices[q][v][3] = rotated.z * self.scale * scale + position.z + pivotOffset.z;
            elseif (space == 0) then
                -- world space --
                local vert = Vector3:New(self.vertices[q][v][1], self.vertices[q][v][2], self.vertices[q][v][3]);
                self.transformedVertices[q][v][1] = vert.x * self.scale * scale + position.x + pivotOffset.x;
                self.transformedVertices[q][v][2] = vert.y * self.scale * scale + position.y + pivotOffset.y;
                self.transformedVertices[q][v][3] = vert.z * self.scale * scale + position.z + pivotOffset.z;
            end
        end
    end
end

--- Renders the lines of the Gizmo object.
function Gizmo:RenderLines()
    local vertices = self.transformedVertices;
    local faceColors = self.faceColors;

    for t = 1, self.lineCount, 1 do
        local vert = vertices[t];
        local faceColor = faceColors[t];
        
        local line = self.lines[t];
        
        -- Near plane face culling --
        local cull = Renderer.NearPlaneFaceCullingLine(vert, Camera.planePosition.x, Camera.planePosition.y, Camera.planePosition.z, Camera.forward.x, Camera.forward.y, Camera.forward.z, 0);

        if (not cull) then
            -- Project to screen space --
            local aX, aY, aZ = Renderer.projectionFrame:Project3DPointTo2D(vert[1][1],vert[1][2],vert[1][3]);
            local bX, bY, bZ = Renderer.projectionFrame:Project3DPointTo2D(vert[2][1],vert[2][2],vert[2][3]);
            
            --- these are needed for calculating mouse over
            self.screenSpaceVertices[t][1][1] = aX;
            self.screenSpaceVertices[t][1][2] = aY;
            self.screenSpaceVertices[t][2][1] = bX;
            self.screenSpaceVertices[t][2][2] = bY;

            -- Render --
            if (aX ~= nil and aY ~= nil and bX ~= nil and bY ~= nil) then
                line:Show();
                line:SetVertexColor(faceColor[1], faceColor[2], faceColor[3], faceColor[4] or 1);
                line:SetStartPoint("BOTTOMLEFT", aX * Renderer.scale, aY * Renderer.scale) -- start topleft
                line:SetEndPoint("BOTTOMLEFT", bX * Renderer.scale, bY * Renderer.scale)   -- end bottomright

                if (self.dashedLine == true) then
                    local dist = Vector3.ManhattanDistanceP(vert[1][1],vert[1][2],vert[1][3],vert[2][1],vert[2][2],vert[2][3]);
                    dist = math.min(math.max(dist, 1), 100);
                    line:SetTexCoord(0, dist , 0, 1);
                end

                if (self.lines ~= nil) then
                    self.lines[t] = line;
                    self.lineDepths[t] = aZ + bZ;
                end
            end
        else
            -- Cull --
            line:Hide();
        end

    end
end

--- Sets the scale of the Gizmo.
--- @param scale number The scale value to set.
function Gizmo:SetScale(scale)
    self.scale = scale;
end

--- Calculates the points on a circle in 3D space.
--- @param centerX number The x-coordinate of the circle's center.
--- @param centerY number The y-coordinate of the circle's center.
--- @param centerZ number The z-coordinate of the circle's center.
--- @param radius number The radius of the circle.
--- @param numPoints number The number of points to calculate on the circle.
--- @param axis Gizmo.Axis The axis along which the circle lies. Can be "x", "y", or "z".
--- @return table[]: An array containing the calculated points on the circle.
function Gizmo:CalculateCirclePoints(centerX, centerY, centerZ, radius, numPoints, axis)
    local points = {}

    for i = 1, numPoints do
        local theta = (i - 1) * (2 * math.pi) / numPoints
        local x, y, z;

        if axis == Gizmo.Axis.X then
            x = centerX;
            y = centerY + radius * math.cos(theta);
            z = centerZ + radius * math.sin(theta);
        elseif axis == Gizmo.Axis.Y then
            x = centerX + radius * math.cos(theta);
            y = centerY;
            z = centerZ + radius * math.sin(theta);
        elseif axis == Gizmo.Axis.Z then
            x = centerX + radius * math.cos(theta);
            y = centerY + radius * math.sin(theta);
            z = centerZ;
        else
            error("Invalid axis. Choose 'Gizmo.Axis.X', 'Gizmo.Axis.Y', or 'Gizmo.Axis.Z'.");
        end

        table.insert(points, {x, y, z});
    end

    return points
end

--- Finds the index of the smallest value in a table of exactly 3 values.
--- @param tbl table The input table containing exactly 3 values.
--- @return number: The index of the smallest value in the table.
function Gizmo:IndexOfSmallestAxis(tbl)
    if #tbl ~= 3 then
        error("Input table must have exactly 3 values.")
    end

    local minIndex = 1
    local minValue = tbl[1]

    for i = 2, 3 do
        if tbl[i] < minValue then
            minIndex = i
            minValue = tbl[i]
        end
    end

    return minIndex
end

-- This function is used as the __index metamethod for the Gizmo table.
-- It is responsible for handling the indexing of Gizmo objects.
Gizmo.__index = function(t,k)
    local var = rawget(Gizmo, k)
        
    if var == nil then							
        var = rawget(fields, k)
        
        if var ~= nil then
            return var(t)	
        end
    end
    
    return var
end