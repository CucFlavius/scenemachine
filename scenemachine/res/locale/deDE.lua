local AceLocale = LibStub("AceLocale-3.0");
local L = AceLocale:NewLocale("SceneMachine", "deDE", false);
if not L then return end

-- General --
L["YES"] = "Ja";
L["NO"] = "Nein";
L["POSITION"] = "Position";
L["ROTATION"] = "Rotation";
L["SCALE"] = "Skalierung";
L["ALPHA"] = "Alpha";   -- Transparenz
L["DESATURATION"] = "Entsättigung";
L["SEARCH"] = "Suchen";
L["RENAME"] = "Umbenennen";
L["EDIT"] = "Bearbeiten";
L["DELETE"] = "Löschen";
L["BUTTON_SAVE"] = "Speichern";
L["BUTTON_CANCEL"] = "Abbrechen";
L["EXPORT"] = "Exportieren";
L["IMPORT"] = "Importieren";
L["SCROLL_TOP"] = "Zum Anfang springen";
L["SCROLL_BOTTOM"] = "Zum Ende springen";
L["LOAD"] = "Laden";

-- Editor --
L["ADDON_NAME"] = "Szenenmaschine";
L["EDITOR_MAIN_WINDOW_TITLE"] = "Szenenmaschine %s - %s";       -- Szenenmaschine <Version> - <aktueller Projektname>
L["EDITOR_MSG_DELETE_OBJECT_TITLE"] = "Objekt löschen";
L["EDITOR_MSG_DELETE_OBJECT_MESSAGE"] = "Das Objekt enthält eine Animations-Spur. Möchten Sie wirklich löschen?";
L["EDITOR_MSG_DELETE_TRACK_TITLE"] = "Spur löschen";
L["EDITOR_MSG_DELETE_TRACK_A_K_MESSAGE"] = "Die Spur enthält Animationen und Schlüsselbilder. Möchten Sie wirklich löschen?";
L["EDITOR_MSG_DELETE_TRACK_A_MESSAGE"] = "Die Spur enthält Animationen. Möchten Sie wirklich löschen?";
L["EDITOR_MSG_DELETE_TRACK_K_MESSAGE"] = "Die Spur enthält Schlüsselbilder. Möchten Sie wirklich löschen?";
L["EDITOR_MSG_SAVE_TITLE"] = "Speichern";
L["EDITOR_MSG_SAVE_MESSAGE"] = "Das Speichern erfordert einen UI-Neustart. Möchten Sie fortfahren?";
L["EDITOR_SCENESCRIPT_WINDOW_TITLE"] = "Szenendatei importieren";
L["EDITOR_TOOLBAR_TT_OPEN_PROJECT_MANAGER"] = "Projektmanager öffnen";
L["EDITOR_TOOLBAR_TT_PROJECT_LIST"] = "Projekt ändern";
L["EDITOR_TOOLBAR_TT_SELECT_TOOL"] = "Auswahlwerkzeug";
L["EDITOR_TOOLBAR_TT_MOVE_TOOL"] = "Bewegen-Werkzeug";
L["EDITOR_TOOLBAR_TT_ROTATE_TOOL"] = "Drehen-Werkzeug";
L["EDITOR_TOOLBAR_TT_SCALE_TOOL"] = "Skalieren-Werkzeug";
L["EDITOR_TOOLBAR_TT_PIVOT_LOCAL_SPACE"] = "Lokaler Pivotpunkt";
L["EDITOR_TOOLBAR_TT_PIVOT_WORLD_SPACE"] = "Globaler Pivotpunkt";
L["EDITOR_TOOLBAR_TT_PIVOT_CENTER"] = "Zentrierter Pivotpunkt";
L["EDITOR_TOOLBAR_TT_PIVOT_BASE"] = "Basierter Pivotpunkt";
L["EDITOR_IMPORT_EXPORT_WINDOW_TITLE"] = "Import - Export";
L["EDITOR_NAME_RENAME_WINDOW_TITLE"] = "Umbenennen";
L["EDITOR_TOOLBAR_TT_MULTITRANSFORM_TOGETHER"] = "Zusammen transformieren";
L["EDITOR_TOOLBAR_TT_MULTITRANSFORM_INDIVIDUAL"] = "Einzeln transformieren";
L["EDITOR_TOOLBAR_TT_UNDO"] = "Schritt rückgängig machen";
L["EDITOR_TOOLBAR_TT_REDO"] = "Wiederherstellen";
L["EDITOR_TOOLBAR_TT_CREATE_CAMERA"] = "Kamera erstellen";
L["EDITOR_TOOLBAR_TT_CREATE_CHARACTER"] = "Charakter erstellen";
L["EDITOR_FULLSCREEN_NOTIFICATION"] = "Vollbildmodus aktiviert\nDrücken Sie ESC, um zu beenden\nDrücken Sie P zum Abspielen/Pausieren";
L["EDITOR_TOOLBAR_TT_LETTERBOX_ON"] = "Briefkästen ausblenden (schwarze Balken)";
L["EDITOR_TOOLBAR_TT_LETTERBOX_OFF"] = "Briefkästen anzeigen (schwarze Balken)";
L["EDITOR_TOOLBAR_TT_FULLSCREEN"] = "Vollbildmodus aktivieren";

