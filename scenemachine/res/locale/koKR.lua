local AceLocale = LibStub("AceLocale-3.0");
local L = AceLocale:NewLocale("SceneMachine", "koKR", false);
if not L then return end

-- General --
L["YES"] = "예";
L["NO"] = "아니요";
L["POSITION"] = "위치";
L["ROTATION"] = "회전";
L["SCALE"] = "크기";
L["ALPHA"] = "투명도";
L["DESATURATION"] = "채도 줄이기";
L["SEARCH"] = "검색";
L["RENAME"] = "이름 바꾸기";
L["EDIT"] = "편집";
L["DELETE"] = "삭제";
L["BUTTON_SAVE"] = "저장";
L["BUTTON_CANCEL"] = "취소";
L["EXPORT"] = "내보내기";
L["IMPORT"] = "가져오기";
L["SCROLL_TOP"] = "맨 위로 이동";
L["SCROLL_BOTTOM"] = "맨 아래로 이동";
L["LOAD"] = "불러오기";

-- Editor --
L["ADDON_NAME"] = "Scene Machine";
L["EDITOR_MAIN_WINDOW_TITLE"] = "Scene Machine %s - %s"; -- Scene Machine <version> - <current project name>
L["EDITOR_MSG_DELETE_OBJECT_TITLE"] = "오브젝트 삭제";
L["EDITOR_MSG_DELETE_OBJECT_MESSAGE"] = "오브젝트에는 애니메이션 트랙이 포함되어 있습니다. 삭제하시겠습니까?";
L["EDITOR_MSG_DELETE_TRACK_TITLE"] = "트랙 삭제";
L["EDITOR_MSG_DELETE_TRACK_A_K_MESSAGE"] = "트랙에 애니메이션과 키프레임이 포함되어 있습니다. 삭제하시겠습니까?";
L["EDITOR_MSG_DELETE_TRACK_A_MESSAGE"] = "트랙에 애니메이션이 포함되어 있습니다. 삭제하시겠습니까?";
L["EDITOR_MSG_DELETE_TRACK_K_MESSAGE"] = "트랙에 키프레임이 포함되어 있습니다. 삭제하시겠습니까?";
L["EDITOR_MSG_SAVE_TITLE"] = "저장";
L["EDITOR_MSG_SAVE_MESSAGE"] = "저장하려면 UI를 다시 불러와야 합니다. 계속하시겠습니까?";
L["EDITOR_SCENESCRIPT_WINDOW_TITLE"] = "장면스크립트 가져오기";
L["EDITOR_TOOLBAR_TT_OPEN_PROJECT_MANAGER"] = "프로젝트 매니저 열기";
L["EDITOR_TOOLBAR_TT_PROJECT_LIST"] = "프로젝트 변경";
L["EDITOR_TOOLBAR_TT_SELECT_TOOL"] = "도구 선택";
L["EDITOR_TOOLBAR_TT_MOVE_TOOL"] = "이동 도구";
L["EDITOR_TOOLBAR_TT_ROTATE_TOOL"] = "회전 도구";
L["EDITOR_TOOLBAR_TT_SCALE_TOOL"] = "크기 조절 도구";
L["EDITOR_TOOLBAR_TT_PIVOT_LOCAL_SPACE"] = "로컬 스페이스 피벗";
L["EDITOR_TOOLBAR_TT_PIVOT_WORLD_SPACE"] = "월드 스페이스 피벗";
L["EDITOR_TOOLBAR_TT_PIVOT_CENTER"] = "가운데 피벗";
L["EDITOR_TOOLBAR_TT_PIVOT_BASE"] = "기준 피벗";
L["EDITOR_IMPORT_EXPORT_WINDOW_TITLE"] = "가져오기 - 내보내기";
L["EDITOR_NAME_RENAME_WINDOW_TITLE"] = "이름 변경";
L["EDITOR_TOOLBAR_TT_MULTITRANSFORM_TOGETHER"] = "함께 변형";
L["EDITOR_TOOLBAR_TT_MULTITRANSFORM_INDIVIDUAL"] = "개별 변형";
L["EDITOR_TOOLBAR_TT_UNDO"] = "실행 취소";
L["EDITOR_TOOLBAR_TT_REDO"] = "다시 실행";
L["EDITOR_TOOLBAR_TT_CREATE_CAMERA"] = "카메라 생성";
L["EDITOR_TOOLBAR_TT_CREATE_CHARACTER"] = "캐릭터 생성";
L["EDITOR_FULLSCREEN_NOTIFICATION"] = "전체 화면 모드로 진입했습니다.\nESC를 눌러 종료하거나 P를 눌러 재생/일시정지하세요.";
L["EDITOR_TOOLBAR_TT_LETTERBOX_ON"] = "레터박스 숨기기 (검은 막대)";
L["EDITOR_TOOLBAR_TT_LETTERBOX_OFF"] = "레터박스 보이기 (검은 막대)";
L["EDITOR_TOOLBAR_TT_FULLSCREEN"] = "전체 화면으로 진입";

