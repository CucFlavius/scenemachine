local AceLocale = LibStub("AceLocale-3.0");
local L = AceLocale:NewLocale("SceneMachine", "ruRU", false);
if not L then return end

-- General --
L["YES"] = "Да";
L["NO"] = "Нет";
L["POSITION"] = "Позиция";
L["ROTATION"] = "Поворот";
L["SCALE"] = "Масштаб";
L["ALPHA"] = "Прозрачность";
L["DESATURATION"] = "Десатурация";
L["SEARCH"] = "Поиск";
L["RENAME"] = "Переименовать";
L["EDIT"] = "Редактировать";
L["DELETE"] = "Удалить";
L["BUTTON_SAVE"] = "Сохранить";
L["BUTTON_CANCEL"] = "Отмена";
L["EXPORT"] = "Экспорт";
L["IMPORT"] = "Импорт";
L["SCROLL_TOP"] = "Перейти в начало";
L["SCROLL_BOTTOM"] = "Перейти в конец";
L["LOAD"] = "Загрузить";

-- Editor --
L["ADDON_NAME"] = "Scene Machine";
L["EDITOR_MAIN_WINDOW_TITLE"] = "Scene Machine %s - %s"; -- Scene Machine <version> - <current project name>
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
L["EDITOR_TOOLBAR_TT_CREATE_CHARACTER"] = "Create Character";
L["EDITOR_FULLSCREEN_NOTIFICATION"] = "Entered Fullscreen\nPress ESC to exit\nPress P to play/pause";
L["EDITOR_TOOLBAR_TT_LETTERBOX_ON"] = "Hide Letterbox (black bars)";
L["EDITOR_TOOLBAR_TT_LETTERBOX_OFF"] = "Show Letterbox (black bars)";
L["EDITOR_TOOLBAR_TT_FULLSCREEN"] = "Enter Fullscreen";

-- Main Menu --
L["MM_FILE"] = "Файл";
L["MM_EDIT"] = "Правка";
L["MM_OPTIONS"] = "Параметры";
L["MM_HELP"] = "Справка";
L["MM_PROJECT_MANAGER"] = "Менеджер проектов";
L["MM_IMPORT_SCENESCRIPT"] = "Импорт Scenescript";
L["MM_SAVE"] = "Сохранить";
L["MM_CLONE_SELECTED"] = "Клонировать выбранный";
L["MM_DELETE_SELECTED"] = "Удалить выбранный";
L["MM_SET_SCALE"] = "Установить масштаб %s";
L["MM_KEYBOARD_SHORTCUTS"] = "Горячие клавиши";
L["MM_ABOUT"] = "О программе";
L["MM_SCENE"] = "Сцена";
L["MM_SCENE_NEW"] = "Новый";
L["MM_SCENE_REMOVE"] = "Удалить";
L["MM_SCENE_RENAME"] = "Переименовать";
L["MM_SCENE_EXPORT"] = "Экспорт";
L["MM_SCENE_IMPORT"] = "Импорт";
L["MM_TITLE_SCENE_NAME"] = "Название сцены";
L["MM_TITLE_SCENE_RENAME"] = "Переименовать сцену";
L["MM_SETTINGS"] = "Настройки";

-- Context Menu --
L["CM_SELECT"] = "Выбрать";
L["CM_MOVE"] = "Переместить";
L["CM_ROTATE"] = "Повернуть";
L["CM_SCALE"] = "Масштаб";
L["CM_DELETE"] = "Удалить";
L["CM_HIDE_SHOW"] = "Скрыть/Показать";
L["CM_HIDE"] = "Скрыть";
L["CM_SHOW"] = "Показать";
L["CM_FREEZE_UNFREEZE"] = "Заморозить/Отморозить";
L["CM_FREEZE"] = "Заморозить";
L["CM_UNFREEZE"] = "Отморозить";
L["CM_RENAME"] = "Переименовать";
L["CM_FOCUS"] = "Фокус";
L["CM_GROUP"] = "Группа";

