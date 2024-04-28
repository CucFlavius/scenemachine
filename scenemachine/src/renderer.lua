local Editor = SceneMachine.Editor;
local SM = Editor.SceneManager;
local Renderer = SceneMachine.Renderer;
local Camera = SceneMachine.Camera;
local Resources = SceneMachine.Resources;
local UI = SceneMachine.UI;
local Object = SceneMachine.GameObjects.Object;

--- WTF ---
local sqrt = math.sqrt;
local floor = math.floor;

Renderer.FrameBufferSize = 1;
Renderer.FrameBufferFrames = {};
Renderer.SpriteBufferSize = 1;
Renderer.SpriteBufferFrames = {};
Renderer.spriteFrameStartLevel = 0;
Renderer.usedSprites = 0;
Renderer.actors = {};
Renderer.gizmos = {};
Renderer.delayedUnitsQueue = {};
Renderer.delayedUnitsQueueHasItems = false;
Renderer.delayedUnitsQueueTimer = 0;
Renderer.letterboxEnabled = false;
Renderer.isFullscreen = false;

function Renderer.GenerateFrameBuffer(startLevel)

    -- Quads --
	for t = 1, Renderer.FrameBufferSize, 1 do
		Renderer.FrameBufferFrames[t] = CreateFrame("Frame", "Renderer.FramebufferFrame_" .. t, Renderer.projectionFrame);
		Renderer.FrameBufferFrames[t]:SetFrameStrata(Editor.MAIN_FRAME_STRATA);
        Renderer.FrameBufferFrames[t]:SetFrameLevel(startLevel + t);
		Renderer.FrameBufferFrames[t]:SetWidth(Editor.width);
		Renderer.FrameBufferFrames[t]:SetHeight(Editor.height);
		Renderer.FrameBufferFrames[t].texture = Renderer.FrameBufferFrames[t]:CreateTexture("Renderer.FramebufferFrame_" .. t ..".texture", "ARTWORK");
		Renderer.FrameBufferFrames[t].texture:SetVertexColor(1,1,1)
        Renderer.FrameBufferFrames[t].texture:SetAllPoints(Renderer.FrameBufferFrames[t]);
		--Renderer.FrameBufferFrames[t].texture:SetTexture(World.TerrainTexture, "REPEAT", "REPEAT", "NEAREST");
		--Renderer.FrameBufferFrames[t].texture:SetTexCoord(0, 0.125, 0.125, 0.25);
		Renderer.FrameBufferFrames[t].texture:SetColorTexture(1,1,1,1);
        
        Renderer.FrameBufferFrames[t]:EnableMouse(true);
		Renderer.FrameBufferFrames[t]:Hide();
	end

    -- Sprites --
    Renderer.spriteFrameStartLevel = startLevel;
    for t = 1, Renderer.SpriteBufferSize, 1 do
        Renderer.SpriteBufferFrames[t] = Renderer.GenerateSpriteFrame(t);
	end
end

function Renderer.GenerateSpriteFrame(t)
    local spriteFrame = CreateFrame("Button", "Renderer.SpritebufferFrame_" .. t, Renderer.projectionFrame);
    spriteFrame:SetFrameStrata(Editor.MAIN_FRAME_STRATA);
    spriteFrame:SetFrameLevel(Renderer.spriteFrameStartLevel + t);
    spriteFrame:SetWidth(30);
    spriteFrame:SetHeight(30);
    spriteFrame.texture = spriteFrame:CreateTexture("Renderer.FramebufferFrame_" .. t ..".texture", "ARTWORK");
    spriteFrame.texture:SetVertexColor(1,1,1,0.5);
    spriteFrame.texture:SetAllPoints(spriteFrame);
    spriteFrame.texture:SetTexture(Resources.textures["SceneSprites"], "REPEAT", "REPEAT");
    
    spriteFrame:EnableMouse(true);
    spriteFrame:SetScript("OnClick", function(self)
        SM.SelectObjectByIndex(self.objIdx);
    end);
    spriteFrame:SetScript('OnEnter', function()
        spriteFrame.texture:SetVertexColor(1,1,1,1);
    end);
    spriteFrame:SetScript('OnLeave', function()
        spriteFrame.texture:SetVertexColor(1,1,1,0.5);
    end);
    spriteFrame:Hide();
    return spriteFrame;
