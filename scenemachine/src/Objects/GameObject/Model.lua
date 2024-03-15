
SceneMachine.GameObjects.Model = {};

local Vector3 = SceneMachine.Vector3;
local Object = SceneMachine.GameObjects.Object;
local Actor = SceneMachine.GameObjects.Actor;
local Model = SceneMachine.GameObjects.Model;
local Gizmos = SceneMachine.Gizmos;

Model.__index = Model;
setmetatable(Model, Actor)

function Model:New(name, fileID, position, rotation, scale)
    local v = 
    {
        fileID = fileID or 0,
        name = name or "NewModel",
        position = position or Vector3:New(),
        rotation = rotation or Vector3:New(),
        scale = scale or 1,
        alpha = 1,
        desaturation = 0,
        actor = nil,
        id = math.random(99999999);
        visible = true,
        frozen = false, -- could check here if path is skybox and freeze automagically
        isRenamed = false,
        type = Object.Type.Model,
    };

	setmetatable(v, Model)
	return v
end