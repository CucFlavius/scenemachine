local Editor = SceneMachine.Editor;
local PM = Editor.ProjectManager;
local SM = Editor.SceneManager;
local SH = Editor.SceneHierarchy;
local Gizmos = SceneMachine.Gizmos;
local OP = Editor.ObjectProperties;
local Renderer = SceneMachine.Renderer;
local UI = SceneMachine.UI;
local Resources = SceneMachine.Resources;
local L = Editor.localization;

function OP.CreatePanel(w, h, c1, c2, c3, c4, leftPanel, startLevel)
    --local group = Editor.CreateGroup("Properties", h, leftPanel:GetFrame());
    local groupBG = UI.Rectangle:New(-6, 0, w, h, leftPanel:GetFrame(), "BOTTOMRIGHT", "BOTTOMRIGHT",  0.1757, 0.1757, 0.1875, 1);
    groupBG:SetPoint("BOTTOMLEFT", leftPanel:GetFrame(), "BOTTOMLEFT", 6, 6);
    groupBG:SetFrameLevel(startLevel);
    groupBG.frame:SetResizable(true);
    groupBG.frame:SetUserPlaced(true);
    groupBG.frame:SetResizeBounds(120, 20, 800, 500);

    Editor.horizontalSeparatorL = UI.Rectangle:New(0, 6, 0, 6, groupBG:GetFrame(), "TOPLEFT", "TOPLEFT", 1,1,1,0);
    Editor.horizontalSeparatorL:SetPoint("TOPRIGHT", leftPanel:GetFrame(), "TOPRIGHT", 0, 0);
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

    local groupTitleText = UI.Label:New(0, 0, w - 30, 20, groupBG:GetFrame(), "TOPLEFT", "TOPLEFT", "   " .. L["OP_TITLE"], 9);
    groupTitleText:SetPoint("TOPRIGHT", groupBG:GetFrame(), "TOPRIGHT", 0, 0);
    groupTitleText:SetFrameLevel(startLevel + 1);

    local groupContent = UI.Rectangle:New(0, -20, w - 12, h - 20, groupBG:GetFrame(), "TOPLEFT", "TOPLEFT", 0.1445, 0.1445, 0.1445, 1);
    groupContent:SetPoint("BOTTOMRIGHT", groupBG:GetFrame(), "BOTTOMRIGHT", 0, 0);
    groupContent:SetFrameLevel(startLevel + 2);

    local collapseList = UI.CollapsableList:New(0, 0, w - 6, h - 20, { 71, 27, 71 }, groupContent:GetFrame(), "TOPLEFT", "TOPLEFT", { L["OP_TRANSFORM"], L["OP_ACTOR_PROPERTIES"], L["OP_SCENE_PROPERTIES"] }, c1[1], c1[2], c1[3], 1);
    collapseList:SetPoint("BOTTOMRIGHT", groupContent:GetFrame(), "BOTTOMRIGHT", 0, 0);
    collapseList:SetFrameLevel(startLevel + 3);
    
    local transformPropertyGroup = collapseList.bars[1].panel:GetFrame();
    OP.positionField = UI.PropertyFieldVector3:New(-5, 20, transformPropertyGroup, L["POSITION"], {0, 0, 0}, OP.SetPosX, OP.SetPosY, OP.SetPosZ);
    OP.rotationField = UI.PropertyFieldVector3:New(-27, 20, transformPropertyGroup, L["ROTATION"], {0, 0, 0}, OP.SetRotX, OP.SetRotY, OP.SetRotZ);
    OP.scaleField = UI.PropertyFieldFloat:New(-49, 20, transformPropertyGroup, L["SCALE"], 1, OP.SetScale);

    local actorPropertyGroup = collapseList.bars[2].panel:GetFrame();
    OP.alphaField = UI.PropertyFieldFloat:New(-5, 20, actorPropertyGroup, L["ALPHA"], 1, OP.SetAlpha);

    local scenePropertyGroup = collapseList.bars[3].panel:GetFrame();
    OP.ambientColorField = UI.PropertyFieldColor:New(-5, 20, scenePropertyGroup, L["OP_AMBIENT_COLOR"], 0, 0, 0, 1, OP.SetAmbientColor);
    OP.diffuseColorField = UI.PropertyFieldColor:New(-27, 20, scenePropertyGroup, L["OP_DIFFUSE_COLOR"], 0, 0, 0, 1, OP.SetDiffuseColor);
    OP.backgroundColorField = UI.PropertyFieldColor:New(-49, 20, scenePropertyGroup, L["OP_BACKGROUND_COLOR"], 0.554,0.554,0.554,1, OP.SetBackgroundColor);

    OP.Refresh();
end