-- Main Menu --
L["MM_FILE"] = "파일";
L["MM_EDIT"] = "편집";
L["MM_OPTIONS"] = "옵션";
L["MM_HELP"] = "도움말";
L["MM_PROJECT_MANAGER"] = "프로젝트 매니저";
L["MM_IMPORT_SCENESCRIPT"] = "씬스크립트 가져오기";
L["MM_SAVE"] = "저장";
L["MM_CLONE_SELECTED"] = "선택 복제";
L["MM_DELETE_SELECTED"] = "선택 삭제";
L["MM_SET_SCALE"] = "크기 설정 %s";
L["MM_KEYBOARD_SHORTCUTS"] = "키보드 단축키";
L["MM_ABOUT"] = "정보";
L["MM_SCENE"] = "씬";
L["MM_SCENE_NEW"] = "새로 만들기";
L["MM_SCENE_REMOVE"] = "삭제";
L["MM_SCENE_RENAME"] = "이름 바꾸기";
L["MM_SCENE_EXPORT"] = "내보내기";
L["MM_SCENE_IMPORT"] = "가져오기";
L["MM_TITLE_SCENE_NAME"] = "씬 이름";
L["MM_TITLE_SCENE_RENAME"] = "씬 이름 변경";
L["MM_SETTINGS"] = "설정";

-- Context Menu --
L["CM_SELECT"] = "선택";
L["CM_MOVE"] = "이동";
L["CM_ROTATE"] = "회전";
L["CM_SCALE"] = "크기 조절";
L["CM_DELETE"] = "삭제";
L["CM_HIDE_SHOW"] = "숨기기/표시";
L["CM_HIDE"] = "숨기기";
L["CM_SHOW"] = "표시";
L["CM_FREEZE_UNFREEZE"] = "고정/해제";
L["CM_FREEZE"] = "고정";
L["CM_UNFREEZE"] = "해제";
L["CM_RENAME"] = "이름 바꾸기";
L["CM_FOCUS"] = "포커스";
L["CM_GROUP"] = "그룹";

