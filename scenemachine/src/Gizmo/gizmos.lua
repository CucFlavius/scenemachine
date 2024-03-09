local Gizmos = SceneMachine.Gizmos;
local Renderer = SceneMachine.Renderer;
local Editor = SceneMachine.Editor;
local SM = Editor.SceneManager;
local OP = Editor.ObjectProperties;
local Camera = SceneMachine.Camera;
local Input = SceneMachine.Input;
local Math = SceneMachine.Math;
local CC = SceneMachine.CameraController;
local Resources = SceneMachine.Resources;
local Vector3 = SceneMachine.Vector3;
local Quaternion = SceneMachine.Quaternion;
local Ray = SceneMachine.Ray;
local UI = SceneMachine.UI;

Gizmos.isUsed = false;
Gizmos.isHighlighted = false;
Gizmos.selectedAxis = 1;            -- x = 1, y = 2, z = 3
Gizmos.activeTransformGizmo = 1;    -- select = 0, move = 1, rotate = 2, scale = 3
Gizmos.space = 1;                   -- world = 0, local = 1
Gizmos.pivot = 0;                   -- center = 0, base(original) = 1 (Only really affects rotation)
Gizmos.LMBPrevious = {};
Gizmos.frames = {};
Gizmos.forward = Vector3:New(1, 0, 0);
Gizmos.right = Vector3:New(0, 1, 0);
Gizmos.up = Vector3:New(0, 0, 1);
Gizmos.previousRotation = Vector3:New();
Gizmos.rotationIncrement = 0;
Gizmos.previousIPoints = {};
Gizmos.marqueeOn = false;
Gizmos.marqueeVisible = false;
Gizmos.marqueeStartPoint = nil;
Gizmos.marqueeAABBSSPoints = nil;

function Gizmos.Create()
    Gizmos.CreateSelectionGizmo();
    Gizmos.CreateMoveGizmo();
    Gizmos.CreateRotateGizmo();
    Gizmos.CreateScaleGizmo();
    Gizmos.CreateDebugGizmo();
    Gizmos.CreateMarqueeSelectGizmo(Renderer.projectionFrame, Renderer.projectionFrame:GetFrameLevel() + 1);
end

function Gizmos.CreateMarqueeSelectGizmo(parent, startLevel)
    -- animation selection box thing
    Gizmos.marqueeBox = UI.Rectangle:New(0, 0, 100, 100, parent, "TOPLEFT", "TOPLEFT",  1, 1, 1, 0);
    Gizmos.marqueeBox:SetFrameLevel(startLevel + 5);

    local thickness = 1 + Editor.pmult;

    local lineTop = Gizmos.marqueeBox:GetFrame():CreateLine(nil, nil, nil);
    local c = { 1, 1, 1, 0.9 };
    lineTop:SetThickness(thickness);
    lineTop:SetTexture(Resources.textures["DashedLine"], "REPEAT", "REPEAT", "NEAREST");
    lineTop:Show();
    lineTop:SetVertexColor(c[1], c[2], c[3], c[4]);
    lineTop:SetStartPoint("TOPLEFT", 0, -thickness / 2) -- start topleft
    lineTop:SetEndPoint("TOPRIGHT", 0, -thickness / 2)   -- end bottomright
    lineTop:SetTexCoord(0, 10, 0, 1);

    local lineBottom = Gizmos.marqueeBox:GetFrame():CreateLine(nil, nil, nil);
    lineBottom:SetThickness(thickness);
    lineBottom:SetTexture(Resources.textures["DashedLine"], "REPEAT", "REPEAT", "NEAREST");
    lineBottom:Show();
    lineBottom:SetVertexColor(c[1], c[2], c[3], c[4]);
    lineBottom:SetStartPoint("BOTTOMLEFT", 0, thickness / 2) -- start topleft
    lineBottom:SetEndPoint("BOTTOMRIGHT", 0, thickness / 2)   -- end bottomright
    lineBottom:SetTexCoord(0, 10, 0, 1);

    local lineLeft = Gizmos.marqueeBox:GetFrame():CreateLine(nil, nil, nil);
    lineLeft:SetThickness(thickness);
    lineLeft:SetTexture(Resources.textures["DashedLine"], "REPEAT", "REPEAT", "NEAREST");
    lineLeft:Show();
    lineLeft:SetVertexColor(c[1], c[2], c[3], c[4]);
    lineLeft:SetStartPoint("BOTTOMLEFT", thickness / 2, 0) -- start topleft
    lineLeft:SetEndPoint("TOPLEFT", thickness / 2, 0)   -- end bottomright
    lineLeft:SetTexCoord(0, 10, 0, 1);

    local lineRight = Gizmos.marqueeBox:GetFrame():CreateLine(nil, nil, nil);
    lineRight:SetThickness(thickness);
    lineRight:SetTexture(Resources.textures["DashedLine"], "REPEAT", "REPEAT", "NEAREST");
    lineRight:Show();
    lineRight:SetVertexColor(c[1], c[2], c[3], c[4]);
    lineRight:SetStartPoint("BOTTOMRIGHT", -thickness / 2, 0) -- start topleft
    lineRight:SetEndPoint("TOPRIGHT", -thickness / 2, 0)   -- end bottomright
    lineRight:SetTexCoord(0, 10, 0, 1);

    Gizmos.marqueeBox.lineTop = lineTop;
    Gizmos.marqueeBox.lineBottom = lineBottom;
    Gizmos.marqueeBox.lineLeft = lineLeft;
    Gizmos.marqueeBox.lineRight = lineRight;
    Gizmos.marqueeBox:Hide();
end

function Gizmos.StartMarqueeSelect()
    Gizmos.marqueeOn = true;
    Gizmos.marqueeVisible = false;
    Gizmos.marqueeStartPoint = { Input.mouseX, Input.mouseY };
    Gizmos.marqueeBox:ClearAllPoints();
    Gizmos.marqueeBox:SetPoint("BOTTOMLEFT", Renderer.projectionFrame, "BOTTOMLEFT", Input.mouseX, Input.mouseY);