end

function Renderer.CreateRenderer(x, y, w, h, parent, startLevel)
	Renderer.w = w;
	Renderer.h = h;
    Renderer.parent = parent;

    Renderer.backgroundFrame = CreateFrame("Frame", "Renderer.backgroundFrame", parent)
	Renderer.backgroundFrame:SetFrameStrata(Editor.MAIN_FRAME_STRATA);
	Renderer.backgroundFrame:SetWidth(Renderer.w);
	Renderer.backgroundFrame:SetHeight(Renderer.h);
	Renderer.backgroundFrame:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, -21);
    Renderer.backgroundFrame:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 0, 0);

	Renderer.backgroundFrame.texture = Renderer.backgroundFrame:CreateTexture("Renderer.backgroundFrame.texture", "ARTWORK")
	Renderer.backgroundFrame.texture:SetColorTexture(0.554,0.554,0.554,1);
	Renderer.backgroundFrame.texture:SetAllPoints(Renderer.backgroundFrame);
	Renderer.backgroundFrame:SetFrameLevel(startLevel);

	Renderer.projectionFrame = CreateFrame("ModelScene", "Renderer.projectionFrame", Renderer.backgroundFrame);
    Renderer.projectionFrame:SetAllPoints(Renderer.backgroundFrame);
	--Renderer.projectionFrame:SetClipsChildren(true);
	Renderer.projectionFrame:SetCameraPosition(4,0,0);
	Renderer.projectionFrame:SetCameraOrientationByYawPitchRoll(0, 0, 0);
    Renderer.projectionFrame:SetFrameLevel(startLevel + 2);

	Renderer.GenerateFrameBuffer(startLevel + 30);
    Renderer.CreateLetterbox(startLevel + 3);

	Renderer.active = false;
end

function Renderer.CreateLetterbox(startLevel)
    Renderer.letterboxT = UI.Rectangle:NewTLTR(0, 0, 0, 0, 20, Renderer.projectionFrame, 0, 0, 0, 1);
    Renderer.letterboxT:SetFrameLevel(startLevel);
    Renderer.letterboxT:Hide();

    Renderer.letterboxB = UI.Rectangle:NewBLBR(0, 0, 0, 0, 20, Renderer.projectionFrame, 0, 0, 0, 1);
    Renderer.letterboxB:SetFrameLevel(startLevel);
    Renderer.letterboxB:Hide();

    Renderer.letterboxL = UI.Rectangle:NewTLBL(0, 0, 0, 0, 20, Renderer.projectionFrame, 0, 0, 0, 1);
    Renderer.letterboxL:SetFrameLevel(startLevel);
    Renderer.letterboxL:Hide();

    Renderer.letterboxR = UI.Rectangle:NewTRBR(0, 0, 0, 0, 20, Renderer.projectionFrame, 0, 0, 0, 1);
    Renderer.letterboxR:SetFrameLevel(startLevel);
    Renderer.letterboxR:Hide();
end

function Renderer.FullScreen(on)
    if (on) then
        Renderer.backgroundFrame:SetParent(UIParent);
        Renderer.backgroundFrame:SetAllPoints(UIParent);
        Renderer.backgroundFrame:SetFrameStrata("FULLSCREEN");
    else
        Renderer.backgroundFrame:SetParent(Renderer.parent);
        Renderer.backgroundFrame:ClearAllPoints();
        Renderer.backgroundFrame:SetPoint("TOPRIGHT", Renderer.parent, "TOPRIGHT", 0, -21);
        Renderer.backgroundFrame:SetPoint("BOTTOMLEFT", Renderer.parent, "BOTTOMLEFT", 0, 0);
        Renderer.backgroundFrame:SetFrameStrata(Editor.MAIN_FRAME_STRATA);
    end

    Renderer.isFullscreen = on;
end

