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
L["SCROLL_TOP"] = "Nach oben springen";
L["SCROLL_BOTTOM"] = "Nach unten springen";
L["LOAD"] = "Laden";

-- Editor --
L["ADDON_NAME"] = "Szenenmaschine";
L["EDITOR_MAIN_WINDOW_TITLE"] = "Szenenmaschine %s - %s";       -- Szenenmaschine <Version> - <aktueller Projektname>
L["EDITOR_MSG_DELETE_OBJECT_TITLE"] = "Objekt löschen";
L["EDITOR_MSG_DELETE_OBJECT_MESSAGE"] = "Das Objekt enthält eine Animations-Spur, möchten Sie es wirklich löschen?";
L["EDITOR_MSG_DELETE_TRACK_TITLE"] = "Spur löschen";
L["EDITOR_MSG_DELETE_TRACK_A_K_MESSAGE"] = "Die Spur enthält Animationen und Schlüsselbilder, möchten Sie sie wirklich löschen?";
L["EDITOR_MSG_DELETE_TRACK_A_MESSAGE"] = "Die Spur enthält Animationen, möchten Sie sie wirklich löschen?";
L["EDITOR_MSG_DELETE_TRACK_K_MESSAGE"] = "Die Spur enthält Schlüsselbilder, möchten Sie sie wirklich löschen?";
L["EDITOR_MSG_SAVE_TITLE"] = "Speichern";
L["EDITOR_MSG_SAVE_MESSAGE"] = "Das Speichern erfordert einen UI-Neustart. Möchten Sie fortfahren?";
L["EDITOR_SCENESCRIPT_WINDOW_TITLE"] = "Szenenskript importieren";
L["EDITOR_TOOLBAR_TT_OPEN_PROJECT_MANAGER"] = "Projekt-Manager öffnen";
L["EDITOR_TOOLBAR_TT_PROJECT_LIST"] = "Projekt ändern";
L["EDITOR_TOOLBAR_TT_SELECT_TOOL"] = "Auswahlwerkzeug";
L["EDITOR_TOOLBAR_TT_MOVE_TOOL"] = "Verschiebungswerkzeug";
L["EDITOR_TOOLBAR_TT_ROTATE_TOOL"] = "Drehwerkzeug";
L["EDITOR_TOOLBAR_TT_SCALE_TOOL"] = "Skalierungswerkzeug";
L["EDITOR_TOOLBAR_TT_PIVOT_LOCAL_SPACE"] = "Lokaler Pivotpunkt";
L["EDITOR_TOOLBAR_TT_PIVOT_WORLD_SPACE"] = "Globaler Pivotpunkt";
L["EDITOR_TOOLBAR_TT_PIVOT_CENTER"] = "Pivotpunkt zentrieren";
L["EDITOR_TOOLBAR_TT_PIVOT_BASE"] = "Basis-Pivotpunkt";
L["EDITOR_IMPORT_EXPORT_WINDOW_TITLE"] = "Import - Export";
L["EDITOR_NAME_RENAME_WINDOW_TITLE"] = "Name ändern";
L["EDITOR_TOOLBAR_TT_MULTITRANSFORM_TOGETHER"] = "Zusammen transformieren";
L["EDITOR_TOOLBAR_TT_MULTITRANSFORM_INDIVIDUAL"] = "Einzeln transformieren";
L["EDITOR_TOOLBAR_TT_UNDO"] = "Rückgängig";
L["EDITOR_TOOLBAR_TT_REDO"] = "Wiederholen";
L["EDITOR_TOOLBAR_TT_CREATE_CAMERA"] = "Kamera erstellen";
L["EDITOR_TOOLBAR_TT_CREATE_CHARACTER"] = "Charakter erstellen";
L["EDITOR_FULLSCREEN_NOTIFICATION"] = "Vollbildmodus aktiviert\nDrücken Sie ESC zum Beenden\nDrücken Sie P zum Abspielen/Pausieren";
L["EDITOR_TOOLBAR_TT_LETTERBOX_ON"] = "Briefkasten ausblenden (schwarze Balken)";
L["EDITOR_TOOLBAR_TT_LETTERBOX_OFF"] = "Briefkasten anzeigen (schwarze Balken)";
L["EDITOR_TOOLBAR_TT_FULLSCREEN"] = "Vollbildmodus aktivieren";

