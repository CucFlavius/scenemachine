local Editor = SceneMachine.Editor;
local PM = Editor.ProjectManager;
local SM = Editor.SceneManager;
local Renderer = SceneMachine.Renderer;
local Camera = SceneMachine.Camera;
local CameraController = SceneMachine.CameraController;
local SH = Editor.SceneHierarchy;
local OP = Editor.ObjectProperties;
local AM = Editor.AnimationManager;
local UI = SceneMachine.UI;
local Resources = SceneMachine.Resources;
local L = Editor.localization;
local Vector3 = SceneMachine.Vector3;
local Actions = SceneMachine.Actions;
local Gizmos = SceneMachine.Gizmos;
local CC = SceneMachine.CameraController;

local tabButtonHeight = 20;
local tabPool = {};

SM.SCENE_DATA_VERSION = 2;

SM.loadedSceneIndex = -1;
SM.loadedScene = nil;
SM.selectedObjects = {};
SM.objectIDMap = {};

SM.selectedPosition = nil;
SM.selectedRotation = nil;
SM.selectedScale = nil;
SM.selectedBounds = nil;
SM.selectedAlpha = nil;

function SM.Create(x, y, w, h, parent, startLevel)
    SM.startLevel = startLevel;
    SM.groupBG = UI.Rectangle:New(6, -6, w, h, Editor.verticalSeparatorL:GetFrame(), "TOPLEFT", "TOPLEFT",  0, 0, 0, 0);
    SM.groupBG:SetPoint("BOTTOMRIGHT", Editor.horizontalSeparator:GetFrame(), "BOTTOMRIGHT", 0, 6);
    SM.groupBG:SetFrameLevel(startLevel);
    SM.groupBG:SetClipsChildren(true);
    SceneMachine.Renderer.CreateRenderer(0, 0, w, h - tabButtonHeight, SM.groupBG:GetFrame(), startLevel + 1);
    
    SM.viewportButton = UI.Button:New(0, 0, 100, 20, SceneMachine.Renderer.projectionFrame, "TOPLEFT", "TOPLEFT", L["SM_EXIT_CAMERA"]);
    SM.viewportButton:SetFrameLevel(SceneMachine.Renderer.projectionFrame:GetFrameLevel() + 100);
    SM.viewportButton:SetScript("OnClick", function()
        SM.StopControllingCamera();
        Camera.fov = math.rad(70);
    end);
    SM.viewportButton:Hide();

    SM.tabGroup = UI.TabGroup:New(0, 0, 100, tabButtonHeight, SM.groupBG:GetFrame(), "TOPLEFT", "TOPLEFT", startLevel + 2, true);
    SM.tabGroup:SetPoint("TOPRIGHT", SM.groupBG:GetFrame(), "TOPRIGHT", 0, 0);
    SM.tabGroup.dropdownButton.tooltip = L["SM_TT_LIST"];
    SM.tabGroup.addButton.tooltip = L["SM_TT_ADDSCENE"];

	SM.tabGroup:SetItemTemplate(
    {
        height = tabButtonHeight,
        lmbAction = function(index)
            SM.LoadScene(index);
            SM.RefreshSceneTabs();
        end,
        rmbAction = function(index, item)
            -- open rmb menu with option to delete, edit, rename the scene
            local point, relativeTo, relativePoint, xOfs, yOfs = item:GetPoint(1);
            local rx = xOfs + (SM.tabGroup:GetLeft() - SceneMachine.mainWindow:GetLeft());
            local ry = (SM.tabGroup:GetTop() - SceneMachine.mainWindow:GetTop()) - item:GetHeight();

            local menuOptions = {
                [1] = { ["Name"] = L["RENAME"], ["Action"] = function() SM.tabGroup:RenameTab(index, item, SM.RenameScene); end },
                [2] = { ["Name"] = L["EXPORT"], ["Action"] = function() SM.Button_ExportScene(index); end },
                [3] = { ["Name"] = L["IMPORT"], ["Action"] = function() SM.Button_ImportScene(); end },
                [4] = { ["Name"] = L["DELETE"], ["Action"] = function() SM.Button_DeleteScene(index); end },
            };

            local scale =  SceneMachine.mainWindow:GetEffectiveScale();
            SceneMachine.mainWindow:PopupWindowMenu(rx * scale, ry * scale, menuOptions);
        end,
        addAction = function(text) SM.AddScene(text) end,
        refreshItem = function(data, item, index)
            -- scene name text --
            item.components[2]:SetWidth(1000);
            item.components[2]:SetText(data.name);
            local strW = item.components[2].frame.text:GetStringWidth() + 20;
            item:SetWidth(strW);
            item.components[1]:SetWidth(strW);
            item.components[2]:SetWidth(strW);
            return strW;
        end,
        defaultTabName = "Scene",
    });

    SM.RefreshSceneTabs();
end

function SM.RefreshSceneTabs()
    if (PM.currentProject ~= nil) then
        SM.tabGroup:SetData(PM.currentProject.scenes);
    end
end

function SM.CreateDefaultScene()
    SM.AddScene("My First Scene");
end

function SM.AddScene(text)
    local index = #PM.currentProject.scenes + 1;
    PM.currentProject.scenes[index] = SM.CreateScene(text);
    SM.LoadScene(index);

    -- load default cube. No! sphere
    --SM.CreateObject(167145, "Default Cube", 0, 0, 0);
    local sphere = SM.CreateObject(3088290, "Default Sphere", 0, 0, 0);
    sphere:SetScale(0.05);

    SM.RefreshSceneTabs();
end

function SM.RenameSelectedScene(text)
    SM.RenameScene(text, SM.loadedSceneIndex);
end

function SM.RenameScene(text, index)
    if (text ~= nil and text ~= "") then
        -- rename existing scene
        PM.currentProject.scenes[index].name = text;
        SM.RefreshSceneTabs();
    end
end

function SM.GetSceneName()
    if (SM.loadedScene) then
        return SM.loadedScene.name;
    end

    return "";
end

function SM.Button_DeleteScene(index)
    Editor.OpenMessageBox(SceneMachine.mainWindow:GetFrame(), L["SM_MSG_DELETE_SCENE_TITLE"], L["SM_MSG_DELETE_SCENE_MESSAGE"], true, true, function() SM.DeleteScene(index); end, function() end);
end

