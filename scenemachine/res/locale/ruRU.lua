local AceLocale = LibStub("AceLocale-3.0");
local L = AceLocale:NewLocale("SceneMachine", "ruRU", false);
if not L then return end

-- General --
L["YES"] = "Да";
L["NO"] = "Нет";
L["POSITION"] = "Позиция";
L["ROTATION"] = "Вращение";
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
L["ADDON_NAME"] = "Сценарная машина";
L["EDITOR_MAIN_WINDOW_TITLE"] = "Сценарная машина %s - %s"; -- Сценарная машина <версия> - <имя текущего проекта>
L["EDITOR_MSG_DELETE_OBJECT_TITLE"] = "Удалить объект";
L["EDITOR_MSG_DELETE_OBJECT_MESSAGE"] = "Объект содержит трек анимации. Уверены, что хотите удалить?";
L["EDITOR_MSG_DELETE_TRACK_TITLE"] = "Удалить трек";
L["EDITOR_MSG_DELETE_TRACK_A_K_MESSAGE"] = "Трек содержит анимации и ключевые кадры. Уверены, что хотите удалить?";
L["EDITOR_MSG_DELETE_TRACK_A_MESSAGE"] = "Трек содержит анимации. Уверены, что хотите удалить?";
L["EDITOR_MSG_DELETE_TRACK_K_MESSAGE"] = "Трек содержит ключевые кадры. Уверены, что хотите удалить?";
L["EDITOR_MSG_SAVE_TITLE"] = "Сохранить";
L["EDITOR_MSG_SAVE_MESSAGE"] = "Для сохранения требуется перезагрузка пользовательского интерфейса. Продолжить?";
L["EDITOR_SCENESCRIPT_WINDOW_TITLE"] = "Импорт Scenescript";
L["EDITOR_TOOLBAR_TT_OPEN_PROJECT_MANAGER"] = "Открыть Менеджер проектов";
L["EDITOR_TOOLBAR_TT_PROJECT_LIST"] = "Сменить проект";
L["EDITOR_TOOLBAR_TT_SELECT_TOOL"] = "Инструмент Выбора";
L["EDITOR_TOOLBAR_TT_MOVE_TOOL"] = "Инструмент Перемещения";
L["EDITOR_TOOLBAR_TT_ROTATE_TOOL"] = "Инструмент Вращения";
L["EDITOR_TOOLBAR_TT_SCALE_TOOL"] = "Инструмент Масштабирования";
L["EDITOR_TOOLBAR_TT_PIVOT_LOCAL_SPACE"] = "Ось относительно собственной системы координат";
L["EDITOR_TOOLBAR_TT_PIVOT_WORLD_SPACE"] = "Ось относительно глобальной системы координат";
L["EDITOR_TOOLBAR_TT_PIVOT_CENTER"] = "Ось в центре модели";
L["EDITOR_TOOLBAR_TT_PIVOT_BASE"] = "Ось в базе модели";
L["EDITOR_IMPORT_EXPORT_WINDOW_TITLE"] = "Импорт - Экспорт";
L["EDITOR_NAME_RENAME_WINDOW_TITLE"] = "Имя - Переименовать";
L["EDITOR_TOOLBAR_TT_MULTITRANSFORM_TOGETHER"] = "Трансформация вместе";
L["EDITOR_TOOLBAR_TT_MULTITRANSFORM_INDIVIDUAL"] = "Индивидуальная трансформация";
L["EDITOR_TOOLBAR_TT_UNDO"] = "Отменить";
L["EDITOR_TOOLBAR_TT_REDO"] = "Повторить";
L["EDITOR_TOOLBAR_TT_CREATE_CAMERA"] = "Создать камеру";
L["EDITOR_TOOLBAR_TT_CREATE_CHARACTER"] = "Создать персонажа";
L["EDITOR_FULLSCREEN_NOTIFICATION"] = "Вошли в полноэкранный режим\nНажмите ESC для выхода\nНажмите P для воспроизведения/паузы";
L["EDITOR_TOOLBAR_TT_LETTERBOX_ON"] = "Скрыть черные полосы (леттербокс)";
L["EDITOR_TOOLBAR_TT_LETTERBOX_OFF"] = "Показать черные полосы (леттербокс)";
L["EDITOR_TOOLBAR_TT_FULLSCREEN"] = "Перейти в полноэкранный режим";

