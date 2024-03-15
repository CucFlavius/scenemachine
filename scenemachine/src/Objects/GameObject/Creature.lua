
SceneMachine.GameObjects.Creature = {};

local Vector3 = SceneMachine.Vector3;
local Object = SceneMachine.GameObjects.Object;
local Actor = SceneMachine.GameObjects.Actor;
local Creature = SceneMachine.GameObjects.Creature;
local Gizmos = SceneMachine.Gizmos;

Creature.__index = Creature;
setmetatable(Creature, Actor)

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
        id = math.random(99999999);
        visible = true,
        frozen = false,
        isRenamed = false,
        type = Object.Type.Creature,
    };

	setmetatable(v, Creature)
	return v
end

function Creature:GetDisplayID()
    return self.displayID;
end