-- Animation Manager --
L["AM_ANIMATION_LIST_WINDOW_TITLE"] = "애니메이션 목록";
L["AM_TIMELINE"] = "타임라인 %d";           -- 타임라인 번호
L["AM_MSG_DELETE_TIMELINE_TITLE"] = "타임라인 삭제";
L["AM_MSG_DELETE_TIMELINE_MESSAGE"] = "진행하시겠습니까?";
L["AM_MSG_NO_TRACK_TITLE"] = "트랙 없음";
L["AM_MSG_NO_TRACK_MESSAGE"] = "객체에 애니메이션 트랙이 없습니다. 추가하시겠습니까?";
L["AM_BUTTON_ADD_ANIMATION"] = "애니메이션 추가";
L["AM_BUTTON_CHANGE_ANIMATION"] = "애니메이션 변경";
L["AM_TIMELINE_NAME"] = "타임라인 이름";
L["AM_TOOLBAR_TRACKS"] = "트랙";
L["AM_TOOLBAR_KEYFRAMES"] = "키프레임";
L["AM_TOOLBAR_CURVES"] = "곡선 (디버그용)";
L["AM_TOOLBAR_TT_UIMODE"] = "애니메이션 모드 전환";
L["AM_TOOLBAR_TTD_UIMODE"] = "애니메이션 모드 전환:\n 1. 트랙 보기 - 다른 객체 트랙 관리, 모델 애니메이션 및 키프레임 추가\n 2. 키프레임 보기 - 키프레임에 대한 고급 제어\n 3. 곡선 보기 - (아직 구현되지 않음 - 현재 디버깅 용도로만 사용)\n";
L["AM_TOOLBAR_TT_ADD_TRACK"] = "트랙 추가";
L["AM_TOOLBAR_TTD_ADD_TRACK"] = "트랙 추가:\n - 새로운 애니메이션 트랙을 생성하고 선택된 씬 객체에 할당\n - 임의 객체에 애니메이션을 수행하려면 트랙이 필요\n - 모든 객체는 하나의 트랙만 할당할 수 있음";
L["AM_TOOLBAR_TT_REMOVE_TRACK"] = "트랙 삭제";
L["AM_TOOLBAR_TT_ADD_ANIMATION"] = "애니메이션 추가";
L["AM_TOOLBAR_TTD_ADD_ANIMATION"] = "애니메이션 추가:\n - 현재 선택된 트랙/객체에 애니메이션 클립 추가\n - 사용 가능한 클립을 선택할 수 있는 애니메이션 목록 창 열기";
L["AM_TOOLBAR_TT_REMOVE_ANIMATION"] = "애니메이션 삭제";
L["AM_TOOLBAR_TT_ADD_KEYFRAME"] = "키프레임 추가";
L["AM_TOOLBAR_TTD_ADD_KEYFRAME"] = "키프레임 추가:\n - 현재 시간에 키프레임 추가\n - 다음 사항을 전환하려면 클릭 유지:\n   1. 모든 변환에 키프레임 추가\n   2. 위치만 키프레임 추가\n   3. 회전만 키프레임 추가\n   4. 크기만 키프레임 추가";
L["AM_TOOLBAR_TT_SET_INTERPOLATION_IN"] = "인터폴레이션 시작 설정";
L["AM_TOOLBAR_TTD_SET_INTERPOLATION_IN"] = "인터폴레이션 시작 설정:\n - 현재 키프레임의 시작(왼쪽) 인터폴레이션 모드 설정\n - 클릭 유지하여 전환:\n   1. 부드러움\n   2. 선형\n   3. 단계\n   4. 느림\n   5. 빠름";
L["AM_TOOLBAR_TT_SET_INTERPOLATION_OUT"] = "인터폴레이션 종료 설정";
L["AM_TOOLBAR_TTD_SET_INTERPOLATION_OUT"] = "인터폴레이션 종료 설정:\n - 현재 키프레임의 종료(오른쪽) 인터폴레이션 모드 설정\n - 클릭 유지하여 전환:\n   1. 부드러움\n   2. 선형\n   3. 단계\n   4. 느림\n   5. 빠름";
L["AM_TOOLBAR_TT_REMOVE_KEYFRAME"] = "키프레임 삭제";
L["AM_TOOLBAR_TT_SEEK_TO_START"] = "시작 위치로 이동";
L["AM_TOOLBAR_TT_SKIP_FRAME_BACK"] = "이전 프레임으로 이동";
L["AM_TOOLBAR_TT_PLAY_PAUSE"] = "재생 / 일시정지";
L["AM_TOOLBAR_TT_SKIP_FRAME_FORWARD"] = "다음 프레임으로 이동";
L["AM_TOOLBAR_TT_SEEK_TO_END"] = "끝 위치로 이동";
L["AM_TOOLBAR_TT_LOOP"] = "반복 재생 켜기/끄기";
L["AM_TOOLBAR_TT_PLAYCAMERA"] = "카메라 재생 켜기/끄기";
L["AM_TT_LIST"] = "타임라인 선택";
L["AM_TT_ADDTIMELINE"] = "타임라인 추가";
L["AM_RMB_CHANGE_ANIM"] = "애니메이션 변경";
L["AM_RMB_SET_ANIM_SPEED"] = "애니메이션 속도 설정";
L["AM_RMB_DELETE_ANIM"] = "애니메이션 삭제";
L["AM_RMB_DIFFERENT_COLOR"] = "다른 색상";
L["AM_SET_ANIMATION_SPEED_PERCENT"] = "애니메이션 속도 % 설정";
L["AM_TIMER_SET_DURATION"] = "타임라인 지속 시간 설정";

