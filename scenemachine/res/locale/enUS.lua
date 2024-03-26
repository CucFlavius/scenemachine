local AceLocale = LibStub("AceLocale-3.0");
local L = AceLocale:NewLocale("SceneMachine", "enUS", true);

-- General --
L["YES"] = "Yes";
L["NO"] = "No";
L["POSITION"] = "Position";
L["ROTATION"] = "Rotation";
L["SCALE"] = "Scale";
L["ALPHA"] = "Alpha";   -- Transparency
L["DESATURATION"] = "Desaturation";
L["SEARCH"] = "Search";
L["RENAME"] = "Rename";
L["EDIT"] = "Edit";
L["DELETE"] = "Delete";
L["BUTTON_SAVE"] = "Save";
L["BUTTON_CANCEL"] = "Cancel";
L["EXPORT"] = "Export";
L["IMPORT"] = "Import";
L["SCROLL_TOP"] = "Jump to Top";
L["SCROLL_BOTTOM"] = "Jump to Bottom";
L["LOAD"] = "Load";

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
L["EDITOR_TOOLBAR_TT_OPEN_PROJECT_MANAGER"] = "Open Project Manager";
L["EDITOR_TOOLBAR_TT_PROJECT_LIST"] = "Change project";
L["EDITOR_TOOLBAR_TT_SELECT_TOOL"] = "Select Tool";
L["EDITOR_TOOLBAR_TT_MOVE_TOOL"] = "Move Tool";
L["EDITOR_TOOLBAR_TT_ROTATE_TOOL"] = "Rotate Tool";
L["EDITOR_TOOLBAR_TT_SCALE_TOOL"] = "Scale Tool";
L["EDITOR_TOOLBAR_TT_PIVOT_LOCAL_SPACE"] = "Local Space Pivot";
L["EDITOR_TOOLBAR_TT_PIVOT_WORLD_SPACE"] = "World Space Pivot";
L["EDITOR_TOOLBAR_TT_PIVOT_CENTER"] = "Center Pivot";
L["EDITOR_TOOLBAR_TT_PIVOT_BASE"] = "Base Pivot";
L["EDITOR_IMPORT_EXPORT_WINDOW_TITLE"] = "Import - Export";
L["EDITOR_NAME_RENAME_WINDOW_TITLE"] = "Name - Rename";
L["EDITOR_TOOLBAR_TT_MULTITRANSFORM_TOGETHER"] = "Transform Together";
L["EDITOR_TOOLBAR_TT_MULTITRANSFORM_INDIVIDUAL"] = "Transform Individual";
L["EDITOR_TOOLBAR_TT_UNDO"] = "Undo";
L["EDITOR_TOOLBAR_TT_REDO"] = "Redo";
L["EDITOR_TOOLBAR_TT_CREATE_CAMERA"] = "Create Camera";

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
L["MM_SCENE"] = "Scene";
L["MM_SCENE_NEW"] = "New";
L["MM_SCENE_REMOVE"] = "Remove";
L["MM_SCENE_RENAME"] = "Rename";
L["MM_SCENE_EXPORT"] = "Export";
L["MM_SCENE_IMPORT"] = "Import";
L["MM_TITLE_SCENE_NAME"] = "Scene Name";
L["MM_TITLE_SCENE_RENAME"] = "Scene Rename";

-- Context Menu --
L["CM_SELECT"] = "Select";
L["CM_MOVE"] = "Move";
L["CM_ROTATE"] = "Rotate";
L["CM_SCALE"] = "Scale";
L["CM_DELETE"] = "Delete";
L["CM_HIDE_SHOW"] = "Hide/Show";
L["CM_HIDE"] = "Hide";
L["CM_SHOW"] = "Show";
L["CM_FREEZE_UNFREEZE"] = "Freeze/Unfreeze";
L["CM_FREEZE"] = "Freeze";
L["CM_UNFREEZE"] = "Unfreeze";
L["CM_RENAME"] = "Rename";
L["CM_FOCUS"] = "Focus";
L["CM_GROUP"] = "Group";

