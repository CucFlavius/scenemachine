local Settings = SceneMachine.Settings;
local UI = SceneMachine.UI;
local Editor = SceneMachine.Editor;
local L = Editor.localization;
local Resources = SceneMachine.Resources;
local SM = Editor.SceneManager;
local GM = SceneMachine.GizmoManager;
local AB = Editor.AssetBrowser;

function Settings.Initialize()
    scenemachine_settings = scenemachine_settings or {};
    scenemachine_settings.minimap_button = scenemachine_settings.minimap_button or {
        minimapPos = 90;
        hide = false;
        lock = true;
    }
    scenemachine_settings.editor_is_open = scenemachine_settings.editor_is_open or false;
    scenemachine_settings.leftPanelW = scenemachine_settings.leftPanelW or 300;
    scenemachine_settings.rightPanelW = scenemachine_settings.rightPanelW or 300;
    scenemachine_settings.propertiesPanelH = scenemachine_settings.propertiesPanelH or 200;
    scenemachine_settings.animationManagerH = scenemachine_settings.animationManagerH or 220;
    scenemachine_settings.editor_scale = scenemachine_settings.editor_scale or 100;
    scenemachine_settings.collectionsPanelH = scenemachine_settings.collectionsPanelH or 300;
    scenemachine_settings.gizmos = scenemachine_settings.gizmos or {
        showSelectionHighlight = true;
        hideTranslationGizmosParallelToCamera = true;
        alwaysShowCameraGizmo = false;
        gizmoSize = 5;
    }
    scenemachine_settings.debug = scenemachine_settings.debug or {
        showDebugTabInAssetBrowser = false;
    }
end

function Settings.CreateSettingsWindow()
    Settings.settingsWindow = UI.Window:New(0, 0, 400, 600, SceneMachine.mainWindow:GetFrame(), "CENTER", "CENTER", L["SETTINGS_WINDOW_TITLE"]);
    Settings.settingsWindow:MakeWholeWindowDraggable();
    Settings.settingsWindow:SetFrameStrata(Editor.SUB_FRAME_STRATA);

    local startLevel = Settings.settingsWindow:GetFrameLevel();
    local tabButtonHeight = 20;
    Settings.tabGroup = UI.TabGroup:NewTLTR(0, 0, 0, 0, tabButtonHeight, Settings.settingsWindow:GetFrame(), startLevel + 2, false);
	Settings.tabGroup:SetItemTemplate(
    {
        height = tabButtonHeight,
        lmbAction = function(index)
            Settings.OnChangeTab(index);
        end,
        refreshItem = function(data, item, index)
            -- timeline name text --
            item.components[2]:SetWidth(1000);
            item.components[2]:SetText(data.name);
            local strW = item.components[2].frame.text:GetStringWidth() + 20;
            item:SetWidth(strW);
            item.components[1]:SetWidth(strW);
            item.components[2]:SetWidth(strW);
            return strW;
        end,
    });

    Settings.tabGroup:SetData({
        { name = L["SETTINGS_TAB_GENERAL"] },
        { name = L["SETTINGS_TAB_GIZMOS"] },
        { name = L["SETTINGS_TAB_DEBUG"] },
    });

    Settings.tabs = {};
    Settings.tabs[1] = UI.Rectangle:NewTLBR(0, -20, 0, 16, Settings.settingsWindow:GetFrame(), 0, 0, 0, 0);
    Settings.tabs[1]:SetFrameLevel(startLevel + 3);
    Settings.tabs[2] = UI.Rectangle:NewTLBR(0, -20, 0, 16, Settings.settingsWindow:GetFrame(), 0, 0, 0, 0);
    Settings.tabs[2]:SetFrameLevel(startLevel + 3);
    Settings.tabs[3] = UI.Rectangle:NewTLBR(0, -20, 0, 16, Settings.settingsWindow:GetFrame(), 0, 0, 0, 0);
    Settings.tabs[3]:SetFrameLevel(startLevel + 3);
    Settings.RefreshTabs();
    Settings.OnChangeTab(1);

    Settings.BuildGeneralTab();
    Settings.BuildGizmosTab();
    Settings.BuildDebugTab();
end

function Settings.BuildGeneralTab()
    local viewport = UI.Rectangle:NewAP(Settings.tabs[1]:GetFrame(), 0, 1, 0, 0);
    viewport:SetClipsChildren(true);
    local list = UI.Rectangle:NewTLTR(5, 0, -21, 0, 100, viewport:GetFrame(), 0, 0, 0, 0);
    local onScroll = function(value)
        local parent = list:GetParent();
        local y = value * (list:GetHeight() - viewport:GetHeight());
        list:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, y);
        list:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -16, y);
    end
    local scrollbar = UI.Scrollbar:NewTRBR(0, 0, 0, 0, 16, viewport:GetFrame(), onScroll);
    viewport:GetFrame():SetScript("OnSizeChanged", function(_, width, height)
        scrollbar:Resize(height, list:GetHeight());
    end);
    list.posY = 0;

    --- fields ---
    Settings.AddSlider(list, L["SETTINGS_EDITOR_SCALE"], 70, 120, Settings.GetEditorScale(), 1, Settings.SetEditorScale);

    list:SetHeight(list.posY);