-- Main Menu --
L["MM_FILE"] = "Файл";
L["MM_EDIT"] = "Правка";
L["MM_OPTIONS"] = "Опции";
L["MM_HELP"] = "Справка";
L["MM_PROJECT_MANAGER"] = "Менеджер проектов";
L["MM_IMPORT_SCENESCRIPT"] = "Импорт скрипта сцены";
L["MM_SAVE"] = "Сохранить";
L["MM_CLONE_SELECTED"] = "Клонировать выбранный";
L["MM_DELETE_SELECTED"] = "Удалить выбранный";
L["MM_SET_SCALE"] = "Установить масштаб %s";
L["MM_KEYBOARD_SHORTCUTS"] = "Горячие клавиши";
L["MM_ABOUT"] = "О приложении";
L["MM_SCENE"] = "Сцена";
L["MM_SCENE_NEW"] = "Новая";
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
L["CM_FREEZE_UNFREEZE"] = "Заморозить/Разморозить";
L["CM_FREEZE"] = "Заморозить";
L["CM_UNFREEZE"] = "Разморозить";
L["CM_RENAME"] = "Переименовать";
L["CM_FOCUS"] = "Фокус";
L["CM_GROUP"] = "Группа";

-- Animation Manager --
L["AM_ANIMATION_LIST_WINDOW_TITLE"] = "Список Анимаций";
L["AM_TIMELINE"] = "Лента времени %d";           -- номер ленты времени
L["AM_MSG_DELETE_TIMELINE_TITLE"] = "Удалить Ленту Времени";
L["AM_MSG_DELETE_TIMELINE_MESSAGE"] = "Вы уверены, что хотите продолжить?";
L["AM_MSG_NO_TRACK_TITLE"] = "Отсутствует Дорожка";
L["AM_MSG_NO_TRACK_MESSAGE"] = "Объект не имеет анимационной дорожки, хотите добавить?";
L["AM_BUTTON_ADD_ANIMATION"] = "Добавить Анимацию";
L["AM_BUTTON_CHANGE_ANIMATION"] = "Изменить Анимацию";
L["AM_TIMELINE_NAME"] = "Название Ленты Времени";
L["AM_TOOLBAR_TRACKS"] = "Дорожки";
L["AM_TOOLBAR_KEYFRAMES"] = "Ключевые кадры";
L["AM_TOOLBAR_CURVES"] = "Кривые (только отладка)";
L["AM_TOOLBAR_TT_UIMODE"] = "Переключить Режим Анимации";
L["AM_TOOLBAR_TTD_UIMODE"] = "Переключить Режим Анимации:\n";
L["AM_TOOLBAR_TT_ADD_TRACK"] = "Добавить Дорожку";
L["AM_TOOLBAR_TTD_ADD_TRACK"] = "Добавить Дорожку:\n";
L["AM_TOOLBAR_TT_REMOVE_TRACK"] = "Удалить Дорожку";
L["AM_TOOLBAR_TT_ADD_ANIMATION"] = "Добавить Анимацию";
L["AM_TOOLBAR_TTD_ADD_ANIMATION"] = "Добавить Анимацию:\n";
L["AM_TOOLBAR_TT_REMOVE_ANIMATION"] = "Удалить Анимацию";
L["AM_TOOLBAR_TT_ADD_KEYFRAME"] = "Добавить Ключевой Кадр";
L["AM_TOOLBAR_TTD_ADD_KEYFRAME"] = "Добавить Ключевой Кадр:\n";
L["AM_TOOLBAR_TT_SET_INTERPOLATION_IN"] = "Установить Интерполяцию Вход";
L["AM_TOOLBAR_TTD_SET_INTERPOLATION_IN"] = "Установить Интерполяцию Вход:\n";
L["AM_TOOLBAR_TT_SET_INTERPOLATION_OUT"] = "Установить Интерполяцию Выход";
L["AM_TOOLBAR_TTD_SET_INTERPOLATION_OUT"] = "Установить Интерполяцию Выход:\n";
L["AM_TOOLBAR_TT_REMOVE_KEYFRAME"] = "Удалить Ключевой Кадр";
L["AM_TOOLBAR_TT_SEEK_TO_START"] = "Перейти к началу";
L["AM_TOOLBAR_TT_SKIP_FRAME_BACK"] = "Перейти к предыдущему кадру";
L["AM_TOOLBAR_TT_PLAY_PAUSE"] = "Воспроизвести / Пауза";
L["AM_TOOLBAR_TT_SKIP_FRAME_FORWARD"] = "Перейти к следующему кадру";
L["AM_TOOLBAR_TT_SEEK_TO_END"] = "Перейти к концу";
L["AM_TOOLBAR_TT_LOOP"] = "Петля Воспроизведения вкл/выкл";
L["AM_TOOLBAR_TT_PLAYCAMERA"] = "Воспроизведение Камеры вкл/выкл";
L["AM_TT_LIST"] = "Выбрать Ленту Времени";
L["AM_TT_ADDTIMELINE"] = "Добавить Ленту Времени";
L["AM_RMB_CHANGE_ANIM"] = "Изменить Анимацию";
L["AM_RMB_SET_ANIM_SPEED"] = "Установить Скорость Анимации";
L["AM_RMB_DELETE_ANIM"] = "Удалить Анимацию";
L["AM_RMB_DIFFERENT_COLOR"] = "Другой Цвет";
L["AM_SET_ANIMATION_SPEED_PERCENT"] = "Установить Скорость Анимации %";
L["AM_TIMER_SET_DURATION"] = "Установить Длительность Ленты Времени";

