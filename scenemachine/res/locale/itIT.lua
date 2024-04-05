local AceLocale = LibStub("AceLocale-3.0");
local L = AceLocale:NewLocale("SceneMachine", "itIT", false);
if not L then return end

-- General --
L["YES"] = "Sì";
L["NO"] = "No";
L["POSITION"] = "Posizione";
L["ROTATION"] = "Rotazione";
L["SCALE"] = "Scala";
L["ALPHA"] = "Alfa";   -- Trasparenza
L["DESATURATION"] = "Desaturazione";
L["SEARCH"] = "Cerca";
L["RENAME"] = "Rinomina";
L["EDIT"] = "Modifica";
L["DELETE"] = "Elimina";
L["BUTTON_SAVE"] = "Salva";
L["BUTTON_CANCEL"] = "Annulla";
L["EXPORT"] = "Esporta";
L["IMPORT"] = "Importa";
L["SCROLL_TOP"] = "Vai in Alto";
L["SCROLL_BOTTOM"] = "Vai in Basso";
L["LOAD"] = "Carica";

-- Editor --
L["ADDON_NAME"] = "Scene Machine";
L["EDITOR_MAIN_WINDOW_TITLE"] = "Scene Machine %s - %s";       -- Scene Machine <version> - <current project name>
L["EDITOR_MSG_DELETE_OBJECT_TITLE"] = "Elimina Oggetto";
L["EDITOR_MSG_DELETE_OBJECT_MESSAGE"] = "L'oggetto contiene una traccia di animazione, sei sicuro di voler eliminare?";
L["EDITOR_MSG_DELETE_TRACK_TITLE"] = "Elimina Traccia";
L["EDITOR_MSG_DELETE_TRACK_A_K_MESSAGE"] = "La traccia contiene animazioni e fotogrammi chiave, sei sicuro di voler eliminare?";
L["EDITOR_MSG_DELETE_TRACK_A_MESSAGE"] = "La traccia contiene animazioni, sei sicuro di voler eliminare?";
L["EDITOR_MSG_DELETE_TRACK_K_MESSAGE"] = "La traccia contiene fotogrammi chiave, sei sicuro di voler eliminare?";
L["EDITOR_MSG_SAVE_TITLE"] = "Salva";
L["EDITOR_MSG_SAVE_MESSAGE"] = "Il salvataggio richiede un ricaricamento dell'interfaccia utente, continuare?";
L["EDITOR_SCENESCRIPT_WINDOW_TITLE"] = "Importa SceneScript";
L["EDITOR_TOOLBAR_TT_OPEN_PROJECT_MANAGER"] = "Apri Gestore Progetti";
L["EDITOR_TOOLBAR_TT_PROJECT_LIST"] = "Cambia progetto";
L["EDITOR_TOOLBAR_TT_SELECT_TOOL"] = "Strumento Selezione";
L["EDITOR_TOOLBAR_TT_MOVE_TOOL"] = "Strumento Spostamento";
L["EDITOR_TOOLBAR_TT_ROTATE_TOOL"] = "Strumento Rotazione";
L["EDITOR_TOOLBAR_TT_SCALE_TOOL"] = "Strumento Scala";
L["EDITOR_TOOLBAR_TT_PIVOT_LOCAL_SPACE"] = "Origine Locale";
L["EDITOR_TOOLBAR_TT_PIVOT_WORLD_SPACE"] = "Origine Globale";
L["EDITOR_TOOLBAR_TT_PIVOT_CENTER"] = "Origine al Centro";
L["EDITOR_TOOLBAR_TT_PIVOT_BASE"] = "Origine alla Base";
L["EDITOR_IMPORT_EXPORT_WINDOW_TITLE"] = "Importa - Esporta";
L["EDITOR_NAME_RENAME_WINDOW_TITLE"] = "Nome - Rinomina";
L["EDITOR_TOOLBAR_TT_MULTITRANSFORM_TOGETHER"] = "Trasforma Insieme";
L["EDITOR_TOOLBAR_TT_MULTITRANSFORM_INDIVIDUAL"] = "Trasforma Singolarmente";
L["EDITOR_TOOLBAR_TT_UNDO"] = "Annulla";
L["EDITOR_TOOLBAR_TT_REDO"] = "Ripeti";
L["EDITOR_TOOLBAR_TT_CREATE_CAMERA"] = "Crea Fotocamera";
L["EDITOR_TOOLBAR_TT_CREATE_CHARACTER"] = "Crea Personaggio";
L["EDITOR_FULLSCREEN_NOTIFICATION"] = "Entrato in Modalità Schermo Intero\nPremi ESC per uscire\nPremi P per riprodurre/in pausa";
L["EDITOR_TOOLBAR_TT_LETTERBOX_ON"] = "Nascondi Bordo Letterbox (fasce nere)";
L["EDITOR_TOOLBAR_TT_LETTERBOX_OFF"] = "Mostra Bordo Letterbox (fasce nere)";
L["EDITOR_TOOLBAR_TT_FULLSCREEN"] = "Entra in Modalità Schermo Intero";

