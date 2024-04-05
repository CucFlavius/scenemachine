local Editor = SceneMachine.Editor;
local SM = Editor.SceneManager;
local OP = Editor.ObjectProperties;
local Renderer = SceneMachine.Renderer;
local UI = SceneMachine.UI;
local Resources = SceneMachine.Resources;
local L = Editor.localization;
local Actions = SceneMachine.Actions;
local CC = SceneMachine.CameraController;
local Camera = SceneMachine.Camera;

function OP.CreatePanel(w, h, c1, c2, c3, c4, leftPanel, startLevel)
    --local group = Editor.CreateGroup("Properties", h, leftPanel:GetFrame());
    local groupBG = UI.Rectangle:NewBLBR(6, 6, -6, 0, h, leftPanel:GetFrame(), 0.1757, 0.1757, 0.1875, 1);
    groupBG:SetFrameLevel(startLevel);
    groupBG.frame:SetResizable(true);
    groupBG.frame:SetUserPlaced(true);
    groupBG.frame:SetResizeBounds(120, 20, 800, 500);

    Editor.horizontalSeparatorL = UI.Rectangle:NewTLTR(0, 6, 0, 0, 6, groupBG:GetFrame(), 1, 1, 1, 0);
    Editor.horizontalSeparatorL:SetFrameLevel(startLevel + 10);
    Editor.horizontalSeparatorL:GetFrame():EnableMouse(true);
    Editor.horizontalSeparatorL:GetFrame():RegisterForDrag("LeftButton");
    Editor.horizontalSeparatorL:GetFrame():SetScript("OnDragStart", function()
        groupBG.frame:StartSizing("TOP");
        SetCursor(Resources.textures["CursorResizeV"]);
    end);
	Editor.horizontalSeparatorL:GetFrame():SetScript("OnDragStop", function()
        scenemachine_settings.propertiesPanelH = (groupBG:GetTop() - 6) - SceneMachine.mainWindow:GetBottom();
        groupBG.frame:StopMovingOrSizing();
        groupBG:SetPoint("BOTTOMRIGHT", leftPanel:GetFrame(), "BOTTOMRIGHT", -6, 0);
        groupBG:SetPoint("BOTTOMLEFT", leftPanel:GetFrame(), "BOTTOMLEFT", 6, 6);
        ResetCursor();
    end);
    Editor.horizontalSeparatorL:GetFrame():SetScript('OnEnter', function() SetCursor(Resources.textures["CursorResizeV"]); end)
    Editor.horizontalSeparatorL:GetFrame():SetScript('OnLeave', function() ResetCursor(); end)

    local groupTitleText = UI.Label:NewTLTR(10, 0, 0, 0, 20, groupBG:GetFrame(), L["OP_TITLE"], 9);
    groupTitleText:SetPoint("TOPRIGHT", groupBG:GetFrame(), "TOPRIGHT", 0, 0);
    groupTitleText:SetFrameLevel(startLevel + 1);

    local groupContent = UI.Rectangle:NewTLBR(0, -20, 0, 0, groupBG:GetFrame(), 0.1445, 0.1445, 0.1445, 1);
    groupContent:SetFrameLevel(startLevel + 2);

    OP.collapseList = UI.CollapsableList:NewTLBR(0, 0, 0, 0, groupContent:GetFrame(), { 71, 49, 159, 71 },
        { L["OP_TRANSFORM"], L["OP_ACTOR_PROPERTIES"], L["OP_SCENE_PROPERTIES"], L["OP_CAMERA_PROPERTIES"], }, c1[1], c1[2], c1[3], 1);
    OP.collapseList:SetFrameLevel(startLevel + 3);
    
    OP.transformPropertyGroup = OP.collapseList.bars[1];
    OP.positionField = UI.PropertyFieldVector3:New(-5, 20, OP.transformPropertyGroup.panel:GetFrame(), L["POSITION"], {0, 0, 0}, OP.SetPosX, OP.SetPosY, OP.SetPosZ);
    OP.rotationField = UI.PropertyFieldVector3:New(-27, 20, OP.transformPropertyGroup.panel:GetFrame(), L["ROTATION"], {0, 0, 0}, OP.SetRotX, OP.SetRotY, OP.SetRotZ);
    OP.scaleField = UI.PropertyFieldFloat:New(-49, 20, OP.transformPropertyGroup.panel:GetFrame(), L["SCALE"], 1, OP.SetScale);

    OP.actorPropertyGroup = OP.collapseList.bars[2];
    OP.alphaField = UI.PropertyFieldFloat:New(-5, 20, OP.actorPropertyGroup.panel:GetFrame(), L["ALPHA"], 1, OP.SetAlpha);
    OP.saturationField = UI.PropertyFieldFloat:New(-27, 20, OP.actorPropertyGroup.panel:GetFrame(), L["DESATURATION"], 0, OP.SetDesaturation);

    local onPropertyColorStartAction = function() Editor.StartAction(Actions.Action.Type.SceneProperties, SM.loadedScene:GetProperties()); end
    local onPropertyColorFinishAction = function() Editor.FinishAction(SM.loadedScene:GetProperties()); end
    OP.scenePropertyGroup = OP.collapseList.bars[3];
    OP.ambientColorField = UI.PropertyFieldColor:New(-5, 20, OP.scenePropertyGroup.panel:GetFrame(), L["OP_AMBIENT_COLOR"], 0, 0, 0, 1, OP.SetAmbientColor, onPropertyColorStartAction, onPropertyColorFinishAction);
    OP.diffuseColorField = UI.PropertyFieldColor:New(-27, 20, OP.scenePropertyGroup.panel:GetFrame(), L["OP_DIFFUSE_COLOR"], 0, 0, 0, 1, OP.SetDiffuseColor, onPropertyColorStartAction, onPropertyColorFinishAction);
    OP.backgroundColorField = UI.PropertyFieldColor:New(-49, 20, OP.scenePropertyGroup.panel:GetFrame(), L["OP_BACKGROUND_COLOR"], 0.554,0.554,0.554,1, OP.SetBackgroundColor, onPropertyColorStartAction, onPropertyColorFinishAction);
    OP.enableLightingField = UI.PropertyFieldCheckbox:New(-71, 20, OP.scenePropertyGroup.panel:GetFrame(), L["OP_ENABLE_LIGHTING"], true, OP.ToggleLighting);
    OP.enableFogField = UI.PropertyFieldCheckbox:New(-93, 20, OP.scenePropertyGroup.panel:GetFrame(), L["OP_ENABLE_FOG"], true, OP.ToggleFog);
    OP.fogColorField = UI.PropertyFieldColor:New(-115, 20, OP.scenePropertyGroup.panel:GetFrame(), L["OP_FOG_COLOR"], 0, 0, 0, 1, OP.SetFogColor, onPropertyColorStartAction, onPropertyColorFinishAction);
    OP.fogDistanceField = UI.PropertyFieldFloat:New(-137, 20, OP.scenePropertyGroup.panel:GetFrame(), L["OP_FOG_DISTANCE"], 100, OP.SetFogDistance);

    OP.cameraPropertyGroup = OP.collapseList.bars[4];
    OP.fieldOfViewField = UI.PropertyFieldFloat:New(-5, 20, OP.cameraPropertyGroup.panel:GetFrame(), L["FOV"], 70, OP.SetFoV);
    OP.nearClipField = UI.PropertyFieldFloat:New(-27, 20, OP.cameraPropertyGroup.panel:GetFrame(), L["NEARCLIP"], 0.01, OP.SetNearClip);
    OP.farClipField = UI.PropertyFieldFloat:New(-49, 20, OP.cameraPropertyGroup.panel:GetFrame(), L["FARCLIP"], 1000, OP.SetFarClip);

    OP.Refresh();