end

function Settings.BuildGizmosTab()
    local viewport = UI.Rectangle:NewAP(Settings.tabs[2]:GetFrame(), 0, 1, 0, 0);
    viewport:SetClipsChildren(true);
    local list = UI.Rectangle:NewTLTR(5, 0, -21, 0, 100, viewport:GetFrame(), 0, 0, 0, 0);
    local onScroll = function(value)
        local parent = list:GetParent();
        local y = value * (list:GetHeight() - viewport:GetHeight());
        list:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, y);
        list:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -16, y);
    end
    local scrollbar = UI.Scrollbar:NewTRBR(0, 0, 0, 0, 16, viewport:GetFrame(), onScroll);
    viewport:GetFrame():SetScript("OnSizeChanged", function(_, width, height)
        scrollbar:Resize(height, list:GetHeight());
    end);
    list.posY = 0;

    --- fields ---
    Settings.AddCheckbox(list, L["SETTINGS_SHOW_SELECTION_HIGHLIGHT"], Settings.ShowSelectionHighlight(), function(value)
        scenemachine_settings.gizmos.showSelectionHighlight = value;
        SM.ApplySelectionEffects();
    end);
    Settings.AddCheckbox(list, L["SETTINGS_HIDE_PARALLEL_GIZMOS"], Settings.HideTranslationGizmosParallelToCamera(), function(value)
        scenemachine_settings.gizmos.hideTranslationGizmosParallelToCamera = value;
        if (not value) then
            GM.ToggleAllAxesOn();
        end
    end);
    Settings.AddCheckbox(list, L["SETTINGS_ALWAYS_SHOW_CAM_GIZMO"], Settings.AlwaysShowCameraGizmo(), function(value)
        scenemachine_settings.gizmos.alwaysShowCameraGizmo = value;
    end);
    Settings.AddSlider(list, L["SETTINGS_GIZMO_SIZE"], 0.1, 10, Settings.GetGizmoSize(), 0.4, function(value)
        scenemachine_settings.gizmos.gizmoSize = value;
    end);

    list:SetHeight(list.posY);
end

function Settings.GetGizmoSize()
    return scenemachine_settings.gizmos.gizmoSize;
end

function Settings.ShowSelectionHighlight()
    return scenemachine_settings.gizmos.showSelectionHighlight;
end

function Settings.HideTranslationGizmosParallelToCamera()
    return scenemachine_settings.gizmos.hideTranslationGizmosParallelToCamera;
end

function Settings.AlwaysShowCameraGizmo()
    return scenemachine_settings.gizmos.alwaysShowCameraGizmo;
end

function Settings.BuildDebugTab()
    local viewport = UI.Rectangle:NewAP(Settings.tabs[3]:GetFrame(), 0, 1, 0, 0);
    viewport:SetClipsChildren(true);
    local list = UI.Rectangle:NewTLTR(5, 0, -21, 0, 100, viewport:GetFrame(), 0, 0, 0, 0);
    local onScroll = function(value)
        local parent = list:GetParent();
        local y = value * (list:GetHeight() - viewport:GetHeight());
        list:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, y);
        list:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -16, y);
    end
    local scrollbar = UI.Scrollbar:NewTRBR(0, 0, 0, 0, 16, viewport:GetFrame(), onScroll);
    viewport:GetFrame():SetScript("OnSizeChanged", function(_, width, height)
        scrollbar:Resize(height, list:GetHeight());
    end);
    list.posY = 0;

    --- fields ---
    Settings.AddCheckbox(list, L["SETTINGS_SHOW_DEBUG_TAB"], Settings.ShowDebugTabInAssetBrowser(), function(value)
        scenemachine_settings.debug.showDebugTabInAssetBrowser = value;
        if (not value) then
            AB.tabGroup:SetData({
                { name = L["AB_TAB_MODELS"] },
                { name = L["AB_TAB_CREATURES"] },
                { name = L["AB_TAB_COLLECTIONS"] },
             });
        else
            AB.tabGroup:SetData({
                { name = L["AB_TAB_MODELS"] },
                { name = L["AB_TAB_CREATURES"] },
                { name = L["AB_TAB_COLLECTIONS"] },
                { name = L["AB_TAB_DEBUG"] },
            });
        end
        AB.tabGroup:Refresh(0);
    end);

    list:SetHeight(list.posY);
end

function Settings.ShowDebugTabInAssetBrowser()
    return scenemachine_settings.debug.showDebugTabInAssetBrowser;
end

function Settings.OnChangeTab(idx)
    Settings.tabGroup.selectedIndex = idx;
    local tabFrame = Settings.tabs[idx]:GetFrame();
    for i = 1, #Settings.tabs, 1 do
        Settings.tabs[i]:Hide();
    end
    tabFrame:Show();
    Settings.RefreshTabs();
end

function Settings.RefreshTabs()
    Settings.tabGroup:Refresh(0);
