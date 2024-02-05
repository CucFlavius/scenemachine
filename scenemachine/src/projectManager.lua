local Editor = SceneMachine.Editor;
local PM = Editor.ProjectManager;
local SM = Editor.SceneManager;
local UI = SceneMachine.UI;

local c1 = { 0.1757, 0.1757, 0.1875 };
local c2 = { 0.242, 0.242, 0.25 };
local c3 = { 0, 0.4765, 0.7968 };
local c4 = { 0.1171, 0.1171, 0.1171 };

local managerWindowWidth = 500;
local managerWindowHeight = 300;

PM.currentProject = nil;
PM.selectedProjectID = nil;
PM.projectListIDs = {};

function PM.CreateWindow()
    -- Window:New(x, y, w, h, parent, point, parentPoint, title)
    PM.window = UI.Window:New(0, 0, managerWindowWidth, managerWindowHeight, SceneMachine.mainWindow:GetFrame(), "CENTER", "CENTER", "ProjectManager");
    PM.window:SetFrameStrata(Editor.SUB_FRAME_STRATA);
    local dropShadow = UI.ImageBox:New(0, 10, managerWindowWidth * 1.20, managerWindowHeight * 1.29, PM.window:GetFrame(), "CENTER", "CENTER",
	"Interface\\Addons\\scenemachine\\static\\textures\\dropShadowSquare.png");
    dropShadow:SetFrameStrata(Editor.MAIN_FRAME_STRATA);

    -- project list frame --
    PM.projectListFrame = UI.Rectangle:New(0, 0, managerWindowWidth, managerWindowHeight, PM.window:GetFrame(), "TOPLEFT", "TOPLEFT", 0, 0, 0, 0);

    PM.projectScrollList = UI.ScrollFrame:New(10, -10, managerWindowWidth - 20, 200, PM.projectListFrame:GetFrame(), "TOPLEFT", "TOPLEFT");
    PM.projectList = UI.ItemList:New(PM.projectScrollList:GetWidth() - 30, 20, PM.projectScrollList.contentFrame, function(index) 
        if (index > 0) then
            PM.selectedProjectID = PM.projectListIDs[index];
        end
     end);

    local buttonSpacing = 5;
    PM.newProjectButton = UI.Button:New(10, 10, 60, 40, PM.projectListFrame:GetFrame(), "BOTTOMLEFT", "BOTTOMLEFT", "New Project", nil);
    PM.newProjectButton:SetScript("OnClick", function(self) PM.ButtonNewProject() end);
    PM.loadProjectButton = UI.Button:New(60 + (buttonSpacing) + 10, 10, 60, 40, PM.projectListFrame:GetFrame(), "BOTTOMLEFT", "BOTTOMLEFT", "Load Project", nil);
    PM.loadProjectButton:SetScript("OnClick", function(self) PM.ButtonLoadProject() end);
    PM.editProjectButton = UI.Button:New((60 * 2) + (buttonSpacing * 2) + 10, 10, 60, 40, PM.projectListFrame:GetFrame(), "BOTTOMLEFT", "BOTTOMLEFT", "Edit Project", nil);
    PM.editProjectButton:SetScript("OnClick", function(self) PM.ButtonEditProject() end);
    PM.deleteProjectButton = UI.Button:New((60 * 3) + (buttonSpacing * 3) + 10, 10, 60, 40, PM.projectListFrame:GetFrame(), "BOTTOMLEFT", "BOTTOMLEFT", "Remove Project", nil);
    PM.deleteProjectButton:SetScript("OnClick", function(self) PM.ButtonDeleteProject() end);
    PM.saveDataButton = UI.Button:New((60 * 4) + (buttonSpacing * 4) + 10, 10, 60, 40, PM.projectListFrame:GetFrame(), "BOTTOMLEFT", "BOTTOMLEFT", "Save Data", nil);
    PM.saveDataButton:SetScript("OnClick", function(self) Editor.Save() end);

    -- project edit frame --
    PM.projectEditFrame = UI.Rectangle:New(0, 0, managerWindowWidth, managerWindowHeight, PM.window:GetFrame(), "TOPLEFT", "TOPLEFT", 0, 0, 0, 0);
    PM.projectEditFrame_NameBox = UI.TextBox:New(10, -10, 300, 20, PM.projectEditFrame:GetFrame(), "TOPLEFT", "TOPLEFT", "", 12);

    PM.saveEditProjectButton = UI.Button:New(10, 10, 60, 40, PM.projectEditFrame:GetFrame(), "BOTTOMLEFT", "BOTTOMLEFT", "Save", nil);
    PM.saveEditProjectButton:SetScript("OnClick", function(self) PM.ButtonSaveEditProject() end);
    PM.closeEditProjectButton = UI.Button:New(60 + 10 + 10, 10, 60, 40, PM.projectEditFrame:GetFrame(), "BOTTOMLEFT", "BOTTOMLEFT", "Cancel", nil);
    PM.closeEditProjectButton:SetScript("OnClick", function(self) PM.ButtonCancelEditProject() end);

    PM.window:Hide();
end

function PM.LoadSavedData()
    print("PM.LoadSavedData()");
    PM.projects = scenemachine_projects or {};

    PM.projectListIDs = {}
    local index = 1;
    for ID in pairs(PM.projects) do
        PM.projectListIDs[index] = ID;
        index = index + 1;
    end

    local lastID = nil;

    if (PM.GetProjectCount() == 0) then
        -- no projects loaded, create new default
        lastID = PM.CreateDefaultProject();
    end

    -- load last project
    PM.LoadLastProject();

    Editor.RefreshProjectsDropdown();
