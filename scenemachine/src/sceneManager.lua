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

local tabButtonHeight = 20;
local tabPool = {};

SM.SCENE_DATA_VERSION = 1;

SM.loadedSceneIndex = 1;
SM.loadedScene = nil;
SM.selectedObject = nil;

function SM.Create(x, y, w, h, parent, startLevel)
    SM.startLevel = startLevel;
    SM.groupBG = UI.Rectangle:New(6, -6, w, h, Editor.verticalSeparatorL:GetFrame(), "TOPLEFT", "TOPLEFT",  0, 0, 0, 0);
    SM.groupBG:SetPoint("BOTTOMRIGHT", Editor.horizontalSeparator:GetFrame(), "BOTTOMRIGHT", 0, 6);
    SM.groupBG:SetFrameLevel(startLevel);
    SM.groupBG:SetClipsChildren(true);
    SceneMachine.Renderer.CreateRenderer(0, 0, w, h - tabButtonHeight, SM.groupBG:GetFrame(), startLevel + 1);

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

            SceneMachine.mainWindow:PopupWindowMenu(rx, ry, menuOptions);
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
    return SM.CreateScene();
end

function SM.AddScene(text)
    PM.currentProject.scenes[#PM.currentProject.scenes + 1] = SM.CreateScene(text);
    SM.RefreshSceneTabs();
end

function SM.RenameScene(text, index)
    if (text ~= nil and text ~= "") then
        -- rename existing scene
        PM.currentProject.scenes[index].name = text;
        SM.RefreshSceneTabs();
    end
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
    }
end

