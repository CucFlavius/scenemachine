
SceneMachine.GameObjects.Actor = {};

local Object = SceneMachine.GameObjects.Object;
local Actor = SceneMachine.GameObjects.Actor;

Actor.__index = Actor;
setmetatable(Actor, Object)

function Actor:GetFileID()
    return self.fileID;
end

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

function Actor:GetActor()
    return self.actor;
end

function Actor:HasActor()
    return true;
end

function Actor:GetActiveBoundingBox()
    local xMin, yMin, zMin, xMax, yMax, zMax = self.actor:GetActiveBoundingBox();

    if (xMin == nil or yMin == nil or zMin == nil) then
        xMin, yMin, zMin, xMax, yMax, zMax = -1, -1, -1, 1, 1, 1;
    end

    return xMin, yMin, zMin, xMax, yMax, zMax;
end

function Actor:SetAlpha(alpha)
    self.alpha = alpha;
    self.actor:SetAlpha(alpha);
end

function Actor:GetAlpha()
    return self.alpha;
end

function Actor:SetDesaturation(desaturation)
    self.desaturation = desaturation;
    self.actor:SetDesaturation(desaturation);
end

function Actor:GetDesaturation()
    return self.desaturation;
end


function Actor:PlayAnimID(id, variation)
    self.actor:SetAnimation(id, variation);
end

function Actor:PlayAnimKitID(id)
    self.actor:PlayAnimationKit(id);
end

function Actor:SetSpellVisualKitID(id, oneShot)
    self.actor:SetSpellVisualKit(id, oneShot);
    self.spellVisualKitID = id;
end

function Actor:ClearSpellVisualKits()
    self:SetSpellVisualKitID(0);
    --[[
    self:SetSpellVisualKitID(-1);

    if (self.type == Object.Type.Model) then
        self.actor:SetModelByFileID(self.fileID);
    elseif (self.type == Object.Type.Creature) then
        self.actor:SetModelByCreatureDisplayID(self.displayID);
    elseif (self.type == Object.Type.Character) then
        self.actor:SetModelByUnit("player");
    end
    --]]
    self.spellVisualKitID = nil;
end

function Actor:Select()
    if (not self.selected) then
        self:SetSpellVisualKitID(70682);
        self.selected = true;
    end
end

function Actor:Deselect()
    if (self.selected) then
        self:ClearSpellVisualKits();
        self.selected = false;
    end
end

function Actor:GetFileName(fileID)
    return self:GetFileNameRecursive(fileID, SceneMachine.modelData[1]);
end

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