local SM = SceneMachine.Editor.SceneManager;
local AM = SceneMachine.Editor.AnimationManager;

SceneMachine.Actions.DestroyTrack = {};

local Action = SceneMachine.Actions.Action;

--- @class DestroyTrack : Action
local DestroyTrack = SceneMachine.Actions.DestroyTrack;

DestroyTrack.__index = DestroyTrack;
setmetatable(DestroyTrack, Action)

--- Creates a new DestroyTrack object.
--- @param tracks table An array of tracks to be destroyed.
--- @param timeline table The timeline object associated with the tracks.
--- @return DestroyTrack v The newly created DestroyTrack object.
function DestroyTrack:New(tracks, timeline)
	--- @class DestroyTrack : Action
	local v = 
	{
		type = Action.Type.DestroyTrack,
		memorySize = 1,
		memoryUsage = 0,
		timeline = timeline,
		tracks = {},
	};

	setmetatable(v, DestroyTrack)

	-- save object states
	for i = 1, #tracks, 1 do
		local trk = tracks[i];
		v.tracks[i] = trk;
	end

	v.memoryUsage = #tracks * v.memorySize;

	return v
end

function DestroyTrack:Finish()

end

--- Undoes the destruction of tracks.
function DestroyTrack:Undo()
	for i = 1, #self.tracks, 1 do
		local trk = self.tracks[i];
		AM.UnremoveTrack_internal(trk, self.timeline);
	end
end

-- Redo function for the DestroyTrack class.
-- Removes all tracks specified in the 'tracks' table from the timeline.
function DestroyTrack:Redo()
	for i = 1, #self.tracks, 1 do
		local trk = self.tracks[i];
		AM.RemoveTrack_internal(trk, self.timeline);
	end
end