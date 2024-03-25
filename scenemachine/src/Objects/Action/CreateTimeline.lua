local AM = SceneMachine.Editor.AnimationManager;

SceneMachine.Actions.CreateTimeline = {};

local Action = SceneMachine.Actions.Action;

--- @class CreateTimeline : Action
local CreateTimeline = SceneMachine.Actions.CreateTimeline;

CreateTimeline.__index = CreateTimeline;
setmetatable(CreateTimeline, Action)

--- Creates a new instance of the CreateTimeline action.
--- @param timeline table The timeline to be associated with the action.
--- @return CreateTimeline v The newly created CreateTimeline object.
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

--- Undoes the action of creating a timeline.
function CreateTimeline:Undo()
	AM.DeleteTimeline_internal(self.timeline);
end

--- Redoes the action of creating a timeline.
function CreateTimeline:Redo()
	AM.UndeleteTimeline_internal(self.timeline);
end