local AceLocale = LibStub("AceLocale-3.0");
local L = AceLocale:NewLocale("SceneMachine", "frFR", false);
if not L then return end

-- General --
L["YES"] = "Oui";
L["NO"] = "Non";
L["POSITION"] = "Position";
L["ROTATION"] = "Rotation";
L["SCALE"] = "Échelle";
L["ALPHA"] = "Transparence";
L["DESATURATION"] = "Désaturation";
L["SEARCH"] = "Rechercher";
L["RENAME"] = "Renommer";
L["EDIT"] = "Modifier";
L["DELETE"] = "Supprimer";
L["BUTTON_SAVE"] = "Enregistrer";
L["BUTTON_CANCEL"] = "Annuler";
L["EXPORT"] = "Exporter";
L["IMPORT"] = "Importer";
L["SCROLL_TOP"] = "Aller en haut";
L["SCROLL_BOTTOM"] = "Aller en bas";
L["LOAD"] = "Charger";

-- Editor --
L["ADDON_NAME"] = "Scene Machine";
L["EDITOR_MAIN_WINDOW_TITLE"] = "Scene Machine %s - %s"; -- Scene Machine <version> - <current project name>
L["EDITOR_MSG_DELETE_OBJECT_TITLE"] = "Supprimer l'objet";
L["EDITOR_MSG_DELETE_OBJECT_MESSAGE"] = "L'objet contient une piste d'animation, êtes-vous sûr de vouloir supprimer ?";
L["EDITOR_MSG_DELETE_TRACK_TITLE"] = "Supprimer la piste";
L["EDITOR_MSG_DELETE_TRACK_A_K_MESSAGE"] = "La piste contient des animations et des images clés, êtes-vous sûr de vouloir supprimer ?";
L["EDITOR_MSG_DELETE_TRACK_A_MESSAGE"] = "La piste contient des animations, êtes-vous sûr de vouloir supprimer ?";
L["EDITOR_MSG_DELETE_TRACK_K_MESSAGE"] = "La piste contient des images clés, êtes-vous sûr de vouloir supprimer ?";
L["EDITOR_MSG_SAVE_TITLE"] = "Enregistrer";
L["EDITOR_MSG_SAVE_MESSAGE"] = "L'enregistrement nécessite un rechargement de l'interface utilisateur, continuer ?";
L["EDITOR_SCENESCRIPT_WINDOW_TITLE"] = "Importer un script de scène";
L["EDITOR_TOOLBAR_TT_OPEN_PROJECT_MANAGER"] = "Ouvrir le Gestionnaire de projets";
L["EDITOR_TOOLBAR_TT_PROJECT_LIST"] = "Changer de projet";
L["EDITOR_TOOLBAR_TT_SELECT_TOOL"] = "Outil de sélection";
L["EDITOR_TOOLBAR_TT_MOVE_TOOL"] = "Outil de déplacement";
L["EDITOR_TOOLBAR_TT_ROTATE_TOOL"] = "Outil de rotation";
L["EDITOR_TOOLBAR_TT_SCALE_TOOL"] = "Outil d'échelle";
L["EDITOR_TOOLBAR_TT_PIVOT_LOCAL_SPACE"] = "Pivot d'espace local";
L["EDITOR_TOOLBAR_TT_PIVOT_WORLD_SPACE"] = "Pivot d'espace mondial";
L["EDITOR_TOOLBAR_TT_PIVOT_CENTER"] = "Pivot central";
L["EDITOR_TOOLBAR_TT_PIVOT_BASE"] = "Pivot de base";
L["EDITOR_IMPORT_EXPORT_WINDOW_TITLE"] = "Importer - Exporter";
L["EDITOR_NAME_RENAME_WINDOW_TITLE"] = "Nom - Renommer";
L["EDITOR_TOOLBAR_TT_MULTITRANSFORM_TOGETHER"] = "Transformer ensemble";
L["EDITOR_TOOLBAR_TT_MULTITRANSFORM_INDIVIDUAL"] = "Transformer individuellement";
L["EDITOR_TOOLBAR_TT_UNDO"] = "Annuler";
L["EDITOR_TOOLBAR_TT_REDO"] = "Refaire";
L["EDITOR_TOOLBAR_TT_CREATE_CAMERA"] = "Créer une caméra";
L["EDITOR_TOOLBAR_TT_CREATE_CHARACTER"] = "Créer un personnage";
L["EDITOR_FULLSCREEN_NOTIFICATION"] = "Entrée en plein écran\nAppuyez sur ESC pour sortir\nAppuyez sur P pour jouer/mettre en pause";
L["EDITOR_TOOLBAR_TT_LETTERBOX_ON"] = "Masquer les bandes noires (Letterbox)";
L["EDITOR_TOOLBAR_TT_LETTERBOX_OFF"] = "Afficher les bandes noires (Letterbox)";
L["EDITOR_TOOLBAR_TT_FULLSCREEN"] = "Entrer en plein écran";