-- Animation Manager --
L["AM_ANIMATION_LIST_WINDOW_TITLE"] = "Animation List";
L["AM_TIMELINE"] = "Timeline %d";           -- timeline number
L["AM_MSG_DELETE_TIMELINE_TITLE"] = "Delete Timeline";
L["AM_MSG_DELETE_TIMELINE_MESSAGE"] = "Are you sure you wish to continue?";
L["AM_MSG_NO_TRACK_TITLE"] = "No Track";
L["AM_MSG_NO_TRACK_MESSAGE"] = "The object doesn't have an animation track, do you want to add one?";
L["AM_BUTTON_ADD_ANIMATION"] = "Add Anim";
L["AM_BUTTON_CHANGE_ANIMATION"] = "Change Anim";
L["AM_TIMELINE_NAME"] = "Timeline Name";
L["AM_TOOLBAR_TRACKS"] = "Tracks";
L["AM_TOOLBAR_KEYFRAMES"] = "Keyframes";
L["AM_TOOLBAR_CURVES"] = "Curves (debug only)";
L["AM_TOOLBAR_TT_UIMODE"] = "Switch Animation Mode";
L["AM_TOOLBAR_TTD_UIMODE"] = "Switch Animation Mode:\n" ..
                                 " 1. Tracks View - Manage different object tracks, add model animations, and keyframes\n" ..
                                 " 2. Keyframes View - Advanced control over keyframes\n" ..
                                 " 3. Curves View - (Not Yet Implemented - Currently only used for debuging)\n";
L["AM_TOOLBAR_TT_ADD_TRACK"] = "Add Track";
L["AM_TOOLBAR_TTD_ADD_TRACK"] = "Add Track:\n" ..
                                    " - Create a new animation track, and assign it to the selected scene object\n" ..
                                    " - An object in the scene requires a track in order to perform\n" ..
                                    "any animation on it.\n" ..
                                    " - Any object may only have one track assigned to it";
L["AM_TOOLBAR_TT_REMOVE_TRACK"] = "Delete Track";
L["AM_TOOLBAR_TT_ADD_ANIMATION"] = "Add Animation";
L["AM_TOOLBAR_TTD_ADD_ANIMATION"] = "Add Animation:\n" ..
                                    " - Add an animation clip to the current selected track/object\n" ..
                                    " - Opens the Animation List window where you can select an available clip";
L["AM_TOOLBAR_TT_REMOVE_ANIMATION"] = "Delete Animation";
L["AM_TOOLBAR_TT_ADD_KEYFRAME"] = "Add Keyframe";
L["AM_TOOLBAR_TTD_ADD_KEYFRAME"] = "Add Keyframe:\n" ..
                                    " - Add a keyframe at the current time.\n" ..
                                    " - Hold to switch between:\n" ..
                                    "    1. Add keyframe to all transforms;\n" ..
                                    "    2. Add position only keyframe;\n" ..
                                    "    3. Add rotation only keyframe;\n" ..
                                    "    4. Add scale only keyframe;";      
L["AM_TOOLBAR_TT_SET_INTERPOLATION_IN"] = "Set Interpolation In";
L["AM_TOOLBAR_TTD_SET_INTERPOLATION_IN"] = "Set Interpolation In:\n" ..
                                               " - Set the current keyframe in(left side) interpolation mode.\n" ..
                                               " - Hold to switch between:\n" ..
                                               "    1. Smooth\n" ..
                                               "    2. Linear\n" ..
                                               "    3. Step\n" ..
                                               "    4. Slow\n" ..
                                               "    5. Fast\n";
L["AM_TOOLBAR_TT_SET_INTERPOLATION_OUT"] = "Set Interpolation Out";
L["AM_TOOLBAR_TTD_SET_INTERPOLATION_OUT"] = "Set Interpolation Out:\n" ..
                                                " - Set the current keyframe out(right side) interpolation mode.\n" ..
                                                " - Hold to switch between:\n" ..
                                                "    1. Smooth\n" ..
                                                "    2. Linear\n" ..
                                                "    3. Step\n" ..
                                                "    4. Slow\n" ..
                                                "    5. Fast\n";
