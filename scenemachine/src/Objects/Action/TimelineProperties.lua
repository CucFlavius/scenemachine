local SM = SceneMachine.Editor.SceneManager;
local AM = SceneMachine.Editor.AnimationManager;
local Renderer = SceneMachine.Renderer;

SceneMachine.Actions.TimelineProperties = {};

local Action = SceneMachine.Actions.Action;
local TimelineProperties = SceneMachine.Actions.TimelineProperties;
TimelineProperties.__index = TimelineProperties;
setmetatable(TimelineProperties, Action)

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

function TimelineProperties:Finish(timeline)
	self.endProperties = {};
	self.endProperties.name = timeline.name;
end

function TimelineProperties:Undo()
	self.timeline.name = self.startProperties.name;
	AM.RefreshTimelineTabs();
end

function TimelineProperties:Redo()
	self.timeline.name = self.endProperties.name;
    AM.RefreshTimelineTabs();
end