-- Main Menu --
L["MM_FILE"] = "Fichier";
L["MM_EDIT"] = "Édition";
L["MM_OPTIONS"] = "Options";
L["MM_HELP"] = "Aide";
L["MM_PROJECT_MANAGER"] = "Gestionnaire de projet";
L["MM_IMPORT_SCENESCRIPT"] = "Importer Scenescript";
L["MM_SAVE"] = "Enregistrer";
L["MM_CLONE_SELECTED"] = "Cloner la sélection";
L["MM_DELETE_SELECTED"] = "Supprimer la sélection";
L["MM_SET_SCALE"] = "Définir l'échelle %s";
L["MM_KEYBOARD_SHORTCUTS"] = "Raccourcis clavier";
L["MM_ABOUT"] = "À propos";
L["MM_SCENE"] = "Scène";
L["MM_SCENE_NEW"] = "Nouveau";
L["MM_SCENE_REMOVE"] = "Supprimer";
L["MM_SCENE_RENAME"] = "Renommer";
L["MM_SCENE_EXPORT"] = "Exporter";
L["MM_SCENE_IMPORT"] = "Importer";
L["MM_TITLE_SCENE_NAME"] = "Nom de la scène";
L["MM_TITLE_SCENE_RENAME"] = "Renommer la scène";
L["MM_SETTINGS"] = "Paramètres";

-- Context Menu --
L["CM_SELECT"] = "Sélectionner";
L["CM_MOVE"] = "Déplacer";
L["CM_ROTATE"] = "Faire pivoter";
L["CM_SCALE"] = "Redimensionner";
L["CM_DELETE"] = "Supprimer";
L["CM_HIDE_SHOW"] = "Masquer/Afficher";
L["CM_HIDE"] = "Masquer";
L["CM_SHOW"] = "Afficher";
L["CM_FREEZE_UNFREEZE"] = "Geler/Dégeler";
L["CM_FREEZE"] = "Geler";
L["CM_UNFREEZE"] = "Dégeler";
L["CM_RENAME"] = "Renommer";
L["CM_FOCUS"] = "Mettre au premier plan";
L["CM_GROUP"] = "Grouper";