-- Animation Manager --
L["AM_ANIMATION_LIST_WINDOW_TITLE"] = "Список анимаций";
L["AM_TIMELINE"] = "График %d";  -- номер графика
L["AM_MSG_DELETE_TIMELINE_TITLE"] = "Удалить график";
L["AM_MSG_DELETE_TIMELINE_MESSAGE"] = "Вы уверены, что хотите продолжить?";
L["AM_MSG_NO_TRACK_TITLE"] = "Нет трека";
L["AM_MSG_NO_TRACK_MESSAGE"] = "Объект не имеет анимационного трека. Хотите добавить один?";
L["AM_BUTTON_ADD_ANIMATION"] = "Добавить анимацию";
L["AM_BUTTON_CHANGE_ANIMATION"] = "Изменить анимацию";
L["AM_TIMELINE_NAME"] = "Название графика";
L["AM_TOOLBAR_TRACKS"] = "Треки";
L["AM_TOOLBAR_KEYFRAMES"] = "Ключевые кадры";
L["AM_TOOLBAR_CURVES"] = "Кривые (только для отладки)";
L["AM_TOOLBAR_TT_UIMODE"] = "Переключить режим анимации";
L["AM_TOOLBAR_TTD_UIMODE"] = "Переключить режим анимации:\n 1. Просмотр треков - Управление различными треками объектов, добавление анимаций модели и ключевых кадров\n 2. Просмотр ключевых кадров - Дополнительное управление ключевыми кадрами\n 3. Просмотр кривых - (Пока не реализовано - в настоящее время используется только для отладки)\n";
L["AM_TOOLBAR_TT_ADD_TRACK"] = "Добавить трек";
L["AM_TOOLBAR_TTD_ADD_TRACK"] = "Добавить трек:\n - Создает новый анимационный трек и назначает его выбранному объекту в сцене\n - Объект в сцене требует трек для выполнения анимации\n - Любой объект может иметь только один назначенный трек";
L["AM_TOOLBAR_TT_REMOVE_TRACK"] = "Удалить трек";
L["AM_TOOLBAR_TT_ADD_ANIMATION"] = "Добавить анимацию";
L["AM_TOOLBAR_TTD_ADD_ANIMATION"] = "Добавить анимацию:\n - Добавляет анимационный клип к текущему выбранному треку/объекту\n - Открывает окно Списка анимаций, где вы можете выбрать доступный клип";
L["AM_TOOLBAR_TT_REMOVE_ANIMATION"] = "Удалить анимацию";
L["AM_TOOLBAR_TT_ADD_KEYFRAME"] = "Добавить ключевой кадр";
L["AM_TOOLBAR_TTD_ADD_KEYFRAME"] = "Добавить ключевой кадр:\n - Добавить ключевой кадр в текущее время\n - Нажмите и удерживайте, чтобы переключаться между:\n    1. Добавление ключевого кадра ко всем трансформациям;\n    2. Добавление ключевого кадра только для позиции;\n    3. Добавление ключевого кадра только для вращения;\n    4. Добавление ключевого кадра только для масштаба;";
L["AM_TOOLBAR_TT_SET_INTERPOLATION_IN"] = "Установить интерполяцию на входе";
L["AM_TOOLBAR_TTD_SET_INTERPOLATION_IN"] = "Установить интерполяцию на входе:\n - Установить режим интерполяции в ключевом кадре на входе (левой стороне)\n - Нажмите и удерживайте, чтобы переключаться между:\n    1. Плавный\n    2. Линейный\n    3. Шаговый\n    4. Медленный\n    5. Быстрый\n";
L["AM_TOOLBAR_TT_SET_INTERPOLATION_OUT"] = "Установить интерполяцию на выходе";
L["AM_TOOLBAR_TTD_SET_INTERPOLATION_OUT"] = "Установить интерполяцию на выходе:\n - Установить режим интерполяции в ключевом кадре на выходе (правой стороне)\n - Нажмите и удерживайте, чтобы переключаться между:\n    1. Плавный\n    2. Линейный\n    3. Шаговый\n    4. Медленный\n    5. Быстрый\n";
L["AM_TOOLBAR_TT_REMOVE_KEYFRAME"] = "Удалить ключевой кадр";
L["AM_TOOLBAR_TT_SEEK_TO_START"] = "Перейти к началу";
L["AM_TOOLBAR_TT_SKIP_FRAME_BACK"] = "Перейти к предыдущему кадру";
L["AM_TOOLBAR_TT_PLAY_PAUSE"] = "Воспроизвести / Пауза";
L["AM_TOOLBAR_TT_SKIP_FRAME_FORWARD"] = "Перейти к следующему кадру";
L["AM_TOOLBAR_TT_SEEK_TO_END"] = "Перейти в конец";
L["AM_TOOLBAR_TT_LOOP"] = "Зациклить воспроизведение вкл/выкл";
L["AM_TOOLBAR_TT_PLAYCAMERA"] = "Воспроизведение камеры вкл/выкл";
L["AM_TT_LIST"] = "Выбор графика";
L["AM_TT_ADDTIMELINE"] = "Добавить график";
L["AM_RMB_CHANGE_ANIM"] = "Изменить анимацию";
L["AM_RMB_SET_ANIM_SPEED"] = "Установить скорость анимации";
L["AM_RMB_DELETE_ANIM"] = "Удалить анимацию";
L["AM_RMB_DIFFERENT_COLOR"] = "Другой цвет";
L["AM_SET_ANIMATION_SPEED_PERCENT"] = "Установить скорость анимации %";
L["AM_TIMER_SET_DURATION"] = "Установить длительность графика";

