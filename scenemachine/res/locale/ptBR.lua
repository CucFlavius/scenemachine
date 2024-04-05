local AceLocale = LibStub("AceLocale-3.0");
local L = AceLocale:NewLocale("SceneMachine", "ptBR", false);
if not L then return end

-- General --
L["YES"] = "Sim";
L["NO"] = "Não";
L["POSITION"] = "Posição";
L["ROTATION"] = "Rotação";
L["SCALE"] = "Escala";
L["ALPHA"] = "Transparência";
L["DESATURATION"] = "Desaturação";
L["SEARCH"] = "Buscar";
L["RENAME"] = "Renomear";
L["EDIT"] = "Editar";
L["DELETE"] = "Excluir";
L["BUTTON_SAVE"] = "Salvar";
L["BUTTON_CANCEL"] = "Cancelar";
L["EXPORT"] = "Exportar";
L["IMPORT"] = "Importar";
L["SCROLL_TOP"] = "Ir para o topo";
L["SCROLL_BOTTOM"] = "Ir para o final";
L["LOAD"] = "Carregar";

-- Editor --
L["ADDON_NAME"] = "Máquina de Cena";
L["EDITOR_MAIN_WINDOW_TITLE"] = "Máquina de Cena %s - %s";           -- Máquina de Cena <versão> - <nome do projeto atual>
L["EDITOR_MSG_DELETE_OBJECT_TITLE"] = "Excluir Objeto";
L["EDITOR_MSG_DELETE_OBJECT_MESSAGE"] = "O objeto contém uma faixa de animação, você tem certeza de que deseja excluir?";
L["EDITOR_MSG_DELETE_TRACK_TITLE"] = "Excluir Trilha";
L["EDITOR_MSG_DELETE_TRACK_A_K_MESSAGE"] = "A trilha contém animações e keyframes, você tem certeza de que deseja excluir?";
L["EDITOR_MSG_DELETE_TRACK_A_MESSAGE"] = "A trilha contém animações, você tem certeza de que deseja excluir?";
L["EDITOR_MSG_DELETE_TRACK_K_MESSAGE"] = "A trilha contém keyframes, você tem certeza de que deseja excluir?";
L["EDITOR_MSG_SAVE_TITLE"] = "Salvar";
L["EDITOR_MSG_SAVE_MESSAGE"] = "Salvar requer uma recarga da interface, continuar?";
L["EDITOR_SCENESCRIPT_WINDOW_TITLE"] = "Importar SceneScript";
L["EDITOR_TOOLBAR_TT_OPEN_PROJECT_MANAGER"] = "Abrir Gerenciador de Projetos";
L["EDITOR_TOOLBAR_TT_PROJECT_LIST"] = "Alterar projeto";
L["EDITOR_TOOLBAR_TT_SELECT_TOOL"] = "Selecionar Ferramenta";
L["EDITOR_TOOLBAR_TT_MOVE_TOOL"] = "Ferramenta de Mover";
L["EDITOR_TOOLBAR_TT_ROTATE_TOOL"] = "Ferramenta de Rotacionar";
L["EDITOR_TOOLBAR_TT_SCALE_TOOL"] = "Ferramenta de Escalar";
L["EDITOR_TOOLBAR_TT_PIVOT_LOCAL_SPACE"] = "Pivô no Espaço Local";
L["EDITOR_TOOLBAR_TT_PIVOT_WORLD_SPACE"] = "Pivô no Espaço Mundial";
L["EDITOR_TOOLBAR_TT_PIVOT_CENTER"] = "Pivô no Centro";
L["EDITOR_TOOLBAR_TT_PIVOT_BASE"] = "Pivô na Base";
L["EDITOR_IMPORT_EXPORT_WINDOW_TITLE"] = "Importar - Exportar";
L["EDITOR_NAME_RENAME_WINDOW_TITLE"] = "Nome - Renomear";
L["EDITOR_TOOLBAR_TT_MULTITRANSFORM_TOGETHER"] = "Transformar Juntos";
L["EDITOR_TOOLBAR_TT_MULTITRANSFORM_INDIVIDUAL"] = "Transformar Individualmente";
L["EDITOR_TOOLBAR_TT_UNDO"] = "Desfazer";
L["EDITOR_TOOLBAR_TT_REDO"] = "Refazer";
L["EDITOR_TOOLBAR_TT_CREATE_CAMERA"] = "Criar Câmera";
L["EDITOR_TOOLBAR_TT_CREATE_CHARACTER"] = "Criar Personagem";
L["EDITOR_FULLSCREEN_NOTIFICATION"] = "Entrou em Tela Cheia\nPressione ESC para sair\nPressione P para reproduzir/pausar";
L["EDITOR_TOOLBAR_TT_LETTERBOX_ON"] = "Ocultar Tarjas Pretas (letterbox)";
L["EDITOR_TOOLBAR_TT_LETTERBOX_OFF"] = "Mostrar Tarjas Pretas (letterbox)";
L["EDITOR_TOOLBAR_TT_FULLSCREEN"] = "Entrar em Tela Cheia";