-- Main Menu --
L["MM_FILE"] = "Datei";
L["MM_EDIT"] = "Bearbeiten";
L["MM_OPTIONS"] = "Optionen";
L["MM_HELP"] = "Hilfe";
L["MM_PROJECT_MANAGER"] = "Projekt Manager";
L["MM_IMPORT_SCENESCRIPT"] = "Szenenskript importieren";
L["MM_SAVE"] = "Speichern";
L["MM_CLONE_SELECTED"] = "Auswahl klonen";
L["MM_DELETE_SELECTED"] = "Auswahl löschen";
L["MM_SET_SCALE"] = "Skalierung festlegen %s";
L["MM_KEYBOARD_SHORTCUTS"] = "Tastenkürzel";
L["MM_ABOUT"] = "Über";
L["MM_SCENE"] = "Szene";
L["MM_SCENE_NEW"] = "Neu";
L["MM_SCENE_REMOVE"] = "Entfernen";
L["MM_SCENE_RENAME"] = "Umbenennen";
L["MM_SCENE_EXPORT"] = "Exportieren";
L["MM_SCENE_IMPORT"] = "Importieren";
L["MM_TITLE_SCENE_NAME"] = "Szenenname";
L["MM_TITLE_SCENE_RENAME"] = "Szene umbenennen";
L["MM_SETTINGS"] = "Einstellungen";

-- Context Menu --
L["CM_SELECT"] = "Auswählen";
L["CM_MOVE"] = "Verschieben";
L["CM_ROTATE"] = "Drehen";
L["CM_SCALE"] = "Skalieren";
L["CM_DELETE"] = "Löschen";
L["CM_HIDE_SHOW"] = "Verstecken/Anzeigen";
L["CM_HIDE"] = "Verstecken";
L["CM_SHOW"] = "Anzeigen";
L["CM_FREEZE_UNFREEZE"] = "Fixieren/Aufheben";
L["CM_FREEZE"] = "Fixieren";
L["CM_UNFREEZE"] = "Aufheben";
L["CM_RENAME"] = "Umbenennen";
L["CM_FOCUS"] = "Fokus";
L["CM_GROUP"] = "Gruppieren";

