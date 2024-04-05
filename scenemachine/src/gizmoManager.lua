local GM = SceneMachine.GizmoManager;
local Renderer = SceneMachine.Renderer;
local Editor = SceneMachine.Editor;
local SM = Editor.SceneManager;
local OP = Editor.ObjectProperties;
local Camera = SceneMachine.Camera;
local Input = SceneMachine.Input;
local Math = SceneMachine.Math;
local Resources = SceneMachine.Resources;
local Vector3 = SceneMachine.Vector3;
local UI = SceneMachine.UI;
local Actions = SceneMachine.Actions;
local Scene = SceneMachine.Scene;
local Gizmo = SceneMachine.Gizmos.Gizmo;
local SelectionGizmo = SceneMachine.Gizmos.SelectionGizmo;
local MoveGizmo = SceneMachine.Gizmos.MoveGizmo;
local RotateGizmo = SceneMachine.Gizmos.RotateGizmo;
local ScaleGizmo = SceneMachine.Gizmos.ScaleGizmo;
local CameraGizmo = SceneMachine.Gizmos.CameraGizmo;
local Object = SceneMachine.GameObjects.Object;
local Quaternion = SceneMachine.Quaternion;
local Settings = SceneMachine.Settings;

GM.isUsed = false;
GM.isHighlighted = false;
GM.activeTransformGizmo = Gizmo.TransformType.Move;
GM.pivot = Gizmo.Pivot.Center;
GM.multiTransform = Gizmo.MultiTransform.Together;
GM.LMBPrevious = {};
GM.frames = {};
GM.previousRotation = Vector3:New();
GM.rotationIncrement = 0;
GM.previousIPoints = {};
GM.marqueeOn = false;
GM.marqueeVisible = false;
GM.marqueeStartPoint = nil;
GM.marqueeAABBSSPoints = nil;
GM.lastSelectedCamera = nil;

GM.space = Gizmo.Space.Local;
GM.selectedAxis = Gizmo.Axis.X;

GM.forward = Vector3:New(1, 0, 0);
GM.right = Vector3:New(0, 1, 0);
GM.up = Vector3:New(0, 0, 1);

GM.axisToDirectionVector =
{
    [Gizmo.Axis.X] = GM.forward,
    [Gizmo.Axis.Y] = GM.right,
    [Gizmo.Axis.Z] = GM.up,
    [Gizmo.Axis.XY] = GM.up,
    [Gizmo.Axis.XZ] = GM.right,
    [Gizmo.Axis.YZ] = GM.forward,
};

function GM.Create()
    GM.selectionGizmo = SelectionGizmo:New();
    GM.moveGizmo = MoveGizmo:New();
    GM.rotateGizmo = RotateGizmo:New();
    GM.scaleGizmo = ScaleGizmo:New();
    GM.cameraGizmo = CameraGizmo:New();
    table.insert(Renderer.gizmos, GM.selectionGizmo);
    table.insert(Renderer.gizmos, GM.moveGizmo);
    table.insert(Renderer.gizmos, GM.rotateGizmo);
    table.insert(Renderer.gizmos, GM.scaleGizmo);
    table.insert(Renderer.gizmos, GM.cameraGizmo);
    GM.CreateMarqueeSelectGizmo(Renderer.projectionFrame, Renderer.projectionFrame:GetFrameLevel() + 1);
end

