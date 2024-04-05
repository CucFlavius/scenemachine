local AceLocale = LibStub("AceLocale-3.0");
local L = AceLocale:NewLocale("SceneMachine", "zhTW", false);
if not L then return end

-- General --
L["YES"] = "是";
L["NO"] = "否";
L["POSITION"] = "位置";
L["ROTATION"] = "旋轉";
L["SCALE"] = "比例";
L["ALPHA"] = "透明度";
L["DESATURATION"] = "去飽和度";
L["SEARCH"] = "搜尋";
L["RENAME"] = "重新命名";
L["EDIT"] = "編輯";
L["DELETE"] = "刪除";
L["BUTTON_SAVE"] = "保存";
L["BUTTON_CANCEL"] = "取消";
L["EXPORT"] = "匯出";
L["IMPORT"] = "匯入";
L["SCROLL_TOP"] = "跳至頂部";
L["SCROLL_BOTTOM"] = "跳至底部";
L["LOAD"] = "載入";

-- Editor --
L["ADDON_NAME"] = "場景機器";
L["EDITOR_MAIN_WINDOW_TITLE"] = "場景機器 %s - %s";       -- 場景機器 <version> - <current project name>
L["EDITOR_MSG_DELETE_OBJECT_TITLE"] = "刪除物件";
L["EDITOR_MSG_DELETE_OBJECT_MESSAGE"] = "此物件包含動畫軌道，確定要刪除嗎？";
L["EDITOR_MSG_DELETE_TRACK_TITLE"] = "刪除軌道";
L["EDITOR_MSG_DELETE_TRACK_A_K_MESSAGE"] = "此軌道包含動畫和關鍵幀，確定要刪除嗎？";
L["EDITOR_MSG_DELETE_TRACK_A_MESSAGE"] = "此軌道包含動畫，確定要刪除嗎？";
L["EDITOR_MSG_DELETE_TRACK_K_MESSAGE"] = "此軌道包含關鍵幀，確定要刪除嗎？";
L["EDITOR_MSG_SAVE_TITLE"] = "儲存";
L["EDITOR_MSG_SAVE_MESSAGE"] = "儲存需重新載入 UI，是否繼續？";
L["EDITOR_SCENESCRIPT_WINDOW_TITLE"] = "導入場景腳本";
L["EDITOR_TOOLBAR_TT_OPEN_PROJECT_MANAGER"] = "開啟項目管理器";
L["EDITOR_TOOLBAR_TT_PROJECT_LIST"] = "更改專案";
L["EDITOR_TOOLBAR_TT_SELECT_TOOL"] = "選擇工具";
L["EDITOR_TOOLBAR_TT_MOVE_TOOL"] = "移動工具";
L["EDITOR_TOOLBAR_TT_ROTATE_TOOL"] = "旋轉工具";
L["EDITOR_TOOLBAR_TT_SCALE_TOOL"] = "縮放工具";
L["EDITOR_TOOLBAR_TT_PIVOT_LOCAL_SPACE"] = "本地空間中心點";
L["EDITOR_TOOLBAR_TT_PIVOT_WORLD_SPACE"] = "世界空間中心點";
L["EDITOR_TOOLBAR_TT_PIVOT_CENTER"] = "中心中心點";
L["EDITOR_TOOLBAR_TT_PIVOT_BASE"] = "底座中心點";
L["EDITOR_IMPORT_EXPORT_WINDOW_TITLE"] = "匯入 - 匯出";
L["EDITOR_NAME_RENAME_WINDOW_TITLE"] = "命名 - 重新命名";
L["EDITOR_TOOLBAR_TT_MULTITRANSFORM_TOGETHER"] = "一起轉換";
L["EDITOR_TOOLBAR_TT_MULTITRANSFORM_INDIVIDUAL"] = "各自轉換";
L["EDITOR_TOOLBAR_TT_UNDO"] = "復原";
L["EDITOR_TOOLBAR_TT_REDO"] = "重做";
L["EDITOR_TOOLBAR_TT_CREATE_CAMERA"] = "創建相機";
L["EDITOR_TOOLBAR_TT_CREATE_CHARACTER"] = "創建角色";
L["EDITOR_FULLSCREEN_NOTIFICATION"] = "進入全螢幕\n按 ESC 鍵退出\n按 P 鍵播放/暫停";
L["EDITOR_TOOLBAR_TT_LETTERBOX_ON"] = "隱藏信箱 (黑邊)";
L["EDITOR_TOOLBAR_TT_LETTERBOX_OFF"] = "顯示信箱 (黑邊)";
L["EDITOR_TOOLBAR_TT_FULLSCREEN"] = "進入全螢幕";