-- Animation Manager --
L["AM_ANIMATION_LIST_WINDOW_TITLE"] = "Animationsliste";
L["AM_TIMELINE"] = "Zeitachse %d"; -- Zeitachse Nummer
L["AM_MSG_DELETE_TIMELINE_TITLE"] = "Zeitachse löschen";
L["AM_MSG_DELETE_TIMELINE_MESSAGE"] = "Möchten Sie fortfahren?";
L["AM_MSG_NO_TRACK_TITLE"] = "Keine Spur";
L["AM_MSG_NO_TRACK_MESSAGE"] = "Das Objekt hat keine Animations-Spur. Möchten Sie eine hinzufügen?";
L["AM_BUTTON_ADD_ANIMATION"] = "Anim hinzufügen";
L["AM_BUTTON_CHANGE_ANIMATION"] = "Anim ändern";
L["AM_TIMELINE_NAME"] = "Zeitachsenname";
L["AM_TOOLBAR_TRACKS"] = "Spuren";
L["AM_TOOLBAR_KEYFRAMES"] = "Schlüsselbilder";
L["AM_TOOLBAR_CURVES"] = "Kurven (nur Debug)";
L["AM_TOOLBAR_TT_UIMODE"] = "Animation-Modus wechseln";
L["AM_TOOLBAR_TTD_UIMODE"] = "Animation-Modus wechseln:\n" ..
L["AM_TOOLBAR_TT_ADD_TRACK"] = "Spur hinzufügen";
L["AM_TOOLBAR_TTD_ADD_TRACK"] = "Spur hinzufügen:\n" ..
L["AM_TOOLBAR_TT_REMOVE_TRACK"] = "Spur löschen";
L["AM_TOOLBAR_TT_ADD_ANIMATION"] = "Animation hinzufügen";
L["AM_TOOLBAR_TTD_ADD_ANIMATION"] = "Animation hinzufügen:\n" ..
L["AM_TOOLBAR_TT_REMOVE_ANIMATION"] = "Animation löschen";
L["AM_TOOLBAR_TT_ADD_KEYFRAME"] = "Schlüsselbild hinzufügen";
L["AM_TOOLBAR_TTD_ADD_KEYFRAME"] = "Schlüsselbild hinzufügen:\n" ..
L["AM_TOOLBAR_TT_SET_INTERPOLATION_IN"] = "Interpolation eingeben";
L["AM_TOOLBAR_TTD_SET_INTERPOLATION_IN"] = "Interpolation eingeben:\n" ..
L["AM_TOOLBAR_TT_SET_INTERPOLATION_OUT"] = "Interpolation ausgeben";
L["AM_TOOLBAR_TTD_SET_INTERPOLATION_OUT"] = "Interpolation ausgeben:\n" ..
L["AM_TOOLBAR_TT_REMOVE_KEYFRAME"] = "Schlüsselbild löschen";
L["AM_TOOLBAR_TT_SEEK_TO_START"] = "Zum Anfang springen";
L["AM_TOOLBAR_TT_SKIP_FRAME_BACK"] = "Zum vorherigen Frame springen";
L["AM_TOOLBAR_TT_PLAY_PAUSE"] = "Abspielen / Pause";
L["AM_TOOLBAR_TT_SKIP_FRAME_FORWARD"] = "Zum nächsten Frame springen";
L["AM_TOOLBAR_TT_SEEK_TO_END"] = "Zum Ende springen";
L["AM_TOOLBAR_TT_LOOP"] = "Wiederholen ein/aus";
L["AM_TOOLBAR_TT_PLAYCAMERA"] = "Kamerawiedergabe ein/aus";
L["AM_TT_LIST"] = "Zeitachse auswählen";
L["AM_TT_ADDTIMELINE"] = "Zeitachse hinzufügen";
L["AM_RMB_CHANGE_ANIM"] = "Animation ändern";
L["AM_RMB_SET_ANIM_SPEED"] = "Animationsgeschwindigkeit einstellen";
L["AM_RMB_DELETE_ANIM"] = "Animation löschen";
L["AM_RMB_DIFFERENT_COLOR"] = "Verschiedene Farbe";
L["AM_SET_ANIMATION_SPEED_PERCENT"] = "Animationsgeschwindigkeit %";
L["AM_TIMER_SET_DURATION"] = "Dauer der Zeitachse festlegen";

