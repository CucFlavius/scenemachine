local AceLocale = LibStub("AceLocale-3.0");
local L = AceLocale:NewLocale("SceneMachine", "esMX", false);
if not L then return end

-- General --
L["YES"] = "Sí";
L["NO"] = "No";
L["POSITION"] = "Posición";
L["ROTATION"] = "Rotación";
L["SCALE"] = "Escala";
L["ALPHA"] = "Alfa";   -- Transparencia
L["DESATURATION"] = "Desaturación";
L["SEARCH"] = "Buscar";
L["RENAME"] = "Renombrar";
L["EDIT"] = "Editar";
L["DELETE"] = "Eliminar";
L["BUTTON_SAVE"] = "Guardar";
L["BUTTON_CANCEL"] = "Cancelar";
L["EXPORT"] = "Exportar";
L["IMPORT"] = "Importar";
L["SCROLL_TOP"] = "Ir Arriba";
L["SCROLL_BOTTOM"] = "Ir Abajo";
L["LOAD"] = "Cargar";

-- Editor --
L["ADDON_NAME"] = "Scene Machine";
L["EDITOR_MAIN_WINDOW_TITLE"] = "Scene Machine %s - %s";       -- Scene Machine <version> - <current project name>
L["EDITOR_MSG_DELETE_OBJECT_TITLE"] = "Eliminar Objeto";
L["EDITOR_MSG_DELETE_OBJECT_MESSAGE"] = "El objeto contiene una pista de animación, ¿estás seguro de que quieres eliminarlo?";
L["EDITOR_MSG_DELETE_TRACK_TITLE"] = "Eliminar Pista";
L["EDITOR_MSG_DELETE_TRACK_A_K_MESSAGE"] = "La pista contiene animaciones y fotogramas clave, ¿estás seguro de que quieres eliminarla?";
L["EDITOR_MSG_DELETE_TRACK_A_MESSAGE"] = "La pista contiene animaciones, ¿estás seguro de que quieres eliminarla?";
L["EDITOR_MSG_DELETE_TRACK_K_MESSAGE"] = "La pista contiene fotogramas clave, ¿estás seguro de que quieres eliminarla?";
L["EDITOR_MSG_SAVE_TITLE"] = "Guardar";
L["EDITOR_MSG_SAVE_MESSAGE"] = "Guardar requiere recargar la interfaz de usuario, ¿quieres continuar?";
L["EDITOR_SCENESCRIPT_WINDOW_TITLE"] = "Importar Scenescript";
L["EDITOR_TOOLBAR_TT_OPEN_PROJECT_MANAGER"] = "Abrir Administrador de Proyectos";
L["EDITOR_TOOLBAR_TT_PROJECT_LIST"] = "Cambiar proyecto";
L["EDITOR_TOOLBAR_TT_SELECT_TOOL"] = "Herramienta de Selección";
L["EDITOR_TOOLBAR_TT_MOVE_TOOL"] = "Herramienta de Movimiento";
L["EDITOR_TOOLBAR_TT_ROTATE_TOOL"] = "Herramienta de Rotación";
L["EDITOR_TOOLBAR_TT_SCALE_TOOL"] = "Herramienta de Escala";
L["EDITOR_TOOLBAR_TT_PIVOT_LOCAL_SPACE"] = "Pivote en Espacio Local";
L["EDITOR_TOOLBAR_TT_PIVOT_WORLD_SPACE"] = "Pivote en Espacio Mundial";
L["EDITOR_TOOLBAR_TT_PIVOT_CENTER"] = "Pivote en Centro";
L["EDITOR_TOOLBAR_TT_PIVOT_BASE"] = "Pivote en Base";
L["EDITOR_IMPORT_EXPORT_WINDOW_TITLE"] = "Importar - Exportar";
L["EDITOR_NAME_RENAME_WINDOW_TITLE"] = "Nombre - Renombrar";
L["EDITOR_TOOLBAR_TT_MULTITRANSFORM_TOGETHER"] = "Transformar Juntos";
L["EDITOR_TOOLBAR_TT_MULTITRANSFORM_INDIVIDUAL"] = "Transformar Individual";
L["EDITOR_TOOLBAR_TT_UNDO"] = "Deshacer";
L["EDITOR_TOOLBAR_TT_REDO"] = "Rehacer";
L["EDITOR_TOOLBAR_TT_CREATE_CAMERA"] = "Crear Cámara";
L["EDITOR_TOOLBAR_TT_CREATE_CHARACTER"] = "Crear Personaje";
L["EDITOR_FULLSCREEN_NOTIFICATION"] = "Entraste en Pantalla Completa\nPresiona ESC para salir\nPresiona P para reproducir/pausar";
L["EDITOR_TOOLBAR_TT_LETTERBOX_ON"] = "Ocultar Banda Negra";
L["EDITOR_TOOLBAR_TT_LETTERBOX_OFF"] = "Mostrar Banda Negra";
L["EDITOR_TOOLBAR_TT_FULLSCREEN"] = "Entrar en Pantalla Completa";

