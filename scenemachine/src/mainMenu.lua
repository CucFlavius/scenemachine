local Editor = SceneMachine.Editor;
local MainMenu = Editor.MainMenu;
local UI = SceneMachine.UI;
local Resources = SceneMachine.Resources;

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
            ["Name"] = "File",
            ["Options"] = {
                { ["Name"] = "Project Manager", ["Action"] = function() Editor.ShowProjectManager() end },
                { ["Name"] = "Import Scenescript", ["Action"] = function() Editor.ShowImportScenescript() end },
                { ["Name"] = "Save", ["Action"] = function() Editor.Save() end },
            },
        },
        {
            ["Name"] = "Edit",
            ["Options"] = {
                { ["Name"] = "Clone Selected", ["Action"] = function() SM.CloneObject(SM.selectedObject, true); end },
                { ["Name"] = "Delete Selected", ["Action"] = function() SM.DeleteObject(SM.selectedObject); end },
            },
        },
        {
            ["Name"] = "Options",
            ["Options"] = {
                { ["Name"] = "Set Scale 80%", ["Action"] = function() Editor.SetScale(80); end },
                { ["Name"] = "Set Scale 90%", ["Action"] = function() Editor.SetScale(90); end },
                { ["Name"] = "Set Scale 100%", ["Action"] = function() Editor.SetScale(100); end },
                { ["Name"] = "Set Scale 110%", ["Action"] = function() Editor.SetScale(110); end },
                { ["Name"] = "Set Scale 120%", ["Action"] = function() Editor.SetScale(120); end },
            },
        },
        {
            ["Name"] = "Help",
            ["Options"] = {
                { ["Name"] = "Keyboard Shortcuts", ["Action"] = MainMenu.OpenKeyboardShortcuts },
                --{ ["Name"] = "About", ["Action"] = nil },
            },
        },
    };
    
	SceneMachine.mainWindow:WindowCreateMenuBar(menu, Editor.MAIN_FRAME_STRATA);
end