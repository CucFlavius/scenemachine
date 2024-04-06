local AceLocale = LibStub("AceLocale-3.0");
local L = AceLocale:NewLocale("SceneMachine", "zhCN", false);
if not L then return end

-- General --
L["YES"] = "是";
L["NO"] = "否";
L["POSITION"] = "位置";
L["ROTATION"] = "旋转";
L["SCALE"] = "缩放";
L["ALPHA"] = "透明度";
L["DESATURATION"] = "去色";
L["SEARCH"] = "搜索";
L["RENAME"] = "重命名";
L["EDIT"] = "编辑";
L["DELETE"] = "删除";
L["BUTTON_SAVE"] = "保存";
L["BUTTON_CANCEL"] = "取消";
L["EXPORT"] = "导出";
L["IMPORT"] = "导入";
L["SCROLL_TOP"] = "跳至顶部";
L["SCROLL_BOTTOM"] = "跳至底部";
L["LOAD"] = "加载";

-- Editor --
L["ADDON_NAME"] = "场景机器";
L["EDITOR_MAIN_WINDOW_TITLE"] = "场景机器 %s - %s";       -- Scene Machine <version> - <current project name>
L["EDITOR_MSG_DELETE_OBJECT_TITLE"] = "删除对象";
L["EDITOR_MSG_DELETE_OBJECT_MESSAGE"] = "该对象包含动画轨道，确定要删除吗？";
L["EDITOR_MSG_DELETE_TRACK_TITLE"] = "删除轨道";
L["EDITOR_MSG_DELETE_TRACK_A_K_MESSAGE"] = "该轨道包含动画和关键帧，确定要删除吗？";
L["EDITOR_MSG_DELETE_TRACK_A_MESSAGE"] = "该轨道包含动画，确定要删除吗？";
L["EDITOR_MSG_DELETE_TRACK_K_MESSAGE"] = "该轨道包含关键帧，确定要删除吗？";
L["EDITOR_MSG_SAVE_TITLE"] = "保存";
L["EDITOR_MSG_SAVE_MESSAGE"] = "保存需要重新加载用户界面，确定要继续吗？";
L["EDITOR_SCENESCRIPT_WINDOW_TITLE"] = "导入场景脚本";
L["EDITOR_TOOLBAR_TT_OPEN_PROJECT_MANAGER"] = "打开项目管理器";
L["EDITOR_TOOLBAR_TT_PROJECT_LIST"] = "切换项目";
L["EDITOR_TOOLBAR_TT_SELECT_TOOL"] = "选择工具";
L["EDITOR_TOOLBAR_TT_MOVE_TOOL"] = "移动工具";
L["EDITOR_TOOLBAR_TT_ROTATE_TOOL"] = "旋转工具";
L["EDITOR_TOOLBAR_TT_SCALE_TOOL"] = "缩放工具";
L["EDITOR_TOOLBAR_TT_PIVOT_LOCAL_SPACE"] = "局部坐标轴";
L["EDITOR_TOOLBAR_TT_PIVOT_WORLD_SPACE"] = "世界坐标轴";
L["EDITOR_TOOLBAR_TT_PIVOT_CENTER"] = "中心点坐标";
L["EDITOR_TOOLBAR_TT_PIVOT_BASE"] = "基准点坐标";
L["EDITOR_IMPORT_EXPORT_WINDOW_TITLE"] = "导入 - 导出";
L["EDITOR_NAME_RENAME_WINDOW_TITLE"] = "更名";
L["EDITOR_TOOLBAR_TT_MULTITRANSFORM_TOGETHER"] = "一起转换";
L["EDITOR_TOOLBAR_TT_MULTITRANSFORM_INDIVIDUAL"] = "单独转换";
L["EDITOR_TOOLBAR_TT_UNDO"] = "撤销";
L["EDITOR_TOOLBAR_TT_REDO"] = "重做";
L["EDITOR_TOOLBAR_TT_CREATE_CAMERA"] = "创建摄像机";
L["EDITOR_TOOLBAR_TT_CREATE_CHARACTER"] = "创建角色";
L["EDITOR_FULLSCREEN_NOTIFICATION"] = "已进入全屏模式\n按 ESC 键退出\n按 P 键播放/暂停";
L["EDITOR_TOOLBAR_TT_LETTERBOX_ON"] = "隐藏信封条（黑边）";
L["EDITOR_TOOLBAR_TT_LETTERBOX_OFF"] = "显示信封条（黑边）";
L["EDITOR_TOOLBAR_TT_FULLSCREEN"] = "进入全屏模式";

