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
PM.selectedProjectID = nil;

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

    PM.projectScrollList = Win.CreateScrollList(10, -10, managerWindowWidth - 20, 200, PM.window, "TOPLEFT", "TOPLEFT");

    PM.newProjectButton = Win.CreateButton(10, 10, 60, 40, PM.window, "BOTTOMLEFT", "BOTTOMLEFT", "New Project", nil, Win.BUTTON_VS);
    PM.newProjectButton:SetScript("OnClick", function(self) PM.ButtonNewProject() end);
    PM.editProjectButton = Win.CreateButton(60 + 10 + 10, 10, 60, 40, PM.window, "BOTTOMLEFT", "BOTTOMLEFT", "Edit Project", nil, Win.BUTTON_VS);
    PM.editProjectButton:SetScript("OnClick", function(self) PM.ButtonEditProject() end);
    PM.deleteProjectButton = Win.CreateButton(60 + 10 + 60 + 10 + 10, 10, 60, 40, PM.window, "BOTTOMLEFT", "BOTTOMLEFT", "Remove Project", nil, Win.BUTTON_VS);
    PM.deleteProjectButton:SetScript("OnClick", function(self) PM.ButtonDeleteProject() end);

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
    local index = 0;
    for ID in pairs(PM.projects) do
        PM.CreateProjectListItem(PM.projects[ID].name .. " " .. ID, index, ID);
        index = index + 1;
    end

    PM.projectScrollList.ContentFrame:SetSize(PM.projectScrollList:GetWidth(), (index + 1) * 22);
end

function PM.CreateProjectListItem(name, index, ID)
	-- TODO : THESE NEED TO BE POOLED --
    
    -- properties --
    local x = 0;
    local y = -index * 21;
    local w = PM.projectScrollList:GetWidth() - 30;
    local h = 20;
    local parent = PM.projectScrollList.ContentFrame;
	local ButtonFont = Win.defaultFont;
	local ButtonFontSize = 9;

	-- main button frame --
	local projectItem = CreateFrame("Button", "Zee.WindowAPI.Button", parent)
	projectItem:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y);
	projectItem:SetWidth(w);
	projectItem:SetHeight(h)
	projectItem.ntex = projectItem:CreateTexture()
	projectItem.htex = projectItem:CreateTexture()
	projectItem.ptex = projectItem:CreateTexture()
    projectItem.ntex:SetColorTexture(0.1757, 0.1757, 0.1875 ,1);
    projectItem.htex:SetColorTexture(0.242, 0.242, 0.25,1);
    projectItem.ptex:SetColorTexture(0, 0.4765, 0.7968,1);
	projectItem.ntex:SetAllPoints()	
	projectItem.ptex:SetAllPoints()
	projectItem.htex:SetAllPoints()
	projectItem:SetNormalTexture(projectItem.ntex)
	projectItem:SetHighlightTexture(projectItem.htex)
	projectItem:SetPushedTexture(projectItem.ptex)

    -- project name text --
    projectItem.projectNameText = projectItem:CreateFontString("Zee.WindowAPI.Button Text");
    projectItem.projectNameText:SetFont(ButtonFont, ButtonFontSize, "NORMAL");
    projectItem.projectNameText:SetPoint("LEFT", projectItem, "LEFT", 10, 0);
    projectItem.projectNameText:SetText(name);

    projectItem.ID = ID;
    projectItem:SetScript("OnClick", function(self) PM.ProjectListItem_OnClick(self, index) end);
end

function PM.ProjectListItem_OnClick(self, index)
    -- deselect all other --
    for i=1, select("#", PM.projectScrollList.ContentFrame:GetChildren()) do
        local ChildFrame = select(i, PM.projectScrollList.ContentFrame:GetChildren())
        ChildFrame.ntex:SetColorTexture(0.1757, 0.1757, 0.1875 ,1);
    end

    -- select current --
    local projectItem = self;
    projectItem.ntex:SetColorTexture(0, 0.4765, 0.7968,1);

    PM.selectedProjectID = projectItem.ID;
end

function PM.ButtonNewProject()

end

function PM.ButtonEditProject()

end

function PM.ButtonDeleteProject()
    if (PM.selectedProjectID == nil) then
        return;
    end

    -- ask for restart / or restart --
    Win.OpenMessageBox(PM.window, 
    "Remove Project", "Removing the project will also remove all its scenes and data, continue?",
    true, true, function() PM.DeleteProject(PM.selectedProjectID) end, function() end)
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

function PM.SaveData()
    scenemachine_projects = PM.projects;

    -- ask for restart / or restart --
    Win.OpenMessageBox(PM.window, 
    "Save", "Saving requires a UI reload, continue?",
    true, true, function() ReloadUI(); end, function()  end
);
end

function PM.GetProjectCount()
    local c = 0
    for k,v in pairs(PM.projects) do
         c = c+1
    end
    return c
end