-- AssetBrowser/AssetExplorer --
L["AB_RESULTS"] = "%d Результатов";             -- <number> результатов (результаты поиска)
L["AB_BREADCRUMB"] = "...";             -- для пути к файлу
L["AB_TOOLBAR_TT_UP_ONE_FOLDER"] = "На один уровень вверх.";
L["AM_MSG_REMOVE_COLLECTION_TITLE"] = "Удалить Коллекцию";
L["AB_MSG_REMOVE_COLLECTION_MESSAGE"] = "Коллекция содержит элементы, вы уверены, что хотите ее удалить?";
L["AB_TOOLBAR_TT_NEW_COLLECTION"] = "Новая Коллекция";
L["AB_TOOLBAR_TT_REMOVE_COLLECTION"] = "Удалить Коллекцию";
L["AB_TOOLBAR_TT_RENAME_COLLECTION"] = "Переименовать Коллекцию";
L["AB_TOOLBAR_TT_ADD_OBJECT"] = "Добавить Выбранный Объект";
L["AB_TOOLBAR_TT_REMOVE_OBJECT"] = "Удалить Объект";
L["AB_TOOLBAR_TT_IMPORT_COLLECTION"] = "Импортировать Коллекцию";
L["AB_TOOLBAR_TT_EXPORT_COLLECTION"] = "Экспортировать Коллекцию";
L["AB_RMB_FILE_INFO"] = "Информация о файле";
L["AB_RMB_ADD_TO_COLLECTION"] = "Добавить в Коллекцию";
L["AB_COLLECTION_NAME"] = "Название Коллекции";
L["AB_COLLECTION_RENAME"] = "Переименовать Коллекцию";
L["AB_TAB_MODELS"] = "Модели";
L["AB_TAB_CREATURES"] = "Существа";
L["AB_TAB_COLLECTIONS"] = "Коллекции";
L["AB_TAB_DEBUG"] = "Отладка";

-- Project Manager --
L["PM_WINDOW_TITLE"] = "Менеджер проектов";
L["PM_PROJECT_NAME"] = "Название проекта";
L["PM_NEW_PROJECT"] = "Новый проект";
L["PM_EDIT_PROJECT"] = "Редактировать проект";
L["PM_MSG_DELETE_PROJECT_TITLE"] = "Удалить проект";
L["PM_MSG_DELETE_PROJECT_MESSAGE"] = "Удаление проекта также приведет к удалению всех его сцен и данных. Продолжить?";
L["PM_BUTTON_NEW_PROJECT"] = "Новый проект";
L["PM_BUTTON_LOAD_PROJECT"] = "Загрузить проект";
L["PM_BUTTON_EDIT_PROJECT"] = "Редактировать проект";
L["PM_BUTTON_REMOVE_PROJECT"] = "Удалить проект";
L["PM_BUTTON_SAVE_DATA"] = "Сохранить данные";

-- Scene Manager --
L["SM_SCENE"] = "Сцена %d";                   -- номер сцены
L["SM_MSG_DELETE_SCENE_TITLE"] = "Удалить сцену";
L["SM_MSG_DELETE_SCENE_MESSAGE"] = "Вы уверены, что хотите продолжить?";
L["SM_SCENE_NAME"] = "Название сцены";
L["SM_TT_LIST"] = "Выберите сцену";
L["SM_TT_ADDSCENE"] = "Добавить сцену";
L["SM_EXIT_CAMERA"] = "Выйти из камеры";

