local Settings = SceneMachine.Settings;

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
end