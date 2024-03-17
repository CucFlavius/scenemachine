local Editor = SceneMachine.Editor;
local SM = Editor.SceneManager;
local Gizmos = SceneMachine.Gizmos;
local Renderer = SceneMachine.Renderer;
local Camera = SceneMachine.Camera;
local World = SceneMachine.World;
local FX = SceneMachine.FX;
local Input = SceneMachine.Input;
local Math = SceneMachine.Math;
local CC = SceneMachine.CameraController;
local Vector3 = SceneMachine.Vector3;
local Resources = SceneMachine.Resources;

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
Renderer.delayedUnitsQueue = {};
Renderer.delayedUnitsQueueHasItems = false;
Renderer.delayedUnitsQueueTimer = 0;
SceneMachine.UsedFrames = 1;
SceneMachine.CulledFrames = 1;
SceneMachine.lineThickness = 2;

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
        Renderer.FrameBufferFrames[t]:SetScript('OnEnter', function() print("Enter " .. t) end);
        Renderer.FrameBufferFrames[t]:SetScript('OnLeave', function() print("Exit " .. t) end);
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

    Renderer.backgroundFrame = CreateFrame("Frame", "Renderer.backgroundFrame", parent)
	Renderer.backgroundFrame:SetFrameStrata(Editor.MAIN_FRAME_STRATA);
	Renderer.backgroundFrame:SetWidth(Renderer.w);
	Renderer.backgroundFrame:SetHeight(Renderer.h);
	Renderer.backgroundFrame:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, -21);
    Renderer.backgroundFrame:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 0, 0);
    --Renderer.backgroundFrame:SetAllPoints(parent);

	Renderer.backgroundFrame.texture = Renderer.backgroundFrame:CreateTexture("Renderer.backgroundFrame.texture", "ARTWORK")
	Renderer.backgroundFrame.texture:SetColorTexture(0.554,0.554,0.554,1);
	Renderer.backgroundFrame.texture:SetAllPoints(Renderer.backgroundFrame);
	Renderer.backgroundFrame:SetFrameLevel(startLevel);

	Renderer.projectionFrame = CreateFrame("ModelScene", "Renderer.projectionFrame", Renderer.backgroundFrame);
	--Renderer.projectionFrame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 0, 0);
    --Renderer.projectionFrame:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0);
    Renderer.projectionFrame:SetAllPoints(Renderer.backgroundFrame);
	--Renderer.projectionFrame:SetWidth(w);
	--Renderer.projectionFrame:SetHeight(h);
	Renderer.projectionFrame:SetClipsChildren(true);
	Renderer.projectionFrame:SetCameraPosition(4,0,0);
	Renderer.projectionFrame:SetCameraOrientationByYawPitchRoll(0, 0, 0);
    Renderer.projectionFrame:SetFrameLevel(startLevel + 2);
	Renderer.GenerateFrameBuffer(startLevel + 30);

	Renderer.active = false;
end

function Renderer.AddActor(fileID, X, Y, Z, type)
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
    Renderer.CheckQueuedTasks();
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

    for i = 1, #SM.loadedScene.objects, 1 do
        local object = SM.loadedScene.objects[i];
        if (object) then
            if (object:GetGizmoType() == Gizmos.Type.Camera) then
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

    for i = Renderer.usedSprites + 1, #Renderer.SpriteBufferFrames, 1 do
        if (Renderer.SpriteBufferFrames[i]) then
            Renderer.SpriteBufferFrames[i]:Hide();
        end
    end
end

function Renderer.RenderGizmos()
    if (Renderer.projectionFrame == nil) then return end
    if (Renderer.active == true) then
        Renderer.scale = 1.0 / Renderer.projectionFrame:GetEffectiveScale();
        SceneMachine.usedFramesLastFrame = SceneMachine.UsedFrames;
        SceneMachine.UsedFrames = 1;
        SceneMachine.CulledFrames = 1;

        -- Render gizmos --

        if (SceneMachine.Gizmos.DebugGizmo) then
            if (SceneMachine.Gizmos.DebugGizmo.active == true) then
                RenderGizmoLines(SceneMachine.Gizmos.DebugGizmo);
                --ShadeScaleGizmo(SceneMachine.Gizmos.DebugGizmo);
            end
        end

        if #SM.selectedObjects > 0 then
            if (SM.selectedObjects[1]:GetGizmoType() == Gizmos.Type.Object) then
                RenderGizmoLines(SceneMachine.Gizmos.WireBox);
                ShadeSelectionGizmo(SceneMachine.Gizmos.WireBox);
            elseif (SM.selectedObjects[1]:GetGizmoType() == Gizmos.Type.Camera) then
                RenderGizmoLines(SceneMachine.Gizmos.CameraGizmo);
            end
        end
        
        if (SceneMachine.Gizmos.activeTransformGizmo == 1) then
            RenderGizmoLines(SceneMachine.Gizmos.MoveGizmo);
            ShadeMovementGizmo(SceneMachine.Gizmos.MoveGizmo);
        elseif (SceneMachine.Gizmos.activeTransformGizmo == 2) then
            RenderGizmoLines(SceneMachine.Gizmos.RotateGizmo);
            ShadeRotationGizmo(SceneMachine.Gizmos.RotateGizmo);
        elseif (SceneMachine.Gizmos.activeTransformGizmo == 3) then
            RenderGizmoLines(SceneMachine.Gizmos.ScaleGizmo);
            ShadeScaleGizmo(SceneMachine.Gizmos.ScaleGizmo);
        end
    end
end