-- Main Menu --
L["MM_FILE"] = "File";
L["MM_EDIT"] = "Modifica";
L["MM_OPTIONS"] = "Opzioni";
L["MM_HELP"] = "Guida";
L["MM_PROJECT_MANAGER"] = "Gestione Progetto";
L["MM_IMPORT_SCENESCRIPT"] = "Importa Script Scena";
L["MM_SAVE"] = "Salva";
L["MM_CLONE_SELECTED"] = "Clona Selezionato";
L["MM_DELETE_SELECTED"] = "Elimina Selezionato";
L["MM_SET_SCALE"] = "Imposta Scala %s";
L["MM_KEYBOARD_SHORTCUTS"] = "Scorciatoie Tastiera";
L["MM_ABOUT"] = "Informazioni";
L["MM_SCENE"] = "Scena";
L["MM_SCENE_NEW"] = "Nuovo";
L["MM_SCENE_REMOVE"] = "Rimuovi";
L["MM_SCENE_RENAME"] = "Rinomina";
L["MM_SCENE_EXPORT"] = "Esporta";
L["MM_SCENE_IMPORT"] = "Importa";
L["MM_TITLE_SCENE_NAME"] = "Nome Scena";
L["MM_TITLE_SCENE_RENAME"] = "Rinomina Scena";
L["MM_SETTINGS"] = "Impostazioni";

-- Context Menu --
L["CM_SELECT"] = "Seleziona";
L["CM_MOVE"] = "Sposta";
L["CM_ROTATE"] = "Ruota";
L["CM_SCALE"] = "Scala";
L["CM_DELETE"] = "Elimina";
L["CM_HIDE_SHOW"] = "Nascondi/Mostra";
L["CM_HIDE"] = "Nascondi";
L["CM_SHOW"] = "Mostra";
L["CM_FREEZE_UNFREEZE"] = "Congela/Scongela";
L["CM_FREEZE"] = "Congela";
L["CM_UNFREEZE"] = "Scongela";
L["CM_RENAME"] = "Rinomina";
L["CM_FOCUS"] = "Focus";
L["CM_GROUP"] = "Raggruppa";

-- Animation Manager --
L["AM_ANIMATION_LIST_WINDOW_TITLE"] = "Elenco Animazioni";
L["AM_TIMELINE"] = "Timeline %d";           -- numero timeline
L["AM_MSG_DELETE_TIMELINE_TITLE"] = "Elimina Timeline";
L["AM_MSG_DELETE_TIMELINE_MESSAGE"] = "Sei sicuro di voler continuare?";
L["AM_MSG_NO_TRACK_TITLE"] = "Nessuna Traccia";
L["AM_MSG_NO_TRACK_MESSAGE"] = "L'oggetto non ha una traccia di animazione, vuoi aggiungerne una?";
L["AM_BUTTON_ADD_ANIMATION"] = "Aggiungi Anim";
L["AM_BUTTON_CHANGE_ANIMATION"] = "Modifica Anim";
L["AM_TIMELINE_NAME"] = "Nome Timeline";
L["AM_TOOLBAR_TRACKS"] = "Tracce";
L["AM_TOOLBAR_KEYFRAMES"] = "Fotogrammi chiave";
L["AM_TOOLBAR_CURVES"] = "Curve (solo debug)";
L["AM_TOOLBAR_TT_UIMODE"] = "Cambia Modalità Animazione";
L["AM_TOOLBAR_TTD_UIMODE"] = "Cambia Modalità Animazione:\n";
L["AM_TOOLBAR_TT_ADD_TRACK"] = "Aggiungi Traccia";
L["AM_TOOLBAR_TTD_ADD_TRACK"] = "Aggiungi Traccia:\n";
L["AM_TOOLBAR_TT_REMOVE_TRACK"] = "Elimina Traccia";
L["AM_TOOLBAR_TT_ADD_ANIMATION"] = "Aggiungi Animazione";
L["AM_TOOLBAR_TTD_ADD_ANIMATION"] = "Aggiungi Animazione:\n";
L["AM_TOOLBAR_TT_REMOVE_ANIMATION"] = "Elimina Animazione";
L["AM_TOOLBAR_TT_ADD_KEYFRAME"] = "Aggiungi Fotogramma Chiave";
L["AM_TOOLBAR_TTD_ADD_KEYFRAME"] = "Aggiungi Fotogramma Chiave:\n";
L["AM_TOOLBAR_TT_SET_INTERPOLATION_IN"] = "Imposta Interpolazione In";
L["AM_TOOLBAR_TTD_SET_INTERPOLATION_IN"] = "Imposta Interpolazione In:\n";
L["AM_TOOLBAR_TT_SET_INTERPOLATION_OUT"] = "Imposta Interpolazione Fuori";
L["AM_TOOLBAR_TTD_SET_INTERPOLATION_OUT"] = "Imposta Interpolazione Fuori:\n";
L["AM_TOOLBAR_TT_REMOVE_KEYFRAME"] = "Elimina Fotogramma Chiave";
L["AM_TOOLBAR_TT_SEEK_TO_START"] = "Vai all'inizio";
L["AM_TOOLBAR_TT_SKIP_FRAME_BACK"] = "Salta al fotogramma precedente";
L["AM_TOOLBAR_TT_PLAY_PAUSE"] = "Play / Pausa";
L["AM_TOOLBAR_TT_SKIP_FRAME_FORWARD"] = "Salta al fotogramma successivo";
L["AM_TOOLBAR_TT_SEEK_TO_END"] = "Vai alla fine";
L["AM_TOOLBAR_TT_LOOP"] = "Riproduzione in loop on/off";
L["AM_TOOLBAR_TT_PLAYCAMERA"] = "Riproduzione fotocamera on/off";
L["AM_TT_LIST"] = "Seleziona Timeline";
L["AM_TT_ADDTIMELINE"] = "Aggiungi Timeline";
L["AM_RMB_CHANGE_ANIM"] = "Modifica Animazione";
L["AM_RMB_SET_ANIM_SPEED"] = "Imposta Velocità Animazione";
L["AM_RMB_DELETE_ANIM"] = "Elimina Animazione";
L["AM_RMB_DIFFERENT_COLOR"] = "Colore Diverso";
L["AM_SET_ANIMATION_SPEED_PERCENT"] = "Imposta Velocità Animazione %";
L["AM_TIMER_SET_DURATION"] = "Imposta Durata Timeline";

