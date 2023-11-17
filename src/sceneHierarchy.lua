local Win = ZWindowAPI;
local Editor = SceneMachine.Editor;
local PM = Editor.ProjectManager;
local SM = Editor.SceneManager;
local SH = Editor.SceneHierarchy;
local Gizmos = SceneMachine.Gizmos;

function SH.CreatePanel(w, h, c4)
    local leftPanelHeight = Editor.height - Editor.toolbarHeight;
    local leftPanel = Win.CreateRectangle(0, -Editor.toolbarHeight, w, h, SceneMachine.mainWindow, "TOPLEFT", "TOPLEFT", c4[1], c4[2], c4[3], 1);
    local group = Editor.CreateGroup("Hierarchy", h, leftPanel);

    SH.scrollList = Win.CreateScrollList(5, -5, w - 20, h - 30, group, "TOPLEFT", "TOPLEFT");
    SH.list = Win.ItemList(w - 45, 20, SH.scrollList.ContentFrame, function(index) 
        if (index > 0) then
            SH.SelectObject(index)
        end
    end);

    SH.RefreshHierarchy();
end

function SH.RefreshHierarchy()
    if (PM.currentProject == nil) then
        return
    end
        
    SH.list:Clear();

    local index = 1;
    local scene = PM.currentProject.scenes[SM.loadedSceneIndex];
    for i in pairs(scene.objects) do
        local object = scene.objects[i];
        SH.list:SetItem(index, object.name);
        index = index + 1;
    end

    -- resize --
    SH.scrollList.Scrollbar:SetMinMaxValues(0, max((index * 20) - (150), 1));
	SH.scrollList.Scrollbar:SetValueStep(1);

    Gizmos.refresh = true;
end

function SH.SelectObject(index)
    local scene = PM.currentProject.scenes[SM.loadedSceneIndex];
    SM.selectedObject = scene.objects[index];
    Gizmos.refresh = true;
end