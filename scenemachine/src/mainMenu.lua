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
            ["Name"] = "Tools",
            ["Options"] = {
            },
        },
        {
            ["Name"] = "Help",
            ["Options"] = {
                { ["Name"] = "About", ["Action"] = nil },
            },
        },
    };
	Win.WindowCreateMenuBar(SceneMachine.mainWindow, menu);
end