-- Main Menu --
L["MM_FILE"] = "檔案";
L["MM_EDIT"] = "編輯";
L["MM_OPTIONS"] = "選項";
L["MM_HELP"] = "說明";
L["MM_PROJECT_MANAGER"] = "專案管理員";
L["MM_IMPORT_SCENESCRIPT"] = "匯入場景腳本";
L["MM_SAVE"] = "儲存";
L["MM_CLONE_SELECTED"] = "複製所選項目";
L["MM_DELETE_SELECTED"] = "刪除所選項目";
L["MM_SET_SCALE"] = "設定比例 %s";
L["MM_KEYBOARD_SHORTCUTS"] = "鍵盤快速鍵";
L["MM_ABOUT"] = "關於";
L["MM_SCENE"] = "場景";
L["MM_SCENE_NEW"] = "新建";
L["MM_SCENE_REMOVE"] = "移除";
L["MM_SCENE_RENAME"] = "重新命名";
L["MM_SCENE_EXPORT"] = "匯出";
L["MM_SCENE_IMPORT"] = "匯入";
L["MM_TITLE_SCENE_NAME"] = "場景名稱";
L["MM_TITLE_SCENE_RENAME"] = "重新命名場景";
L["MM_SETTINGS"] = "設定";

-- Context Menu --
L["CM_SELECT"] = "選擇";
L["CM_MOVE"] = "移動";
L["CM_ROTATE"] = "旋轉";
L["CM_SCALE"] = "縮放";
L["CM_DELETE"] = "刪除";
L["CM_HIDE_SHOW"] = "隱藏/顯示";
L["CM_HIDE"] = "隱藏";
L["CM_SHOW"] = "顯示";
L["CM_FREEZE_UNFREEZE"] = "凍結/解凍";
L["CM_FREEZE"] = "凍結";
L["CM_UNFREEZE"] = "解凍";
L["CM_RENAME"] = "重新命名";
L["CM_FOCUS"] = "焦點";
L["CM_GROUP"] = "分組";

