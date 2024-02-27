local AceLocale = LibStub("AceLocale-3.0");
local L = AceLocale:NewLocale("SceneMachine", "enUS", true);

-- General --
L["YES"] = "Yes";
L["NO"] = "No";
L["POSITION"] = "Position";
L["ROTATION"] = "Rotation";
L["SCALE"] = "Scale";
L["ALPHA"] = "Alpha";   -- Transparency
L["SEARCH"] = "Search";
L["RENAME"] = "Rename";
L["EDIT"] = "Edit";
L["DELETE"] = "Delete";
L["BUTTON_SAVE"] = "Save";
L["BUTTON_CANCEL"] = "Cancel";

-- Editor --
L["ADDON_NAME"] = "Scene Machine";
L["EDITOR_MAIN_WINDOW_TITLE"] = "Scene Machine %s - %s";       -- Scene Machine <version> - <current project name>
L["EDITOR_MSG_DELETE_OBJECT_TITLE"] = "Delete Object";
L["EDITOR_MSG_DELETE_OBJECT_MESSAGE"] = "The object contains an animation track, are you sure you want to delete?";
L["EDITOR_MSG_DELETE_TRACK_TITLE"] = "Delete Track";
L["EDITOR_MSG_DELETE_TRACK_A_K_MESSAGE"] = "The track contains animations and keyframes, are you sure you want to delete?";
L["EDITOR_MSG_DELETE_TRACK_A_MESSAGE"] = "The track contains animations, are you sure you want to delete?";
L["EDITOR_MSG_DELETE_TRACK_K_MESSAGE"] = "The track contains keyframes, are you sure you want to delete?";
L["EDITOR_MSG_SAVE_TITLE"] = "Save";
L["EDITOR_MSG_SAVE_MESSAGE"] = "Saving requires a UI reload, continue?";
L["EDITOR_SCENESCRIPT_WINDOW_TITLE"] = "Import Scenescript";

-- Main Menu --
L["MM_FILE"] = "File";
L["MM_EDIT"] = "Edit";
L["MM_OPTIONS"] = "Options";
L["MM_HELP"] = "Help";
L["MM_PROJECT_MANAGER"] = "Project Manager";
L["MM_IMPORT_SCENESCRIPT"] = "Import Scenescript";
L["MM_SAVE"] = "Save";
L["MM_CLONE_SELECTED"] = "Clone Selected";
L["MM_DELETE_SELECTED"] = "Delete Selected";
L["MM_SET_SCALE"] = "Set Scale %s";
L["MM_KEYBOARD_SHORTCUTS"] = "Keyboard Shortcuts";
L["MM_ABOUT"] = "About";

-- Context Menu --
L["CM_SELECT"] = "Select";
L["CM_MOVE"] = "Move";
L["CM_ROTATE"] = "Rotate";
L["CM_SCALE"] = "Scale";
L["CM_DELETE"] = "Delete";
L["CM_HIDE_SHOW"] = "Hide/Show";
L["CM_FREEZE_UNFREEZE"] = "Freeze/Unfreeze";

-- Animation Manager --
L["AM_ANIMATION_LIST_WINDOW_TITLE"] = "Animation List";
L["AM_TIMELINE"] = "Timeline %d";           -- timeline number
L["AM_MSG_DELETE_TIMELINE_TITLE"] = "Delete Timeline";
L["AM_MSG_DELETE_TIMELINE_MESSAGE"] = "Are you sure you wish to continue?";
L["AM_MSG_NO_TRACK_TITLE"] = "No Track";
L["AM_MSG_NO_TRACK_MESSAGE"] = "The object doesn't have an animation track, do you want to add one?";
L["AM_BUTTON_ADD_ANIMATION"] = "Add Anim";
L["AM_TIMELINE_NAME"] = "Timeline Name";
L["AM_TOOLBAR_TRACKS"] = "Tracks";
L["AM_TOOLBAR_KEYFRAMES"] = "Keyframes";
L["AM_TOOLBAR_CURVES"] = "Curves (debug only)";

-- AssetBrowser --
L["AB_RESULTS"] = "%d Results";             -- <number> results (search results)
L["AB_BREADCRUMB"] = "...";             -- for a file path

-- Project Manager --
L["PM_WINDOW_TITLE"] = "Project Manager";
L["PM_PROJECT_NAME"] = "Project Name";
L["PM_NEW_PROJECT"] = "New Project";
L["PM_EDIT_PROJECT"] = "Edit Project";
L["PM_MSG_DELETE_PROJECT_TITLE"] = "Delete Project";
L["PM_MSG_DELETE_PROJECT_MESSAGE"] = "Deleting the project will also delete all its scenes and data, continue?";
L["PM_BUTTON_NEW_PROJECT"] = "New Project";
L["PM_BUTTON_LOAD_PROJECT"] = "Load Project";
L["PM_BUTTON_EDIT_PROJECT"] = "Edit Project";
L["PM_BUTTON_REMOVE_PROJECT"] = "Remove Project";
L["PM_BUTTON_SAVE_DATA"] = "Save Data";

-- Scene Manager --
L["SM_SCENE"] = "Scene %d";                 -- scene number
L["SM_MSG_DELETE_SCENE_TITLE"] = "Delete Scene";
L["SM_MSG_DELETE_SCENE_MESSAGE"] = "Are you sure you wish to continue?";
L["SM_SCENE_NAME"] = "Scene Name";

-- Object Properties --
L["OP_TITLE"] = "Properties";
L["OP_TRANSFORM"] = "Transform";
L["OP_ACTOR_PROPERTIES"] = "Actor Properties";
L["OP_SCENE_PROPERTIES"] = "Scene properties";
L["OP_AMBIENT_COLOR"] = "Ambient Color";
L["OP_DIFFUSE_COLOR"] = "Diffuse Color";
L["OP_BACKGROUND_COLOR"] = "Background Color";

-- Scene Hierarchy --
L["SH_TITLE"] = "Scene Hierarchy";

-- Color Picker --
L["COLP_WINDOW_TITLE"] = "Color Picker";
L["COLP_RGB_NAME"] = "RGB (Red/Green/Blue):";
L["COLP_HSL_NAME"] = "HSL (Hue/Saturation/Lightness):";
L["COLP_R"] = "R";  -- Red
L["COLP_G"] = "G";  -- Green
L["COLP_B"] = "B";  -- Blue
L["COLP_H"] = "H";  -- Hue
L["COLP_S"] = "S";  -- Saturation
L["COLP_L"] = "L";  -- Lightness

----------- TODO ------------
-- toolbar:CreateGroup

SceneMachine.Editor.localization = AceLocale:GetLocale("SceneMachine", false);