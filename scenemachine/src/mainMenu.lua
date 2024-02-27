local Editor = SceneMachine.Editor;
local MainMenu = Editor.MainMenu;
local UI = SceneMachine.UI;
local Resources = SceneMachine.Resources;
local L = Editor.localization;
local SM = Editor.SceneManager;

function MainMenu.OpenKeyboardShortcuts()
    if (not Editor.KeyboardShortcutsWindow) then
        Editor.KeyboardShortcutsWindow = UI.Window:New(0, 0, 900, 450, SceneMachine.mainWindow:GetFrame(), "CENTER", "CENTER", "Keyboard Shortcuts");
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
                { ["Name"] = L["MM_IMPORT_SCENESCRIPT"], ["Action"] = function() Editor.ShowImportScenescript() end },
                { ["Name"] = L["MM_SAVE"], ["Action"] = function() Editor.Save() end },
            },
        },
        {
            ["Name"] = L["MM_EDIT"],
            ["Options"] = {
                { ["Name"] = L["MM_CLONE_SELECTED"], ["Action"] = function() SM.CloneObject(SM.selectedObject, true); end },
                { ["Name"] = L["MM_DELETE_SELECTED"], ["Action"] = function() SM.DeleteObject(SM.selectedObject); end },
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