-- Main Menu --
L["MM_FILE"] = "文件";
L["MM_EDIT"] = "编辑";
L["MM_OPTIONS"] = "选项";
L["MM_HELP"] = "帮助";
L["MM_PROJECT_MANAGER"] = "项目管理器";
L["MM_IMPORT_SCENESCRIPT"] = "导入场景脚本";
L["MM_SAVE"] = "保存";
L["MM_CLONE_SELECTED"] = "克隆所选";
L["MM_DELETE_SELECTED"] = "删除所选";
L["MM_SET_SCALE"] = "设置比例 %s";
L["MM_KEYBOARD_SHORTCUTS"] = "键盘快捷键";
L["MM_ABOUT"] = "关于";
L["MM_SCENE"] = "场景";
L["MM_SCENE_NEW"] = "新建";
L["MM_SCENE_REMOVE"] = "移除";
L["MM_SCENE_RENAME"] = "重命名";
L["MM_SCENE_EXPORT"] = "导出";
L["MM_SCENE_IMPORT"] = "导入";
L["MM_TITLE_SCENE_NAME"] = "场景名称";
L["MM_TITLE_SCENE_RENAME"] = "场景重命名";
L["MM_SETTINGS"] = "设置";

-- Context Menu --
L["CM_SELECT"] = "选择";
L["CM_MOVE"] = "移动";
L["CM_ROTATE"] = "旋转";
L["CM_SCALE"] = "缩放";
L["CM_DELETE"] = "删除";
L["CM_HIDE_SHOW"] = "隐藏/显示";
L["CM_HIDE"] = "隐藏";
L["CM_SHOW"] = "显示";
L["CM_FREEZE_UNFREEZE"] = "冻结/解冻";
L["CM_FREEZE"] = "冻结";
L["CM_UNFREEZE"] = "解冻";
L["CM_RENAME"] = "重命名";
L["CM_FOCUS"] = "焦点";
L["CM_GROUP"] = "分组";

-- Animation Manager --
L["AM_ANIMATION_LIST_WINDOW_TITLE"] = "动画列表";
L["AM_TIMELINE"] = "时间轴 %d";           -- 时间轴编号
L["AM_MSG_DELETE_TIMELINE_TITLE"] = "删除时间轴";
L["AM_MSG_DELETE_TIMELINE_MESSAGE"] = "您确定要继续吗？";
L["AM_MSG_NO_TRACK_TITLE"] = "无轨道";
L["AM_MSG_NO_TRACK_MESSAGE"] = "对象没有动画轨道，您要添加一个吗？";
L["AM_BUTTON_ADD_ANIMATION"] = "添加动画";
L["AM_BUTTON_CHANGE_ANIMATION"] = "更改动画";
L["AM_TIMELINE_NAME"] = "时间轴名称";
L["AM_TOOLBAR_TRACKS"] = "轨道";
L["AM_TOOLBAR_KEYFRAMES"] = "关键帧";
L["AM_TOOLBAR_CURVES"] = "曲线（仅调试）";
L["AM_TOOLBAR_TT_UIMODE"] = "切换动画模式";
L["AM_TOOLBAR_TTD_UIMODE"] = "切换动画模式：\n 1. 轨道视图 - 管理不同对象轨道，添加模型动画和关键帧\n 2. 关键帧视图 - 对关键帧进行高级控制\n 3. 曲线视图 - （尚未实现 - 目前仅用于调试）\n";
L["AM_TOOLBAR_TT_ADD_TRACK"] = "添加轨道";
L["AM_TOOLBAR_TTD_ADD_TRACK"] = "添加轨道：\n - 创建一个新的动画轨道，并将其分配给所选场景对象\n - 场景中的对象需要轨道才能执行任何动画操作\n - 任何对象最多只能分配一个轨道";
L["AM_TOOLBAR_TT_REMOVE_TRACK"] = "删除轨道";
L["AM_TOOLBAR_TT_ADD_ANIMATION"] = "添加动画";
L["AM_TOOLBAR_TTD_ADD_ANIMATION"] = "添加动画：\n - 向当前选定的轨道/对象添加动画剪辑\n - 打开动画列表窗口，在其中选择可用剪辑";
L["AM_TOOLBAR_TT_REMOVE_ANIMATION"] = "删除动画";
L["AM_TOOLBAR_TT_ADD_KEYFRAME"] = "添加关键帧";
L["AM_TOOLBAR_TTD_ADD_KEYFRAME"] = "添加关键帧：\n - 在当前时间添加关键帧\n - 按住以在以下选项之间切换：\n    1. 添加关键帧到所有转换；\n    2. 仅添加位置关键帧；\n    3. 仅添加旋转关键帧；\n    4. 仅添加缩放关键帧；";
L["AM_TOOLBAR_TT_SET_INTERPOLATION_IN"] = "设置内插入";
L["AM_TOOLBAR_TTD_SET_INTERPOLATION_IN"] = "设置内插入：\n - 设置当前关键帧的内插入（左侧）模式\n - 按住以在以下选项之间切换：\n    1. 平滑\n    2. 线性\n    3. 步进\n    4. 缓慢\n    5. 快速\n";
L["AM_TOOLBAR_TT_SET_INTERPOLATION_OUT"] = "设置外插出";
L["AM_TOOLBAR_TTD_SET_INTERPOLATION_OUT"] = "设置外插出：\n - 设置当前关键帧的外插出（右侧）模式\n - 按住以在以下选项之间切换：\n    1. 平滑\n    2. 线性\n    3. 步进\n    4. 缓慢\n    5. 快速\n";
L["AM_TOOLBAR_TT_REMOVE_KEYFRAME"] = "删除关键帧";
L["AM_TOOLBAR_TT_SEEK_TO_START"] = "定位到开头";
L["AM_TOOLBAR_TT_SKIP_FRAME_BACK"] = "跳到前一帧";
L["AM_TOOLBAR_TT_PLAY_PAUSE"] = "播放/暂停";
L["AM_TOOLBAR_TT_SKIP_FRAME_FORWARD"] = "跳到下一帧";
L["AM_TOOLBAR_TT_SEEK_TO_END"] = "定位到结尾";
L["AM_TOOLBAR_TT_LOOP"] = "循环播放 开/关";
L["AM_TOOLBAR_TT_PLAYCAMERA"] = "相机播放 开/关";
L["AM_TT_LIST"] = "选择时间轴";
L["AM_TT_ADDTIMELINE"] = "新增时间轴";
L["AM_RMB_CHANGE_ANIM"] = "更改动画";
L["AM_RMB_SET_ANIM_SPEED"] = "设置动画速度";
L["AM_RMB_DELETE_ANIM"] = "删除动画";
L["AM_RMB_DIFFERENT_COLOR"] = "不同颜色";
L["AM_SET_ANIMATION_SPEED_PERCENT"] = "设置动画速度 %";
L["AM_TIMER_SET_DURATION"] = "设置时间轴持续时间";

