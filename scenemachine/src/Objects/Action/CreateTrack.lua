local SM = SceneMachine.Editor.SceneManager;
local AM = SceneMachine.Editor.AnimationManager;

SceneMachine.Actions.CreateTrack = {};

local Action = SceneMachine.Actions.Action;

--- @class CreateTrack : Action
local CreateTrack = SceneMachine.Actions.CreateTrack;

CreateTrack.__index = CreateTrack;
setmetatable(CreateTrack, Action)

--- Creates a new instance of the CreateTrack action.
--- @param tracks table The tracks to be created.
--- @param timeline table The timeline to which the tracks will be added.
--- @return CreateTrack v The newly created CreateTrack object.
function CreateTrack:New(tracks, timeline)
	local v = 
	{
		type = Action.Type.CreateTrack,
		memorySize = 1,
		memoryUsage = 0,
		timeline = timeline,
		tracks = {},
	};

	setmetatable(v, CreateTrack)

	-- save object states
	for i = 1, #tracks, 1 do
		local trk = tracks[i];
		v.tracks[i] = trk;
	end

	v.memoryUsage = #tracks * v.memorySize;

	return v
end

function CreateTrack:Finish()

end

-- Undoes the action of creating a track by removing all the tracks created by this action.
function CreateTrack:Undo()
	for i = 1, #self.tracks, 1 do
		local trk = self.tracks[i];
		AM.RemoveTrack_internal(trk, self.timeline);
	end
end

-- Redo the action of creating a track.
function CreateTrack:Redo()
	for i = 1, #self.tracks, 1 do
		local trk = self.tracks[i];
		AM.UnremoveTrack_internal(trk, self.timeline);
	end
end