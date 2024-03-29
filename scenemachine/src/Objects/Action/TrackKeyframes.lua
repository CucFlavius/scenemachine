local SM = SceneMachine.Editor.SceneManager;
local AM = SceneMachine.Editor.AnimationManager;

SceneMachine.Actions.TrackKeyframes = {};

local Action = SceneMachine.Actions.Action;
local Keyframe = SceneMachine.Keyframe;

--- @class TrackKeyframes : Action
local TrackKeyframes = SceneMachine.Actions.TrackKeyframes;

TrackKeyframes.__index = TrackKeyframes;
setmetatable(TrackKeyframes, Action)

--- Creates a new instance of the TrackKeyframes class.
--- @param track table The track object.
--- @param timeline table The timeline object.
--- @return TrackKeyframes v The newly created TrackKeyframes instance.
function TrackKeyframes:New(track, timeline)
	--- @class TrackKeyframes : Action
	local v = 
	{
		type = Action.Type.TrackKeyframes,
		memorySize = 4;
		memoryUsage = 0;
		timeline = timeline;
		track = track;
		startKeysPx = {};
		startKeysPy = {};
		startKeysPz = {};
		startKeysRx = {};
		startKeysRy = {};
		startKeysRz = {};
		startKeysS = {};
		startKeysA = {};
	};

	setmetatable(v, TrackKeyframes)

	-- save key states
	self:TransferKeys(track.keysPx, v.startKeysPx);
	self:TransferKeys(track.keysPy, v.startKeysPy);
	self:TransferKeys(track.keysPz, v.startKeysPz);
	self:TransferKeys(track.keysRx, v.startKeysRx);
	self:TransferKeys(track.keysRy, v.startKeysRy);
	self:TransferKeys(track.keysRz, v.startKeysRz);
	self:TransferKeys(track.keysS, v.startKeysS);
	self:TransferKeys(track.keysA, v.startKeysA);

	v.memoryUsage = #track.keysPx * v.memorySize + #track.keysPy * v.memorySize + #track.keysPz * v.memorySize + 
					#track.keysRx * v.memorySize + #track.keysRy * v.memorySize + #track.keysRz * v.memorySize +
					#track.keysA * v.memorySize;

	return v
end

-- Finish function to finalize the keyframes for each property of the track
function TrackKeyframes:Finish()
	self.endKeysPx = {};
	self.endKeysPy = {};
	self.endKeysPz = {};
	self.endKeysRx = {};
	self.endKeysRy = {};
	self.endKeysRz = {};
	self.endKeysS = {};
	self.endKeysA = {};

	self:TransferKeys(self.track.keysPx, self.endKeysPx);
	self:TransferKeys(self.track.keysPy, self.endKeysPy);
	self:TransferKeys(self.track.keysPz, self.endKeysPz);
	self:TransferKeys(self.track.keysRx, self.endKeysRx);
	self:TransferKeys(self.track.keysRy, self.endKeysRy);
	self:TransferKeys(self.track.keysRz, self.endKeysRz);
	self:TransferKeys(self.track.keysA, self.endKeysA);
end

function TrackKeyframes:TransferKeys(fromKeys, toKeys)
	for i = 1, #fromKeys, 1 do
		local fromKey = fromKeys[i];
		toKeys[i] = Keyframe:NewClone(fromKey);
	end
end

-- Undoes the changes made to the keyframes of a track.
function TrackKeyframes:Undo()
	self.track.keysPx = {};
	self.track.keysPy = {};
	self.track.keysPz = {};
	self.track.keysRx = {};
	self.track.keysRy = {};
	self.track.keysRz = {};
	self.track.keysS = {};
	self.track.keysA = {};
	TrackKeyframes:TransferKeys(self.startKeysPx, self.track.keysPx);
	TrackKeyframes:TransferKeys(self.startKeysPy, self.track.keysPy);
	TrackKeyframes:TransferKeys(self.startKeysPz, self.track.keysPz);
	TrackKeyframes:TransferKeys(self.startKeysRx, self.track.keysRx);
	TrackKeyframes:TransferKeys(self.startKeysRy, self.track.keysRy);
	TrackKeyframes:TransferKeys(self.startKeysRz, self.track.keysRz);
	TrackKeyframes:TransferKeys(self.startKeysS, self.track.keysS);
	TrackKeyframes:TransferKeys(self.startKeysA, self.track.keysA);

	AM.RefreshWorkspace();
end

-- Redo function to update the keyframes of the track
function TrackKeyframes:Redo()
	self.track.keysPx = {};
	self.track.keysPy = {};
	self.track.keysPz = {};
	self.track.keysRx = {};
	self.track.keysRy = {};
	self.track.keysRz = {};
	self.track.keysS = {};
	self.track.keysA = {};
	self:TransferKeys(self.endKeysPx, self.track.keysPx);
	self:TransferKeys(self.endKeysPy, self.track.keysPy);
	self:TransferKeys(self.endKeysPz, self.track.keysPz);
	self:TransferKeys(self.endKeysRx, self.track.keysRx);
	self:TransferKeys(self.endKeysRy, self.track.keysRy);
	self:TransferKeys(self.endKeysRz, self.track.keysRz);
	self:TransferKeys(self.endKeysS, self.track.keysS);
	self:TransferKeys(self.endKeysA, self.track.keysA);

	-- Refresh the workspace
	AM.RefreshWorkspace();
end