function RenderGizmoLines(gizmo)
    if (not gizmo) then return end
	local vertices = gizmo.transformedVertices;
	local faceColors = gizmo.faceColors;

	for t = 1, gizmo.lineCount, 1 do
		local vert = vertices[t];
		local faceColor = faceColors[t];
        
        local line = gizmo.lines[t];
        
		-- Near plane face culling --
		local cull = Renderer.NearPlaneFaceCullingLine(vert, Camera.planePosition.x, Camera.planePosition.y, Camera.planePosition.z, Camera.forward.x, Camera.forward.y, Camera.forward.z, 0);

		if (not cull) then
			-- Project to screen space --
			local aX, aY, aZ = Renderer.projectionFrame:Project3DPointTo2D(vert[1][1],vert[1][2],vert[1][3]);
			local bX, bY, bZ = Renderer.projectionFrame:Project3DPointTo2D(vert[2][1],vert[2][2],vert[2][3]);
            
            --- these are needed for calculating mouse over
            gizmo.screenSpaceVertices[t][1][1] = aX;
            gizmo.screenSpaceVertices[t][1][2] = aY;
            gizmo.screenSpaceVertices[t][2][1] = bX;
            gizmo.screenSpaceVertices[t][2][2] = bY;

			-- Render --
			if (aX ~= nil and aY ~= nil and bX ~= nil and bY ~= nil) then
                line:Show();
                line:SetVertexColor(faceColor[1], faceColor[2], faceColor[3], faceColor[4] or 1);
                line:SetStartPoint("BOTTOMLEFT", aX * Renderer.scale, aY * Renderer.scale) -- start topleft
                line:SetEndPoint("BOTTOMLEFT", bX * Renderer.scale, bY * Renderer.scale)   -- end bottomright

                if (gizmo.dashedLine == true) then
                    local dist = Vector3.ManhattanDistanceP(vert[1][1],vert[1][2],vert[1][3],vert[2][1],vert[2][2],vert[2][3]);
                    dist = max(dist, 1);
                    dist = min(dist, 100);
                    line:SetTexCoord(0, dist , 0, 1);
                end

                if (gizmo.lines ~= nil) then
                    gizmo.lines[t] = line;
                    gizmo.lineDepths[t] = aZ + bZ;
                end
            end
		else
			-- Cull --
			line:Hide();
		end

	end
end

function ShadeSelectionGizmo(gizmo)
    if (not gizmo) then return end
    -- Create an array of indices
    local indices = {}
    for i = 1, #gizmo.lineDepths do
        indices[i] = i
    end

    -- Sort the indices based on the values in the 'numbers' table
    table.sort(indices, function(a, b)
        if (gizmo.lineDepths[a] ~= nil and gizmo.lineDepths[b] ~= nil) then
            return gizmo.lineDepths[a] < gizmo.lineDepths[b];
        else
            return false;
        end
    end)

    -- Create sorted tables
    local sortedLineDepths = {}
    local sortedLines = {}
    for _, index in ipairs(indices) do
        table.insert(sortedLineDepths, gizmo.lineDepths[index])
        table.insert(sortedLines, gizmo.lines[index])
    end

    for i = 1, 3 do
        if (sortedLines[i] ~= nil) then
            sortedLines[i]:SetVertexColor(1, 1, 1, 0.3);
        end
    end
end

function ShadeMovementGizmo(gizmo)
    if (not gizmo) then return end
    for t = 1, 3, 1 do
        if (gizmo.lines[t].axis == Gizmos.highlightedAxis) then
            gizmo.faceColors[t][4] = 1.0;
            for c = 4 + 2 + (gizmo.coneDetail * (t-1)), 4 + 2 + (gizmo.coneDetail * (t)), 1 do
                gizmo.faceColors[c][4] = 1.0;
            end
        else
            gizmo.faceColors[t][4] = 0.3;
            for c = 4 + 2 + (gizmo.coneDetail * (t-1)), 4 + 2 + (gizmo.coneDetail * (t)), 1 do
                gizmo.faceColors[c][4] = 0.3;
            end
        end
    end

    for t = 4, 4 + 6, 1 do
        if (gizmo.lines[t].axis == Gizmos.highlightedAxis) then
            gizmo.faceColors[t][4] = 1.0;
        else
            gizmo.faceColors[t][4] = 0.3;
        end
    end
end

function ShadeRotationGizmo(gizmo)
    if (not gizmo) then return end
    local function normalize(value, min, max)
        return (value - min) / (max - min)
    end
    
    local function clamp(value, min, max)
        return math.min(math.max(value, min), max);
    end

    local minD = 10000000;
    local maxD = -10000000;

    -- find min max depth
    for i = 1, #gizmo.lineDepths do
        if (gizmo.lineDepths[i] > maxD) then
            maxD = gizmo.lineDepths[i];
        end
        if (gizmo.lineDepths[i] < minD) then
            minD = gizmo.lineDepths[i];
        end
    end

    -- fade alpha
    for i = 1, #gizmo.lineDepths do
        -- get an alpha value between 0 and 1
        local alpha = normalize(gizmo.lineDepths[i], minD, maxD);

        -- make non linear
        alpha = math.pow(alpha, 2.2);

        gizmo.lines[i].alpha = alpha;

        -- clamp
        if (gizmo.lines[i].axis == Gizmos.highlightedAxis) then
            alpha = clamp(alpha, 0.5, 1);
        else
            alpha = clamp(alpha, 0, 0.3);
        end

        local faceColor = gizmo.faceColors[i];
        gizmo.lines[i]:SetVertexColor(faceColor[1], faceColor[2], faceColor[3], alpha);
    end
end

function ShadeScaleGizmo(gizmo)
    if (not gizmo) then return end
    for t = 1, gizmo.lineCount, 1 do
        if (Gizmos.highlightedAxis ~= 0) then
            gizmo.faceColors[t][4] = 1.0;
        else
            gizmo.faceColors[t][4] = 0.3;
        end
    end
end