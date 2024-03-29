local Editor = SceneMachine.Editor;
local MousePick = Editor.MousePick;
local Gizmos = SceneMachine.Gizmos;
local SM = Editor.SceneManager;
local SH = Editor.SceneHierarchy;
local Renderer = SceneMachine.Renderer;
local PM = Editor.ProjectManager;
local OP = Editor.ObjectProperties;
local Camera = SceneMachine.Camera;
local BoundingBox = SceneMachine.BoundingBox;
local Ray = SceneMachine.Ray;
local Vector3 = SceneMachine.Vector3;
local Quaternion = SceneMachine.Quaternion;
local AM = SceneMachine.Editor.AnimationManager;

function MousePick.Initialize()
    MousePick.previousSelectionList = {};
    MousePick.selectionList = {};
end

function MousePick.Pick(x, y)

    if (Gizmos.marqueeVisible) then
        return;
    end

    if (not SM.loadedScene) then
        return;
    end

    -- x, y are relative coordinates to the viewport
    local idx = 1;
    MousePick.selectionList = {};

    for i = 1, SM.loadedScene:GetObjectCount(), 1 do
        local object = SM.loadedScene:GetObject(i);

        local gizmoType = object:GetGizmoType();

        -- Can't select invisible/frozen, only in the hierarchy
        if (object.visible) and (not object.frozen) and (gizmoType == Gizmos.Type.Object) and
            (object:GetType() ~= SceneMachine.GameObjects.Object.Type.Group) then

            local xMin, yMin, zMin, xMax, yMax, zMax = object:GetActiveBoundingBox();
            
            if (xMax == nil) then
                return;
            end

            local ray = Camera.GetMouseRay();
            local bb = BoundingBox:New();
            bb:SetFromMinMaxAABB(xMin, yMin, zMin, xMax, yMax, zMax);

            local tNear, tFar = ray:IntersectsBoundingBox(bb, object:GetWorldPosition(), object:GetWorldRotation(), object:GetWorldScale())
            
            if (tNear <= tFar) then
                MousePick.selectionList[idx] = {};
                MousePick.selectionList[idx].object = object;
                MousePick.selectionList[idx].tNear = tNear;
                MousePick.selectionList[idx].tFar = tFar;
                idx = idx + 1;
            end
        end
    end

    MousePick.SortSelectionList(MousePick.selectionList);

    if (SceneMachine.Input.ControlModifier) then
        if (#MousePick.selectionList > 0) then
            for i = 1, #MousePick.selectionList, 1 do
                if (not MousePick.selectionList[i].object.selected) then    -- this is faster than SM.IsObjectSelected
                --if (not SM.IsObjectSelected(MousePick.selectionList[i].object)) then
                    SM.SelectObject(MousePick.selectionList[i].object);
                    break;
                end
            end
        end
    else
        -- go through each selection list item and determine which one to select
        if (#MousePick.selectionList == 0) then
            SM.SelectObject(nil);
        elseif (#MousePick.selectionList == 1) then

            -- if multiple objects are selected, trim the list to the first
            if (#SM.selectedObjects > 1) then
                SM.selectedObjects = { SM.selectedObjects[1].object }
            end

            SM.SelectObject(MousePick.selectionList[1].object);
        else
            if (MousePick.CompareSelectionLists(MousePick.previousSelectionList, MousePick.selectionList)) then
                -- same selection list, so loop through to determine which one to select next

                -- if multiple objects are selected, trim the list to the first
                if (#SM.selectedObjects > 1) then
                    SM.selectedObjects = { SM.selectedObjects[1] }
                end

                for i = 1, #MousePick.selectionList, 1 do
                    if (SM.selectedObjects[1] == MousePick.selectionList[i].object) then
                        local currentIndex = i;
                        if (currentIndex >= #MousePick.selectionList) then
                            -- loop back
                            currentIndex = 0;
                        end
                        -- select next
                        SM.selectedObjects[1] = MousePick.selectionList[currentIndex + 1].object;
                        break;
                    end
                end
            else
                -- different selection list, so just select first object
                SM.selectedObjects = { MousePick.selectionList[1].object }
            end
        end
    end

    -- store previous selection list
    MousePick.previousSelectionList = {};
    for i = 1, #MousePick.selectionList, 1 do
        MousePick.previousSelectionList[i] = MousePick.selectionList[i];
    end

    -- also select track if available
	-- only select a track if a one single object is selected, no multi-track selection support needed
    if (#SM.selectedObjects == 1) then
        AM.SelectTrackOfObject(SM.selectedObjects[1]);
		Editor.lastSelectedType = Editor.SelectionType.Object;
	else
        AM.SelectTrack(-1);
    end

    SH.RefreshHierarchy();
    OP.Refresh();
end

function MousePick.SortSelectionList(list)
    -- Sort the list based on the values in the 'numbers' table
    table.sort(list, function(a, b)
        return a.tNear < b.tNear;
    end);
end

function MousePick.CompareSelectionLists(listA, listB)
    if (#listA ~= #listB) then
        return false;
    end

    local same = true;
    for i = 1, #listA, 1 do
        if (listA[i].object ~= listB[i].object) then
            same = false;
        end
    end

    return same;
end