-- AssetBrowser/AssetExplorer --
L["AB_RESULTS"] = "%d Risultati";             -- <number> risultati (risultati della ricerca)
L["AB_BREADCRUMB"] = "...";             -- per un percorso del file
L["AB_TOOLBAR_TT_UP_ONE_FOLDER"] = "Torna alla cartella precedente.";
L["AM_MSG_REMOVE_COLLECTION_TITLE"] = "Rimuovi Collezione";
L["AB_MSG_REMOVE_COLLECTION_MESSAGE"] = "La collezione contiene elementi, sei sicuro di volerla rimuovere?";
L["AB_TOOLBAR_TT_NEW_COLLECTION"] = "Nuova Collezione";
L["AB_TOOLBAR_TT_REMOVE_COLLECTION"] = "Rimuovi Collezione";
L["AB_TOOLBAR_TT_RENAME_COLLECTION"] = "Rinomina Collezione";
L["AB_TOOLBAR_TT_ADD_OBJECT"] = "Aggiungi Oggetto Selezionato";
L["AB_TOOLBAR_TT_REMOVE_OBJECT"] = "Rimuovi Oggetto";
L["AB_TOOLBAR_TT_IMPORT_COLLECTION"] = "Importa Collezione";
L["AB_TOOLBAR_TT_EXPORT_COLLECTION"] = "Esporta Collezione";
L["AB_RMB_FILE_INFO"] = "Informazioni File";
L["AB_RMB_ADD_TO_COLLECTION"] = "Aggiungi alla Collezione";
L["AB_COLLECTION_NAME"] = "Nome Collezione";
L["AB_COLLECTION_RENAME"] = "Rinomina Collezione";
L["AB_TAB_MODELS"] = "Modelli";
L["AB_TAB_CREATURES"] = "Creature";
L["AB_TAB_COLLECTIONS"] = "Collezioni";
L["AB_TAB_DEBUG"] = "Debug";

-- Project Manager --
L["PM_WINDOW_TITLE"] = "Gestore Progetti";
L["PM_PROJECT_NAME"] = "Nome Progetto";
L["PM_NEW_PROJECT"] = "Nuovo Progetto";
L["PM_EDIT_PROJECT"] = "Modifica Progetto";
L["PM_MSG_DELETE_PROJECT_TITLE"] = "Elimina Progetto";
L["PM_MSG_DELETE_PROJECT_MESSAGE"] = "L'eliminazione del progetto comporterà anche l'eliminazione di tutte le sue scene e dati. Continuare?";
L["PM_BUTTON_NEW_PROJECT"] = "Nuovo Progetto";
L["PM_BUTTON_LOAD_PROJECT"] = "Carica Progetto";
L["PM_BUTTON_EDIT_PROJECT"] = "Modifica Progetto";
L["PM_BUTTON_REMOVE_PROJECT"] = "Rimuovi Progetto";
L["PM_BUTTON_SAVE_DATA"] = "Salva Dati";