-- Main Menu --
L["MM_FILE"] = "Archivo";
L["MM_EDIT"] = "Editar";
L["MM_OPTIONS"] = "Opciones";
L["MM_HELP"] = "Ayuda";
L["MM_PROJECT_MANAGER"] = "Gestor de Proyectos";
L["MM_IMPORT_SCENESCRIPT"] = "Importar Scenescript";
L["MM_SAVE"] = "Guardar";
L["MM_CLONE_SELECTED"] = "Clonar Seleccionado";
L["MM_DELETE_SELECTED"] = "Eliminar Seleccionado";
L["MM_SET_SCALE"] = "Establecer Escala %s";
L["MM_KEYBOARD_SHORTCUTS"] = "Atajos de Teclado";
L["MM_ABOUT"] = "Acerca de";
L["MM_SCENE"] = "Escena";
L["MM_SCENE_NEW"] = "Nueva";
L["MM_SCENE_REMOVE"] = "Eliminar";
L["MM_SCENE_RENAME"] = "Renombrar";
L["MM_SCENE_EXPORT"] = "Exportar";
L["MM_SCENE_IMPORT"] = "Importar";
L["MM_TITLE_SCENE_NAME"] = "Nombre de la Escena";
L["MM_TITLE_SCENE_RENAME"] = "Renombrar Escena";
L["MM_SETTINGS"] = "Configuración";

-- Context Menu --
L["CM_SELECT"] = "Seleccionar";
L["CM_MOVE"] = "Mover";
L["CM_ROTATE"] = "Rotar";
L["CM_SCALE"] = "Escalar";
L["CM_DELETE"] = "Eliminar";
L["CM_HIDE_SHOW"] = "Ocultar/Mostrar";
L["CM_HIDE"] = "Ocultar";
L["CM_SHOW"] = "Mostrar";
L["CM_FREEZE_UNFREEZE"] = "Congelar/Descongelar";
L["CM_FREEZE"] = "Congelar";
L["CM_UNFREEZE"] = "Descongelar";
L["CM_RENAME"] = "Renombrar";
L["CM_FOCUS"] = "Enfocar";
L["CM_GROUP"] = "Agrupar";

