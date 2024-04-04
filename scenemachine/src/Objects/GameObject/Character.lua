
SceneMachine.GameObjects.Character = {};

local Vector3 = SceneMachine.Vector3;
local Object = SceneMachine.GameObjects.Object;
local Actor = SceneMachine.GameObjects.Actor;

--- @class Character : Actor
local Character = SceneMachine.GameObjects.Character;

Character.__index = Character;
setmetatable(Character, Actor)

--- Creates a new Character object.
--- @param scene Scene The scene the character belongs to.
--- @param name string? (optional) The name of the character.
--- @param position Vector3? (optional) The position of the character.
--- @param rotation Vector3? (optional) The rotation of the character.
--- @param scale number? (optional) The scale of the character.
--- @return Character: The newly created Character object.
function Character:New(scene, name, position, rotation, scale)
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
        id = math.random(99999999),
        visible = true,
        frozen = false,
        isRenamed = false,
        scene = scene,
        type = Object.Type.Character,
    };

    setmetatable(v, Character)
    return v
end