-- Animation Manager --
L["AM_ANIMATION_LIST_WINDOW_TITLE"] = "Liste des animations";
L["AM_TIMELINE"] = "Chronologie %d";               -- numéro de la chronologie
L["AM_MSG_DELETE_TIMELINE_TITLE"] = "Supprimer la chronologie";
L["AM_MSG_DELETE_TIMELINE_MESSAGE"] = "Voulez-vous vraiment continuer ?";
L["AM_MSG_NO_TRACK_TITLE"] = "Aucun chemin";
L["AM_MSG_NO_TRACK_MESSAGE"] = "L'objet n'a pas de piste d'animation, voulez-vous en ajouter une ?";
L["AM_BUTTON_ADD_ANIMATION"] = "Ajouter anim";
L["AM_BUTTON_CHANGE_ANIMATION"] = "Modifier anim";
L["AM_TIMELINE_NAME"] = "Nom de la chronologie";
L["AM_TOOLBAR_TRACKS"] = "Pistes";
L["AM_TOOLBAR_KEYFRAMES"] = "Images clés";
L["AM_TOOLBAR_CURVES"] = "Courbes (debug uniquement)";
L["AM_TOOLBAR_TT_UIMODE"] = "Basculer le mode d'animation";
L["AM_TOOLBAR_TTD_UIMODE"] = "Basculer le mode d'animation :\n 1. Vue des pistes - Gérer différentes pistes d'objets, ajouter des animations de modèles et des images clés\n 2. Vue des images clés - Contrôle avancé sur les images clés\n 3. Vue des courbes - (Pas encore implémenté - Actuellement uniquement utilisé pour le débogage)\n";
L["AM_TOOLBAR_TT_ADD_TRACK"] = "Ajouter une piste";
L["AM_TOOLBAR_TTD_ADD_TRACK"] = "Ajouter une piste :\n - Crée une nouvelle piste d'animation et l'assigne à l'objet de scène sélectionné\n - Un objet dans la scène nécessite une piste pour effectuer toute animation sur celui-ci.\n - Chaque objet ne peut avoir qu'une piste lui étant assignée";
L["AM_TOOLBAR_TT_REMOVE_TRACK"] = "Supprimer la piste";
L["AM_TOOLBAR_TT_ADD_ANIMATION"] = "Ajouter une animation";
L["AM_TOOLBAR_TTD_ADD_ANIMATION"] = "Ajouter une animation :\n - Ajoute un clip d'animation à la piste/objet actuellement sélectionné(e)\n - Ouvre la fenêtre de la liste des animations où vous pouvez sélectionner un clip disponible";
L["AM_TOOLBAR_TT_REMOVE_ANIMATION"] = "Supprimer l'animation";
L["AM_TOOLBAR_TT_ADD_KEYFRAME"] = "Ajouter une image clé";
L["AM_TOOLBAR_TTD_ADD_KEYFRAME"] = "Ajouter une image clé :\n - Ajoute une image clé au temps actuel.\n - Maintenez enfoncé pour basculer entre :\n    1. Ajouter des images clés à toutes les transformations ;\n    2. Ajouter uniquement une image clé de position ;\n    3. Ajouter uniquement une image clé de rotation ;\n    4. Ajouter uniquement une image clé d'échelle ;";
L["AM_TOOLBAR_TT_SET_INTERPOLATION_IN"] = "Définir l'interpolation entrante";
L["AM_TOOLBAR_TTD_SET_INTERPOLATION_IN"] = "Définir l'interpolation entrante :\n - Définit le mode d'interpolation entrante de l'image clé actuelle (gauche).\n - Maintenez pour basculer entre :\n    1. Lisse\n    2. Linéaire\n    3. Marche\n    4. Lente\n    5. Rapide\n";
L["AM_TOOLBAR_TT_SET_INTERPOLATION_OUT"] = "Définir l'interpolation sortante";
L["AM_TOOLBAR_TTD_SET_INTERPOLATION_OUT"] = "Définir l'interpolation sortante :\n - Définit le mode d'interpolation sortante de l'image clé actuelle (droite).\n - Maintenez pour basculer entre :\n    1. Lisse\n    2. Linéaire\n    3. Marche\n    4. Lente\n    5. Rapide\n";
L["AM_TOOLBAR_TT_REMOVE_KEYFRAME"] = "Supprimer l'image clé";
L["AM_TOOLBAR_TT_SEEK_TO_START"] = "Revenir au début";
L["AM_TOOLBAR_TT_SKIP_FRAME_BACK"] = "Aller à l'image clé précédente";
L["AM_TOOLBAR_TT_PLAY_PAUSE"] = "Lecture / Pause";
L["AM_TOOLBAR_TT_SKIP_FRAME_FORWARD"] = "Aller à l'image clé suivante";
L["AM_TOOLBAR_TT_SEEK_TO_END"] = "Aller à la fin";
L["AM_TOOLBAR_TT_LOOP"] = "Boucle de lecture activée/désactivée";
L["AM_TOOLBAR_TT_PLAYCAMERA"] = "Lecture de la caméra activée/désactivée";
L["AM_TT_LIST"] = "Sélectionner la chronologie";
L["AM_TT_ADDTIMELINE"] = "Ajouter une chronologie";
L["AM_RMB_CHANGE_ANIM"] = "Modifier l'animation";
L["AM_RMB_SET_ANIM_SPEED"] = "Définir la vitesse de l'animation";
L["AM_RMB_DELETE_ANIM"] = "Supprimer l'animation";
L["AM_RMB_DIFFERENT_COLOR"] = "Couleur différente";
L["AM_SET_ANIMATION_SPEED_PERCENT"] = "Définir la vitesse de l'animation %";
L["AM_TIMER_SET_DURATION"] = "Définir la durée de la chronologie";