end

function Gizmos.EndMarqueeSelect()
    
    if (Gizmos.marqueeAABBSSPoints) then
        local selectedObjects = {};
        for i = 1, #Gizmos.marqueeAABBSSPoints, 1 do
            if (Gizmos.marqueeAABBSSPoints[i].selected) then
                selectedObjects[#selectedObjects + 1] = Gizmos.marqueeAABBSSPoints[i].object;
            end
        end
        SM.SelectObjects(selectedObjects);
        for i = 1, #selectedObjects, 1 do
            selectedObjects[i]:Select();
        end

        -- ensure all selection effects clear
        if (#selectedObjects == 0) then
            for i = 1, #Gizmos.marqueeAABBSSPoints, 1 do
                Gizmos.marqueeAABBSSPoints[i].object:Deselect();
            end
        end
        Gizmos.marqueeAABBSSPoints = nil;
    end

    Gizmos.marqueeOn = false;
    Gizmos.marqueeVisible = false;
    Gizmos.marqueeBox:Hide();
end

function Gizmos.CreateLineProjectionFrame()
	local lineProjectionFrame = CreateFrame("Frame", "lineProjectionFrame", Renderer.projectionFrame)
	lineProjectionFrame:SetFrameStrata(Editor.MAIN_FRAME_STRATA);
	--lineProjectionFrame:SetWidth(Renderer.w);
	--lineProjectionFrame:SetHeight(Renderer.h);
	--lineProjectionFrame:SetPoint("TOPRIGHT", Renderer.projectionFrame, "TOPRIGHT", 0, 0);
    lineProjectionFrame:SetAllPoints(Renderer.projectionFrame);
	lineProjectionFrame.texture = lineProjectionFrame:CreateTexture("Renderer.lineProjectionFrame.texture", "ARTWORK")
	lineProjectionFrame.texture:SetColorTexture(0,0,0,0);
	lineProjectionFrame.texture:SetAllPoints(Renderer.lineProjectionFrame);
	lineProjectionFrame:SetFrameLevel(101);
    lineProjectionFrame:Hide();
    return lineProjectionFrame;
end

function Gizmos.Update()
    local mouseX, mouseY = Input.mouseX, Input.mouseY;

    Gizmos.highlightedAxis = 0;
    Gizmos.isHighlighted = false;

    Gizmos.UpdateMarquee(mouseX, mouseY);

    -- Handle gizmo mouse highlight and selection --
    local highlighted = Gizmos.SelectionCheck(mouseX, mouseY);

    -- Handle gizmo visibility --
    Gizmos.VisibilityCheck();

    -- Handle gizmo motion to transformation --
    Gizmos.MotionToTransform();

    -- Update the gizmo transform --
    Gizmos.UpdateGizmoTransform();
end

function Gizmos.UpdateMarquee(mouseX, mouseY)
    if (Gizmos.marqueeOn) then
        --print(mouseX, mouseY) bottom left is 0,0
        local w = mouseX - Gizmos.marqueeStartPoint[1];
        local h = mouseY - Gizmos.marqueeStartPoint[2];

        if (not Gizmos.marqueeVisible) then
            if (math.abs(w) > 5 and math.abs(h) > 5) then
                Gizmos.marqueeVisible = true;

                -- populate screen space points
                Gizmos.marqueeAABBSSPoints = {};
                local idx = 1;
                
                for i = 1, #SM.loadedScene.objects, 1 do
                    local object = SM.loadedScene.objects[i];
            
                    -- Can't select invisible/frozen, only in the hierarchy
                    if (object.visible) and (not object.frozen) then

                        Gizmos.marqueeAABBSSPoints[idx] = {};
                        local vertices = {};
                        Gizmos.marqueeAABBSSPoints[idx].SSvertices = {};
                        Gizmos.marqueeAABBSSPoints[idx].object = object;

                        local position = object:GetPosition();
                        local rotation = object:GetRotation();
                        local scale = object:GetScale();
                        local xMin, yMin, zMin, xMax, yMax, zMax = object:GetActiveBoundingBox();
                        local bbCenter = {(xMax - xMin) / 2, (yMax - yMin) / 2, (zMax - zMin) / 2};

                        -- transformToAABB
                        local chX = bbCenter[1];
                        local chY = bbCenter[2];
                        local chZ = bbCenter[3];
                        vertices[1] = {-chX, -chY, -chZ};
                        vertices[2] = {chX, chY, chZ};
                        vertices[3] = {chX, -chY, -chZ};
                        vertices[4] = {chX, chY, -chZ};
                        vertices[5] = {chX, -chY, -chZ};
                        vertices[6] = {-chX, -chY, chZ};
                        vertices[7] = {-chX, chY, -chZ};
                        vertices[8] = {chX, -chY, chZ};

                        -- transformGizmo
                        for q = 1, 8, 1 do
                            Gizmos.marqueeAABBSSPoints[idx].SSvertices[q] = {};
                            -- local space --
                            local rotated = Vector3:New(vertices[q][1], vertices[q][2], vertices[q][3]);
                            rotated:RotateAroundPivot(Vector3:New(0, 0, 0), rotation);
                            vertices[q][1] = rotated.x * scale + position.x;
                            vertices[q][2] = rotated.y * scale + position.y;
                            vertices[q][3] = rotated.z * scale + position.z;

                            local cull = Renderer.NearPlaneFaceCullingVert(vertices[q], Camera.planePosition.x, Camera.planePosition.y, Camera.planePosition.z, Camera.forward.x, Camera.forward.y, Camera.forward.z);

                            if (not cull) then
                                local aX, aY, aZ = Renderer.projectionFrame:Project3DPointTo2D(vertices[q][1], vertices[q][2], vertices[q][3]);
                                Gizmos.marqueeAABBSSPoints[idx].SSvertices[q][1] = aX;
                                Gizmos.marqueeAABBSSPoints[idx].SSvertices[q][2] = aY;
                            end
                            Gizmos.marqueeAABBSSPoints[idx].SSvertices[q][3] = cull;
                        end

                        idx = idx + 1;
                    end
                end
            end
        end

        if (Gizmos.marqueeVisible) then
            Gizmos.marqueeBox:SetWidth(mouseX - Gizmos.marqueeStartPoint[1]);
            Gizmos.marqueeBox:SetHeight(mouseY - Gizmos.marqueeStartPoint[2]);
            Gizmos.marqueeBox:Show();

            Gizmos.marqueeBox.lineTop:SetTexCoord(0, w / 10, 0, 1);
            Gizmos.marqueeBox.lineBottom:SetTexCoord(0, w / 10, 0, 1);
            Gizmos.marqueeBox.lineLeft:SetTexCoord(0, h / 10, 0, 1);
            Gizmos.marqueeBox.lineRight:SetTexCoord(0, h / 10, 0, 1);

            for i = 1, #Gizmos.marqueeAABBSSPoints, 1 do
                local selected = false;
                for v = 1, 8, 1 do
                    local vert = Gizmos.marqueeAABBSSPoints[i].SSvertices[v];
                    local x = vert[1];
                    local y = vert[2];
                    local cull = vert[3];

                    if (not cull) then
                        local minX = math.min(mouseX, Gizmos.marqueeStartPoint[1]);
                        local maxX = math.max(mouseX, Gizmos.marqueeStartPoint[1]);
                        local minY = math.min(mouseY, Gizmos.marqueeStartPoint[2]);
                        local maxY = math.max(mouseY, Gizmos.marqueeStartPoint[2]);
                        if (x > minX and x < maxX and y > minY and y < maxY) then
                            selected = true;
                            break;
                        end
                    end
                end

                Gizmos.marqueeAABBSSPoints[i].selected = selected;
                if (selected) then
                    Gizmos.marqueeAABBSSPoints[i].object:Select();
                else
                    Gizmos.marqueeAABBSSPoints[i].object:Deselect();
                end
            end
        end
    end
end

local function indexOfSmallestValue(tbl)
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

function Gizmos.SelectionCheck(mouseX, mouseY)
    if not Gizmos.isUsed then
        -- Position --
        if (Gizmos.activeTransformGizmo == 1) then
            -- check against the rectangle XY
            -- <
            local aX = Gizmos.MoveGizmo.screenSpaceVertices[4][1][1];
            local aY = Gizmos.MoveGizmo.screenSpaceVertices[4][1][2];
            -- >
            local bX = Gizmos.MoveGizmo.screenSpaceVertices[5][1][1];
            local bY = Gizmos.MoveGizmo.screenSpaceVertices[5][1][2];
            -- v
            local cX = Gizmos.MoveGizmo.screenSpaceVertices[5][2][1];
            local cY = Gizmos.MoveGizmo.screenSpaceVertices[5][2][2];
            -- ^
            local dX = Gizmos.MoveGizmo.screenSpaceVertices[1][1][1];
            local dY = Gizmos.MoveGizmo.screenSpaceVertices[1][1][2];
            if (mouseX ~= nil and mouseY ~= nil and aX ~= nil and aY ~= nil and bX ~= nil and bY ~= nil) then
                local inTriangle = Math.isPointInPolygon(mouseX, mouseY, aX, aY, cX, cY, bX, bY, dX, dY);
                if (inTriangle) then
                    Gizmos.isHighlighted = true;
                    Gizmos.selectedAxis = 4;
                    Gizmos.highlightedAxis = 4;
                end
            end

            -- check against the rectangle XZ
            -- <
            local aX = Gizmos.MoveGizmo.screenSpaceVertices[6][1][1];
            local aY = Gizmos.MoveGizmo.screenSpaceVertices[6][1][2];
            -- >
            local bX = Gizmos.MoveGizmo.screenSpaceVertices[7][1][1];
            local bY = Gizmos.MoveGizmo.screenSpaceVertices[7][1][2];
            -- v
            local cX = Gizmos.MoveGizmo.screenSpaceVertices[7][2][1];
            local cY = Gizmos.MoveGizmo.screenSpaceVertices[7][2][2];
            -- ^
            local dX = Gizmos.MoveGizmo.screenSpaceVertices[1][1][1];
            local dY = Gizmos.MoveGizmo.screenSpaceVertices[1][1][2];
            if (mouseX ~= nil and mouseY ~= nil and aX ~= nil and aY ~= nil and bX ~= nil and bY ~= nil) then
                local inTriangle = Math.isPointInPolygon(mouseX, mouseY, aX, aY, cX, cY, bX, bY, dX, dY);
                if (inTriangle) then
                    Gizmos.isHighlighted = true;
                    Gizmos.selectedAxis = 5;
                    Gizmos.highlightedAxis = 5;
                end
            end

            -- check against the rectangle YZ
            -- <
            local aX = Gizmos.MoveGizmo.screenSpaceVertices[8][1][1];
            local aY = Gizmos.MoveGizmo.screenSpaceVertices[8][1][2];
            -- >
            local bX = Gizmos.MoveGizmo.screenSpaceVertices[9][1][1];
            local bY = Gizmos.MoveGizmo.screenSpaceVertices[9][1][2];
            -- v
            local cX = Gizmos.MoveGizmo.screenSpaceVertices[9][2][1];
            local cY = Gizmos.MoveGizmo.screenSpaceVertices[9][2][2];
            -- ^
            local dX = Gizmos.MoveGizmo.screenSpaceVertices[1][1][1];
            local dY = Gizmos.MoveGizmo.screenSpaceVertices[1][1][2];
            if (mouseX ~= nil and mouseY ~= nil and aX ~= nil and aY ~= nil and bX ~= nil and bY ~= nil) then
                local inTriangle = Math.isPointInPolygon(mouseX, mouseY, aX, aY, cX, cY, bX, bY, dX, dY);
                if (inTriangle) then
                    Gizmos.isHighlighted = true;
                    Gizmos.selectedAxis = 6;
                    Gizmos.highlightedAxis = 6;
                end
            end
            
            -- check against the line distances
            if (not Gizmos.isHighlighted) then
                local minDists = { 10000, 10000, 10000 };
                for t = 1, 3, 1 do
                    local aX = Gizmos.MoveGizmo.screenSpaceVertices[t][1][1];
                    local aY = Gizmos.MoveGizmo.screenSpaceVertices[t][1][2];
                    local bX = Gizmos.MoveGizmo.screenSpaceVertices[t][2][1];
                    local bY = Gizmos.MoveGizmo.screenSpaceVertices[t][2][2];

                    if (mouseX ~= nil and mouseY ~= nil and aX ~= nil and aY ~= nil and bX ~= nil and bY ~= nil) then
                        local dist = Math.distToSegment({mouseX, mouseY}, {aX, aY}, {bX, bY});
                        if (dist < 10) then
                            if (minDists[t] > dist) then
                                minDists[t] = dist;
                            end
                        end
                    end
                end

                local smallest = indexOfSmallestValue(minDists);
                if (minDists[smallest] < 10) then
                    Gizmos.isHighlighted = true;
                    Gizmos.selectedAxis = smallest;
                    Gizmos.highlightedAxis = smallest;
                end

            end
        -- Rotation --
        elseif (Gizmos.activeTransformGizmo == 2) then
            local minDists = { 10000, 10000, 10000 };
            for t = 1, Gizmos.RotateGizmo.lineCount, 1 do
                local aX = Gizmos.RotateGizmo.screenSpaceVertices[t][1][1];
                local aY = Gizmos.RotateGizmo.screenSpaceVertices[t][1][2];
                local bX = Gizmos.RotateGizmo.screenSpaceVertices[t][2][1];
                local bY = Gizmos.RotateGizmo.screenSpaceVertices[t][2][2];

                if (mouseX ~= nil and mouseY ~= nil and aX ~= nil and aY ~= nil and bX ~= nil and bY ~= nil) then
                    local dist = Math.distToSegment({mouseX, mouseY}, {aX, aY}, {bX, bY});
                    local line = Gizmos.RotateGizmo.lines[t];
                    if (dist < 10 and line.alpha > 0.2) then
                        local ax = line.axis;
                        if (minDists[ax] > dist) then
                            minDists[ax] = dist;
                        end
                    end
                end
            end

            local smallest = indexOfSmallestValue(minDists);
            if (minDists[smallest] < 10) then
                Gizmos.isHighlighted = true;
                Gizmos.selectedAxis = smallest;
                Gizmos.highlightedAxis = smallest;
            end

        -- Scale --
        elseif(Gizmos.activeTransformGizmo == 3) then
            for t = 1, Gizmos.ScaleGizmo.lineCount, 1 do
                local aX = Gizmos.ScaleGizmo.screenSpaceVertices[t][1][1];
                local aY = Gizmos.ScaleGizmo.screenSpaceVertices[t][1][2];
                local bX = Gizmos.ScaleGizmo.screenSpaceVertices[t][2][1];
                local bY = Gizmos.ScaleGizmo.screenSpaceVertices[t][2][2];

                if (mouseX ~= nil and mouseY ~= nil and aX ~= nil and aY ~= nil and bX ~= nil and bY ~= nil) then
                    local dist = Math.distToSegment({mouseX, mouseY}, {aX, aY}, {bX, bY});
                    if (dist < 30) then
                        Gizmos.isHighlighted = true;
                        Gizmos.selectedAxis = 1;
                        Gizmos.highlightedAxis = 1;
                    end
                end
            end
        end
    end
end

function Gizmos.VisibilityCheck()
    if (Gizmos.frames["SelectionGizmoFrame"] == nil) then
        return;
    end

    if (#SM.selectedObjects > 0) then
        Gizmos.frames["SelectionGizmoFrame"]:Show();

        if(Gizmos.activeTransformGizmo == 1) then
            Gizmos.frames["MoveGizmoFrame"]:Show();
            Gizmos.frames["RotateGizmoFrame"]:Hide();
            Gizmos.frames["ScaleGizmoFrame"]:Hide();
        elseif (Gizmos.activeTransformGizmo == 2) then
            Gizmos.frames["MoveGizmoFrame"]:Hide();
            Gizmos.frames["RotateGizmoFrame"]:Show();
            Gizmos.frames["ScaleGizmoFrame"]:Hide();
        elseif (Gizmos.activeTransformGizmo == 3) then
            Gizmos.frames["MoveGizmoFrame"]:Hide();
            Gizmos.frames["RotateGizmoFrame"]:Hide();
            Gizmos.frames["ScaleGizmoFrame"]:Show();
        else
            Gizmos.frames["MoveGizmoFrame"]:Hide();
            Gizmos.frames["RotateGizmoFrame"]:Hide();
            Gizmos.frames["ScaleGizmoFrame"]:Hide();
        end
    else
        Gizmos.frames["SelectionGizmoFrame"]:Hide();
        Gizmos.frames["MoveGizmoFrame"]:Hide();
        Gizmos.frames["RotateGizmoFrame"]:Hide();
        Gizmos.frames["ScaleGizmoFrame"]:Hide();
    end
end

function Gizmos.UpdateGizmoTransform()

    if (SceneMachine.Gizmos.DebugGizmo.active == true) then
        Gizmos.transformGizmo(SceneMachine.Gizmos.DebugGizmo, SceneMachine.Gizmos.DebugGizmo.position, SceneMachine.Gizmos.DebugGizmo.rotation, 1, {0, 0, 0}, 1, 0);
    end

    if (#SM.selectedObjects == 0) then
        return;
    end

    if (not SM.selectedBounds) then
        return;
    end

    local position = SM.selectedPosition;
    local rotation = SM.selectedRotation;
    local scale = SM.selectedScale;
    local bb = SM.selectedBounds;
    local xMin, yMin, zMin, xMax, yMax, zMax = bb[1], bb[2], bb[3], bb[4], bb[5], bb[6];
    local bbCenter = {(xMax - xMin) / 2, (yMax - yMin) / 2, (zMax - zMin) / 2};
    local centerH = -(zMax - zMin) / 2 * scale;
    Gizmos.transformToAABB(SceneMachine.Gizmos.WireBox, bbCenter);
    Gizmos.transformGizmo(SceneMachine.Gizmos.WireBox, position, rotation, scale, bbCenter, 1, 0);

    if (Gizmos.activeTransformGizmo == 1) then
        -- calculate a scale based on the gizmo distance from the camera (to keep it relatively the same size on screen)
        SceneMachine.Gizmos.MoveGizmo.scale = Vector3.ManhattanDistance(position, Camera.position) / 15;
        Gizmos.transformGizmo(SceneMachine.Gizmos.MoveGizmo, position, rotation, 1, centerH, Gizmos.space, Gizmos.pivot);
    elseif (Gizmos.activeTransformGizmo == 2) then
        -- calculate a scale based on the gizmo distance from the camera (to keep it relatively the same size on screen)
        SceneMachine.Gizmos.RotateGizmo.scale = Vector3.ManhattanDistance(position, Camera.position) / 10;
        Gizmos.transformGizmo(SceneMachine.Gizmos.RotateGizmo, position, rotation, 1, centerH, Gizmos.space, Gizmos.pivot);
    elseif (Gizmos.activeTransformGizmo == 3) then
        SceneMachine.Gizmos.ScaleGizmo.scale = Vector3.ManhattanDistance(position, Camera.position) / 15;
        Gizmos.transformGizmo(SceneMachine.Gizmos.ScaleGizmo, position, rotation, 1, centerH, Gizmos.space, Gizmos.pivot);
    end
end

function Gizmos.MotionToTransform()
    if (Gizmos.isUsed) then
        -- when using the gizmo (clicked), keep it highlighted even if the mouse moves away
        Gizmos.highlightedAxis = Gizmos.selectedAxis;

        local mouseRay = Camera.GetMouseRay();

        if (Gizmos.LMBPrevious.x == nil) then
            Gizmos.LMBPrevious.x = Input.mouseXRaw;
            Gizmos.LMBPrevious.y = Input.mouseYRaw;
        end
        
		local xDiff = Input.mouseXRaw - Gizmos.LMBPrevious.x;
		local yDiff = Input.mouseYRaw - Gizmos.LMBPrevious.y;
        local diff = ((xDiff + yDiff) / 2) / 100;

        if (#SM.selectedObjects > 0) then
            for i = 1, #SM.selectedObjects, 1 do
                local position = SM.selectedObjects[i]:GetPosition();
                local px, py, pz = position.x, position.y, position.z;
                local rotation = SM.selectedObjects[i]:GetRotation();
                local rx, ry, rz = rotation.x, rotation.y, rotation.z;
                local s = SM.selectedObjects[i]:GetScale();
                local iPoint;
                local axisMoveSpeed = 0.02;
                if (Gizmos.activeTransformGizmo == 1) then
                    if (Gizmos.selectedAxis == 1) then
                        -- X --
                        local ssX = Gizmos.MoveGizmo.screenSpaceVertices[1][2][1] - Gizmos.MoveGizmo.screenSpaceVertices[1][1][1];
                        local ssY = Gizmos.MoveGizmo.screenSpaceVertices[1][2][2] - Gizmos.MoveGizmo.screenSpaceVertices[1][1][2];
                        local ssMag = math.sqrt(ssX^2 + ssY^2);
                        if (ssMag == 0) then
                            ssX = 0;
                            ssY = 0;
                        else
                            ssX = ssX / ssMag;
                            ssY = ssY / ssMag;
                        end
                        local dot = Math.dotProduct(xDiff, yDiff, ssX, ssY);
                        local gscale = dot * axisMoveSpeed * Gizmos.MoveGizmo.scale;
                        if (Gizmos.space == 0) then
                            px = px + gscale;
                        elseif (Gizmos.space == 1) then
                            px = px + (gscale * Gizmos.forward.x);
                            py = py + (gscale * Gizmos.forward.y);
                            pz = pz + (gscale * Gizmos.forward.z);
                        end
                    elseif (Gizmos.selectedAxis == 2) then
                        -- Y --
                        local ssX = Gizmos.MoveGizmo.screenSpaceVertices[2][2][1] - Gizmos.MoveGizmo.screenSpaceVertices[2][1][1];
                        local ssY = Gizmos.MoveGizmo.screenSpaceVertices[2][2][2] - Gizmos.MoveGizmo.screenSpaceVertices[2][1][2];
                        local ssMag = math.sqrt(ssX^2 + ssY^2);
                        if (ssMag == 0) then
                            ssX = 0;
                            ssY = 0;
                        else
                            ssX = ssX / ssMag;
                            ssY = ssY / ssMag;
                        end
                        local dot = Math.dotProduct(xDiff, yDiff, ssX, ssY);
                        local gscale = dot * axisMoveSpeed * Gizmos.MoveGizmo.scale;
                        if (Gizmos.space == 0) then
                            py = py + gscale;
                        elseif (Gizmos.space == 1) then                    
                            px = px + (gscale * Gizmos.right.x);
                            py = py + (gscale * Gizmos.right.y);
                            pz = pz + (gscale * Gizmos.right.z);
                        end
                    elseif (Gizmos.selectedAxis == 3) then
                        -- Z --
                        local ssX = Gizmos.MoveGizmo.screenSpaceVertices[3][2][1] - Gizmos.MoveGizmo.screenSpaceVertices[3][1][1];
                        local ssY = Gizmos.MoveGizmo.screenSpaceVertices[3][2][2] - Gizmos.MoveGizmo.screenSpaceVertices[3][1][2];
                        local ssMag = math.sqrt(ssX^2 + ssY^2);
                        if (ssMag == 0) then
                            ssX = 0;
                            ssY = 0;
                        else
                            ssX = ssX / ssMag;
                            ssY = ssY / ssMag;
                        end
                        local dot = Math.dotProduct(xDiff, yDiff, ssX, ssY);
                        local gscale = dot * axisMoveSpeed * Gizmos.MoveGizmo.scale;
                        if (Gizmos.space == 0) then
                            pz = pz + gscale;
                        elseif (Gizmos.space == 1) then
                            px = px + (gscale * Gizmos.up.x);
                            py = py + (gscale * Gizmos.up.y);
                            pz = pz + (gscale * Gizmos.up.z);
                        end
                    elseif (Gizmos.selectedAxis == 4) then
                        -- XY --
                        iPoint = mouseRay:PlaneIntersection(SM.selectedObjects[1]:GetPosition(), Gizmos.up);
                        if (iPoint ~= nil) then
                            px = px + (iPoint.x - Gizmos.previousIPoints[i].x)
                            py = py + (iPoint.y - Gizmos.previousIPoints[i].y)
                            pz = pz + (iPoint.z - Gizmos.previousIPoints[i].z)
                        end
                    elseif (Gizmos.selectedAxis == 5) then
                        -- XZ --
                        iPoint = mouseRay:PlaneIntersection(SM.selectedObjects[1]:GetPosition(), Gizmos.right);
                        if (iPoint ~= nil) then
                            px = px + (iPoint.x - Gizmos.previousIPoints[i].x)
                            py = py + (iPoint.y - Gizmos.previousIPoints[i].y)
                            pz = pz + (iPoint.z - Gizmos.previousIPoints[i].z)
                        end
                    elseif (Gizmos.selectedAxis == 6) then
                        -- YZ --
                        iPoint = mouseRay:PlaneIntersection(SM.selectedObjects[1]:GetPosition(), Gizmos.forward);
                        if (iPoint ~= nil) then
                            px = px + (iPoint.x - Gizmos.previousIPoints[i].x)
                            py = py + (iPoint.y - Gizmos.previousIPoints[i].y)
                            pz = pz + (iPoint.z - Gizmos.previousIPoints[i].z)
                        end
                    end

                    if (iPoint and Gizmos.previousIPoints[i]) then
                        Gizmos.previousIPoints[i].x = iPoint.x;
                        Gizmos.previousIPoints[i].y = iPoint.y;
                        Gizmos.previousIPoints[i].z = iPoint.z;
                    end

                    SM.selectedObjects[i]:SetPosition(px, py, pz);
                elseif (Gizmos.activeTransformGizmo == 2) then
                    Gizmos.rotationIncrement = Gizmos.rotationIncrement + diff;
                    if (Gizmos.selectedAxis == 1) then
                        if (Gizmos.space == 0) then
                            local oldRx = rx;
                            rx = rx + diff;
                            if (Gizmos.pivot == 1) then
                                local xMin, yMin, zMin, xMax, yMax, zMax = SM.selectedObjects[i]:GetActiveBoundingBox();
                                local h = (zMax - zMin) / 2;
                                
                                local pivotOffsetA = Vector3:New(0, 0, -h);
                                pivotOffsetA:RotateAroundPivot(Vector3:New(h, 0, 0), Vector3:New(oldRx, 0, 0));
                                local pivotOffset = Vector3:New(0, 0, -h);
                                pivotOffset:RotateAroundPivot(Vector3:New(h, 0, 0), Vector3:New(rx, 0, 0));

                                px = px + (pivotOffsetA.x - pivotOffset.x);
                                py = py + (pivotOffsetA.y - pivotOffset.y);
                                pz = pz + (pivotOffsetA.z - pivotOffset.z);
                                SM.selectedObjects[i]:SetPosition(px, py, pz);
                            end
                        elseif (Gizmos.space == 1) then
                            local rot = Math.multiplyRotations(Gizmos.previousRotation, Vector3:New(Gizmos.rotationIncrement, 0, 0));
                            local oldRx = rx;
                            local oldRy = ry;
                            local oldRz = rz;
                            rx = rot.x;
                            ry = rot.y;
                            rz = rot.z;

                            if (Gizmos.pivot == 1) then
                                local xMin, yMin, zMin, xMax, yMax, zMax = SM.selectedObjects[i]:GetActiveBoundingBox();
                                local h = (zMax - zMin) / 2;
                                
                                local pivotOffsetA = Vector3:New(0, 0, -h);
                                pivotOffsetA:RotateAroundPivot(Vector3:New(h, 0, 0), Vector3:New(oldRx, oldRy, oldRz));
                                local pivotOffset = Vector3:New(0, 0, -h);
                                pivotOffset:RotateAroundPivot(Vector3:New(h, 0, 0), Vector3:New(rx, ry, rz));

                                px = px + (pivotOffsetA.x - pivotOffset.x);
                                py = py + (pivotOffsetA.y - pivotOffset.y);
                                pz = pz + (pivotOffsetA.z - pivotOffset.z);
                                SM.selectedObjects[i]:SetPosition(px, py, pz);
                            end
                        end
                    elseif (Gizmos.selectedAxis == 2) then
                        if (Gizmos.space == 0) then
                            local oldRy = ry;
                            ry = ry + diff;
                            if (Gizmos.pivot == 1) then
                                local xMin, yMin, zMin, xMax, yMax, zMax = SM.selectedObjects[i]:GetActiveBoundingBox();
                                local h = (zMax - zMin) / 2;
                                
                                local pivotOffsetA = Vector3:New(0, 0, -h);
                                pivotOffsetA:RotateAroundPivot(Vector3:New(0, h, 0), Vector3:New(0, oldRy, 0));
                                local pivotOffset = Vector3:New(0, 0, -h);
                                pivotOffset:RotateAroundPivot(Vector3:New(0, h, 0), Vector3:New(0, ry, 0));

                                px = px + (pivotOffsetA.x - pivotOffset.x);
                                py = py + (pivotOffsetA.y - pivotOffset.y);
                                pz = pz + (pivotOffsetA.z - pivotOffset.z);
                                SM.selectedObjects[i]:SetPosition(px, py, pz);
                            end
                        elseif (Gizmos.space == 1) then
                            local rot = Math.multiplyRotations(Gizmos.previousRotation, Vector3:New(0, Gizmos.rotationIncrement, 0));
                            local oldRx = rx;
                            local oldRy = ry;
                            local oldRz = rz;
                            rx = rot.x;
                            ry = rot.y;
                            rz = rot.z;

                            if (Gizmos.pivot == 1) then
                                local xMin, yMin, zMin, xMax, yMax, zMax = SM.selectedObjects[i]:GetActiveBoundingBox();
                                local h = (zMax - zMin) / 2;
                                
                                local pivotOffsetA = Vector3:New(0, 0, -h);
                                pivotOffsetA:RotateAroundPivot(Vector3:New(0, h, 0), Vector3:New(oldRx, oldRy, oldRz));
                                local pivotOffset = Vector3:New(0, 0, -h);
                                pivotOffset:RotateAroundPivot(Vector3:New(0, h, 0), Vector3:New(rx, ry, rz));

                                px = px + (pivotOffsetA.x - pivotOffset.x);
                                py = py + (pivotOffsetA.y - pivotOffset.y);
                                pz = pz + (pivotOffsetA.z - pivotOffset.z);
                                SM.selectedObjects[i]:SetPosition(px, py, pz);
                            end
                        end
                    elseif (Gizmos.selectedAxis == 3) then
                        if (Gizmos.space == 0) then
                            local oldRz = rz;
                            rz = rz + diff;
                            if (Gizmos.pivot == 1) then
                                local xMin, yMin, zMin, xMax, yMax, zMax = SM.selectedObjects[i]:GetActiveBoundingBox();
                                local h = (zMax - zMin) / 2;
                                
                                local pivotOffsetA = Vector3:New(0, 0, -h);
                                pivotOffsetA:RotateAroundPivot(Vector3:New(0, 0, h), Vector3:New(0, 0, oldRz));
                                local pivotOffset = Vector3:New(0, 0, -h);
                                pivotOffset:RotateAroundPivot(Vector3:New(0, 0, h), Vector3:New(0, 0, rz));

                                px = px + (pivotOffsetA.x - pivotOffset.x);
                                py = py + (pivotOffsetA.y - pivotOffset.y);
                                pz = pz + (pivotOffsetA.z - pivotOffset.z);
                                SM.selectedObjects[i]:SetPosition(px, py, pz);
                            end
                        elseif (Gizmos.space == 1) then
                            local rot = Math.multiplyRotations(Gizmos.previousRotation, Vector3:New(0, 0, Gizmos.rotationIncrement));
                            local oldRx = rx;
                            local oldRy = ry;
                            local oldRz = rz;
                            rx = rot.x;
                            ry = rot.y;
                            rz = rot.z;

                            if (Gizmos.pivot == 1) then
                                local xMin, yMin, zMin, xMax, yMax, zMax = SM.selectedObjects[i]:GetActiveBoundingBox();
                                local h = (zMax - zMin) / 2;
                                
                                local pivotOffsetA = Vector3:New(0, 0, -h);
                                pivotOffsetA:RotateAroundPivot(Vector3:New(0, 0, h), Vector3:New(oldRx, oldRy, oldRz));
                                local pivotOffset = Vector3:New(0, 0, -h);
                                pivotOffset:RotateAroundPivot(Vector3:New(0, 0, h), Vector3:New(rx, ry, rz));

                                px = px + (pivotOffsetA.x - pivotOffset.x);
                                py = py + (pivotOffsetA.y - pivotOffset.y);
                                pz = pz + (pivotOffsetA.z - pivotOffset.z);
                                SM.selectedObjects[i]:SetPosition(px, py, pz);
                            end
                        end
                    end

                    SM.selectedObjects[i]:SetRotation(rx, ry, rz);
                elseif (Gizmos.activeTransformGizmo == 3) then
                    if (Gizmos.pivot == 0) then
                        s = s + diff;
                        s = math.max(0.0001, s);
                        SM.selectedObjects[i]:SetScale(s, s, s);
                    elseif (Gizmos.pivot == 1) then
                        s = s + diff;
                        local xMin, yMin, zMin, xMax, yMax, zMax = SM.selectedObjects[i]:GetActiveBoundingBox();
                        local h = (zMax - zMin) / 2 * diff;
                        s = math.max(0.0001, s);
                        SM.selectedObjects[i]:SetScale(s, s, s);
                        SM.selectedObjects[i]:SetPosition(px, py, pz + h);
                    end
                end
            end

            OP.Refresh();
        end

        Gizmos.LMBPrevious.x = Input.mouseXRaw;
		Gizmos.LMBPrevious.y = Input.mouseYRaw;
    end

end

function Gizmos.OnLMBDown(x, y)
	Gizmos.LMBPrevious.x = x;
	Gizmos.LMBPrevious.y = y;
    Gizmos.isUsed = true;
    Gizmos.rotationIncrement = 0;

    -- Store initial values so they can be diffed during mouse movement
    -- in order to get smooth transition

    -- store rotation vector
    if (#SM.selectedObjects > 0) then
        local rotation = SM.selectedRotation;--SM.selectedObject:GetRotation();
        local rx, ry, rz = rotation.x, rotation.y, rotation.z;
        local forward = Math.normalize(Math.rotateVector(rx, ry, rz, 1, 0, 0));
        local right = Math.normalize(Math.rotateVector(rx, ry, rz, 0, 1, 0));
        local up = Math.normalize(Math.rotateVector(rx, ry, rz, 0, 0, 1));
        Gizmos.forward:Set(forward[1], forward[2], forward[3]);
        Gizmos.right:Set(right[1], right[2], right[3]);
        Gizmos.up:Set(up[1], up[2], up[3]);
        Gizmos.previousRotation:Set(rx, ry, rz);
    else
        Gizmos.forward:SetVector3(Vector3.forward);
        Gizmos.right:SetVector3(Vector3.right);
        Gizmos.up:SetVector3(Vector3.up);
        Gizmos.previousRotation:Set(0, 0, 0);
    end

    -- store initial ray intersection
    if (#SM.selectedObjects > 0) then
        for i = 1, #SM.selectedObjects, 1 do
            local position = SM.selectedObjects[i]:GetPosition();
            local mouseRay = Camera.GetMouseRay();
            if (Gizmos.activeTransformGizmo == 1) then
                if (Gizmos.selectedAxis == 1) then
                    -- X --
                    Gizmos.previousIPoints[i] = mouseRay:PlaneIntersection(position, Gizmos.up) or Gizmos.previousIPoints[i];
                elseif (Gizmos.selectedAxis == 2) then
                    -- Y --
                    Gizmos.previousIPoints[i] = mouseRay:PlaneIntersection(position, Gizmos.up) or Gizmos.previousIPoints[i];
                elseif (Gizmos.selectedAxis == 3) then
                    -- Z --
                    Gizmos.previousIPoints[i] = mouseRay:PlaneIntersection(position, Gizmos.right) or Gizmos.previousIPoints[i];
                elseif (Gizmos.selectedAxis == 4) then
                    -- XY --
                    Gizmos.previousIPoints[i] = mouseRay:PlaneIntersection(SM.selectedObjects[1]:GetPosition(), Gizmos.up);
                elseif (Gizmos.selectedAxis == 5) then
                    -- XZ --
                    Gizmos.previousIPoints[i] = mouseRay:PlaneIntersection(SM.selectedObjects[1]:GetPosition(), Gizmos.right);
                elseif (Gizmos.selectedAxis == 6) then
                    -- YZ --
                    Gizmos.previousIPoints[i] = mouseRay:PlaneIntersection(SM.selectedObjects[1]:GetPosition(), Gizmos.forward);
                end
            end

            if (not Gizmos.previousIPoints[i]) then
                Gizmos.previousIPoints[i] = { x = 0, y = 0, z = 0 };
            end
        end
    end
end

function Gizmos.OnLMBUp()
    Gizmos.isUsed = false;
end

function Gizmos.transformGizmo(gizmo, position, rotation, scale, centerH, space, pivot)
    local pivotOffset;
    if (pivot == 0) then
        -- center
        pivotOffset = Vector3:New( 0, 0, 0 );
    elseif (pivot == 1) then
        -- base
        pivotOffset = Vector3:New(0, 0, centerH);
        pivotOffset:RotateAroundPivot(Vector3:New(0, 0, 0), rotation);
    end

    for q = 1, gizmo.lineCount, 1 do
        for v = 1, 2, 1 do
            if (space == 1) then
                -- local space --
                local rotated = Vector3:New(gizmo.vertices[q][v][1], gizmo.vertices[q][v][2], gizmo.vertices[q][v][3]);
                rotated:RotateAroundPivot(Vector3:New(0, 0, 0), rotation);
                gizmo.transformedVertices[q][v][1] = rotated.x * gizmo.scale * scale + position.x + pivotOffset.x;
                gizmo.transformedVertices[q][v][2] = rotated.y * gizmo.scale * scale + position.y + pivotOffset.y;
                gizmo.transformedVertices[q][v][3] = rotated.z * gizmo.scale * scale + position.z + pivotOffset.z;
            elseif (space == 0) then
                -- world space --
                gizmo.transformedVertices[q][v][1] = gizmo.vertices[q][v][1] * gizmo.scale * scale + position.x + pivotOffset.x;
                gizmo.transformedVertices[q][v][2] = gizmo.vertices[q][v][2] * gizmo.scale * scale + position.y + pivotOffset.y;
                gizmo.transformedVertices[q][v][3] = gizmo.vertices[q][v][3] * gizmo.scale * scale + position.z + pivotOffset.z;
            end
        end
    end
end

function Gizmos.transformToAABB(gizmo, boundsCenter)
    local chX = boundsCenter[1];
    local chY = boundsCenter[2];
    local chZ = boundsCenter[3];

    gizmo.vertices[1][1] = {-chX, -chY, -chZ};
    gizmo.vertices[1][2] = {chX, -chY, -chZ};
    gizmo.vertices[2][1] = {chX, -chY, -chZ};
    gizmo.vertices[2][2] = {chX, -chY, chZ};
    gizmo.vertices[3][1] = {chX, -chY, chZ};
    gizmo.vertices[3][2] = {-chX, -chY, chZ};
    gizmo.vertices[4][1] = {-chX, -chY, chZ};
    gizmo.vertices[4][2] = {-chX, -chY, -chZ};

    gizmo.vertices[5][1] = {-chX, chY, -chZ};
    gizmo.vertices[5][2] = {chX, chY, -chZ};
    gizmo.vertices[6][1] = {chX, chY, -chZ};
    gizmo.vertices[6][2] = {chX, chY, chZ};
    gizmo.vertices[7][1] = {chX, chY, chZ};
    gizmo.vertices[7][2] = {-chX, chY, chZ};
    gizmo.vertices[8][1] = {-chX, chY, chZ};
    gizmo.vertices[8][2] = {-chX, chY, -chZ};

    gizmo.vertices[9][1] = {-chX, -chY, -chZ};
    gizmo.vertices[9][2] = {-chX, chY, -chZ};
    gizmo.vertices[10][1] = {chX, -chY, -chZ};
    gizmo.vertices[10][2] = {chX, chY, -chZ};
    gizmo.vertices[11][1] = {chX, -chY, chZ};
    gizmo.vertices[11][2] = {chX, chY, chZ};
    gizmo.vertices[12][1] = {-chX, -chY, chZ};
    gizmo.vertices[12][2] = {-chX, chY, chZ};
end