-- AssetBrowser/AssetExplorer --
L["AB_RESULTS"] = "%d Ergebnisse"; -- <number> Ergebnisse (Suchergebnisse)
L["AB_BREADCRUMB"] = "..."; -- für einen Dateipfad
L["AB_TOOLBAR_TT_UP_ONE_FOLDER"] = "Zurück zum übergeordneten Ordner.";
L["AM_MSG_REMOVE_COLLECTION_TITLE"] = "Sammlung entfernen";
L["AB_MSG_REMOVE_COLLECTION_MESSAGE"] = "Die Sammlung enthält Elemente. Sind Sie sicher, dass Sie sie entfernen möchten?";
L["AB_TOOLBAR_TT_NEW_COLLECTION"] = "Neue Sammlung";
L["AB_TOOLBAR_TT_REMOVE_COLLECTION"] = "Sammlung entfernen";
L["AB_TOOLBAR_TT_RENAME_COLLECTION"] = "Sammlung umbenennen";
L["AB_TOOLBAR_TT_ADD_OBJECT"] = "Ausgewähltes Objekt hinzufügen";
L["AB_TOOLBAR_TT_REMOVE_OBJECT"] = "Objekt entfernen";
L["AB_TOOLBAR_TT_IMPORT_COLLECTION"] = "Sammlung importieren";
L["AB_TOOLBAR_TT_EXPORT_COLLECTION"] = "Sammlung exportieren";
L["AB_RMB_FILE_INFO"] = "Dateiinformationen";
L["AB_RMB_ADD_TO_COLLECTION"] = "Zur Sammlung hinzufügen";
L["AB_COLLECTION_NAME"] = "Sammlungsname";
L["AB_COLLECTION_RENAME"] = "Sammlung umbenennen";
L["AB_TAB_MODELS"] = "Modelle";
L["AB_TAB_CREATURES"] = "Kreaturen";
L["AB_TAB_COLLECTIONS"] = "Sammlungen";
L["AB_TAB_DEBUG"] = "Debug";

-- Project Manager --
L["PM_WINDOW_TITLE"] = "Projektmanager";
L["PM_PROJECT_NAME"] = "Projektname";
L["PM_NEW_PROJECT"] = "Neues Projekt";
L["PM_EDIT_PROJECT"] = "Projekt bearbeiten";
L["PM_MSG_DELETE_PROJECT_TITLE"] = "Projekt löschen";
L["PM_MSG_DELETE_PROJECT_MESSAGE"] = "Durch das Löschen des Projekts werden auch alle Szenen und Daten gelöscht. Möchten Sie fortfahren?";
L["PM_BUTTON_NEW_PROJECT"] = "Neues Projekt";
L["PM_BUTTON_LOAD_PROJECT"] = "Projekt laden";
L["PM_BUTTON_EDIT_PROJECT"] = "Projekt bearbeiten";
L["PM_BUTTON_REMOVE_PROJECT"] = "Projekt entfernen";
L["PM_BUTTON_SAVE_DATA"] = "Daten speichern";

-- Scene Manager --
L["SM_SCENE"] = "Szene %d";                 -- Szenennummer
L["SM_MSG_DELETE_SCENE_TITLE"] = "Szene löschen";
L["SM_MSG_DELETE_SCENE_MESSAGE"] = "Sind Sie sicher, dass Sie fortfahren möchten?";
L["SM_SCENE_NAME"] = "Szenenname";
L["SM_TT_LIST"] = "Szene wählen";
L["SM_TT_ADDSCENE"] = "Szene hinzufügen";
L["SM_EXIT_CAMERA"] = "Kamera verlassen";

