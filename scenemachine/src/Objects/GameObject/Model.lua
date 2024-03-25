
SceneMachine.GameObjects.Model = {};

local Vector3 = SceneMachine.Vector3;
local Object = SceneMachine.GameObjects.Object;
local Actor = SceneMachine.GameObjects.Actor;

--- @class Model : Actor
local Model = SceneMachine.GameObjects.Model;

Model.__index = Model;
setmetatable(Model, Actor)

--- Creates a new instance of the Model class.
--- @param name string? (optional) The name of the model. Defaults to "NewModel".
--- @param fileID number? (optional) The file ID of the model.
--- @param position Vector3? (optional) The position of the model.
--- @param rotation Vector3? (optional) The rotation of the model.
--- @param scale number? (optional) The scale of the model.
--- @return Model v The newly created Model instance.
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