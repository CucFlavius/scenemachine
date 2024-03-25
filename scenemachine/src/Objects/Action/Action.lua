SceneMachine.Actions.Action = {};

--- @class Action
local Action = SceneMachine.Actions.Action;

--- @enum Action.Type
Action.Type = {
	None = 0,
	TransformObject = 1,
	DestroyObject = 2,
	CreateObject = 3,
	CreateTrack = 4,
	DestroyTrack = 5,
	SceneProperties = 6,
	CreateTimeline = 7,
	DestroyTimeline = 8,
	TimelineProperties = 9,
	TrackAnimations = 10,
	TrackKeyframes = 11,
	HierarchyChange = 12,
};

setmetatable(Action, Action)

local fields = {}

--- Creates a new instance of the Action class.
--- @return Action v The new Action instance.
function Action:New()
	local v = 
	{
		type = Action.Type.None,
		memorySize = 0,
		memoryUsage = 0,
	};

	setmetatable(v, Action)
	return v
end

-- This function is used as the __index metamethod for the Action table.
-- It is called when a key is not found in the Action table.
Action.__index = function(t,k)
	local var = rawget(Action, k)
		
	if var == nil then							
		var = rawget(fields, k)
		
		if var ~= nil then
			return var(t)
		end
	end
	
	return var
end