-- AssetBrowser/AssetExplorer --
L["AB_RESULTS"] = "%d результатов"; -- <число> результатов (результаты поиска)
L["AB_BREADCRUMB"] = "..."; -- для пути к файлу
L["AB_TOOLBAR_TT_UP_ONE_FOLDER"] = "На одну папку вверх.";
L["AM_MSG_REMOVE_COLLECTION_TITLE"] = "Удалить коллекцию";
L["AB_MSG_REMOVE_COLLECTION_MESSAGE"] = "В коллекции содержатся элементы. Вы уверены, что хотите её удалить?";
L["AB_TOOLBAR_TT_NEW_COLLECTION"] = "Новая коллекция";
L["AB_TOOLBAR_TT_REMOVE_COLLECTION"] = "Удалить коллекцию";
L["AB_TOOLBAR_TT_RENAME_COLLECTION"] = "Переименовать коллекцию";
L["AB_TOOLBAR_TT_ADD_OBJECT"] = "Добавить выбранный объект";
L["AB_TOOLBAR_TT_REMOVE_OBJECT"] = "Удалить объект";
L["AB_TOOLBAR_TT_IMPORT_COLLECTION"] = "Импорт коллекции";
L["AB_TOOLBAR_TT_EXPORT_COLLECTION"] = "Экспорт коллекции";
L["AB_RMB_FILE_INFO"] = "Информация о файле";
L["AB_RMB_ADD_TO_COLLECTION"] = "Добавить в коллекцию";
L["AB_COLLECTION_NAME"] = "Имя коллекции";
L["AB_COLLECTION_RENAME"] = "Переименовать коллекцию";
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
L["PM_MSG_DELETE_PROJECT_MESSAGE"] = "Удаление проекта также приведет к удалению всех его сцен и данных, продолжить?";
L["PM_BUTTON_NEW_PROJECT"] = "Новый проект";
L["PM_BUTTON_LOAD_PROJECT"] = "Загрузить проект";
L["PM_BUTTON_EDIT_PROJECT"] = "Редактировать проект";
L["PM_BUTTON_REMOVE_PROJECT"] = "Удалить проект";
L["PM_BUTTON_SAVE_DATA"] = "Сохранить данные";

