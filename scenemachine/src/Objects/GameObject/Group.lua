
SceneMachine.GameObjects.Group = {};

local Object = SceneMachine.GameObjects.Object;
local Group = SceneMachine.GameObjects.Group;
local Gizmos = SceneMachine.Gizmos;

Group.__index = Group;
setmetatable(Group, Object)

function Group:New(name)
    local v = 
    {
        name = name or "NewGroup",
        id = math.random(99999999);
        visible = true,
        frozen = false,
        isRenamed = false,
        type = Object.Type.Group,
    };

	setmetatable(v, Group)
	return v
end