function Renderer.AddActor(fileID, X, Y, Z, type)
    X = tonumber(X);
    Y = tonumber(Y);
    Z = tonumber(Z);
    if (X == nil) then X = 0 end
    if (Y == nil) then Y = 0 end
    if (Z == nil) then Z = 0 end

    type = type or SceneMachine.GameObjects.Object.Type.Model;

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
    if (type == SceneMachine.GameObjects.Object.Type.Model) then
        actor:SetModelByFileID(fileID);
    elseif (type == SceneMachine.GameObjects.Object.Type.Creature) then
        actor:SetModelByCreatureDisplayID(fileID);
    elseif (type == SceneMachine.GameObjects.Object.Type.Character) then
        local worked = actor:SetModelByUnit("player");
        if (not worked) then
            Renderer.delayedUnitsQueueHasItems = true;
            Renderer.delayedUnitsQueue[#Renderer.delayedUnitsQueue + 1] = { actor = actor, unit = "player"};
        end
    end
    actor:SetPosition(X, Y, Z);

    -- forcing center as origin so that the bounding boxes stay consistent
    actor:SetUseCenterForOrigin(0, 0, 0);

    return actor;
end

function Renderer.RemoveActor(actor)
    if (actor) then
        actor:Hide();
    end
end

function Renderer.Clear()
    for i in pairs(Renderer.actors) do
        local actor = Renderer.actors[i];
        Renderer.RemoveActor(actor);
    end
end

function Renderer.NearPlaneFaceCullingVert(vert, planePositionX, planePositionY, planePositionZ, planeNormalX, planeNormalY, planeNormalZ)
    local distA = {};
    distA[1] = vert[1] - planePositionX;	distA[2] = vert[2] - planePositionY;	distA[3] = vert[3] - planePositionZ;

    if (((distA[1] * planeNormalX) + (distA[2] * planeNormalY) + (distA[3] * planeNormalZ)) < 0) then
        return true;
    end

    return false
end

function Renderer.NearPlaneFaceCullingLine(vert, planePositionX, planePositionY, planePositionZ, planeNormalX, planeNormalY, planeNormalZ, maxP)
    local distA = {};
    local distB = {};

    distA[1] = vert[1][1] - planePositionX;	distA[2] = vert[1][2] - planePositionY;	distA[3] = vert[1][3] - planePositionZ;
    distB[1] = vert[2][1] - planePositionX;	distB[2] = vert[2][2] - planePositionY;	distB[3] = vert[2][3] - planePositionZ;
	
    local culledPoints = 0;

    if ((distA[1] * planeNormalX) + (distA[2] * planeNormalY) + (distA[3] * planeNormalZ)) < 0
    then
        culledPoints = culledPoints + 1;
    end

    if ((distB[1] * planeNormalX) + (distB[2] * planeNormalY) + (distB[3] * planeNormalZ)) < 0
    then
        culledPoints = culledPoints + 1;
    end

    if (culledPoints <= maxP) then
        return false
    else
        return true
    end
end

function Renderer.Update()
    Renderer.RenderGizmos();
    Renderer.RenderSprites();
    if (Renderer.letterboxEnabled) then
        Renderer.UpdateLetterbox();
    end
    Renderer.CheckQueuedTasks();
end

function Renderer.ShowLetterbox()
    Renderer.letterboxEnabled = true;
    Renderer.letterboxT:Show();
    Renderer.letterboxB:Show();
    Renderer.letterboxL:Show();
    Renderer.letterboxR:Show();
end

function Renderer.HideLetterbox()
    Renderer.letterboxEnabled = false;
    Renderer.letterboxT:Hide();
    Renderer.letterboxB:Hide();
    Renderer.letterboxL:Hide();
    Renderer.letterboxR:Hide();
end

function Renderer.ToggleLetterbox()
    Renderer.letterboxEnabled = not Renderer.letterboxEnabled;
    if (not Renderer.letterboxEnabled) then
        Renderer.letterboxT:Hide();
        Renderer.letterboxB:Hide();
        Renderer.letterboxL:Hide();
        Renderer.letterboxR:Hide();
    end
end

function Renderer.UpdateLetterbox()
    -- Get camera and screen aspect ratios
    local cameraAspect = Camera.aspectRatio
    local width, height = GetPhysicalScreenSize()
    local screenAspect = width / height

    -- Calculate letterbox height
    local letterboxHeight = 0

    if cameraAspect < screenAspect then
        Renderer.letterboxT:Show();
        Renderer.letterboxB:Show();
        Renderer.letterboxL:Hide();
        Renderer.letterboxR:Hide();
        -- Camera aspect ratio is narrower, add letterbox at top and bottom
        letterboxHeight = (Camera.height - Camera.width / screenAspect) / 2
        Renderer.letterboxT:SetHeight(letterboxHeight);
        Renderer.letterboxB:SetHeight(letterboxHeight);
    else
        Renderer.letterboxT:Hide();
        Renderer.letterboxB:Hide();
        Renderer.letterboxL:Show();
        Renderer.letterboxR:Show();
        -- Camera aspect ratio is wider, add letterbox at left and right
        local letterboxWidth = (Camera.width - Camera.height * screenAspect) / 2
        Renderer.letterboxL:SetWidth(letterboxWidth);
        Renderer.letterboxR:SetWidth(letterboxWidth);

    end

end

function Renderer.CheckQueuedTasks()
    if (Renderer.delayedUnitsQueueHasItems) then
        Renderer.delayedUnitsQueueTimer = Renderer.delayedUnitsQueueTimer + 1;
        if (Renderer.delayedUnitsQueueTimer >= 50) then
            Renderer.delayedUnitsQueueTimer = 0;
            for i = 1, #Renderer.delayedUnitsQueue, 1 do
                local item = Renderer.delayedUnitsQueue[i];
                local worked = item.actor:SetModelByUnit(item.unit);
                if (worked) then
                    table.remove(Renderer.delayedUnitsQueue, i);
                    return;
                end
            end

            if #Renderer.delayedUnitsQueue == 0 then
                Renderer.delayedUnitsQueueHasItems = false;
            end
        end
    end
end

function Renderer.GetAvailableSprite()
    local i = Renderer.usedSprites + 1;
    Renderer.usedSprites = Renderer.usedSprites + 1;

    if (i > #Renderer.SpriteBufferFrames) then
        -- generate new sprite
        Renderer.SpriteBufferFrames[i] = Renderer.GenerateSpriteFrame(i);
    end

    return Renderer.SpriteBufferFrames[i];
end

function Renderer.RenderSprites()
    Renderer.usedSprites = 0;
    if (not SM.loadedScene) then
        -- hide all
        return;
    end

    if (not Renderer.isFullscreen) then
        for i = 1, SM.loadedScene:GetObjectCount(), 1 do
            local object = SM.loadedScene:GetObject(i);
            if (object) then
                if (object:GetGizmoType() == Object.GizmoType.Camera) then
                    if (object:IsVisible()) then
                        local pos = object:GetPosition();
                        
                        -- Near plane face culling --
                        local cull = Renderer.NearPlaneFaceCullingVert({pos.x, pos.y, pos.z}, Camera.planePosition.x, Camera.planePosition.y, Camera.planePosition.z, Camera.forward.x, Camera.forward.y, Camera.forward.z)
                        if (not cull) then
                            local sprite = Renderer.GetAvailableSprite();
                            sprite.objIdx = i;

                            -- Project to screen space --
                            local aX, aY, aZ = Renderer.projectionFrame:Project3DPointTo2D(pos.x, pos.y, pos.z);
                            local size = 20;
                            local hSize = size / 2;
                            -- Render --
                            if (aX ~= nil and aY ~= nil) then
                                sprite:Show();
                                sprite:ClearAllPoints();
                                sprite:SetPoint("BOTTOMLEFT", Renderer.projectionFrame, "BOTTOMLEFT", aX * Renderer.scale - hSize, aY * Renderer.scale - hSize);
                                sprite:SetSize(size, size);
                                sprite.texture:SetTexCoord(0, 0.25, 0, 0.25);
                            end
                        end
                    end
                end
            end
        end
    end

    for i = Renderer.usedSprites + 1, #Renderer.SpriteBufferFrames, 1 do
        if (Renderer.SpriteBufferFrames[i]) then
            Renderer.SpriteBufferFrames[i]:Hide();
        end
    end
end

function Renderer.RenderGizmos()
    if (not Renderer.projectionFrame or Renderer.isFullscreen) then
        return;
    end

    if (Renderer.active) then
        Renderer.scale = 1.0 / Renderer.projectionFrame:GetEffectiveScale();

        for i = 1, #Renderer.gizmos, 1 do
            local gizmo = Renderer.gizmos[i];
            if (gizmo) then
                if (gizmo:IsVisible()) then
                    gizmo:RenderLines();
                    gizmo:Shade();
                end
            end
        end
    end
end