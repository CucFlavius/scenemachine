SceneMachine.Editor = SceneMachine.Editor or {};
local Win = ZWindowAPI;
local Editor = SceneMachine.Editor;
Editor.ProjectManager = Editor.ProjectManager or {};
local PM = Editor.ProjectManager;
Editor.SceneManager = Editor.SceneManager or {};
local SM = Editor.SceneManager;

local tabButtonHeight = 20;
local tabPool = {};

SM.loadedSceneIndex = 1;

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
                        SM.SceneTabButtonOnRightClick(i);
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
        SM.addSceneEditBox:Show();
        SM.addSceneEditBox:SetText("Scene " .. (#PM.currentProject.scenes));
        SM.addSceneButtonTab:Hide();
        SM.addSceneEditBox:SetPoint("TOPLEFT", SM.groupBG, "TOPLEFT", x, 0);
        SM.addSceneEditBox:SetFocus();
        SM.addSceneEditBox:SetScript('OnEscapePressed', function(self1) 
            self1:ClearFocus();
            self1:Hide();
            SM.addSceneButtonTab:Show();
        end);
        SM.addSceneEditBox:SetScript('OnEnterPressed', function(self1)
            self1:ClearFocus();
            local text = self1:GetText();
            if (text ~= nil and text ~= "") then
                PM.currentProject.scenes[#PM.currentProject.scenes + 1] = SM.CreateScene(text);
                SM.RefreshSceneTabs();
            end
            self1:Hide();
            SM.addSceneButtonTab:Show();
        end);
    end);
end

function SM.CreateDefaultScene()
    return SM.CreateScene();
end

function SM.SceneTabButtonOnClick(index)
    SM.loadedSceneIndex = index;
    SM.RefreshSceneTabs();
end

function SM.SceneTabButtonOnRightClick(index)
    -- open rmb menu with option to delete, edit, rename the scene
end

function SM.CreateScene(sceneName)
    if (sceneName == nil) then
        sceneName = "Scene " .. #PM.currentProject.scenes;
    end

    return {
        name = sceneName,
    }
end

function SM.LoadScene(index)
    if (#PM.currentProject.scenes == 0) then
        -- current project has no scenes, create a default one
        PM.currentProject.scenes[1] = SM.CreateDefaultScene();
        SM.RefreshSceneTabs();
    end

    -- load --

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