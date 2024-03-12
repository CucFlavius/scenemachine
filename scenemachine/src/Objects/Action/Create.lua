local Math = SceneMachine.Math;
local Vector3 = SceneMachine.Vector3;
local SM = SceneMachine.Editor.SceneManager;

SceneMachine.Actions.Create = {};

local Action = SceneMachine.Actions.Action;
local Create = SceneMachine.Actions.Create;
Create.__index = Create;
setmetatable(Create, Action)

function Create:New(objects)
	local v = 
    {
        type = Action.Type.Create,
		memorySize = 1,
		memoryUsage = 0,
		objects = {},
    };

	setmetatable(v, Create)

	-- save object states
	for i = 1, #objects, 1 do
		local obj = objects[i];
		v.objects[i] = obj;
	end

	v.memoryUsage = #objects * v.memorySize;

	return v
end

function Create:Finish()

end

function Create:Undo()
	for i = 1, #self.objects, 1 do
		local obj = self.objects[i];
		SM.DeleteObject_internal(obj);
	end
end

function Create:Redo()
	for i = 1, #self.objects, 1 do
		local obj = self.objects[i];
		SM.UndeleteObject_internal(obj);
	end
end