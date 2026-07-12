local SH = SceneMachine.Editor.SceneHierarchy;
local SM = SceneMachine.Editor.SceneManager;

SceneMachine.Actions.HierarchyChange = {};

local Action = SceneMachine.Actions.Action;
local Scene = SceneMachine.Scene;

--- @class HierarchyChange : Action
local HierarchyChange = SceneMachine.Actions.HierarchyChange;

HierarchyChange.__index = HierarchyChange;
setmetatable(HierarchyChange, Action)

--- Creates a new instance of the HierarchyChange action.
--- @param hierarchy table The object hierarchy to be changed.
--- @return HierarchyChange v The newly created HierarchyChange action.
function HierarchyChange:New(hierarchy)
	--- @class HierarchyChange : Action
	local v =
	{
		type = Action.Type.HierarchyChange,
		memorySize = 4,
		memoryUsage = 0,
		startHierarchy = Scene.RawCopyObjectHierarchy(hierarchy);
		-- reparenting rewrites local transforms (world-preserving), so snapshot them too
		startTransforms = HierarchyChange.CaptureTransforms();
	};

	setmetatable(v, HierarchyChange)

	for i = 1, #hierarchy, 1 do
		v.memoryUsage = v.memoryUsage + self:CalculateSize(hierarchy[i]) * v.memorySize;
	end

	return v
end

--- Captures the local transforms of every object in the loaded scene, keyed by object id.
--- @return table transforms The captured transforms.
function HierarchyChange.CaptureTransforms()
	local transforms = {};
	local scene = SM.loadedScene;
	for i = 1, scene:GetObjectCount(), 1 do
		local object = scene:GetObject(i);
		local pos = object:GetPosition();
		local rot = object:GetRotation();
		transforms[object.id] = {
			px = pos.x, py = pos.y, pz = pos.z,
			rx = rot.x, ry = rot.y, rz = rot.z,
			s = object:GetScale(),
		};
	end
	return transforms;
end

--- Applies previously captured local transforms (call after the hierarchy is restored).
--- @param transforms table The transforms captured by CaptureTransforms.
function HierarchyChange:ApplyTransforms(transforms)
	if (not transforms) then
		return;
	end
	local scene = SM.loadedScene;
	for id, t in pairs(transforms) do
		local object = scene:GetObjectByID(id);
		if (object) then
			object:SetPosition(t.px, t.py, t.pz);
			object:SetRotation(t.rx, t.ry, t.rz);
			object:SetScale(t.s);
		end
	end
end

--- Calculates the size of a hierarchy of objects.
--- @param hobject table The root object of the hierarchy.
--- @param currentSize? number The current size of the hierarchy (optional).
--- @return number size The size of the hierarchy.
function HierarchyChange:CalculateSize(hobject, currentSize)
	if (currentSize == nil) then
		currentSize = 1;
	end

	for i = 1, #hobject.childObjects, 1 do
		currentSize = currentSize + self:CalculateSize(hobject.childObjects[i], currentSize);
	end

	return currentSize;
end

--- Finishes the hierarchy change action by copying the object hierarchy.
--- @param hierarchy table The object hierarchy to be copied.
function HierarchyChange:Finish(hierarchy)
	self.endHierarchy = Scene.RawCopyObjectHierarchy(hierarchy);
	self.endTransforms = HierarchyChange.CaptureTransforms();
end

--- Undoes the hierarchy change by setting the hierarchy back to its initial state and refreshing it.
function HierarchyChange:Undo()
	SM.loadedScene:SetObjectHierarchy(self.startHierarchy);
	self:ApplyTransforms(self.startTransforms);
	SH.RefreshHierarchy();
end

--- Redo the hierarchy change action.
function HierarchyChange:Redo()
	SM.loadedScene:SetObjectHierarchy(self.endHierarchy);
	self:ApplyTransforms(self.endTransforms);
	SH.RefreshHierarchy();
end