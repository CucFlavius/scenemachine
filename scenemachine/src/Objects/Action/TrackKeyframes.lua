local SM = SceneMachine.Editor.SceneManager;
local AM = SceneMachine.Editor.AnimationManager;

SceneMachine.Actions.TrackKeyframes = {};

local Action = SceneMachine.Actions.Action;

--- @class TrackKeyframes : Action
local TrackKeyframes = SceneMachine.Actions.TrackKeyframes;

TrackKeyframes.__index = TrackKeyframes;
setmetatable(TrackKeyframes, Action)

--- Creates a new instance of the TrackKeyframes class.
--- @param track table The track object.
--- @param timeline table The timeline object.
--- @return TrackKeyframes v The newly created TrackKeyframes instance.
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

-- Finish function to finalize the keyframes for each property of the track
function TrackKeyframes:Finish()
	-- Store the end keyframes for the 'x' position property
	self.endKeysPx = {};
	for i = 1, #self.track.keysPx, 1 do
		local key = self.track.keysPx[i];
		self.endKeysPx[i] = { key.time, key.value, key.interpolationIn, key.interpolationOut };
	end

	-- Store the end keyframes for the 'y' position property
	self.endKeysPy = {};
	for i = 1, #self.track.keysPy, 1 do
		local key = self.track.keysPy[i];
		self.endKeysPy[i] = { key.time, key.value, key.interpolationIn, key.interpolationOut };
	end

	-- Store the end keyframes for the 'z' position property
	self.endKeysPz = {};
	for i = 1, #self.track.keysPz, 1 do
		local key = self.track.keysPz[i];
		self.endKeysPz[i] = { key.time, key.value, key.interpolationIn, key.interpolationOut };
	end

	-- Store the end keyframes for the 'x' rotation property
	self.endKeysRx = {};
	for i = 1, #self.track.keysRx, 1 do
		local key = self.track.keysRx[i];
		self.endKeysRx[i] = { key.time, key.value, key.interpolationIn, key.interpolationOut };
	end

	-- Store the end keyframes for the 'y' rotation property
	self.endKeysRy = {};
	for i = 1, #self.track.keysRy, 1 do
		local key = self.track.keysRy[i];
		self.endKeysRy[i] = { key.time, key.value, key.interpolationIn, key.interpolationOut };
	end

	-- Store the end keyframes for the 'z' rotation property
	self.endKeysRz = {};
	for i = 1, #self.track.keysRz, 1 do
		local key = self.track.keysRz[i];
		self.endKeysRz[i] = { key.time, key.value, key.interpolationIn, key.interpolationOut };
	end

	-- Store the end keyframes for the 'alpha' property
	self.endKeysA = {};
	for i = 1, #self.track.keysA, 1 do
		local key = self.track.keysA[i];
		self.endKeysA[i] = { key.time, key.value, key.interpolationIn, key.interpolationOut };
	end
end

-- Undoes the changes made to the keyframes of a track.
function TrackKeyframes:Undo()
	-- Reset the keysPx table
	self.track.keysPx = {};
	-- Iterate over the startKeysPx table
	for i = 1, #self.startKeysPx, 1 do
		local keyframe = {};
		local key = self.startKeysPx[i];
		-- Copy the keyframe properties
		keyframe.time = key[1];
		keyframe.value = key[2];
		keyframe.interpolationIn = key[3];
		keyframe.interpolationOut = key[4];
		-- Add the keyframe to the keysPx table
		self.track.keysPx[i] = keyframe;
	end

	-- Reset the keysPy table
	self.track.keysPy = {};
	-- Iterate over the startKeysPy table
	for i = 1, #self.startKeysPy, 1 do
		local keyframe = {};
		local key = self.startKeysPy[i];
		-- Copy the keyframe properties
		keyframe.time = key[1];
		keyframe.value = key[2];
		keyframe.interpolationIn = key[3];
		keyframe.interpolationOut = key[4];
		-- Add the keyframe to the keysPy table
		self.track.keysPy[i] = keyframe;
	end

	-- Reset the keysPz table
	self.track.keysPz = {};
	-- Iterate over the startKeysPz table
	for i = 1, #self.startKeysPz, 1 do
		local keyframe = {};
		local key = self.startKeysPz[i];
		-- Copy the keyframe properties
		keyframe.time = key[1];
		keyframe.value = key[2];
		keyframe.interpolationIn = key[3];
		keyframe.interpolationOut = key[4];
		-- Add the keyframe to the keysPz table
		self.track.keysPz[i] = keyframe;
	end

	-- Reset the keysRx table
	self.track.keysRx = {};
	-- Iterate over the startKeysRx table
	for i = 1, #self.startKeysRx, 1 do
		local keyframe = {};
		local key = self.startKeysRx[i];
		-- Copy the keyframe properties
		keyframe.time = key[1];
		keyframe.value = key[2];
		keyframe.interpolationIn = key[3];
		keyframe.interpolationOut = key[4];
		-- Add the keyframe to the keysRx table
		self.track.keysRx[i] = keyframe;
	end

	-- Reset the keysRy table
	self.track.keysRy = {};
	-- Iterate over the startKeysRy table
	for i = 1, #self.startKeysRy, 1 do
		local keyframe = {};
		local key = self.startKeysRy[i];
		-- Copy the keyframe properties
		keyframe.time = key[1];
		keyframe.value = key[2];
		keyframe.interpolationIn = key[3];
		keyframe.interpolationOut = key[4];
		-- Add the keyframe to the keysRy table
		self.track.keysRy[i] = keyframe;
	end

	-- Reset the keysRz table
	self.track.keysRz = {};
	-- Iterate over the startKeysRz table
	for i = 1, #self.startKeysRz, 1 do
		local keyframe = {};
		local key = self.startKeysRz[i];
		-- Copy the keyframe properties
		keyframe.time = key[1];
		keyframe.value = key[2];
		keyframe.interpolationIn = key[3];
		keyframe.interpolationOut = key[4];
		-- Add the keyframe to the keysRz table
		self.track.keysRz[i] = keyframe;
	end

	-- Reset the keysA table
	self.track.keysA = {};
	-- Iterate over the startKeysA table
	for i = 1, #self.startKeysA, 1 do
		local keyframe = {};
		local key = self.startKeysA[i];
		-- Copy the keyframe properties
		keyframe.time = key[1];
		keyframe.value = key[2];
		keyframe.interpolationIn = key[3];
		keyframe.interpolationOut = key[4];
		-- Add the keyframe to the keysA table
		self.track.keysA[i] = keyframe;
	end

	-- Refresh the workspace to reflect the changes
	AM.RefreshWorkspace();