function OP.Refresh()
    -- TODO: MOVE THIS outside of here, and call every time selection changes
    SM.CalculateObjectsAverage();
    
    local pos, rot, scale, alpha;

    --[[
    if (SM.selectedPosition == nil) then
        pos = { x=0, y=0, z=0 };
        rot = { x=0, y=0, z=0 };
        scale = 1;
        alpha = 1;
        OP.ToggleTransformFields(false);
    else
        OP.ToggleTransformFields(true);
        pos = SM.selectedPosition;
        rot = SM.selectedRotation;
        scale = SM.selectedScale;
        alpha = SM.selectedAlpha;
    end
    --]]

    if (#SM.selectedObjects == 0) then
        OP.ToggleTransformFields(false);
        pos = { x=0, y=0, z=0 };
        rot = { x=0, y=0, z=0 };
        scale = 1;
        alpha = 1;
    elseif (#SM.selectedObjects == 1) then
        OP.ToggleTransformFields(true);
        pos = SM.selectedObjects[1]:GetPosition();
        rot = SM.selectedObjects[1]:GetRotation();
        scale = SM.selectedObjects[1]:GetScale();
        alpha = SM.selectedObjects[1]:GetAlpha();
    else
        OP.ToggleTransformFields(true);
        pos = { x=0, y=0, z=0 };
        rot = { x=0, y=0, z=0 };
        scale = 1;
        alpha = 1;
    end

    OP.positionField:Set(OP.Truncate(pos.x, 3), OP.Truncate(pos.y, 3), OP.Truncate(pos.z, 3));
    OP.rotationField:Set(OP.Truncate(math.deg(rot.x), 3), OP.Truncate(math.deg(rot.y), 3), OP.Truncate(math.deg(rot.z), 3));
    OP.scaleField:Set(OP.Truncate(scale, 3));
    OP.alphaField:Set(OP.Truncate(alpha, 3));

    if (Renderer.projectionFrame) then
        --local r, g, b = Renderer.projectionFrame:GetLightAmbientColor();
        local amb = SM.loadedScene.properties.ambientColor;
        OP.ambientColorField:Set(amb[1], amb[2], amb[3], 1);
        --local r, g, b = Renderer.projectionFrame:GetLightDiffuseColor();
        local dif = SM.loadedScene.properties.diffuseColor;
        OP.diffuseColorField:Set(dif[1], dif[2], dif[3], 1);
        local bg = SM.loadedScene.properties.backgroundColor;
        OP.backgroundColorField:Set(bg[1], bg[2], bg[3], 1);
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

    for i = 1, #SM.selectedObjects, 1 do
        local pos = SM.selectedObjects[i]:GetPosition();
        SM.selectedObjects[i]:SetPosition(value, pos.y, pos.z);
    end
end

function OP.SetPosY(value)
    if (not value) then
        return;
    end
    if (#SM.selectedObjects == 0) then
        return;
    end

    for i = 1, #SM.selectedObjects, 1 do
        local pos = SM.selectedObjects[i]:GetPosition();
        SM.selectedObjects[i]:SetPosition(pos.x, value, pos.z);
    end
end

function OP.SetPosZ(value)
    if (not value) then
        return;
    end
    if (#SM.selectedObjects == 0) then
        return;
    end

    for i = 1, #SM.selectedObjects, 1 do
        local pos = SM.selectedObjects[i]:GetPosition();
        SM.selectedObjects[i]:SetPosition(pos.x, pos.y, value);
    end
end

function OP.SetRotX(value)
    if (not value) then
        return;
    end
    if (#SM.selectedObjects == 0) then
        return;
    end

    for i = 1, #SM.selectedObjects, 1 do
        local rot = SM.selectedObjects[i]:GetRotation();
        SM.selectedObjects[i]:SetRotation(rad(value), rot.y, rot.z);
    end
end

function OP.SetRotY(value)
    if (not value) then
        return;
    end
    if (#SM.selectedObjects == 0) then
        return;
    end

    for i = 1, #SM.selectedObjects, 1 do
        local rot = SM.selectedObjects[i]:GetRotation();
        SM.selectedObjects[i]:SetRotation(rot.x, rad(value), rot.z);
    end
end

function OP.SetRotZ(value)
    if (not value) then
        return;
    end
    if (#SM.selectedObjects == 0) then
        return;
    end

    for i = 1, #SM.selectedObjects, 1 do
        local rot = SM.selectedObjects[i]:GetRotation();
        SM.selectedObjects[i]:SetRotation(rot.x, rot.y, rad(value));
    end
end

function OP.SetScale(value)
    if (not value) then
        return;
    end
    if (#SM.selectedObjects == 0) then
        return;
    end

    for i = 1, #SM.selectedObjects, 1 do
        SM.selectedObjects[i]:SetScale(value);
    end
end

function OP.SetAlpha(value)
    if (not value) then
        return;
    end
    if (#SM.selectedObjects == 0) then
        return;
    end

    for i = 1, #SM.selectedObjects, 1 do
        SM.selectedObjects[i]:SetAlpha(value);
    end
end

function OP.Truncate(num, digits)
    local mult = 10^(digits)
    return math.modf(num*mult)/mult
end

function OP.SetAmbientColor(R, G, B, A)
    Renderer.projectionFrame:SetLightAmbientColor(R, G, B);
    SM.loadedScene.properties.ambientColor = { R, G, B, A };
end

function OP.SetDiffuseColor(R, G, B, A)
    Renderer.projectionFrame:SetLightDiffuseColor(R, G, B);
    SM.loadedScene.properties.diffuseColor = { R, G, B, A };
end

function OP.SetBackgroundColor(R, G, B, A)
    Renderer.backgroundFrame.texture:SetColorTexture(R, G, B, 1);
    SM.loadedScene.properties.backgroundColor = { R, G, B, A };
end