-- Main Menu --
L["MM_FILE"] = "Arquivo";
L["MM_EDIT"] = "Editar";
L["MM_OPTIONS"] = "Opções";
L["MM_HELP"] = "Ajuda";
L["MM_PROJECT_MANAGER"] = "Gerenciador de Projetos";
L["MM_IMPORT_SCENESCRIPT"] = "Importar Script de Cena";
L["MM_SAVE"] = "Salvar";
L["MM_CLONE_SELECTED"] = "Clonar Selecionado";
L["MM_DELETE_SELECTED"] = "Excluir Selecionado";
L["MM_SET_SCALE"] = "Definir Escala %s";
L["MM_KEYBOARD_SHORTCUTS"] = "Atalhos de Teclado";
L["MM_ABOUT"] = "Sobre";
L["MM_SCENE"] = "Cena";
L["MM_SCENE_NEW"] = "Nova";
L["MM_SCENE_REMOVE"] = "Remover";
L["MM_SCENE_RENAME"] = "Renomear";
L["MM_SCENE_EXPORT"] = "Exportar";
L["MM_SCENE_IMPORT"] = "Importar";
L["MM_TITLE_SCENE_NAME"] = "Nome da Cena";
L["MM_TITLE_SCENE_RENAME"] = "Renomear Cena";
L["MM_SETTINGS"] = "Configurações";

-- Context Menu --
L["CM_SELECT"] = "Selecionar";
L["CM_MOVE"] = "Mover";
L["CM_ROTATE"] = "Rotacionar";
L["CM_SCALE"] = "Escalonar";
L["CM_DELETE"] = "Excluir";
L["CM_HIDE_SHOW"] = "Ocultar/Mostrar";
L["CM_HIDE"] = "Ocultar";
L["CM_SHOW"] = "Mostrar";
L["CM_FREEZE_UNFREEZE"] = "Congelar/Descongelar";
L["CM_FREEZE"] = "Congelar";
L["CM_UNFREEZE"] = "Descongelar";
L["CM_RENAME"] = "Renomear";
L["CM_FOCUS"] = "Focar";
L["CM_GROUP"] = "Agrupar";