end

-- Redo function to update the keyframes of the track
function TrackKeyframes:Redo()
	-- Clear the keysPx table
	self.track.keysPx = {};
	-- Iterate over the endKeysPx table
	for i = 1, #self.endKeysPx, 1 do
		local keyframe = {};
		local key = self.endKeysPx[i];
		-- Set the keyframe properties
		keyframe.time = key[1];
		keyframe.value = key[2];
		keyframe.interpolationIn = key[3];
		keyframe.interpolationOut = key[4];
		-- Add the keyframe to the keysPx table
		self.track.keysPx[i] = keyframe;
	end

	-- Clear the keysPy table
	self.track.keysPy = {};
	-- Iterate over the endKeysPy table
	for i = 1, #self.endKeysPy, 1 do
		local keyframe = {};
		local key = self.endKeysPy[i];
		-- Set the keyframe properties
		keyframe.time = key[1];
		keyframe.value = key[2];
		keyframe.interpolationIn = key[3];
		keyframe.interpolationOut = key[4];
		-- Add the keyframe to the keysPy table
		self.track.keysPy[i] = keyframe;
	end

	-- Clear the keysPz table
	self.track.keysPz = {};
	-- Iterate over the endKeysPz table
	for i = 1, #self.endKeysPz, 1 do
		local keyframe = {};
		local key = self.endKeysPz[i];
		-- Set the keyframe properties
		keyframe.time = key[1];
		keyframe.value = key[2];
		keyframe.interpolationIn = key[3];
		keyframe.interpolationOut = key[4];
		-- Add the keyframe to the keysPz table
		self.track.keysPz[i] = keyframe;
	end

	-- Clear the keysRx table
	self.track.keysRx = {};
	-- Iterate over the endKeysRx table
	for i = 1, #self.endKeysRx, 1 do
		local keyframe = {};
		local key = self.endKeysRx[i];
		-- Set the keyframe properties
		keyframe.time = key[1];
		keyframe.value = key[2];
		keyframe.interpolationIn = key[3];
		keyframe.interpolationOut = key[4];
		-- Add the keyframe to the keysRx table
		self.track.keysRx[i] = keyframe;
	end

	-- Clear the keysRy table
	self.track.keysRy = {};
	-- Iterate over the endKeysRy table
	for i = 1, #self.endKeysRy, 1 do
		local keyframe = {};
		local key = self.endKeysRy[i];
		-- Set the keyframe properties
		keyframe.time = key[1];
		keyframe.value = key[2];
		keyframe.interpolationIn = key[3];
		keyframe.interpolationOut = key[4];
		-- Add the keyframe to the keysRy table
		self.track.keysRy[i] = keyframe;
	end

	-- Clear the keysRz table
	self.track.keysRz = {};
	-- Iterate over the endKeysRz table
	for i = 1, #self.endKeysRz, 1 do
		local keyframe = {};
		local key = self.endKeysRz[i];
		-- Set the keyframe properties
		keyframe.time = key[1];
		keyframe.value = key[2];
		keyframe.interpolationIn = key[3];
		keyframe.interpolationOut = key[4];
		-- Add the keyframe to the keysRz table
		self.track.keysRz[i] = keyframe;
	end

	-- Clear the keysA table
	self.track.keysA = {};
	-- Iterate over the endKeysA table
	for i = 1, #self.endKeysA, 1 do
		local keyframe = {};
		local key = self.endKeysA[i];
		-- Set the keyframe properties
		keyframe.time = key[1];
		keyframe.value = key[2];
		keyframe.interpolationIn = key[3];
		keyframe.interpolationOut = key[4];
		-- Add the keyframe to the keysA table
		self.track.keysA[i] = keyframe;
	end

	-- Refresh the workspace
	AM.RefreshWorkspace();
end