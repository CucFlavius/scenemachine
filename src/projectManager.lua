SceneMachine.Editor = SceneMachine.Editor or {};
local Win = ZWindowAPI;
local Editor = SceneMachine.Editor;
Editor.ProjectManager = Editor.ProjectManager or {};
local PM = Editor.ProjectManager;
local c1 = { 0.1757, 0.1757, 0.1875 };
local c2 = { 0.242, 0.242, 0.25 };
local c3 = { 0, 0.4765, 0.7968 };
local c4 = { 0.1171, 0.1171, 0.1171 };

local managerWindowWidth = 500;
local managerWindowHeight = 300;

PM.currentProject = nil;

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
    PM.window:Hide();
end

function PM.LoadSavedData()
    print("PM.LoadSavedData()");
    PM.projects = scenemachine_projects or {};

    local lastID = nil;
    if (#PM.projects == 0) then
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
    PM.RefreshProjectWindow();
end

function PM.RefreshProjectWindow()
    
end

function PM.SaveData()
    scenemachine_projects = PM.projects;

    -- ask for restart / or restart --
    Win.OpenMessageBox(SceneMachine.mainWindow, 
    "Save", "Saving requires a UI reload, continue?",
    true, true, function() ReloadUI(); end, function()  end
);
end