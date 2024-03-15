SceneMachine.Actions.Action = {};

local Actions = SceneMachine.Actions;
local Action = SceneMachine.Actions.Action;

Action.Type = {};
Action.Type.None = 0;
Action.Type.TransformObject = 1;
Action.Type.DestroyObject = 2;
Action.Type.CreateObject = 3;
Action.Type.CreateTrack = 4;
Action.Type.DestroyTrack = 5;
Action.Type.SceneProperties = 6;
Action.Type.CreateTimeline = 7;
Action.Type.DestroyTimeline = 8;
Action.Type.TimelineProperties = 9;
Action.Type.TrackAnimations = 10;
Action.Type.TrackKeyframes = 11;

setmetatable(Action, Action)

local fields = {}

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