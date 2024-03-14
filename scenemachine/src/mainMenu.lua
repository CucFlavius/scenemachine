local Editor = SceneMachine.Editor;
local MainMenu = Editor.MainMenu;
local UI = SceneMachine.UI;
local Resources = SceneMachine.Resources;
local L = Editor.localization;
local SM = Editor.SceneManager;

function MainMenu.OpenKeyboardShortcuts()
    if (not Editor.KeyboardShortcutsWindow) then
        Editor.KeyboardShortcutsWindow = UI.Window:New(0, 0, 900, 450, SceneMachine.mainWindow:GetFrame(), "CENTER", "CENTER", "Keyboard Shortcuts");
        Editor.KeyboardShortcutsWindow:MakeWholeWindowDraggable();
        Editor.KeyboardShortcutsWindow:SetFrameStrata(Editor.SUB_FRAME_STRATA);
        Editor.KeyboardShortcutsWindow.resizeFrame:Hide();

        Editor.KeyboardShortcutsPicture = UI.ImageBox:New(0, 0, 1024, 512, Editor.KeyboardShortcutsWindow:GetFrame(), "TOPLEFT", "TOPLEFT", Resources.textures["KeyboardShortcuts"]);
        Editor.KeyboardShortcutsPicture:SetPoint("BOTTOMRIGHT", Editor.KeyboardShortcutsWindow:GetFrame(), "BOTTOMRIGHT", 0, 0);
    end

    Editor.KeyboardShortcutsWindow:Show();
end

function MainMenu.Create()
	local menu = 
    {
        {
            ["Name"] = L["MM_FILE"],
            ["Options"] = {
                { ["Name"] = L["MM_PROJECT_MANAGER"], ["Action"] = function() Editor.ShowProjectManager() end },
                { ["Name"] = L["MM_IMPORT_SCENESCRIPT"], ["Action"] = function(text) Editor.ShowImportExportWindow(SceneMachine.ImportScenescript) end },
                { ["Name"] = L["MM_SAVE"], ["Action"] = function() Editor.Save() end },
            },
        },
        {
            ["Name"] = L["MM_EDIT"],
            ["Options"] = {
                { ["Name"] = L["MM_CLONE_SELECTED"], ["Action"] = function() SM.CloneObjects(SM.selectedObjects, true); end },
                { ["Name"] = L["MM_DELETE_SELECTED"], ["Action"] = function() SM.DeleteObjects(SM.selectedObjects); end },
            },
        },
        {
            ["Name"] = L["MM_SCENE"],
            ["Options"] = {
                { ["Name"] = L["MM_SCENE_NEW"], ["Action"] = function() Editor.OpenQuickTextbox(SM.AddScene, L["MM_SCENE_NEW"], L["MM_TITLE_SCENE_NAME"]); end },
                { ["Name"] = L["MM_SCENE_REMOVE"], ["Action"] = function() SM.Button_DeleteScene(SM.loadedSceneIndex); end },
                { ["Name"] = L["MM_SCENE_RENAME"], ["Action"] = function() Editor.OpenQuickTextbox(SM.RenameSelectedScene, SM.GetSceneName(), L["MM_TITLE_SCENE_RENAME"]); end },
                { ["Name"] = L["MM_SCENE_IMPORT"], ["Action"] = function() SM.Button_ImportScene(); end },
                { ["Name"] = L["MM_SCENE_EXPORT"], ["Action"] = function() SM.Button_ExportScene(SM.loadedSceneIndex); end },
            },
        },
        {
            ["Name"] = L["MM_OPTIONS"],
            ["Options"] = {
                { ["Name"] = string.format(L["MM_SET_SCALE"], "80%"), ["Action"] = function() Editor.SetScale(80); end },
                { ["Name"] = string.format(L["MM_SET_SCALE"], "90%"), ["Action"] = function() Editor.SetScale(90); end },
                { ["Name"] = string.format(L["MM_SET_SCALE"], "100%"), ["Action"] = function() Editor.SetScale(100); end },
                { ["Name"] = string.format(L["MM_SET_SCALE"], "110%"), ["Action"] = function() Editor.SetScale(110); end },
                { ["Name"] = string.format(L["MM_SET_SCALE"], "120%"), ["Action"] = function() Editor.SetScale(120); end },
            },
        },
        {
            ["Name"] = L["MM_HELP"],
            ["Options"] = {
                { ["Name"] = L["MM_KEYBOARD_SHORTCUTS"], ["Action"] = MainMenu.OpenKeyboardShortcuts },
                --{ ["Name"] = L["MM_ABOUT"], ["Action"] = nil },
            },
        },
    };
    
	SceneMachine.mainWindow:WindowCreateMenuBar(menu, Editor.MAIN_FRAME_STRATA);
end