local AM = SceneMachine.Editor.AnimationManager;

SceneMachine.Actions.CreateTimeline = {};

local Action = SceneMachine.Actions.Action;
local CreateTimeline = SceneMachine.Actions.CreateTimeline;
CreateTimeline.__index = CreateTimeline;
setmetatable(CreateTimeline, Action)

function CreateTimeline:New(timeline)
	local v = 
    {
        type = Action.Type.CreateTimeline,
		memorySize = 1,
		memoryUsage = 0,
		timeline = timeline,
    };

	setmetatable(v, CreateTimeline)

	v.memoryUsage = v.memorySize;

	return v
end

function CreateTimeline:Finish()

end

function CreateTimeline:Undo()
	print("del")
	AM.DeleteTimeline_internal(self.timeline);
end

function CreateTimeline:Redo()
	print("undel")
	AM.UndeleteTimeline_internal(self.timeline);
end