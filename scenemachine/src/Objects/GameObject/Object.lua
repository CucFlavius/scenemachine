local Vector3 = SceneMachine.Vector3;
local Matrix = SceneMachine.Matrix;
local Quaternion = SceneMachine.Quaternion;
local Gizmos = SceneMachine.Gizmos;
local SH = SceneMachine.Editor.SceneHierarchy;

SceneMachine.GameObjects.Object = {}

--- @class Object
local Object = SceneMachine.GameObjects.Object;

--- @enum Object.Type
Object.Type = {
    Group = 0,
    Model = 1,
    Creature = 2,
    Character = 3,
    Camera = 4
};

Object.TypeNames = {
    [Object.Type.Group] = "Group",
    [Object.Type.Model] = "Model",
    [Object.Type.Creature] = "Creature",
    [Object.Type.Character] = "Character",
    [Object.Type.Camera] = "Camera",
};

setmetatable(Object, Object);

local fields = {}

--- Gets the type of the object.
--- @return Object.Type type The type of the object.
function Object:GetType()
    return self.type;
end

--- Retrieves the name of the object's type.
--- @return string typeName The name of the object's type.
function Object:GetTypeName()
    return Object.TypeNames[self.type];
end

--- Gets the name of the object.
---@return string name The name of the object.
function Object:GetName()
    return self.name;
end

--- Checks if the object has an actor.
--- @return boolean: True if the object has an actor, false otherwise.
function Object:HasActor()
    return false;
end

--- Returns the gizmo type for the object.
--- @return Gizmos.Type gizmoType The gizmo type.
function Object:GetGizmoType()
    return Gizmos.Type.Object;
end

--- Recalculates the position, rotation, and scale of the object's associated actor.
--- And travels the hierarchy to recalculate the actors of all child objects.
function Object:RecalculateActors()
    -- apply to actor
    if (self:HasActor()) then
        local wPos, rot, scale = self.matrix:Decompose();

        self.actor:SetPosition(wPos.x / scale, wPos.y / scale, wPos.z / scale);
        local rotE = rot:ToEuler();
        self.actor:SetRoll(rotE.x);
        self.actor:SetPitch(rotE.y);
        self.actor:SetYaw(rotE.z);
        self.actor:SetScale(scale);
    end

    local childObjects = SH.GetChildObjects(self.id);
    if (childObjects ~= nil) then
        for i = 1, #childObjects do
            childObjects[i]:RecalculateActors();
        end
    end
end

-- Recalculates the world matrices for the object and its child objects.
function Object:RecalculateWorldMatrices()
    self.matrix = self:CreateWorldMatrix();

    local childObjects = SH.GetChildObjects(self.id);
    if (childObjects ~= nil) then
        for i = 1, #childObjects, 1 do
            childObjects[i]:RecalculateWorldMatrices();
        end
    end
end

--- Sets the local space position of the object using a Vector3.
--- @param pos Vector3 The position to set.
function Object:SetPositionVector3(pos)
    self:SetPosition(pos.x, pos.y, pos.z);
end

--- Sets the local space position of the object in 3D space.
--- @param x number The x-coordinate of the position.
--- @param y number The y-coordinate of the position.
--- @param z number The z-coordinate of the position.
function Object:SetPosition(x, y, z)
    self.position:Set(x, y, z);

    self:RecalculateWorldMatrices();
    self:RecalculateActors();
end

--- Sets the world space position of the object.
--- @param x number The x-coordinate of the position.
--- @param y number The y-coordinate of the position.
--- @param z number The z-coordinate of the position.
function Object:SetWorldPosition(x, y, z)
    local parent = SH.GetParentObject(self.id);
    if (not parent) then
        self:SetPosition(x, y, z);
    else
        local parentMatrix = parent:CreateWorldMatrix();
        parentMatrix:Invert();
        local pos = Vector3:New(x, y, z);
        local transMatrix = Matrix:New();
        transMatrix:SetIdentity();
        transMatrix:Translate(pos);
        transMatrix:Multiply(parentMatrix);
        local localPos = transMatrix:ExtractPosition();
        self:SetPosition(localPos.x, localPos.y, localPos.z);
    end
end

--- Gets the local space position of the object.
--- @return Vector3 localPosition The position of the object.
function Object:GetPosition()
    return Vector3:New(self.position.x, self.position.y, self.position.z);
end

--- Retrieves the world space position of the object.
--- @return Vector3 worldPosition The world position of the object.
function Object:GetWorldPosition()
    if (not self.matrix) then
        self.matrix = self:CreateWorldMatrix();
    end

    return self.matrix:ExtractPosition();