-- Object Properties --
L["OP_TITLE"] = "Eigenschaften";
L["OP_TRANSFORM"] = "Transformation";
L["OP_ACTOR_PROPERTIES"] = "Eigenschaften des Akteurs";
L["OP_SCENE_PROPERTIES"] = "Szeneneigenschaften";
L["OP_AMBIENT_COLOR"] = "Umgebungslichtfarbe";
L["OP_DIFFUSE_COLOR"] = "Diffuse Farbe";
L["OP_BACKGROUND_COLOR"] = "Hintergrundfarbe";
L["OP_TT_RESET_VALUE"] = "Wert auf Standard zurücksetzen";
L["OP_TT_X_FIELD"] = "X";
L["OP_TT_Y_FIELD"] = "Y";
L["OP_TT_Z_FIELD"] = "Z";
L["OP_ENABLE_LIGHTING"] = "Beleuchtung aktivieren";
L["OP_CAMERA_PROPERTIES"] = "Kameraparameter";
L["FOV"] = "Sichtfeld";
L["NEARCLIP"] = "Nahe Bereich";
L["FARCLIP"] = "Ferne Bereich";

-- Scene Hierarchy --
L["SH_TITLE"] = "Szenenhierarchie";

-- Color Picker --
L["COLP_WINDOW_TITLE"] = "Farbauswahl";
L["COLP_RGB_NAME"] = "RGB (Rot/Grün/Blau):";
L["COLP_HSL_NAME"] = "HSL (Farbton/Sättigung/Helligkeit):";
L["COLP_R"] = "R";  -- Rot
L["COLP_G"] = "G";  -- Grün
L["COLP_B"] = "B";  -- Blau
L["COLP_H"] = "H";  -- Farbton
L["COLP_S"] = "S";  -- Sättigung
L["COLP_L"] = "L";  -- Helligkeit

-- About Screen --
L["ABOUT_WINDOW_TITLE"] = "Szenenmaschine";
L["ABOUT_VERSION"] = "Version %s";
L["ABOUT_DESCRIPTION"] = "Die Szenenmaschine ist ein Tool zum Erstellen und Bearbeiten von 3D-Szenen mit verfügbaren In-Game-Modellen. Sie basiert auf der ModelScene-API, daher gelten einige Einschränkungen.";
L["ABOUT_LICENSE"] = "Lizenziert unter der MIT-Lizenz";
L["ABOUT_AUTHOR"] = "Autor: %s";
L["ABOUT_CONTACT"] = "Kontakt: %s";

-- Settings window --
L["SETTINGS_WINDOW_TITLE"] = "Einstellungen";
L["SETTINGS_TAB_GENERAL"] = "Allgemein";
L["SETTINGS_TAB_GIZMOS"] = "Gizmos";
L["SETTINGS_TAB_DEBUG"] = "Debug";
L["SETTINGS_EDITOR_SCALE"] = "Editor-Skala";
L["SETTINGS_SHOW_SELECTION_HIGHLIGHT"] = "Auswahl-Hervorhebung anzeigen";
L["SETTINGS_HIDE_PARALLEL_GIZMOS"] = "Übersetzungsgizmos parallel zur Kamera ausblenden";
L["SETTINGS_ALWAYS_SHOW_CAM_GIZMO"] = "Kameragizmo immer anzeigen";
L["SETTINGS_GIZMO_SIZE"] = "Gizmo-Größe";
L["SETTINGS_SHOW_DEBUG_TAB"] = "Debug-Tab im Asset Browser anzeigen";

-- Error Messages --
L["DECODE_FAILED"] = "Daten konnten nicht decodiert werden.";
L["DECOMPRESS_FAILED"] = "Daten konnten nicht dekomprimiert werden.";
L["DESERIALIZE_FAILED"] = "Daten konnten nicht deserialisiert werden.";
L["DATA_VERSION_TOO_NEW"] = "Neuere Datenversion erkannt und wird nicht unterstützt. Bitte aktualisieren Sie SceneMachine.";