-- AssetBrowser/AssetExplorer --
L["AB_RESULTS"] = "%d 결과";             -- <number> 결과 (검색 결과)
L["AB_BREADCRUMB"] = "...";             -- 파일 경로를 위한
L["AB_TOOLBAR_TT_UP_ONE_FOLDER"] = "한 단계 위로 이동";
L["AM_MSG_REMOVE_COLLECTION_TITLE"] = "컬렉션 제거";
L["AB_MSG_REMOVE_COLLECTION_MESSAGE"] = "컬렉션에 항목이 포함되어 있습니다. 정말로 제거하시겠습니까?";
L["AB_TOOLBAR_TT_NEW_COLLECTION"] = "새로운 컬렉션";
L["AB_TOOLBAR_TT_REMOVE_COLLECTION"] = "컬렉션 제거";
L["AB_TOOLBAR_TT_RENAME_COLLECTION"] = "컬렉션 이름 바꾸기";
L["AB_TOOLBAR_TT_ADD_OBJECT"] = "선택한 항목 추가";
L["AB_TOOLBAR_TT_REMOVE_OBJECT"] = "항목 제거";
L["AB_TOOLBAR_TT_IMPORT_COLLECTION"] = "컬렉션 가져오기";
L["AB_TOOLBAR_TT_EXPORT_COLLECTION"] = "컬렉션 내보내기";
L["AB_RMB_FILE_INFO"] = "파일 정보";
L["AB_RMB_ADD_TO_COLLECTION"] = "컬렉션에 추가";
L["AB_COLLECTION_NAME"] = "컬렉션 이름";
L["AB_COLLECTION_RENAME"] = "컬렉션 이름 변경";
L["AB_TAB_MODELS"] = "모델";
L["AB_TAB_CREATURES"] = "생물";
L["AB_TAB_COLLECTIONS"] = "컬렉션";
L["AB_TAB_DEBUG"] = "디버그";

-- Project Manager --
L["PM_WINDOW_TITLE"] = "프로젝트 매니저";
L["PM_PROJECT_NAME"] = "프로젝트 이름";
L["PM_NEW_PROJECT"] = "새 프로젝트";
L["PM_EDIT_PROJECT"] = "프로젝트 편집";
L["PM_MSG_DELETE_PROJECT_TITLE"] = "프로젝트 삭제";
L["PM_MSG_DELETE_PROJECT_MESSAGE"] = "프로젝트를 삭제하면 모든 씬과 데이터도 함께 삭제됩니다. 계속하시겠습니까?";
L["PM_BUTTON_NEW_PROJECT"] = "새 프로젝트";
L["PM_BUTTON_LOAD_PROJECT"] = "프로젝트 불러오기";
L["PM_BUTTON_EDIT_PROJECT"] = "프로젝트 편집";
L["PM_BUTTON_REMOVE_PROJECT"] = "프로젝트 제거";
L["PM_BUTTON_SAVE_DATA"] = "데이터 저장";

-- Scene Manager --
L["SM_SCENE"] = "장면 %d"; -- 장면 번호
L["SM_MSG_DELETE_SCENE_TITLE"] = "장면 삭제";
L["SM_MSG_DELETE_SCENE_MESSAGE"] = "계속하시겠습니까?";
L["SM_SCENE_NAME"] = "장면 이름";
L["SM_TT_LIST"] = "장면 선택";
L["SM_TT_ADDSCENE"] = "장면 추가";
L["SM_EXIT_CAMERA"] = "카메라 나가기";

