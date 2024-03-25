local SM = SceneMachine.Editor.SceneManager;
local AM = SceneMachine.Editor.AnimationManager;

SceneMachine.Actions.DestroyTimeline = {};

local Action = SceneMachine.Actions.Action;

--- @class DestroyTimeline : Action
local DestroyTimeline = SceneMachine.Actions.DestroyTimeline;

DestroyTimeline.__index = DestroyTimeline;
setmetatable(DestroyTimeline, Action)

--- Creates a new DestroyTimeline object.
--- @param timeline table The timeline to be destroyed.
--- @return DestroyTimeline v The newly created DestroyTimeline object.
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

--- Undoes the destruction of a timeline.
function DestroyTimeline:Undo()
	AM.UndeleteTimeline_internal(self.timeline);
end

--- Redo the action of destroying a timeline.
function DestroyTimeline:Redo()
	AM.DeleteTimeline_internal(self.timeline);
end