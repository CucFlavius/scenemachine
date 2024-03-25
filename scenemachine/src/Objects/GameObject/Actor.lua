
SceneMachine.GameObjects.Actor = {};

local Object = SceneMachine.GameObjects.Object;

--- @class Actor : Object
local Actor = SceneMachine.GameObjects.Actor;

Actor.__index = Actor;
setmetatable(Actor, Object)

--- Retrieves the fileID of the actor.
--- @return number fileID The fileID of the actor.
function Actor:GetFileID()
    return self.fileID;
end

--- Sets the actor for the GameObject.
--- @param actor table The actor to set.
function Actor:SetActor(actor)
    self.actor = actor;

    -- also set all properties
    local s = 1.0;
    if (type(self.scale) == "number") then
        s = self.scale;
    end

    self.actor:SetPosition(self.position.x / s, self.position.y / s, self.position.z / s);
    self.actor:SetRoll(self.rotation.x);
    self.actor:SetPitch(self.rotation.y);
    self.actor:SetYaw(self.rotation.z);
    self.actor:SetAlpha(self.alpha);
    self.actor:SetDesaturation(self.desaturation);
    self.actor:SetScale(s);
end

--- Retrieves the actor associated with this game object.
--- @return table actor The actor associated with this game object.
function Actor:GetActor()
    return self.actor;
end

--- Checks if the object has an actor.
--- @return boolean: True if the object has an actor, false otherwise.
function Actor:HasActor()
    return true;
end

--- Returns the active bounding box of the actor.
--- If the active bounding box is not available, a default bounding box of (-1, -1, -1, 1, 1, 1) is returned.
function Actor:GetActiveBoundingBox()
    local xMin, yMin, zMin, xMax, yMax, zMax = self.actor:GetActiveBoundingBox();

    if (xMin == nil or yMin == nil or zMin == nil) then
        xMin, yMin, zMin, xMax, yMax, zMax = -1, -1, -1, 1, 1, 1;
    end

    return xMin, yMin, zMin, xMax, yMax, zMax;
end

--- Sets the alpha value of the actor.
--- @param alpha number The new alpha value.
function Actor:SetAlpha(alpha)
    self.alpha = alpha;
    self.actor:SetAlpha(alpha);
end

--- Gets the alpha value of the actor.
--- @return number alpha The alpha value of the actor.
function Actor:GetAlpha()
    return self.alpha;
end

--- Sets the desaturation value for the actor.
--- Desaturation is a value between 0 and 1.
--- 0 means colored, 1 means grayscale.
--- @param desaturation number The desaturation value to set.
function Actor:SetDesaturation(desaturation)
    self.desaturation = desaturation;
    self.actor:SetDesaturation(desaturation);
end

--- Retrieves the desaturation value of the actor.
--- @return number desaturation The desaturation value.
function Actor:GetDesaturation()
    return self.desaturation;
end

--- Plays the animation with the specified ID and variation.
--- @param id number The ID of the animation to play.
--- @param variation? number (optional) The variation of the animation to play.
function Actor:PlayAnimID(id, variation)
    self.actor:SetAnimation(id, variation);
end

--- Plays an animation kit with the specified ID.
--- @param id number The ID of the animation kit to play.
function Actor:PlayAnimKitID(id)
    self.actor:PlayAnimationKit(id);
end

--- Sets the Spell Visual Kit ID for the actor.
--- @param id number The ID of the Spell Visual Kit.
--- @param oneShot boolean? (optional) Whether the Spell Visual Kit should be played as a one-shot effect.
function Actor:SetSpellVisualKitID(id, oneShot)
    self.actor:SetSpellVisualKit(id, oneShot);
    self.spellVisualKitID = id;
end

--- Clears the spell visual kits for the actor.
function Actor:ClearSpellVisualKits()
    self:SetSpellVisualKitID(0);
    self.spellVisualKitID = nil;
end

--- Selects the actor.
function Actor:Select()
    if (not self.selected) then
        self:SetSpellVisualKitID(70682);
        self.selected = true;
    end
end

--- Deselects the actor.
function Actor:Deselect()
    if (self.selected) then
        self:ClearSpellVisualKits();
        self.selected = false;
    end
end

--- Retrieves the file name associated with the given fileID.
--- @param fileID number The ID of the file.
--- @return string? The file name.
function Actor:GetFileName(fileID)
    return self:GetFileNameRecursive(fileID, SceneMachine.modelData[1]);
end

--- Retrieves the file name recursively from the given directory structure.
--- @param value number The fileID to search for.
--- @param dir table The directory structure to search in.
--- @return string? fileName The file name if found, nil otherwise.
function Actor:GetFileNameRecursive(value, dir)
    -- File Scan
    if (not dir) then return nil; end

    if (dir["FN"] ~= nil) then
        local fileCount = #dir["FN"];
        for i = 1, fileCount, 1 do
            local fileID = dir["FI"][i];
            if (fileID == value) then
                local fileName = dir["FN"][i];
                return fileName;
            end
        end
    end

    -- Directory scan
    if (dir["D"] ~= nil) then
        local directoryCount = #dir["D"];
        for i = 1, directoryCount, 1 do
            local n = self:GetFileNameRecursive(value, dir["D"][i]);
            if (n) then return n; end
        end
    end

    return nil;
end