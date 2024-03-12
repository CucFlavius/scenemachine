local SM = SceneMachine.Editor.SceneManager;
local AM = SceneMachine.Editor.AnimationManager;

SceneMachine.Actions.CreateTrack = {};

local Action = SceneMachine.Actions.Action;
local CreateTrack = SceneMachine.Actions.CreateTrack;
CreateTrack.__index = CreateTrack;
setmetatable(CreateTrack, Action)

function CreateTrack:New(tracks)
	local v = 
    {
        type = Action.Type.CreateTrack,
		memorySize = 1,
		memoryUsage = 0,
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

function CreateTrack:Undo()
	for i = 1, #self.tracks, 1 do
		local trk = self.tracks[i];
		AM.RemoveTrack_internal(trk);
	end
end

function CreateTrack:Redo()
	for i = 1, #self.tracks, 1 do
		local trk = self.tracks[i];
		AM.UnremoveTrack_internal(trk);
	end
end