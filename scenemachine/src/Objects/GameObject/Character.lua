
SceneMachine.GameObjects.Character = {};

local Vector3 = SceneMachine.Vector3;
local Object = SceneMachine.GameObjects.Object;
local Actor = SceneMachine.GameObjects.Actor;
local Character = SceneMachine.GameObjects.Character;
local Gizmos = SceneMachine.Gizmos;

Character.__index = Character;
setmetatable(Character, Actor)

function Character:New(name, position, rotation, scale)
	local v = 
    {
        fileID = -1,
        displayID = -1,
        name = name or "Character",
        position = position or Vector3:New(),
        rotation = rotation or Vector3:New(),
        scale = scale or 1,	
        alpha = 1,
        desaturation = 0,
        actor = nil,
        class = "Object",
        id = math.random(99999999);
        visible = true,
        frozen = false,
        isRenamed = false,
        type = Object.Type.Character,
    };

	setmetatable(v, Character)
	return v
end