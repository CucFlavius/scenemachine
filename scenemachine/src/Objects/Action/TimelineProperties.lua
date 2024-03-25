local SM = SceneMachine.Editor.SceneManager;
local AM = SceneMachine.Editor.AnimationManager;
local Renderer = SceneMachine.Renderer;

SceneMachine.Actions.TimelineProperties = {};

local Action = SceneMachine.Actions.Action;

--- @class TimelineProperties : Action
local TimelineProperties = SceneMachine.Actions.TimelineProperties;

TimelineProperties.__index = TimelineProperties;
setmetatable(TimelineProperties, Action)

--- Creates a new instance of the TimelineProperties class.
--- @param timeline table The timeline object associated with the properties.
--- @return TimelineProperties v The newly created TimelineProperties object.
function TimelineProperties:New(timeline)
	local v = 
	{
		type = Action.Type.TimelineProperties,
		memorySize = 9,
		memoryUsage = 0,
		timeline = timeline,
		startProperties = {},
	};

	setmetatable(v, TimelineProperties)

	v.startProperties.name = timeline.name;

	v.memoryUsage = v.memorySize;

	return v
end

--- Finish the timeline by setting the end properties.
--- @param timeline table The timeline to finish.
function TimelineProperties:Finish(timeline)
	self.endProperties = {};
	self.endProperties.name = timeline.name;
end

--- Undoes the changes made to the timeline properties.
function TimelineProperties:Undo()
	self.timeline.name = self.startProperties.name;
	AM.RefreshTimelineTabs();
end

--- Redo the timeline properties.
function TimelineProperties:Redo()
	self.timeline.name = self.endProperties.name;
	AM.RefreshTimelineTabs();
end