end

function Settings.SetEditorScale(percent)
    local n = percent / 100;
    Editor.scale = n * (1 / UIParent:GetScale());
    SceneMachine.mainWindow:SetScale(Editor.scale);
    scenemachine_settings.editor_scale = percent;

    Editor.ResetWindow();
end

function Settings.AddCheckbox(tab, name, defaultValue, onCheck)
    local h = 25;
    local panel = Settings.CreatePanel(tab:GetFrame(), -tab.posY, h, name);

    local label = UI.Label:NewTLTR(10, 0, -26, 0, h, panel:GetFrame(), name);
    label:SetTextColor(1, 1, 1, 0.5);

    local checkbox = UI.Checkbox:New(-10, 0, 16, 16, panel:GetFrame(), "RIGHT", "RIGHT", defaultValue, onCheck);

    tab.posY = tab.posY + h + 2;
end

function Settings.AddSlider(tab, name, startValue, endValue, defaultValue, step, onScroll)
    local h = 40;
    local panel = Settings.CreatePanel(tab:GetFrame(), -tab.posY, h, name);

    local label = UI.Label:New(10, 0, 100, 20, panel:GetFrame(), "TOPLEFT", "TOPLEFT", name);
    label:SetTextColor(1, 1, 1, 0.5);

    local valuelabel = UI.Label:New(-10, 0, 100, 20, panel:GetFrame(), "TOPRIGHT", "TOPRIGHT", tostring(defaultValue));
    valuelabel:SetTextColor(1, 1, 1, 1);
    valuelabel:SetJustifyH("RIGHT");

    local currentOnscroll = onScroll;
    onScroll = function(value)
        if (currentOnscroll) then
            currentOnscroll(value);
        end
        valuelabel:SetText(tostring(value));
    end

    local slider = UI.SliderHorizontal:NewLR(20, -5, -20, 0, 5, panel:GetFrame(), onScroll, startValue, endValue, step);
    slider:SetValueWithoutAction(defaultValue);

    tab.posY = tab.posY + h + 2;
end

function Settings.CreatePanel(parent, y, h, name)
    local R, G, B, A = 0.1757, 0.1757, 0.1875, 1;
    local cornerSize = 8;

    local bg = UI.Rectangle:NewTLTR(0, y, 0, y, h, parent, 1,1,1,0);

    local tl = UI.ImageBox:New(0, 0, cornerSize, cornerSize, bg:GetFrame(), "TOPLEFT", "TOPLEFT", Resources.textures["ScrollBar"], { 0, 0.5, 0, 0.5 });
    tl:SetVertexColor(R, G, B, A);
    local tr = UI.ImageBox:New(0, 0, cornerSize, cornerSize, bg:GetFrame(), "TOPRIGHT", "TOPRIGHT", Resources.textures["ScrollBar"], { 0.5, 0, 0, 0.5 });
    tr:SetVertexColor(R, G, B, A);
    local bl = UI.ImageBox:New(0, 0, cornerSize, cornerSize, bg:GetFrame(), "BOTTOMLEFT", "BOTTOMLEFT", Resources.textures["ScrollBar"], { 0, 0.5, 0.5, 0 });
    bl:SetVertexColor(R, G, B, A);
    local br = UI.ImageBox:New(0, 0, cornerSize, cornerSize, bg:GetFrame(), "BOTTOMRIGHT", "BOTTOMRIGHT", Resources.textures["ScrollBar"], { 0.5, 0, 0.5, 0 });
    br:SetVertexColor(R, G, B, A);

    local l = UI.ImageBox:NewTLBL(0, -cornerSize, 0, cornerSize, cornerSize, bg:GetFrame(), Resources.textures["ScrollBar"], { 0, 0.5, 0.4, 0.6 });
    l:SetVertexColor(R, G, B, A);
    local r = UI.ImageBox:NewTRBR(0, -cornerSize, 0, cornerSize, cornerSize, bg:GetFrame(), Resources.textures["ScrollBar"], { 0.5, 0, 0.4, 0.6 });
    r:SetVertexColor(R, G, B, A);
    local t = UI.ImageBox:NewTLTR(cornerSize, 0, -cornerSize, 0, cornerSize, bg:GetFrame(), Resources.textures["ScrollBar"], { 0.4, 0.6, 0, 0.5 });
    t:SetVertexColor(R, G, B, A);
    local b = UI.ImageBox:NewBLBR(cornerSize, 0, -cornerSize, 0, cornerSize, bg:GetFrame(), Resources.textures["ScrollBar"], { 0.4, 0.6, 0.5, 1 });
    b:SetVertexColor(R, G, B, A);

    local c = UI.Rectangle:NewTLBR(cornerSize, -cornerSize, -cornerSize, cornerSize, bg:GetFrame(), R, G, B, A);

    return bg;
end

function Settings.GetEditorScale()
    return scenemachine_settings.editor_scale;
end

function Settings.OpenSettingsWindow()
    if (not Settings.settingsWindow) then
        Settings.CreateSettingsWindow();
    end

    Settings.settingsWindow:Show();
end