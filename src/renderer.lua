SceneMachine.Editor = SceneMachine.Editor or {};
SceneMachine.Renderer = SceneMachine.Renderer or {}
SceneMachine.World = SceneMachine.World or {}
SceneMachine.Gizmos = SceneMachine.Gizmos or {};
local Editor = SceneMachine.Editor;
Editor.SceneManager = Editor.SceneManager or {};
local SM = Editor.SceneManager;
local Gizmos = SceneMachine.Gizmos;
local Renderer = SceneMachine.Renderer;
local Camera = SceneMachine.Camera;
local World = SceneMachine.World;
local FX = SceneMachine.FX;
local Input = SceneMachine.Input;

--- WTF ---
local sqrt = math.sqrt;
local floor = math.floor;

Renderer.FrameBufferSize = 400;
Renderer.FrameBufferFrames = {};
Renderer.actors = {};

function Renderer.GenerateFrameBuffer()

	for t = 1, Renderer.FrameBufferSize, 1 do
		Renderer.FrameBufferFrames[t] = CreateFrame("Frame", "Renderer.FramebufferFrame_" .. t, Renderer.projectionFrame)
		Renderer.FrameBufferFrames[t]:SetFrameStrata("BACKGROUND");
        Renderer.FrameBufferFrames[t]:SetFrameLevel(100);
		Renderer.FrameBufferFrames[t]:SetWidth(SceneMachine.WINDOW_WIDTH)
		Renderer.FrameBufferFrames[t]:SetHeight(SceneMachine.WINDOW_HEIGHT)
		Renderer.FrameBufferFrames[t].texture = Renderer.FrameBufferFrames[t]:CreateTexture("Renderer.FramebufferFrame_" .. t ..".texture", "ARTWORK")
		Renderer.FrameBufferFrames[t].texture:SetVertexColor(1,1,1)
        Renderer.FrameBufferFrames[t].texture:SetAllPoints(Renderer.FrameBufferFrames[t])
		--Renderer.FrameBufferFrames[t].texture:SetTexture(World.TerrainTexture, "REPEAT", "REPEAT", "NEAREST");
		--Renderer.FrameBufferFrames[t].texture:SetTexCoord(0, 0.125, 0.125, 0.25);
		Renderer.FrameBufferFrames[t].texture:SetColorTexture(1,1,1,1);
        
        Renderer.FrameBufferFrames[t]:EnableMouse(true);
        Renderer.FrameBufferFrames[t]:SetScript('OnEnter', function() print("Enter " .. t) end);
        Renderer.FrameBufferFrames[t]:SetScript('OnLeave', function() print("Exit " .. t) end);
		Renderer.FrameBufferFrames[t]:Hide();
	end
end

function Renderer.CreateBackgroundFrame()
	Renderer.backgroundFrame = CreateFrame("Frame", "Renderer.backgroundFrame", Renderer.projectionFrame)
	Renderer.backgroundFrame:SetFrameStrata("BACKGROUND");
	Renderer.backgroundFrame:SetWidth(Renderer.w);
	Renderer.backgroundFrame:SetHeight(Renderer.h);
	Renderer.backgroundFrame:SetPoint("TOPRIGHT", Renderer.projectionFrame, "TOPRIGHT", 0, 0);
	Renderer.backgroundFrame.texture = Renderer.backgroundFrame:CreateTexture("Renderer.backgroundFrame.texture", "ARTWORK")
	Renderer.backgroundFrame.texture:SetColorTexture(0.554,0.554,0.554,1);
	Renderer.backgroundFrame.texture:SetAllPoints(Renderer.backgroundFrame);
	Renderer.backgroundFrame:SetFrameLevel(0);
end