end

function OP.Refresh()
    if (not SM.loadedScene) then
        return;
    end

    -- TODO: MOVE THIS outside of here, and call every time selection changes
    SM.CalculateObjectsAverage();
    
    local pos, rot, scale, alpha, desaturation;

    if (#SM.selectedObjects == 0) then
        OP.ToggleTransformFields(false);
        pos = { x=0, y=0, z=0 };
        rot = { x=0, y=0, z=0 };
        scale = 1;
        alpha = 1;
        desaturation = 0;
        OP.transformPropertyGroup:Hide();
        OP.actorPropertyGroup:Hide();
        OP.cameraPropertyGroup:Hide();
        OP.scenePropertyGroup:Show();
        OP.collapseList:Sort();
    elseif (#SM.selectedObjects == 1) then
        OP.ToggleTransformFields(true);
        pos = SM.selectedObjects[1]:GetPosition();
        rot = SM.selectedObjects[1]:GetRotation();
        scale = SM.selectedObjects[1]:GetScale();
        if (SM.selectedObjects[1]:HasActor()) then
            alpha = SM.selectedObjects[1]:GetAlpha();
            desaturation = SM.selectedObjects[1]:GetDesaturation();
        end
        -- change available properties when selecting a single object
        OP.transformPropertyGroup:Show();
        OP.actorPropertyGroup:Show();
        if (SM.selectedObjects[1]:HasActor()) then
            OP.actorPropertyGroup:Show();
        else
            OP.actorPropertyGroup:Hide();
        end

        if (SM.selectedObjects[1].type == SceneMachine.GameObjects.Object.Type.Camera) then
            OP.cameraPropertyGroup:Show();
            local fov = SM.selectedObjects[1]:GetFoV();
            OP.fieldOfViewField:Set(OP.Truncate(math.deg(fov), 2));
            local near = SM.selectedObjects[1]:GetNearClip();
            OP.nearClipField:Set(OP.Truncate(near, 2));
            local far = SM.selectedObjects[1]:GetFarClip();
            OP.farClipField:Set(OP.Truncate(far, 2));
        else
            OP.cameraPropertyGroup:Hide();
        end
        OP.scenePropertyGroup:Hide();
        OP.collapseList:Sort();
    else
        OP.ToggleTransformFields(true);
        pos = { x=0, y=0, z=0 };
        rot = { x=0, y=0, z=0 };
        scale = 1;
        alpha = 1;
        desaturation = 0;

        OP.transformPropertyGroup:Show();
        OP.actorPropertyGroup:Hide();
        OP.cameraPropertyGroup:Hide();
        OP.collapseList:Sort();
    end

    OP.positionField:Set(OP.Truncate(pos.x, 3), OP.Truncate(pos.y, 3), OP.Truncate(pos.z, 3));
    OP.rotationField:Set(OP.Truncate(math.deg(rot.x), 3), OP.Truncate(math.deg(rot.y), 3), OP.Truncate(math.deg(rot.z), 3));
    if (scale) then
        OP.scaleField:Set(OP.Truncate(scale, 3));
    end
    if (alpha) then
        OP.alphaField:Set(OP.Truncate(alpha, 3));
    end
    if (desaturation) then
        OP.saturationField:Set(OP.Truncate(desaturation, 3));
    end

    if (Renderer.projectionFrame) then
        local amb = SM.loadedScene:GetAmbientColor();
        OP.ambientColorField:Set(amb[1], amb[2], amb[3], 1);
        local dif = SM.loadedScene:GetDiffuseColor();
        OP.diffuseColorField:Set(dif[1], dif[2], dif[3], 1);
        local bg = SM.loadedScene:GetBackgroundColor();
        OP.backgroundColorField:Set(bg[1], bg[2], bg[3], 1);
        local enableLighting = SM.loadedScene:IsLightingEnabled();
        OP.enableLightingField:Set(enableLighting);
        local enableFog = SM.loadedScene:IsFogEnabled();
        OP.enableFogField:Set(enableFog);
        local fogColor = SM.loadedScene:GetFogColor();
        OP.fogColorField:Set(fogColor[1], fogColor[2], fogColor[3], 1);
        local fogDistance = SM.loadedScene:GetFogDistance();
        OP.fogDistanceField:Set(OP.Truncate(fogDistance, 3));
    end
end

function OP.ToggleTransformFields(enabled)
    OP.positionField:SetEnabled(enabled);
    OP.rotationField:SetEnabled(enabled);
    OP.scaleField:SetEnabled(enabled);
    OP.alphaField:SetEnabled(enabled);
end

function OP.SetPosX(value)
    if (not value) then
        return;
    end
    if (#SM.selectedObjects == 0) then
        return;
    end
    
    Editor.StartAction(Actions.Action.Type.TransformObject, SM.selectedObjects);
    for i = 1, #SM.selectedObjects, 1 do
        local pos = SM.selectedObjects[i]:GetPosition();
        SM.selectedObjects[i]:SetPosition(value, pos.y, pos.z);
    end
    Editor.FinishAction();
    OP.Refresh();
end

function OP.SetPosY(value)
    if (not value) then
        return;
    end
    if (#SM.selectedObjects == 0) then
        return;
    end

    Editor.StartAction(Actions.Action.Type.TransformObject, SM.selectedObjects);
    for i = 1, #SM.selectedObjects, 1 do
        local pos = SM.selectedObjects[i]:GetPosition();
        SM.selectedObjects[i]:SetPosition(pos.x, value, pos.z);
    end
    Editor.FinishAction();
    OP.Refresh();
end

function OP.SetPosZ(value)
    if (not value) then
        return;
    end
    if (#SM.selectedObjects == 0) then
        return;
    end

    Editor.StartAction(Actions.Action.Type.TransformObject, SM.selectedObjects);
    for i = 1, #SM.selectedObjects, 1 do
        local pos = SM.selectedObjects[i]:GetPosition();
        SM.selectedObjects[i]:SetPosition(pos.x, pos.y, value);
    end
    Editor.FinishAction();
    OP.Refresh();
end

function OP.SetRotX(value)
    if (not value) then
        return;
    end
    if (#SM.selectedObjects == 0) then
        return;
    end

    Editor.StartAction(Actions.Action.Type.TransformObject, SM.selectedObjects);
    for i = 1, #SM.selectedObjects, 1 do
        local rot = SM.selectedObjects[i]:GetRotation();
        SM.selectedObjects[i]:SetRotation(rad(value), rot.y, rot.z);
    end
    Editor.FinishAction();
    OP.Refresh();
end

function OP.SetRotY(value)
    if (not value) then
        return;
    end
    if (#SM.selectedObjects == 0) then
        return;
    end

    Editor.StartAction(Actions.Action.Type.TransformObject, SM.selectedObjects);
    for i = 1, #SM.selectedObjects, 1 do
        local rot = SM.selectedObjects[i]:GetRotation();
        SM.selectedObjects[i]:SetRotation(rot.x, rad(value), rot.z);
    end
    Editor.FinishAction();
    OP.Refresh();
end

function OP.SetRotZ(value)
    if (not value) then
        return;
    end
    if (#SM.selectedObjects == 0) then
        return;
    end

    Editor.StartAction(Actions.Action.Type.TransformObject, SM.selectedObjects);
    for i = 1, #SM.selectedObjects, 1 do
        local rot = SM.selectedObjects[i]:GetRotation();
        SM.selectedObjects[i]:SetRotation(rot.x, rot.y, rad(value));
    end
    Editor.FinishAction();
    OP.Refresh();
end

function OP.SetScale(value)
    if (not value) then
        return;
    end
    if (#SM.selectedObjects == 0) then
        return;
    end

    Editor.StartAction(Actions.Action.Type.TransformObject, SM.selectedObjects);
    for i = 1, #SM.selectedObjects, 1 do
        SM.selectedObjects[i]:SetScale(value);
    end
    Editor.FinishAction();
    OP.Refresh();
end

function OP.SetAlpha(value)
    if (not value) then
        return;
    end
    if (#SM.selectedObjects == 0) then
        return;
    end

    Editor.StartAction(Actions.Action.Type.TransformObject, SM.selectedObjects);
    for i = 1, #SM.selectedObjects, 1 do
        SM.selectedObjects[i]:SetAlpha(value);
    end
    Editor.FinishAction();
end

function OP.SetDesaturation(value)
    if (not value) then
        return;
    end
    if (#SM.selectedObjects == 0) then
        return;
    end

    Editor.StartAction(Actions.Action.Type.TransformObject, SM.selectedObjects);
    for i = 1, #SM.selectedObjects, 1 do
        SM.selectedObjects[i]:SetDesaturation(value);
    end
    Editor.FinishAction();
end

function OP.Truncate(num, digits)
    local mult = 10^(digits)
    return math.modf(num*mult)/mult
end

function OP.SetAmbientColor(R, G, B, A)
    SM.loadedScene:SetAmbientColor(R, G, B, A);
end

function OP.SetDiffuseColor(R, G, B, A)
    SM.loadedScene:SetDiffuseColor(R, G, B, A);
end

function OP.SetBackgroundColor(R, G, B, A)
    SM.loadedScene:SetBackgroundColor(R, G, B, A);
end

function OP.ToggleLighting(on)
    SM.loadedScene:SetLightingEnabled(on);
end

function OP.ToggleFog(on)
    SM.loadedScene:SetFogEnabled(on);
end

function OP.SetFogColor(R, G, B, A)
    SM.loadedScene:SetFogColor(R, G, B, A);
end

function OP.SetFogDistance(value)
    SM.loadedScene:SetFogDistance(value);
end

function OP.SetFoV(fovDeg)
    SM.selectedObjects[1]:SetFoV(math.rad(fovDeg));

    if (CC.ControllingCameraObject == SM.selectedObjects[1]) then
        Camera.fov = math.rad(fovDeg);
    end
end

function OP.SetNearClip(near)
    SM.selectedObjects[1]:SetNearClip(near);

    if (CC.ControllingCameraObject == SM.selectedObjects[1]) then
        Camera.nearClip = near;
    end
end

function OP.SetFarClip(far)
    SM.selectedObjects[1]:SetFarClip(far);

    if (CC.ControllingCameraObject == SM.selectedObjects[1]) then
        Camera.farClip = far;
    end
end