-- AssetBrowser/AssetExplorer --
L["AB_RESULTS"] = "%d Résultats"; -- <nombre> résultats (résultats de recherche)
L["AB_BREADCRUMB"] = "..."; -- pour un chemin de fichier
L["AB_TOOLBAR_TT_UP_ONE_FOLDER"] = "Remonter d'un dossier.";
L["AM_MSG_REMOVE_COLLECTION_TITLE"] = "Supprimer la collection";
L["AB_MSG_REMOVE_COLLECTION_MESSAGE"] = "La collection contient des éléments, êtes-vous sûr de vouloir la supprimer ?";
L["AB_TOOLBAR_TT_NEW_COLLECTION"] = "Nouvelle collection";
L["AB_TOOLBAR_TT_REMOVE_COLLECTION"] = "Supprimer la collection";
L["AB_TOOLBAR_TT_RENAME_COLLECTION"] = "Renommer la collection";
L["AB_TOOLBAR_TT_ADD_OBJECT"] = "Ajouter l'objet sélectionné";
L["AB_TOOLBAR_TT_REMOVE_OBJECT"] = "Supprimer l'objet";
L["AB_TOOLBAR_TT_IMPORT_COLLECTION"] = "Importer la collection";
L["AB_TOOLBAR_TT_EXPORT_COLLECTION"] = "Exporter la collection";
L["AB_RMB_FILE_INFO"] = "Informations sur le fichier";
L["AB_RMB_ADD_TO_COLLECTION"] = "Ajouter à la collection";
L["AB_COLLECTION_NAME"] = "Nom de la collection";
L["AB_COLLECTION_RENAME"] = "Renommer la collection";
L["AB_TAB_MODELS"] = "Modèles";
L["AB_TAB_CREATURES"] = "Créatures";
L["AB_TAB_COLLECTIONS"] = "Collections";
L["AB_TAB_DEBUG"] = "Débogage";

-- Project Manager --
L["PM_WINDOW_TITLE"] = "Gestionnaire de projets";
L["PM_PROJECT_NAME"] = "Nom du projet";
L["PM_NEW_PROJECT"] = "Nouveau projet";
L["PM_EDIT_PROJECT"] = "Modifier le projet";
L["PM_MSG_DELETE_PROJECT_TITLE"] = "Supprimer le projet";
L["PM_MSG_DELETE_PROJECT_MESSAGE"] = "La suppression du projet entraînera également la suppression de toutes ses scènes et de ses données, continuer ?";
L["PM_BUTTON_NEW_PROJECT"] = "Nouveau projet";
L["PM_BUTTON_LOAD_PROJECT"] = "Charger le projet";
L["PM_BUTTON_EDIT_PROJECT"] = "Modifier le projet";
L["PM_BUTTON_REMOVE_PROJECT"] = "Supprimer le projet";
L["PM_BUTTON_SAVE_DATA"] = "Enregistrer les données";

-- Scene Manager --
L["SM_SCENE"] = "Scène %d";                 -- numéro de la scène
L["SM_MSG_DELETE_SCENE_TITLE"] = "Supprimer la scène";
L["SM_MSG_DELETE_SCENE_MESSAGE"] = "Êtes-vous sûr de vouloir continuer ?";
L["SM_SCENE_NAME"] = "Nom de la scène";
L["SM_TT_LIST"] = "Sélectionnez la scène";
L["SM_TT_ADDSCENE"] = "Ajouter une scène";
L["SM_EXIT_CAMERA"] = "Quitter la caméra";