end

--- Sets the local space rotation of the object.
--- Clamps the rotation values between -1000000 and 1000000.
--- @param x number The rotation value along the x-axis.
--- @param y number The rotation value along the y-axis.
--- @param z number The rotation value along the z-axis.
function Object:SetRotation(x, y, z)
    x = math.max(-1000000, math.min(1000000, x));
    y = math.max(-1000000, math.min(1000000, y));
    z = math.max(-1000000, math.min(1000000, z));

    self.rotation:Set(x, y, z);

    self:RecalculateWorldMatrices();
    self:RecalculateActors();
end

--- Sets the world space rotation of the object.
--- If the object has a parent, the rotation is applied relative to the parent's rotation.
--- If the object does not have a parent, the rotation is applied directly to the object in local space.
--- @param x number: The rotation around the x-axis in degrees.
--- @param y number: The rotation around the y-axis in degrees.
--- @param z number: The rotation around the z-axis in degrees.
function Object:SetWorldRotation(x, y, z)
    local parent = SH.GetParentObject(self.id);
    if (not parent) then
        self:SetRotation(x, y, z);
    else
        local parentMatrix = parent:CreateWorldMatrix();
        parentMatrix:Invert();
        local rot = Quaternion:New();
        rot:SetFromEuler(Vector3:New(x, y, z));
        local rotMatrix = Matrix:New();
        rotMatrix:SetIdentity();
        rotMatrix:RotateQuaternion(rot);
        rotMatrix:Multiply(parentMatrix);
        local localRotQ = rotMatrix:ExtractRotation();
        local localRot = localRotQ:ToEuler();
        self:SetRotation(localRot.x, localRot.y, localRot.z);
    end
end

--- Retrieves the local space rotation of the object.
--- @return Vector3 localRotation The rotation of the object.
function Object:GetRotation()
    return Vector3:New(self.rotation.x, self.rotation.y, self.rotation.z);
end

--- Retrieves the world space rotation of the object.
--- @return Quaternion worldRotation The world rotation of the object.
function Object:GetWorldRotation()
    if (not self.matrix) then
        self.matrix = self:CreateWorldMatrix();
    end

    local qRot = self.matrix:ExtractRotation();
    return qRot:ToEuler();
end

--- Sets the scale of the object.
--- @param value number The scale value to set.
function Object:SetScale(value)
    self.scale = value;

    self:RecalculateWorldMatrices();
    self:RecalculateActors();
end

--- Sets the world space scale of the object.
--- If the object has a parent, the scale is applied relative to the parent's scale.
--- If the object does not have a parent, the scale is applied directly to the object in local space.
--- @param value number The scale value to set.
function Object:SetWorldScale(value)
    local parent = SH.GetParentObject(self.id);
    if (not parent) then
        self:SetScale(value);
    else
        local parentMatrix = parent:CreateWorldMatrix();
        parentMatrix:Invert();
        local scaleMatrix = Matrix:New();
        scaleMatrix:SetIdentity();
        scaleMatrix:Scale(Vector3:New(value, value, value));
        scaleMatrix:Multiply(parentMatrix);
        local localScale = scaleMatrix:ExtractScale();
        self:SetScale(localScale);
    end
end

--- Retrieves the local space scale of the object.
--- @return number localScale The scale of the object.
function Object:GetScale()
    return self.scale;
end

--- Retrieves the world space scale of the object.
--- @return number worldScale The world scale of the object.
function Object:GetWorldScale()
    if (not self.matrix) then
        self.matrix = self:CreateWorldMatrix();
    end
    
    return self.matrix:ExtractScale();
end

--- Returns a Vector3 representing the local scale of the object in all three dimensions.
--- Because the object's scale is uniform, only one value is used for all 3 componets.
--- @return Vector3 localScaleVec The scale of the object as a Vector3.
function Object:GetVector3Scale()
    local s = self:GetScale();
    return Vector3:New(s, s, s);
end

--- Retrieves the quaternion local space rotation of the object.
--- @return Quaternion localRotationQuaternion The quaternion rotation of the object.
function Object:GetQuaternionRotation()
    local qRotation = Quaternion:New();
    qRotation:SetFromEuler(self:GetRotation());
    return qRotation;
end

