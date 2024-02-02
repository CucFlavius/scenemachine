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
    -- x, y are relative coordinates to the viewport
    local idx = 1;
    MousePick.selectionList = {};

    for i in pairs(SM.loadedScene.objects) do
        local object = SM.loadedScene.objects[i];

        -- Can't select invisible/frozen, only in the hierarchy
        if (object.visible) and (not object.frozen) then

            local xMin, yMin, zMin, xMax, yMax, zMax = object:GetActiveBoundingBox();
            
            if (xMax == nil) then
                return;
            end

            local ray = Camera.GetMouseRay();
            local bb = BoundingBox:New();
            bb:SetFromMinMaxAABB(xMin, yMin, zMin, xMax, yMax, zMax);

            if (ray:IntersectsBoundingBox(bb, object:GetPosition(), object:GetRotation(), object:GetScale())) then
                MousePick.selectionList[idx] = object;
                idx = idx + 1;
            end
        end
    end

    -- go through each selection list item and determine which one to select
    if (#MousePick.selectionList == 0) then
        SM.selectedObject = nil;
    elseif (#MousePick.selectionList == 1) then
        SM.selectedObject = MousePick.selectionList[1];
    else
        if (MousePick.CompareSelectionLists(MousePick.previousSelectionList, MousePick.selectionList)) then
            -- same selection list, so loop through to determine which one to select next
            for i = 1, #MousePick.selectionList, 1 do
                if (SM.selectedObject == MousePick.selectionList[i]) then
                    local currentIndex = i;
                    if (currentIndex >= #MousePick.selectionList) then
                        -- loop back
                        currentIndex = 0;
                    end
                    -- select next
                    SM.selectedObject = MousePick.selectionList[currentIndex + 1];
                    break;
                end
            end
        else
            -- different selection list, so just select first object
            SM.selectedObject = MousePick.selectionList[1];
        end
    end

    -- store previous selection list
    MousePick.previousSelectionList = {};
    for i = 1, #MousePick.selectionList, 1 do
        MousePick.previousSelectionList[i] = MousePick.selectionList[i];
    end

    -- also select track if available
    if (SM.selectedObject ~= nil) then
        AM.SelectTrackOfObject(SM.selectedObject);
    end

    SH.RefreshHierarchy();
    OP.Refresh();
end

function MousePick.CompareSelectionLists(listA, listB)
    if (#listA ~= #listB) then
        return false;
    end

    local same = true;
    for i = 1, #listA, 1 do
        if (listA[i] ~= listB[i]) then
            same = false;
        end
    end

    return same;
end