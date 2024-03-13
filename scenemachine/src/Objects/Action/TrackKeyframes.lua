local SM = SceneMachine.Editor.SceneManager;
local AM = SceneMachine.Editor.AnimationManager;

SceneMachine.Actions.TrackKeyframes = {};

local Action = SceneMachine.Actions.Action;
local TrackKeyframes = SceneMachine.Actions.TrackKeyframes;
TrackKeyframes.__index = TrackKeyframes;
setmetatable(TrackKeyframes, Action)

function TrackKeyframes:New(track, timeline)
	local v = 
    {
        type = Action.Type.TrackKeyframes,
		memorySize = 4,
		memoryUsage = 0,
		timeline = timeline,
		track = track,
		startKeysPx = {},
		startKeysPy = {},
		startKeysPz = {},
		startKeysRx = {},
		startKeysRy = {},
		startKeysRz = {},
		startKeysS = {},
		startKeysA = {},
    };

	setmetatable(v, TrackKeyframes)

	-- save key states
	for i = 1, #track.keysPx, 1 do
		local key = track.keysPx[i];
		v.startKeysPx[i] = { key.time, key.value, key.interpolationIn, key.interpolationOut };
	end

	for i = 1, #track.keysPy, 1 do
		local key = track.keysPy[i];
		v.startKeysPy[i] = { key.time, key.value, key.interpolationIn, key.interpolationOut };
	end

	for i = 1, #track.keysPz, 1 do
		local key = track.keysPz[i];
		v.startKeysPz[i] = { key.time, key.value, key.interpolationIn, key.interpolationOut };
	end

	for i = 1, #track.keysRx, 1 do
		local key = track.keysRx[i];
		v.startKeysRx[i] = { key.time, key.value, key.interpolationIn, key.interpolationOut };
	end

	for i = 1, #track.keysRy, 1 do
		local key = track.keysRy[i];
		v.startKeysRy[i] = { key.time, key.value, key.interpolationIn, key.interpolationOut };
	end

	for i = 1, #track.keysRz, 1 do
		local key = track.keysRz[i];
		v.startKeysRz[i] = { key.time, key.value, key.interpolationIn, key.interpolationOut };
	end

	for i = 1, #track.keysA, 1 do
		local key = track.keysA[i];
		v.startKeysA[i] = { key.time, key.value, key.interpolationIn, key.interpolationOut };
	end

	v.memoryUsage = #track.keysPx * v.memorySize + #track.keysPy * v.memorySize + #track.keysPz * v.memorySize + 
					#track.keysRx * v.memorySize + #track.keysRy * v.memorySize + #track.keysRz * v.memorySize +
					#track.keysA * v.memorySize;

	return v
end

function TrackKeyframes:Finish()
	self.endKeysPx = {};
	for i = 1, #self.track.keysPx, 1 do
		local key = self.track.keysPx[i];
		self.endKeysPx[i] = { key.time, key.value, key.interpolationIn, key.interpolationOut };
	end

	self.endKeysPy = {};
	for i = 1, #self.track.keysPy, 1 do
		local key = self.track.keysPy[i];
		self.endKeysPy[i] = { key.time, key.value, key.interpolationIn, key.interpolationOut };
	end

	self.endKeysPz = {};
	for i = 1, #self.track.keysPz, 1 do
		local key = self.track.keysPz[i];
		self.endKeysPz[i] = { key.time, key.value, key.interpolationIn, key.interpolationOut };
	end

	self.endKeysRx = {};
	for i = 1, #self.track.keysRx, 1 do
		local key = self.track.keysRx[i];
		self.endKeysRx[i] = { key.time, key.value, key.interpolationIn, key.interpolationOut };
	end

	self.endKeysRy = {};
	for i = 1, #self.track.keysRy, 1 do
		local key = self.track.keysRy[i];
		self.endKeysRy[i] = { key.time, key.value, key.interpolationIn, key.interpolationOut };
	end

	self.endKeysRz = {};
	for i = 1, #self.track.keysRz, 1 do
		local key = self.track.keysRz[i];
		self.endKeysRz[i] = { key.time, key.value, key.interpolationIn, key.interpolationOut };
	end

	self.endKeysA = {};
	for i = 1, #self.track.keysA, 1 do
		local key = self.track.keysA[i];
		self.endKeysA[i] = { key.time, key.value, key.interpolationIn, key.interpolationOut };
	end
end