--- Creates the world matrix for the object.
--- @return Matrix worldMatrix The world matrix of the object.
function Object:CreateWorldMatrix()
    local localMatrix = Matrix:New();
    localMatrix:SetIdentity();

    local scaleMatrix = Matrix:New();
    scaleMatrix:SetIdentity();
    scaleMatrix:Scale(self:GetVector3Scale());

    local rotationMatrix = Matrix:New();
    rotationMatrix:SetIdentity();
    rotationMatrix:RotateQuaternion(self:GetQuaternionRotation());

    local translationMatrix = Matrix:New();
    translationMatrix:SetIdentity();
    translationMatrix:Translate(self:GetPosition());

    localMatrix:Multiply(scaleMatrix);
    localMatrix:Multiply(rotationMatrix);
    localMatrix:Multiply(translationMatrix);

    local worldMatrix = Matrix:New();
    worldMatrix:SetMatrix(localMatrix);
    
    local parent = SH.GetParentObject(self.id);
    if (parent) then
        local parentMatrix = parent:CreateWorldMatrix();
        worldMatrix:Multiply(parentMatrix);
    end

    return worldMatrix;
end

--- Toggles the visibility of the object.
function Object:ToggleVisibility()
    self.visible = not self.visible;
    if (self.visible) then
        self:Show();
    else
        self:Hide();
    end
end

--- Shows the object.
function Object:Show()
    --self.actor:Show();
    self.visible = true;
    if (self:HasActor()) then
        self.actor:SetAlpha(self.alpha or 1);
    end
end

--- Hides the object.
function Object:Hide()
    --self.actor:Hide();
    self.visible = false;
    if (self:HasActor()) then
        self.actor:SetAlpha(0);
    end
end

--- Checks if the object is hidden.
--- @return boolean: True if the object is hidden, false otherwise.
function Object:IsHidden()
    return not self.visible;
end

--- Checks if the object is visible.
--- @return boolean: True if the object is visible, false otherwise.
function Object:IsVisible()
    return self.visible;
end

--- Toggles the frozen state of the object.
function Object:ToggleFrozen()
    self.frozen = not self.frozen;
end

--- Checks if the object is frozen.
--- @return boolean: True if the object is frozen, false otherwise.
function Object:IsFrozen()
    return self.frozen;
end

--- Freezes the object.
--- Makes it unselectable in the scene viewport.
function Object:Freeze()
    self.frozen = true;
end

--- Unfreezes the object.
--- Makes it selectable in the scene viewport.
function Object:Unfreeze()
    self.frozen = false;
end

--- Renames the object.
--- @param newName string The new name for the object.
function Object:Rename(newName)
    self.isRenamed = true;
    self.name = newName;
end

--- Packs the rotation values of a given rotation vector into the range of 0 to 360 degrees.
--- @param rotation Vector3 The rotation vector to be packed (in radians).
--- @return number rotX, number rotY, number rotZ The packed rotation values for each axis (rotX, rotY, rotZ).
function Object:PackRotation(rotation)
    -- packing to 0, 360 range
    local rotX = math.floor(math.deg(rotation.x) + 180);
    local rotY = math.floor(math.deg(rotation.y) + 180);
    local rotZ = math.floor(math.deg(rotation.z) + 180);
    return rotX, rotY, rotZ;
end

--- Unpacks rotation values from degrees to radians.
--- @param X number The X rotation value in degrees.
--- @param Y number The Y rotation value in degrees.
--- @param Z number The Z rotation value in degrees.
--- @return number rotX, number rotY, number rotZ The unpacked rotation values in radians.
function Object:UnpackRotation(X, Y, Z)
    local rotX = math.rad(X - 180);
    local rotY = math.rad(Y - 180);
    local rotZ = math.rad(Z - 180);
    return rotX, rotY, rotZ;
end

--- ExportPacked function exports the object's properties as a packed table.
--- @return table: The packed table containing the object's properties.
function Object:ExportPacked()
    local name = nil;
    if (self.isRenamed) then
        name = self.name;
    end

    return {
        self.type,
        self.id,
        self.fileID,
        self.displayID,
        name,
        self.position.x, self.position.y, self.position.z,
        self.rotation.x, self.rotation.y, self.rotation.z,
        self.scale,
        self.visible,
        self.frozen,
        self.alpha,
        self.desaturation,
    }
end

--- Exports the object data as a table.
--- @return table data The exported object data.
function Object:Export()
    local data = {
        fileID = self.fileID,
        displayID = self.displayID,
        type = self.type,
        name = self.name,
        position = self.position:Export(),
        rotation = self.rotation:Export(),
        scale = self.scale,
        id = self.id,
        visible = self.visible,
        frozen = self.frozen,
        alpha = self.alpha,
        desaturation = self.desaturation,
        isRenamed = self.isRenamed,
        fov = self.fov,
        nearClip = self.nearClip,
        farClip = self.farClip,
        minX = self.minX,
        minY = self.minY,
        minZ = self.minZ,
        maxX = self.maxX,
        maxY = self.maxY,
        maxZ = self.maxZ,
    };

    return data;
