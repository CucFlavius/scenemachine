SceneMachine.Scene = {}

--- @class Scene
local Scene = SceneMachine.Scene;
Scene.SCENE_DATA_VERSION = 2;

local Renderer = SceneMachine.Renderer;
local Timeline = SceneMachine.Timeline;
local Vector3 = SceneMachine.Vector3;
local Actions = SceneMachine.Actions;

setmetatable(Scene, Scene)

local fields = {}

--- Creates a new Scene object.
--- @param sceneName string (optional) The name of the scene.
--- @return Scene: The newly created Scene object.
function Scene:New(sceneName)
    --- @class Scene
    local v =
    {
        name = sceneName or "Scene",
        objects = {},
        objectHierarchy = {},
        timelines = {},
        properties = {
            ambientColor = { 181/255, 194/255, 203/255, 1 },
            diffuseColor = { 217/255, 217/255, 190/255, 1 },
            backgroundColor = { 0.554, 0.554, 0.554, 1 },
            enableLighting = true,
        },
        lastCameraPosition = {8.8, -8.8, 6.5},
        lastCameraEuler = {0, math.rad(27), math.rad(135)},
        --- @type Action
        startedAction = nil,
    };

    setmetatable(v, Scene)

    return v
end

--- Loads the scene and initializes its properties and objects.
function Scene:Load()
    self.loaded = true;
    self.actionPool = self.actionPool or {};
    self.startedAction = self.startedAction or nil;
    self.actionPointer = self.actionPointer or 0;

    self.objects = self.objects or {};
    self.timelines = self.timelines or {};

    self.properties = self.properties or {
        ambientColor = { 181/255, 194/255, 203/255, 1 },
        diffuseColor = { 217/255, 217/255, 190/255, 1 },
        backgroundColor = { 0.554, 0.554, 0.554, 1 },
        enableLighting = true,
    };

    if (self.properties.enableLighting == nil) then
        self.properties.enableLighting = true;
    end

    -- verify scene objects integrity, and remove any nil objects
    for i = #self.objects, 1, -1 do
        if (not self.objects[i]) then
            table.remove(self.objects, i);
        end
    end

    -- buld objectid map
    self.objectIDMap = {};
    for i = 1, #self.objects, 1 do
        self.objectIDMap[self.objects[i].id] = self.objects[i];
    end

    -- verify hierarchy integrity, and remove any nil objects
    self:VerifyHierarchyIntegrityRecursive(self.objectHierarchy);

    if (#self.timelines == 0) then
        self.timelines[1] = Timeline:New("Timeline 1", 30000, self);
    end

    for i = 1, #self.objects, 1 do
        self.objects[i]:RecalculateWorldMatrices();
        self.objects[i]:RecalculateActors();
    end
end

--- Rebuilds the object hierarchy for the scene.
--- This function creates a new object hierarchy table and populates it with the IDs of the objects in the scene.
--- Each object entry in the hierarchy table also contains an empty childObjects table.
--- This is mainly for backwards compatibility with older scene data.
function Scene:RebuildObjectHierarchy()
    self.objectHierarchy = {};
    for i = 1, #self.objects, 1 do
        table.insert(self.objectHierarchy, { id = self.objects[i].id, childObjects = {} });
    end
end

--- Recursively verifies the integrity of the object hierarchy.
--- @param objectBuffer table The buffer containing the objects to verify.
function Scene:VerifyHierarchyIntegrityRecursive(objectBuffer)
    if (objectBuffer) then
        for i = 1, #objectBuffer, 1 do
            if (objectBuffer[i]) then
                local object = self:GetObjectByID(objectBuffer[i].id);
                if (not object) then
                    table.remove(objectBuffer, i);
                    i = i - 1;
                end
                if (i > 0) then
                    self:VerifyHierarchyIntegrityRecursive(objectBuffer[i].childObjects);
                end
            end
        end
    end
end

--- Retrieves an object from the scene by its ID.
--- @param id number The ID of the object to retrieve.
--- @return Object|Actor|nil: The object with the specified ID, or nil if not found.
function Scene:GetObjectByID(id)
    if (self.objectIDMap[id]) then
        return self.objectIDMap[id];
    end

    for i = 1, #self.objects, 1 do
        if (self.objects[i].id == id) then
            self.objectIDMap[self.objects[i].id] = self.objects[i];
            return self.objectIDMap[id];
        end
    end

    return nil;
end

--- Returns the number of objects in the scene.
--- @return number The number of objects in the scene.
function Scene:GetObjectCount()
    return #self.objects;
end

--- Retrieves an object from the scene by its index.
--- @param index number The index of the object to retrieve.
--- @return Object|nil: The object at the specified index, or nil if the index is out of range.
function Scene:GetObject(index)
    if (index > 0 and index <= #self.objects) then
        return self.objects[index];
    end
    return nil;
end

--- Retrieves the timeline at the specified index.
--- @param index number The index of the timeline to retrieve.
--- @return Timeline|nil: The timeline at the specified index, or nil if the index is out of range.
function Scene:GetTimeline(index)
    if (index > 0 and index <= #self.timelines) then
        return self.timelines[index];
    end
    return nil;
end

--- Gets the count of timelines in the scene.
--- @return number: The count of timelines.
function Scene:GetTimelineCount()
    return #self.timelines;
end

--- Retrieves the timelines associated with the scene.
--- @return Timeline[]: The timelines associated with the scene.
function Scene:GetTimelines()
    return self.timelines;
end

--- Adds a timeline to the scene.
--- @param timeline Timeline The timeline to add.
function Scene:AddTimeline(timeline)
    table.insert(self.timelines, timeline);
end

--- Deletes a timeline from the scene.
--- @param timeline Timeline The timeline to be deleted.
function Scene:DeleteTimeline(timeline)
    for i = 1, #self.timelines, 1 do
        local t = self.timelines[i];
        if (t == timeline) then
            table.remove(self.timelines, i);
            break;
        end
    end
end

--- Adds a timeline to the scene's list of timelines.
--- @param timeline Timeline The timeline to be added.
function Scene:UndeleteTimeline(timeline)
    table.insert(self.timelines, timeline);
end

--- Gets the name of the scene.
--- @return string: The name of the scene.
function Scene:GetName()
    return self.name;
end

--- Sets the name of the scene.
--- @param name string The name to set for the scene.
function Scene:SetName(name)
    if (name ~= nil and name ~= "") then
        self.name = name;
    end
end

--- Creates a new object (model) in the scene.
--- @param fileID number The ID of the file associated with the object.
--- @param name string The name of the object.
--- @param x number The x-coordinate of the object's position.
--- @param y number The y-coordinate of the object's position.
--- @param z number The z-coordinate of the object's position.
--- @return Model: The newly created model object.
function Scene:CreateObject(fileID, name, x, y, z)
    local object = SceneMachine.GameObjects.Model:New(self, name, fileID, Vector3:New(x, y, z));
    table.insert(self.objects, object);

    -- Create actor
    if (object.fileID ~= nil) then
        local actor = Renderer.AddActor(object.fileID, object.position.x, object.position.y, object.position.z, SceneMachine.GameObjects.Object.Type.Model);
        object:SetActor(actor);
    end

    self:AddObjectToHierarchy(object.id);
    return object;
end

--- Creates a new creature object and adds it to the scene.
--- @param displayID number The display ID of the creature.
--- @param name string The name of the creature.
--- @param x number The x-coordinate of the creature's position.
--- @param y number The y-coordinate of the creature's position.
--- @param z number The z-coordinate of the creature's position.
--- @return Creature: The newly created creature object.
function Scene:CreateCreature(displayID, name, x, y, z)
    local object = SceneMachine.GameObjects.Creature:New(self, name, displayID, Vector3:New(x, y, z));
    table.insert(self.objects, object);

    -- Create actor
    if (object.fileID ~= nil) then
        local actor = Renderer.AddActor(object.displayID, object.position.x, object.position.y, object.position.z, SceneMachine.GameObjects.Object.Type.Creature);
        object:SetActor(actor);
    end

    self:AddObjectToHierarchy(object.id);
    return object;
end

--- Creates a player character object and adds it to the scene.
--- @param x number The x-coordinate of the character's position.
--- @param y number The y-coordinate of the character's position.
--- @param z number The z-coordinate of the character's position.
--- @return Character: The created character object.
function Scene:CreateCharacter(x, y, z)
    local object = SceneMachine.GameObjects.Character:New(self, UnitName("player"), Vector3:New(x, y, z));
    table.insert(self.objects, object);

    -- Create actor
    if (object.fileID ~= nil) then
        local actor = Renderer.AddActor(-1, object.position.x, object.position.y, object.position.z, SceneMachine.GameObjects.Object.Type.Character);
        object:SetActor(actor);
    end

    self:AddObjectToHierarchy(object.id);
    return object;
end

--- Creates a new camera object in the scene.
--- @param fov number? The field of view of the camera in radians. Defaults to 60 degrees.
--- @param nearClip number? The distance to the near clipping plane. Defaults to 0.01.
--- @param farClip number? The distance to the far clipping plane. Defaults to 1000.
--- @param x number? The x-coordinate of the camera's position. Optional.
--- @param y number? The y-coordinate of the camera's position. Optional.
--- @param z number? The z-coordinate of the camera's position. Optional.
--- @param rx number? The x-component of the camera's rotation. Optional.
--- @param ry number? The y-component of the camera's rotation. Optional.
--- @param rz number? The z-component of the camera's rotation. Optional.
--- @return Camera: The newly created camera object.
function Scene:CreateCamera(fov, nearClip, farClip, x, y, z, rx, ry, rz)
    local name = "New Camera";
    local position = Vector3:New();
    if (x and y and z) then
        position:SetVector3(Vector3:New(x, y, z));
    end
    local rotation = Vector3:New();
    if (rx and ry and rz) then
        rotation:SetVector3(Vector3:New(rx, ry, rz));
    end
    fov = fov or math.rad(60);
    nearClip = nearClip or 0.01;
    farClip = farClip or 1000;

    local object = SceneMachine.GameObjects.Camera:New(self, name, position, rotation, fov, nearClip, farClip);
    table.insert(self.objects, object);

    self:AddObjectToHierarchy(object.id);
    return object;
end

--- Adds a group of objects to the scene and updates the object hierarchy.
--- @param group Group The group object to be added.
--- @param objects Object[] A table containing the objects to be grouped.
function Scene:GroupObjects(group, objects)
    table.insert(self.objects, group);
    self:AddObjectToHierarchy(group.id);

    -- exclude current item from data, but remember the position in hierarchy
    self.savedWorldPositions = {};
    self.savedWorldRotations = {};
    self.savedWorldScales = {};

    for i = 1, #objects, 1 do
        local object = objects[i];
        local hobject = self:GetHierarchyObject(self.objectHierarchy, object.id);
        if (hobject) then
            local wPosition = object:GetWorldPosition();
            self.savedWorldPositions[object.id] = wPosition;
            local wRotation = object:GetWorldRotation();
            self.savedWorldRotations[object.id] = wRotation;
            local wScale = object:GetWorldScale();
            self.savedWorldScales[object.id] = wScale;
            self:RemoveIDFromHierarchy(object.id, self.objectHierarchy);

            local intoId = group.id;
            self:InsertIDChildInHierarchy(hobject, intoId, self.objectHierarchy);
        end
    end
end

--- Deletes an object from the scene.
--- @param object Object The object to be deleted.
function Scene:DeleteObject(object)
    if (#self.objects > 0) then
        for i in pairs(self.objects) do
            if (self.objects[i] == object) then
                table.remove(self.objects, i);
            end
        end
    end

    if (object:HasActor()) then
        Renderer.RemoveActor(object:GetActor());
    end

    -- also delete track if it exists
    if (self.timelines) then
        for t = 1, #self.timelines, 1 do
            for i = 1, self.timelines[t]:GetTrackCount(), 1 do
                if (self.timelines[t]:GetTrack(i).objectID == object.id) then
                    self.timelines[t]:RemoveTrack(self.timelines[t]:GetTrack(i));
                end
            end
        end
    end

    self:RemoveIDFromHierarchy(object.id, self.objectHierarchy);
end

--- Undeletes an object in the scene.
--- @param object Object The object to undelete.
function Scene:UndeleteObject(object)
    table.insert(self.objects, object);

    if (object:HasActor()) then
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

        object:SetActor(actor);
        object:RecalculateActors();
    end

    -- TODO: restore timeline track
    --[[
    if (AM.loadedTimeline) then
		for i = 1, AM.loadedTimeline:GetTrackCount(), 1 do
			if (AM.loadedTimeline:GetTrack(i).objectID == object.id) then
				AM.RemoveTrack(AM.loadedTimeline:GetTrack(i));
			end
		end
	end
    --]]
end

--- Clones an object within the scene.
--- @param object Object The object to be cloned.
--- @return Object?: The cloned object.
function Scene:CloneObject(object)
    if (object == nil) then
        return nil;
    end

    local pos = object:GetPosition();
    local rot = object:GetRotation();
    local scale = object:GetScale();

    local clone = nil;
    if (object:GetType() == SceneMachine.GameObjects.Object.Type.Model) then
        clone = self:CreateObject(object:GetFileID(), object:GetName(), pos.x, pos.y, pos.z);
        clone:SetAlpha(object:GetAlpha());
        clone:SetDesaturation(object:GetDesaturation());
    elseif(object:GetType() == SceneMachine.GameObjects.Object.Type.Creature) then
        clone = self:CreateCreature(object:GetDisplayID(), object:GetName(), pos.x, pos.y, pos.z);
        clone:SetAlpha(object:GetAlpha());
        clone:SetDesaturation(object:GetDesaturation());
    elseif(object:GetType() == SceneMachine.GameObjects.Object.Type.Character) then
        clone = self:CreateCharacter(pos.x, pos.y, pos.z);
        clone:SetAlpha(object:GetAlpha());
        clone:SetDesaturation(object:GetDesaturation());
    end
    if (clone) then
        local hobject = self:GetHierarchyObject(self.objectHierarchy, clone.id);
        
        local parentObj = self:GetParentObject(object.id);
        if (parentObj and hobject) then
            self.savedWorldPositions = {};
            self.savedWorldRotations = {};
            self.savedWorldScales = {};

            local wPosition = object:GetWorldPosition();
            self.savedWorldPositions[hobject.id] = wPosition;
            local wRotation = object:GetWorldRotation();
            self.savedWorldRotations[hobject.id] = wRotation;
            local wScale = object:GetWorldScale();
            self.savedWorldScales[hobject.id] = wScale;
        
            self:RemoveIDFromHierarchy(clone.id, self.objectHierarchy);

            local intoId = parentObj.id;
            self:InsertIDChildInHierarchy(hobject, intoId, self.objectHierarchy);
        end

        clone:SetRotation(rot.x, rot.y, rot.z);
        clone:SetScale(scale);
    end

    return clone;
end

--- Inserts a child object into the hierarchy of the scene based on the given parent ID.
--- @param hobject table The child object to insert.
--- @param intoId number The ID of the parent object to insert into.
--- @param currentList table[] The current list of objects to search for the parent ID.
function Scene:InsertIDChildInHierarchy(hobject, intoId, currentList)
    for i = 1, #currentList, 1 do
        if (currentList[i].id == intoId) then
            table.insert(currentList[i].childObjects, hobject);
            hobject.parentID = intoId;
            local object = self:GetObjectByID(hobject.id)
            local wPosition = self.savedWorldPositions[hobject.id];
            local wRotation = self.savedWorldRotations[hobject.id];
            local wScale = self.savedWorldScales[hobject.id];
            if (object) then
                object:SetWorldPosition(wPosition.x, wPosition.y, wPosition.z);
                object:SetWorldRotation(wRotation.x, wRotation.y, wRotation.z);
                object:SetWorldScale(wScale);
            end
            return;
        end

        self:InsertIDChildInHierarchy(hobject, intoId, currentList[i].childObjects);
    end
end

--- Removes the specified ID from the hierarchy of objects in the scene.
--- @param id number The ID of the object to be removed.
--- @param currentList table[] The current list of objects to search through.
function Scene:RemoveIDFromHierarchy(id, currentList)
    for i = 1, #currentList, 1 do
        if (currentList[i].id == id) then
            table.remove(currentList, i);
            return;
        end

        self:RemoveIDFromHierarchy(id, currentList[i].childObjects);
    end
end

--- Inserts an object above a specified ID in the hierarchy.
--- @param hobject table The object to be inserted.
--- @param aboveID number The ID of the object above which the new object should be inserted.
--- @param currentList table[] The current list of objects in the hierarchy.
function Scene:InsertIDAboveInHierarchy(hobject, aboveID, currentList)
    for i = 1, #currentList, 1 do
        if (currentList[i].id == aboveID) then
            -- insert above current id in id's parent
            table.insert(currentList, i, hobject);
            local object = self:GetObjectByID(hobject.id)
            local wPosition = self.savedWorldPositions[hobject.id];
            local wRotation = self.savedWorldRotations[hobject.id];
            local wScale = self.savedWorldScales[hobject.id];
            if (object) then
                object:SetWorldPosition(wPosition.x, wPosition.y, wPosition.z);
                object:SetWorldRotation(wRotation.x, wRotation.y, wRotation.z);
                object:SetWorldScale(wScale);
            end
            hobject.parentID = aboveID;
            return;
        end

        self:InsertIDAboveInHierarchy(hobject, aboveID, currentList[i].childObjects);
    end
end

--- Inserts an object below a specified ID in the hierarchy.
--- @param hobject table The object to be inserted.
--- @param belowID number The ID of the object below which the new object should be inserted.
--- @param currentList table[] The current list of objects in the hierarchy.
function Scene:InsertIDBelowInHierarchy(hobject, belowID, currentList)
    for i = 1, #currentList, 1 do
        if (currentList[i].id == belowID) then
            -- if current has child objects
            if (#currentList[i].childObjects > 0) then
                -- if open
                if (currentList[i].open) then
                    -- insert as first child
                    table.insert(currentList[i].childObjects, 1, hobject);
                    hobject.parentID = belowID;
                -- if closed
                else
                    -- insert below current id in id's parent
                    table.insert(currentList, i + 1, hobject);
                    hobject.parentID = currentList[i].parentID;
                end
            -- if current doesn't have child objects
            else
                -- insert below current id in id's parent
                table.insert(currentList, i + 1, hobject);
                hobject.parentID = currentList[i].parentID;
            end
            local object = self:GetObjectByID(hobject.id)
            local wPosition = self.savedWorldPositions[hobject.id];
            local wRotation = self.savedWorldRotations[hobject.id];
            local wScale = self.savedWorldScales[hobject.id];
            if (object) then
                object:SetWorldPosition(wPosition.x, wPosition.y, wPosition.z);
                object:SetWorldRotation(wRotation.x, wRotation.y, wRotation.z);
                object:SetWorldScale(wScale);
            end
            return;
        end

        self:InsertIDBelowInHierarchy(hobject, belowID, currentList[i].childObjects);
    end
end

--- Retrieves the hierarchy object with the specified ID from the object buffer.
--- @param objectBuffer table[] The table containing the objects to search through.
--- @param ID number The ID of the object to retrieve.
--- @return table|nil: The hierarchy object with the specified ID, or nil if not found.
function Scene:GetHierarchyObject(objectBuffer, ID)
    for i = 1, #objectBuffer do
        if objectBuffer[i].id == ID then
            return objectBuffer[i]
        elseif objectBuffer[i].childObjects then
            local result = self:GetHierarchyObject(objectBuffer[i].childObjects, ID)
            if result then
                return result
            end
        end
    end
    return nil;
end

--- Retrieves the child objects of a given ID in the scene.
--- @param ID number The ID of the parent object.
--- @return table|nil: A table containing the child objects.
function Scene:GetChildObjects(ID)
    local hobject = self:GetHierarchyObject(self.objectHierarchy, ID);
    if (not hobject) then
        return nil;
    end
    
    local childObjects = {};
    for i = 1, #hobject.childObjects, 1 do
        local object = self:GetObjectByID(hobject.childObjects[i].id);
        if (object) then
            table.insert(childObjects, object);
        end
    end
    
    return childObjects;
end

--- Recursively retrieves all child objects of a given ID in the scene hierarchy.
--- @param ID number The ID of the parent object.
--- @return table|nil: A table containing all child objects.
function Scene:GetChildObjectsRecursive(ID)
    local hobject = self:GetHierarchyObject(self.objectHierarchy, ID);
    if (not hobject) then
        return nil;
    end
    
    local childObjects = {};
    for i = 1, #hobject.childObjects, 1 do
        local object = self:GetObjectByID(hobject.childObjects[i].id);
        if (object) then
            table.insert(childObjects, object);
            local childChildObjects = self:GetChildObjectsRecursive(hobject.childObjects[i].id);
            if (childChildObjects) then
                for j = 1, #childChildObjects, 1 do
                    table.insert(childObjects, childChildObjects[j]);
                end
            end
        end
    end
    
    return childObjects;
end

--- Retrieves the parent object of the specified ID.
--- @param ID number The ID of the object.
--- @return table|nil The parent object if found, or nil if not found.
function Scene:GetParentObject(ID)
    local hobject = self:GetHierarchyObject(self.objectHierarchy, ID);
    if (not hobject) then
        return nil;
    end

    if (hobject.parentID == -1) then
        return nil;
    end

    local parentObject = self:GetObjectByID(hobject.parentID);
    return parentObject;
end

--- Adds an object to the scene's object hierarchy.
--- @param ID number The ID of the object to add.
function Scene:AddObjectToHierarchy(ID)
    if (not self.objectHierarchy) then
        self.objectHierarchy = {};
    end

    table.insert(self.objectHierarchy, { id = ID, childObjects = {} });
end

--- Retrieves the object hierarchy of the scene.
--- @return table[] The object hierarchy of the scene.
function Scene:GetObjectHierarchy()
    return self.objectHierarchy;
end

--- Sets the object hierarchy for the scene.
--- @param hierarchy table[] The object hierarchy to set.
function Scene:SetObjectHierarchy(hierarchy)
    self.objectHierarchy = Scene.RawCopyObjectHierarchy(hierarchy);
end

--- Stores the world positions, rotations, and scales of objects in the scene hierarchy
--- and removes the objects from the hierarchy so that a hierarchy operation can be performed on them.
--- @param objects Object[] A table containing objects to store the hierarchy information for.
function Scene:StoreHierarchyObjects(objects)
    self.savedWorldPositions = {};
	self.savedWorldRotations = {};
	self.savedWorldScales = {};
	for i = 1, #objects, 1 do
		local object = self:GetObjectByID(objects[i].id)
        if (object) then
            local wPosition = object:GetWorldPosition();
            self.savedWorldPositions[objects[i].id] = wPosition;
            local wRotation = object:GetWorldRotation();
            self.savedWorldRotations[objects[i].id] = wRotation;
            local wScale = object:GetWorldScale();
            self.savedWorldScales[objects[i].id] = wScale;
            self:RemoveIDFromHierarchy(objects[i].id, self:GetObjectHierarchy());
        end
    end
end

--- Sets the ambient color of the scene.
--- @param r number: The red component of the ambient color (0-1).
--- @param g number: The green component of the ambient color (0-1).
--- @param b number: The blue component of the ambient color (0-1).
--- @param a number: The alpha component of the ambient color (0-1).
function Scene:SetAmbientColor(r, g, b, a)
    self.properties.ambientColor = { r, g, b, a };
    Renderer.projectionFrame:SetLightAmbientColor(r, g, b);
end

--- Retrieves the ambient color of the scene.
--- @return table: The ambient color of the scene.
function Scene:GetAmbientColor()
    return self.properties.ambientColor;
end

--- Sets the diffuse color of the scene.
--- @param r number: The red component of the diffuse color (0-1).
--- @param g number: The green component of the diffuse color (0-1).
--- @param b number: The blue component of the diffuse color (0-1).
--- @param a number: The alpha component of the diffuse color (0-1).
function Scene:SetDiffuseColor(r, g, b, a)
    self.properties.diffuseColor = { r, g, b, a };
    Renderer.projectionFrame:SetLightDiffuseColor(r, g, b);
end

--- Retrieves the diffuse color of the scene.
--- @return table: The diffuse color of the scene.
function Scene:GetDiffuseColor()
    return self.properties.diffuseColor;
end

--- Sets the background color of the scene.
--- @param r number: The red component of the color (0-1).
--- @param g number: The green component of the color (0-1).
--- @param b number: The blue component of the color (0-1).
--- @param a number: The alpha component of the color (0-1).
function Scene:SetBackgroundColor(r, g, b, a)
    self.properties.backgroundColor = { r, g, b, a };
    Renderer.backgroundFrame.texture:SetColorTexture(r, g, b, 1);
end

--- Retrieves the background color of the scene.
--- @return table: The background color as a table containing RGB values.
function Scene:GetBackgroundColor()
    return self.properties.backgroundColor;
end

--- Sets the lighting enabled state for the scene.
--- @param enabled boolean - Whether to enable or disable lighting.
function Scene:SetLightingEnabled(enabled)
    self.properties.enableLighting = enabled;
    Renderer.projectionFrame:SetLightVisible(enabled);
end

--- Checks if lighting is enabled for the scene.
--- @return boolean: True if lighting is enabled, false otherwise.
function Scene:IsLightingEnabled()
    return self.properties.enableLighting;
end

--- Retrieves the properties of the scene.
--- @return table: The properties of the scene.
function Scene:GetProperties()
    return self.properties;
end

--- Returns the number of actions in the scene's action pool.
--- @return number: The count of actions in the action pool.
function Scene:GetActionCount()
    return #self.actionPool;
end

--- Retrieves the action pointer of the scene.
--- @return number: The action pointer of the scene.
function Scene:GetActionPointer()
    return self.actionPointer;
end

--- Undo the last action performed in the scene.
--- If there are no more actions to undo, the function returns without doing anything.
function Scene:Undo()
    if (self.actionPointer < 1) then
        return;
    end

    self.actionPool[self.actionPointer]:Undo();
    self.actionPointer = self.actionPointer - 1;
    self.actionPointer = math.max(0, self.actionPointer);
end

--- Redo the next action performed in the scene.
--- If there are no more actions to redo, the function returns without doing anything.
function Scene:Redo()
    if (self.actionPointer >= #self.actionPool) then
        return;
    end

    self.actionPointer = self.actionPointer + 1;
    self.actionPointer = math.min(#self.actionPool, self.actionPointer);
    self.actionPool[self.actionPointer]:Redo();
end

--- Start recording an action in the scene.
--- @param type Action.Type The type of action to start.
--- @param ... any arguments for the action.
function Scene:StartAction(type, ...)
    if (type == Actions.Action.Type.TransformObject) then
        self.startedAction = Actions.TransformObject:New(...);
    elseif (type == Actions.Action.Type.DestroyObject) then
        self.startedAction = Actions.DestroyObject:New(...);
    elseif (type == Actions.Action.Type.CreateObject) then
        self.startedAction = Actions.CreateObject:New(...);
    elseif (type == Actions.Action.Type.DestroyTrack) then
        self.startedAction = Actions.DestroyTrack:New(...);
    elseif (type == Actions.Action.Type.CreateTrack) then
        self.startedAction = Actions.CreateTrack:New(...);
    elseif (type == Actions.Action.Type.SceneProperties) then
        self.startedAction = Actions.SceneProperties:New(...);
    elseif (type == Actions.Action.Type.DestroyTimeline) then
        self.startedAction = Actions.DestroyTimeline:New(...);
    elseif (type == Actions.Action.Type.CreateTimeline) then
        self.startedAction = Actions.CreateTimeline:New(...);
    elseif (type == Actions.Action.Type.TimelineProperties) then
        self.startedAction = Actions.TimelineProperties:New(...);
    elseif (type == Actions.Action.Type.TrackAnimations) then
        self.startedAction = Actions.TrackAnimations:New(...);
    elseif (type == Actions.Action.Type.TrackKeyframes) then
        self.startedAction = Actions.TrackKeyframes:New(...);
    elseif (type == Actions.Action.Type.HierarchyChange) then
        self.startedAction = Actions.HierarchyChange:New(...);
    else
        print ("NYI Scene:StartAction() type:" .. type);
    end
end

--- Interrupt current action being recorded
function Scene:CancelAction()
    self.startedAction = nil;
end

--- Finishes recording the current action and updates the action pool.
--- @param ... any The optional arguments to pass to the Finish method of the current action.
function Scene:FinishAction(...)
    if (not self.startedAction) then
        return;
    end

    self.actionPointer = self.actionPointer + 1;
    self.startedAction:Finish(...);
    self.actionPool[self.actionPointer] = self.startedAction;
    self.startedAction = nil;

    -- performing an action has to clear the actionPool after the current action pointer
    for i = #self.actionPool, self.actionPointer + 1, -1 do
        table.remove(self.actionPool, i);
    end
end

--- Clears all actions in the scene.
function Scene:ClearActions()
    for i = 1, #self.actionPool, 1 do
        self.actionPool[i] = nil;
    end

    self.actionPool = {};
    self.startedAction = nil;
    self.actionPointer = 0;
end

--- Retrieves the last saved camera position of the scene.
--- @return table[]: The last saved camera position.
function Scene:GetSavedCameraPosition()
    return self.lastCameraPosition;
end

--- Retrieves the saved camera rotation of the scene.
--- @return table[]: The Euler angles representing the camera rotation.
function Scene:GetSavedCameraRotation()
    return self.lastCameraEuler;
end

--- Saves the camera position in the scene.
--- @param x number The x-coordinate of the camera position.
--- @param y number The y-coordinate of the camera position.
--- @param z number The z-coordinate of the camera position.
function Scene:SaveCameraPosition(x, y, z)
    if (not self.lastCameraPosition) then
        self.lastCameraPosition = {};
    end
    self.lastCameraPosition[1] = x;
    self.lastCameraPosition[2] = y;
    self.lastCameraPosition[3] = z;
end

--- Saves the camera rotation values.
-- @param x The X-axis rotation value.
-- @param y The Y-axis rotation value.
-- @param z The Z-axis rotation value.
function Scene:SaveCameraRotation(x, y, z)
    if (not self.lastCameraEuler) then
        self.lastCameraEuler = {};
    end
    self.lastCameraEuler[1] = x;
    self.lastCameraEuler[2] = y;
    self.lastCameraEuler[3] = z;
end

--- Clears the runtime data of the scene.
--- Is called right before saving the variables to file.
function Scene:ClearRuntimeData()
    self.loaded = nil;
    self.actionPool = nil;
    self.actionPointer = nil;
    self.width = nil;
    self.objectIDMap = nil;
    self.savedWorldPositions = nil;
    self.savedWorldRotations = nil;
    self.savedWorldScales = nil;

    if (self.objects) then
        for o = 1, #self.objects, 1 do
            self.objects[o]:ClearRuntimeData();
        end
    end

    if (self.timelines) then
        for t = 1, #self.timelines, 1 do
            self.timelines[t]:ClearRuntimeData();
        end
    end
end

function Scene:ExportPacked()
    local sceneData = {};
    sceneData.objects = {};
    sceneData.hierarchy = {};
    sceneData.timelines = {};
    sceneData.properties = {};
    
    sceneData.version = Scene.SCENE_DATA_VERSION;
    sceneData.name = self.name;

    -- transfer objects --
    if (#self.objects > 0) then
        for i = 1, #self.objects, 1 do
            sceneData.objects[i] = self.objects[i]:ExportPacked(self.objects[i]);
        end
    end

    -- transfer hierarchy --
    sceneData.hierarchy = Scene.RawCopyObjectHierarchy(self.objectHierarchy);

    -- transfer timelines --
    if (#self.timelines > 0) then
        for i = 1, #self.timelines, 1 do
            local timeline = self.timelines[i];
            sceneData.timelines[i] = timeline:Export();
        end
    end

    -- scene properties
    sceneData.properties = self.properties;

    -- the camera position and rotation
    sceneData.lastCameraPosition = self.lastCameraPosition;
    sceneData.lastCameraEuler = self.lastCameraEuler;

    return sceneData;
end

--- Imports data into the Scene object.
--- @param data? table The data to be imported.
function Scene:ImportData(data)

    if (data == nil) then
        print("Scene:ImportData() data was nil.");
        return;
    end

    self.name = data.name or "Scene";
    self.objects = {};

    for i = 1, #data.objects, 1 do
        local type = data.objects[i].type;

        -- Create actor
        local object;
        local id = 0;
        if (type == SceneMachine.GameObjects.Object.Type.Model) then
            object = SceneMachine.GameObjects.Model:New();
            object:ImportData(data.objects[i]);
            id = object.fileID;
        elseif(type == SceneMachine.GameObjects.Object.Type.Creature) then
            object = SceneMachine.GameObjects.Creature:New();
            object:ImportData(data.objects[i]);
            id = object.displayID;
        elseif(type == SceneMachine.GameObjects.Object.Type.Character) then
            object = SceneMachine.GameObjects.Character:New();
            object:ImportData(data.objects[i]);
            id = -1;
        elseif(type == SceneMachine.GameObjects.Object.Type.Camera) then
            object = SceneMachine.GameObjects.Camera:New();
            object:ImportData(data.objects[i]);
        elseif(type == SceneMachine.GameObjects.Object.Type.Group) then
            object = SceneMachine.GameObjects.Group:New();
            object:ImportData(data.objects[i]);
        else 
            print("Scene:Load() - Unknown object type: " .. type);
        end
        
        if (object) then
            object:SetScene(self);
        end

        if (object:HasActor()) then
            local actor = Renderer.AddActor(id, object.position.x, object.position.y, object.position.z, object.type);
            object:SetActor(actor);

            if (not object.visible) then
                actor:SetAlpha(0);
            end
        end

        self.objects[i] = object;
    end

    self.objectHierarchy = data.objectHierarchy;

    if (#data.timelines > 0) then
        for i in pairs(data.timelines) do
            local timelineData = data.timelines[i];
            local timeline = Timeline:New();
            timeline:ImportData(timelineData);
            timeline.scene = self;
            self.timelines[i] = timeline;
        end
    end

    self.properties = {};

    self.properties.ambientColor = data.properties.ambientColor or { 181/255, 194/255, 203/255, 1 };
    self.properties.diffuseColor = data.properties.diffuseColor or { 217/255, 217/255, 190/255, 1 };
    self.properties.backgroundColor = data.properties.backgroundColor or { 0.554, 0.554, 0.554, 1 };
    self.properties.enableLighting = data.properties.enableLighting;
    if (self.properties.enableLighting == nil) then
        self.properties.enableLighting = true;
    end

    self.lastCameraPosition = data.lastCameraPosition;
    self.lastCameraEuler = data.lastCameraEuler;
end

--- Copies the object hierarchy from the given hierarchy table.
--- @param hierarchy table The table representing the object hierarchy.
--- @return table hierarchy A new table containing the copied object hierarchy.
function Scene.RawCopyObjectHierarchy(hierarchy)
    local copy = {};
    for i = 1, #hierarchy, 1 do
        local hobject = { id = hierarchy[i].id, childObjects = {}, open = hierarchy[i].open, parentID = hierarchy[i].parentID};
        if (#hierarchy[i].childObjects > 0) then
            hobject.childObjects = Scene.RawCopyObjectHierarchy(hierarchy[i].childObjects);
        end
        table.insert(copy, hobject);
    end
    return copy;
end

--- Exports the scene data for copy/pasting into an EditBox.
--- @return string: The encoded scene data for printing.
function Scene:ExportSceneForPrint()
    local sceneData = self:ExportPacked();
    local serialized = SceneMachine.Libs.LibSerialize:Serialize(sceneData);
    local compressed = SceneMachine.Libs.LibDeflate:CompressDeflate(serialized);
    local chatEncoded = SceneMachine.Libs.LibDeflate:EncodeForPrint(compressed);
    return chatEncoded;
end

--- Exports the scene data for sending as a message.
--- @return string: The encoded scene data for the WoW addon channel.
function Scene:ExportSceneForMessage()
    local sceneData = self:ExportPacked();
    local serialized = SceneMachine.Libs.LibSerialize:Serialize(sceneData);
    local compressed = SceneMachine.Libs.LibDeflate:CompressDeflate(serialized);
    local addonChannelEncoded = SceneMachine.Libs.LibDeflate:EncodeForWoWAddonChannel(compressed);
    return addonChannelEncoded;
end

--- Imports a scene from a print-encoded string.
--- @param chatEncoded string The print-encoded string representing the scene data.
function Scene:ImportSceneFromPrint(chatEncoded)
    local decoded = SceneMachine.Libs.LibDeflate:DecodeForPrint(chatEncoded);
    if (not decoded) then print("Failed to decode data."); return end
    local decompressed = SceneMachine.Libs.LibDeflate:DecompressDeflate(decoded);
    if (not decompressed) then print("Failed to decompress data."); return end
    local success, sceneData = SceneMachine.Libs.LibSerialize:Deserialize(decompressed);
    if (not success) then print("Failed to deserialize data."); return end

    if(sceneData.version > Scene.SCENE_DATA_VERSION) then
        -- handle newer version
        print("Newer data version detected, and is unsupported. Please update SceneMachine");
    else
        -- handle known versions
        if (sceneData.version == 1) then
            self:ImportVersion1Scene(sceneData);
        elseif (sceneData.version == 2) then
            self:ImportVersion2Scene(sceneData);
        end
    end
end

--- Imports a version 1 scene from sceneData
--- @param sceneData table The scene data to import
function Scene:ImportVersion1Scene(sceneData)
    self.name = sceneData.name;

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
                self.objects[i] = object;
            end
        end
    end

    if (#sceneData.timelines > 0) then
        for i = 1, #sceneData.timelines, 1 do
            local timelineData = sceneData.timelines[i];
            local timeline = Timeline:New();
            timeline:ImportData(timelineData);
            timeline.scene = self;
            self.timelines[i] = timeline;
        end
    end

    -- Sets the scene properties
    self.properties = sceneData.properties;

    -- Sets the last camera position and rotation
    self.lastCameraPosition = sceneData.lastCameraPosition;
    self.lastCameraEuler = sceneData.lastCameraEuler;
end

--- Imports a version 2 scene from sceneData.
--- @param sceneData table The scene data to import.
function Scene:ImportVersion2Scene(sceneData)
    self.name = sceneData.name;

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
                self.objects[i] = object;
            end
        end
    end

    if (sceneData.hierarchy) then
        self.objectHierarchy = sceneData.hierarchy;
    end

    if (#sceneData.timelines > 0) then
        for i = 1, #sceneData.timelines, 1 do
            local timelineData = sceneData.timelines[i];
            local timeline = Timeline:New();
            timeline:ImportData(timelineData);
            timeline.scene = self;
            self.timelines[i] = timeline;
        end
    end

    -- Sets the scene properties.
    self.properties = sceneData.properties;

    -- Sets the camera position and rotation.
    self.lastCameraPosition = sceneData.lastCameraPosition;
    self.lastCameraEuler = sceneData.lastCameraEuler;
end

--- Imports a network scene into the current scene.
--- @param sceneData table The data of the scene to import.
function Scene:ImportNetworkScene(sceneData)
    self.name = sceneData.name;

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
                self.objects[i] = object;
            end
        end
    end

    if (#sceneData.timelines > 0) then
        for i = 1, #sceneData.timelines, 1 do
            local timelineData = sceneData.timelines[i];
            local timeline = Timeline:New();
            timeline:ImportData(timelineData);
            timeline.scene = self;
            self.timelines[i] = timeline;
        end
    end

    -- Sets the scene properties.
    self.properties = sceneData.properties;

    -- Sets the last camera position and rotation.
    self.lastCameraPosition = sceneData.lastCameraPosition;
    self.lastCameraEuler = sceneData.lastCameraEuler
end

--- Returns a string representation of the Scene object.
--- @return string The string representation of the Scene object.
Scene.__tostring = function(self)
    return string.format("Scene: %s %i Objects %i Timelines", self.name, #self.objects, #self.timelines);
end

-- This function is used as the __index metamethod for the Scene table.
-- It is responsible for handling the indexing of Scene objects.
Scene.__index = function(t,k)
    local var = rawget(Scene, k)
        
    if var == nil then							
        var = rawget(fields, k)
        
        if var ~= nil then
            return var(t)	
        end
    end
    
    return var
end