
SceneMachine.GameObjects.Group = {};

local Object = SceneMachine.GameObjects.Object;

--- @class Group : Object
local Group = SceneMachine.GameObjects.Group;

Group.__index = Group;
setmetatable(Group, Object)

--- Creates a new Group object.
---@param name string? (optional) The name of the group. Defaults to "NewGroup".
---@return Group v The newly created Group object.
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