-- Animation Manager --
L["AM_ANIMATION_LIST_WINDOW_TITLE"] = "Lista de Animações";
L["AM_TIMELINE"] = "Sequência %d";           -- número da sequência
L["AM_MSG_DELETE_TIMELINE_TITLE"] = "Excluir Sequência";
L["AM_MSG_DELETE_TIMELINE_MESSAGE"] = "Tem certeza de que deseja continuar?";
L["AM_MSG_NO_TRACK_TITLE"] = "Sem Trajetória";
L["AM_MSG_NO_TRACK_MESSAGE"] = "O objeto não possui uma trajetória de animação, deseja adicionar uma?";
L["AM_BUTTON_ADD_ANIMATION"] = "Adicionar Animação";
L["AM_BUTTON_CHANGE_ANIMATION"] = "Alterar Animação";
L["AM_TIMELINE_NAME"] = "Nome da Sequência";
L["AM_TOOLBAR_TRACKS"] = "Trajetórias";
L["AM_TOOLBAR_KEYFRAMES"] = "Keyframes";
L["AM_TOOLBAR_CURVES"] = "Curvas (apenas para depuração)";
L["AM_TOOLBAR_TT_UIMODE"] = "Alternar Modo de Animação";
L["AM_TOOLBAR_TTD_UIMODE"] = "Alternar Modo de Animação:\n 1. Visualizar Trajetórias - Gerenciar diferentes trajetórias de objetos, adicionar animações de modelos e keyframes\n 2. Visualizar Keyframes - Controle avançado sobre os keyframes\n 3. Visualizar Curvas - (Ainda não implementado - Atualmente usado apenas para depuração)\n";
L["AM_TOOLBAR_TT_ADD_TRACK"] = "Adicionar Trajetória";
L["AM_TOOLBAR_TTD_ADD_TRACK"] = "Adicionar Trajetória:\n - Criar uma nova trajetória de animação e atribuí-la ao objeto de cena selecionado\n - Um objeto na cena requer uma trajetória para executar\nqualquer animação nele.\n - Qualquer objeto só pode ter uma trajetória atribuída a ele";
L["AM_TOOLBAR_TT_REMOVE_TRACK"] = "Excluir Trajetória";
L["AM_TOOLBAR_TT_ADD_ANIMATION"] = "Adicionar Animação";
L["AM_TOOLBAR_TTD_ADD_ANIMATION"] = "Adicionar Animação:\n - Adicionar um clipe de animação à trajetória/objeto selecionado atualmente\n - Abre a janela Lista de Animações onde você pode selecionar um clipe disponível";
L["AM_TOOLBAR_TT_REMOVE_ANIMATION"] = "Excluir Animação";
L["AM_TOOLBAR_TT_ADD_KEYFRAME"] = "Adicionar Keyframe";
L["AM_TOOLBAR_TTD_ADD_KEYFRAME"] = "Adicionar Keyframe:\n - Adicionar um keyframe no tempo atual.\n - Pressione para alternar entre:\n    1. Adicionar keyframe para todas as transformações;\n    2. Adicionar keyframe apenas para posição;\n    3. Adicionar keyframe apenas para rotação;\n    4. Adicionar keyframe apenas para escala;";
L["AM_TOOLBAR_TT_SET_INTERPOLATION_IN"] = "Definir Interpolação na Entrada";
L["AM_TOOLBAR_TTD_SET_INTERPOLATION_IN"] = "Definir Interpolação na Entrada:\n - Definir o modo de interpolação do keyframe atual na entrada (lado esquerdo).\n - Pressione para alternar entre:\n    1. Suave\n    2. Linear\n    3. Degrau\n    4. Lento\n    5. Rápido\n";
L["AM_TOOLBAR_TT_SET_INTERPOLATION_OUT"] = "Definir Interpolação na Saída";
L["AM_TOOLBAR_TTD_SET_INTERPOLATION_OUT"] = "Definir Interpolação na Saída:\n - Definir o modo de interpolação do keyframe atual na saída (lado direito).\n - Pressione para alternar entre:\n    1. Suave\n    2. Linear\n    3. Degrau\n    4. Lento\n    5. Rápido\n";
L["AM_TOOLBAR_TT_REMOVE_KEYFRAME"] = "Excluir Keyframe";
L["AM_TOOLBAR_TT_SEEK_TO_START"] = "Ir para o Início";
L["AM_TOOLBAR_TT_SKIP_FRAME_BACK"] = "Ir para o quadro anterior";
L["AM_TOOLBAR_TT_PLAY_PAUSE"] = "Reproduzir / Pausar";
L["AM_TOOLBAR_TT_SKIP_FRAME_FORWARD"] = "Ir para o próximo quadro";
L["AM_TOOLBAR_TT_SEEK_TO_END"] = "Ir para o Fim";
L["AM_TOOLBAR_TT_LOOP"] = "Repetir Reprodução ligado/desligado";
L["AM_TOOLBAR_TT_PLAYCAMERA"] = "Reprodução de Câmera ligado/desligado";
L["AM_TT_LIST"] = "Selecionar Sequência";
L["AM_TT_ADDTIMELINE"] = "Adicionar Sequência";
L["AM_RMB_CHANGE_ANIM"] = "Alterar Animação";
L["AM_RMB_SET_ANIM_SPEED"] = "Definir Velocidade da Animação";
L["AM_RMB_DELETE_ANIM"] = "Excluir Animação";
L["AM_RMB_DIFFERENT_COLOR"] = "Cor Diferente";
L["AM_SET_ANIMATION_SPEED_PERCENT"] = "Definir Velocidade da Animação %";
L["AM_TIMER_SET_DURATION"] = "Definir Duração da Sequência";