-- Scene Manager --
L["SM_SCENE"] = "Scena %d";                  -- numero scena
L["SM_MSG_DELETE_SCENE_TITLE"] = "Elimina Scena";
L["SM_MSG_DELETE_SCENE_MESSAGE"] = "Sei sicuro di voler procedere?";
L["SM_SCENE_NAME"] = "Nome Scena";
L["SM_TT_LIST"] = "Seleziona scena";
L["SM_TT_ADDSCENE"] = "Aggiungi Scena";
L["SM_EXIT_CAMERA"] = "Uscita fotocamera";

-- Object Properties --
L["OP_TITLE"] = "Proprietà";
L["OP_TRANSFORM"] = "Trasformazione";
L["OP_ACTOR_PROPERTIES"] = "Proprietà dell'Attore";
L["OP_SCENE_PROPERTIES"] = "Proprietà della Scena";
L["OP_AMBIENT_COLOR"] = "Colore Ambiente";
L["OP_DIFFUSE_COLOR"] = "Colore Diffuso";
L["OP_BACKGROUND_COLOR"] = "Colore di Sfondo";
L["OP_TT_RESET_VALUE"] = "Ripristina il valore predefinito";
L["OP_TT_X_FIELD"] = "X";
L["OP_TT_Y_FIELD"] = "Y";
L["OP_TT_Z_FIELD"] = "Z";
L["OP_ENABLE_LIGHTING"] = "Abilita Illuminazione";
L["OP_CAMERA_PROPERTIES"] = "Proprietà della Fotocamera";
L["FOV"] = "Campo Visivo";
L["NEARCLIP"] = "Clip Vicino";
L["FARCLIP"] = "Clip Lontano";

-- Scene Hierarchy --
L["SH_TITLE"] = "Gerarchia della Scena";

-- Color Picker --
L["COLP_WINDOW_TITLE"] = "Selettore Colore";
L["COLP_RGB_NAME"] = "RGB (Rosso/Verde/Blu):";
L["COLP_HSL_NAME"] = "HSL (Tonalità/Saturazione/Luminosità):";
L["COLP_R"] = "R";  -- Rosso
L["COLP_G"] = "V";  -- Verde
L["COLP_B"] = "B";  -- Blu
L["COLP_H"] = "H";  -- Tonalità
L["COLP_S"] = "S";  -- Saturazione
L["COLP_L"] = "L";  -- Luminosità

-- About Screen --
L["ABOUT_WINDOW_TITLE"] = "Scene Machine";
L["ABOUT_VERSION"] = "Version %s";
L["ABOUT_DESCRIPTION"] = "Scene Machine è uno strumento per creare e modificare scene 3D utilizzando i modelli disponibili nel gioco. Si basa sull'API ModelScene, quindi si applicano alcune limitazioni.";
L["ABOUT_LICENSE"] = "Soggetto a licenza sotto il MIT License";
L["ABOUT_AUTHOR"] = "Autore: %s";
L["ABOUT_CONTACT"] = "Contatto: %s";

-- Settings window --
L["SETTINGS_WINDOW_TITLE"] = "Impostazioni";
L["SETTINGS_TAB_GENERAL"] = "Generale";
L["SETTINGS_TAB_GIZMOS"] = "Gizmos";
L["SETTINGS_TAB_DEBUG"] = "Debug";
L["SETTINGS_EDITOR_SCALE"] = "Scala editor";
L["SETTINGS_SHOW_SELECTION_HIGHLIGHT"] = "Mostra selezione evidenziata";
L["SETTINGS_HIDE_PARALLEL_GIZMOS"] = "Nascondi gizmos di traslazione paralleli alla fotocamera";
L["SETTINGS_ALWAYS_SHOW_CAM_GIZMO"] = "Mostra sempre il gizmo della fotocamera";
L["SETTINGS_GIZMO_SIZE"] = "Dimensione del gizmo";
L["SETTINGS_SHOW_DEBUG_TAB"] = "Mostra scheda Debug in Esplora risorse asset";

-- Error Messages --
L["DECODE_FAILED"] = "Impossibile decodificare i dati.";
L["DECOMPRESS_FAILED"] = "Impossibile decomprimere i dati.";
L["DESERIALIZE_FAILED"] = "Impossibile deserializzare i dati.";
L["DATA_VERSION_TOO_NEW"] = "Rilevata una versione più recente dei dati, non supportata. Si prega di aggiornare SceneMachine.";