-- Scene Manager --
L["SM_SCENE"] = "Сцена %d";                 -- номер сцены
L["SM_MSG_DELETE_SCENE_TITLE"] = "Удалить сцену";
L["SM_MSG_DELETE_SCENE_MESSAGE"] = "Вы уверены, что хотите продолжить?";
L["SM_SCENE_NAME"] = "Название сцены";
L["SM_TT_LIST"] = "Выберите сцену";
L["SM_TT_ADDSCENE"] = "Добавить сцену";
L["SM_EXIT_CAMERA"] = "Выйти из камеры";

-- Object Properties --
L["OP_TITLE"] = "Свойства";
L["OP_TRANSFORM"] = "Трансформация";
L["OP_ACTOR_PROPERTIES"] = "Свойства объекта";
L["OP_SCENE_PROPERTIES"] = "Свойства сцены";
L["OP_AMBIENT_COLOR"] = "Фоновый цвет";
L["OP_DIFFUSE_COLOR"] = "Диффузный цвет";
L["OP_BACKGROUND_COLOR"] = "Цвет фона";
L["OP_TT_RESET_VALUE"] = "Сбросить значение на умолчание";
L["OP_TT_X_FIELD"] = "X";
L["OP_TT_Y_FIELD"] = "Y";
L["OP_TT_Z_FIELD"] = "Z";
L["OP_ENABLE_LIGHTING"] = "Включить освещение";
L["OP_CAMERA_PROPERTIES"] = "Свойства камеры";
L["FOV"] = "Угол обзора";
L["NEARCLIP"] = "Ближнее обрезание";
L["FARCLIP"] = "Дальнее обрезание";

-- Scene Hierarchy --
L["SH_TITLE"] = "Иерархия сцены";

-- Color Picker --
L["COLP_WINDOW_TITLE"] = "Выбор Цвета";
L["COLP_RGB_NAME"] = "RGB (Красный/Зеленый/Синий):";
L["COLP_HSL_NAME"] = "HSL (Тон/Насыщенность/Яркость):";
L["COLP_R"] = "К";  -- Красный
L["COLP_G"] = "З";  -- Зеленый
L["COLP_B"] = "С";  -- Синий
L["COLP_H"] = "Т";  -- Тон
L["COLP_S"] = "Н";  -- Насыщенность
L["COLP_L"] = "Я";  -- Яркость

-- About Screen --
L["ABOUT_WINDOW_TITLE"] = "Сценарная машина";
L["ABOUT_VERSION"] = "Версия %s";
L["ABOUT_DESCRIPTION"] = "Сценарная машина - это инструмент для создания и редактирования 3D сцен с использованием доступных в игре моделей. Она использует базовый API ModelScene, поэтому существуют некоторые ограничения.";
L["ABOUT_LICENSE"] = "Лицензировано по лицензии MIT";
L["ABOUT_AUTHOR"] = "Автор: %s";
L["ABOUT_CONTACT"] = "Контакт: %s";

-- Settings window --
L["SETTINGS_WINDOW_TITLE"] = "Настройки";
L["SETTINGS_TAB_GENERAL"] = "Общие";
L["SETTINGS_TAB_GIZMOS"] = "Манипуляторы";
L["SETTINGS_TAB_DEBUG"] = "Отладка";
L["SETTINGS_EDITOR_SCALE"] = "Масштаб редактора";
L["SETTINGS_SHOW_SELECTION_HIGHLIGHT"] = "Показывать выделение";
L["SETTINGS_HIDE_PARALLEL_GIZMOS"] = "Скрыть манипуляторы параллельно камере";
L["SETTINGS_ALWAYS_SHOW_CAM_GIZMO"] = "Всегда показывать манипуляторы камеры";
L["SETTINGS_GIZMO_SIZE"] = "Размер манипулятора";
L["SETTINGS_SHOW_DEBUG_TAB"] = "Показать вкладку отладки в обозревателе ресурсов";

-- Error Messages --
L["DECODE_FAILED"] = "Ошибка при декодировании данных.";
L["DECOMPRESS_FAILED"] = "Ошибка при распаковке данных.";
L["DESERIALIZE_FAILED"] = "Ошибка при десериализации данных.";
L["DATA_VERSION_TOO_NEW"] = "Обнаружена более новая версия данных, которая не поддерживается. Пожалуйста, обновите SceneMachine.";