-- Main Menu --
L["MM_FILE"] = "Datei";
L["MM_EDIT"] = "Bearbeiten";
L["MM_OPTIONS"] = "Optionen";
L["MM_HELP"] = "Hilfe";
L["MM_PROJECT_MANAGER"] = "Projekt-Manager";
L["MM_IMPORT_SCENESCRIPT"] = "Szenenskript importieren";
L["MM_SAVE"] = "Speichern";
L["MM_CLONE_SELECTED"] = "Ausgewählte klonen";
L["MM_DELETE_SELECTED"] = "Ausgewählte löschen";
L["MM_SET_SCALE"] = "Skala festlegen %s";
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
L["CM_MOVE"] = "Bewegen";
L["CM_ROTATE"] = "Drehen";
L["CM_SCALE"] = "Skalieren";
L["CM_DELETE"] = "Löschen";
L["CM_HIDE_SHOW"] = "Verstecken/Anzeigen";
L["CM_HIDE"] = "Verstecken";
L["CM_SHOW"] = "Anzeigen";
L["CM_FREEZE_UNFREEZE"] = "Einfrieren/Auftauen";
L["CM_FREEZE"] = "Einfrieren";
L["CM_UNFREEZE"] = "Auftauen";
L["CM_RENAME"] = "Umbenennen";
L["CM_FOCUS"] = "Fokussieren";
L["CM_GROUP"] = "Gruppieren";