function TrackKeyframes:Undo()

	self.track.keysPx = {};
	for i = 1, #self.startKeysPx, 1 do
		local keyframe = {};
		local key = self.startKeysPx[i];
		keyframe.time = key[1];
		keyframe.value = key[2];
		keyframe.interpolationIn = key[3];
		keyframe.interpolationOut = key[4];
		self.track.keysPx[i] = keyframe;
	end

	self.track.keysPy = {};
	for i = 1, #self.startKeysPy, 1 do
		local keyframe = {};
		local key = self.startKeysPy[i];
		keyframe.time = key[1];
		keyframe.value = key[2];
		keyframe.interpolationIn = key[3];
		keyframe.interpolationOut = key[4];
		self.track.keysPy[i] = keyframe;
	end

	self.track.keysPz = {};
	for i = 1, #self.startKeysPz, 1 do
		local keyframe = {};
		local key = self.startKeysPz[i];
		keyframe.time = key[1];
		keyframe.value = key[2];
		keyframe.interpolationIn = key[3];
		keyframe.interpolationOut = key[4];
		self.track.keysPz[i] = keyframe;
	end

	self.track.keysRx = {};
	for i = 1, #self.startKeysRx, 1 do
		local keyframe = {};
		local key = self.startKeysRx[i];
		keyframe.time = key[1];
		keyframe.value = key[2];
		keyframe.interpolationIn = key[3];
		keyframe.interpolationOut = key[4];
		self.track.keysRx[i] = keyframe;
	end

	self.track.keysRy = {};
	for i = 1, #self.startKeysRy, 1 do
		local keyframe = {};
		local key = self.startKeysRy[i];
		keyframe.time = key[1];
		keyframe.value = key[2];
		keyframe.interpolationIn = key[3];
		keyframe.interpolationOut = key[4];
		self.track.keysRy[i] = keyframe;
	end

	self.track.keysRz = {};
	for i = 1, #self.startKeysRz, 1 do
		local keyframe = {};
		local key = self.startKeysRz[i];
		keyframe.time = key[1];
		keyframe.value = key[2];
		keyframe.interpolationIn = key[3];
		keyframe.interpolationOut = key[4];
		self.track.keysRz[i] = keyframe;
	end

	self.track.keysA = {};
	for i = 1, #self.startKeysA, 1 do
		local keyframe = {};
		local key = self.startKeysA[i];
		keyframe.time = key[1];
		keyframe.value = key[2];
		keyframe.interpolationIn = key[3];
		keyframe.interpolationOut = key[4];
		self.track.keysA[i] = keyframe;
	end

	AM.RefreshWorkspace();
end

function TrackKeyframes:Redo()

	self.track.keysPx = {};
	for i = 1, #self.endKeysPx, 1 do
		local keyframe = {};
		local key = self.endKeysPx[i];
		keyframe.time = key[1];
		keyframe.value = key[2];
		keyframe.interpolationIn = key[3];
		keyframe.interpolationOut = key[4];
		self.track.keysPx[i] = keyframe;
	end

	self.track.keysPy = {};
	for i = 1, #self.endKeysPy, 1 do
		local keyframe = {};
		local key = self.endKeysPy[i];
		keyframe.time = key[1];
		keyframe.value = key[2];
		keyframe.interpolationIn = key[3];
		keyframe.interpolationOut = key[4];
		self.track.keysPy[i] = keyframe;
	end

	self.track.keysPz = {};
	for i = 1, #self.endKeysPz, 1 do
		local keyframe = {};
		local key = self.endKeysPz[i];
		keyframe.time = key[1];
		keyframe.value = key[2];
		keyframe.interpolationIn = key[3];
		keyframe.interpolationOut = key[4];
		self.track.keysPz[i] = keyframe;
	end

	self.track.keysRx = {};
	for i = 1, #self.endKeysRx, 1 do
		local keyframe = {};
		local key = self.endKeysRx[i];
		keyframe.time = key[1];
		keyframe.value = key[2];
		keyframe.interpolationIn = key[3];
		keyframe.interpolationOut = key[4];
		self.track.keysRx[i] = keyframe;
	end

	self.track.keysRy = {};
	for i = 1, #self.endKeysRy, 1 do
		local keyframe = {};
		local key = self.endKeysRy[i];
		keyframe.time = key[1];
		keyframe.value = key[2];
		keyframe.interpolationIn = key[3];
		keyframe.interpolationOut = key[4];
		self.track.keysRy[i] = keyframe;
	end

	self.track.keysRz = {};
	for i = 1, #self.endKeysRz, 1 do
		local keyframe = {};
		local key = self.endKeysRz[i];
		keyframe.time = key[1];
		keyframe.value = key[2];
		keyframe.interpolationIn = key[3];
		keyframe.interpolationOut = key[4];
		self.track.keysRz[i] = keyframe;
	end

	self.track.keysA = {};
	for i = 1, #self.endKeysA, 1 do
		local keyframe = {};
		local key = self.endKeysA[i];
		keyframe.time = key[1];
		keyframe.value = key[2];
		keyframe.interpolationIn = key[3];
		keyframe.interpolationOut = key[4];
		self.track.keysA[i] = keyframe;
	end

	AM.RefreshWorkspace();
end