function SM.Button_ExportScene(index)
    local scene = PM.currentProject.scenes[index];

    if (SM.loadedScene ~= scene) then
        SM.LoadScene(index);
    end

    local sceneString = SM.ExportSceneForPrint(scene);

    Editor.ShowImportExportWindow(nil, sceneString);
end

function SM.Button_ImportScene()
    Editor.ShowImportExportWindow(SM.ImportSceneFromPrint, "");
end

function SM.CreateScene(sceneName)
    if (sceneName == nil) then
        sceneName = "Scene " .. #PM.currentProject.scenes;
    end

    return {
        name = sceneName,
        objects = {},
        timelines = {},
        properties = {
            ambientColor = { 181/255, 194/255, 203/255, 1 },
            diffuseColor = { 217/255, 217/255, 190/255, 1 },
            backgroundColor = { 0.554, 0.554, 0.554, 1 },
            enableLighting = true,
        },
        lastCameraPosition = {8.8, -8.8, 6.5},
        lastCameraEuler = {0, math.rad(27), math.rad(135)},
    }
end

function SM.LoadScene(index)
    if (index == SM.loadedSceneIndex) then
        return;
    end

    SM.loadedSceneIndex = index;
    SM.tabGroup.selectedIndex = index;

    -- unload current --
    SM.UnloadScene();

    -- load new --
    local scene = PM.currentProject.scenes[index];

    SM.loadedScene = scene;

    scene.actionPool = scene.actionPool or {};
    scene.startedAction = scene.startedAction or nil;
    scene.actionPointer = scene.actionPointer or 0;

    if (scene.objects == nil) then
        scene.objects = {};
    end

    if (scene.timelines == nil) then
        scene.timelines = {};
    end

    if (scene.objectHierarchy == nil) then
        SM.RebuildObjectHierarchyFromScene(scene);
    end

    if (scene.properties == nil) then
        local ar, ag, ab = Renderer.projectionFrame:GetLightAmbientColor();
        local dr, dg, db = Renderer.projectionFrame:GetLightDiffuseColor();
        local enableLighting = Renderer.projectionFrame:IsLightVisible();
        scene.properties = {
            ambientColor = { ar, ag, ab, 1 },
            diffuseColor = { dr, dg, db, 1 },
            backgroundColor = { 0.554, 0.554, 0.554, 1 },
            enableLighting = enableLighting,
        };
    end

    if (scene.properties.enableLighting == nil) then
        scene.properties.enableLighting = true;
    end

    -- verify scene objects integrity
    for i = #scene.objects, 1, -1 do
        if (not scene.objects[i]) then
            table.remove(scene.objects, i);
        end
    end

    -- verify hierarchy integrity
    SH.VerifyIntegrityRecursive(scene.objectHierarchy);

    for i = 1, #scene.objects, 1 do
        local type = scene.objects[i].type;

        -- Create actor
        local object;
        local id = 0;
        if (type == SceneMachine.GameObjects.Object.Type.Model) then
            object = SceneMachine.GameObjects.Model:New();
            object:ImportData(scene.objects[i]);
            id = object.fileID;
        elseif(type == SceneMachine.GameObjects.Object.Type.Creature) then
            object = SceneMachine.GameObjects.Creature:New();
            object:ImportData(scene.objects[i]);
            id = object.displayID;
        elseif(type == SceneMachine.GameObjects.Object.Type.Character) then
            object = SceneMachine.GameObjects.Character:New();
            object:ImportData(scene.objects[i]);
            id = -1;
        elseif(type == SceneMachine.GameObjects.Object.Type.Camera) then
            object = SceneMachine.GameObjects.Camera:New();
            object:ImportData(scene.objects[i]);
        elseif(type == SceneMachine.GameObjects.Object.Type.Group) then
            object = SceneMachine.GameObjects.Group:New();
            object:ImportData(scene.objects[i]);
        end

        if (object:HasActor()) then
            local actor = Renderer.AddActor(id, object.position.x, object.position.y, object.position.z, object.type);
            object:SetActor(actor);

            if (not object.visible) then
                actor:SetAlpha(0);
            end
        end

        -- assigning the new object so that we have access to the class functions (which get stripped when exporting to savedata)
        SM.loadedScene.objects[i] = object;
    end

    -- buld objectid map
    SM.objectIDMap = {};
    for i = 1, #scene.objects, 1 do
        SM.objectIDMap[scene.objects[i].id] = scene.objects[i];
    end

    if (#scene.timelines == 0) then
        SM.loadedScene.timelines[1] = AM.CreateDefaultTimeline();
    end

    if (#scene.timelines > 0) then
        for i in pairs(scene.timelines) do
            local timeline = scene.timelines[i];
            if (timeline.tracks) then
                if (#timeline.tracks > 0) then
                    for j in pairs(timeline.tracks) do
                        local track = SceneMachine.Track:New();
                        track:ImportData(timeline.tracks[j]);
            
                        -- assigning the new track so that we have access to the class functions (which get stripped when exporting to savedata)
                        SM.loadedScene.timelines[i].tracks[j] = track;
                    end
                end
            end
        end
    end

    if (scene.properties) then
        OP.SetAmbientColor(scene.properties.ambientColor[1], scene.properties.ambientColor[2], scene.properties.ambientColor[3], 1);
        OP.SetDiffuseColor(scene.properties.diffuseColor[1], scene.properties.diffuseColor[2], scene.properties.diffuseColor[3], 1);
        OP.SetBackgroundColor(scene.properties.backgroundColor[1], scene.properties.backgroundColor[2], scene.properties.backgroundColor[3], 1);
        OP.ToggleLighting(scene.properties.enableLighting);
    end

    AM.RefreshTimelineTabs();

    -- load the first timeline
    AM.LoadTimeline(1);

    -- remember this scene was opened last
    PM.currentProject.lastOpenScene = index;

    -- set the camera position and rotation to the last
    if (scene.lastCameraPosition ~= nil) then
        CameraController.position:Set(scene.lastCameraPosition[1], scene.lastCameraPosition[2], scene.lastCameraPosition[3]);
    end
    if (scene.lastCameraEuler ~= nil) then
        scene.lastCameraEuler[1] = 0;
        Camera.eulerRotation:Set(scene.lastCameraEuler[1], scene.lastCameraEuler[2], scene.lastCameraEuler[3]);
    end
    CameraController.Direction = math.deg(Camera.eulerRotation.z);

    for i = 1, #SM.loadedScene.objects, 1 do
        SM.loadedScene.objects[i]:RecalculateWorldMatrices();
        SM.loadedScene.objects[i]:RecalculateActors();
    end


    -- refresh the scene tabs
    SM.RefreshSceneTabs();

    -- refresh
    SH.RefreshHierarchy();
    OP.Refresh();
    SM.ApplySelectionEffects();
    Editor.RefreshActionToolbar();

    SM.selectedObjects = {};
end

function SM.RebuildObjectHierarchyFromScene(scene)
    scene.objectHierarchy = {};
    for i = 1, #scene.objects, 1 do
        table.insert(scene.objectHierarchy, { id = scene.objects[i].id, childObjects = {} });
    end
end

function SM.GetObjectByID(id)
    if (SM.objectIDMap[id]) then
        return SM.objectIDMap[id];
    end

    for i = 1, #SM.loadedScene.objects, 1 do
        if (SM.loadedScene.objects[i].id == id) then
            SM.objectIDMap[SM.loadedScene.objects[i].id] = SM.loadedScene.objects[i];
            return SM.objectIDMap[id];
        end
    end

    return nil;
end

function SM.UnloadScene()
    if (SM.loadedScene == nil) then
        return;
    end
    
    for i = 1, #SM.loadedScene.objects, 1 do
        SM.loadedScene.objects[i]:Deselect();
    end
    
    SM.selectedObjects = {};
    Renderer.Clear();
    SM.StopControllingCamera();
    SM.loadedScene = nil;
    SM.loadedSceneIndex = -1;
end

function SM.StopControllingCamera()
    SM.viewportButton:Hide();
    CC.ControllingCameraObject = nil;
end

function SM.ClearSceneActions(scene)
    if (not scene) then
        return;
    end
    scene.actionPool = scene.actionPool or {};
    scene.startedAction = scene.startedAction or nil;
    scene.actionPointer = scene.actionPointer or 0;
end

function SM.DeleteScene(index)
    -- switch to a different scene because the currently loaded is being deleted
    -- load first that isn't this one
    if (SM.loadedScene == PM.currentProject.scenes[index]) then
        SM.UnloadScene();
        SH.RefreshHierarchy();
    end

    for i in pairs(PM.currentProject.scenes) do
        local scene = PM.currentProject.scenes[i];
        if (i ~= index) then
            SM.LoadScene(i);
            break;
        end
    end

    -- delete it
    table.remove(PM.currentProject.scenes, index);

    -- if this was the only scene then create a new default one
    if (#PM.currentProject.scenes == 0) then
        SM.CreateDefaultScene();
    end

    -- refresh ui
    SM.RefreshSceneTabs();
end

function SM.CreateObject(_fileID, _name, _x, _y, _z)
    local object = SceneMachine.GameObjects.Model:New(_name, _fileID, Vector3:New(_x, _y, _z));

    local scene = SM.loadedScene;
    scene.objects[#scene.objects + 1] = object;

    -- Create actor
    if (object.fileID ~= nil) then
        local actor = Renderer.AddActor(object.fileID, object.position.x, object.position.y, object.position.z, SceneMachine.GameObjects.Object.Type.Model);
        object:SetActor(actor);
    end

    -- Refresh
    SH.AddNewObject(object.id);
    SH.RefreshHierarchy();
    OP.Refresh();

    return object;
end

function SM.CreateCreature(_displayID, _name, _x, _y, _z)
    local object = SceneMachine.GameObjects.Creature:New(_name, _displayID, Vector3:New(_x, _y, _z));

    local scene = SM.loadedScene;
    scene.objects[#scene.objects + 1] = object;

    -- Create actor
    if (object.fileID ~= nil) then
        local actor = Renderer.AddActor(object.displayID, object.position.x, object.position.y, object.position.z, SceneMachine.GameObjects.Object.Type.Creature);
        object:SetActor(actor);
    end

    -- Refresh
    SH.AddNewObject(object.id);
    SH.RefreshHierarchy();
    OP.Refresh();

    return object;
end

function SM.CreateCharacter(_x, _y, _z)
    local object = SceneMachine.GameObjects.Character:New(UnitName("player"), Vector3:New(_x, _y, _z));

    local scene = SM.loadedScene;
    scene.objects[#scene.objects + 1] = object;

    -- Create actor
    if (object.fileID ~= nil) then
        local actor = Renderer.AddActor(-1, object.position.x, object.position.y, object.position.z, SceneMachine.GameObjects.Object.Type.Character);
        object:SetActor(actor);
    end

    -- Refresh
    SH.AddNewObject(object.id);
    SH.RefreshHierarchy();
    OP.Refresh();

    return object;
end

function SM.CreateCamera()
    local name = "New Camera";
    local position = Vector3:New();
    local rotation = Vector3:New();
    local fov = math.rad(60);
    local nearClip = 0.01;
    local farClip = 1000;

    -- get info from current viewport camera settings
    fov = Camera.fov;
    nearClip = Camera.nearClip;
    farClip = Camera.farClip;
    position:SetVector3(Camera.position);
    rotation:SetVector3(Camera.eulerRotation);

    local object = SceneMachine.GameObjects.Camera:New(name, position, rotation, fov, nearClip, farClip);
    
    local scene = SM.loadedScene;
    scene.objects[#scene.objects + 1] = object;

    SM.SelectObject(object);

    -- Refresh
    SH.AddNewObject(object.id);
    SH.RefreshHierarchy();
    OP.Refresh();

    return object;
end

function SM.IsObjectSelected(object)
    if (not object) then
        return false;
    end

    for i = 1, #SM.selectedObjects, 1 do
        if (SM.selectedObjects[i] == object) then
            return true;
        end
    end

    return false;
end

function SM.SelectObjects(objects)
    if (not SceneMachine.Input.ControlModifier) then
        SM.selectedObjects = {};
    end

    for i = 1, #objects, 1 do
        if (SceneMachine.Input.ControlModifier) then
            if (not SM.IsObjectSelected(objects[i])) then
                SM.selectedObjects[#SM.selectedObjects + 1] = objects[i];
            end
        else
            SM.selectedObjects[#SM.selectedObjects + 1] = objects[i];
        end
    end

    SM.StopControllingCamera();
    SH.RefreshHierarchy();
	OP.Refresh();

    if (#SM.selectedObjects == 1) then
        -- also select track if available
        -- only select a track if a one single object is selected, no multi-track selection support needed
        AM.SelectTrackOfObject(SM.selectedObjects[1]);
		Editor.lastSelectedType = "obj";
	end
end

function SM.SelectObjectByIndex(index)
    if (index <= 0) then
        SM.SelectObject(nil);
        return;
    end
    SM.SelectObject(SM.loadedScene.objects[index]);
end

function SM.SelectObject(object)
	if (not object) then
        for i = 1, #SM.selectedObjects, 1 do
            SM.selectedObjects[i]:Deselect();
        end
		SM.selectedObjects = {};
	else
		if (SceneMachine.Input.ControlModifier) then
            -- first check if object isn't already selected
            if (SM.IsObjectSelected(object)) then
                return;
            end
			SM.selectedObjects[#SM.selectedObjects + 1] = object;
		else
			SM.selectedObjects = { object };
		end
        SM.StopControllingCamera();
	end

    SH.RefreshHierarchy();
	OP.Refresh();

    -- also select track if available
	-- only select a track if a one single object is selected, no multi-track selection support needed
    if (#SM.selectedObjects == 1) then
        AM.SelectTrackOfObject(SM.selectedObjects[1]);
		Editor.lastSelectedType = "obj";
	end
end

function SM.CalculateObjectsAverage()

    if (#SM.selectedObjects == 0) then
        SM.selectedPosition = Vector3.zero;
        SM.selectedRotation = Vector3.zero;
        SM.selectedScale = 1.0;
        SM.selectedWorldPosition = Vector3.zero;
        SM.selectedWorldRotation = Vector3.zero;
        SM.selectedWorldScale = 1.0;
        SM.selectedAlpha = 1.0;
        SM.selectedBounds = nil;
    elseif (#SM.selectedObjects == 1) then
        SM.selectedPosition = SM.selectedObjects[1]:GetPosition();
        SM.selectedRotation = SM.selectedObjects[1]:GetRotation();
        SM.selectedScale = SM.selectedObjects[1]:GetScale();
        SM.selectedAlpha = 1.0;

        SM.selectedWorldPosition = SM.selectedObjects[1]:GetWorldPosition();
        SM.selectedWorldRotation = SM.selectedObjects[1]:GetWorldRotation();
        SM.selectedWorldScale = SM.selectedObjects[1]:GetWorldScale();

        if (SM.selectedObjects[1]:HasActor() or SM.selectedObjects[1]:GetType() == SceneMachine.GameObjects.Object.Type.Group) then
            local xMin, yMin, zMin, xMax, yMax, zMax = SM.selectedObjects[1]:GetActiveBoundingBox();
            SM.selectedBounds = { xMin, yMin, zMin, xMax, yMax, zMax };
        else
            SM.selectedBounds = { 0, 0, 0, 0, 0, 0 };
        end
    else
        -- Position (Calculate center position)
        --local x, y, z = 0, 0, 0;
        --for i = 1, #SM.selectedObjects, 1 do
        --    local pos = SM.selectedObjects[i]:GetPosition();
        --    x = x + pos.x;
        --    y = y + pos.y;
        --    z = z + pos.z;
        --end

        --SM.selectedPosition = Vector3:New(x / #SM.selectedObjects, y / #SM.selectedObjects, z / #SM.selectedObjects);

        -- Rotation (set to 0?)
        SM.selectedRotation = Vector3:New(0, 0, 0);
        SM.selectedWorldRotation = Vector3:New(0, 0, 0);

        -- Scale (set to 1?)
        SM.selectedScale = 1.0;
        SM.selectedWorldScale = 1.0;

        -- Alpha (set to 1?)
        SM.selectedAlpha = 1.0;

        -- Calculate encapsulating bounds
        local xMin, yMin, zMin, xMax, yMax, zMax = 100000, 100000, 100000, -100000, -100000, -100000;

        -- Iterate through the rest of the objects in the array
        for i = 1, #SM.selectedObjects do
            local xmin, ymin, zmin, xmax, ymax, zmax = 0, 0, 0, 0, 0, 0;
            if (SM.selectedObjects[i]:GetGizmoType() == Gizmos.Type.Object) then
                xmin, ymin, zmin, xmax, ymax, zmax = SM.selectedObjects[i]:GetActiveBoundingBox();
                xmin = xmin or 0; ymin = ymin or 0; zmin = zmin or 0;
                xmax = xmax or 0; ymax = ymax or 0; zmax = zmax or 0;
                local bbCenter = {(xmax - xmin) / 2, (ymax - ymin) / 2, (zmax - zmin) / 2};
                xmin = -bbCenter[1];
                ymin = -bbCenter[2];
                zmin = -bbCenter[3];
                xmax = bbCenter[1];
                ymax = bbCenter[2];
                zmax = bbCenter[3];
            elseif (SM.selectedObjects[i]:GetGizmoType() == Gizmos.Type.Camera) then
                xmin = 0;
                ymin = 0;
                zmin = 0;
                xmax = 0;
                ymax = 0;
                zmax = 0;
            end

            local Pos = SM.selectedObjects[i]:GetWorldPosition();
            local Rot = SM.selectedObjects[i]:GetWorldRotation();
            local Scale = SM.selectedObjects[i]:GetWorldScale();

            local corners = {
                Vector3:New(xmin, ymin, zmin),
                Vector3:New(xmin, ymin, zmax),
                Vector3:New(xmin, ymax, zmin),
                Vector3:New(xmin, ymax, zmax),
                Vector3:New(xmax, ymin, zmin),
                Vector3:New(xmax, ymin, zmax),
                Vector3:New(xmax, ymax, zmin),
                Vector3:New(xmax, ymax, zmax)
            }

            for _, corner in ipairs(corners) do
                corner:RotateAroundPivot(Vector3.zero, Rot);
                -- Update minimum bounds
                xMin = math.min(xMin, corner.x * Scale + Pos.x);
                yMin = math.min(yMin, corner.y * Scale + Pos.y);
                zMin = math.min(zMin, corner.z * Scale + Pos.z);
                
                -- Update maximum bounds
                xMax = math.max(xMax, corner.x * Scale + Pos.x);
                yMax = math.max(yMax, corner.y * Scale + Pos.y);
                zMax = math.max(zMax, corner.z * Scale + Pos.z);
            end
        end

        SM.selectedBounds = { xMin, yMin, zMin, xMax, yMax, zMax };
        SM.selectedPosition = Vector3:New(xMin + (xMax - xMin) / 2, yMin + (yMax - yMin) / 2, zMin + (zMax - zMin) / 2);
        SM.selectedWorldPosition = Vector3:New(xMin + (xMax - xMin) / 2, yMin + (yMax - yMin) / 2, zMin + (zMax - zMin) / 2);
    end

end

function SM.ApplySelectionEffects()

    -- TODO: Don't loop all, try comparing which objects changed selection
    if (not SM.loadedScene) then
        return;
    end

    for i = 1, #SM.loadedScene.objects, 1 do
        if (SM.loadedScene.objects[i]) then
            SM.loadedScene.objects[i]:Deselect();
        end
    end

    for i = 1, #SM.selectedObjects, 1 do
        if (SM.loadedScene.objects[i]) then
            SM.selectedObjects[i]:Select();
        end
    end
end

function SM.CloneObjects(objects, selectAfter)
    if (not objects) then
        return;
    end

    local clones = {};
    for i = 1, #objects, 1 do
        if (objects[i]) then
            clones[i] = SM.CloneObject_internal(objects[i]);
        end
    end
    local objectHierarchyBefore = SH.CopyObjectHierarchy(SM.loadedScene.objectHierarchy);
    Editor.StartAction(Actions.Action.Type.CreateObject, clones, objectHierarchyBefore);

    local objectHierarchyAfter = SH.CopyObjectHierarchy(SM.loadedScene.objectHierarchy);
    Editor.FinishAction(objectHierarchyAfter);

    if (selectAfter) then
        SM.selectedObjects = clones;
    end

    SH.RefreshHierarchy();
    OP.Refresh();
end

function SM.CloneObject_internal(object, selectAfter)
    if (object == nil) then
        return;
    end

    local pos = object:GetPosition();
    local rot = object:GetRotation();
    local scale = object:GetScale();

    --------------------------------

    local clone = nil;
    if (object:GetType() == SceneMachine.GameObjects.Object.Type.Model) then
        clone = SM.CreateObject(object:GetFileID(), object:GetName(), pos.x, pos.y, pos.z);
        clone:SetAlpha(object:GetAlpha());
        clone:SetDesaturation(object:GetDesaturation());
    elseif(object:GetType() == SceneMachine.GameObjects.Object.Type.Creature) then
        clone = SM.CreateCreature(object:GetDisplayID(), object:GetName(), pos.x, pos.y, pos.z);
        clone:SetAlpha(object:GetAlpha());
        clone:SetDesaturation(object:GetDesaturation());
    elseif(object:GetType() == SceneMachine.GameObjects.Object.Type.Character) then
        clone = SM.CreateCharacter(pos.x, pos.y, pos.z);
        clone:SetAlpha(object:GetAlpha());
        clone:SetDesaturation(object:GetDesaturation());
    end
    if (clone) then
        local hobject = SH.GetHierarchyObject(SM.loadedScene.objectHierarchy, clone.id);
        
        local parentObj = SH.GetParentObject(object.id);
        if (parentObj) then
            SH.inputState.savedWorldPositions = {};
            SH.inputState.savedWorldRotations = {};
            SH.inputState.savedWorldScales = {};

            local wPosition = object:GetWorldPosition();
            SH.inputState.savedWorldPositions[hobject.id] = wPosition;
            local wRotation = object:GetWorldRotation();
            SH.inputState.savedWorldRotations[hobject.id] = wRotation;
            local wScale = object:GetWorldScale();
            SH.inputState.savedWorldScales[hobject.id] = wScale;
        
            SH.RemoveIDFromHierarchy(clone.id, SM.loadedScene.objectHierarchy);

            local intoId = parentObj.id;
            SH.InsertIDChildInHierarchy(hobject, intoId, SM.loadedScene.objectHierarchy);
        end

        clone:SetRotation(rot.x, rot.y, rot.z);
        clone:SetScale(scale);

        if (selectAfter) then
            SM.selectedObjects = { clone };
        end

        SH.RefreshHierarchy();
        OP.Refresh();
    end

    return clone;
end

function SM.Clear()
    if (#SM.loadedScene.objects > 0) then
        for i in pairs(SM.loadedScene.objects) do
            Renderer.RemoveActor(SM.loadedScene.objects[i] .actor);
        end
    end

    SM.loadedScene.objects = {};

    -- refresh hierarchy
    SH.RefreshHierarchy();
    OP.Refresh();
end

function SM.ObjectHasTrack(obj)
    if (not obj) then
        return false;
    end
    
    if (AM.loadedTimeline) then
		for i in pairs(AM.loadedTimeline.tracks) do
			if (AM.loadedTimeline.tracks[i].objectID == obj.id) then
				return true;
			end
		end
	end

    return false;
end

function SM.DeleteObjects(objects)
    if (not objects) then
        return;
    end

    -- make a copy of the objectHierarchy, so it can be restored without too much complication
    local objectHierarchyBefore = SH.CopyObjectHierarchy(SM.loadedScene.objectHierarchy);

    -- collect child objects
    local allObjects = {};
    for i = 1, #objects, 1 do
        table.insert(allObjects, objects[i]);
        local childObjects = SH.GetChildObjectsRecursive(objects[i].id);
        if (childObjects) then
            for j = 1, #childObjects, 1 do
                table.insert(allObjects, childObjects[j])
            end
        end
    end

    Editor.StartAction(Actions.Action.Type.DestroyObject, allObjects, objectHierarchyBefore);
    for i = 1, #allObjects, 1 do
        if (allObjects[i]) then
            SM.DeleteObject_internal(allObjects[i]);
        end
    end
    SH.RefreshHierarchy();
    local objectHierarchyAfter = SH.CopyObjectHierarchy(SM.loadedScene.objectHierarchy);
    Editor.FinishAction(objectHierarchyAfter);
end

function SM.DeleteObject_internal(object)
    if (object == nil) then
        return;
    end

    SM.selectedObjects = {};

    if (#SM.loadedScene.objects > 0) then
        for i in pairs(SM.loadedScene.objects) do
            if (SM.loadedScene.objects[i] == object) then
                table.remove(SM.loadedScene.objects, i);
            end
        end
    end

    Renderer.RemoveActor(object.actor);

    -- also delete track if it exists
    if (AM.loadedTimeline) then
		for i in pairs(AM.loadedTimeline.tracks) do
			if (AM.loadedTimeline.tracks[i].objectID == object.id) then
				AM.RemoveTrack_internal(AM.loadedTimeline.tracks[i], AM.loadedTimeline);
			end
		end
	end

    -- refresh hierarchy
    SH.RemoveIDFromHierarchy(object.id, SM.loadedScene.objectHierarchy);
    SH.RefreshHierarchy();
    OP.Refresh();
end

function SM.UndeleteObject_internal(object)
    if (object == nil) then
        return;
    end

    SM.loadedScene.objects[#SM.loadedScene.objects + 1] = object;

    local pos = object:GetPosition();
    local actor;
    if (object.type == SceneMachine.GameObjects.Object.Type.Model) then
        actor = Renderer.AddActor(object.fileID, pos.x, pos.y, pos.z, object.type);
    elseif (object.type == SceneMachine.GameObjects.Object.Type.Creature) then
        actor = Renderer.AddActor(object.displayID, pos.x, pos.y, pos.z, object.type);
    elseif (object.type == SceneMachine.GameObjects.Object.Type.Character) then
        actor = Renderer.AddActor(-1, pos.x, pos.y, pos.z, object.type);
    elseif (object.type == SceneMachine.GameObjects.Object.Type.Group) then
        actor = nil;
    else
        print("SM.UndeleteObject_internal(object) Unsupported obj.type : " .. object.type);
        return;
    end
    if (object:HasActor()) then
        object:SetActor(actor);
        object:RecalculateActors();
    end
    -- todo: restore timeline track
    --[[
    if (AM.loadedTimeline) then
		for i in pairs(AM.loadedTimeline.tracks) do
			if (AM.loadedTimeline.tracks[i].objectID == object.id) then
				AM.RemoveTrack(AM.loadedTimeline.tracks[i]);
			end
		end
	end
    --]]

    SH.RefreshHierarchy();
    OP.Refresh();
end

function SM.ToggleObjectsVisibility(objects)
    if (not objects) then
        return;
    end

    for i = 1, #objects, 1 do
        if (objects[i]) then
            objects[i]:ToggleVisibility();
        end
    end

    SH.RefreshHierarchy();
end

function SM.ToggleObjectVisibility(object)
    if (object == nil) then
        return;
    end

    object:ToggleVisibility();
    SH.RefreshHierarchy();
end

function SM.ToggleObjectsFreezeState(objects)
    if (not objects) then
        return;
    end

    for i = 1, #objects, 1 do
        if (objects[i]) then
            objects[i]:ToggleFrozen();
        end
    end

    SH.RefreshHierarchy();
end

function SM.ToggleObjectFreezeState(object)
    if (object == nil) then
        return;
    end

    object:ToggleFrozen();
    SH.RefreshHierarchy();
end

function SM.ExportScene(scene)
    local sceneData = {};
    sceneData.objects = {};
    sceneData.hierarchy = {};
    sceneData.timelines = {};
    sceneData.properties = {};
    
    sceneData.version = SM.SCENE_DATA_VERSION;
    sceneData.name = scene.name;

    -- transfer objects --
    if (#scene.objects > 0) then
        for i = 1, #scene.objects, 1 do
            sceneData.objects[i] = scene.objects[i]:ExportPacked(scene.objects[i]);
        end
    end

    -- transfer hierarchy --
    sceneData.hierarchy = SH.CopyObjectHierarchy(scene.objectHierarchy);

    -- transfer timelines --
    if (#scene.timelines > 0) then
        for i = 1, #scene.timelines, 1 do
            local timelineData = {};
            local timeline = scene.timelines[i];
            timelineData.currentTime = timeline.currentTime;
            timelineData.duration = timeline.duration;
            timelineData.name = timeline.name;
            timelineData.tracks = {};

            for t = 1, #timeline.tracks, 1 do
                timelineData.tracks[t] = timeline.tracks[t]:Export();
            end

            sceneData.timelines[i] = timelineData;
        end
    end

    -- scene properties
    sceneData.properties = scene.properties;

    -- the camera position and rotation
    sceneData.lastCameraPosition = scene.lastCameraPosition;
    sceneData.lastCameraEuler = scene.lastCameraEuler;

    return sceneData;
end

function SM.ExportSceneForPrint(scene)
    local sceneData = SM.ExportScene(scene);
    local serialized = SceneMachine.Libs.LibSerialize:Serialize(sceneData);
    local compressed = SceneMachine.Libs.LibDeflate:CompressDeflate(serialized);
    local chatEncoded = SceneMachine.Libs.LibDeflate:EncodeForPrint(compressed);
    --print("scene objects: " .. #scene.objects);
    --print("serialized: " .. string.len(serialized));
    --print("compressed: " .. string.len(compressed));
    --print("chat encoded: " .. string.len(chatEncoded));
    return chatEncoded;
end

function SM.ExportSceneForMessage(scene)
    local sceneData = SM.ExportScene(scene);
    local serialized = SceneMachine.Libs.LibSerialize:Serialize(sceneData);
    local compressed = SceneMachine.Libs.LibDeflate:CompressDeflate(serialized);
    local addonChannelEncoded = SceneMachine.Libs.LibDeflate:EncodeForWoWAddonChannel(compressed);
    --print("scene objects: " .. #scene.objects);
    --print("serialized: " .. string.len(serialized));
    --print("compressed: " .. string.len(compressed));
    --print("addon channel encoded: " .. string.len(addonChannelEncoded));
    return addonChannelEncoded;
end

function SM.ImportSceneFromPrint(chatEncoded)
    local decoded = SceneMachine.Libs.LibDeflate:DecodeForPrint(chatEncoded);
    if (not decoded) then print(L["DECODE_FAILED"]); return end
    local decompressed = SceneMachine.Libs.LibDeflate:DecompressDeflate(decoded);
    if (not decompressed) then print(L["DECOMPRESS_FAILED"]); return end
    local success, sceneData = SceneMachine.Libs.LibSerialize:Deserialize(decompressed);
    if (not success) then print(L["DESERIALIZE_FAILED"]); return end

    if(sceneData.version > SM.SCENE_DATA_VERSION) then
        -- handle newer version
        print(L["DATA_VERSION_TOO_NEW"]);
    else
        -- handle known versions
        if (sceneData.version == 1) then
            SM.ImportVersion1Scene(sceneData);
        elseif (sceneData.version == 2) then
            SM.ImportVersion2Scene(sceneData);
        end
    end
end

function SM.ImportVersion1Scene(sceneData)
    local scene = SM.CreateScene(sceneData.name);

    if (#sceneData.objects > 0) then
        for i = 1, #sceneData.objects, 1 do
            local type = sceneData.objects[i][3];
            local object;
            if (type == SceneMachine.GameObjects.Object.Type.Model) then
                object = SceneMachine.GameObjects.Model:New();
            elseif(type == SceneMachine.GameObjects.Object.Type.Creature) then
                object = SceneMachine.GameObjects.Creature:New();
            elseif(type == SceneMachine.GameObjects.Object.Type.Character) then
                object = SceneMachine.GameObjects.Character:New();
            end

            if (object) then
                object:ImportPackedV1(sceneData.objects[i]);
                scene.objects[i] = object;
            end
        end
    end

    if (#sceneData.timelines > 0) then
        for i = 1, #sceneData.timelines, 1 do
            local timelineData = sceneData.timelines[i];
            local timeline = {};
            timeline.tracks = {};
            if (timelineData.tracks) then
                if (#timelineData.tracks > 0) then
                    for j = 1, #timelineData.tracks, 1 do
                        local track = SceneMachine.Track:New();
                        track:ImportData(timelineData.tracks[j]);
                        timeline.tracks[j] = track;
                    end
                end
            end
            timeline.name = timelineData.name;
            timeline.duration = timelineData.duration;
            timeline.currentTime = timelineData.currentTime;
            scene.timelines[i] = timeline;
        end
    end

    -- scene properties
    scene.properties = sceneData.properties;

    -- the camera position and rotation
    scene.lastCameraPosition = sceneData.lastCameraPosition;
    scene.lastCameraEuler = sceneData.lastCameraEuler;

    PM.currentProject.scenes[#PM.currentProject.scenes + 1] = scene;
    SM.LoadScene(#PM.currentProject.scenes);
end

function SM.ImportVersion2Scene(sceneData)
    local scene = SM.CreateScene(sceneData.name);

    if (#sceneData.objects > 0) then
        for i = 1, #sceneData.objects, 1 do
            local type = sceneData.objects[i][1];
            local object;
            if (type == SceneMachine.GameObjects.Object.Type.Model) then
                object = SceneMachine.GameObjects.Model:New();
            elseif(type == SceneMachine.GameObjects.Object.Type.Creature) then
                object = SceneMachine.GameObjects.Creature:New();
            elseif(type == SceneMachine.GameObjects.Object.Type.Character) then
                object = SceneMachine.GameObjects.Character:New();
            elseif(type == SceneMachine.GameObjects.Object.Type.Camera) then
                object = SceneMachine.GameObjects.Camera:New();
            elseif(type == SceneMachine.GameObjects.Object.Type.Group) then
                object = SceneMachine.GameObjects.Group:New();
            end

            if (object) then
                object:ImportPacked(sceneData.objects[i]);
                scene.objects[i] = object;
            end
        end
    end

    if (sceneData.hierarchy) then
        scene.objectHierarchy = sceneData.hierarchy;
    end

    if (#sceneData.timelines > 0) then
        for i = 1, #sceneData.timelines, 1 do
            local timelineData = sceneData.timelines[i];
            local timeline = {};
            timeline.tracks = {};
            if (timelineData.tracks) then
                if (#timelineData.tracks > 0) then
                    for j = 1, #timelineData.tracks, 1 do
                        local track = SceneMachine.Track:New();
                        track:ImportData(timelineData.tracks[j]);
                        timeline.tracks[j] = track;
                    end
                end
            end
            timeline.name = timelineData.name;
            timeline.duration = timelineData.duration;
            timeline.currentTime = timelineData.currentTime;
            scene.timelines[i] = timeline;
        end
    end

    -- scene properties
    scene.properties = sceneData.properties;

    -- the camera position and rotation
    scene.lastCameraPosition = sceneData.lastCameraPosition;
    scene.lastCameraEuler = sceneData.lastCameraEuler;

    PM.currentProject.scenes[#PM.currentProject.scenes + 1] = scene;
    SM.LoadScene(#PM.currentProject.scenes);
end

function SM.ImportNetworkScene(sceneData)
    local scene = SM.CreateScene(sceneData.name);

    if (#sceneData.objects > 0) then
        for i = 1, #sceneData.objects, 1 do
            local type = sceneData.objects[i][3];
            local object;
            if (type == SceneMachine.GameObjects.Object.Type.Model) then
                object = SceneMachine.GameObjects.Model:New();
            elseif(type == SceneMachine.GameObjects.Object.Type.Creature) then
                object = SceneMachine.GameObjects.Creature:New();
            elseif(type == SceneMachine.GameObjects.Object.Type.Character) then
                object = SceneMachine.GameObjects.Character:New();
            end

            if (object) then
                object:ImportPacked(sceneData.objects[i]);
                scene.objects[i] = object;
            end
        end
    end

    if (#sceneData.timelines > 0) then
        for i = 1, #sceneData.timelines, 1 do
            local timelineData = sceneData.timelines[i];
            local timeline = {};
            timeline.tracks = {};
            if (timelineData.tracks) then
                if (#timelineData.tracks > 0) then
                    for j = 1, #timelineData.tracks, 1 do
                        local track = SceneMachine.Track:New();
                        track:ImportData(timelineData.tracks[j]);
                        timeline.tracks[j] = track;
                    end
                end
            end
            timeline.name = timelineData.name;
            timeline.duration = timelineData.duration;
            timeline.currentTime = timelineData.currentTime;
            scene.timelines[i] = timeline;
        end
    end

    -- scene properties
    scene.properties = sceneData.properties;

    -- the camera position and rotation
    scene.lastCameraPosition = sceneData.lastCameraPosition;
    scene.lastCameraEuler = sceneData.lastCameraEuler

    return scene;
end

function SM.LoadNetworkScene(scene)
    --PM.currentProject.scenes[#PM.currentProject.scenes + 1] = scene;
    --SM.LoadScene(#PM.currentProject.scenes);

    SM.loadedSceneIndex = -1;

    Editor.SetMode(Editor.MODE_NETWORK);
    --if (#PM.currentProject.scenes == 0) then
    --    -- current project has no scenes, create a default one
    --    SM.CreateDefaultScene();
    --    SM.RefreshSceneTabs();
    --end

    -- unload current --
    SM.UnloadScene();

    -- load new --
    --local scene = PM.currentProject.scenes[index];
    SM.loadedScene = scene;

    if (scene.objects == nil) then
        scene.objects = {};
    end

    if (scene.timelines == nil) then
        scene.timelines = {};
    end

    if (scene.properties == nil) then
        local ar, ag, ab = Renderer.projectionFrame:GetLightAmbientColor();
        local dr, dg, db = Renderer.projectionFrame:GetLightDiffuseColor();
        local enableLighting = Renderer.projectionFrame:IsLightVisible() or true;
        scene.properties = {
            ambientColor = { ar, ag, ab, 1 },
            diffuseColor = { dr, dg, db, 1 },
            backgroundColor = { 0.554, 0.554, 0.554, 1 },
            enableLighting = enableLighting,
        };
    end

    -- create loaded scene (so that objects get loaded from data not referenced) --
    --SM.loadedScene.objects = {};
    --SM.loadedScene.name = scene.name;

    if (#scene.objects > 0) then
        for i in pairs(scene.objects) do
            local type = scene.objects[i][3];
            local object;
            if (type == SceneMachine.GameObjects.Object.Type.Model) then
                object = SceneMachine.GameObjects.Model:New();
            elseif(type == SceneMachine.GameObjects.Object.Type.Creature) then
                object = SceneMachine.GameObjects.Creature:New();
            elseif(type == SceneMachine.GameObjects.Object.Type.Character) then
                object = SceneMachine.GameObjects.Character:New();
            end

            if (object) then
                object:ImportPacked(scene.objects[i]);
                scene.objects[i] = object;
            end

            -- Create actor
            local id = 0;
            if (object.type == SceneMachine.GameObjects.Object.Type.Model) then
                id = object.fileID;
            elseif(object.type == SceneMachine.GameObjects.Object.Type.Creature) then
                id = object.displayID;
            elseif(object.type == SceneMachine.GameObjects.Object.Type.Character) then
                id = -1;
            end
            local actor = Renderer.AddActor(id, object.position.x, object.position.y, object.position.z, object.type);
            object:SetActor(actor);

            if (not object.visible) then
                actor:SetAlpha(0);
            end

            -- assigning the new object so that we have access to the class functions (which get stripped when exporting to savedata)
            SM.loadedScene.objects[i] = object;
        end
    end

    if (#scene.timelines == 0) then
        SM.loadedScene.timelines[1] = AM.CreateDefaultTimeline();
    end

    if (#scene.timelines > 0) then
        for i in pairs(scene.timelines) do
            local timeline = scene.timelines[i];
            if (timeline.tracks) then
                if (#timeline.tracks > 0) then
                    for j in pairs(timeline.tracks) do
                        local track = SceneMachine.Track:New();
                        track:ImportData(timeline.tracks[j]);
            
                        -- assigning the new track so that we have access to the class functions (which get stripped when exporting to savedata)
                        SM.loadedScene.timelines[i].tracks[j] = track;
                    end
                end
            end
        end
    end

    if (scene.properties) then
        OP.SetAmbientColor(scene.properties.ambientColor[1], scene.properties.ambientColor[2], scene.properties.ambientColor[3], 1);
        OP.SetDiffuseColor(scene.properties.diffuseColor[1], scene.properties.diffuseColor[2], scene.properties.diffuseColor[3], 1);
        OP.SetBackgroundColor(scene.properties.backgroundColor[1], scene.properties.backgroundColor[2], scene.properties.backgroundColor[3], 1);
        OP.ToggleLighting(scene.properties.enableLighting);
    end

    AM.RefreshTimelineTabs();

    -- load the first timeline
    AM.LoadTimeline(1);

    -- remember this scene was opened last
    --PM.currentProject.lastOpenScene = index;

    -- set the camera position and rotation to the last
    if (scene.lastCameraPosition ~= nil) then
        CameraController.position:Set(scene.lastCameraPosition[1], scene.lastCameraPosition[2], scene.lastCameraPosition[3]);
    end
    if (scene.lastCameraEuler ~= nil) then
        scene.lastCameraEuler[1] = 0;
        Camera.eulerRotation:Set(scene.lastCameraEuler[1], scene.lastCameraEuler[2], scene.lastCameraEuler[3]);
    end
    CameraController.Direction = math.deg(Camera.eulerRotation.z);

    -- refresh the scene tabs
    SM.RefreshSceneTabs();

    -- refresh
    SH.RefreshHierarchy();
    OP.Refresh();

    SM.selectedObjects = {};
end

function SM.GroupObjects(objects)
    if (not objects) then
        return;
    end

    local group = SceneMachine.GameObjects.Group:New("Group");
    group:FitObjects(objects);

    local scene = SM.loadedScene;
    
    local objectHierarchyBefore = SH.CopyObjectHierarchy(SM.loadedScene.objectHierarchy);
    Editor.StartAction(Actions.Action.Type.CreateObject, { group }, objectHierarchyBefore);
    
    scene.objects[#scene.objects + 1] = group;
    SH.AddNewObject(group.id);

	-- exclude current item from data, but remember the position in hierarchy
	SH.inputState.savedWorldPositions = {};
	SH.inputState.savedWorldRotations = {};
	SH.inputState.savedWorldScales = {};

    for i = 1, #objects, 1 do

		local object = objects[i];
        local hobject = SH.GetHierarchyObject(SM.loadedScene.objectHierarchy, object.id);

		local wPosition = object:GetWorldPosition();
		SH.inputState.savedWorldPositions[object.id] = wPosition;
		local wRotation = object:GetWorldRotation();
		SH.inputState.savedWorldRotations[object.id] = wRotation;
		local wScale = object:GetWorldScale();
		SH.inputState.savedWorldScales[object.id] = wScale;
		SH.RemoveIDFromHierarchy(object.id, SM.loadedScene.objectHierarchy);

        local intoId = group.id;
        SH.InsertIDChildInHierarchy(hobject, intoId, SM.loadedScene.objectHierarchy);
    end

    local objectHierarchyAfter = SH.CopyObjectHierarchy(SM.loadedScene.objectHierarchy);
    Editor.FinishAction(objectHierarchyAfter);

    SM.SelectObject(group);

    -- Refresh
    SH.RefreshHierarchy();
    OP.Refresh();
end