end

--- Gets the file name associated with the object.
--- Overriden in child classes.
--- @return string|nil The file name, or nil if it is not available.
function Object:GetFileName(_)
    return nil;
end

--- Imports packed data into the Object instance.
--- Imports version 1 data, for backwards compatibility.
--- @param data table The packed data to import.
function Object:ImportPackedV1(data)
    if (data == nil) then
        print("Object:ImportPacked() data was nil.");
        return;
    end

    -- verifying all elements upon import because sometimes the saved variables get corrupted --
    if (data[1] ~= nil) then
        self.fileID = data[1];
    end

    if (data[2] ~= nil) then
        self.displayID = data[2];
    else
        self.displayID = 0;
    end

    if (data[3] ~= nil) then
        self.type = data[3];
    else
        self.type = Object.Type.Model;
    end

    if (data[4] ~= nil and data[4] ~= "") then
        self.name = data[4];
        self.isRenamed = true;
    else
        -- fetch name from displayID
        if (self.type == Object.Type.Creature and self.displayID ~= 0) then
            local found = false;
            for creatureID, displayID in pairs(SceneMachine.creatureToDisplayID) do
                if (displayID == self.displayID) then
                    self.name = SceneMachine.creatureData[creatureID];
                end
            end
        end

        -- fetch name from fileID
        if (self.type == Object.Type.Model and self.fileID ~= 0) then
            self.name = self:GetFileName(self.fileID);
        end

        self.isRenamed = false;
    end

    if (data[5] ~= nil and data[6] ~= nil and data[7] ~= nil) then
        self.position = Vector3:New(data[5], data[6], data[7]);
    end

    if (data[8] ~= nil and data[9] ~= nil and data[10] ~= nil) then
        --self.rotation = Vector3:New(self:UnpackRotation(data[8], data[9], data[10]));
        self.rotation = Vector3:New(data[8], data[9], data[10]);
    end

    if (data[11] ~= nil and data[11] ~= 0) then
        self.scale = data[11];
    end
    
    self.id = data[12] or math.random(99999999);

    if (data[13] ~= nil) then
        self.visible = data[13];
    else
        self.visible = true;
    end
    
    if (data[14] ~= nil) then
        self.frozen = data[14];
    else
        self.frozen = false;
    end

    if(data[15] ~= nil) then
        self.alpha = data[15];
    else
        self.alpha = 1.0;
    end

    if(data[16] ~= nil) then
        self.desaturation = data[16];
    else
        self.desaturation = 0.0;
    end
end

--- Imports packed data into the Object instance.
--- Imports the current version data
--- @param data table The packed data to import.
function Object:ImportPacked(data)
    if (data == nil) then
        print("Object:ImportPacked() data was nil.");
        return;
    end

    -- verifying all elements upon import because sometimes the saved variables get corrupted --
    self.type = data[1] or Object.Type.Model;
    self.id = data[2] or math.random(99999999);
    self.fileID = data[3] or 0;
    self.displayID = data[4] or 0;

    if (data[5] ~= nil and data[5] ~= "") then
        self.name = data[5];
        self.isRenamed = true;
    else
        -- fetch name from displayID
        if (self.type == Object.Type.Creature and self.displayID ~= 0) then
            local found = false;
            for creatureID, displayID in pairs(SceneMachine.creatureToDisplayID) do
                if (displayID == self.displayID) then
                    self.name = SceneMachine.creatureData[creatureID];
                end
            end
        end

        -- fetch name from fileID
        if (self.type == Object.Type.Model and self.fileID ~= 0) then
            self.name = self:GetFileName(self.fileID);
        end

        self.isRenamed = false;
    end

    if (data[6] ~= nil and data[7] ~= nil and data[8] ~= nil) then
        self.position = Vector3:New(data[6], data[7], data[8]);
    end

    if (data[9] ~= nil and data[10] ~= nil and data[11] ~= nil) then
        --self.rotation = Vector3:New(self:UnpackRotation(data[8], data[9], data[10]));
        self.rotation = Vector3:New(data[9], data[10], data[11]);
    end

    self.scale = data[12] or 1;

    if (data[13] ~= nil) then
        self.visible = data[13];
    else
        self.visible = true;
    end
    
    if (data[14] ~= nil) then
        self.frozen = data[14];
    else
        self.frozen = false;
    end

    if(data[15] ~= nil) then
        self.alpha = data[15];
    else
        self.alpha = 1.0;
    end

    if(data[16] ~= nil) then
        self.desaturation = data[16];
    else
        self.desaturation = 0.0;
    end
