
SceneMachine.GameObjects.Creature = {};

local Vector3 = SceneMachine.Vector3;
local Object = SceneMachine.GameObjects.Object;
local Actor = SceneMachine.GameObjects.Actor;

--- @class Creature : Actor
local Creature = SceneMachine.GameObjects.Creature;

Creature.__index = Creature;
setmetatable(Creature, Actor)

--- Creates a new instance of the Creature class.
--- @param name string? (optional) The name of the creature.
--- @param displayID number? (optional) The display ID of the creature.
--- @param position Vector3? (optional) The position of the creature.
--- @param rotation Vector3? (optional) The rotation of the creature.
--- @param scale number? (optional) The scale of the creature.
--- @return Creature v The newly created Creature instance.
function Creature:New(name, displayID, position, rotation, scale)
    local v = 
    {
        fileID = 0,
        displayID = displayID or 0,
        name = name or "NewObject",
        position = position or Vector3:New(),
        rotation = rotation or Vector3:New(),
        scale = scale or 1,
        alpha = 1,
        desaturation = 0,
        actor = nil,
        id = math.random(99999999),
        visible = true,
        frozen = false,
        isRenamed = false,
        type = Object.Type.Creature,
    };

    setmetatable(v, Creature)
    return v
end

--- Retrieves the displayID of the creature.
--- @return number displayID The display ID of the creature.
function Creature:GetDisplayID()
    return self.displayID;
end