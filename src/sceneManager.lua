SceneMachine.Editor = SceneMachine.Editor or {};
local Win = ZWindowAPI;
local Editor = SceneMachine.Editor;
Editor.ProjectManager = Editor.ProjectManager or {};
local PM = Editor.ProjectManager;
Editor.SceneManager = Editor.SceneManager or {};
local SM = Editor.SceneManager;
local Renderer = SceneMachine.Renderer;
local Camera = SceneMachine.Camera;
SceneMachine.Player = SceneMachine.Player or {}
local Player = SceneMachine.Player;
local CameraController = SceneMachine.CameraController;
Editor.SceneHierarchy = Editor.SceneHierarchy or {};
local SH = Editor.SceneHierarchy;

local tabButtonHeight = 20;
local tabPool = {};

SM.loadedSceneIndex = 1;
SM.selectedObject = nil;

function SM.Create(x, y, w, h, parent)
    SM.groupBG = Win.CreateRectangle(x, y, w, h, parent, "TOPLEFT", "TOPLEFT",  0, 0, 0, 0);
    SceneMachine.Renderer.CreateRenderer(0, 0, w, h - tabButtonHeight, SM.groupBG, "BOTTOMLEFT", "BOTTOMLEFT");

    SM.addSceneButtonTab = SM.CreateNewSceneTab(0, 0, 20, tabButtonHeight, SM.groupBG);
    SM.addSceneButtonTab.text:SetText("+");
    SM.addSceneButtonTab.ntex:SetColorTexture(0, 0, 0 ,0);
    SM.addSceneButtonTab.text:SetAllPoints(SM.addSceneButtonTab);
    SM.addSceneButtonTab:Hide();

    SM.addSceneEditBox = Win.CreateEditBox(0, 0, 100, tabButtonHeight, SM.groupBG, "TOPLEFT", "TOPLEFT", "Scene Name");
    SM.addSceneEditBox:Hide();

    SM.RefreshSceneTabs();
end

function SM.RefreshSceneTabs()
    -- clear --
    for idx in pairs(tabPool) do
        tabPool[idx]:Hide();
    end

    -- add available scenes --
    local x = 0;
    if (PM.currentProject ~= nil) then
        for i in pairs(PM.currentProject.scenes) do
            local scene = PM.currentProject.scenes[i];
            if (tabPool[i] == nil) then
                tabPool[i] = SM.CreateNewSceneTab(x, 0, 50, tabButtonHeight, SM.groupBG);
                tabPool[i].text:SetText(scene.name);
                tabPool[i]:SetWidth(tabPool[i].text:GetStringWidth() + 20);
                tabPool[i]:RegisterForClicks("LeftButtonUp", "RightButtonUp");
                tabPool[i]:SetScript("OnClick", function(self, button, down)
                    if (button == "LeftButton") then
                        SM.SceneTabButtonOnClick(i);
                    elseif (button == "RightButton") then
                        local point, relativeTo, relativePoint, xOfs, yOfs = tabPool[i]:GetPoint(1);
                        SM.SceneTabButtonOnClick(i);
                        SM.SceneTabButtonOnRightClick(i, xOfs, -5);
                    end
                end);
            else
                tabPool[i].text:SetText(scene.name);
                tabPool[i]:SetWidth(tabPool[i].text:GetStringWidth() + 20);
            end

            tabPool[i]:Show();

            if (SM.loadedSceneIndex == i) then
                tabPool[i].ntex:SetColorTexture(0.1757, 0.1757, 0.1875 ,1);
            else
                tabPool[i].ntex:SetColorTexture(0, 0, 0 ,0);
            end

            x = x + tabPool[i]:GetWidth() + 1;
        end
    end

    -- add new scene button --
    SM.addSceneButtonTab:Show();
    SM.addSceneEditBox:Hide();
    SM.addSceneButtonTab:SetPoint("TOPLEFT", SM.groupBG, "TOPLEFT", x, 0);
    SM.addSceneButtonTab:SetScript("OnClick", function(self) 
        SM.Button_RenameScene(-1, x);
    end);
