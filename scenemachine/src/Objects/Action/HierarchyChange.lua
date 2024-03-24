local SH = SceneMachine.Editor.SceneHierarchy;
local OP = SceneMachine.Editor.ObjectProperties;

SceneMachine.Actions.HierarchyChange = {};

local Action = SceneMachine.Actions.Action;
local HierarchyChange = SceneMachine.Actions.HierarchyChange;
HierarchyChange.__index = HierarchyChange;
setmetatable(HierarchyChange, Action)

function HierarchyChange:New(hierarchy)
	local v = 
    {
        type = Action.Type.HierarchyChange,
		memorySize = 4,
		memoryUsage = 0,
		startHierarchy = SH.CopyObjectHierarchy(hierarchy);
    };

	setmetatable(v, HierarchyChange)

	for i = 1, #hierarchy, 1 do
		v.memorySize = v.memorySize + self:CalculateSize(hierarchy[i]);
	end

	return v
end

function HierarchyChange:CalculateSize(hobject, currentSize)
	if (currentSize == nil) then
		currentSize = 1;
	end

	for i = 1, #hobject.childObjects, 1 do
		currentSize = currentSize + self:CalculateSize(hobject.childObjects[i], currentSize);
	end

	return currentSize;
end

function HierarchyChange:Finish(hierarchy)
	self.endHierarchy = SH.CopyObjectHierarchy(hierarchy);
end

function HierarchyChange:Undo()
	SH.SetHierarchy(self.startHierarchy);
	SH.RefreshHierarchy();
end

function HierarchyChange:Redo()
	SH.SetHierarchy(self.endHierarchy);
	SH.RefreshHierarchy();
end