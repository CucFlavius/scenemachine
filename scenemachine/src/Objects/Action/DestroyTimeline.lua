local SM = SceneMachine.Editor.SceneManager;
local AM = SceneMachine.Editor.AnimationManager;

SceneMachine.Actions.DestroyTimeline = {};

local Action = SceneMachine.Actions.Action;
local DestroyTimeline = SceneMachine.Actions.DestroyTimeline;
DestroyTimeline.__index = DestroyTimeline;
setmetatable(DestroyTimeline, Action)

function DestroyTimeline:New(timeline)
	local v = 
    {
        type = Action.Type.DestroyTimeline,
		memorySize = 1,
		memoryUsage = 0,
		timeline = timeline,
    };

	setmetatable(v, DestroyTimeline)

	v.memoryUsage = v.memorySize;

	return v
end

function DestroyTimeline:Finish()

end

function DestroyTimeline:Undo()
	AM.UndeleteTimeline_internal(self.timeline);
end

function DestroyTimeline:Redo()
	AM.DeleteTimeline_internal(self.timeline);
end