-- AssetBrowser/AssetExplorer --
L["AB_RESULTS"] = "%d Resultados"; -- <número> resultados (resultados da pesquisa)
L["AB_BREADCRUMB"] = "..."; -- para um caminho de arquivo
L["AB_TOOLBAR_TT_UP_ONE_FOLDER"] = "Voltar uma pasta.";
L["AM_MSG_REMOVE_COLLECTION_TITLE"] = "Remover Coleção";
L["AB_MSG_REMOVE_COLLECTION_MESSAGE"] = "A coleção contém itens, tem certeza de que deseja removê-la?";
L["AB_TOOLBAR_TT_NEW_COLLECTION"] = "Nova Coleção";
L["AB_TOOLBAR_TT_REMOVE_COLLECTION"] = "Remover Coleção";
L["AB_TOOLBAR_TT_RENAME_COLLECTION"] = "Renomear Coleção";
L["AB_TOOLBAR_TT_ADD_OBJECT"] = "Adicionar Objeto Selecionado";
L["AB_TOOLBAR_TT_REMOVE_OBJECT"] = "Remover Objeto";
L["AB_TOOLBAR_TT_IMPORT_COLLECTION"] = "Importar Coleção";
L["AB_TOOLBAR_TT_EXPORT_COLLECTION"] = "Exportar Coleção";
L["AB_RMB_FILE_INFO"] = "Informações do Arquivo";
L["AB_RMB_ADD_TO_COLLECTION"] = "Adicionar à Coleção";
L["AB_COLLECTION_NAME"] = "Nome da Coleção";
L["AB_COLLECTION_RENAME"] = "Renomear Coleção";
L["AB_TAB_MODELS"] = "Modelos";
L["AB_TAB_CREATURES"] = "Criaturas";
L["AB_TAB_COLLECTIONS"] = "Coleções";
L["AB_TAB_DEBUG"] = "Depuração";

-- Project Manager --
L["PM_WINDOW_TITLE"] = "Gerenciador de Projetos";
L["PM_PROJECT_NAME"] = "Nome do Projeto";
L["PM_NEW_PROJECT"] = "Novo Projeto";
L["PM_EDIT_PROJECT"] = "Editar Projeto";
L["PM_MSG_DELETE_PROJECT_TITLE"] = "Excluir Projeto";
L["PM_MSG_DELETE_PROJECT_MESSAGE"] = "Excluir o projeto também excluirá todas as suas cenas e dados, deseja continuar?";
L["PM_BUTTON_NEW_PROJECT"] = "Novo Projeto";
L["PM_BUTTON_LOAD_PROJECT"] = "Carregar Projeto";
L["PM_BUTTON_EDIT_PROJECT"] = "Editar Projeto";
L["PM_BUTTON_REMOVE_PROJECT"] = "Remover Projeto";
L["PM_BUTTON_SAVE_DATA"] = "Salvar Dados";

-- Scene Manager --
L["SM_SCENE"] = "Cena %d";                 -- número da cena
L["SM_MSG_DELETE_SCENE_TITLE"] = "Excluir Cena";
L["SM_MSG_DELETE_SCENE_MESSAGE"] = "Tem certeza de que deseja continuar?";
L["SM_SCENE_NAME"] = "Nome da Cena";
L["SM_TT_LIST"] = "Selecionar cena";
L["SM_TT_ADDSCENE"] = "Adicionar Cena";
L["SM_EXIT_CAMERA"] = "Sair da Câmera";