-- Animation Manager --
L["AM_ANIMATION_LIST_WINDOW_TITLE"] = "Animationsliste";
L["AM_TIMELINE"] = "Zeitachse %d";           -- timeline number
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
L["AM_TOOLBAR_TT_UIMODE"] = "Animationsmodus wechseln";
L["AM_TOOLBAR_TTD_UIMODE"] = "Animationsmodus wechseln:\n 1. Spuren-Ansicht - Verschiedene Objektspuren verwalten, Modelanimationen hinzufügen und Schlüsselbilder\n 2. Schlüsselbilder-Ansicht - Erweiterte Steuerung über Schlüsselbilder\n 3. Kurven-Ansicht - (noch nicht implementiert - derzeit nur für Debugging verwendet)\n";
L["AM_TOOLBAR_TT_ADD_TRACK"] = "Spur hinzufügen";
L["AM_TOOLBAR_TTD_ADD_TRACK"] = "Spur hinzufügen:\n - Erstellt eine neue Animations-Spur und ordnet sie dem ausgewählten Szenenobjekt zu\n - Ein Objekt in der Szene benötigt eine Spur, um eine Animation ausführen zu können\n - Jedes Objekt kann nur eine Spur zugeordnet haben";
L["AM_TOOLBAR_TT_REMOVE_TRACK"] = "Spur löschen";
L["AM_TOOLBAR_TT_ADD_ANIMATION"] = "Animation hinzufügen";
L["AM_TOOLBAR_TTD_ADD_ANIMATION"] = "Animation hinzufügen:\n - Fügt dem ausgewählten Track/Objekt einen Animationsclip hinzu\n - Öffnet das Fenster „Animationsliste“, in dem Sie einen verfügbaren Clip auswählen können";
L["AM_TOOLBAR_TT_REMOVE_ANIMATION"] = "Animation löschen";
L["AM_TOOLBAR_TT_ADD_KEYFRAME"] = "Schlüsselbild hinzufügen";
L["AM_TOOLBAR_TTD_ADD_KEYFRAME"] = "Schlüsselbild hinzufügen:\n - Fügt ein Schlüsselbild zur aktuellen Zeit hinzu.\n - Halten Sie die Schaltfläche gedrückt, um zwischen den Optionen zu wechseln:\n    1. Schlüsselbild zu allen Transformationen hinzufügen;\n    2. Nur Positionsschlüsselbild hinzufügen;\n    3. Nur Rotations-Schlüsselbild hinzufügen;\n    4. Nur Skalierungs-Schlüsselbild hinzufügen;";
L["AM_TOOLBAR_TT_SET_INTERPOLATION_IN"] = "Einfügung In festlegen";
L["AM_TOOLBAR_TTD_SET_INTERPOLATION_IN"] = "Einfügung In festlegen:\n - Legt den aktuellen Schlüsselbild-Innenbereich im Interpolationsmodus fest.\n - Halten Sie die Schaltfläche gedrückt, um zwischen den Optionen zu wechseln:\n    1. Weich\n    2. Linear\n    3. Schritt\n    4. Langsam\n    5. Schnell\n";
L["AM_TOOLBAR_TT_SET_INTERPOLATION_OUT"] = "Einfügung Out festlegen";
L["AM_TOOLBAR_TTD_SET_INTERPOLATION_OUT"] = "Einfügung Out festlegen:\n - Legt den aktuellen Schlüsselbild-Außenbereich im Interpolationsmodus fest.\n - Halten Sie die Schaltfläche gedrückt, um zwischen den Optionen zu wechseln:\n    1. Weich\n    2. Linear\n    3. Schritt\n    4. Langsam\n    5. Schnell\n";
L["AM_TOOLBAR_TT_REMOVE_KEYFRAME"] = "Schlüsselbild löschen";
L["AM_TOOLBAR_TT_SEEK_TO_START"] = "Zum Anfang springen";
L["AM_TOOLBAR_TT_SKIP_FRAME_BACK"] = "Zum vorherigen Bildspringen";
L["AM_TOOLBAR_TT_PLAY_PAUSE"] = "Wiedergabe/Pause";
L["AM_TOOLBAR_TT_SKIP_FRAME_FORWARD"] = "Zum nächsten Bildspringen";
L["AM_TOOLBAR_TT_SEEK_TO_END"] = "Zum Ende springen";
L["AM_TOOLBAR_TT_LOOP"] = "Wiedergabe wiederholen ein/aus";
L["AM_TOOLBAR_TT_PLAYCAMERA"] = "Kamerawiedergabe ein/aus";
L["AM_TT_LIST"] = "Zeitachse auswählen";
L["AM_TT_ADDTIMELINE"] = "Zeitachse hinzufügen";
L["AM_RMB_CHANGE_ANIM"] = "Animation ändern";
L["AM_RMB_SET_ANIM_SPEED"] = "Animationsgeschwindigkeit einstellen";
L["AM_RMB_DELETE_ANIM"] = "Animation löschen";
L["AM_RMB_DIFFERENT_COLOR"] = "Unterschiedliche Farbe";
L["AM_SET_ANIMATION_SPEED_PERCENT"] = "Animationsgeschwindigkeit einstellen %";
L["AM_TIMER_SET_DURATION"] = "Zeitachsen-Dauer festlegen";

-- AssetBrowser/AssetExplorer --
L["AB_RESULTS"] = "%d Ergebnisse";             -- <Anzahl> Ergebnisse (Suchergebnisse)
L["AB_BREADCRUMB"] = "...";             -- für einen Dateipfad
L["AB_TOOLBAR_TT_UP_ONE_FOLDER"] = "Ein Ordner nach oben.";
L["AM_MSG_REMOVE_COLLECTION_TITLE"] = "Sammlung entfernen";
L["AB_MSG_REMOVE_COLLECTION_MESSAGE"] = "Die Sammlung enthält Elemente, sind Sie sicher, dass Sie sie entfernen möchten?";
L["AB_TOOLBAR_TT_NEW_COLLECTION"] = "Neue Sammlung";
L["AB_TOOLBAR_TT_REMOVE_COLLECTION"] = "Sammlung entfernen";
L["AB_TOOLBAR_TT_RENAME_COLLECTION"] = "Sammlung umbenennen";
L["AB_TOOLBAR_TT_ADD_OBJECT"] = "Ausgewähltes Objekt hinzufügen";
L["AB_TOOLBAR_TT_REMOVE_OBJECT"] = "Objekt entfernen";
L["AB_TOOLBAR_TT_IMPORT_COLLECTION"] = "Sammlung importieren";
L["AB_TOOLBAR_TT_EXPORT_COLLECTION"] = "Sammlung exportieren";
L["AB_RMB_FILE_INFO"] = "Dateiinformationen";
L["AB_RMB_ADD_TO_COLLECTION"] = "Zur Sammlung hinzufügen";
L["AB_COLLECTION_NAME"] = "Name der Sammlung";
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
L["SM_SCENE"] = "Szene %d";                        -- Szenennummer
L["SM_MSG_DELETE_SCENE_TITLE"] = "Szene löschen";
L["SM_MSG_DELETE_SCENE_MESSAGE"] = "Möchten Sie fortfahren?";
L["SM_SCENE_NAME"] = "Szenenname";
L["SM_TT_LIST"] = "Szene auswählen";
L["SM_TT_ADDSCENE"] = "Szene hinzufügen";
L["SM_EXIT_CAMERA"] = "Kamera verlassen";

