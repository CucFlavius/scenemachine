
SceneMachine.GameObjects.Group = {};

local Vector3 = SceneMachine.Vector3;
local Gizmos = SceneMachine.Gizmos;
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
        position = Vector3:New(),
        rotation = Vector3:New(),
        scale = 1,
    };

	setmetatable(v, Group)
	return v
end

--- Selects the group.
function Group:Select()
    if (not self.selected) then
        self.selected = true;
    end
end

--- Deselects the group.
function Group:Deselect()
    if (self.selected) then
        self.selected = false;
    end
end

function Group:GetActiveBoundingBox()
    return -0.5, -0.5, -0.5, 0.5, 0.5, 0.5;
end

--- Returns the gizmo type for the object.
--- @return Gizmos.Type gizmoType The gizmo type.
function Group:GetGizmoType()
    return Gizmos.Type.Object;
end