function GM.CreateMarqueeSelectGizmo(parent, startLevel)
    -- animation selection box thing
    GM.marqueeBox = UI.Rectangle:New(0, 0, 100, 100, parent, "TOPLEFT", "TOPLEFT",  1, 1, 1, 0);
    GM.marqueeBox:SetFrameLevel(startLevel + 5);

    local thickness = 1 + Editor.pmult;

    local lineTop = GM.marqueeBox:GetFrame():CreateLine(nil, nil, nil);
    local c = { 1, 1, 1, 0.9 };
    lineTop:SetThickness(thickness);
    lineTop:SetTexture(Resources.textures["DashedLine"], "REPEAT", "REPEAT", "NEAREST");
    lineTop:Show();
    lineTop:SetVertexColor(c[1], c[2], c[3], c[4]);
    lineTop:SetStartPoint("TOPLEFT", 0, -thickness / 2) -- start topleft
    lineTop:SetEndPoint("TOPRIGHT", 0, -thickness / 2)   -- end bottomright
    lineTop:SetTexCoord(0, 10, 0, 1);

    local lineBottom = GM.marqueeBox:GetFrame():CreateLine(nil, nil, nil);
    lineBottom:SetThickness(thickness);
    lineBottom:SetTexture(Resources.textures["DashedLine"], "REPEAT", "REPEAT", "NEAREST");
    lineBottom:Show();
    lineBottom:SetVertexColor(c[1], c[2], c[3], c[4]);
    lineBottom:SetStartPoint("BOTTOMLEFT", 0, thickness / 2) -- start topleft
    lineBottom:SetEndPoint("BOTTOMRIGHT", 0, thickness / 2)   -- end bottomright
    lineBottom:SetTexCoord(0, 10, 0, 1);

    local lineLeft = GM.marqueeBox:GetFrame():CreateLine(nil, nil, nil);
    lineLeft:SetThickness(thickness);
    lineLeft:SetTexture(Resources.textures["DashedLine"], "REPEAT", "REPEAT", "NEAREST");
    lineLeft:Show();
    lineLeft:SetVertexColor(c[1], c[2], c[3], c[4]);
    lineLeft:SetStartPoint("BOTTOMLEFT", thickness / 2, 0) -- start topleft
    lineLeft:SetEndPoint("TOPLEFT", thickness / 2, 0)   -- end bottomright
    lineLeft:SetTexCoord(0, 10, 0, 1);

    local lineRight = GM.marqueeBox:GetFrame():CreateLine(nil, nil, nil);
    lineRight:SetThickness(thickness);
    lineRight:SetTexture(Resources.textures["DashedLine"], "REPEAT", "REPEAT", "NEAREST");
    lineRight:Show();
    lineRight:SetVertexColor(c[1], c[2], c[3], c[4]);
    lineRight:SetStartPoint("BOTTOMRIGHT", -thickness / 2, 0) -- start topleft
    lineRight:SetEndPoint("TOPRIGHT", -thickness / 2, 0)   -- end bottomright
    lineRight:SetTexCoord(0, 10, 0, 1);

    GM.marqueeBox.lineTop = lineTop;
    GM.marqueeBox.lineBottom = lineBottom;
    GM.marqueeBox.lineLeft = lineLeft;
    GM.marqueeBox.lineRight = lineRight;
    GM.marqueeBox:Hide();
end

function GM.StartMarqueeSelect()
    if (not GM.marqueeBox) then
        return;
    end

    if (Input.IsChildWindowOpen()) then
        return;
    end

    GM.marqueeOn = true;
    GM.marqueeVisible = false;


    local w, h = Renderer.projectionFrame:GetSize();
    local rx = Input.mouseX * Renderer.scale;
    local ry = Input.mouseY * Renderer.scale;

    GM.marqueeStartPoint = { rx, ry };
    GM.marqueeBox:ClearAllPoints();
    GM.marqueeBox:SetPoint("BOTTOMLEFT", Renderer.projectionFrame, "BOTTOMLEFT", rx, ry);
end