-- Animation Manager --
L["AM_ANIMATION_LIST_WINDOW_TITLE"] = "動畫清單";
L["AM_TIMELINE"] = "時間軸 %d";           -- timeline number
L["AM_MSG_DELETE_TIMELINE_TITLE"] = "刪除時間軸";
L["AM_MSG_DELETE_TIMELINE_MESSAGE"] = "您確定要繼續嗎？";
L["AM_MSG_NO_TRACK_TITLE"] = "無軌道";
L["AM_MSG_NO_TRACK_MESSAGE"] = "物件沒有動畫軌道，您要新增一個嗎？";
L["AM_BUTTON_ADD_ANIMATION"] = "新增動畫";
L["AM_BUTTON_CHANGE_ANIMATION"] = "更改動畫";
L["AM_TIMELINE_NAME"] = "時間軸名稱";
L["AM_TOOLBAR_TRACKS"] = "軌道";
L["AM_TOOLBAR_KEYFRAMES"] = "關鍵影格";
L["AM_TOOLBAR_CURVES"] = "曲線（僅偵錯用）";
L["AM_TOOLBAR_TT_UIMODE"] = "切換動畫模式";
L["AM_TOOLBAR_TTD_UIMODE"] = "切換動畫模式：\n";
L["AM_TOOLBAR_TT_ADD_TRACK"] = "新增軌道";
L["AM_TOOLBAR_TTD_ADD_TRACK"] = "新增軌道：\n";
L["AM_TOOLBAR_TT_REMOVE_TRACK"] = "刪除軌道";
L["AM_TOOLBAR_TT_ADD_ANIMATION"] = "新增動畫";
L["AM_TOOLBAR_TTD_ADD_ANIMATION"] = "新增動畫：\n";
L["AM_TOOLBAR_TT_REMOVE_ANIMATION"] = "刪除動畫";
L["AM_TOOLBAR_TT_ADD_KEYFRAME"] = "新增關鍵影格";
L["AM_TOOLBAR_TTD_ADD_KEYFRAME"] = "新增關鍵影格：\n";
L["AM_TOOLBAR_TT_SET_INTERPOLATION_IN"] = "設定內插入值";
L["AM_TOOLBAR_TTD_SET_INTERPOLATION_IN"] = "設定內插入值：\n";
L["AM_TOOLBAR_TT_SET_INTERPOLATION_OUT"] = "設定外插出值";
L["AM_TOOLBAR_TTD_SET_INTERPOLATION_OUT"] = "設定外插出值：\n";
L["AM_TOOLBAR_TT_REMOVE_KEYFRAME"] = "刪除關鍵影格";
L["AM_TOOLBAR_TT_SEEK_TO_START"] = "定位到開頭";
L["AM_TOOLBAR_TT_SKIP_FRAME_BACK"] = "跳至前一幀";
L["AM_TOOLBAR_TT_PLAY_PAUSE"] = "播放 / 暫停";
L["AM_TOOLBAR_TT_SKIP_FRAME_FORWARD"] = "跳至下一幀";
L["AM_TOOLBAR_TT_SEEK_TO_END"] = "定位到結尾";
L["AM_TOOLBAR_TT_LOOP"] = "循環播放 開啟/關閉";
L["AM_TOOLBAR_TT_PLAYCAMERA"] = "攝影機播放 開啟/關閉";
L["AM_TT_LIST"] = "選擇時間軸";
L["AM_TT_ADDTIMELINE"] = "新增時間軸";
L["AM_RMB_CHANGE_ANIM"] = "更改動畫";
L["AM_RMB_SET_ANIM_SPEED"] = "設定動畫速度";
L["AM_RMB_DELETE_ANIM"] = "刪除動畫";
L["AM_RMB_DIFFERENT_COLOR"] = "不同顏色";
L["AM_SET_ANIMATION_SPEED_PERCENT"] = "設定動畫速度 %";
L["AM_TIMER_SET_DURATION"] = "設定時間軸持續時間";

-- AssetBrowser/AssetExplorer --
L["AB_RESULTS"] = "%d 結果";
L["AB_BREADCRUMB"] = "...";
L["AB_TOOLBAR_TT_UP_ONE_FOLDER"] = "回上層目錄。";
L["AM_MSG_REMOVE_COLLECTION_TITLE"] = "移除收藏";
L["AB_MSG_REMOVE_COLLECTION_MESSAGE"] = "該收藏包含項目，確定要移除嗎？";
L["AB_TOOLBAR_TT_NEW_COLLECTION"] = "新建收藏";
L["AB_TOOLBAR_TT_REMOVE_COLLECTION"] = "移除收藏";
L["AB_TOOLBAR_TT_RENAME_COLLECTION"] = "重新命名收藏";
L["AB_TOOLBAR_TT_ADD_OBJECT"] = "加入所選項目";
L["AB_TOOLBAR_TT_REMOVE_OBJECT"] = "移除項目";
L["AB_TOOLBAR_TT_IMPORT_COLLECTION"] = "匯入收藏";
L["AB_TOOLBAR_TT_EXPORT_COLLECTION"] = "匯出收藏";
L["AB_RMB_FILE_INFO"] = "檔案資訊";
L["AB_RMB_ADD_TO_COLLECTION"] = "加入至收藏";
L["AB_COLLECTION_NAME"] = "收藏名稱";
L["AB_COLLECTION_RENAME"] = "重新命名收藏";
L["AB_TAB_MODELS"] = "模型";
L["AB_TAB_CREATURES"] = "生物";
L["AB_TAB_COLLECTIONS"] = "收藏";
L["AB_TAB_DEBUG"] = "偵錯";

-- Project Manager --
L["PM_WINDOW_TITLE"] = "專案管理器";
L["PM_PROJECT_NAME"] = "專案名稱";
L["PM_NEW_PROJECT"] = "新專案";
L["PM_EDIT_PROJECT"] = "編輯專案";
L["PM_MSG_DELETE_PROJECT_TITLE"] = "刪除專案";
L["PM_MSG_DELETE_PROJECT_MESSAGE"] = "刪除專案將同時刪除所有場景和資料，確定要繼續嗎？";
L["PM_BUTTON_NEW_PROJECT"] = "新專案";
L["PM_BUTTON_LOAD_PROJECT"] = "載入專案";
L["PM_BUTTON_EDIT_PROJECT"] = "編輯專案";
L["PM_BUTTON_REMOVE_PROJECT"] = "移除專案";
L["PM_BUTTON_SAVE_DATA"] = "儲存資料";

