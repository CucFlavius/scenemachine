local Math = SceneMachine.Math;
local Vector3 = SceneMachine.Vector3;
local SM = SceneMachine.Editor.SceneManager;
local SH = SceneMachine.Editor.SceneHierarchy;

SceneMachine.Actions.DestroyObject = {};

local Action = SceneMachine.Actions.Action;
local DestroyObject = SceneMachine.Actions.DestroyObject;
DestroyObject.__index = DestroyObject;
setmetatable(DestroyObject, Action)

function DestroyObject:New(objects, hierarchyBefore)
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

function DestroyObject:Finish(objectHierarchyAfter)
	self.objectHierarchyAfter = objectHierarchyAfter;
end

function DestroyObject:Undo()
	for i = 1, #self.objects, 1 do
		local obj = self.objects[i];
		SM.UndeleteObject_internal(obj);
	end
	SH.SetHierarchy(self.objectHierarchyBefore);
end

function DestroyObject:Redo()
	for i = 1, #self.objects, 1 do
		local obj = self.objects[i];
		SM.DeleteObject_internal(obj);
	end
	SH.SetHierarchy(self.objectHierarchyAfter);
end