-- AssetBrowser/AssetExplorer --
L["AB_RESULTS"] = "%d 结果";             -- <number> 结果（搜索结果）
L["AB_BREADCRUMB"] = "...";             -- 文件路径
L["AB_TOOLBAR_TT_UP_ONE_FOLDER"] = "返回上一级文件夹。";
L["AM_MSG_REMOVE_COLLECTION_TITLE"] = "移除收藏夹";
L["AB_MSG_REMOVE_COLLECTION_MESSAGE"] = "该收藏夹包含项目，您确定要移除吗？";
L["AB_TOOLBAR_TT_NEW_COLLECTION"] = "新建收藏夹";
L["AB_TOOLBAR_TT_REMOVE_COLLECTION"] = "移除收藏夹";
L["AB_TOOLBAR_TT_RENAME_COLLECTION"] = "重命名收藏夹";
L["AB_TOOLBAR_TT_ADD_OBJECT"] = "添加所选对象";
L["AB_TOOLBAR_TT_REMOVE_OBJECT"] = "移除对象";
L["AB_TOOLBAR_TT_IMPORT_COLLECTION"] = "导入收藏夹";
L["AB_TOOLBAR_TT_EXPORT_COLLECTION"] = "导出收藏夹";
L["AB_RMB_FILE_INFO"] = "文件信息";
L["AB_RMB_ADD_TO_COLLECTION"] = "添加到收藏夹";
L["AB_COLLECTION_NAME"] = "收藏夹名称";
L["AB_COLLECTION_RENAME"] = "重命名收藏夹";
L["AB_TAB_MODELS"] = "模型";
L["AB_TAB_CREATURES"] = "生物";
L["AB_TAB_COLLECTIONS"] = "收藏夹";
L["AB_TAB_DEBUG"] = "调试";

