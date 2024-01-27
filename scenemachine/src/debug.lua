--------------------------------------------------
-- Debug ~ don't ship file with build ~
--------------------------------------------------

Debug = {};
local Gizmos = SceneMachine.Gizmos;
local Renderer = SceneMachine.Renderer;
local Vector3 = SceneMachine.Vector3;

local linePoolSize = 100;

function Debug.Init()
    Debug.HideGameUI();
	Debug.linePool = {};

	local lineProjectionFrame = Debug.CreateLineProjectionFrame()

	for t = 1, linePoolSize, 1 do
		Debug.linePool[t] = lineProjectionFrame:CreateLine(nil, nil, nil);
        Debug.linePool[t]:SetThickness(5.5);
        Debug.linePool[t]:SetTexture("Interface\\Addons\\scenemachine\\static\\textures\\line.png", "REPEAT", "REPEAT", "NEAREST");
	end
end

function Debug.CreateLineProjectionFrame()
	local lineProjectionFrame = CreateFrame("Frame", "lineProjectionFrame", Renderer.projectionFrame)
	lineProjectionFrame:SetFrameStrata("BACKGROUND");
	lineProjectionFrame:SetWidth(Renderer.w);
	lineProjectionFrame:SetHeight(Renderer.h);
	lineProjectionFrame:SetPoint("TOPRIGHT", Renderer.projectionFrame, "TOPRIGHT", 0, 0);
	lineProjectionFrame.texture = lineProjectionFrame:CreateTexture("Renderer.lineProjectionFrame.texture", "ARTWORK")
	lineProjectionFrame.texture:SetColorTexture(0,0,0,0);
	lineProjectionFrame.texture:SetAllPoints(Renderer.lineProjectionFrame);
	lineProjectionFrame:SetFrameLevel(201);
    lineProjectionFrame:Show();
    return lineProjectionFrame;
end

-- Hide unnecesary game UI for debugging --
function Debug.HideGameUI()
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
end

function Debug.TablePrint(table)
	local indent = 4;
	local toprint = string.rep(" ", indent) .. "{\r\n"
	indent = indent + 2
	for k, v in pairs(tbl) do
		toprint = toprint .. string.rep(" ", indent)
		if (type(k) == "number") then
			toprint = toprint .. "[" .. k .. "] = "
		elseif (type(k) == "string") then
			toprint = toprint  .. k ..  "= "   
		end
		if (type(v) == "number") then
			toprint = toprint .. v .. ",\r\n"
		elseif (type(v) == "string") then
			toprint = toprint .. "\"" .. v .. "\",\r\n"
		elseif (type(v) == "table") then
			toprint = toprint .. tprint(v, indent + 2) .. ",\r\n"
		else
			toprint = toprint .. "\"" .. tostring(v) .. "\",\r\n"
		end
	end
	toprint = toprint .. string.rep(" ", indent-2) .. "}"
	print(toprint)
end

function Debug.DrawRay(ray, length, R, G, B, A)
	length = length or 1;
	Debug.DrawLine(ray.origin, Vector3:New(
		ray.origin.x + (ray.direction.x * length),
		ray.origin.y + (ray.direction.y * length),
		ray.origin.z + (ray.direction.z * length)), R, G, B, A);
end

function Debug.ClearLines()
	for t = 1, linePoolSize, 1 do
		Debug.linePool[t].visible = false;
	end
end

function Debug.DrawLine(pointA, pointB, R, G, B, A)
	R = R or 1;
	G = G or 1;
	B = B or 1;
	A = A or 1;
	local line = Debug.GetAvailableLineFromPool();
	line.Ax = pointA.x;
	line.Ay = pointA.y;
	line.Az = pointA.z;
	line.Bx = pointB.x;
	line.By = pointB.y;
	line.Bz = pointB.z;
	line.R = R;
	line.G = G;
	line.B = B;
	line.A = A;
	line.visible = true;
end

function Debug.GetAvailableLineFromPool()
	for t = 1, linePoolSize, 1 do
		if (Debug.linePool[t].visible == false) then
			return Debug.linePool[t];
		end
	end

	return Debug.linePool[1];
end

function Debug.FlushLinePool()
	for t = 1, linePoolSize, 1 do
		if (Debug.linePool[t].visible == true) then
			local line = Debug.linePool[t];

			local aX, aY, aZ = Renderer.projectionFrame:Project3DPointTo2D(line.Ax, line.Ay, line.Az);
			local bX, bY, bZ = Renderer.projectionFrame:Project3DPointTo2D(line.Bx, line.By, line.Bz);
		
			-- Render --
			if (aX ~= nil and aY ~= nil and bX ~= nil and bY ~= nil) then
				line:Show();
				line:SetVertexColor(line.R, line.G, line.B, line.A);
				line:SetStartPoint("BOTTOMLEFT", aX, aY) -- start topleft
				line:SetEndPoint("BOTTOMLEFT", bX, bY)   -- end bottomright
			end
		end
	end
end