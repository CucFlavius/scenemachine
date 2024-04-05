local Editor = SceneMachine.Editor;
local PM = Editor.ProjectManager;
local SM = Editor.SceneManager;
local UI = SceneMachine.UI;
local L = Editor.localization;

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
    PM.window:MakeWholeWindowDraggable();

    -- project list frame --
    PM.projectListFrame = UI.Rectangle:New(0, 0, managerWindowWidth, managerWindowHeight, PM.window:GetFrame(), "TOPLEFT", "TOPLEFT", 0, 0, 0, 0);

    PM.projectList = UI.PooledScrollList:NewTLBR(10, -10, 0, 30, PM.projectListFrame:GetFrame(), "TOPLEFT", "TOPLEFT");
	PM.projectList:SetItemTemplate(
		{
            replaceAnim = nil,
			height = 20,
			buildItem = function(item)
				-- main button --
				item.components[1] = UI.Button:NewAP(item:GetFrame(), "");

				-- project name text --
				item.components[2] = UI.Label:New(10, 0, 200, 18, item.components[1]:GetFrame(), "LEFT", "LEFT", "");
			end,
			refreshItem = function(entry, item)
                -- main button --
				item.components[1]:SetScript("OnClick", function()
                    PM.selectedProjectID = entry.ID;
                    PM.projectList:RefreshStatic();
                end);

				if (entry.ID == PM.selectedProjectID) then
					item.components[1]:SetColor(UI.Button.State.Normal, 0, 0.4765, 0.7968, 1);
				else
					item.components[1]:SetColor(UI.Button.State.Normal, 0.1757, 0.1757, 0.1875, 1);
				end

				-- object name text --
				item.components[2]:SetText(entry.name);
			end,
	    }
    );

    PM.projectList:SetFrameLevel(10);
	PM.projectList:MakePool();

    local buttonSpacing = 5;
    PM.newProjectButton = UI.Button:New(10, 10, 60, 40, PM.projectListFrame:GetFrame(), "BOTTOMLEFT", "BOTTOMLEFT", L["PM_BUTTON_NEW_PROJECT"], nil);
    PM.newProjectButton:SetScript("OnClick", function(self) PM.ButtonNewProject() end);
    PM.loadProjectButton = UI.Button:New(60 + (buttonSpacing) + 10, 10, 60, 40, PM.projectListFrame:GetFrame(), "BOTTOMLEFT", "BOTTOMLEFT", L["PM_BUTTON_LOAD_PROJECT"], nil);
    PM.loadProjectButton:SetScript("OnClick", function(self) PM.ButtonLoadProject() end);
    PM.editProjectButton = UI.Button:New((60 * 2) + (buttonSpacing * 2) + 10, 10, 60, 40, PM.projectListFrame:GetFrame(), "BOTTOMLEFT", "BOTTOMLEFT", L["PM_BUTTON_EDIT_PROJECT"], nil);
    PM.editProjectButton:SetScript("OnClick", function(self) PM.ButtonEditProject() end);
    PM.deleteProjectButton = UI.Button:New((60 * 3) + (buttonSpacing * 3) + 10, 10, 60, 40, PM.projectListFrame:GetFrame(), "BOTTOMLEFT", "BOTTOMLEFT", L["PM_BUTTON_REMOVE_PROJECT"], nil);
    PM.deleteProjectButton:SetScript("OnClick", function(self) PM.ButtonDeleteProject() end);
    PM.saveDataButton = UI.Button:New((60 * 4) + (buttonSpacing * 4) + 10, 10, 60, 40, PM.projectListFrame:GetFrame(), "BOTTOMLEFT", "BOTTOMLEFT", L["PM_BUTTON_SAVE_DATA"], nil);
    PM.saveDataButton:SetScript("OnClick", function(self) Editor.Save() end);

    PM.window:Hide();
end

function PM.LoadSavedData()
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
    local project = PM.CreateProject("MyNewProject");
    project.lastLoaded = true;
    return project.ID;
end

function PM.LoadProjectByIndex(index)
    PM.selectedProjectID = PM.projectListIDs[index];
    PM.LoadProject(PM.selectedProjectID);
end

function PM.LoadProject(ID)
    --print("PM.LoadProject("..ID..")");
    PM.currentProject = PM.projects[ID];
    
    for ID in pairs(PM.projects) do 
        PM.projects[ID].lastLoaded = false
    end

    PM.currentProject.lastLoaded = true;

    if (PM.currentProject == nil) then
        print("Exception: PM.projects doesn't contain ID:" .. ID);
        return;
    end

    SceneMachine.mainWindow:SetTitle(string.format(L["EDITOR_MAIN_WINDOW_TITLE"], Editor.version, PM.currentProject.name));

    if (#PM.currentProject.scenes == 0) then
        -- current project has no scenes, create a default one
        SM.CreateDefaultScene();
        SM.RefreshSceneTabs();
    end

    -- Load last scene
    if (PM.currentProject.lastOpenScene ~= nil) then
        SM.LoadScene(PM.currentProject.lastOpenScene);
    else
        SM.LoadScene(1);
    end

    -- update scene tabs with available scenes
    SM.RefreshSceneTabs();

    Editor.RefreshProjectsDropdown();
    Editor.ClearActions();
end

function PM.LoadLastProject()
    for ID in pairs(PM.projects) do 
        if (PM.projects[ID].lastLoaded == true) then
            PM.LoadProject(ID);
            return;
        end
    end
end

function PM.GenerateUniqueProjectID()
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
    PM.window:SetTitle(L["PM_WINDOW_TITLE"]);
    PM.RefreshProjectWindow();
end

function PM.RefreshProjectWindow()
    local data = {};
    local index = 1;
    for ID in pairs(PM.projects) do
        data[index] = PM.projects[ID];
        index = index + 1;
    end

    PM.projectList:SetData(data);
    Editor.RefreshProjectsDropdown();
end

function PM.ButtonNewProject()
    local action = function(text)
        local project = PM.CreateProject(text);
        PM.RefreshProjectWindow();
    end;
    Editor.OpenQuickTextbox(action, L["PM_PROJECT_NAME"], L["PM_NEW_PROJECT"]);
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

    local action = function(text)
        local project = PM.projects[PM.selectedProjectID];
        project.name = text;
        PM.RefreshProjectWindow();
    end;
    Editor.OpenQuickTextbox(action, PM.projects[PM.selectedProjectID].name, L["PM_EDIT_PROJECT"]);
end

function PM.ButtonDeleteProject()
    if (PM.selectedProjectID == nil) then
        return;
    end

    -- ask for restart / or restart --
    Editor.OpenMessageBox(PM.window:GetFrame(), L["PM_MSG_DELETE_PROJECT_TITLE"], L["PM_MSG_DELETE_PROJECT_MESSAGE"], true, true, function() PM.DeleteProject(PM.selectedProjectID) end, function() end);
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