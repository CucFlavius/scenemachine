local Math = SceneMachine.Math;
local Vector3 = SceneMachine.Vector3;
local SM = SceneMachine.Editor.SceneManager;

SceneMachine.Actions.CreateObject = {};

local Action = SceneMachine.Actions.Action;
local CreateObject = SceneMachine.Actions.CreateObject;
CreateObject.__index = CreateObject;
setmetatable(CreateObject, Action)

function CreateObject:New(objects)
	local v = 
    {
        type = Action.Type.CreateObject,
		memorySize = 1,
		memoryUsage = 0,
		objects = {},
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

function CreateObject:Finish()

end

function CreateObject:Undo()
	for i = 1, #self.objects, 1 do
		local obj = self.objects[i];
		SM.DeleteObject_internal(obj);
	end
end

function CreateObject:Redo()
	for i = 1, #self.objects, 1 do
		local obj = self.objects[i];
		SM.UndeleteObject_internal(obj);
	end
end