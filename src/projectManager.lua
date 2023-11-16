SceneMachine.Editor = SceneMachine.Editor or {};
local Win = ZWindowAPI;
local Editor = SceneMachine.Editor;
Editor.ProjectManager = Editor.ProjectManager or {};
local PM = Editor.ProjectManager;
Editor.SceneManager = Editor.SceneManager or {};
local SM = Editor.SceneManager;

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
    PM.window = Win.CreatePopupWindow(0, 0, managerWindowWidth, managerWindowHeight, SceneMachine.mainWindow, "CENTER", "CENTER", "ProjectManager");
    local dropShadow = Win.CreateImageBox(0, 10, managerWindowWidth * 1.20, managerWindowHeight * 1.29, PM.window, "CENTER", "CENTER",
	"Interface\\Addons\\scenemachine\\static\\textures\\dropShadowSquare.png");
    dropShadow:SetFrameStrata("MEDIUM");
    PM.window.texture:SetColorTexture(c4[1], c4[2], c4[3],1);
    PM.window.TitleBar.texture:SetColorTexture(c1[1], c1[2], c1[3], 1);
    PM.window.CloseButton.ntex:SetColorTexture(c1[1], c1[2], c1[3], 1);
    PM.window.CloseButton.htex:SetColorTexture(c2[1], c2[2], c2[3], 1);
    PM.window.CloseButton.ptex:SetColorTexture(c3[1], c3[2], c3[3], 1);

    -- project list frame --
    PM.projectListFrame = Win.CreateRectangle(0, 0, managerWindowWidth, managerWindowHeight, PM.window, "TOPLEFT", "TOPLEFT", 0, 0, 0, 0);
    PM.projectScrollList = Win.CreateScrollList(10, -10, managerWindowWidth - 20, 200, PM.projectListFrame, "TOPLEFT", "TOPLEFT");
    PM.projectList = Win.ItemList(PM.projectScrollList:GetWidth() - 30, 20, PM.projectScrollList.ContentFrame, function(index) 
        if (index > 0) then
            PM.selectedProjectID = PM.projectListIDs[index];
        end
     end);

    local buttonSpacing = 5;
    PM.newProjectButton = Win.CreateButton(10, 10, 60, 40, PM.projectListFrame, "BOTTOMLEFT", "BOTTOMLEFT", "New Project", nil, Win.BUTTON_VS);
    PM.newProjectButton:SetScript("OnClick", function(self) PM.ButtonNewProject() end);
    PM.loadProjectButton = Win.CreateButton(60 + (buttonSpacing) + 10, 10, 60, 40, PM.projectListFrame, "BOTTOMLEFT", "BOTTOMLEFT", "Load Project", nil, Win.BUTTON_VS);
    PM.loadProjectButton:SetScript("OnClick", function(self) PM.ButtonLoadProject() end);
    PM.editProjectButton = Win.CreateButton((60 * 2) + (buttonSpacing * 2) + 10, 10, 60, 40, PM.projectListFrame, "BOTTOMLEFT", "BOTTOMLEFT", "Edit Project", nil, Win.BUTTON_VS);
    PM.editProjectButton:SetScript("OnClick", function(self) PM.ButtonEditProject() end);
    PM.deleteProjectButton = Win.CreateButton((60 * 3) + (buttonSpacing * 3) + 10, 10, 60, 40, PM.projectListFrame, "BOTTOMLEFT", "BOTTOMLEFT", "Remove Project", nil, Win.BUTTON_VS);
    PM.deleteProjectButton:SetScript("OnClick", function(self) PM.ButtonDeleteProject() end);
    PM.saveDataButton = Win.CreateButton((60 * 4) + (buttonSpacing * 4) + 10, 10, 60, 40, PM.projectListFrame, "BOTTOMLEFT", "BOTTOMLEFT", "Save Data", nil, Win.BUTTON_VS);
    PM.saveDataButton:SetScript("OnClick", function(self) Editor.Save() end);

    -- project edit frame --
    PM.projectEditFrame = Win.CreateRectangle(0, 0, managerWindowWidth, managerWindowHeight, PM.window, "TOPLEFT", "TOPLEFT", 0, 0, 0, 0);
    PM.projectEditFrame_NameBox = Win.CreateEditBox(10, -10, 300, 20, PM.projectEditFrame, "TOPLEFT", "TOPLEFT", "", 12);

    PM.saveEditProjectButton = Win.CreateButton(10, 10, 60, 40, PM.projectEditFrame, "BOTTOMLEFT", "BOTTOMLEFT", "Save", nil, Win.BUTTON_VS);
    PM.saveEditProjectButton:SetScript("OnClick", function(self) PM.ButtonSaveEditProject() end);
    PM.closeEditProjectButton = Win.CreateButton(60 + 10 + 10, 10, 60, 40, PM.projectEditFrame, "BOTTOMLEFT", "BOTTOMLEFT", "Cancel", nil, Win.BUTTON_VS);
    PM.closeEditProjectButton:SetScript("OnClick", function(self) PM.ButtonCancelEditProject() end);

    PM.window:Hide();