-- Animation Manager --
L["AM_ANIMATION_LIST_WINDOW_TITLE"] = "Lista de Animaciones";
L["AM_TIMELINE"] = "Línea de tiempo %d";           -- número de línea de tiempo
L["AM_MSG_DELETE_TIMELINE_TITLE"] = "Eliminar Línea de Tiempo";
L["AM_MSG_DELETE_TIMELINE_MESSAGE"] = "¿Estás seguro de que deseas continuar?";
L["AM_MSG_NO_TRACK_TITLE"] = "Sin Pista";
L["AM_MSG_NO_TRACK_MESSAGE"] = "El objeto no tiene una pista de animación, ¿deseas agregar una?";
L["AM_BUTTON_ADD_ANIMATION"] = "Agregar Animación";
L["AM_BUTTON_CHANGE_ANIMATION"] = "Cambiar Animación";
L["AM_TIMELINE_NAME"] = "Nombre de la Línea de Tiempo";
L["AM_TOOLBAR_TRACKS"] = "Pistas";
L["AM_TOOLBAR_KEYFRAMES"] = "Fotogramas Clave";
L["AM_TOOLBAR_CURVES"] = "Curvas (solo para depuración)";
L["AM_TOOLBAR_TT_UIMODE"] = "Cambiar Modo de Animación";
L["AM_TOOLBAR_TTD_UIMODE"] = "Cambiar Modo de Animación:\n 1. Vista de Pistas: Administra diferentes pistas de objetos, agrega animaciones de modelos y fotogramas clave.\n 2. Vista de Fotogramas Clave: Control avanzado sobre los fotogramas clave.\n 3. Vista de Curvas: (Aún no implementada, actualmente solo se usa para depuración).\n";
L["AM_TOOLBAR_TT_ADD_TRACK"] = "Agregar Pista";
L["AM_TOOLBAR_TTD_ADD_TRACK"] = "Agregar Pista:\n - Crea una nueva pista de animación y asígnala al objeto de escena seleccionado.\n - Un objeto en la escena necesita una pista para realizar cualquier animación en él.\n - Cualquier objeto solo puede tener asignada una pista.";
L["AM_TOOLBAR_TT_REMOVE_TRACK"] = "Eliminar Pista";
L["AM_TOOLBAR_TT_ADD_ANIMATION"] = "Agregar Animación";
L["AM_TOOLBAR_TTD_ADD_ANIMATION"] = "Agregar Animación:\n - Agrega un clip de animación a la pista/objeto seleccionado actualmente.\n - Abre la ventana de Lista de Animaciones donde puedes seleccionar un clip disponible.";
L["AM_TOOLBAR_TT_REMOVE_ANIMATION"] = "Eliminar Animación";
L["AM_TOOLBAR_TT_ADD_KEYFRAME"] = "Agregar Fotograma Clave";
L["AM_TOOLBAR_TTD_ADD_KEYFRAME"] = "Agregar Fotograma Clave:\n - Agrega un fotograma clave en el tiempo actual.\n - Mantén presionado para alternar entre:\n    1. Agregar fotograma clave a todas las transformaciones;\n    2. Agregar fotograma clave solo de posición;\n    3. Agregar fotograma clave solo de rotación;\n    4. Agregar fotograma clave solo de escala;";
L["AM_TOOLBAR_TT_SET_INTERPOLATION_IN"] = "Establecer Interpolación de Entrada";
L["AM_TOOLBAR_TTD_SET_INTERPOLATION_IN"] = "Establecer Interpolación de Entrada:\n - Establecer el modo de interpolación de entrada del fotograma clave actual (lado izquierdo).\n - Mantén presionado para alternar entre:\n    1. Suave\n    2. Lineal\n    3. Escalonado\n    4. Lento\n    5. Rápido\n";
L["AM_TOOLBAR_TT_SET_INTERPOLATION_OUT"] = "Establecer Interpolación de Salida";
L["AM_TOOLBAR_TTD_SET_INTERPOLATION_OUT"] = "Establecer Interpolación de Salida:\n - Establecer el modo de interpolación de salida del fotograma clave actual (lado derecho).\n - Mantén presionado para alternar entre:\n    1. Suave\n    2. Lineal\n    3. Escalonado\n    4. Lento\n    5. Rápido\n";
L["AM_TOOLBAR_TT_REMOVE_KEYFRAME"] = "Eliminar Fotograma Clave";
L["AM_TOOLBAR_TT_SEEK_TO_START"] = "Ir al Inicio";
L["AM_TOOLBAR_TT_SKIP_FRAME_BACK"] = "Saltar al fotograma anterior";
L["AM_TOOLBAR_TT_PLAY_PAUSE"] = "Reproducir / Pausar";
L["AM_TOOLBAR_TT_SKIP_FRAME_FORWARD"] = "Saltar al siguiente fotograma";
L["AM_TOOLBAR_TT_SEEK_TO_END"] = "Ir al Final";
L["AM_TOOLBAR_TT_LOOP"] = "Repetir Reproducción activado/desactivado";
L["AM_TOOLBAR_TT_PLAYCAMERA"] = "Reproducir Cámara activado/desactivado";
L["AM_TT_LIST"] = "Seleccionar Línea de Tiempo";
L["AM_TT_ADDTIMELINE"] = "Agregar Línea de Tiempo";
L["AM_RMB_CHANGE_ANIM"] = "Cambiar Animación";
L["AM_RMB_SET_ANIM_SPEED"] = "Establecer Velocidad de la Animación";
L["AM_RMB_DELETE_ANIM"] = "Eliminar Animación";
L["AM_RMB_DIFFERENT_COLOR"] = "Color Diferente";
L["AM_SET_ANIMATION_SPEED_PERCENT"] = "Establecer Velocidad de Animación %";
L["AM_TIMER_SET_DURATION"] = "Establecer Duración de la Línea de Tiempo";

