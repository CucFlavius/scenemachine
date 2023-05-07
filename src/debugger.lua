--------------------------------------------------
-- ZEngine Debugger							--
--------------------------------------------------

-- Hide unnecesary game UI for debugging --

-- Chat Frame
--local z_wgs_debug_chat = DEFAULT_CHAT_FRAME
--z_wgs_debug_chat:SetScript("OnShow", z_wgs_debug_chat.Hide)
--z_wgs_debug_chat:Hide()

local z_wgs_debug_dock = GeneralDockManager
z_wgs_debug_dock:SetScript("OnShow", z_wgs_debug_dock.Hide)
z_wgs_debug_dock:Hide()
local z_wgs_debug_cfmb = ChatFrameMenuButton
z_wgs_debug_cfmb:SetScript("OnShow", z_wgs_debug_cfmb.Hide)
z_wgs_debug_cfmb:Hide()
local z_wgs_debug_cfcb = ChatFrameChannelButton
z_wgs_debug_cfcb:SetScript("OnShow", z_wgs_debug_cfcb.Hide)
z_wgs_debug_cfcb:Hide()
local z_wgs_debug_qjtb = QuickJoinToastButton
z_wgs_debug_qjtb:SetScript("OnShow", z_wgs_debug_qjtb.Hide)
z_wgs_debug_qjtb:Hide()

-- Spell Bar
local z_wgs_debug_mmb = MainMenuBar
z_wgs_debug_mmb:SetScript("OnShow", z_wgs_debug_mmb.Hide)
z_wgs_debug_mmb:Hide()

-- Player Frame
local z_wgs_debug_pf = PlayerFrame
z_wgs_debug_pf:SetScript("OnShow", z_wgs_debug_pf.Hide)
z_wgs_debug_pf:Hide()

-- Quests Tracker
local z_wgs_debug_otf = ObjectiveTrackerFrame
z_wgs_debug_otf:SetScript("OnShow", z_wgs_debug_otf.Hide)
z_wgs_debug_otf:Hide()

-- Exp Bar
local z_wgs_debug_ebr = MainStatusTrackingBarContainer
z_wgs_debug_ebr:SetScript("OnShow", z_wgs_debug_otf.Hide)
z_wgs_debug_ebr:Hide()

--local z_wgs_debug_mmc = Minimap
--z_wgs_debug_mmc:SetScript("OnShow",
-- z_wgs_debug_mmc:SetVertexOffset(1, 0, 0)
--);