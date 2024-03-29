local SM = SceneMachine.Editor.SceneManager;
local AM = SceneMachine.Editor.AnimationManager;

SceneMachine.Actions.TrackAnimations = {};

local Action = SceneMachine.Actions.Action;
local AnimationClip = SceneMachine.AnimationClip;

--- @class TrackAnimations : Action
local TrackAnimations = SceneMachine.Actions.TrackAnimations;

TrackAnimations.__index = TrackAnimations;
setmetatable(TrackAnimations, Action)

--- Creates a new instance of the TrackAnimations class.
--- @param track table The track to associate with the animations.
--- @param timeline table The timeline to associate with the animations.
--- @return TrackAnimations v The newly created TrackAnimations object.
function TrackAnimations:New(track, timeline)
	--- @class TrackAnimations : Action
	local v = 
	{
		type = Action.Type.TrackAnimations,
		memorySize = 7,
		memoryUsage = 0,
		timeline = timeline,
		track = track,
		startAnimations = {},
	};

	setmetatable(v, TrackAnimations)

	-- save animations states
	for i = 1, #track.animations, 1 do
		local anim = track.animations[i];
		v.startAnimations[i] = AnimationClip:NewClone(anim);
	end

	v.memoryUsage = #track.animations * v.memorySize;

	return v
end

-- This function is called to finish tracking animations and store their information.
function TrackAnimations:Finish()
	self.endAnimations = {}
	for i = 1, #self.track.animations, 1 do
		local anim = self.track.animations[i];
		self.endAnimations[i] = AnimationClip:NewClone(anim);
	end
end

-- Undoes the tracked animations by restoring the initial state of the track.
function TrackAnimations:Undo()
	self.track.animations = {};
	for i = 1, #self.startAnimations, 1 do
		self.track.animations[i] = self.startAnimations[i];
	end

	AM.RefreshWorkspace();
end

--- Redo the track animations.
function TrackAnimations:Redo()
	self.track.animations = {};
	for i = 1, #self.endAnimations, 1 do
		self.track.animations[i] = self.endAnimations[i];
	end

	AM.RefreshWorkspace();
end