end

function PM.LoadSavedData()
    print("PM.LoadSavedData()");
    PM.projects = scenemachine_projects or {};

    local lastID = nil;

    if (PM.GetProjectCount() == 0) then
        -- no projects loaded, create new default
        lastID = PM.CreateDefaultProject();
    end

    -- load last project
    PM.LoadLastProject();
end

function PM.CreateProject(name)
    print("PM.CreateProject("..name..")");
    local ID = PM.GenerateUniqueProjectID();
    PM.projects[ID] = {};
    PM.projects[ID].ID = ID;
    PM.projects[ID].name = name;
    PM.projects[ID].scenes = {};
    return PM.projects[ID];
end

function PM.CreateDefaultProject()
    print("PM.CreateDefaultProject()");
    local project = PM.CreateProject("MyNewProject");
    project.lastLoaded = true;
    return project.ID;
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

    SceneMachine.mainWindow.TitleBar.text:SetText("Editor " .. PM.currentProject.name);

    -- Load last scene
    if (PM.currentProject.lastOpenScene ~= nil) then
        SM.LoadScene(PM.currentProject.lastOpenScene);
    else
        SM.LoadScene(1);
    end

    -- update scene tabs with available scenes
    SM.RefreshSceneTabs();
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
    PM.window.TitleBar.text:SetText("Project Manager");
    PM.RefreshProjectWindow();
end

function PM.RefreshProjectWindow()
    PM.projectList:Clear();
    local index = 1;
    for ID in pairs(PM.projects) do
        PM.projectList:SetItem(index, PM.projects[ID].name .. " " .. ID);
        PM.projectListIDs[index] = ID;
        index = index + 1;
    end

    -- resize --
    PM.projectScrollList.Scrollbar:SetMinMaxValues(0, max((index * 20) - (150), 1));
	PM.projectScrollList.Scrollbar:SetValueStep(1);
end

function PM.ButtonNewProject()
    PM.projectListFrame:Hide();
    PM.projectEditFrame:Show();
    PM.window.TitleBar.text:SetText("New Project");

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
    PM.window.TitleBar.text:SetText("Edit Project");

    -- fill in existing info --
    PM.projectEditFrame_NameBox:SetText(PM.projects[PM.selectedProjectID].name);
end

function PM.ButtonCancelEditProject()
    PM.projectListFrame:Show();
    PM.projectEditFrame:Hide();
    PM.window.TitleBar.text:SetText("Project Manager");
end

function PM.ButtonSaveEditProject()
    PM.projectListFrame:Show();
    PM.projectEditFrame:Hide();
    PM.window.TitleBar.text:SetText("Project Manager");

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
    Win.OpenMessageBox(PM.window, 
    "Remove Project", "Removing the project will also remove all its scenes and data, continue?",
    true, true, function() PM.DeleteProject(PM.selectedProjectID) end, function() end);
    Win.messageBox:SetFrameStrata("DIALOG");
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

    PM.RefreshProjectWindow();
end

function PM.GetProjectCount()
    local c = 0
    for k,v in pairs(PM.projects) do
         c = c+1
    end
    return c
end