-- Object Properties --
L["OP_TITLE"] = "Eigenschaften";
L["OP_TRANSFORM"] = "Transformieren";
L["OP_ACTOR_PROPERTIES"] = "Schauspieler Eigenschaften";
L["OP_SCENE_PROPERTIES"] = "Szeneneigenschaften";
L["OP_AMBIENT_COLOR"] = "Umgebungslichtfarbe";
L["OP_DIFFUSE_COLOR"] = "Diffuse Farbe";
L["OP_BACKGROUND_COLOR"] = "Hintergrundfarbe";
L["OP_TT_RESET_VALUE"] = "Wert auf Standard zurücksetzen";
L["OP_TT_X_FIELD"] = "X";
L["OP_TT_Y_FIELD"] = "Y";
L["OP_TT_Z_FIELD"] = "Z";
L["OP_ENABLE_LIGHTING"] = "Beleuchtung aktivieren";
L["OP_CAMERA_PROPERTIES"] = "Kameraeigenschaften";
L["FOV"] = "Sichtfeld";
L["NEARCLIP"] = "Nahclip";
L["FARCLIP"] = "Fernclip";
L["OP_ENABLE_FOG"] = "Nebel aktivieren";
L["OP_FOG_COLOR"] = "Nebelfarbe";
L["OP_FOG_DISTANCE"] = "Nebelentfernung";

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
L["ABOUT_DESCRIPTION"] = "Die Szenenmaschine ist ein Werkzeug zur Erstellung und Bearbeitung von 3D-Szenen unter Verwendung der verfügbaren Ingame-Modelle. Sie basiert auf der ModelScene-API, sodass einige Einschränkungen gelten.";
L["ABOUT_LICENSE"] = "Lizenziert unter der MIT-Lizenz";
L["ABOUT_AUTHOR"] = "Autor: %s";
L["ABOUT_CONTACT"] = "Kontakt: %s";

-- Settings window --
L["SETTINGS_WINDOW_TITLE"] = "Einstellungen";
L["SETTINGS_TAB_GENERAL"] = "Allgemein";
L["SETTINGS_TAB_GIZMOS"] = "Gizmos";
L["SETTINGS_TAB_DEBUG"] = "Debug";
L["SETTINGS_EDITOR_SCALE"] = "Editor-Skalierung";
L["SETTINGS_SHOW_SELECTION_HIGHLIGHT"] = "Auswahl-Hervorhebung anzeigen";
L["SETTINGS_HIDE_PARALLEL_GIZMOS"] = "Übersetzungsgizmos parallel zur Kamera ausblenden";
L["SETTINGS_ALWAYS_SHOW_CAM_GIZMO"] = "Kamera-Gizmo immer anzeigen";
L["SETTINGS_GIZMO_SIZE"] = "Gizmo-Größe";
L["SETTINGS_SHOW_DEBUG_TAB"] = "Debug-Tab im Asset-Browser anzeigen";

-- Error Messages --
L["DECODE_FAILED"] = "Daten konnten nicht decodiert werden.";
L["DECOMPRESS_FAILED"] = "Datenkonnte nicht dekomprimiert werden.";
L["DESERIALIZE_FAILED"] = "Datenkonnten nicht deserialisiert werden.";
L["DATA_VERSION_TOO_NEW"] = "Neuere Daten-Version erkannt und wird nicht unterstützt. Bitte SceneMachine aktualisieren.";

