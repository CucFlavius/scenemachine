local SM = SceneMachine.Editor.SceneManager;

SceneMachine.Actions.CreateObject = {};

local Action = SceneMachine.Actions.Action;

--- @class CreateObject : Action
local CreateObject = SceneMachine.Actions.CreateObject;

CreateObject.__index = CreateObject;
setmetatable(CreateObject, Action)

--- Creates a new instance of the CreateObject action.
--- @param objects table An array of objects to be created.
--- @param hierarchyBefore table The hierarchy of objects before the creation.
--- @return CreateObject v The newly created instance of the CreateObject action.
function CreateObject:New(objects, hierarchyBefore)
	--- @class CreateObject : Action
	local v =
	{
		type = Action.Type.CreateObject,
		memorySize = 1,
		memoryUsage = 0,
		objects = {},
		objectHierarchyBefore = hierarchyBefore,
	};

	setmetatable(v, CreateObject)

	-- save object states
	for i = 1, #objects, 1 do
		local obj = objects[i];
		v.objects[i] = obj;
	end

	v.memoryUsage = #objects * v.memorySize;

	return v
end

--- Finishes the creation of an object by setting the object hierarchy after creation.
--- @param objectHierarchyAfter table The object hierarchy after the creation.
function CreateObject:Finish(objectHierarchyAfter)
	self.objectHierarchyAfter = objectHierarchyAfter;
end

--- Undoes the creation of objects and restores the previous object hierarchy.
function CreateObject:Undo()
	for i = 1, #self.objects, 1 do
		local obj = self.objects[i];
		SM.DeleteObject_internal(obj);
	end
	SM.loadedScene:SetObjectHierarchy(self.objectHierarchyBefore);
end

--- Redo the creation of objects.
function CreateObject:Redo()
	-- Iterate over each object in the list
	for i = 1, #self.objects, 1 do
		local obj = self.objects[i];
		-- Undelete the object
		SM.UndeleteObject_internal(obj);
	end
	-- Set the object hierarchy to the updated hierarchy
	SM.loadedScene:SetObjectHierarchy(self.objectHierarchyAfter);
end