function Renderer.CreateRenderer(x, y, w, h, parent, point, relativePoint)
	Renderer.w = w;
	Renderer.h = h;
	Renderer.projectionFrame = CreateFrame("ModelScene", "Renderer.projectionFrame", parent);
	Renderer.projectionFrame:SetPoint(point, parent, relativePoint, x, y);
	Renderer.projectionFrame:SetWidth(w);
	Renderer.projectionFrame:SetHeight(h);
	Renderer.projectionFrame:SetClipsChildren(true);
	Renderer.projectionFrame:SetCameraPosition(4,0,0);
	Renderer.projectionFrame:SetCameraOrientationByYawPitchRoll(0, 0, 0);

	Renderer.GenerateFrameBuffer();
	Renderer.CreateBackgroundFrame();
	Renderer.active = false;

    Input.mouseInputFrame:SetWidth(w);
	Input.mouseInputFrame:SetHeight(h);
end

function Renderer.AddActor(fileID, X, Y, Z)
    if (X == nil) then X = 0 end
    if (Y == nil) then Y = 0 end
    if (Z == nil) then Z = 0 end

    print("Renderer.AddActor(" .. fileID .. ", " .. X .. ", " .. Y .. ", " .. Z .. ")");

    if (Renderer.projectionFrame == nil) then
        print("Renderer: AddActor() - called before CreateRenderer()");
        return;
    end

    local actor = nil;
    for i in pairs(Renderer.actors) do
        local acr = Renderer.actors[i];
        --if (acr.loaded == false) then
        if (acr:IsVisible() == false) then
            actor = acr;
            break;
        end
    end

    if (actor == nil) then
        -- no available actors found, creating new
        actor = Renderer.projectionFrame:CreateActor("actor"..#Renderer.actors);
        --actor.loaded = true;
        table.insert(Renderer.actors, actor);
    end

    actor:Show();
    actor:SetModelByFileID(fileID);
    actor:SetPosition(X, Y, Z);

    Gizmos.refresh = true;

    return actor;
end

function Renderer.Clear()
    for i in pairs(Renderer.actors) do
        local actor = Renderer.actors[i];
        actor:Hide();
        --actor.loaded = false;
    end
end

---Render a 2D Quad
--Set a screen space frame properties such as vertex position and color
---@param frame table Wow frame to use for this quad
---@param color table Color
---@param aX number Vertex A, X coordinate
---@param aY number Vertex A, Y coordinate
---@param bX number Vertex B, X coordinate
---@param bY number Vertex B, Y coordinate
function SceneMachine.RenderLine(frame, color, aX, aY, bX, bY, flip)
    local ht = SceneMachine.lineThickness / 2;
	-- VerteX Colors --
	frame.texture:SetVertexColor(color.r, color.g, color.b)

	-- Vertex Positions --
    if flip then
        frame.texture:SetVertexOffset(1, aX, aY + ht);
        frame.texture:SetVertexOffset(2, bX, bY + ht);
        frame.texture:SetVertexOffset(3, aX, aY - ht);
        frame.texture:SetVertexOffset(4, bX, bY - ht);
    else
        frame.texture:SetVertexOffset(1, aX + ht, aY);
        frame.texture:SetVertexOffset(2, bX + ht, bY);
        frame.texture:SetVertexOffset(3, aX - ht, aY);
        frame.texture:SetVertexOffset(4, bX - ht, bY);
    end

	frame:Show();
end

local culledPoints = 0;
local distA = { 0, 0, 0 };
local distB = { 0, 0, 0 };
local function NearPlaneFaceCullingLine(vert, planePositionX, planePositionY, planePositionZ, planeNormalX, planeNormalY, planeNormalZ)
    distA[1] = vert[1][1] - planePositionX;	distA[2] = vert[1][2] - planePositionY;	distA[3] = vert[1][3] - planePositionZ;
    distB[1] = vert[2][1] - planePositionX;	distB[2] = vert[2][2] - planePositionY;	distB[3] = vert[2][3] - planePositionZ;
	
    culledPoints = 0;

    if ((distA[1] * planeNormalX) + (distA[2] * planeNormalY) + (distA[3] * planeNormalZ)) < 0
    then
        culledPoints = culledPoints + 1;
    end

    if ((distB[1] * planeNormalX) + (distB[2] * planeNormalY) + (distB[3] * planeNormalZ)) < 0
    then
        culledPoints = culledPoints + 1;
    end

    if (culledPoints <= 1) then
        return false
    else
        return true
    end
end

local xOfs = 0;
local yOfs = 0;

function Renderer.RenderGizmos()
    if (Renderer.active == true) then
        -- Calculate window offsets --
        xOfs = Renderer.projectionFrame:GetLeft();
        yOfs = Renderer.projectionFrame:GetBottom();
        SceneMachine.usedFramesLastFrame = SceneMachine.UsedFrames;
        SceneMachine.UsedFrames = 1;
        SceneMachine.CulledFrames = 1;

        -- Render gizmos --
        if SM.selectedObject ~= nil then
            RenderGizmo(SceneMachine.Gizmos.WireBox);
        end

        if (SceneMachine.Gizmos.activeTransformGizmo == 1) then
            RenderGizmo(SceneMachine.Gizmos.MoveGizmo);
        elseif (SceneMachine.Gizmos.activeTransformGizmo == 2) then
            RenderGizmo(SceneMachine.Gizmos.RotateGizmoX);
            RenderGizmo(SceneMachine.Gizmos.RotateGizmoY);
            RenderGizmo(SceneMachine.Gizmos.RotateGizmoZ);
        elseif (SceneMachine.Gizmos.activeTransformGizmo == 3) then
            
        end
    end
end

local aX, aY, aZ = 0, 0, 0;
local bX, bY, bZ = 0, 0, 0;
local color = Color.New();

SceneMachine.UsedFrames = 1;
SceneMachine.CulledFrames = 1;
SceneMachine.lineThickness = 2;
local vertices = {};
local vert = {};
local faceColors = {};
local faceColor = {};
local cull = false;
function RenderGizmo(gizmo)
	vertices = gizmo.transformedVertices;
	faceColors = gizmo.faceColors;

	for t = 1, gizmo.lines, 1 do
		vert = vertices[t];
		faceColor = faceColors[t];

		-- Near plane face culling --
		cull = NearPlaneFaceCullingLine(vert, Camera.planePositionX, Camera.planePositionY, Camera.planePositionZ, Camera.planeNormalX, Camera.planeNormalY, Camera.planeNormalZ);
		if (not cull) then
			-- Project to screen space --
			aX, aY = Renderer.projectionFrame:Project3DPointTo2D(vert[1][1],vert[1][2],vert[1][3]);
			bX, bY = Renderer.projectionFrame:Project3DPointTo2D(vert[2][1],vert[2][2],vert[2][3]);
            gizmo.screenSpaceVertices[t][1][1] = aX;
            gizmo.screenSpaceVertices[t][1][2] = aY;
            gizmo.screenSpaceVertices[t][2][1] = bX;
            gizmo.screenSpaceVertices[t][2][2] = bY;
            
			-- Face color --
			color:Set(faceColor[1], faceColor[2], faceColor[3]);

            SceneMachine.lineThickness = gizmo.thickness[t];

			-- Render --
			if (aX ~= nil and aY ~= nil and bX ~= nil and bY ~= nil) then
                -- rendering 2 quads across (+) to ensure thickness no matter the angle
				SceneMachine.RenderLine(Renderer.FrameBufferFrames[SceneMachine.UsedFrames], color, aX + xOfs, aY + yOfs, bX + xOfs, bY + yOfs);
                SceneMachine.UsedFrames = SceneMachine.UsedFrames + 1;
                SceneMachine.RenderLine(Renderer.FrameBufferFrames[SceneMachine.UsedFrames], color, aX + xOfs, aY + yOfs, bX + xOfs, bY + yOfs, true);
                SceneMachine.UsedFrames = SceneMachine.UsedFrames + 1;
            end
		else
			-- Cull --
			Renderer.FrameBufferFrames[SceneMachine.UsedFrames]:Hide();
			SceneMachine.CulledFrames = SceneMachine.CulledFrames + 2;
		end

	end

	if (SceneMachine.usedFramesLastFrame > SceneMachine.UsedFrames) then
		for h = SceneMachine.UsedFrames + 1, SceneMachine.usedFramesLastFrame + 1, 1 do
			Renderer.FrameBufferFrames[h]:Hide();
		end
	end
end