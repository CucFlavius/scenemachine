local Editor = SceneMachine.Editor;
local Win = ZWindowAPI;
local MainMenu = Editor.MainMenu;


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
                { ["Name"] = "About", ["Action"] = nil },
            },
        },
    };
	Win.WindowCreateMenuBar(SceneMachine.mainWindow, menu, Editor.MAIN_FRAME_STRATA);
end