function SM.LoadScene(index)
    SM.loadedSceneIndex = index;
    SM.tabGroup.selectedIndex = index;
    --SM.loadedScene = {};

    if (#PM.currentProject.scenes == 0) then
        -- current project has no scenes, create a default one
        PM.currentProject.scenes[1] = SM.CreateDefaultScene();
        SM.RefreshSceneTabs();
    end

    -- unload current --
    SM.UnloadScene();

    -- load new --
    local scene = PM.currentProject.scenes[index];
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
        scene.properties = {
            ambientColor = { ar, ag, ab, 1 },
            diffuseColor = { dr, dg, db, 1 },
            backgroundColor = { 0.554, 0.554, 0.554, 1 }
        };
    end

    -- create loaded scene (so that objects get loaded from data not referenced) --
    --SM.loadedScene.objects = {};
    --SM.loadedScene.name = scene.name;

    if (#scene.objects > 0) then
        for i in pairs(scene.objects) do
            local object = SceneMachine.Object:New();
            object:ImportData(scene.objects[i]);

            -- Create actor
            local id = 0;
            if (object.type == SceneMachine.ObjectType.Model) then
                id = object.fileID;
            elseif(object.type == SceneMachine.ObjectType.Creature) then
                id = object.displayID;
            elseif(object.type == SceneMachine.ObjectType.Character) then
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
        OP.SetAmbientColor(scene.properties.ambientColor[1], scene.properties.ambientColor[2], scene.properties.ambientColor[2], 1);
        OP.SetDiffuseColor(scene.properties.diffuseColor[1], scene.properties.diffuseColor[2], scene.properties.diffuseColor[2], 1);
        OP.SetBackgroundColor(scene.properties.backgroundColor[1], scene.properties.backgroundColor[2], scene.properties.backgroundColor[2], 1);
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
        Camera.eulerRotation:Set(scene.lastCameraEuler[1], scene.lastCameraEuler[2], scene.lastCameraEuler[3]);
    end
    CameraController.Direction = deg(Camera.eulerRotation.x);

    -- refresh the scene tabs
    SM.RefreshSceneTabs();

    -- refresh
    SH.RefreshHierarchy();
    OP.Refresh();

    SM.selectedObject = nil;
end

function SM.UnloadScene()
    SM.selectedObject = nil;
    Renderer.Clear();
end

function SM.DeleteScene(index)
    -- switch to a different scene because the currently loaded is being deleted
    -- load first that isn't this one
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
    if (#PM.currentProject.scenes == 1) then
        SM.CreateDefaultScene();
        SM.LoadScene(1);
    end

    -- refresh ui
    SM.RefreshSceneTabs();
end

function SM.CreateObject(_fileID, _name, _x, _y, _z)
    local object = SceneMachine.Object:New(_name, _fileID, { x = _x, y = _y, z = _z });

    local scene = SM.loadedScene;--PM.currentProject.scenes[SM.loadedSceneIndex];
    scene.objects[#scene.objects + 1] = object;

    -- Create actor
    if (object.fileID ~= nil) then
        local actor = Renderer.AddActor(object.fileID, object.position.x, object.position.y, object.position.z, SceneMachine.ObjectType.Model);
        object:SetActor(actor);
    end

    -- Refresh
    SH.RefreshHierarchy();
    OP.Refresh();

    return object;
end

function SM.CreateCreature(_displayID, _name, _x, _y, _z)
    local object = SceneMachine.Object:NewCreature(_name, _displayID, { x = _x, y = _y, z = _z });

    local scene = SM.loadedScene;
    scene.objects[#scene.objects + 1] = object;

    -- Create actor
    if (object.fileID ~= nil) then
        local actor = Renderer.AddActor(object.displayID, object.position.x, object.position.y, object.position.z, SceneMachine.ObjectType.Creature);
        object:SetActor(actor);
    end

    -- Refresh
    SH.RefreshHierarchy();
    OP.Refresh();

    return object;
end

function SM.CreateCharacter(_x, _y, _z)
    local object = SceneMachine.Object:NewCharacter(UnitName("player"), { x = _x, y = _y, z = _z });

    local scene = SM.loadedScene;
    scene.objects[#scene.objects + 1] = object;

    -- Create actor
    if (object.fileID ~= nil) then
        local actor = Renderer.AddActor(-1, object.position.x, object.position.y, object.position.z, SceneMachine.ObjectType.Character);
        object:SetActor(actor);
    end

    -- Refresh
    SH.RefreshHierarchy();
    OP.Refresh();

    return object;
end

function SM.CloneObject(object, selectAfter)
    if (object == nil) then
        return;
    end

    local pos = object:GetPosition();
    local rot = object:GetRotation();
    local scale = object:GetScale();
    local clone = nil;
    if (object:GetType() == SceneMachine.ObjectType.Model) then
        clone = SM.CreateObject(object:GetFileID(), object:GetName(), pos.x, pos.y, pos.z);
    elseif(object:GetType() == SceneMachine.ObjectType.Creature) then
        clone = SM.CreateCreature(object:GetDisplayID(), object:GetName(), pos.x, pos.y, pos.z);
    elseif(object:GetType() == SceneMachine.ObjectType.Character) then
        clone = SM.CreateCharacter(pos.x, pos.y, pos.z);
    end
    
    if (clone) then
        clone:SetRotation(rot.x, rot.y, rot.z);
        clone:SetScale(scale);

        if (selectAfter) then
            SM.selectedObject = clone;
        end

        SH.RefreshHierarchy();
        OP.Refresh();
    end
end

function SM.Clear()
    print("clear")
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

function SM.DeleteObject(object)
    if (object == nil) then
        return;
    end

    if (SM.selectedObject == object) then
        SM.selectedObject = nil;
    end

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
				AM.RemoveTrack(AM.loadedTimeline.tracks[i]);
			end
		end
	end

    -- refresh hierarchy
    SH.RefreshHierarchy();
    OP.Refresh();
end

function SM.ToggleObjectVisibility(object)
    if (object == nil) then
        return;
    end

    object:ToggleVisibility();
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
    if (not decoded) then print("Decode failed."); return end
    local decompressed = SceneMachine.Libs.LibDeflate:DecompressDeflate(decoded);
    if (not decompressed) then print("Decompress failed."); return end
    local success, sceneData = SceneMachine.Libs.LibSerialize:Deserialize(decompressed);
    if (not success) then print("Deserialize failed."); return end

    if(sceneData.version > SM.SCENE_DATA_VERSION) then
        -- handle newer version
        print("Newer scene version detected, and is unsupported. Please update SceneMachine");
    else
        -- handle known versions
        if (sceneData.version == 1) then
            SM.ImportVersion1Scene(sceneData);
        end
    end
end

function SM.ImportVersion1Scene(sceneData)
    local scene = SM.CreateScene(sceneData.name);

    if (#sceneData.objects > 0) then
        for i = 1, #sceneData.objects, 1 do
            local object = SceneMachine.Object:New();
            object:ImportPacked(sceneData.objects[i]);
            scene.objects[i] = object;
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

    PM.currentProject.scenes[#PM.currentProject.scenes + 1] = scene;
    SM.LoadScene(#PM.currentProject.scenes);
end

function SM.ImportNetworkScene(sceneData)
    local scene = SM.CreateScene(sceneData.name);

    if (#sceneData.objects > 0) then
        for i = 1, #sceneData.objects, 1 do
            local object = SceneMachine.Object:New();
            object:ImportPacked(sceneData.objects[i]);
            scene.objects[i] = object;
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
    --    PM.currentProject.scenes[1] = SM.CreateDefaultScene();
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
        scene.properties = {
            ambientColor = { ar, ag, ab, 1 },
            diffuseColor = { dr, dg, db, 1 },
            backgroundColor = { 0.554, 0.554, 0.554, 1 }
        };
    end

    -- create loaded scene (so that objects get loaded from data not referenced) --
    --SM.loadedScene.objects = {};
    --SM.loadedScene.name = scene.name;

    if (#scene.objects > 0) then
        for i in pairs(scene.objects) do
            local object = SceneMachine.Object:New();
            object:ImportData(scene.objects[i]);

            -- Create actor
            local id = 0;
            if (object.type == SceneMachine.ObjectType.Model) then
                id = object.fileID;
            elseif(object.type == SceneMachine.ObjectType.Creature) then
                id = object.displayID;
            elseif(object.type == SceneMachine.ObjectType.Character) then
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
        OP.SetAmbientColor(scene.properties.ambientColor[1], scene.properties.ambientColor[2], scene.properties.ambientColor[2], 1);
        OP.SetDiffuseColor(scene.properties.diffuseColor[1], scene.properties.diffuseColor[2], scene.properties.diffuseColor[2], 1);
        OP.SetBackgroundColor(scene.properties.backgroundColor[1], scene.properties.backgroundColor[2], scene.properties.backgroundColor[2], 1);
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
        Camera.eulerRotation:Set(scene.lastCameraEuler[1], scene.lastCameraEuler[2], scene.lastCameraEuler[3]);
    end
    CameraController.Direction = deg(Camera.eulerRotation.x);

    -- refresh the scene tabs
    SM.RefreshSceneTabs();

    -- refresh
    SH.RefreshHierarchy();
    OP.Refresh();

    SM.selectedObject = nil;
end