L["AM_TOOLBAR_TT_REMOVE_KEYFRAME"] = "Delete Keyframe";
L["AM_TOOLBAR_TT_SEEK_TO_START"] = "Seek to Start";
L["AM_TOOLBAR_TT_SKIP_FRAME_BACK"] = "Jump to previous frame";
L["AM_TOOLBAR_TT_PLAY_PAUSE"] = "Play / Pause";
L["AM_TOOLBAR_TT_SKIP_FRAME_FORWARD"] = "Jump to next frame";
L["AM_TOOLBAR_TT_SEEK_TO_END"] = "Seek to End";
L["AM_TOOLBAR_TT_LOOP"] = "Loop Playback on/off";
L["AM_TT_LIST"] = "Select Timeline";
L["AM_TT_ADDTIMELINE"] = "Add Timeline";
L["AM_RMB_CHANGE_ANIM"] = "Change Animation";
L["AM_RMB_SET_ANIM_SPEED"] = "Set Animation Speed";
L["AM_RMB_DELETE_ANIM"] = "Delete Animation";
L["AM_RMB_DIFFERENT_COLOR"] = "Different Color";
L["AM_SET_ANIMATION_SPEED_PERCENT"] = "Set Animation Speed %";
L["AM_TIMER_SET_DURATION"] = "Set Timeline Duration";

-- AssetBrowser/AssetExplorer --
L["AB_RESULTS"] = "%d Results";             -- <number> results (search results)
L["AB_BREADCRUMB"] = "...";             -- for a file path
L["AB_TOOLBAR_TT_UP_ONE_FOLDER"] = "Up one folder.";
L["AM_MSG_REMOVE_COLLECTION_TITLE"] = "Remove Collection";
L["AB_MSG_REMOVE_COLLECTION_MESSAGE"] = "The collection contains items, are you sure you want to remove it?";
L["AB_TOOLBAR_TT_NEW_COLLECTION"] = "New Collection";
L["AB_TOOLBAR_TT_REMOVE_COLLECTION"] = "Remove Collection";
L["AB_TOOLBAR_TT_RENAME_COLLECTION"] = "Rename Collection";
L["AB_TOOLBAR_TT_ADD_OBJECT"] = "Add Selected Object";
L["AB_TOOLBAR_TT_REMOVE_OBJECT"] = "Remove Object";
L["AB_TOOLBAR_TT_IMPORT_COLLECTION"] = "Import Collection";
L["AB_TOOLBAR_TT_EXPORT_COLLECTION"] = "Export Collection";
L["AB_RMB_FILE_INFO"] = "File Info";
L["AB_RMB_ADD_TO_COLLECTION"] = "Add to Collection";
L["AB_COLLECTION_NAME"] = "Collection Name";
L["AB_COLLECTION_RENAME"] = "Rename Collection";

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
L["SM_TT_LIST"] = "Select scene";
L["SM_TT_ADDSCENE"] = "Add Scene";
L["SM_EXIT_CAMERA"] = "Exit Camera";

-- Object Properties --
L["OP_TITLE"] = "Properties";
L["OP_TRANSFORM"] = "Transform";
L["OP_ACTOR_PROPERTIES"] = "Actor Properties";
L["OP_SCENE_PROPERTIES"] = "Scene properties";
L["OP_AMBIENT_COLOR"] = "Ambient Color";
L["OP_DIFFUSE_COLOR"] = "Diffuse Color";
L["OP_BACKGROUND_COLOR"] = "Background Color";
L["OP_TT_RESET_VALUE"] = "Reset value to default";
L["OP_TT_X_FIELD"] = "X";
L["OP_TT_Y_FIELD"] = "Y";
L["OP_TT_Z_FIELD"] = "Z";
L["OP_ENABLE_LIGHTING"] = "Enable Lighting";
L["OP_CAMERA_PROPERTIES"] = "Camera Properties";
L["FOV"] = "Field of View";
L["NEARCLIP"] = "Near Clip";
L["FARCLIP"] = "Far Clip";

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

-- Error Messages --
L["DECODE_FAILED"] = "Failed to decode data.";
L["DECOMPRESS_FAILED"] = "Failed to decompress data.";
L["DESERIALIZE_FAILED"] = "Failed to deserialize data.";
L["DATA_VERSION_TOO_NEW"] = "Newer data version detected, and is unsupported. Please update SceneMachine";

SceneMachine.Editor.localization = AceLocale:GetLocale("SceneMachine", false);