-- AssetBrowser/AssetExplorer --
L["AB_RESULTS"] = "%d Resultados";             -- <número> resultados (resultados de búsqueda)
L["AB_BREADCRUMB"] = "...";             -- para una ruta de archivo
L["AB_TOOLBAR_TT_UP_ONE_FOLDER"] = "Ir a la carpeta anterior.";
L["AM_MSG_REMOVE_COLLECTION_TITLE"] = "Eliminar Colección";
L["AB_MSG_REMOVE_COLLECTION_MESSAGE"] = "La colección contiene elementos, ¿Estás seguro/a de que quieres eliminarla?";
L["AB_TOOLBAR_TT_NEW_COLLECTION"] = "Nueva Colección";
L["AB_TOOLBAR_TT_REMOVE_COLLECTION"] = "Eliminar Colección";
L["AB_TOOLBAR_TT_RENAME_COLLECTION"] = "Renombrar Colección";
L["AB_TOOLBAR_TT_ADD_OBJECT"] = "Añadir Objeto Seleccionado";
L["AB_TOOLBAR_TT_REMOVE_OBJECT"] = "Eliminar Objeto";
L["AB_TOOLBAR_TT_IMPORT_COLLECTION"] = "Importar Colección";
L["AB_TOOLBAR_TT_EXPORT_COLLECTION"] = "Exportar Colección";
L["AB_RMB_FILE_INFO"] = "Información del Archivo";
L["AB_RMB_ADD_TO_COLLECTION"] = "Añadir a la Colección";
L["AB_COLLECTION_NAME"] = "Nombre de la Colección";
L["AB_COLLECTION_RENAME"] = "Renombrar Colección";
L["AB_TAB_MODELS"] = "Modelos";
L["AB_TAB_CREATURES"] = "Crias";
L["AB_TAB_COLLECTIONS"] = "Colecciones";
L["AB_TAB_DEBUG"] = "Depuración";

-- Project Manager --
L["PM_WINDOW_TITLE"] = "Administrador de Proyectos";
L["PM_PROJECT_NAME"] = "Nombre del Proyecto";
L["PM_NEW_PROJECT"] = "Nuevo Proyecto";
L["PM_EDIT_PROJECT"] = "Editar Proyecto";
L["PM_MSG_DELETE_PROJECT_TITLE"] = "Eliminar Proyecto";
L["PM_MSG_DELETE_PROJECT_MESSAGE"] = "Al eliminar el proyecto también se eliminarán todas sus escenas y datos, ¿desea continuar?";
L["PM_BUTTON_NEW_PROJECT"] = "Nuevo Proyecto";
L["PM_BUTTON_LOAD_PROJECT"] = "Cargar Proyecto";
L["PM_BUTTON_EDIT_PROJECT"] = "Editar Proyecto";
L["PM_BUTTON_REMOVE_PROJECT"] = "Eliminar Proyecto";
L["PM_BUTTON_SAVE_DATA"] = "Guardar Datos";

-- Scene Manager --
L["SM_SCENE"] = "Escena %d";                 -- número de escena
L["SM_MSG_DELETE_SCENE_TITLE"] = "Eliminar Escena";
L["SM_MSG_DELETE_SCENE_MESSAGE"] = "¿Estás seguro de que deseas continuar?";
L["SM_SCENE_NAME"] = "Nombre de la Escena";
L["SM_TT_LIST"] = "Seleccionar escena";
L["SM_TT_ADDSCENE"] = "Agregar Escena";
L["SM_EXIT_CAMERA"] = "Salir de la cámara";