function GM.EndMarqueeSelect()
    if (not GM.marqueeBox) then
        return;
    end

    if (GM.marqueeAABBSSPoints) then
        local selectedObjects = {};
        for i = 1, #GM.marqueeAABBSSPoints, 1 do
            if (GM.marqueeAABBSSPoints[i].selected) then
                selectedObjects[#selectedObjects + 1] = GM.marqueeAABBSSPoints[i].object;
            end
        end
        SM.SelectObjects(selectedObjects);
        if (Settings.ShowSelectionHighlight()) then
            for i = 1, #selectedObjects, 1 do
                selectedObjects[i]:Select();
            end
        end

        -- ensure all selection effects clear
        if (#selectedObjects == 0) then
            for i = 1, #GM.marqueeAABBSSPoints, 1 do
                GM.marqueeAABBSSPoints[i].object:Deselect();
            end
        end
        GM.marqueeAABBSSPoints = nil;
    end

    GM.marqueeOn = false;
    GM.marqueeVisible = false;
    GM.marqueeBox:Hide();
end

function GM.Update()
    local mouseX, mouseY = Input.mouseX, Input.mouseY;

    GM.highlightedAxis = 0;
    GM.isHighlighted = false;

    if (Renderer.scale) then
        local rx = mouseX * Renderer.scale;
        local ry = mouseY * Renderer.scale;
        GM.UpdateMarquee(rx, ry);
    end

    -- Handle gizmo mouse highlight and selection --
    GM.SelectionCheck(mouseX, mouseY);

    -- Handle gizmo visibility --
    GM.VisibilityCheck();

    -- Handle gizmo motion to transformation --
    GM.MotionToTransform();

    -- Update the gizmo transform --
    GM.UpdateGizmoTransform();
end

function GM.UpdateMarquee(mouseX, mouseY)
    if (GM.marqueeOn) then
        --print(mouseX, mouseY) bottom left is 0,0
        local w = mouseX - GM.marqueeStartPoint[1];
        local h = mouseY - GM.marqueeStartPoint[2];

        if (not GM.marqueeVisible) then
            if (math.abs(w) > 5 and math.abs(h) > 5) then
                GM.marqueeVisible = true;

                -- populate screen space points
                GM.marqueeAABBSSPoints = {};
                local idx = 1;
                
                for i = 1, SM.loadedScene:GetObjectCount(), 1 do
                    local object = SM.loadedScene:GetObject(i);
            
                    -- Can't select invisible/frozen, only in the hierarchy
                    if (object.visible) and (not object.frozen) and (object:GetType() ~= SceneMachine.GameObjects.Object.Type.Group) then

                        GM.marqueeAABBSSPoints[idx] = {};
                        local vertices = {};
                        GM.marqueeAABBSSPoints[idx].SSvertices = {};
                        GM.marqueeAABBSSPoints[idx].object = object;

                        local position = object:GetWorldPosition();
                        local rotation = object:GetWorldRotation();
                        local scale = object:GetWorldScale();

                        local bbCenter;
                        if (object:HasActor()) then
                            local xMin, yMin, zMin, xMax, yMax, zMax = object:GetActiveBoundingBox();
                            bbCenter = {(xMax - xMin) / 2, (yMax - yMin) / 2, (zMax - zMin) / 2};
                        else
                            bbCenter = { 0, 0, 0, };
                        end
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
                            GM.marqueeAABBSSPoints[idx].SSvertices[q] = {};
                            -- local space --
                            local rotated = Vector3:New(vertices[q][1], vertices[q][2], vertices[q][3]);
                            rotated:RotateAroundPivot(Vector3:New(0, 0, 0), rotation);
                            vertices[q][1] = rotated.x * scale + position.x;
                            vertices[q][2] = rotated.y * scale + position.y;
                            vertices[q][3] = rotated.z * scale + position.z;

                            local cull = Renderer.NearPlaneFaceCullingVert(vertices[q], Camera.planePosition.x, Camera.planePosition.y, Camera.planePosition.z, Camera.forward.x, Camera.forward.y, Camera.forward.z);

                            if (not cull) then
                                local aX, aY, aZ = Renderer.projectionFrame:Project3DPointTo2D(vertices[q][1], vertices[q][2], vertices[q][3]);
                                GM.marqueeAABBSSPoints[idx].SSvertices[q][1] = aX;
                                GM.marqueeAABBSSPoints[idx].SSvertices[q][2] = aY;
                            end
                            GM.marqueeAABBSSPoints[idx].SSvertices[q][3] = cull;
                        end

                        idx = idx + 1;
                    end
                end
            end
        end

        if (GM.marqueeVisible and GM.marqueeBox) then
            GM.marqueeBox:SetWidth(mouseX - GM.marqueeStartPoint[1]);
            GM.marqueeBox:SetHeight(mouseY - GM.marqueeStartPoint[2]);
            GM.marqueeBox:Show();

            GM.marqueeBox.lineTop:SetTexCoord(0, w / 10, 0, 1);
            GM.marqueeBox.lineBottom:SetTexCoord(0, w / 10, 0, 1);
            GM.marqueeBox.lineLeft:SetTexCoord(0, h / 10, 0, 1);
            GM.marqueeBox.lineRight:SetTexCoord(0, h / 10, 0, 1);

            for i = 1, #GM.marqueeAABBSSPoints, 1 do
                local selected = false;
                for v = 1, 8, 1 do
                    local vert = GM.marqueeAABBSSPoints[i].SSvertices[v];
                    local x = vert[1];
                    local y = vert[2];
                    local cull = vert[3];

                    if (not cull) then
                        local minX = math.min(mouseX, GM.marqueeStartPoint[1]);
                        local maxX = math.max(mouseX, GM.marqueeStartPoint[1]);
                        local minY = math.min(mouseY, GM.marqueeStartPoint[2]);
                        local maxY = math.max(mouseY, GM.marqueeStartPoint[2]);
                        if (x > minX and x < maxX and y > minY and y < maxY) then
                            selected = true;
                            break;
                        end
                    end
                end

                GM.marqueeAABBSSPoints[i].selected = selected;
                if (Settings.ShowSelectionHighlight()) then
                    if (selected) then
                        GM.marqueeAABBSSPoints[i].object:Select();
                    else
                        GM.marqueeAABBSSPoints[i].object:Deselect();
                    end
                end
            end
        end
    end
end

function GM.SelectionCheck(mouseX, mouseY)
    if not GM.isUsed then
        -- Position --
        if (GM.activeTransformGizmo == Gizmo.TransformType.Move) then
            GM.isHighlighted, GM.selectedAxis, GM.highlightedAxis = GM.moveGizmo:SelectionCheck(mouseX, mouseY);
            if (not GM.moveGizmo.axisVisibility[GM.highlightedAxis]) then
                GM.isHighlighted = false;
                GM.selectedAxis = -1;
            end
        -- Rotation --
        elseif (GM.activeTransformGizmo == Gizmo.TransformType.Rotate) then
            GM.isHighlighted, GM.selectedAxis, GM.highlightedAxis = GM.rotateGizmo:SelectionCheck(mouseX, mouseY);
        -- Scale --
        elseif(GM.activeTransformGizmo == Gizmo.TransformType.Scale) then
            GM.isHighlighted, GM.selectedAxis, GM.highlightedAxis = GM.scaleGizmo:SelectionCheck(mouseX, mouseY);
        end
    end
end

function GM.CalculateAngleBetweenPlanes(planeA, planeB)
    local dot = SceneMachine.Vector3.DotProduct(planeA, planeB);
    local magA = SceneMachine.Vector3.Magnitude(planeA);
    local magB = SceneMachine.Vector3.Magnitude(planeB);
    return math.acos(dot / (magA * magB));
end

function GM.ToggleAllAxesOn()
    GM.moveGizmo:ShowAxis(Gizmo.Axis.X);
    GM.moveGizmo:ShowAxis(Gizmo.Axis.Y);
    GM.moveGizmo:ShowAxis(Gizmo.Axis.Z);
    GM.moveGizmo:ShowAxis(Gizmo.Axis.XY);
    GM.moveGizmo:ShowAxis(Gizmo.Axis.XZ);
    GM.moveGizmo:ShowAxis(Gizmo.Axis.YZ);
end

function GM.MoveGizmoParalelAxesCheck()
    local x, y = Renderer.projectionFrame:Project3DPointTo2D(SM.selectedWorldPosition.x, SM.selectedWorldPosition.y, SM.selectedWorldPosition.z);
    local ray = Camera.ScreenPointToRay(x, y);

    -- xy
    local direction = GM.axisToDirectionVector[Gizmo.Axis.Z];
    local angle = GM.CalculateAngleBetweenPlanes(direction, ray.direction);

    if (angle > 1.55 and angle < 1.65) then
        GM.moveGizmo:HideAxis(Gizmo.Axis.XY);
    else
        GM.moveGizmo:ShowAxis(Gizmo.Axis.XY);
    end

    -- xz
    direction = GM.axisToDirectionVector[Gizmo.Axis.Y];
    angle = GM.CalculateAngleBetweenPlanes(direction, ray.direction);

    if (angle > 1.55 and angle < 1.65) then
        GM.moveGizmo:HideAxis(Gizmo.Axis.XZ);
    else
        GM.moveGizmo:ShowAxis(Gizmo.Axis.XZ);
    end

    -- yz
    direction = GM.axisToDirectionVector[Gizmo.Axis.X];
    angle = GM.CalculateAngleBetweenPlanes(direction, ray.direction);

    if (angle > 1.55 and angle < 1.65) then
        GM.moveGizmo:HideAxis(Gizmo.Axis.YZ);
    else
        GM.moveGizmo:ShowAxis(Gizmo.Axis.YZ);
    end
end

function GM.VisibilityCheck()
    if (not GM.selectionGizmo) then
        return;
    end

    if (#SM.selectedObjects > 0) then
        if (SM.selectedObjects[1]:GetGizmoType() == Object.GizmoType.Object) then
            GM.cameraGizmo:Hide();
            GM.selectionGizmo:Show();
        elseif (SM.selectedObjects[1]:GetGizmoType() == Object.GizmoType.Camera) then
            GM.selectionGizmo:Hide();
            GM.cameraGizmo:Show();
        end

        if(GM.activeTransformGizmo == Gizmo.TransformType.Move) then
            GM.moveGizmo:Show();
            GM.rotateGizmo:Hide();
            GM.scaleGizmo:Hide();

            -- update gizmo vectors
            local rotation = SM.selectedWorldRotation;
            local forward = Math.normalizeVector(Math.rotateVector(rotation.x, rotation.y, rotation.z, 1, 0, 0));
            local right = Math.normalizeVector(Math.rotateVector(rotation.x, rotation.y, rotation.z, 0, 1, 0));
            local up = Math.normalizeVector(Math.rotateVector(rotation.x, rotation.y, rotation.z, 0, 0, 1));
            GM.forward:Set(forward[1], forward[2], forward[3]);
            GM.right:Set(right[1], right[2], right[3]);
            GM.up:Set(up[1], up[2], up[3]);
            
            if (Settings.HideTranslationGizmosParallelToCamera()) then
                GM.MoveGizmoParalelAxesCheck();
            end
        elseif (GM.activeTransformGizmo == Gizmo.TransformType.Rotate) then
            GM.moveGizmo:Hide();
            GM.rotateGizmo:Show();
            GM.scaleGizmo:Hide();
        elseif (GM.activeTransformGizmo == Gizmo.TransformType.Scale) then
            GM.moveGizmo:Hide();
            GM.rotateGizmo:Hide();
            GM.scaleGizmo:Show();
        else
            GM.moveGizmo:Hide();
            GM.rotateGizmo:Hide();
            GM.scaleGizmo:Hide();
        end
    else
        GM.selectionGizmo:Hide();
        GM.moveGizmo:Hide();
        GM.rotateGizmo:Hide();
        GM.scaleGizmo:Hide();
        GM.cameraGizmo:Hide();
    end

    if (Settings.AlwaysShowCameraGizmo()) then
        GM.cameraGizmo:Show();
    end
end

function GM.UpdateGizmoTransform()

    if (#SM.selectedObjects == 0) then
        return;
    end

    if (not SM.selectedBounds) then
        return;
    end

    local worldPosition = SM.selectedWorldPosition;
    local worldRotation = SM.selectedWorldRotation;
    local worldScale = SM.selectedWorldScale;
    local centerH = 0;

    if (Settings.AlwaysShowCameraGizmo()) then
        if (GM.lastSelectedCamera) then
            local fov = GM.lastSelectedCamera:GetFoV();
            local aspect = 1 / Camera.aspectRatio;
            local near = 1;
            local far = 20;
            GM.cameraGizmo:GenerateCameraFrustumVertices(fov, aspect, near, far);
            GM.cameraGizmo:TransformGizmo(worldPosition, worldRotation, 1, 0, GM.space, 0);
        end
    end

    if (SM.selectedObjects[1]:GetGizmoType() == Object.GizmoType.Object) then
        local bb = SM.selectedBounds;
        local xMin, yMin, zMin, xMax, yMax, zMax = bb[1], bb[2], bb[3], bb[4], bb[5], bb[6];
        local bbCenter = {(xMax - xMin) / 2, (yMax - yMin) / 2, (zMax - zMin) / 2};
        centerH = -(zMax - zMin) / 2 * worldScale;
        GM.selectionGizmo:TransformToAABB(bbCenter);
        GM.selectionGizmo:TransformGizmo(worldPosition, worldRotation, worldScale, 0, 1, 1);
    elseif (SM.selectedObjects[1]:GetGizmoType() == Object.GizmoType.Camera) then
        local fov = SM.selectedObjects[1]:GetFoV();
        local aspect = 1 / Camera.aspectRatio;
        local near = 1;
        local far = 20;
        GM.cameraGizmo:GenerateCameraFrustumVertices(fov, aspect, near, far);
        GM.cameraGizmo:TransformGizmo(worldPosition, worldRotation, 1, 0, GM.space, 0);
        GM.lastSelectedCamera = SM.selectedObjects[1];
    end

    if (GM.activeTransformGizmo == Gizmo.TransformType.Move) then
        -- calculate a scale based on the gizmo distance from the camera (to keep it relatively the same size on screen)
        GM.moveGizmo:SetScale(Vector3.Distance(worldPosition, Camera.position) / 10 * Settings.GetGizmoSize());
        -- determine which axes point away from the camera in order to flip the gizmo
        local directionX = GM.axisToDirectionVector[Gizmo.Axis.X];
        local dotX = Vector3.DotProduct(directionX, Camera.forward);
        GM.moveGizmo.flipX = dotX > 0;
        local directionY = GM.axisToDirectionVector[Gizmo.Axis.Y];
        local dotY = Vector3.DotProduct(directionY, Camera.forward);
        GM.moveGizmo.flipY = dotY > 0;
        local directionZ = GM.axisToDirectionVector[Gizmo.Axis.Z];
        local dotZ = Vector3.DotProduct(directionZ, Camera.forward);
        GM.moveGizmo.flipZ = dotZ > 0;
        GM.moveGizmo:TransformGizmo(worldPosition, worldRotation, 1, centerH, GM.space, GM.pivot);
    elseif (GM.activeTransformGizmo == Gizmo.TransformType.Rotate) then
        -- calculate a scale based on the gizmo distance from the camera (to keep it relatively the same size on screen)
        GM.rotateGizmo:SetScale(Vector3.Distance(worldPosition, Camera.position) / 5 * Settings.GetGizmoSize());
        GM.rotateGizmo:TransformGizmo(worldPosition, worldRotation, 1, centerH, GM.space, GM.pivot);
    elseif (GM.activeTransformGizmo == Gizmo.TransformType.Scale) then
        GM.scaleGizmo:SetScale(Vector3.ManhattanDistance(worldPosition, Camera.position) / 15 * Settings.GetGizmoSize());
        GM.scaleGizmo:TransformGizmo(worldPosition, worldRotation, 1, centerH, GM.space, GM.pivot);
    end
end

function GM.ApplyPositionMotion(object, iPointDiff)
    if (not iPointDiff) then
        return;
    end

    local position = object:GetWorldPosition();
    position:Add(iPointDiff);
    object:SetWorldPosition(position.x, position.y, position.z);
end

local fullCircle = math.rad(360);
local halfCircle = math.rad(180);
local quarterCircle = math.rad(90);

function GM.ApplyRotationMotion(object, direction, mouseDiff, axis)

    local rotationOld = object:GetRotation();
    local oldRx = rotationOld.x;
    local oldRy = rotationOld.y;
    local oldRz = rotationOld.z;


    local repeatX = math.floor(oldRx / fullCircle);
    local repeatY = math.floor(oldRy / fullCircle);
    local repeatZ = math.floor(oldRz / fullCircle);

    -- Clamp rotation values between -180 and 180
    --oldRx = mod((oldRx + halfCircle), fullCircle) - halfCircle;
    --oldRy = mod((oldRy + halfCircle), fullCircle) - halfCircle;
    --oldRz = mod((oldRz + halfCircle), fullCircle) - halfCircle;
    --rotationOld:Set(oldRx, oldRy, oldRz);

    local rotation = Quaternion:New();
    rotation:SetFromEuler(rotationOld);
    rotation:RotateAroundAxis(direction, mouseDiff);
    local rotationNew = rotation:ToEuler();
    --[[
    if (mouseDiff > 0) then
        if (rotationOld.z > 0 and rotationNew.z < 0) then
            repeatZ = repeatZ + 1;
        elseif (rotationOld.z < 0 and rotationNew.z > 0) then
            repeatZ = repeatZ - 1;
        end
    elseif (mouseDiff < 0) then
        if (rotationOld.z > 0 and rotationNew.z < 0) then
            repeatZ = repeatZ + 1;
        elseif (rotationOld.z < 0 and rotationNew.z > 0) then
            repeatZ = repeatZ - 1;
        end
    end

    rotationNew.z = rotationNew.z + (repeatZ * fullCircle);
    --]]
    --[[
    if (rotationOld.x >= 0 and rotationNew.x < 0 and mouseDiff > 0) then
        -- x flipped from +180 to -180
        --rotationNew.x = rotationNew.x + fullCircle;
        repeatX = repeatX + 1;
    elseif (rotationOld.x < 0 and rotationNew.x >= 0 and mouseDiff < 0) then
        -- x flipped from -180 to +180
        --rotationNew.x = rotationNew.x - fullCircle;
        repeatX = repeatX - 1;
    end

    if (rotationOld.y >= 0 and rotationNew.y < 0 and mouseDiff > 0) then
        -- y flipped from +180 to -180
        --rotationNew.y = rotationNew.y + fullCircle;
        repeatY = repeatY + 1;
    elseif (rotationOld.y < 0 and rotationNew.y >= 0 and mouseDiff < 0) then
        -- y flipped from -180 to +180
        --rotationNew.y = rotationNew.y - fullCircle;
        repeatY = repeatY - 1;
    end
    --]]

    --rotationNew.x = rotationNew.x + repeatX * fullCircle;
    --rotationNew.y = rotationNew.y + repeatY * fullCircle;

    -- handle rotation that affects position
    local position = object:GetPosition();
    if (GM.multiTransform == Gizmo.MultiTransform.Together and #SM.selectedObjects > 1) then
        -- together
        local offsetVec = Vector3:New();
        if (GM.selectedAxis == Gizmo.Axis.X) then
            offsetVec.x = mouseDiff;
        elseif (GM.selectedAxis == Gizmo.Axis.Y) then
            offsetVec.y = mouseDiff;
        elseif (GM.selectedAxis == Gizmo.Axis.Z) then
            offsetVec.z = mouseDiff;
        end

        local pivotOffset = Vector3:New();
        pivotOffset:SetVector3(position);
        pivotOffset:RotateAroundPivot(
            Vector3:New(GM.center[1], GM.center[2], GM.center[3]),
            offsetVec
        );

        object:SetPosition(pivotOffset.x, pivotOffset.y, pivotOffset.z);
    else
        -- individual
        if (GM.pivot == Gizmo.Pivot.Base) then

            local xMin, yMin, zMin, xMax, yMax, zMax = object:GetActiveBoundingBox();
            local h = (zMax - zMin) / 2;

            local pivotCenter = Vector3:New();
            if (GM.selectedAxis == Gizmo.Axis.X) then
                pivotCenter.x = h;
            elseif (GM.selectedAxis == Gizmo.Axis.Y) then
                pivotCenter.y = h;
            elseif (GM.selectedAxis == Gizmo.Axis.Z) then
                pivotCenter.z = h;
            end

            local pivotOffsetA = Vector3:New(0, 0, -h);
            pivotOffsetA:RotateAroundPivot(pivotCenter, Vector3:New(oldRx, oldRy, oldRz));
            local pivotOffset = Vector3:New(0, 0, -h);
            pivotOffset:RotateAroundPivot(pivotCenter, Vector3:New(rotationNew.x, rotationNew.y, rotationNew.z));

            local px, py, pz = position.x, position.y, position.z;
            px = px + (pivotOffsetA.x - pivotOffset.x);
            py = py + (pivotOffsetA.y - pivotOffset.y);
            pz = pz + (pivotOffsetA.z - pivotOffset.z);
            object:SetPosition(px, py, pz);
        end
    end

    object:SetRotation(rotationNew.x, rotationNew.y, rotationNew.z);
end

function GM.ApplyScaleMotion(object, direction, mouseDiff)
    local s = object:GetScale();
    local position = object:GetPosition();
    local px, py, pz = position.x, position.y, position.z;

    if (GM.multiTransform == Gizmo.MultiTransform.Together and #SM.selectedObjects > 1) then
        local olds = s;
        s = s + mouseDiff;
        s = math.max(0.0001, s);
        object:SetScale(s, s, s);
        local h1, h2, h3 = px - GM.center[1], py - GM.center[2], pz + GM.center[3];
        h1 = h1 * (s - olds);
        h2 = h2 * (s - olds);
        h3 = h3 * (s - olds);

        object:SetPosition(px + h1, py + h2, pz + h3);
    else
        if (GM.pivot == Gizmo.Pivot.Center) then
            s = s + mouseDiff;
            s = math.max(0.0001, s);
            object:SetScale(s, s, s);
        elseif (GM.pivot == Gizmo.Pivot.Base) then
            local olds = s;
            s = s + mouseDiff;
            local xMin, yMin, zMin, xMax, yMax, zMax = object:GetActiveBoundingBox();
            local h = (zMax - zMin) / 2;
            s = math.max(0.0001, s);
            h = h * (s - olds);
            object:SetScale(s, s, s);

            local rotation = object:GetRotation();
            local rx, ry, rz = rotation.x, rotation.y, rotation.z;
            local up = Math.normalizeVector(Math.rotateVector(rx, ry, rz, 0, 0, 1));
            object:SetPosition(px + up[1] * h, py + up[2] * h, pz + up[3] * h);
        end
    end
end

function GM.MotionToTransform()
    if (not GM.isUsed) then
        return;
    end

    -- when using the gizmo (clicked), keep it highlighted even if the mouse moves away
    GM.highlightedAxis = GM.selectedAxis;

    local direction = GM.axisToDirectionVector[GM.selectedAxis];

    -- Position --
    if (GM.activeTransformGizmo == Gizmo.TransformType.Move) then
        local mouseRay = Camera.GetMouseRay();

        local iPoint;
        local position = SM.selectedWorldPosition;
        if (GM.selectedAxis == Gizmo.Axis.X or GM.selectedAxis == Gizmo.Axis.Y or GM.selectedAxis == Gizmo.Axis.Z) then
            iPoint = mouseRay:LineIntersection(position, direction);
        elseif (GM.selectedAxis == Gizmo.Axis.XY or GM.selectedAxis == Gizmo.Axis.XZ or GM.selectedAxis == Gizmo.Axis.YZ) then
            iPoint = mouseRay:PlaneIntersection(position, direction);
        end

        if (iPoint) then
            if (not GM.previousIPoint) then
                GM.previousIPoint = Vector3:New();
            end

            local iPointDiff = Vector3:New();
            iPointDiff:SetVector3(iPoint);
            iPointDiff:Subtract(GM.previousIPoint);

            for i = 1, #SM.selectedObjects, 1 do
                GM.ApplyPositionMotion(SM.selectedObjects[i], iPointDiff);
            end

            GM.previousIPoint:SetVector3(iPoint);
        end
    end

    -- Rotation --
    if (GM.activeTransformGizmo == Gizmo.TransformType.Rotate) then
        local xDiff = Input.mouseXRaw - (GM.LMBPrevious.x or Input.mouseXRaw);
        local yDiff = Input.mouseYRaw - (GM.LMBPrevious.y or Input.mouseYRaw);
        local mouseDiff = ((xDiff + yDiff) / 2) / 100;

        for i = 1, #SM.selectedObjects, 1 do
            GM.ApplyRotationMotion(SM.selectedObjects[i], direction, mouseDiff, GM.selectedAxis);
        end

        GM.LMBPrevious.x = Input.mouseXRaw;
		GM.LMBPrevious.y = Input.mouseYRaw;
    end
    
    if (GM.activeTransformGizmo == Gizmo.TransformType.Scale) then
        local xDiff = Input.mouseXRaw - (GM.LMBPrevious.x or Input.mouseXRaw);
        local yDiff = Input.mouseYRaw - (GM.LMBPrevious.y or Input.mouseYRaw);
        local mouseDiff = ((xDiff + yDiff) / 2) / 100;

        for i = 1, #SM.selectedObjects, 1 do
            GM.ApplyScaleMotion(SM.selectedObjects[i], direction, mouseDiff);
        end

        GM.LMBPrevious.x = Input.mouseXRaw;
		GM.LMBPrevious.y = Input.mouseYRaw;
    end

    -- Refresh --
    OP.Refresh();
end

function GM.OnLMBDown(x, y, recordAction)
	GM.LMBPrevious.x = x;
	GM.LMBPrevious.y = y;
    GM.isUsed = true;
    GM.rotationIncrement = 0;
    GM.recordAction = recordAction;

    -- Store initial values so they can be diffed during mouse movement
    -- in order to get smooth transition

    -- store rotation vector
    if (#SM.selectedObjects > 0) then
        -- store center
        if (GM.pivot == Gizmo.Pivot.Center) then
            GM.center = { SM.selectedPosition.x, SM.selectedPosition.y, SM.selectedPosition.z };
        elseif (GM.pivot == Gizmo.Pivot.Base) then
            local h = (SM.selectedBounds[6] - SM.selectedBounds[3]) / 2
            GM.center = { SM.selectedPosition.x, SM.selectedPosition.y, SM.selectedPosition.z - h };
        end
        local rotation = SM.selectedWorldRotation;

        if (GM.space == Gizmo.Space.World) then
            GM.forward:Set(1, 0, 0);
            GM.right:Set(0, 1, 0);
            GM.up:Set(0, 0, 1);
        elseif(GM.space == Gizmo.Space.Local) then
            local forward = Math.normalizeVector(Math.rotateVector(rotation.x, rotation.y, rotation.z, 1, 0, 0));
            local right = Math.normalizeVector(Math.rotateVector(rotation.x, rotation.y, rotation.z, 0, 1, 0));
            local up = Math.normalizeVector(Math.rotateVector(rotation.x, rotation.y, rotation.z, 0, 0, 1));
            GM.forward:Set(forward[1], forward[2], forward[3]);
            GM.right:Set(right[1], right[2], right[3]);
            GM.up:Set(up[1], up[2], up[3]);
        end

        GM.previousRotation:Set(rotation.x, rotation.y, rotation.z);
    else
        GM.forward:Set(1, 0, 0);
        GM.right:Set(0, 1, 0);
        GM.up:Set(0, 0, 1);
        GM.previousRotation:Set(0, 0, 0);
    end

    -- store initial ray intersection
    local position = SM.selectedWorldPosition;
    local mouseRay = Camera.GetMouseRay();
    if (GM.activeTransformGizmo == Gizmo.TransformType.Move) then
        local direction = GM.axisToDirectionVector[GM.selectedAxis];
        if (GM.selectedAxis == Gizmo.Axis.X or GM.selectedAxis == Gizmo.Axis.Y or GM.selectedAxis == Gizmo.Axis.Z) then
            GM.previousIPoint = mouseRay:LineIntersection(position, direction);
        elseif (GM.selectedAxis == Gizmo.Axis.XY or GM.selectedAxis == Gizmo.Axis.XZ or GM.selectedAxis == Gizmo.Axis.YZ) then
            GM.previousIPoint = mouseRay:PlaneIntersection(position, direction);
        end
    end

    if (not GM.previousIPoint) then
        GM.previousIPoint = Vector3:New();
    end

    if (not Input.mouseState.isDraggingAssetFromUI and recordAction) then
        Editor.StartAction(Actions.Action.Type.TransformObject, SM.selectedObjects);
    end
end

function GM.OnLMBUp()
    GM.isUsed = false;
    if (not Input.mouseState.isDraggingAssetFromUI and GM.recordAction) then
        local objectHierarchyAfter = Scene.RawCopyObjectHierarchy(SM.loadedScene:GetObjectHierarchy());
        Editor.FinishAction(objectHierarchyAfter);
    end
end