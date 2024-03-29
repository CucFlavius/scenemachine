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
	};

	setmetatable(v, HierarchyChange)

	for i = 1, #hierarchy, 1 do
		v.memorySize = v.memorySize + self:CalculateSize(hierarchy[i]);
	end

	return v
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
end

--- Undoes the hierarchy change by setting the hierarchy back to its initial state and refreshing it.
function HierarchyChange:Undo()
	SM.loadedScene:SetObjectHierarchy(self.startHierarchy);
	SH.RefreshHierarchy();
end

--- Redo the hierarchy change action.
function HierarchyChange:Redo()
	SM.loadedScene:SetObjectHierarchy(self.endHierarchy);
	SH.RefreshHierarchy();
end