-- Object Properties --
L["OP_TITLE"] = "속성";
L["OP_TRANSFORM"] = "변형";
L["OP_ACTOR_PROPERTIES"] = "엑터 속성";
L["OP_SCENE_PROPERTIES"] = "장면 속성";
L["OP_AMBIENT_COLOR"] = "주변색상";
L["OP_DIFFUSE_COLOR"] = "확산색상";
L["OP_BACKGROUND_COLOR"] = "배경색상";
L["OP_TT_RESET_VALUE"] = "기본값으로 재설정";
L["OP_TT_X_FIELD"] = "X";
L["OP_TT_Y_FIELD"] = "Y";
L["OP_TT_Z_FIELD"] = "Z";
L["OP_ENABLE_LIGHTING"] = "조명 활성화";
L["OP_CAMERA_PROPERTIES"] = "카메라 속성";
L["FOV"] = "시야각";
L["NEARCLIP"] = "근접 클립";
L["FARCLIP"] = "원거리 클립";

-- Scene Hierarchy --
L["SH_TITLE"] = "씬 계층 구조";

-- Color Picker --
L["COLP_WINDOW_TITLE"] = "색 선택기";
L["COLP_RGB_NAME"] = "RGB (빨강/녹색/파랑):";
L["COLP_HSL_NAME"] = "HSL (색조/채도/명도):";
L["COLP_R"] = "R";  -- 빨강
L["COLP_G"] = "G";  -- 녹색
L["COLP_B"] = "B";  -- 파랑
L["COLP_H"] = "H";  -- 색조
L["COLP_S"] = "S";  -- 채도
L["COLP_L"] = "L";  -- 명도

-- About Screen --
L["ABOUT_WINDOW_TITLE"] = "씬 머신";
L["ABOUT_VERSION"] = "버전 %s";
L["ABOUT_DESCRIPTION"] = "씬 머신은 게임 내 모델을 사용하여 3D 씬을 만들고 편집하는 도구입니다. ModelScene API를 기반으로 사용하기 때문에 일부 제한 사항이 적용됩니다.";
L["ABOUT_LICENSE"] = "MIT 라이선스에 따라 라이선스가 부여됨";
L["ABOUT_AUTHOR"] = "저자: %s";
L["ABOUT_CONTACT"] = "문의: %s";

-- Settings window --
L["SETTINGS_WINDOW_TITLE"] = "설정";
L["SETTINGS_TAB_GENERAL"] = "일반";
L["SETTINGS_TAB_GIZMOS"] = "기즈모";
L["SETTINGS_TAB_DEBUG"] = "디버그";
L["SETTINGS_EDITOR_SCALE"] = "에디터 크기";
L["SETTINGS_SHOW_SELECTION_HIGHLIGHT"] = "선택 강조 표시";
L["SETTINGS_HIDE_PARALLEL_GIZMOS"] = "카메라와 평행한 이동 기즈모 숨기기";
L["SETTINGS_ALWAYS_SHOW_CAM_GIZMO"] = "카메라 기즈모 항상 표시";
L["SETTINGS_GIZMO_SIZE"] = "기즈모 크기";
L["SETTINGS_SHOW_DEBUG_TAB"] = "에셋 브라우저에서 디버그 탭 표시";

-- Error Messages --
L["DECODE_FAILED"] = "데이터를 해독하는 데 실패했습니다.";
L["DECOMPRESS_FAILED"] = "데이터를 압축 해제하는 데 실패했습니다.";
L["DESERIALIZE_FAILED"] = "데이터 역직렬화에 실패했습니다.";
L["DATA_VERSION_TOO_NEW"] = "더 최신 데이터 버전이 감지되었으며 지원되지 않습니다. SceneMachine을 업데이트해주세요.";