end

function PM.CreateProject(name)
    print("PM.CreateProject("..name..")");
    local ID = PM.GenerateUniqueProjectID();
    PM.projects[ID] = {};
    PM.projects[ID].ID = ID;
    PM.projects[ID].name = name;
    PM.projects[ID].scenes = {};

    Editor.RefreshProjectsDropdown();
    PM.projectListIDs = {}
    local index = 1;
    for ID in pairs(PM.projects) do
        PM.projectListIDs[index] = ID;
        index = index + 1;
    end

    return PM.projects[ID];
end

function PM.CreateDefaultProject()
    print("PM.CreateDefaultProject()");
    local project = PM.CreateProject("MyNewProject");
    project.lastLoaded = true;
    return project.ID;
end

function PM.LoadProjectByIndex(index)
    PM.selectedProjectID = PM.projectListIDs[index];
    PM.LoadProject(PM.selectedProjectID);
end

function PM.LoadProject(ID)
    print("PM.LoadProject("..ID..")");
    PM.currentProject = PM.projects[ID];
    
    for ID in pairs(PM.projects) do 
        PM.projects[ID].lastLoaded = false
    end

    PM.currentProject.lastLoaded = true;

    if (PM.currentProject == nil) then
        print("Exception: PM.projects doesn't contain ID:" .. ID);
        return;
    end

    SceneMachine.mainWindow:SetTitle("Scene Machine " .. Editor.version .. " - " .. PM.currentProject.name);

    -- Load last scene
    if (PM.currentProject.lastOpenScene ~= nil) then
        SM.LoadScene(PM.currentProject.lastOpenScene);
    else
        SM.LoadScene(1);
    end

    -- update scene tabs with available scenes
    SM.RefreshSceneTabs();

    Editor.RefreshProjectsDropdown();
end

function PM.LoadLastProject()
    print("PM.LoadLastProject()");
    for ID in pairs(PM.projects) do 
        if (PM.projects[ID].lastLoaded == true) then
            PM.LoadProject(ID);
            return;
        end
    end
end

function PM.GenerateUniqueProjectID()
    print("PM.GenerateUniqueProjectID()");
    local ID = "P"..math.random(999999);
    for ID in pairs(PM.projects) do
        if (PM.projects[ID].ID == ID) then
            ID = "P"..math.random(999999);
        end
    end
    return ID;
end

function PM.OpenWindow()
    PM.window:Show();
    PM.projectListFrame:Show();
    PM.projectEditFrame:Hide();
    PM.window:SetTitle("Project Manager");
    PM.RefreshProjectWindow();
end

function PM.RefreshProjectWindow()
    PM.projectList:Clear();
    local index = 1;
    for ID in pairs(PM.projects) do
        PM.projectList:SetItem(index, PM.projects[ID].name .. " " .. ID);
        index = index + 1;
    end

    -- resize --
    --PM.projectScrollList.Scrollbar:SetMinMaxValues(0, max((index * 20) - (150), 1));
	--PM.projectScrollList.Scrollbar:SetValueStep(1);
end

function PM.ButtonNewProject()
    PM.projectListFrame:Hide();
    PM.projectEditFrame:Show();
    PM.window:SetTitle("New Project");

    PM.projectEditFrame_NameBox:SetText("Project Name");
end

function PM.ButtonLoadProject()
    if (PM.selectedProjectID == nil) then
        return;
    end

    PM.LoadProject(PM.selectedProjectID);
    PM.window:Hide();
end

function PM.ButtonEditProject()
    if (PM.selectedProjectID == nil) then
        return;
    end

    PM.projectListFrame:Hide();
    PM.projectEditFrame:Show();
    PM.window:SetTitle("Edit Project");

    -- fill in existing info --
    PM.projectEditFrame_NameBox:SetText(PM.projects[PM.selectedProjectID].name);
end

function PM.ButtonCancelEditProject()
    PM.projectListFrame:Show();
    PM.projectEditFrame:Hide();
    PM.window:SetTitle("Project Manager");
end

function PM.ButtonSaveEditProject()
    PM.projectListFrame:Show();
    PM.projectEditFrame:Hide();
    PM.window:SetTitle("Project Manager");

    local projectName = PM.projectEditFrame_NameBox:GetText();

    local project = PM.projects[PM.selectedProjectID];
    if (project == nil) then
        -- make a new project
        project = PM.CreateProject(projectName);
    else
        project.name = projectName;
    end

    PM.RefreshProjectWindow();
end

function PM.ButtonDeleteProject()
    if (PM.selectedProjectID == nil) then
        return;
    end

    -- ask for restart / or restart --
    Editor.OpenMessageBox(PM.window:GetFrame(), "Remove Project", "Removing the project will also remove all its scenes and data, continue?", true, true, function() PM.DeleteProject(PM.selectedProjectID) end, function() end);
end

function PM.DeleteProject(ID)
    if (ID == nil) then
        return;
    end

    if (PM.currentProject ~= nil) then
        if (PM.currentProject.ID == ID) then
            -- unload the project and scenes first --
        end
    end

    PM.projects[ID] = nil;
    PM.projectListIDs = {}
    local index = 1;
    for ID in pairs(PM.projects) do
        PM.projectListIDs[index] = ID;
        index = index + 1;
    end
    
    PM.RefreshProjectWindow();
    Editor.RefreshProjectsDropdown();
end

function PM.GetProjectCount()
    local c = 0
    for k,v in pairs(PM.projects) do
         c = c+1
    end
    return c
end