-- Object Properties --
L["OP_TITLE"] = "Propiedades";
L["OP_TRANSFORM"] = "Transformar";
L["OP_ACTOR_PROPERTIES"] = "Propiedades del Actor";
L["OP_SCENE_PROPERTIES"] = "Propiedades de la Escena";
L["OP_AMBIENT_COLOR"] = "Color Ambiente";
L["OP_DIFFUSE_COLOR"] = "Color Difuso";
L["OP_BACKGROUND_COLOR"] = "Color de Fondo";
L["OP_TT_RESET_VALUE"] = "Restablecer valor por defecto";
L["OP_TT_X_FIELD"] = "X";
L["OP_TT_Y_FIELD"] = "Y";
L["OP_TT_Z_FIELD"] = "Z";
L["OP_ENABLE_LIGHTING"] = "Activar Iluminación";
L["OP_CAMERA_PROPERTIES"] = "Propiedades de la Cámara";
L["FOV"] = "Campo de Visión";
L["NEARCLIP"] = "Near Clip";
L["FARCLIP"] = "Far Clip";

-- Scene Hierarchy --
L["SH_TITLE"] = "Jerarquía de Escena";

-- Color Picker --
L["COLP_WINDOW_TITLE"] = "Selector de color";
L["COLP_RGB_NAME"] = "RGB (Rojo/Verde/Azul):";
L["COLP_HSL_NAME"] = "HSL (Matiz/Saturación/Luminosidad):";
L["COLP_R"] = "R";  -- Rojo (Red)
L["COLP_G"] = "V";  -- Verde (Green)
L["COLP_B"] = "A";  -- Azul (Blue)
L["COLP_H"] = "H";  -- Matiz (Hue)
L["COLP_S"] = "S";  -- Saturación (Saturation)
L["COLP_L"] = "L";  -- Luminosidad (Lightness)

-- About Screen --
L["ABOUT_WINDOW_TITLE"] = "Máquina de Escenas";
L["ABOUT_VERSION"] = "Versión %s";
L["ABOUT_DESCRIPTION"] = "Máquina de Escenas es una herramienta para crear y editar escenas en 3D utilizando los modelos disponibles en el juego. Utiliza la API ModelScene como base, por lo que se aplican algunas limitaciones.";
L["ABOUT_LICENSE"] = "Licenciado bajo la Licencia MIT";
L["ABOUT_AUTHOR"] = "Autor: %s";
L["ABOUT_CONTACT"] = "Contacto: %s";

-- Settings window --
L["SETTINGS_WINDOW_TITLE"] = "Configuración";
L["SETTINGS_TAB_GENERAL"] = "General";
L["SETTINGS_TAB_GIZMOS"] = "Gizmos";
L["SETTINGS_TAB_DEBUG"] = "Depuración";
L["SETTINGS_EDITOR_SCALE"] = "Escala del Editor";
L["SETTINGS_SHOW_SELECTION_HIGHLIGHT"] = "Mostrar resaltado de selección";
L["SETTINGS_HIDE_PARALLEL_GIZMOS"] = "Ocultar gizmos de traducción paralelos a la cámara";
L["SETTINGS_ALWAYS_SHOW_CAM_GIZMO"] = "Mostrar siempre gizmo de cámara";
L["SETTINGS_GIZMO_SIZE"] = "Tamaño del gizmo";
L["SETTINGS_SHOW_DEBUG_TAB"] = "Mostrar pestaña de depuración en el Explorador de recursos";

-- Error Messages --
L["DECODE_FAILED"] = "Error al decodificar los datos.";
L["DECOMPRESS_FAILED"] = "Error al descomprimir los datos.";
L["DESERIALIZE_FAILED"] = "Error al deserializar los datos.";
L["DATA_VERSION_TOO_NEW"] = "Se ha detectado una versión más reciente de los datos, la cual no es compatible. Por favor, actualiza SceneMachine.";