-- Object Properties --
L["OP_TITLE"] = "Propriétés";
L["OP_TRANSFORM"] = "Transform";
L["OP_ACTOR_PROPERTIES"] = "Propriétés de l'acteur";
L["OP_SCENE_PROPERTIES"] = "Propriétés de la scène";
L["OP_AMBIENT_COLOR"] = "Couleur ambiante";
L["OP_DIFFUSE_COLOR"] = "Couleur diffuse";
L["OP_BACKGROUND_COLOR"] = "Couleur de fond";
L["OP_TT_RESET_VALUE"] = "Réinitialiser la valeur par défaut";
L["OP_TT_X_FIELD"] = "X";
L["OP_TT_Y_FIELD"] = "Y";
L["OP_TT_Z_FIELD"] = "Z";
L["OP_ENABLE_LIGHTING"] = "Activer l'éclairage";
L["OP_CAMERA_PROPERTIES"] = "Propriétés de la caméra";
L["FOV"] = "Champ de vision";
L["NEARCLIP"] = "Clipping proche";
L["FARCLIP"] = "Clipping lointain";
L["OP_ENABLE_FOG"] = "Activer le Brouillard";
L["OP_FOG_COLOR"] = "Couleur du Brouillard";
L["OP_FOG_DISTANCE"] = "Distance du Brouillard";

-- Scene Hierarchy --
L["SH_TITLE"] = "Hiérarchie des scènes";

-- Color Picker --
L["COLP_WINDOW_TITLE"] = "Sélecteur de couleur";
L["COLP_RGB_NAME"] = "RGB (Rouge/Vert/Bleu) :";
L["COLP_HSL_NAME"] = "HSL (Teinte/Saturation/Luminosité) :";
L["COLP_R"] = "R";  -- Rouge
L["COLP_G"] = "V";  -- Vert
L["COLP_B"] = "B";  -- Bleu
L["COLP_H"] = "T";  -- Teinte
L["COLP_S"] = "S";  -- Saturation
L["COLP_L"] = "L";  -- Luminosité

-- About Screen --
L["ABOUT_WINDOW_TITLE"] = "Machine à scène";
L["ABOUT_VERSION"] = "Version %s";
L["ABOUT_DESCRIPTION"] = "La Machine à scène est un outil pour créer et éditer des scènes 3D en utilisant des modèles disponibles en jeu. Elle utilise l'API ModelScene comme base, donc certaines limitations s'appliquent.";
L["ABOUT_LICENSE"] = "Sous licence MIT";
L["ABOUT_AUTHOR"] = "Auteur : %s";
L["ABOUT_CONTACT"] = "Contact : %s";

-- Settings window --
L["SETTINGS_WINDOW_TITLE"] = "Paramètres";
L["SETTINGS_TAB_GENERAL"] = "Général";
L["SETTINGS_TAB_GIZMOS"] = "Gadgets";
L["SETTINGS_TAB_DEBUG"] = "Débogage";
L["SETTINGS_EDITOR_SCALE"] = "Échelle de l'éditeur";
L["SETTINGS_SHOW_SELECTION_HIGHLIGHT"] = "Afficher la mise en surbrillance de la sélection";
L["SETTINGS_HIDE_PARALLEL_GIZMOS"] = "Masquer les gadgets de translation parallèles à la caméra";
L["SETTINGS_ALWAYS_SHOW_CAM_GIZMO"] = "Toujours afficher le gadget de caméra";
L["SETTINGS_GIZMO_SIZE"] = "Taille du gadget";
L["SETTINGS_SHOW_DEBUG_TAB"] = "Afficher l'onglet de débogage dans le navigateur d'actifs";

-- Error Messages --
L["DECODE_FAILED"] = "Échec du décodage des données.";
L["DECOMPRESS_FAILED"] = "Échec de la décompression des données.";
L["DESERIALIZE_FAILED"] = "Échec de la désérialisation des données.";
L["DATA_VERSION_TOO_NEW"] = "Une version de données plus récente a été détectée et n'est pas prise en charge. Veuillez mettre à jour SceneMachine.";