end

function SM.CreateDefaultScene()
    return SM.CreateScene();
end

function SM.SceneTabButtonOnClick(index)
    SM.LoadScene(index);
    SM.RefreshSceneTabs();
end

function SM.SceneTabButtonOnRightClick(index, x, y)
    -- open rmb menu with option to delete, edit, rename the scene
    local gpoint, grelativeTo, grelativePoint, gxOfs, gyOfs = SM.groupBG:GetPoint(1);

	local menuOptions = {
        [1] = { ["Name"] = "Rename", ["Action"] = function() SM.Button_RenameScene(index, x) end },
        [2] = { ["Name"] = "Edit", ["Action"] = function()  SM.Button_EditScene(index) end },
        [3] = { ["Name"] = "Delete", ["Action"] = function() SM.Button_DeleteScene(index) end },
	};

    Win.PopupWindowMenu(x + gxOfs, y + gyOfs, SceneMachine.mainWindow, menuOptions);
end

function SM.Button_RenameScene(index, x)
    SM.addSceneEditBox:Show();
    SM.addSceneEditBox:SetText("Scene " .. (#PM.currentProject.scenes));
    SM.addSceneButtonTab:Hide();
    SM.addSceneEditBox:SetPoint("TOPLEFT", SM.groupBG, "TOPLEFT", x, 0);
    SM.addSceneEditBox:SetFocus();

    local previousName = "";
    if (index ~= -1) then
        -- copy current text to edit box
        previousName = tabPool[index].text:GetText();
        SM.addSceneEditBox:SetText(previousName);
        SM.addSceneEditBox:SetPoint("TOPLEFT", SM.groupBG, "TOPLEFT", x + 10, 0);
        -- clearing current visible name
        tabPool[index].text:SetText("");
    end

    SM.addSceneEditBox:SetScript('OnEscapePressed', function(self1) 
        self1:ClearFocus();
        self1:Hide();
        SM.addSceneButtonTab:Show();
        if (index ~= -1) then
            -- restore previous visible name
            tabPool[index].text:SetText(previousName);
        end
    end);
    SM.addSceneEditBox:SetScript('OnEnterPressed', function(self1)
        self1:ClearFocus();
        local text = self1:GetText();
        if (text ~= nil and text ~= "") then
            if (index == -1) then
                -- create a new scene
                PM.currentProject.scenes[#PM.currentProject.scenes + 1] = SM.CreateScene(text);
            else
                -- rename existing scene
                PM.currentProject.scenes[index].name = text;
            end
            SM.RefreshSceneTabs();
        end
        self1:Hide();
        SM.addSceneButtonTab:Show();
    end);
end

function SM.Button_EditScene(index)
    -- not sure what this will do, most likely open some scene properties window
    local scene = PM.currentProject.scenes[index];
    print(#scene.objects .. " " .. #Renderer.actors .. " " .. Renderer.projectionFrame:GetNumActors());
end

function SM.Button_DeleteScene(index)
    Win.OpenMessageBox(SceneMachine.mainWindow, 
    "Delete Scene", "Are you sure you wish to continue?",
    true, true, function() 
        SM.DeleteScene(index);
    end, function() end);
    Win.messageBox:SetFrameStrata("DIALOG");
end

function SM.CreateScene(sceneName)
    if (sceneName == nil) then
        sceneName = "Scene " .. #PM.currentProject.scenes;
    end

    return {
        name = sceneName,
        objects = {},
    }
end

function SM.LoadScene(index)
    SM.loadedSceneIndex = index;

    if (#PM.currentProject.scenes == 0) then
        -- current project has no scenes, create a default one
        PM.currentProject.scenes[1] = SM.CreateDefaultScene();
        SM.RefreshSceneTabs();
    end

    -- unload current --
    SM.UnloadScene();

    -- load new --
    local scene = PM.currentProject.scenes[index];
    
    if (scene.objects == nil) then
        scene.objects = {}
    end

    if (#scene.objects > 0) then
        for i in pairs(scene.objects) do
            local object = scene.objects[i];

            object.actor = Renderer.AddActor(object.fileID, object.position.x, object.position.y, object.position.z);

            object.GetActiveBoundingBox = function(self)
                return object.actor:GetActiveBoundingBox();
            end

            object.SetPosition = function(self, x, y, z)
                object.position.x = x;
                object.position.y = y;
                object.position.z = z;
                self.actor:SetPosition(x, y, z);
            end

            object.GetPosition = function(self)
                return object.position;
            end
        end
    end

    -- remember this scene was opened last
    PM.currentProject.lastOpenScene = index;

    -- set the camera position and rotation to the last
    CameraController.Position.x = scene.lastCameraPositionX or 0;
    CameraController.Position.y = scene.lastCameraPositionY or 0;
    CameraController.Position.z = scene.lastCameraPositionZ or 0;
    CameraController.Direction = deg(scene.lastCameraYaw or 0);
    Camera.Yaw = scene.lastCameraYaw or 0;
    Camera.Pitch = scene.lastCameraPitch or 0;
    Camera.Roll = scene.lastCameraRoll or 0;

    --scene.lastCameraPosition = Renderer.projectionFrame:GetCameraPosition();

    -- refresh the scene tabs
    SM.RefreshSceneTabs();

    -- refresh hierarchy
    SH.RefreshHierarchy();

    SM.selectedObject = nil;
end

function SM.UnloadScene()
    SM.selectedObject = nil;
    Renderer.Clear();
end

function SM.CreateObject(_fileID, _name, _x, _y, _z)
    local object = {
        fileID = _fileID,
        name = _name,
        position = { x = _x, y = _y, z = _z },
    }
    local scene = PM.currentProject.scenes[SM.loadedSceneIndex];
    scene.objects[#scene.objects + 1] = object;

    Renderer.AddActor(object.fileID, object.position.x, object.position.y, object.position.z);

    SH.RefreshHierarchy();
end

function SM.DeleteScene(index)
    -- switch to a different scene because the currently loaded is being deleted
    -- load first that isn't this one
    for i in pairs(PM.currentProject.scenes) do
        local scene = PM.currentProject.scenes[i];
        if (i ~= index) then
            SM.LoadScene(i);
            break;
        end
    end

    -- delete it
    table.remove(PM.currentProject.scenes, index);

    -- if this was the only scene then create a new default one
    if (#PM.currentProject.scenes == 1) then
        SM.CreateDefaultScene();
        SM.LoadScene(1);
    end

    -- refresh ui
    SM.RefreshSceneTabs();
end

function SM.CreateNewSceneTab(x, y, w, h, parent)
	local ButtonFont = Win.defaultFont;
	local ButtonFontSize = 9;

	-- main button frame --
	local item = CreateFrame("Button", "Zee.WindowAPI.Button", parent)
	item:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y);
	item:SetWidth(w);
	item:SetHeight(h)
	item.ntex = item:CreateTexture()
	item.htex = item:CreateTexture()
	item.ptex = item:CreateTexture()
	item.ntex:SetColorTexture(0.1757, 0.1757, 0.1875 ,1);
	item.htex:SetColorTexture(0.242, 0.242, 0.25,1);
	item.ptex:SetColorTexture(0, 0.4765, 0.7968,1);
	item.ntex:SetAllPoints()	
	item.ptex:SetAllPoints()
	item.htex:SetAllPoints()
	item:SetNormalTexture(item.ntex)
	item:SetHighlightTexture(item.htex)
	item:SetPushedTexture(item.ptex)

	-- project name text --
	item.text = item:CreateFontString("Zee.WindowAPI.Button Text");
	item.text:SetFont(ButtonFont, ButtonFontSize, "NORMAL");
	--item.text:SetPoint("LEFT", item, "LEFT", 10, 0);
    item.text:SetAllPoints(item);
	item.text:SetText(name);

	return item;
end