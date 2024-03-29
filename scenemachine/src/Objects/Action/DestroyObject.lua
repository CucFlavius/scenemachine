local SM = SceneMachine.Editor.SceneManager;

SceneMachine.Actions.DestroyObject = {};

local Action = SceneMachine.Actions.Action;

--- @class DestroyObject : Action
local DestroyObject = SceneMachine.Actions.DestroyObject;

DestroyObject.__index = DestroyObject;
setmetatable(DestroyObject, Action)

--- Creates a new DestroyObject action.
--- @param objects table The objects to be destroyed.
--- @param hierarchyBefore table The hierarchy of the objects before destruction.
--- @return DestroyObject v The newly created DestroyObject action.
function DestroyObject:New(objects, hierarchyBefore)
	--- @class DestroyObject : Action
	local v = 
	{
		type = Action.Type.DestroyObject,
		memorySize = 1,
		memoryUsage = 0,
		objects = {},
		objectHierarchyBefore = hierarchyBefore,
	};

	setmetatable(v, DestroyObject)

	-- save object states
	for i = 1, #objects, 1 do
		local obj = objects[i];
		v.objects[i] = obj;
	end

	v.memoryUsage = #objects * v.memorySize;

	return v
end

--- Finishes the destruction of an object.
--- @param objectHierarchyAfter table The object hierarchy after the destruction.
function DestroyObject:Finish(objectHierarchyAfter)
	self.objectHierarchyAfter = objectHierarchyAfter;
end

-- Undoes the destruction of objects and restores the object hierarchy.
function DestroyObject:Undo()
	for i = 1, #self.objects, 1 do
		local obj = self.objects[i];
		SM.UndeleteObject_internal(obj);
	end
	SM.loadedScene:SetObjectHierarchy(self.objectHierarchyBefore);
end

-- Redo the destruction of objects.
function DestroyObject:Redo()
	-- Loop through each object in the list
	for i = 1, #self.objects, 1 do
		local obj = self.objects[i];
		SM.DeleteObject_internal(obj);
	end
	-- Set the object hierarchy after the destruction
	SM.loadedScene:SetObjectHierarchy(self.objectHierarchyAfter);
end