-- Project Manager --
L["PM_WINDOW_TITLE"] = "项目管理";
L["PM_PROJECT_NAME"] = "项目名称";
L["PM_NEW_PROJECT"] = "新建项目";
L["PM_EDIT_PROJECT"] = "编辑项目";
L["PM_MSG_DELETE_PROJECT_TITLE"] = "删除项目";
L["PM_MSG_DELETE_PROJECT_MESSAGE"] = "删除项目将同时删除所有其场景和数据，是否继续？";
L["PM_BUTTON_NEW_PROJECT"] = "新建项目";
L["PM_BUTTON_LOAD_PROJECT"] = "加载项目";
L["PM_BUTTON_EDIT_PROJECT"] = "编辑项目";
L["PM_BUTTON_REMOVE_PROJECT"] = "移除项目";
L["PM_BUTTON_SAVE_DATA"] = "保存数据";

-- Scene Manager --
L["SM_SCENE"] = "场景 %d";                 -- 场景编号
L["SM_MSG_DELETE_SCENE_TITLE"] = "删除场景";
L["SM_MSG_DELETE_SCENE_MESSAGE"] = "您确定要继续吗？";
L["SM_SCENE_NAME"] = "场景名称";
L["SM_TT_LIST"] = "选择场景";
L["SM_TT_ADDSCENE"] = "添加场景";
L["SM_EXIT_CAMERA"] = "退出相机";

-- Object Properties --
L["OP_TITLE"] = "属性";
L["OP_TRANSFORM"] = "变换";
L["OP_ACTOR_PROPERTIES"] = "角色属性";
L["OP_SCENE_PROPERTIES"] = "场景属性";
L["OP_AMBIENT_COLOR"] = "环境颜色";
L["OP_DIFFUSE_COLOR"] = "漫反射颜色";
L["OP_BACKGROUND_COLOR"] = "背景颜色";
L["OP_TT_RESET_VALUE"] = "重置为默认值";
L["OP_TT_X_FIELD"] = "X";
L["OP_TT_Y_FIELD"] = "Y";
L["OP_TT_Z_FIELD"] = "Z";
L["OP_ENABLE_LIGHTING"] = "启用照明";
L["OP_CAMERA_PROPERTIES"] = "相机属性";
L["FOV"] = "视野";
L["NEARCLIP"] = "近裁剪";
L["FARCLIP"] = "远裁剪";
L["OP_ENABLE_FOG"] = "启用雾";
L["OP_FOG_COLOR"] = "雾颜色";
L["OP_FOG_DISTANCE"] = "雾距离";

-- Scene Hierarchy --
L["SH_TITLE"] = "场景层次结构";

-- Color Picker --
L["COLP_WINDOW_TITLE"] = "颜色选择器";
L["COLP_RGB_NAME"] = "RGB（红/绿/蓝）：";
L["COLP_HSL_NAME"] = "HSL（色调/饱和度/亮度）：";
L["COLP_R"] = "红";  -- Red
L["COLP_G"] = "绿";  -- Green
L["COLP_B"] = "蓝";  -- Blue
L["COLP_H"] = "色调";  -- Hue
L["COLP_S"] = "饱和度";  -- Saturation
L["COLP_L"] = "亮度";  -- Lightness

-- About Screen --
L["ABOUT_WINDOW_TITLE"] = "场景工具";
L["ABOUT_VERSION"] = "版本 %s";
L["ABOUT_DESCRIPTION"] = "场景工具是一个使用游戏内可用模型创建和编辑3D场景的工具。它基于ModelScene API，因此存在一些限制。";
L["ABOUT_LICENSE"] = "根据 MIT 许可证授权";
L["ABOUT_AUTHOR"] = "作者：%s";
L["ABOUT_CONTACT"] = "联系：%s";

-- Settings window --
L["SETTINGS_WINDOW_TITLE"] = "设置";
L["SETTINGS_TAB_GENERAL"] = "通用";
L["SETTINGS_TAB_GIZMOS"] = "工具";
L["SETTINGS_TAB_DEBUG"] = "调试";
L["SETTINGS_EDITOR_SCALE"] = "编辑器比例";
L["SETTINGS_SHOW_SELECTION_HIGHLIGHT"] = "显示选择高亮";
L["SETTINGS_HIDE_PARALLEL_GIZMOS"] = "隐藏平行于相机的平移工具";
L["SETTINGS_ALWAYS_SHOW_CAM_GIZMO"] = "始终显示相机工具";
L["SETTINGS_GIZMO_SIZE"] = "工具大小";
L["SETTINGS_SHOW_DEBUG_TAB"] = "在资源浏览器中显示调试选项卡";

-- Error Messages --
L["DECODE_FAILED"] = "解码数据失败。";
L["DECOMPRESS_FAILED"] = "解压数据失败。";
L["DESERIALIZE_FAILED"] = "反序列化数据失败。";
L["DATA_VERSION_TOO_NEW"] = "检测到更新的数据版本，不受支持。请更新 SceneMachine。";

