local Editor = SceneMachine.Editor;
local Resources = SceneMachine.Resources;

function Resources.Initialize(resourcePath)
    Resources.resourcePath = resourcePath;
    
    -- Fonts --
    Resources.fontsPath = Resources.resourcePath .. "\\font";

    Resources.fonts = {}
    Resources.fonts["Segoe"] = Resources.fontsPath .. "\\Segoe UI.ttf";
    Resources.fonts["Digital"] = Resources.fontsPath .. "\\digital-7.ttf";
    Resources.fonts["ARHei"] = "Fonts\\ARHei.ttf";
    Resources.fonts["blei00d"] = "Fonts\\blei00d.TTF";
    Resources.fonts["2002"] = "Fonts\\2002.ttf";
    
    if (GAME_LOCALE == "zhCN") then
        Resources.defaultFont = Resources.fonts["ARHei"];
        Resources.defaultFontSize = 13;
    elseif(GAME_LOCALE == "zhTW") then
        Resources.defaultFont = Resources.fonts["blei00d"];
        Resources.defaultFontSize = 13;
    elseif (GAME_LOCALE == "koKR") then
        Resources.defaultFont = Resources.fonts["2002"];
        Resources.defaultFontSize = 13;
    else
        Resources.defaultFont = Resources.fonts["Segoe"];
        Resources.defaultFontSize = 9;
    end

    -- Textures --
    Resources.texturesPath = Resources.resourcePath .. "\\textures";
    Resources.textures = {}

    Resources.textures["SliderThumb"] = Resources.texturesPath .. "\\SliderThumb.png";
    Resources.textures["Keyframe"] = Resources.texturesPath .. "\\keyframe.png";
    Resources.textures["TimeSlider"] = Resources.texturesPath .. "\\timeSlider.png";
    Resources.textures["CloseButton"] = Resources.texturesPath .. "\\closeButton.png";
    Resources.textures["Line"] = Resources.texturesPath .. "\\line.png";
    Resources.textures["DashedLine"] = Resources.texturesPath .. "\\dashedLine.png";
    Resources.textures["Animation"] = Resources.texturesPath .. "\\animation.png";
    Resources.textures["CropBar"] = Resources.texturesPath .. "\\cropBar.png";
    Resources.textures["FolderIcon"] = Resources.texturesPath .. "\\folderIcon.png";
    Resources.textures["Icon32"] = Resources.texturesPath .. "\\icon32.png";
    Resources.textures["ScrollBar"] = Resources.texturesPath .. "\\scrollBar.png";
    Resources.textures["Toolbar"] = Resources.texturesPath .. "\\toolbar.png";
    Resources.textures["ToolbarAnimation"] = Resources.texturesPath .. "\\toolbarAnimation.png";
    Resources.textures["DropShadow"] = Resources.texturesPath .. "\\dropShadowSquare.png";
    Resources.textures["CornerResize"] = Resources.texturesPath .. "\\cornerResize.png";
    Resources.textures["CursorResizeH"] = "interface\\cursor\\crosshair\\ui-cursor-move.blp";--Resources.texturesPath .. "\\resizeCursorHorizontal.png";
    Resources.textures["CursorResizeV"] = "interface\\cursor\\crosshair\\ui-cursor-move.blp";--Resources.texturesPath .. "\\resizeCursorVertical.png.crosshair";
    Resources.textures["CursorResize"] = "interface\\cursor\\crosshair\\ui-cursor-sizeright.blp";--Resources.texturesPath .. "\\resizeCursorBoth.png.crosshair";
    Resources.textures["ResizeArrowV"] = Resources.texturesPath .. "\\resizeCursorVertical.png";
    Resources.textures["ColorPicker"] = Resources.texturesPath .. "\\colorPickerV2.png";
    Resources.textures["KeyboardShortcuts"] = Resources.texturesPath .. "\\keyboardShortcuts.png";
    Resources.textures["ArrowDown"] = Resources.texturesPath .. "\\ArrowDown.png";
    Resources.textures["ResetIcon"] = Resources.texturesPath .. "\\resetIcon.png";
    Resources.textures["Add"] = Resources.texturesPath .. "\\add.png";
    Resources.textures["ToolbarAssetExplorer"] = Resources.texturesPath .. "\\toolbarAssetExplorer.png";
    Resources.textures["Dropshadow"] = Resources.texturesPath .. "\\dropshadow.png";
    Resources.textures["SceneSprites"] = Resources.texturesPath .. "\\sceneSprites.png";
    Resources.textures["Hierarchy"] = Resources.texturesPath .. "\\hierarchy.png";
    Resources.textures["TimeNeedle"] = Resources.texturesPath .. "\\timeNeedle.png";
    Resources.textures["Checkbox"] = Resources.texturesPath .. "\\checkbox.png";

    -- Icons --
    Resources.iconData = {};

    Resources.iconData["MainToolbar"] = {
        texture = Resources.textures["Toolbar"];
        rows = 8,
        columns = 8,
        coords = {
            { "select", "move", "rotate", "scale", "worldpivot", "localpivot", "centerpivot", "basepivot" },
            { "projects", "together", "individual", "undo", "undooff", "redo", "redooff", "addcamera" },
            { "letterboxoff", "letterboxon", "fullscreen", "", "", "", "", "addcharacter" },
            { "", "", "", "", "", "", "", "" },
            { "", "", "", "", "", "", "", "" },
            { "", "", "", "", "", "", "", "" },
            { "", "", "", "", "", "", "", "" },
            { "", "", "", "", "", "", "", "" },
        };
    }

    Resources.iconData["AnimToolbar"] = {
        texture = Resources.textures["ToolbarAnimation"];
        rows = 6,
        columns = 6,
        coords = {
            { "play", "pause", "fastforward", "skiponeframe", "skiptoend", "" },
            { "addkey", "removekey", "addanim", "removeanim", "addobj", "removeobj" },
            { "loop", "loopoff", "timesettings", "ismooth", "ilinear", "istep" },
            { "addposkey", "addrotkey", "addscalekey", "osmooth", "olinear", "ostep" },
            { "islow", "ifast", "cameraplayon", "cameraplayoff", "", ""},
            { "oslow", "ofast", "", "", "", "" },
        };
    }

    Resources.iconData["AssetExplorerToolbar"] = {
        texture = Resources.textures["ToolbarAssetExplorer"];
        rows = 8,
        columns = 8,
        coords = {
            { "uponefolder", "newcollection", "removecollection", "renamecollection", "addsceneobject", "removeobject", "importcollection", "exportcollection" },
            { "", "", "", "", "", "", "", "" },
            { "", "", "", "", "", "", "", "" },
            { "", "", "", "", "", "", "", "" },
            { "", "", "", "", "", "", "", "" },
            { "", "", "", "", "", "", "", "" },
            { "", "", "", "", "", "", "", "" },
            { "", "", "", "", "", "", "", "" },
        };
    }
end