-- Scene Manager --
L["SM_SCENE"] = "場景 %d";                 -- 場景號碼
L["SM_MSG_DELETE_SCENE_TITLE"] = "刪除場景";
L["SM_MSG_DELETE_SCENE_MESSAGE"] = "確定要繼續嗎？";
L["SM_SCENE_NAME"] = "場景名稱";
L["SM_TT_LIST"] = "選擇場景";
L["SM_TT_ADDSCENE"] = "新增場景";
L["SM_EXIT_CAMERA"] = "退出攝影機";

-- Object Properties --
L["OP_TITLE"] = "屬性";
L["OP_TRANSFORM"] = "變換";
L["OP_ACTOR_PROPERTIES"] = "角色屬性";
L["OP_SCENE_PROPERTIES"] = "場景屬性";
L["OP_AMBIENT_COLOR"] = "環境光顏色";
L["OP_DIFFUSE_COLOR"] = "漫反射顏色";
L["OP_BACKGROUND_COLOR"] = "背景顏色";
L["OP_TT_RESET_VALUE"] = "重置值為預設值";
L["OP_TT_X_FIELD"] = "X";
L["OP_TT_Y_FIELD"] = "Y";
L["OP_TT_Z_FIELD"] = "Z";
L["OP_ENABLE_LIGHTING"] = "啟用燈光";
L["OP_CAMERA_PROPERTIES"] = "攝影機屬性";
L["FOV"] = "視野";
L["NEARCLIP"] = "近端剪切";
L["FARCLIP"] = "遠端剪切";

-- Scene Hierarchy --
L["SH_TITLE"] = "場景層級";

-- Color Picker --
L["COLP_WINDOW_TITLE"] = "顏色選擇器";
L["COLP_RGB_NAME"] = "RGB（紅/綠/藍）：";
L["COLP_HSL_NAME"] = "HSL（色調/飽和度/明度）：";
L["COLP_R"] = "紅";  -- Red
L["COLP_G"] = "綠";  -- Green
L["COLP_B"] = "藍";  -- Blue
L["COLP_H"] = "色調";  -- Hue
L["COLP_S"] = "飽和度";  -- Saturation
L["COLP_L"] = "明度";  -- Lightness

-- About Screen --
L["ABOUT_WINDOW_TITLE"] = "場景製作機";
L["ABOUT_VERSION"] = "版本 %s";
L["ABOUT_DESCRIPTION"] = "場景製作機是一個使用遊戲內可用模型來創建和編輯3D場景的工具。它基於ModelScene API，因此有一些限制。";
L["ABOUT_LICENSE"] = "根據 MIT 授權許可";
L["ABOUT_AUTHOR"] = "作者：%s";
L["ABOUT_CONTACT"] = "聯絡：%s";

-- Settings window --
L["SETTINGS_WINDOW_TITLE"] = "設定";
L["SETTINGS_TAB_GENERAL"] = "一般";
L["SETTINGS_TAB_GIZMOS"] = "小工具";
L["SETTINGS_TAB_DEBUG"] = "除錯";
L["SETTINGS_EDITOR_SCALE"] = "編輯器比例";
L["SETTINGS_SHOW_SELECTION_HIGHLIGHT"] = "顯示選取框亮點";
L["SETTINGS_HIDE_PARALLEL_GIZMOS"] = "隱藏平行於相機的平移小工具";
L["SETTINGS_ALWAYS_SHOW_CAM_GIZMO"] = "永遠顯示攝影機小工具";
L["SETTINGS_GIZMO_SIZE"] = "小工具大小";
L["SETTINGS_SHOW_DEBUG_TAB"] = "在資產瀏覽器中顯示除錯選項卡";

-- Error Messages --
L["DECODE_FAILED"] = "解碼資料失敗。";
L["DECOMPRESS_FAILED"] = "解壓縮資料失敗。";
L["DESERIALIZE_FAILED"] = "反序列化資料失敗。";
L["DATA_VERSION_TOO_NEW"] = "檢測到更新版本的資料，且不支援。請更新 SceneMachine。";

