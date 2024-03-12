local SM = SceneMachine.Editor.SceneManager;
local AM = SceneMachine.Editor.AnimationManager;

SceneMachine.Actions.DestroyTrack = {};

local Action = SceneMachine.Actions.Action;
local DestroyTrack = SceneMachine.Actions.DestroyTrack;
DestroyTrack.__index = DestroyTrack;
setmetatable(DestroyTrack, Action)

function DestroyTrack:New(tracks)
	local v = 
    {
        type = Action.Type.DestroyTrack,
		memorySize = 1,
		memoryUsage = 0,
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

function DestroyTrack:Undo()
	for i = 1, #self.tracks, 1 do
		local trk = self.tracks[i];
		AM.UnremoveTrack_internal(trk);
	end
end

function DestroyTrack:Redo()
	for i = 1, #self.tracks, 1 do
		local trk = self.tracks[i];
		AM.RemoveTrack_internal(trk);
	end
end