-- Object Properties --
L["OP_TITLE"] = "Свойства";
L["OP_TRANSFORM"] = "Преобразование";
L["OP_ACTOR_PROPERTIES"] = "Свойства актера";
L["OP_SCENE_PROPERTIES"] = "Свойства сцены";
L["OP_AMBIENT_COLOR"] = "Окружающий цвет";
L["OP_DIFFUSE_COLOR"] = "Рассеиваемый цвет";
L["OP_BACKGROUND_COLOR"] = "Цвет фона";
L["OP_TT_RESET_VALUE"] = "Сбросить значение на умолчание";
L["OP_TT_X_FIELD"] = "Х";
L["OP_TT_Y_FIELD"] = "Y";
L["OP_TT_Z_FIELD"] = "Z";
L["OP_ENABLE_LIGHTING"] = "Включить освещение";
L["OP_CAMERA_PROPERTIES"] = "Свойства камеры";
L["FOV"] = "Угол обзора";
L["NEARCLIP"] = "Ближняя отсечка";
L["FARCLIP"] = "Дальняя отсечка";
L["OP_ENABLE_FOG"] = "Включить Туман";
L["OP_FOG_COLOR"] = "Цвет Тумана";
L["OP_FOG_DISTANCE"] = "Дальность Тумана";

-- Scene Hierarchy --
L["SH_TITLE"] = "Иерархия сцены";

-- Color Picker --
L["COLP_WINDOW_TITLE"] = "Выбор цвета";
L["COLP_RGB_NAME"] = "RGB (Красный/Зеленый/Синий):";
L["COLP_HSL_NAME"] = "HSL (Тон/Насыщенность/Яркость):";
L["COLP_R"] = "К";  -- Красный
L["COLP_G"] = "З";  -- Зеленый
L["COLP_B"] = "С";  -- Синий
L["COLP_H"] = "Т";  -- Тон
L["COLP_S"] = "Н";  -- Насыщенность
L["COLP_L"] = "Я";  -- Яркость

-- About Screen --
L["ABOUT_WINDOW_TITLE"] = "Машина сцен";
L["ABOUT_VERSION"] = "Версия %s";
L["ABOUT_DESCRIPTION"] = "Машина сцен - это инструмент для создания и редактирования трехмерных сцен с использованием доступных в игре моделей. Он использует API ModelScene в качестве основы, поэтому существуют некоторые ограничения.";
L["ABOUT_LICENSE"] = "Лицензировано на условиях лицензии MIT";
L["ABOUT_AUTHOR"] = "Автор: %s";
L["ABOUT_CONTACT"] = "Контакт: %s";

-- Settings window --
L["SETTINGS_WINDOW_TITLE"] = "Настройки";
L["SETTINGS_TAB_GENERAL"] = "Общие";
L["SETTINGS_TAB_GIZMOS"] = "Гизмо";
L["SETTINGS_TAB_DEBUG"] = "Отладка";
L["SETTINGS_EDITOR_SCALE"] = "Масштаб редактора";
L["SETTINGS_SHOW_SELECTION_HIGHLIGHT"] = "Показать выделение объектов";
L["SETTINGS_HIDE_PARALLEL_GIZMOS"] = "Скрыть гизмо параллельно камере";
L["SETTINGS_ALWAYS_SHOW_CAM_GIZMO"] = "Всегда показывать гизмо камеры";
L["SETTINGS_GIZMO_SIZE"] = "Размер гизмо";
L["SETTINGS_SHOW_DEBUG_TAB"] = "Показать вкладку Отладка в Браузере активов";

-- Error Messages --
L["DECODE_FAILED"] = "Не удалось декодировать данные.";
L["DECOMPRESS_FAILED"] = "Не удалось разархивировать данные.";
L["DESERIALIZE_FAILED"] = "Не удалось десериализовать данные.";
L["DATA_VERSION_TOO_NEW"] = "Обнаружена более новая версия данных, которая не поддерживается. Пожалуйста, обновите SceneMachine.";

