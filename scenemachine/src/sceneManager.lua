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
local Timeline = SceneMachine.Timeline;
local Scene = SceneMachine.Scene;

local tabButtonHeight = 20;
local tabPool = {};

SM.loadedSceneIndex = -1;
SM.loadedScene = nil;
SM.selectedObjects = {};

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
    PM.currentProject.scenes[index] = Scene:New(text);
    SM.LoadScene(index);

    -- load default cube. No! sphere
    local sphere = SM.loadedScene:CreateObject(3088290, "Default Sphere", 0, 0, 0);
    sphere:SetScale(0.05);

    SM.RefreshSceneTabs();
    SH.RefreshHierarchy();
    OP.Refresh();
end

function SM.RenameSelectedScene(text)
    SM.RenameScene(text, SM.loadedSceneIndex);
end

function SM.RenameScene(text, index)
    -- rename existing scene
    PM.currentProject.scenes[index]:SetName(text);
    SM.RefreshSceneTabs();
end

function SM.GetSceneName()
    if (SM.loadedScene) then
        return SM.loadedScene:GetName();
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

    local sceneString = scene:ExportSceneForPrint();

    Editor.ShowImportExportWindow(nil, sceneString);
end

function SM.Button_ImportScene()
    Editor.ShowImportExportWindow(SM.ImportSceneFromPrint, "");
end

function SM.ImportSceneFromPrint(text)
    local scene = Scene:New();
    scene:ImportSceneFromPrint(text);
    table.insert(PM.currentProject.scenes, scene);
    SM.RefreshSceneTabs();
    SM.LoadScene(#PM.currentProject.scenes);
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
    local sceneData = PM.currentProject.scenes[index];
    local scene = Scene:New();
    scene:ImportData(sceneData);
    scene:Load();
    
    PM.currentProject.scenes[index] = scene;    -- feed the class back into the data to save it properly
    SM.loadedScene = scene;

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

    -- refresh the scene tabs
    SM.RefreshSceneTabs();

    -- refresh
    SH.RefreshHierarchy();
    OP.Refresh();
    SM.ApplySelectionEffects();
    Editor.RefreshActionToolbar();

    SM.selectedObjects = {};
end

function SM.UnloadScene()
    if (SM.loadedScene == nil) then
        return;
    end
    
    for i = 1, SM.loadedScene:GetObjectCount(), 1 do
        local object = SM.loadedScene:GetObject(i);
        object:Deselect();
        if (object:HasActor()) then
            object:ClearSpellVisualKits();
        end
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

function SM.DeleteScene(index)
    -- switch to a different scene because the currently loaded is being deleted
    -- load first that isn't this one
    if (SM.loadedScene == PM.currentProject.scenes[index]) then
        SM.UnloadScene();
        SH.RefreshHierarchy();
    end

    for i in pairs(PM.currentProject.scenes) do
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
		Editor.lastSelectedType = Editor.SelectionType.Object;
	end
end

function SM.SelectObjectByIndex(index)
    if (index <= 0) then
        SM.SelectObject(nil);
        return;
    end
    SM.SelectObject(SM.loadedScene:GetObject(index));
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
		Editor.lastSelectedType = Editor.SelectionType.Object;
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
    if (not SM.loadedScene) then
        return;
    end

    -- Deselect all
    for i = 1, SM.loadedScene:GetObjectCount(), 1 do
        local object = SM.loadedScene:GetObject(i);
        if (object) then
            object:Deselect();
        end
    end

    -- Select selected
    for i = 1, #SM.selectedObjects, 1 do
        local object = SM.loadedScene:GetObjectByID(SM.selectedObjects[i]:GetID());
        if (object) then
            object:Select();
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
            clones[i] = SM.loadedScene:CloneObject(objects[i]);
        end
    end
    local objectHierarchyBefore = Scene.RawCopyObjectHierarchy(SM.loadedScene:GetObjectHierarchy());
    Editor.StartAction(Actions.Action.Type.CreateObject, clones, objectHierarchyBefore);

    local objectHierarchyAfter = Scene.RawCopyObjectHierarchy(SM.loadedScene:GetObjectHierarchy());
    Editor.FinishAction(objectHierarchyAfter);

    if (selectAfter) then
        SM.selectedObjects = clones;
    end

    SH.RefreshHierarchy();
    OP.Refresh();
end

function SM.ObjectHasTrack(obj)
    if (not obj) then
        return false;
    end
    
    if (AM.loadedTimeline) then
		for i = 1, AM.loadedTimeline:GetTrackCount(), 1 do
			if (AM.loadedTimeline:GetTrack(i).objectID == obj.id) then
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
    local objectHierarchyBefore = Scene.RawCopyObjectHierarchy(SM.loadedScene:GetObjectHierarchy());

    -- collect child objects
    local allObjects = {};
    for i = 1, #objects, 1 do
        table.insert(allObjects, objects[i]);
        local childObjects = SM.loadedScene:GetChildObjectsRecursive(objects[i].id);
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
    local objectHierarchyAfter = Scene.RawCopyObjectHierarchy(SM.loadedScene:GetObjectHierarchy());
    Editor.FinishAction(objectHierarchyAfter);
end

function SM.DeleteObject_internal(object)
    if (object == nil) then
        return;
    end

    SM.selectedObjects = {};
    SM.loadedScene:DeleteObject(object);

    -- refresh hierarchy
    SH.RefreshHierarchy();
    OP.Refresh();
end

function SM.UndeleteObject_internal(object)
    if (object == nil) then
        return;
    end

    SM.loadedScene:UndeleteObject(object);

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

function SM.LoadNetworkScene(sceneData)
    SM.loadedSceneIndex = -1;

    Editor.SetMode(Editor.MODE_NETWORK);

    -- unload current --
    SM.UnloadScene();

    -- load new --
    local scene = Scene:New();
    scene:ImportData(sceneData);
    scene:Load();
    SM.loadedScene = scene;

    if (scene.properties) then
        OP.SetAmbientColor(scene.properties.ambientColor[1], scene.properties.ambientColor[2], scene.properties.ambientColor[3], 1);
        OP.SetDiffuseColor(scene.properties.diffuseColor[1], scene.properties.diffuseColor[2], scene.properties.diffuseColor[3], 1);
        OP.SetBackgroundColor(scene.properties.backgroundColor[1], scene.properties.backgroundColor[2], scene.properties.backgroundColor[3], 1);
        OP.ToggleLighting(scene.properties.enableLighting);
    end

    AM.RefreshTimelineTabs();

    -- load the first timeline
    AM.LoadTimeline(1);

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

    local scene = SM.loadedScene;
    
    local group = SceneMachine.GameObjects.Group:New("Group");
    group:FitObjects(objects);

    local objectHierarchyBefore = Scene.RawCopyObjectHierarchy(SM.loadedScene:GetObjectHierarchy());
    Editor.StartAction(Actions.Action.Type.CreateObject, { group }, objectHierarchyBefore);
    
    local group = scene:GroupObjects(group, objects);

    local objectHierarchyAfter = Scene.RawCopyObjectHierarchy(SM.loadedScene:GetObjectHierarchy());
    Editor.FinishAction(objectHierarchyAfter);

    SM.SelectObject(group);

    -- Refresh
    SH.RefreshHierarchy();
    OP.Refresh();
end