-- Object Properties --
L["OP_TITLE"] = "Propriedades";
L["OP_TRANSFORM"] = "Transformar";
L["OP_ACTOR_PROPERTIES"] = "Propriedades do Ator";
L["OP_SCENE_PROPERTIES"] = "Propriedades da Cena";
L["OP_AMBIENT_COLOR"] = "Cor Ambiente";
L["OP_DIFFUSE_COLOR"] = "Cor Difusa";
L["OP_BACKGROUND_COLOR"] = "Cor de Fundo";
L["OP_TT_RESET_VALUE"] = "Redefinir valor para o padrão";
L["OP_TT_X_FIELD"] = "X";
L["OP_TT_Y_FIELD"] = "Y";
L["OP_TT_Z_FIELD"] = "Z";
L["OP_ENABLE_LIGHTING"] = "Ativar Iluminação";
L["OP_CAMERA_PROPERTIES"] = "Propriedades da Câmera";
L["FOV"] = "Campo de Visão";
L["NEARCLIP"] = "Plano Próximo";
L["FARCLIP"] = "Plano Distante";

-- Scene Hierarchy --
L["SH_TITLE"] = "Hierarquia da Cena";

-- Color Picker --
L["COLP_WINDOW_TITLE"] = "Seletor de Cores";
L["COLP_RGB_NAME"] = "RGB (Vermelho/Verde/Azul):";
L["COLP_HSL_NAME"] = "HSL (Matiz/Saturação/Luminosidade):";
L["COLP_R"] = "V";  -- Vermelho
L["COLP_G"] = "Vd";  -- Verde
L["COLP_B"] = "Az";  -- Azul
L["COLP_H"] = "M";  -- Matiz
L["COLP_S"] = "S";  -- Saturação
L["COLP_L"] = "L";  -- Luminosidade

-- About Screen --
L["ABOUT_WINDOW_TITLE"] = "Máquina de Cena";
L["ABOUT_VERSION"] = "Versão %s";
L["ABOUT_DESCRIPTION"] = "A Máquina de Cena é uma ferramenta para criar e editar cenas 3D usando modelos disponíveis no jogo. Ela utiliza a API ModelScene como base, sendo assim, algumas limitações se aplicam.";
L["ABOUT_LICENSE"] = "Licenciado sob a Licença MIT";
L["ABOUT_AUTHOR"] = "Autor: %s";
L["ABOUT_CONTACT"] = "Contato: %s";

-- Settings window --
L["SETTINGS_WINDOW_TITLE"] = "Configurações";
L["SETTINGS_TAB_GENERAL"] = "Geral";
L["SETTINGS_TAB_GIZMOS"] = "Gizmos";
L["SETTINGS_TAB_DEBUG"] = "Depuração";
L["SETTINGS_EDITOR_SCALE"] = "Escala do Editor";
L["SETTINGS_SHOW_SELECTION_HIGHLIGHT"] = "Mostrar destaque da seleção";
L["SETTINGS_HIDE_PARALLEL_GIZMOS"] = "Ocultar gizmos de tradução paralelos à câmera";
L["SETTINGS_ALWAYS_SHOW_CAM_GIZMO"] = "Sempre mostrar gizmo da câmera";
L["SETTINGS_GIZMO_SIZE"] = "Tamanho do gizmo";
L["SETTINGS_SHOW_DEBUG_TAB"] = "Mostrar aba de Depuração no Navegador de Ativos";

-- Error Messages --
L["DECODE_FAILED"] = "Falha ao decodificar os dados.";
L["DECOMPRESS_FAILED"] = "Falha ao descomprimir os dados.";
L["DESERIALIZE_FAILED"] = "Falha ao desserializar os dados.";
L["DATA_VERSION_TOO_NEW"] = "Detectada versão mais recente dos dados, que não é suportada. Por favor, atualize o SceneMachine.";