end

--- Imports data into the Object instance.
--- @param data table The data to import.
function Object:ImportData(data)
    if (data == nil) then
        print("Object:ImportData() data was nil.");
        return;
    end

    -- verifying all elements upon import because sometimes the saved variables get corrupted --

    -- Import fileID if it exists in the data.
    if (data.fileID ~= nil) then
        self.fileID = data.fileID;
    end

    -- Import displayID if it exists in the data, otherwise set it to 0.
    if (data.displayID ~= nil) then
        self.displayID = data.displayID;
    else
        self.displayID = 0;
    end

    -- Import type if it exists in the data, otherwise set it to Object.Type.Model.
    if (data.type ~= nil) then
        self.type = data.type;
    else
        self.type = Object.Type.Model;
    end

    -- Import name if it exists in the data.
    if (data.name ~= nil and data.name ~= "") then
        self.name = data.name;
    end

    -- Import position if it exists in the data.
    if (data.position ~= nil) then
        self.position = Vector3:New(data.position.x, data.position.y, data.position.z);
    end

    -- Import rotation if it exists in the data.
    if (data.rotation ~= nil) then
        self.rotation = Vector3:New(data.rotation.x, data.rotation.y, data.rotation.z);
    end

    -- Import scale if it exists in the data and is not 0.
    if (data.scale ~= nil and data.scale ~= 0) then
        self.scale = data.scale;
    end
    
    -- Import visible if it exists in the data, otherwise set it to true.
    if (data.visible ~= nil) then
        self.visible = data.visible;
    else
        self.visible = true;
    end
    
    -- Import frozen if it exists in the data, otherwise set it to false.
    if (data.frozen ~= nil) then
        self.frozen = data.frozen;
    else
        self.frozen = false;
    end

    -- Import alpha if it exists in the data, otherwise set it to 1.0.
    if(data.alpha ~= nil) then
        self.alpha = data.alpha;
    else
        self.alpha = 1.0;
    end

    -- Import desaturation if it exists in the data, otherwise set it to 0.0.
    if(data.desaturation ~= nil) then
        self.desaturation = data.desaturation;
    else
        self.desaturation = 0.0;
    end

    -- Import isRenamed if it exists in the data.
    if (data.isRenamed ~= nil) then
        self.isRenamed = data.isRenamed;
    end

    -- Import fov if it exists in the data.
    if (data.fov ~= nil) then
        self.fov = data.fov;
    end

    -- Import nearClip if it exists in the data.
    if (data.nearClip ~= nil) then
        self.nearClip = data.nearClip;
    end

    -- Import farClip if it exists in the data.
    if (data.farClip ~= nil) then
        self.farClip = data.farClip;
    end

    if (data.minX ~= nil) then
        self.minX = data.minX;
    end

    if (data.minY ~= nil) then
        self.minY = data.minY;
    end

    if (data.minZ ~= nil) then
        self.minZ = data.minZ;
    end

    if (data.maxX ~= nil) then
        self.maxX = data.maxX;
    end

    if (data.maxY ~= nil) then
        self.maxY = data.maxY;
    end

    if (data.maxZ ~= nil) then
        self.maxZ = data.maxZ;
    end

    -- Generate a random id if data.id is nil.
    self.id = data.id or math.random(99999999);
end

--- Selects the object.
function Object:Select()
    print("Select() not implemented for type " .. self:GetTypeName());
end

--- Deselects the object.
function Object:Deselect()
    print("Deselect() not implemented for type " .. self:GetTypeName());
end

--- Returns a string representation of the Object.
--- @return string string The string representation of the Object.
Object.__tostring = function(self)
    return string.format("%s %i p(%f,%f,%f)", self.name, self.fileID, self.position.x, self.position.y, self.position.z);
end

--- Compares two objects for equality based on their IDs.
--- @param a Object The first object to compare.
--- @param b Object The second object to compare.
--- @return boolean: True if the objects have the same ID, false otherwise.
Object.__eq = function(a,b)
    return a.id == b.id;
end

-- This function is used as the __index metamethod for the Object table.
-- It is called when a key is not found in the Object table.
Object.__index = function(t,k)
	local var = rawget(Object, k)
		
	if var == nil then							
		var = rawget(fields, k)
		
		if var ~= nil then
			return var(t)	
		end
	end
	
	return var
end