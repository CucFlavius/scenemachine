local AM = SceneMachine.Editor.AnimationManager;
local SM = SceneMachine.Editor.SceneManager;
local SH = SceneMachine.Editor.SceneHierarchy;
local OP = SceneMachine.Editor.ObjectProperties;
local Renderer = SceneMachine.Renderer;
local Editor = SceneMachine.Editor;
local Input = SceneMachine.Input;
local Track = SceneMachine.Track;
local UI = SceneMachine.UI;
local Resources = SceneMachine.Resources;
local L = Editor.localization;
local Actions = SceneMachine.Actions;
local CC = SceneMachine.CameraController;
local Camera = SceneMachine.Camera;
local Keyframe = SceneMachine.Keyframe;
local AnimationClip = SceneMachine.AnimationClip;
local Timeline = SceneMachine.Timeline;

local tabButtonHeight = 20;
local tabPool = {};

AM.needlePoolSize = 10;
AM.usedNeedles = 0;
AM.minShownNeedles = 10;
AM.maxShownNeedles = 25;
AM.needles = {};
AM.currentCrop = {
    min = 0;
    max = 0.5;
};

AM.keyframeGroups = {};

AM.inputState = {
    timebarFramePosStart = 0;
    mousePosStartX = 0;
    movingTime = false;
    movingKeyframe = false;
    movingAnim = -1;
    movingAnimHandleL = -1;
    movingAnimHandleR = -1;
    workspaceRefreshed = false;
};
AM.loadedTimelineIndex = 1;
AM.loadedTimeline = nil;
AM.selectedTrack = nil;
AM.selectedAnim = nil;
AM.selectedKeys = {};
AM.selectedKeyComponents = {};
AM.toOverrideKeys = nil;

AM.TrackPoolSize = 10;
AM.usedTracks = 0;
AM.trackElementH = 30;

AM.AnimationPoolSize = 10;
AM.usedAnimations = 0;

AM.keyframeElementH = 14;
AM.KeyframePoolSize = 20;
AM.usedKeyframes = 0;

AM.selectedAnimID = -1;
AM.selectedAnimVariant = 0;
AM.clonedKeys = {};

AM.Mode = {
    Tracks = 0,
    Keyframes = 1,
    Curves = 2,
}

AM.KeyAddMode = {
    All = 0,
    Position = 1,
    Rotation = 2,
    Scale = 3
}

AM.uiMode = AM.Mode.Tracks;
AM.keyAddMode = AM.KeyAddMode.All;

AM.CurvePoolSize = 30;
AM.usedCurveLines = 0;

AM.playing = false;
AM.loopPlay = true;
AM.lastKeyedTime = 0;
AM.currentInterpolationIn = Keyframe.Interpolation.Bezier;
AM.currentInterpolationOut = Keyframe.Interpolation.Bezier;

local c1 = { 0.1757, 0.1757, 0.1875 };
local c2 = { 0.242, 0.242, 0.25 };
local c3 = { 0, 0.4765, 0.7968 };
local c4 = { 0.1171, 0.1171, 0.1171 };

local squash = 0;
local squashStrength = 0.01;
local isSquashing = false;
local squashIndex = -1;

function AM.Update(deltaTime)
    isSquashing = false;
    AM.inputState.workspaceRefreshed = false;

    if (AM.loadedTimeline) then
        if (AM.playing) then
            local deltaTimeMS = math.floor(deltaTime * 1000);
            local nextTime = AM.loadedTimeline:GetTime() + deltaTimeMS;

            if (not AM.loopPlay) then
                -- if stop at the end
                local duration = AM.loadedTimeline:GetDuration();
                if (nextTime >= duration) then
                    AM.SetTime(duration);
                    AM.playing = false;
                    return;
                end
            else
                -- if loop
                if (nextTime >= AM.lastKeyedTime) then
                    AM.SetTime(0);
                    return;
                end
            end

            AM.SetTime(nextTime, false);
        end
    end

    if (AM.inputState.movingTime) then
        local groupBgH = AM.timebarGroup:GetWidth() - 26;
        local mouseDiff = (AM.inputState.timebarFramePosStart + 10) - Input.mouseXRaw * Renderer.scale;
        local newPoint = -mouseDiff;

        -- Scroll the items list --
        local newPointNormalized = newPoint / groupBgH;
        local totalTimeMS = AM.loadedTimeline:GetDuration();
        local startMS = AM.currentCrop.min * totalTimeMS;
        local endMS = AM.currentCrop.max * totalTimeMS;
        local lengthMS = endMS - startMS;

        local timeMS = startMS + (newPointNormalized * lengthMS);
        timeMS = max(startMS, min(endMS, timeMS));  -- clamp

        AM.SetTime(math.floor(timeMS));
    end

    if (AM.inputState.movingKeyframe) then

        if (not Input.mouseState.LMB) then
            AM.inputState.movingKeyframe = false;
            AM.inputState.timeStart = nil;
            AM.OnFinishedKeyRetiming();
            return;
        end

        local groupBgH = AM.timebarGroup:GetWidth() - 26;
        local mouseDiff = (AM.inputState.timebarFramePosStart + 5) - Input.mouseXRaw * Renderer.scale;
        local newPoint = -mouseDiff;

        -- Scroll the items list --
        local newPointNormalized = newPoint / groupBgH;
        local totalTimeMS = AM.loadedTimeline:GetDuration();
        local startMS = AM.currentCrop.min * totalTimeMS;
        local endMS = AM.currentCrop.max * totalTimeMS;
        local lengthMS = endMS - startMS;

        if (not AM.inputState.timeStart) then
            AM.inputState.timeStart = AM.selectedKeys[1].time;
        end

        local previousTime = AM.selectedKeys[1].time;
        
        local timeChangeMS = startMS + (newPointNormalized * lengthMS);
        local timeMS = AM.inputState.timeStart + timeChangeMS - startMS;
        local maxT = math.floor(math.floor(totalTimeMS / 33.3333) * 33.3333);
        timeMS = math.floor(math.floor(timeMS / 33.3333) * 33.3333);
        timeMS = min(maxT ,max(0, timeMS));

        if (previousTime ~= timeMS) then
            AM.toOverrideKeys = nil;
            if (AM.keyframeGroups[timeMS]) then
                local grp = AM.keyframeGroups[timeMS];
                AM.toOverrideKeys = {};
                for c = 1, #AM.selectedKeyComponents, 1 do
                    if (AM.selectedKeyComponents[c] == 1) then
                        AM.toOverrideKeys[#AM.toOverrideKeys + 1] = grp.px;
                    elseif(AM.selectedKeyComponents[c] == 2) then
                        AM.toOverrideKeys[#AM.toOverrideKeys + 1] = grp.py;
                    elseif(AM.selectedKeyComponents[c] == 3) then
                        AM.toOverrideKeys[#AM.toOverrideKeys + 1] = grp.pz;
                    elseif(AM.selectedKeyComponents[c] == 4) then
                        AM.toOverrideKeys[#AM.toOverrideKeys + 1] = grp.rx;
                    elseif(AM.selectedKeyComponents[c] == 5) then
                        AM.toOverrideKeys[#AM.toOverrideKeys + 1] = grp.ry;
                    elseif(AM.selectedKeyComponents[c] == 6) then
                        AM.toOverrideKeys[#AM.toOverrideKeys + 1] = grp.rz;
                    elseif(AM.selectedKeyComponents[c] == 7) then
                        AM.toOverrideKeys[#AM.toOverrideKeys + 1] = grp.s;
                    elseif(AM.selectedKeyComponents[c] == 8) then
                        AM.toOverrideKeys[#AM.toOverrideKeys + 1] = grp.a;
                    end
                end
            end
        end

        for k = 1, #AM.selectedKeys, 1 do
            AM.selectedKeys[k]:SetTime(timeMS);
            AM.selectedKeyGroup = timeMS;
        end

        AM.RefreshWorkspace();
    end

    if (AM.inputState.movingAnim ~= -1) then

        local groupBgH = AM.timebarGroup:GetWidth() - 26;
        local mouseDiff = (AM.inputState.mousePosStartX - Input.mouseXRaw) * Renderer.scale;
        local newPoint = -mouseDiff;

        -- Scroll the items list --
        local newPointNormalized = newPoint / groupBgH;
        local totalTimeMS = AM.loadedTimeline:GetDuration();
        local startMS = AM.currentCrop.min * totalTimeMS;
        local endMS = AM.currentCrop.max * totalTimeMS;
        local lengthMS = endMS - startMS;

        local diffTimeMS = (newPointNormalized * lengthMS);

        if (diffTimeMS ~= 0) then

            local animElement = AM.AnimationPool[AM.inputState.movingAnim];

            local track = AM.loadedTimeline:GetTrack(animElement.trackIdx);
            local anim = track.animations[animElement.animIdx];
            local desiredStartT = math.floor(anim:GetStartTime() + diffTimeMS);
            local desiredEndT = math.floor(anim:GetEndTime() + diffTimeMS);

            -- check each side
            local animL = track.animations[animElement.animIdx - 1];
            local animR = track.animations[animElement.animIdx + 1];

            local length = anim:GetDuration();

            local savePrevMouse = AM.inputState.mousePosStartX;

            if (animL and not animR) then
                if (desiredStartT > animL:GetEndTime()) then
                    anim:SetStartTime(desiredStartT);
                    anim:SetEndTime(desiredEndT);
                    AM.inputState.mousePosStartX = Input.mouseXRaw;
                else
                    if (desiredStartT < animL:GetStartTime()) then
                        AnimationClip.SwapLeft(anim, animL);
                        -- select the other
                        AM.inputState.movingAnim = AM.inputState.movingAnim - 1;
                        AM.SelectAnimation(AM.inputState.movingAnim);
                        AM.inputState.mousePosStartX = Input.mouseXRaw;
                        isSquashing = false;
                        squashIndex = AM.inputState.movingAnim + 1;
                    else
                        anim:SetStartTime(animL:GetEndTime());
                        anim:SetEndTime(anim:GetStartTime() + length);
                        squash = (AM.inputState.mousePosStartX - Input.mouseXRaw) * squashStrength;
                        isSquashing = true;
                        squashIndex = AM.inputState.movingAnim - 1;
                    end
                end
            elseif (animR and not animL) then
                if (desiredEndT < animR:GetStartTime()) then
                    anim:SetStartTime(desiredStartT);
                    anim:SetEndTime(desiredEndT);
                    AM.inputState.mousePosStartX = Input.mouseXRaw;
                else
                    -- check if mouse past whole of animR, and swap them
                    if (desiredEndT > animR:GetEndTime()) then
                        AnimationClip.SwapRight(anim, animR);
                        -- select the other
                        AM.inputState.movingAnim = AM.inputState.movingAnim + 1;
                        AM.SelectAnimation(AM.inputState.movingAnim);
                        AM.inputState.mousePosStartX = Input.mouseXRaw;
                        isSquashing = false;
                        squashIndex = AM.inputState.movingAnim - 1;
                    else
                        anim:SetEndTime(animR:GetStartTime());
                        anim:SetStartTime(anim:GetEndTime() - length);
                        squash = -(AM.inputState.mousePosStartX - Input.mouseXRaw) * squashStrength;
                        isSquashing = true;
                        squashIndex = AM.inputState.movingAnim + 1;
                    end
                end
            elseif (animL and animR) then
                if (desiredStartT > animL:GetEndTime()) and (desiredEndT < animR:GetStartTime()) then
                    anim:SetStartTime(desiredStartT);
                    anim:SetEndTime(desiredEndT);
                    AM.inputState.mousePosStartX = Input.mouseXRaw;
                else
                    if (desiredStartT <= animL:GetEndTime()) then
                        -- check if mouse past whole of animR, and swap them
                        if (desiredStartT < animL:GetStartTime()) then
                            AnimationClip.SwapLeft(anim, animL);
                            -- select the other
                            AM.inputState.movingAnim = AM.inputState.movingAnim - 1;
                            AM.SelectAnimation(AM.inputState.movingAnim);
                            AM.inputState.mousePosStartX = Input.mouseXRaw;
                            isSquashing = false;
                            squashIndex = AM.inputState.movingAnim + 1;
                        else
                            anim:SetStartTime(animL:GetEndTime());
                            anim:SetEndTime(anim:GetStartTime() + length);
                            squash = (AM.inputState.mousePosStartX - Input.mouseXRaw) * squashStrength;
                            isSquashing = true;
                            squashIndex = AM.inputState.movingAnim - 1;
                        end
                    elseif (desiredEndT >= animR:GetStartTime()) then
                        -- check if mouse past whole of animR, and swap them
                        if (desiredEndT > animR:GetEndTime()) then
                            AnimationClip.SwapRight(anim, animR);
                            -- select the other
                            AM.inputState.movingAnim = AM.inputState.movingAnim + 1;
                            AM.SelectAnimation(AM.inputState.movingAnim);
                            AM.inputState.mousePosStartX = Input.mouseXRaw;
                            isSquashing = false;
                            squashIndex = AM.inputState.movingAnim - 1;
                        else
                            anim:SetEndTime(animR:GetStartTime());
                            anim:SetStartTime(anim:GetEndTime() - length);
                            squash = -(AM.inputState.mousePosStartX - Input.mouseXRaw) * squashStrength;
                            isSquashing = true;
                            squashIndex = AM.inputState.movingAnim + 1;
                        end
                    end
                end
            elseif (not animL and not animR) then
                anim:SetStartTime(desiredStartT);
                anim:SetEndTime(desiredEndT);
                AM.inputState.mousePosStartX = Input.mouseXRaw;
            end

            if (anim:GetStartTime() < 0) then
                anim:SetStartTime(0);
                anim:SetEndTime(anim:GetStartTime() + length);
                AM.inputState.mousePosStartX = savePrevMouse;
            elseif(anim:GetEndTime() > totalTimeMS) then
                anim:SetEndTime(totalTimeMS);
                anim:SetStartTime(anim:GetEndTime() - length);
                AM.inputState.mousePosStartX = savePrevMouse;
            end

            AM.SetTime(AM.loadedTimeline:GetTime(), false);
            AM.RefreshWorkspace();
        end
    end

    if (AM.inputState.movingAnimHandleL ~= -1) then
        local groupBgH = AM.timebarGroup:GetWidth() - 26;
        local mouseDiff = (AM.inputState.mousePosStartX - Input.mouseXRaw) * Renderer.scale;
        local newPoint = -mouseDiff;

        -- Scroll the items list --
        local newPointNormalized = newPoint / groupBgH;
        local totalTimeMS = AM.loadedTimeline:GetDuration();
        local startMS = AM.currentCrop.min * totalTimeMS;
        local endMS = AM.currentCrop.max * totalTimeMS;
        local lengthMS = endMS - startMS;

        local diffTimeMS = (newPointNormalized * lengthMS);

        if (diffTimeMS ~= 0) then
            local animElement = AM.AnimationPool[AM.inputState.movingAnimHandleL];
            local trackElement = animElement.trackIdx;
            local track = AM.loadedTimeline:GetTrack(animElement.trackIdx);
            local anim = track.animations[animElement.animIdx];
            local desiredStartT = math.floor(anim:GetStartTime() + diffTimeMS);

            -- check left
            local animL = track.animations[animElement.animIdx - 1];
            local length = anim:GetDuration();
            local savePrevMouse = AM.inputState.mousePosStartX;

            if (animL) then
                if (desiredStartT > animL:GetEndTime()) then
                    anim:SetStartTime(desiredStartT);
                    AM.inputState.mousePosStartX = Input.mouseXRaw;
                else
                    anim:SetStartTime(animL:GetEndTime());
                end
            else
                anim:SetStartTime(desiredStartT);
                AM.inputState.mousePosStartX = Input.mouseXRaw;
            end

            -- limit anim to start and end of track
            if (anim:GetStartTime() < 0) then
                anim:SetStartTime(0);
                AM.inputState.mousePosStartX = savePrevMouse;
            elseif(anim:GetEndTime() > totalTimeMS) then
                anim:SetStartTime(totalTimeMS - length);
                AM.inputState.mousePosStartX = savePrevMouse;
            end

            -- limit anim min size to 100 miliseconds
            if (anim:GetStartTime() > anim:GetEndTime() - 100) then
                anim:SetStartTime(anim:GetEndTime() - 100);
                AM.inputState.mousePosStartX = savePrevMouse;
            end

            AM.SetTime(AM.loadedTimeline:GetTime(), false);
            AM.RefreshWorkspace();
        end
    end

    if (AM.inputState.movingAnimHandleR ~= -1) then
        local groupBgH = AM.timebarGroup:GetWidth() - 26;
        local mouseDiff = (AM.inputState.mousePosStartX - Input.mouseXRaw) * Renderer.scale;
        local newPoint = -mouseDiff;

        -- Scroll the items list --
        local newPointNormalized = newPoint / groupBgH;
        local totalTimeMS = AM.loadedTimeline:GetDuration();
        local startMS = AM.currentCrop.min * totalTimeMS;
        local endMS = AM.currentCrop.max * totalTimeMS;
        local lengthMS = endMS - startMS;

        local diffTimeMS = (newPointNormalized * lengthMS);

        if (diffTimeMS ~= 0) then
            local animElement = AM.AnimationPool[AM.inputState.movingAnimHandleR];
            local trackElement = animElement.trackIdx;
            local track = AM.loadedTimeline:GetTrack(animElement.trackIdx);
            local anim = track.animations[animElement.animIdx];
            local desiredEndT = math.floor(anim:GetEndTime() + diffTimeMS);

            -- check right
            local animR = track.animations[animElement.animIdx + 1];
            local length = anim:GetEndTime() - anim:GetStartTime();
            local savePrevMouse = AM.inputState.mousePosStartX;

            if (animR) then
                if (desiredEndT < animR:GetStartTime()) then
                    anim:SetEndTime(desiredEndT);
                    AM.inputState.mousePosStartX = Input.mouseXRaw;
                else
                    anim:SetEndTime(animR:GetStartTime());
                end
            else
                anim:SetEndTime(desiredEndT);
                AM.inputState.mousePosStartX = Input.mouseXRaw;
            end

            -- limit anim to start and end of track
            if (anim:GetStartTime() < 0) then
                anim:SetEndTime(length);
                AM.inputState.mousePosStartX = savePrevMouse;
            elseif(anim:GetEndTime() > totalTimeMS) then
                anim:SetEndTime(totalTimeMS);
                AM.inputState.mousePosStartX = savePrevMouse;
            end

            -- limit anim min size to 100 miliseconds
            if (anim:GetStartTime() > anim:GetEndTime() - 100) then
                anim:SetEndTime(anim:GetStartTime() + 100);
                AM.inputState.mousePosStartX = savePrevMouse;
            end

            AM.SetTime(AM.loadedTimeline:GetTime(), false);
            AM.RefreshWorkspace();
        end
    end

    -- desquash
    if (not isSquashing) then
        if (squash > 0) then
            squash = squash - (squashStrength * 4);
            if (squash <= 0) then
                squash = 0;
                squashIndex = -1;
            end
        end
    end

    if (squash ~= 0 and squashIndex ~= -1) then
        if (squash > 0.5) then
            squash = 0.5;
        end
        local animElement = AM.AnimationPool[squashIndex];
        --animElement:SetScale(1 + squash);
        
        animElement:SetHeight((1 + squash) * AM.trackElementH);
        --local gpointL, grelativeToL, grelativePointL, gxOfsL, gyOfsL = animElement:GetPoint(1);
        --animElement:SetPoint("TOPLEFT", grelativeToL, "TOPLEFT", gxOfsL, gyOfsL + squash * AM.trackElementH);
    end
end

function AM.Round(num, dp)
    --[[
    round a number to so-many decimal of places, which can be negative, 
    e.g. -1 places rounds to 10's,  
    
    examples
        173.2562 rounded to 0 dps is 173.0
        173.2562 rounded to 2 dps is 173.26
        173.2562 rounded to -1 dps is 170.0
    ]]--
    local mult = 10^(dp or 0)
    return math.floor(num * mult + 0.5)/mult
end

function AM.CreateAnimationManager(x, y, w, h, parent, startLevel)

    local timelineTabH = 20;

    AM.groupBG = UI.Rectangle:NewTLBR(x, y, 0, 0, parent, 0, 0, 0, 0);
    AM.groupBG:SetFrameLevel(startLevel);
    AM.groupBG:GetFrame():SetScript("OnSizeChanged",
    function(_, width, height)
        AM.RefreshTimebar();
        AM.RefreshWorkspace();
        if (AM.workAreaScrollbar) then
            if (AM.uiMode == AM.Mode.Tracks) then
                AM.workAreaScrollbar:Resize(height - 106, AM.workAreaList:GetHeight());
            elseif (AM.uiMode == AM.Mode.Keyframes) then
                AM.workAreaScrollbar:Resize(height - 106, AM.keyframeAreaList:GetHeight());
            end
        end
        if (AM.rangeBar) then
            AM.rangeBar:Resize();
        end;

        if (AM.TimeSliderBar) then
            AM.TimeSliderBar:SetHeight(height - 80);
        end
    end);

    AM.parentFrame = parent;
    AM.groupBGy = y;

    AM.tabGroup = UI.TabGroup:NewTLTR(0, 0, 0, 0, tabButtonHeight, AM.groupBG:GetFrame(), startLevel + 2, true);
    AM.tabGroup.dropdownButton.tooltip = L["AM_TT_LIST"];
    AM.tabGroup.addButton.tooltip = L["AM_TT_ADDTIMELINE"];

	AM.tabGroup:SetItemTemplate(
    {
        height = tabButtonHeight,
        lmbAction = function(index)
            AM.LoadTimeline(index);
            AM.RefreshTimelineTabs();
        end,
        rmbAction = function(index, item)
            -- open rmb menu with option to delete, edit, rename the scene
            local point, relativeTo, relativePoint, xOfs, yOfs = item:GetPoint(1);
            local rx = xOfs + (AM.parentFrame:GetLeft() - SceneMachine.mainWindow:GetLeft());
            local ry = (AM.parentFrame:GetTop() - SceneMachine.mainWindow:GetTop()) - item:GetHeight();
            local scale =  SceneMachine.mainWindow:GetEffectiveScale();

            local menuOptions = {
                [1] = { ["Name"] = L["RENAME"], ["Action"] = function() AM.tabGroup:RenameTab(index, item, AM.RenameTimeline); end },
                [2] = { ["Name"] = L["EDIT"], ["Action"] = function()  AM.Button_EditTimeline(index) end },
                [3] = { ["Name"] = L["DELETE"], ["Action"] = function() AM.Button_DeleteTimeline(index); end },
            };

            SceneMachine.mainWindow:PopupWindowMenu(rx * scale, ry * scale, menuOptions);
        end,
        addAction = function(text) AM.CreateTimeline(text) end,
        refreshItem = function(data, item, index)
            -- timeline name text --
            item.components[2]:SetWidth(1000);
            item.components[2]:SetText(data.name);
            local strW = item.components[2].frame.text:GetStringWidth() + 20;
            item:SetWidth(strW);
            item.components[1]:SetWidth(strW);
            item.components[2]:SetWidth(strW);
            return strW;
        end,
        defaultTabName = "Timeline",
    });

    local bottomPad = 4;
    local toolbarH = 25;
    local toolbarY = -timelineTabH
    local timebarH = 25;
    local timebarY = -timelineTabH - toolbarH;
    local cropperBarH = 16;
    local cropperBarY = bottomPad;
    local keyframeBarX = 10;
    local keyframeBarY = -(timebarH + timelineTabH + toolbarH);
    local keyframeBarW = w - 20;
    local keyframeBarH = 15;
    local workAreaX = 10;
    local workAreaY = -(timebarH + timelineTabH + toolbarH + keyframeBarH);
    local workAreaW = w - 20;
    local workAreaH = h - (timelineTabH + timebarH + cropperBarH + bottomPad + toolbarH + keyframeBarH);
    local curveViewH = h - (timelineTabH + timebarH + cropperBarH + bottomPad + toolbarH);
    local curveViewY = -(timebarH + timelineTabH + toolbarH);
    AM.CreateTimebar(0, timebarY, w, timebarH, AM.groupBG:GetFrame(), startLevel + 3);
    AM.CreateTimeSlider(workAreaH, startLevel + 5);
    AM.CreateToolbar(0, toolbarY, w, toolbarH, AM.groupBG:GetFrame(), startLevel + 3);
    AM.CreateMainKeyframeBar(keyframeBarX, keyframeBarY, keyframeBarW, keyframeBarH, AM.groupBG:GetFrame(), startLevel + 3)
    AM.CreateWorkArea(workAreaX - 6, workAreaY, workAreaW, workAreaH, AM.groupBG:GetFrame(), startLevel + 3);
    AM.CreateKeyframeView(workAreaX - 6, workAreaY, workAreaW, workAreaH, AM.groupBG:GetFrame(), startLevel + 3);
    AM.CreateCurveView(workAreaX - 6, curveViewY, workAreaW, curveViewH, AM.groupBG:GetFrame(), startLevel + 3);

    local onRangeChange = function(min, max)
        AM.currentCrop.min = min;
        AM.currentCrop.max = max;
        --print(min, max);
        AM.RefreshTimebar();
        AM.RefreshWorkspace();
    end
    AM.rangeBar = UI.RangeScrollbar:New(x, cropperBarY, cropperBarH, AM.groupBG:GetFrame(), onRangeChange);
    AM.rangeBar:SetFrameLevel(startLevel + 3);
    AM.rangeBar:SetRange(AM.currentCrop.min, AM.currentCrop.max);

    AM.CreateAnimationSelectWindow(0, 0, 300, 500);

    AM.RefreshTimelineTabs();
    AM.RefreshTimebar();

    AM.ChangeUIMode(AM.uiMode);
    AM.RefreshWorkspace();
end

function AM.CreateAnimationSelectWindow(x, y, w, h)
    AM.animSelectWindow = UI.Window:New(x, y, w, h, SceneMachine.mainWindow:GetFrame(), "CENTER", "CENTER", L["AM_ANIMATION_LIST_WINDOW_TITLE"]);
    AM.animSelectWindow:SetFrameStrata(Editor.SUB_FRAME_STRATA);
    AM.animSelectWindow:MakeWholeWindowDraggable();

    AM.animScrollList = UI.PooledScrollList:NewTLBR(0, 0, 0, 30, AM.animSelectWindow:GetFrame());
	AM.animScrollList:SetItemTemplate(
		{
            replaceAnim = nil,
			height = 20,
			buildItem = function(item)
				-- main button --
				item.components[1] = UI.Button:NewAP(item:GetFrame(), "");

				-- anim name text --
				item.components[2] = UI.Label:New(10, 0, 200, 18, item.components[1]:GetFrame(), "LEFT", "LEFT", "", 9);
			end,
			refreshItem = function(entry, item)
                -- interpret data --
                local animID = entry[1];
                local animVariant = entry[2];
                local name = SceneMachine.animationNames[animID];
                name = name or ("Anim_" .. animID);

                if (animVariant ~= 0) then
                    name = name .. " " .. animVariant;
                end

                -- main button --
				item.components[1]:SetScript("OnClick", function()
                    AM.selectedAnimID = animID;
                    AM.selectedAnimVariant = animVariant;
                    if (#SM.selectedObjects > 0) then
                        SM.selectedObjects[1]:PlayAnimID(animID, animVariant);
                    end
                    AM.animScrollList:RefreshStatic();
                end);

				if (animID == AM.selectedAnimID and animVariant == AM.selectedAnimVariant) then
					item.components[1]:SetColor(UI.Button.State.Normal, 0, 0.4765, 0.7968, 1);
				else
					item.components[1]:SetColor(UI.Button.State.Normal, 0.1757, 0.1757, 0.1875, 1);
				end

				-- object name text --
				item.components[2]:SetText(name);
			end,
	    }
    );

    -- Override close window button
    AM.animSelectWindow.closeButton:SetScript("OnClick", function()
        AM.animSelectWindow:Hide();
        -- reset preview animation to Stand
        if (#SM.selectedObjects > 0) then
            SM.selectedObjects[1]:PlayAnimID(0);
        end
    end);

    AM.animScrollList:SetFrameLevel(10);
	AM.animScrollList:MakePool();

    AM.animSelectWindow.loadAnimBtn = UI.Button:New(5, 5, 70, 20, AM.animSelectWindow:GetFrame(), "BOTTOMLEFT", "BOTTOMLEFT", L["AM_BUTTON_ADD_ANIMATION"], nil);
    AM.animSelectWindow.loadAnimBtn:SetScript("OnClick", function(self)
        if (not AM.animScrollList.replaceAnim) then
            AM.AddAnim(AM.selectedTrack, AM.selectedAnimID, AM.selectedAnimVariant);
        else
            AM.ReplaceAnim(AM.selectedTrack, AM.animScrollList.replaceAnim, AM.selectedAnimID, AM.selectedAnimVariant);
        end
        AM.animSelectWindow:Hide();
        AM.SetTime(AM.loadedTimeline:GetTime());
    end);
    AM.animSelectWindow.filterBox = UI.TextBox:NewBLBR(80, 5, -5, 0, 20, AM.animSelectWindow:GetFrame(), "", 9);
    AM.animSelectWindow.filterBox:SetScript("OnTextChanged", function(self, userInput) AM.FilterAnimList(self:GetText()); end );
    AM.animSelectWindow:Hide();
end

function AM.FilterAnimList(text)
    if (not AM.selectedTrack) then return; end

    local obj = AM.GetObjectOfTrack(AM.selectedTrack);

    if (not obj) then return; end

    local animData = SceneMachine.animationData[obj.fileID];
    if (not text or text == "") then
        AM.animScrollList:SetData(animData);
    else
        local animDataFiltered = {};
        local fI = 1;
        for i = 1, #animData, 1 do
            local anim = animData[i];
            local animID = anim[1];
            local name = SceneMachine.animationNames[animID];
            if (name) then
                local startIdx, endIdx = string.find(name:lower(), text:lower());
                if (startIdx) then
                    animDataFiltered[fI] = anim;
                    fI = fI + 1;
                end
            end
        end
        AM.animScrollList:SetData(animDataFiltered);
    end
end

function AM.CreateTimebar(x, y, w, h, parent, startLevel)
    AM.timebarGroup = CreateFrame("Button", "AM.TimebarGroup", parent)
	AM.timebarGroup:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y);
    AM.timebarGroup:SetPoint("TOPRIGHT", parent, "TOPRIGHT", x, y);
	AM.timebarGroup:SetHeight(h);
    AM.timebarGroup.ntex = AM.timebarGroup:CreateTexture();
    AM.timebarGroup.ntex:SetColorTexture(c4[1], c4[2], c4[3], 1)
    --element.ntex:SetTexCoord(0, 0.5, 0, 0.5);    -- (left,right,top,bottom)
    AM.timebarGroup.ntex:SetAllPoints();
    AM.timebarGroup:SetNormalTexture(AM.timebarGroup.ntex);
    AM.timebarGroup:RegisterForClicks("LeftButtonUp", "LeftButtonDown");
    AM.timebarGroup:SetScript("OnMouseDown", function(self, button)
        AM.inputState.movingTime = true;
        AM.inputState.timebarFramePosStart = AM.timebarGroup:GetLeft();
        AM.inputState.mousePosStartX = Input.mouseXRaw;
    end);
    AM.timebarGroup:SetScript("OnMouseUp", function(self, button) AM.inputState.movingTime = false; end);
    AM.timebarGroup:SetFrameLevel(startLevel);

    for i = 1, AM.needlePoolSize, 1 do
        local needle = AM.CreateNeedle();
        AM.needles[i] = needle;
    end
end

function AM.CreateMainKeyframeBar(x, y, w, h, parent, startLevel)
    AM.mainKeyframeBar = CreateFrame("Button", "AM.mainKeyframeBar", parent)
	AM.mainKeyframeBar:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, y);
    AM.mainKeyframeBar:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, y);
	AM.mainKeyframeBar:SetSize(w, h);
    AM.mainKeyframeBar.ntex = AM.mainKeyframeBar:CreateTexture();
    AM.mainKeyframeBar.ntex:SetColorTexture(0, 0, 0, 0.5);
    AM.mainKeyframeBar.ntex:SetAllPoints();
    AM.mainKeyframeBar:SetNormalTexture(AM.mainKeyframeBar.ntex);
    AM.mainKeyframeBar:RegisterForClicks("LeftButtonUp", "LeftButtonDown");
    AM.mainKeyframeBar:SetFrameLevel(startLevel);
    AM.mainKeyframeBar:SetScript("OnClick", function() AM.SelectKeyAtIndex(-1); end);


    AM.KeyframePool = {};
    for i = 1, AM.KeyframePoolSize, 1 do
        AM.KeyframePool[i] = AM.GenerateKeyframeElement(i, 0, 0, AM.keyframeElementH, AM.keyframeElementH, AM.mainKeyframeBar, 0.5, 0.5, 0.5, 1);
        AM.KeyframePool[i]:SetFrameLevel(startLevel + 1);
        AM.KeyframePool[i]:Hide();
    end
end

function AM.GenerateKeyframeElement(index, x, y, w, h, parent, R, G, B, A)
    local element = CreateFrame("Button", "AM.KeyframeElement"..index, parent)
	element:SetPoint("LEFT", parent, "LEFT", x, y);
	element:SetSize(w, h);
    element:SetFrameLevel(100);
    element.ntex = element:CreateTexture();
    element.ntex:SetTexture(Resources.textures["Keyframe"]);
    element.ntex:SetTexCoord(0, 0.25, 0, 0.25);
    element.ntex:SetAllPoints();
    element.ntex:SetVertexColor(R, G, B, A);
    element:SetNormalTexture(element.ntex);
    element:RegisterForClicks("LeftButtonUp", "LeftButtonDown");
    element:SetScript("OnMouseDown", function(self, button)
        if (button == "LeftButton") then
            local track = AM.loadedTimeline:GetTrack(self.trackIdx);
            Editor.StartAction(Actions.Action.Type.TrackKeyframes, track, AM.loadedTimeline);
            if (SceneMachine.Input.ShiftModifier) then
                -- clone keys
                AM.CloneSelectedKeys();
            end
            AM.inputState.movingKeyframe = true;
            AM.inputState.timebarFramePosStart = element:GetLeft();
            AM.inputState.timeStart = nil;
            AM.inputState.mousePosStartX = Input.mouseXRaw;
        end
    end);
    element:SetScript("OnMouseUp", function(self, button)
        AM.inputState.movingKeyframe = false;
        AM.inputState.timeStart = nil;
        AM.OnFinishedKeyRetiming();
    end);
    element:SetScript("OnClick", function (self, button, down)
        if (button == "LeftButton" and down) then
            AM.SelectKeyAtIndex(index);
            AM.SelectAnimation(-1);
        end
    end)

    return element;
end

function AM.CloneSelectedKeys()
    AM.clonedKeys = {};
    for i = 1, #AM.selectedKeys, 1 do
        local key = AM.selectedKeys[i];
        local newKey = Keyframe:NewClone(key);

        if (AM.keyframeGroups[AM.selectedKeyGroup].px == key) then
            if (AM.selectedTrack.keysPx) then
                AM.selectedTrack.keysPx[#AM.selectedTrack.keysPx + 1] = newKey;
                AM.clonedKeys[i] = newKey;
            end
        end
        if (AM.keyframeGroups[AM.selectedKeyGroup].py == key) then
            if (AM.selectedTrack.keysPy) then
                AM.selectedTrack.keysPy[#AM.selectedTrack.keysPy + 1] = newKey;
                AM.clonedKeys[i] = newKey;
            end
        end
        if (AM.keyframeGroups[AM.selectedKeyGroup].pz == key) then
            if (AM.selectedTrack.keysPz) then
                AM.selectedTrack.keysPz[#AM.selectedTrack.keysPz + 1] = newKey;
                AM.clonedKeys[i] = newKey;
            end
        end
        
        if (AM.keyframeGroups[AM.selectedKeyGroup].rx == key) then
            if (AM.selectedTrack.keysRx) then
                AM.selectedTrack.keysRx[#AM.selectedTrack.keysRx + 1] = newKey;
                AM.clonedKeys[i] = newKey;
            end
        end
        if (AM.keyframeGroups[AM.selectedKeyGroup].ry == key) then
            if (AM.selectedTrack.keysRy) then
                AM.selectedTrack.keysRy[#AM.selectedTrack.keysRy + 1] = newKey;
                AM.clonedKeys[i] = newKey;
            end
        end
        if (AM.keyframeGroups[AM.selectedKeyGroup].rz == key) then
            if (AM.selectedTrack.keysRz) then
                AM.selectedTrack.keysRz[#AM.selectedTrack.keysRz + 1] = newKey;
                AM.clonedKeys[i] = newKey;
            end
        end

        if (AM.keyframeGroups[AM.selectedKeyGroup].s == key) then
            if (AM.selectedTrack.keysS) then
                AM.selectedTrack.keysS[#AM.selectedTrack.keysS + 1] = newKey;
                AM.clonedKeys[i] = newKey;
            end
        end

        if (AM.keyframeGroups[AM.selectedKeyGroup].a == key) then
            if (AM.selectedTrack.keysA) then
                AM.selectedTrack.keysA[#AM.selectedTrack.keysA + 1] = newKey;
                AM.clonedKeys[i] = newKey;
            end
        end
    end
    
    AM.selectedTrack:SortAllKeyframes();
end

function AM.GetAvailableKeyframeElement()
    local i = AM.usedKeyframes + 1;
    AM.usedKeyframes = AM.usedKeyframes + 1;

    if (i > #AM.KeyframePool) then
        AM.KeyframePool[i] = AM.GenerateKeyframeElement(i, 0, 0, AM.keyframeElementH, AM.keyframeElementH, AM.mainKeyframeBar, 0.5, 0.5, 0.5, 1);
    end

    return AM.KeyframePool[i];
end

function AM.CreateTimeSlider(workAreaH, startLevel)
    local c = { 0.9, 0.2, 0.2 };
    AM.TimeSlider = UI.ImageBox:New(20, 0, 20, 20, AM.timebarGroup, "CENTER", "LEFT", Resources.textures["TimeSlider"]);
    AM.TimeSlider:SetVertexColor(c[1], c[2], c[3], 1);
    AM.TimeSlider:SetFrameLevel(startLevel);
    
    AM.TimeSliderBar = UI.Rectangle:New(0, 0, 1, workAreaH + 10, AM.TimeSlider:GetFrame(), "TOP", "CENTER",  c[1], c[2], c[3], 1);
    AM.TimeSliderBar:SetFrameLevel(startLevel);
end

function AM.CreateNeedle()
    local needle = UI.ImageBox:New(0, 0, 10, 4, AM.timebarGroup, "TOPLEFT", "TOPLEFT", Resources.textures["TimeNeedle"]);
    needle:SetVertexColor(1,1,1,0.7);
    needle.text = needle:GetFrame():CreateFontString("needle text");
	needle.text:SetFont(Resources.defaultFont, 8, "NORMAL");
	needle.text:SetPoint("TOP", needle.frame, "TOP", 0, 12);
    needle.text:SetSize(30, 10);
    needle.text:SetTextColor(1,1,1,0.5);
	needle.text:SetJustifyV("CENTER");
	needle.text:SetJustifyH("CENTER");
    needle:Hide();
    needle:SetFrameLevel(AM.timebarGroup:GetFrameLevel() + 1);
    return needle;
end

function AM.GetNeedle()
    local i = AM.usedNeedles + 1;
    AM.usedNeedles = AM.usedNeedles + 1;

    if i < #AM.needles then
        local needle = AM.needles[i];
        return needle;
    else
        -- create new needle
        local needle = AM.CreateNeedle();
        AM.needles[i] = needle;
        return needle;
    end
end

function AM.CreateToolbar(x, y, w, h, parent, startLevel)
    local toolbar = UI.Toolbar:New(x, y, w, h, parent, SceneMachine.mainWindow, Resources.iconData["AnimToolbar"]);
    toolbar:SetFrameLevel(startLevel);
    local mainGroup = toolbar:CreateGroup(x, 0, w, h,
    {
        {
            type = "Dropdown", name = "UIMode", width = 100, options = { L["AM_TOOLBAR_TRACKS"], L["AM_TOOLBAR_KEYFRAMES"], L["AM_TOOLBAR_CURVES"] },
            action = function(index) AM.Dropdown_SetUIMode(index); end, tooltip = L["AM_TOOLBAR_TT_UIMODE"], tooltipDetailed = L["AM_TOOLBAR_TTD_UIMODE"],
        },
        { type = "Separator", name = "Separator1" },
        {
            type = "Button", name = "AddObject", icon = toolbar:GetIcon("addobj"), action = function(self) AM.AddTracks(SM.selectedObjects); end,
            tooltip = L["AM_TOOLBAR_TT_ADD_TRACK"], tooltipDetailed = L["AM_TOOLBAR_TTD_ADD_TRACK"],
        },
        { 
            type = "Button", name = "RemoveObject", icon = toolbar:GetIcon("removeobj"), action = function(self) AM.RemoveTracks({ AM.selectedTrack }); end,
            tooltip = L["AM_TOOLBAR_TT_REMOVE_TRACK"],
        },
        { type = "Separator", name = "Separator2" },
        { 
            type = "Button", name = "AddAnim", icon = toolbar:GetIcon("addanim"), action = function(self) AM.OpenAddAnimationWindow(AM.selectedTrack); end,
            tooltip = L["AM_TOOLBAR_TT_ADD_ANIMATION"], tooltipDetailed = L["AM_TOOLBAR_TTD_ADD_ANIMATION"],
        },
        {
            type = "Button", name = "RemoveAnim", icon = toolbar:GetIcon("removeanim"), action = function(self) AM.RemoveAnim(AM.selectedTrack, AM.selectedAnim); end,
            tooltip = L["AM_TOOLBAR_TT_REMOVE_ANIMATION"],
        },
        { type = "Separator", name = "Separator3" },
        {
            type = "SplitButton", name = "AddKey", icons = { toolbar:GetIcon("addkey"), toolbar:GetIcon("addposkey"), toolbar:GetIcon("addrotkey"), toolbar:GetIcon("addscalekey") },
            splitaction = function(v) AM.Button_SetKeyAddMode(v); end, action = function() AM.Button_AddKey(); end,
            tooltip = L["AM_TOOLBAR_TT_ADD_KEYFRAME"], tooltipDetailed = L["AM_TOOLBAR_TTD_ADD_KEYFRAME"],
        },
        { type = "Button", name = "RemoveKey", icon = toolbar:GetIcon("removekey"), action = function(self)
            AM.RemoveKeys(AM.selectedTrack, AM.selectedKeys); end,
            tooltip = L["AM_TOOLBAR_TT_REMOVE_KEYFRAME"],
        },
        { type = "Separator", name = "Separator4" },
        {
            type = "SplitButton", name = "InterpolationIn",
            icons = { toolbar:GetIcon("ismooth"), toolbar:GetIcon("ilinear"), toolbar:GetIcon("istep"), toolbar:GetIcon("islow"), toolbar:GetIcon("ifast") },
            splitaction = function(v) AM.Button_SetInterpolationInMode(v); end, action = function() AM.Button_SetKeyInterpolationIn(); end,
            tooltip = L["AM_TOOLBAR_TT_SET_INTERPOLATION_IN"], tooltipDetailed = L["AM_TOOLBAR_TTD_SET_INTERPOLATION_IN"],
        },
        {
            type = "SplitButton", name = "InterpolationOut",
            icons = { toolbar:GetIcon("osmooth"), toolbar:GetIcon("olinear"), toolbar:GetIcon("ostep"), toolbar:GetIcon("oslow"), toolbar:GetIcon("ofast") },
            splitaction = function(v) AM.Button_SetInterpolationOutMode(v); end, action = function() AM.Button_SetKeyInterpolationOut(); end,
            tooltip = L["AM_TOOLBAR_TT_SET_INTERPOLATION_OUT"], tooltipDetailed = L["AM_TOOLBAR_TTD_SET_INTERPOLATION_OUT"],
        },
        { type = "DragHandle" },
        {
            type = "Button", name = "SeekToStart", icon = toolbar:GetIcon("skiptoend", true), action = function(self) AM.SeekToStartButton_OnClick(); end,
            tooltip = L["AM_TOOLBAR_TT_SEEK_TO_START"],
        },
        {
            type = "Button", name = "SkipOneFrameBack", icon = toolbar:GetIcon("skiponeframe", true), action = function(self) AM.SkipFrameBackwardButton_OnClick(); end,
            tooltip = L["AM_TOOLBAR_TT_SKIP_FRAME_BACK"],
        },
        {
            type = "Toggle", name = "PlayPause", iconOn = toolbar:GetIcon("pause"), iconOff = toolbar:GetIcon("play"), action = function(self, on) AM.PlayToggle_OnClick(on); end,
            default = false, tooltip = L["AM_TOOLBAR_TT_PLAY_PAUSE"],
        },
        {
            type = "Button", name = "SkipOneFrameForward", icon = toolbar:GetIcon("skiponeframe"), action = function(self) AM.SkipFrameForwardButton_OnClick(); end,
            tooltip = L["AM_TOOLBAR_TT_SKIP_FRAME_FORWARD"],
        },
        {
            type = "Button", name = "SeekToEnd", icon = toolbar:GetIcon("skiptoend"), action = function(self) AM.SeekToEndButton_OnClick(); end,
            tooltip = L["AM_TOOLBAR_TT_SEEK_TO_END"],
        },
        { type = "Separator", name = "Separator5" },
        {
            type = "Toggle", name = "Loop", iconOn = toolbar:GetIcon("loop"), iconOff = toolbar:GetIcon("loopoff"), action = function(self, on) AM.LoopToggle_OnClick(on); end,
            default = true, tooltip = L["AM_TOOLBAR_TT_LOOP"],
        },
        {
            type = "Toggle", name = "Loop", iconOn = toolbar:GetIcon("cameraplayon"), iconOff = toolbar:GetIcon("cameraplayoff"), action = function(self, on) AM.CameraToggle_OnClick(on); end,
            default = false, tooltip = L["AM_TOOLBAR_TT_PLAYCAMERA"],
        },
        { type = "Separator", name = "Separator6" },
    });
    mainGroup:SetFrameLevel(startLevel + 1);
    AM.mainToolbar = toolbar;
    AM.mainToolbarGroup = mainGroup;

    -- timer
    AM.timerTextBox = UI.Button:New(0, 0, 90, h, mainGroup:GetFrame(), "RIGHT", "RIGHT", "00:00 / 00:00");
    AM.timerTextBox:SetFont(Resources.fonts["Digital"], 16);
    AM.timerTextBox:SetFrameLevel(startLevel + 2);
    AM.timerTextBox:SetScript("OnClick", function()
        local currentDuration = AM.loadedTimeline:GetDuration();
        -- convert from miliseconds to seconds
        local action = function(text)
            local value = tonumber(text);
            if (value) then
                AM.loadedTimeline:SetDuration(value * 1000);
                AM.RefreshWorkspace();
                AM.RefreshTimebar();
            end
        end;
        Editor.OpenQuickTextbox(action, tostring(currentDuration / 1000), L["AM_TIMER_SET_DURATION"]);
    end);
end

function AM.CreateWorkArea(x, y, w, h, parent, startLevel)
    AM.workAreaBG = UI.Rectangle:NewTLBR(x, y, -6, 20, parent, 0, 0, 0, 0);
    AM.workAreaBG:GetFrame():SetClipsChildren(true);
    AM.workAreaBG:SetFrameLevel(startLevel + 1);

    AM.workAreaViewport = CreateFrame("Button", "AM.workAreaViewport", AM.workAreaBG:GetFrame())
	AM.workAreaViewport:SetPoint("TOPLEFT", AM.workAreaBG:GetFrame(), "TOPLEFT", 0, 0);
    AM.workAreaViewport:SetPoint("BOTTOMRIGHT", AM.workAreaBG:GetFrame(), "BOTTOMRIGHT", -10, 0);
	AM.workAreaViewport:SetSize(w, h);
    AM.workAreaViewport.ntex = AM.workAreaViewport:CreateTexture();
    AM.workAreaViewport.ntex:SetColorTexture(c4[2], c4[3], c4[3], 1);
    AM.workAreaViewport.ntex:SetAllPoints();
    AM.workAreaViewport:SetNormalTexture(AM.workAreaViewport.ntex);
    AM.workAreaViewport:RegisterForClicks("LeftButtonUp", "LeftButtonDown");
    AM.workAreaViewport:SetFrameLevel(startLevel + 1);
    AM.workAreaViewport:SetScript("OnClick", function (self, button, down)
        if (button == "LeftButton" and down) then
            AM.SelectAnimation(-1);
            AM.SelectTrack(-1);
            AM.SelectKeyAtIndex(-1);
            SM.SelectObject(nil);
        end
    end)

    AM.workAreaList = UI.Rectangle:NewTLTR(0, 0, 0, 0, h, AM.workAreaViewport, c4[1], c4[2], c4[3], 1);
    AM.workAreaList:SetFrameLevel(startLevel + 2);

    AM.TrackPool = {};
    for i = 1, AM.TrackPoolSize, 1 do
        AM.TrackPool[i] = AM.GenerateTrackElement(i, 0, -((AM.trackElementH + Editor.pmult) * (i - 1)), w, AM.trackElementH, AM.workAreaList:GetFrame(), c2[1], c2[2], c2[3], c2[4]);
        AM.TrackPool[i]:SetFrameLevel(startLevel + 3);
    end

    AM.AnimationPool = {};
    for i = 1, AM.AnimationPoolSize, 1 do
        AM.AnimationPool[i] = AM.GenerateAnimationElement(i, 0, 0, AM.trackElementH, AM.trackElementH, AM.workAreaList:GetFrame(), c2[1], c2[2], c2[3], c2[4]);
        AM.AnimationPool[i]:SetFrameLevel(startLevel + 4);
    end

    -- track selection box thing
    AM.trackSelectionBox = UI.Rectangle:New(-6, 0, 5, AM.trackElementH, AM.workAreaList:GetFrame(), "TOPLEFT", "TOPLEFT",  c3[1], c3[2], c3[3], c3[4]);
    AM.trackSelectionBox:SetFrameLevel(startLevel + 4);
    AM.trackSelectionBox:Hide();

    -- animation selection box thing
    AM.animationSelectionBox = UI.Rectangle:New(0, 0, AM.trackElementH, AM.trackElementH, AM.workAreaList:GetFrame(), "TOPLEFT", "TOPLEFT",  1, 1, 1, 0);
    AM.animationSelectionBox:SetFrameLevel(startLevel + 5);

    local thickness = 2 + Editor.pmult;

    local lineTop = AM.animationSelectionBox:GetFrame():CreateLine(nil, nil, nil);
    local c = { 1, 1, 1, 0.5 };
    lineTop:SetThickness(thickness);
    lineTop:SetTexture(Resources.textures["DashedLine"], "REPEAT", "REPEAT", "NEAREST");
    lineTop:Show();
    lineTop:SetVertexColor(c[1], c[2], c[3], c[4]);
    lineTop:SetStartPoint("TOPLEFT", 0, -thickness / 2) -- start topleft
    lineTop:SetEndPoint("TOPRIGHT", 0, -thickness / 2)   -- end bottomright
    lineTop:SetTexCoord(0, 10, 0, 1);

    local lineBottom = AM.animationSelectionBox:GetFrame():CreateLine(nil, nil, nil);
    lineBottom:SetThickness(thickness);
    lineBottom:SetTexture(Resources.textures["DashedLine"], "REPEAT", "REPEAT", "NEAREST");
    lineBottom:Show();
    lineBottom:SetVertexColor(c[1], c[2], c[3], c[4]);
    lineBottom:SetStartPoint("BOTTOMLEFT", 0, thickness / 2) -- start topleft
    lineBottom:SetEndPoint("BOTTOMRIGHT", 0, thickness / 2)   -- end bottomright
    lineBottom:SetTexCoord(0, 10, 0, 1);

    local lineLeft = AM.animationSelectionBox:GetFrame():CreateLine(nil, nil, nil);
    lineLeft:SetThickness(thickness);
    lineLeft:SetTexture(Resources.textures["DashedLine"], "REPEAT", "REPEAT", "NEAREST");
    lineLeft:Show();
    lineLeft:SetVertexColor(c[1], c[2], c[3], c[4]);
    lineLeft:SetStartPoint("BOTTOMLEFT", thickness / 2, 0) -- start topleft
    lineLeft:SetEndPoint("TOPLEFT", thickness / 2, 0)   -- end bottomright
    lineLeft:SetTexCoord(0, 2.5, 0, 1);

    local lineRight = AM.animationSelectionBox:GetFrame():CreateLine(nil, nil, nil);
    lineRight:SetThickness(thickness);
    lineRight:SetTexture(Resources.textures["DashedLine"], "REPEAT", "REPEAT", "NEAREST");
    lineRight:Show();
    lineRight:SetVertexColor(c[1], c[2], c[3], c[4]);
    lineRight:SetStartPoint("BOTTOMRIGHT", -thickness / 2, 0) -- start topleft
    lineRight:SetEndPoint("TOPRIGHT", -thickness / 2, 0)   -- end bottomright
    lineRight:SetTexCoord(0, 2.5, 0, 1);

    AM.animationSelectionBox.lineTop = lineTop;
    AM.animationSelectionBox.lineBottom = lineBottom;
    AM.animationSelectionBox.lineLeft = lineLeft;
    AM.animationSelectionBox.lineRight = lineRight;
    AM.animationSelectionBox:Hide();

	AM.workAreaScrollbar = UI.Scrollbar:NewTRBR(0, y, 0, 20, 16, AM.groupBG:GetFrame(),
	function(value)
		-- on scroll
        if (AM.uiMode == AM.Mode.Tracks) then
            local height = AM.workAreaList:GetHeight() - AM.workAreaViewport:GetHeight();
            local pos = value * height;
            AM.workAreaList:ClearAllPoints();
            AM.workAreaList:SetPoint("TOPLEFT", AM.workAreaViewport, "TOPLEFT", 0, math.floor(pos));
            AM.workAreaList:SetPoint("TOPRIGHT", AM.workAreaViewport, "TOPRIGHT", 0, math.floor(pos));
        elseif (AM.uiMode == AM.Mode.Keyframes) then
            local height = AM.keyframeAreaList:GetHeight() - AM.keyframeViewport:GetHeight();
            local pos = value * height;
            AM.keyframeAreaList:ClearAllPoints();
            AM.keyframeAreaList:SetPoint("TOPLEFT", AM.keyframeViewport, "TOPLEFT", 0, math.floor(pos));
            AM.keyframeAreaList:SetPoint("TOPRIGHT", AM.keyframeViewport, "TOPRIGHT", 0, math.floor(pos));
        end
	end);
    AM.workAreaScrollbar:SetFrameLevel(startLevel + 6);

    AM.workAreaCreated = true;
end

function AM.CreateKeyframeView(x, y, w, h, parent, startLevel)
    AM.keyframeViewBG = UI.Rectangle:NewTLBR(x, y, 0, 20, parent, 0, 0, 0, 0);
    AM.keyframeViewBG:GetFrame():SetClipsChildren(true);
    AM.keyframeViewBG:SetFrameLevel(startLevel + 1);

    AM.keyframeViewport = CreateFrame("Button", "AM.keyframeViewport", AM.keyframeViewBG:GetFrame())
	AM.keyframeViewport:SetPoint("TOPLEFT", AM.keyframeViewBG:GetFrame(), "TOPLEFT", 0, 0);
    AM.keyframeViewport:SetPoint("BOTTOMRIGHT", AM.keyframeViewBG:GetFrame(), "BOTTOMRIGHT", -10, 0);
	AM.keyframeViewport:SetSize(w, h);
    AM.keyframeViewport.ntex = AM.keyframeViewport:CreateTexture();
    AM.keyframeViewport.ntex:SetColorTexture(c4[2], c4[3], c4[3], 1);
    AM.keyframeViewport.ntex:SetAllPoints();
    AM.keyframeViewport:SetNormalTexture(AM.keyframeViewport.ntex);
    AM.keyframeViewport:RegisterForClicks("LeftButtonUp", "LeftButtonDown");
    AM.keyframeViewport:SetFrameLevel(startLevel + 1);
    AM.keyframeViewport:SetScript("OnClick", function() AM.SelectKeyAtIndex(-1); end);

    AM.keyframeAreaList = UI.Rectangle:NewTLTR(0, 0, -6, 0, h, AM.keyframeViewport, c4[1], c4[2], c4[3], 1);
    AM.keyframeAreaList:SetFrameLevel(startLevel + 2);

    AM.keyframeBars = {};
    local barSize = 16;
    local barCount = 12;
    AM.keyframeAreaList:SetHeight(barSize * barCount);
    
    local positionText = UI.Label:New(0, 0, 200, barSize, AM.keyframeAreaList:GetFrame(), "TOPLEFT", "TOPLEFT", L["POSITION"]);
    AM.keyframeBars[1] = AM.CreateKeyframeBarElement(0, -barSize, barSize, AM.keyframeAreaList:GetFrame());
    AM.keyframeBars[2] = AM.CreateKeyframeBarElement(0, -barSize * 2, barSize, AM.keyframeAreaList:GetFrame());
    AM.keyframeBars[3] = AM.CreateKeyframeBarElement(0, -barSize * 3, barSize, AM.keyframeAreaList:GetFrame());

    local rotationText = UI.Label:New(0, -barSize * 4, 200, barSize, AM.keyframeAreaList:GetFrame(), "TOPLEFT", "TOPLEFT", L["ROTATION"]);
    AM.keyframeBars[4] = AM.CreateKeyframeBarElement(0, -barSize * 5, barSize, AM.keyframeAreaList:GetFrame());
    AM.keyframeBars[5] = AM.CreateKeyframeBarElement(0, -barSize * 6, barSize, AM.keyframeAreaList:GetFrame());
    AM.keyframeBars[6] = AM.CreateKeyframeBarElement(0, -barSize * 7, barSize, AM.keyframeAreaList:GetFrame());

    local scaleText = UI.Label:New(0, -barSize * 8, 200, barSize, AM.keyframeAreaList:GetFrame(), "TOPLEFT", "TOPLEFT", L["SCALE"]);
    AM.keyframeBars[7] = AM.CreateKeyframeBarElement(0, -barSize * 9, barSize, AM.keyframeAreaList:GetFrame());

    local alphaText = UI.Label:New(0, -barSize * 10, 200, barSize, AM.keyframeAreaList:GetFrame(), "TOPLEFT", "TOPLEFT", L["ALPHA"]);
    AM.keyframeBars[8] = AM.CreateKeyframeBarElement(0, -barSize * 11, barSize, AM.keyframeAreaList:GetFrame());
end

function AM.CreateKeyframeBarElement(x, y, h, parent)
    local element = CreateFrame("Button", "AM.KeyframeBarElement", parent)
    element:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y);
    element:SetPoint("TOPRIGHT", parent, "TOPRIGHT", x, y);
    element:SetHeight(h);
    element:SetFrameLevel(8);
    element.ntex = element:CreateTexture();
    element.ntex:SetTexture(Resources.textures["Animation"]);
    element.ntex:SetTexCoord(0, 0.5, 0, 0.5);    -- (left,right,top,bottom)
    element.ntex:SetAllPoints();
    element.ntex:SetVertexColor(0.2, 0.2, 0.2, 1);
    element:SetNormalTexture(element.ntex);
    element:SetScript("OnClick", function() AM.SelectKeyAtIndex(-1); end);
    
    return element;
end

function AM.CreateCurveView(x, y, w, h, parent, startLevel)
    AM.curveViewBG = UI.Rectangle:New(x, y, w, h, parent, "TOPLEFT", "TOPLEFT",  0, 0, 0, 1);
    AM.curveViewBG:SetFrameLevel(startLevel);

    --[[
    -- create line pool
    AM.CurvePool = {};
    for i = 1, AM.CurvePoolSize, 1 do
        AM.CurvePool[i] = AM.CreateCurveLineElement();
    end
    --]]
end
--[[
function AM.CreateCurveLineElement()
    local line = AM.curveViewBG:GetFrame():CreateLine(nil, nil, nil);
    line:SetThickness(1 + Editor.pmult);
    line:SetTexture(Resources.textures["Line"], "REPEAT", "REPEAT");
    line:SetVertexColor(1,1,1,1);
    line:Hide();
    return line;
end

function AM.GetAvailableCurvePoolLineElement()
    local i = AM.usedCurveLines + 1;
    AM.usedCurveLines = AM.usedCurveLines + 1;

    if (i >= #AM.CurvePool) then
        AM.CurvePool[i] = AM.CreateCurveLineElement();
    end

    return AM.CurvePool[i];
end
--]]
function AM.GenerateTrackElement(index, x, y, w, h, parent, R, G, B, A)
    local element = CreateFrame("Button", "AM.TrackElement"..index, parent)
	element:SetPoint("TOPLEFT", parent, "TOPLEFT", x + 6, y);
    element:SetPoint("TOPRIGHT", parent, "TOPRIGHT", x, y);
	element:SetSize(w, h);
    element:SetFrameLevel(8);
    element.ntex = element:CreateTexture();
    element.ntex:SetTexture(Resources.textures["Animation"]);
    element.ntex:SetTexCoord(0, 0.5, 0, 0.5);    -- (left,right,top,bottom)
    element.ntex:SetAllPoints();
    element.ntex:SetVertexColor(0.2, 0.2, 0.2, 1);
    element:SetNormalTexture(element.ntex);
    element:SetScript("OnClick", function (self, button, down)
        if (AM.loadedTimeline) then
            AM.SelectTrack(index);
        end
    end)

    element.name = UI.Label:New(2, 0, 200, 10, element, "TOPLEFT", "TOPLEFT", index, 8);
    element:Hide();

    return element;
end

function AM.GetAvailableTrackElement()
    local i = AM.usedTracks + 1;
    AM.usedTracks = AM.usedTracks + 1;

    if (i > #AM.TrackPool) then
        AM.TrackPool[i] = AM.GenerateTrackElement(i, 0, -((AM.trackElementH + Editor.pmult) * (i - 1)), 10, AM.trackElementH, AM.workAreaList:GetFrame());
    end

    return AM.TrackPool[i];
end

function AM.GenerateAnimationElement(index, x, y, w, h, parent, R, G, B, A)
    local colIdx = 10;
    local element = CreateFrame("Button", "AM.AnimationElement"..index, parent)
	element:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y);
	element:SetSize(w, h);
    --element:SetAlpha(0.5);
    element:SetFrameLevel(10);
    element.ntex = element:CreateTexture();
    element.ntex:SetTexture(Resources.textures["Animation"]);
    element.ntex:SetTexCoord(0, 0.5, 0, 0.5);    -- (left,right,top,bottom)
    element.ntex:SetAllPoints();
    element.ntex:SetVertexColor(0, 0, 0, 1);
    element:SetNormalTexture(element.ntex);
    element:RegisterForClicks("LeftButtonUp", "LeftButtonDown", "RightButtonDown");
    element:SetScript("OnMouseDown", function(self, button, down)
        if (button == "LeftButton") then
            local track = AM.loadedTimeline:GetTrack(self.trackIdx);
            Editor.StartAction(Actions.Action.Type.TrackAnimations, track, AM.loadedTimeline);
            AM.inputState.movingAnim = index;
            AM.inputState.mousePosStartX = Input.mouseXRaw;
        end
    end);
    element:SetScript("OnMouseUp", function(self, button)
        Editor.FinishAction();
        AM.inputState.movingAnim = -1;
    end);
    element:SetScript("OnClick", function (self, button, down)
        if (button == "LeftButton" and down) then
            AM.SelectAnimation(index);
            AM.SelectKeyAtIndex(-1);
        elseif (button == "RightButton" and down) then
            AM.SelectAnimation(index);
            AM.SelectKeyAtIndex(-1);

            local scale = SceneMachine.mainWindow:GetEffectiveScale();
            local rx = Input.mouseXRaw / scale - SceneMachine.mainWindow:GetLeft();
            local ry = Input.mouseYRaw / scale - SceneMachine.mainWindow:GetTop();

            local menuOptions = {
                [1] = { ["Name"] = L["AM_RMB_CHANGE_ANIM"], ["Action"] = function() AM.Button_ChangeAnimation(index); end },
                [2] = { ["Name"] = L["AM_RMB_SET_ANIM_SPEED"], ["Action"] = function()  AM.Button_SetAnimationSpeed(index) end },
                [3] = { ["Name"] = L["AM_RMB_DELETE_ANIM"], ["Action"] = function() AM.Button_DeleteAnimation(index); end },
                [4] = { ["Name"] = L["AM_RMB_DIFFERENT_COLOR"], ["Action"] = function() AM.Button_RandomizeAnimColor(index); end },
            };

            SceneMachine.mainWindow:PopupWindowMenu(rx * scale, ry * scale, menuOptions);
        end
    end)

    -- Left handle
    element.handleL = CreateFrame("Button", "AM.AnimationElement.HandleL"..index, element)
	element.handleL:SetPoint("TOPLEFT", element, "TOPLEFT", 0, 0);
    element.handleL:SetPoint("BOTTOMLEFT", element, "BOTTOMLEFT", 0, 0);
	element.handleL:SetSize(6, h);
    element.handleL:SetFrameLevel(11);
    element.handleL.ntex = element.handleL:CreateTexture();
    element.handleL.ntex:SetTexture(Resources.textures["Animation"]);
    --element.handleL.ntex:SetTexCoord(0.125, 0.27, 0.5, 1);    -- (left,right,top,bottom)
    element.handleL.ntex:SetTexCoord(0, 0.5, 0, 0.5);
    element.handleL.ntex:SetAllPoints();
    element.handleL.ntex:SetVertexColor(1, 1, 1, 0.1);
    element.handleL:SetHighlightTexture(element.handleL.ntex);
    element.handleL:RegisterForClicks("LeftButtonUp", "LeftButtonDown", "RightButtonDown");
    element.handleL:SetScript("OnMouseDown", function(self, button)
        if (button == "LeftButton") then
            local animElement = AM.AnimationPool[index];
            local track = AM.loadedTimeline:GetTrack(animElement.trackIdx);
            Editor.StartAction(Actions.Action.Type.TrackAnimations, track, AM.loadedTimeline);
            AM.inputState.movingAnimHandleL = index;
            AM.inputState.mousePosStartX = Input.mouseXRaw;
        end
    end);
    element.handleL:SetScript("OnMouseUp", function(self, button)
        AM.inputState.movingAnimHandleL = -1;
        Editor.FinishAction();
    end);
    element.handleL:SetScript("OnClick", function (self, button, down)
        if (button == "LeftButton" and down) then
            --AM.SelectAnimation(index);
        end
    end)

    -- Right handle
    element.handleR = CreateFrame("Button", "AM.AnimationElement.HandleR"..index, element)
	element.handleR:SetPoint("TOPRIGHT", element, "TOPRIGHT", 0, 0);
    element.handleR:SetPoint("BOTTOMRIGHT", element, "BOTTOMRIGHT", 0, 0);
    element.handleR:SetSize(6, h);
    element.handleR:SetFrameLevel(11);
    element.handleR.ntex = element.handleR:CreateTexture();
    element.handleR.ntex:SetTexture(Resources.textures["Animation"]);
    --element.handleR.ntex:SetTexCoord(0.0, 0.125, 0.5, 1);    -- (left,right,top,bottom)
    element.handleR.ntex:SetTexCoord(0, 0.5, 0, 0.5);
    element.handleR.ntex:SetAllPoints();
    element.handleR.ntex:SetVertexColor(1, 1, 1, 0.1);
    element.handleR:SetHighlightTexture(element.handleR.ntex);
    element.handleR:RegisterForClicks("LeftButtonUp", "LeftButtonDown", "RightButtonDown");
    element.handleR:SetScript("OnMouseDown", function(self, button)
        if (button == "LeftButton") then
            local animElement = AM.AnimationPool[index];
            local track = AM.loadedTimeline:GetTrack(animElement.trackIdx);
            Editor.StartAction(Actions.Action.Type.TrackAnimations, track, AM.loadedTimeline);
            AM.inputState.movingAnimHandleR = index;
            AM.inputState.mousePosStartX = Input.mouseXRaw;
        end
    end);
    element.handleR:SetScript("OnMouseUp", function(self, button)
        AM.inputState.movingAnimHandleR = -1;
        Editor.FinishAction();
    end);
    element.handleR:SetScript("OnClick", function (self, button, down)
        if (button == "LeftButton" and down) then
            AM.SelectAnimation(index);
        end
    end)

    -- name
    element.name = UI.Label:NewLR(10, 0, 0, 0, 10, element, index, 8);
    element.name:SetAlpha(0.7);
    element.name:SetTextColor(0, 0, 0, 1);
    element:Hide();

    return element;
end

function AM.GetAvailableAnimationElement()
    local i = AM.usedAnimations + 1;
    AM.usedAnimations = AM.usedAnimations + 1;

    if (i > #AM.AnimationPool) then
        AM.AnimationPool[i] = AM.GenerateAnimationElement(i, 0, 0, AM.trackElementH, AM.trackElementH, AM.workAreaList:GetFrame(), 0, 0, 0, 1);
    end

    return AM.AnimationPool[i];
end

function AM.CreateDefaultTimeline()
    return AM.CreateTimeline();
end

function AM.RenameTimeline(text, index)
    if (text ~= nil and text ~= "") then
        -- rename existing scene
        local timeline = SM.loadedScene:GetTimeline(index);
        Editor.StartAction(Actions.Action.Type.TimelineProperties, timeline);
        timeline.name = text;
        Editor.FinishAction(timeline);
        AM.RefreshTimelineTabs();
    end
end

function AM.Button_EditTimeline(index)
    -- not sure what this will do
end

function AM.Button_DeleteTimeline(index)
    Editor.OpenMessageBox(SceneMachine.mainWindow:GetFrame(), L["AM_MSG_DELETE_TIMELINE_TITLE"], L["AM_MSG_DELETE_TIMELINE_MESSAGE"], true, true, function() AM.DeleteTimeline(index); end, function() end);
end

function AM.CreateTimeline(timelineName)
    if (timelineName == nil) then
        timelineName = "Timeline " .. SM.loadedScene:GetTimelineCount();
    end

    local timeline = AM.CreateTimeline_internal(timelineName);

    Editor.StartAction(Actions.Action.Type.CreateTimeline, timeline);
    Editor.FinishAction();

    return timeline;
end

function AM.CreateTimeline_internal(timelineName)
    local timeline = Timeline:New(timelineName);
    SM.loadedScene:AddTimeline(timeline);
    AM.RefreshTimelineTabs();
    AM.RefreshWorkspace();

    return timeline;
end

function AM.DeleteTimeline(index)
    -- switch to a different timeline because the currently loaded is being deleted
    -- load first that isn't this one
    for i = 1, SM.loadedScene:GetTimelineCount(), 1 do
        if (i ~= index) then
            AM.LoadTimeline(i);
            break;
        end
    end

    local timeline = SM.loadedScene:GetTimeline(index);

    -- delete it
    AM.DeleteTimeline_internal(timeline);

    Editor.StartAction(Actions.Action.Type.DestroyTimeline, timeline);
    Editor.FinishAction();

    -- if this was the only timeline then create a new default one
    if (SM.loadedScene:GetTimelineCount() == 0) then
        SM.loadedScene:AddTimeline(AM.CreateDefaultTimeline());
        AM.LoadTimeline(1);
    end
end

function AM.DeleteTimeline_internal(timeline)
    SM.loadedScene:DeleteTimeline(timeline);
    
    AM.selectedTrack = nil;
    AM.selectedKeys = nil;

    -- refresh ui
    AM.RefreshTimelineTabs();
    AM.RefreshWorkspace();
end

function AM.UndeleteTimeline_internal(timeline)
    SM.loadedScene:UndeleteTimeline(timeline);

    -- refresh ui
    AM.RefreshTimelineTabs();
    AM.RefreshWorkspace();
end

function AM.AddTracks(objects)
    if (not objects) then
        return;
    end

    local tracks = {};
    for i = 1, #objects, 1 do
        if (objects[i]) then
            tracks[i] = AM.AddTrack_internal(objects[i]);
        end
    end

    Editor.StartAction(Actions.Action.Type.CreateTrack, tracks, AM.loadedTimeline);
    Editor.FinishAction();
end

function AM.AddTrack_internal(object)
    if (not object) then
        return;
    end

    if (not AM.loadedTimeline) then
        return;
    end

    -- even simpler, when adding a track the selected object would have current track selected anyway
    if (AM.selectedTrack) then
        if (AM.selectedTrack.objectID == object.id) then
            return;
        end
    end

    local track = Track:New(object);
    local index = AM.loadedTimeline:AddTrack(track);

    AM.SelectTrack(index);
    AM.RefreshWorkspace();

    return track;
end

function AM.RemoveTracks(tracks)
    for i = 1, #tracks, 1 do
        AM.RemoveTrack_internal(tracks[i], AM.loadedTimeline);
    end

    Editor.StartAction(Actions.Action.Type.DestroyTrack, tracks, AM.loadedTimeline);
    Editor.FinishAction();
end

function AM.RemoveTrack_internal(track, timeline)

    if (not timeline or not track) then
        return;
    end

    if (AM.selectedTrack == track) then
        AM.selectedTrack = nil;
    end

    timeline:RemoveTrack(track);
    AM.RefreshWorkspace();
end

function AM.UnremoveTrack_internal(track, timeline)
    if (not timeline or not track) then
        return;
    end

    timeline:AddTrack(track);
    AM.RefreshWorkspace();
end

function AM.SelectTrack(index)
    if (index == -1) then
        AM.selectedTrack = nil;
        AM.SelectAnimation(-1);
        AM.SelectKeyAtIndex(-1);
        return;
    end

    if (not AM.loadedTimeline:GetTrack(index)) then
        return;
    end

    if (AM.loadedTimeline:GetTrack(index) ~= AM.selectedTrack) then
        AM.SelectKeyAtIndex(-1);
    end

    AM.selectedTrack = AM.loadedTimeline:GetTrack(index);

    Editor.lastSelectedType = Editor.SelectionType.Track;

    -- also select object
    local obj = AM.GetObjectOfTrack(AM.selectedTrack);
    if (obj) then
        SM.selectedObjects = { obj };
        SH.RefreshHierarchy();
        OP.Refresh();
    end

    AM.SelectAnimation(-1);
    AM.SelectKeyAtIndex(-1);
    AM.RefreshTimebar();
    AM.RefreshWorkspace();
end

function AM.LoadTimeline(index)
    AM.loadedTimelineIndex = index;
    AM.tabGroup.selectedIndex = index;

    if (SM.loadedScene:GetTimelineCount() == 0) then
        -- current project has no timelines, create a default one
        SM.loadedScene:AddTimeline(AM.CreateDefaultTimeline());
        AM.RefreshTimelineTabs();
    end

    -- unload current --
    AM.UnloadTimeline();

    -- load new --
    local timeline = SM.loadedScene:GetTimeline(index);
    AM.loadedTimeline = timeline;

    -- refresh the ui
    AM.SetTime(0);
    AM.RefreshTimelineTabs();
    AM.RefreshTimebar();
    AM.RefreshWorkspace();

    SM.selectedObjects = {};
end

function AM.UnloadTimeline()
    SM.selectedObjects = {};
end

function AM.CreateNewTimelineTab(x, y, w, h, parent, startLevel)
	local ButtonFont = Resources.defaultFont;
	local ButtonFontSize = 9;

	-- main button frame --
	local item = CreateFrame("Button", "Zee.WindowAPI.Button", parent)
	item:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y);
	item:SetWidth(w);
	item:SetHeight(h)
	item.ntex = item:CreateTexture()
	item.htex = item:CreateTexture()
	item.ptex = item:CreateTexture()
	item.ntex:SetColorTexture(0.1757, 0.1757, 0.1875 ,1);
	item.htex:SetColorTexture(0.242, 0.242, 0.25,1);
	item.ptex:SetColorTexture(0, 0.4765, 0.7968,1);
	item.ntex:SetAllPoints()	
	item.ptex:SetAllPoints()
	item.htex:SetAllPoints()
	item:SetNormalTexture(item.ntex)
	item:SetHighlightTexture(item.htex)
	item:SetPushedTexture(item.ptex)
    item:SetFrameLevel(startLevel);

	-- project name text --
	item.text = item:CreateFontString("Zee.WindowAPI.Button Text");
	item.text:SetFont(ButtonFont, ButtonFontSize, "NORMAL");
	--item.text:SetPoint("LEFT", item, "LEFT", 10, 0);
    item.text:SetAllPoints(item);
	item.text:SetText(name);

	return item;
end

function AM.RefreshTimelineTabs()
    if (SM.loadedScene ~= nil) then
        AM.tabGroup:SetData(SM.loadedScene:GetTimelines());
    end
end

function AM.RefreshTimebar()
    if (not AM.loadedTimeline) then return; end

    -- Clear needles
    AM.usedNeedles = 0;
    for i = 1, #AM.needles, 1 do
        AM.needles[i]:Hide();
    end

    local timeBarW = AM.timebarGroup:GetWidth();
    local totalTimeMs = AM.loadedTimeline:GetDuration() or 0;

    local startTimeMs = math.floor(AM.currentCrop.min * totalTimeMs);
    local startTimeS = startTimeMs / 1000;
    local endTimeMs = math.ceil(AM.currentCrop.max * totalTimeMs);
    local endTimeS = endTimeMs / 1000;
    local croppedTimeMs = endTimeMs - startTimeMs;
    local croppedTimeS = croppedTimeMs / 1000;

    local needlesNeededF = croppedTimeS;

    local maxloop = 1000;
    local needleTimeSpacing = 1;    -- 1 second
    while (needlesNeededF < AM.minShownNeedles) do
        needlesNeededF = needlesNeededF * 2;
        needleTimeSpacing = needleTimeSpacing / 2;
        maxloop = maxloop - 1;
        if (maxloop < 0) then
            break;
        end
    end
    local maxloop = 1000;
    while (needlesNeededF > AM.maxShownNeedles) do
        needlesNeededF = needlesNeededF / 2;
        needleTimeSpacing = needleTimeSpacing * 2;
        maxloop = maxloop - 1;
        if (maxloop < 0) then
            break;
        end
    end

    local needleSpacing = timeBarW / needlesNeededF;
    local startDiff = 0;
    if (needleTimeSpacing == 1) then
        startDiff = (math.floor(startTimeS) - startTimeS) * needleSpacing;
    elseif (needleTimeSpacing < 1) then
        startDiff = (math.floor(startTimeS) - startTimeS) * needleSpacing / needleTimeSpacing;
    elseif (needleTimeSpacing > 1) then
        startDiff = ((math.floor(startTimeS / needleTimeSpacing) * needleTimeSpacing) - (startTimeS)) * needleSpacing / needleTimeSpacing;
    end

    local needlesNeededCount = math.ceil(needlesNeededF) + 2;

    for i = 1, needlesNeededCount, 1 do
        local pos = startDiff + ((i - 1) * needleSpacing) + 5;

        local text;
        if (needleTimeSpacing == 1) then
            text = math.floor(startTimeS) + (i - 1) .. "s";
        elseif (needleTimeSpacing < 1) then
            text = math.floor(startTimeS) + ((i - 1) * needleTimeSpacing) .. "s";
        elseif (needleTimeSpacing > 1) then
            text = (math.floor(startTimeS / needleTimeSpacing) * needleTimeSpacing) + ((i - 1) * needleTimeSpacing) .. "s";
        end

        local needle = AM.GetNeedle();
        needle:SetSinglePoint("BOTTOMLEFT", pos, 0);
        needle.text:SetText(text);
        needle:Show();

        if (pos < 0) then
            needle:Hide();
        end

        if (pos > timeBarW) then
            needle:Hide();
        end
    end
end

function AM.RefreshWorkspace()
    -- limiting to once per frame (for performance reasons)
    --if (AM.inputState.workspaceRefreshed) then
    --    return;
    --end

    if (not AM.workAreaCreated) then
        return;
    end

    -- reset used
    AM.usedTracks = 0;
    AM.usedAnimations = 0;
    AM.usedKeyframes = 0;
    AM.usedCurveLines = 0;
    AM.trackSelectionBox:Hide();

    if (AM.uiMode == AM.Mode.Tracks) then
        AM.RefreshUIModeTracks();

        -- resize scrollbar
        AM.workAreaScrollbar:Resize(AM.groupBG:GetHeight() - 106, AM.workAreaList:GetHeight());
    elseif (AM.uiMode == AM.Mode.Keyframes) then
        AM.RefreshUIModeKeyframes();

        -- resize scrollbar
        if (AM.keyframeAreaList) then
            AM.workAreaScrollbar:Resize(AM.keyframeViewport:GetHeight(), AM.keyframeAreaList:GetHeight());
        end
    elseif (AM.uiMode == AM.Mode.Curves) then
        AM.RefreshUIModeCurves();
    end

    -- update timer
    if (AM.loadedTimeline) then
        local totalTime = AM.TimeValueToString(AM.loadedTimeline:GetDuration());
        local currentTime = AM.TimeValueToString(AM.loadedTimeline:GetTime() or 0);
        AM.timerTextBox:SetText(currentTime .. "-" .. totalTime);
    end

    AM.inputState.workspaceRefreshed = true;
end

function AM.RefreshUIModeTracks()
    -- load tracks
    local usedTracks = 0;
    local usedAnimations = 0;
    local usedKeys = 0;
    if (AM.loadedTimeline and AM.loadedTimeline:HasTracks()) then
        usedTracks = AM.loadedTimeline:GetTrackCount();
        for t = 1, AM.loadedTimeline:GetTrackCount(), 1 do
            local track = AM.loadedTimeline:GetTrack(t);
            local trackElement = AM.GetAvailableTrackElement();
            local trackElementW = trackElement:GetWidth();
            trackElement.name:SetText(track.name);
            trackElement:Show();

            -- animations
            if (track.animations) then
                for a = 1, #track.animations, 1 do
                    local animElement = AM.GetAvailableAnimationElement();
                    usedAnimations = usedAnimations + 1;
                    local startMS = AM.currentCrop.min * AM.loadedTimeline:GetDuration();
                    local endMS = AM.currentCrop.max * AM.loadedTimeline:GetDuration();
                    local xMS = track.animations[a]:GetStartTime() or 0;
                    local yMS = track.animations[a]:GetEndTime() or 3000;

                    -- check if on screen or cropped out
                    -- check if any of the points are on screen, or if both points are larger than screen else hide
                    if (xMS >= startMS and xMS <= endMS) or (yMS >= startMS and yMS <= endMS) or (xMS <= startMS and yMS >= endMS ) then
                        local xNorm = (xMS - startMS) / (endMS - startMS);
                        local yNorm = (yMS - startMS) / (endMS - startMS);
                        xNorm = max(0, xNorm);
                        yNorm = min(1, yNorm);
        
                        local startP = math.floor(trackElementW * xNorm);
                        local endP = math.floor(trackElementW * yNorm);
                        local width = endP - startP;
        
                        animElement:ClearAllPoints();
                        animElement:SetPoint("TOPLEFT", trackElement, "TOPLEFT", startP, 0);
                        animElement:SetSize(width, AM.trackElementH);

                        -- use alpha to desaturate the animation bars
                        -- so that they don't draw more attention than the scene
                        -- calculate an alpha value based on percieved R,G,B
                        local R, G, B, A = track.animations[a]:GetColor();
                        local alpha = 1.0 - ((R + G + (B / 2)) / 3);
                        alpha = max(0, min(1, alpha));

                        animElement.ntex:SetVertexColor(R, G, B, alpha);
                        animElement:Show();
        
                        animElement.name:SetText(track.animations[a].name);

                        -- store some information for lookup
                        animElement.animIdx = a;
                        animElement.trackIdx = t;

                        if (track.animations[a] == AM.selectedAnim) then
                            AM.animationSelectionBox.lineTop:SetTexCoord(0, width / 20, 0, 1);
                            AM.animationSelectionBox.lineBottom:SetTexCoord(0, width / 20, 0, 1);
                            local alphaH = max(0, min(1, alpha + 0.3));
                            animElement.ntex:SetVertexColor(R, G, B, alphaH);
                        end
                    else
                        animElement:Hide();
                    end
                end
            end

            -- animations: hide unused
            for i = usedAnimations + 1, #AM.AnimationPool, 1 do
                if (AM.AnimationPool[i]) then
                    AM.AnimationPool[i]:Hide();
                end
            end

            -- keyframes: hide unused
            for i = usedKeys + 1, #AM.KeyframePool, 1 do
                if (AM.KeyframePool[i]) then
                    AM.KeyframePool[i]:Hide();
                end
            end

            if (track == AM.selectedTrack) then
                -- keyframes
                local startMS = AM.currentCrop.min * AM.loadedTimeline:GetDuration();
                local endMS = AM.currentCrop.max * AM.loadedTimeline:GetDuration();
                local barWidth = AM.keyframeBars[1]:GetWidth();
                usedKeys = usedKeys + AM.RefreshGroupKeyframes(track, startMS, endMS, barWidth, t);

                -- Show track selection box on the left
                AM.trackSelectionBox:Show();
                AM.trackSelectionBox:SetSinglePoint("TOPLEFT", 0, (t - 1) * -(AM.trackElementH + Editor.pmult));
            end
        end
    end

    -- if no tracks, hide keyframes
    if (usedTracks == 0) then
        for i = 1, #AM.KeyframePool, 1 do
            if (AM.KeyframePool[i]) then
                AM.KeyframePool[i]:Hide();
            end
        end
    end

    -- tracks: hide unused
    for i = usedTracks + 1, #AM.TrackPool, 1 do
        if (AM.TrackPool[i]) then
            AM.TrackPool[i]:Hide();
        end
    end

    -- make list fit elements
    local workAreaListHeight = usedTracks * (AM.trackElementH + Editor.pmult);
    AM.workAreaList:SetHeight(workAreaListHeight);
end

function AM.RefreshUIModeKeyframes()
    -- load tracks
    local usedKeys = 0;
    if (AM.loadedTimeline and AM.loadedTimeline:HasTracks()) then
        for t = 1, AM.loadedTimeline:GetTrackCount(), 1 do
            local track = AM.loadedTimeline:GetTrack(t);

            if (AM.selectedTrack == track) then
                local startMS = AM.currentCrop.min * AM.loadedTimeline:GetDuration();
                local endMS = AM.currentCrop.max * AM.loadedTimeline:GetDuration();
                local barWidth = AM.keyframeBars[1]:GetWidth();

                -- keyframes
                usedKeys = usedKeys + AM.RefreshKeyframes(track.keysPx, startMS, endMS, barWidth, t, 1);
                usedKeys = usedKeys + AM.RefreshKeyframes(track.keysPy, startMS, endMS, barWidth, t, 2);
                usedKeys = usedKeys + AM.RefreshKeyframes(track.keysPz, startMS, endMS, barWidth, t, 3);

                usedKeys = usedKeys + AM.RefreshKeyframes(track.keysRx, startMS, endMS, barWidth, t, 4);
                usedKeys = usedKeys + AM.RefreshKeyframes(track.keysRy, startMS, endMS, barWidth, t, 5);
                usedKeys = usedKeys + AM.RefreshKeyframes(track.keysRz, startMS, endMS, barWidth, t, 6);

                usedKeys = usedKeys + AM.RefreshKeyframes(track.keysS, startMS, endMS, barWidth, t, 7);

                usedKeys = usedKeys + AM.RefreshKeyframes(track.keysA, startMS, endMS, barWidth, t, 8);

                usedKeys = usedKeys + AM.RefreshGroupKeyframes(track, startMS, endMS, barWidth, t);
            end
        end
    end
    
    -- keyframes: hide unused
    --print (usedKeys .. " " .. #AM.KeyframePool)
    for i = usedKeys + 1, #AM.KeyframePool, 1 do
        if (AM.KeyframePool[i]) then
            AM.KeyframePool[i]:Hide();
        end
    end
end

function AM.RefreshUIModeCurves()
    local usedLines = 0;
    local viewScale = 20;
    if (AM.loadedTimeline and AM.selectedTrack) then
        local track = AM.selectedTrack;
        --local trackElement = AM.GetAvailableTrackElement();
        --local trackElementW = trackElement:GetWidth() - 6;
        local trackElementW = AM.workAreaList:GetWidth() - 6;
        --[[
        if (track.keyframes) then
            local linePreviousX = nil;
            local linePreviousY = nil;
            local linePreviousZ = nil;
            for k = 1, #track.keyframes - 1, 1 do
                local startMS = AM.currentCrop.min * AM.loadedTimeline:GetDuration();
                local endMS = AM.currentCrop.max * AM.loadedTimeline:GetDuration();

                local time1MS = track.keyframes[k].time;
                local time2MS = track.keyframes[k + 1].time;

                local x1Norm = (time1MS - startMS) / (endMS - startMS);
                local x2Norm = (time2MS - startMS) / (endMS - startMS);

                local startX = math.floor(trackElementW * x1Norm);
                local endX = math.floor(trackElementW * x2Norm);

                local lineCount = 20;

                for l = 1, lineCount, 1 do
                    local t = (l / lineCount);
                    local timeMS = time1MS * (1 - t) + time2MS * t;
                    local pos = track:SamplePositionKey(timeMS);

                    -- pos X
                    local lineX = AM.GetAvailableCurvePoolLineElement();
                    local x = startX * (1 - t) + endX * t;
                    local y = pos.x * viewScale;
                    lineX:SetVertexColor(1,0,0,1);
                    lineX:ClearAllPoints();
                    lineX:SetStartPoint("LEFT", AM.curveViewBG:GetFrame(), x, y);
                    if (linePreviousX) then
                        local relativePoint, relativeTo, offsetX, offsetY = linePreviousX:GetStartPoint();
                        lineX:SetEndPoint(relativePoint, relativeTo, offsetX, offsetY);
                    else
                        lineX:SetEndPoint("LEFT", AM.curveViewBG:GetFrame(), 0, 0);
                    end
                    lineX:Show();
                    usedLines = usedLines + 1;
                    linePreviousX = lineX;

                    -- pos Y
                    local lineY = AM.GetAvailableCurvePoolLineElement();
                    local x = startX * (1 - t) + endX * t;
                    local y = pos.y * viewScale;
                    lineY:SetVertexColor(0,1,0,1);
                    lineY:ClearAllPoints();
                    lineY:SetStartPoint("LEFT", AM.curveViewBG:GetFrame(), x, y);
                    if (linePreviousY) then
                        local relativePoint, relativeTo, offsetX, offsetY = linePreviousY:GetStartPoint();
                        lineY:SetEndPoint(relativePoint, relativeTo, offsetX, offsetY);
                    else
                        lineY:SetEndPoint("LEFT", AM.curveViewBG:GetFrame(), 0, 0);
                    end
                    lineY:Show();
                    usedLines = usedLines + 1;
                    linePreviousY = lineY;

                    -- pos Z
                    local lineZ = AM.GetAvailableCurvePoolLineElement();
                    local x = startX * (1 - t) + endX * t;
                    local y = pos.z * viewScale;
                    lineZ:SetVertexColor(0,0,1,1);
                    lineZ:ClearAllPoints();
                    lineZ:SetStartPoint("LEFT", AM.curveViewBG:GetFrame(), x, y);
                    if (linePreviousZ) then
                        local relativePoint, relativeTo, offsetX, offsetY = linePreviousZ:GetStartPoint();
                        lineZ:SetEndPoint(relativePoint, relativeTo, offsetX, offsetY);
                    else
                        lineZ:SetEndPoint("LEFT", AM.curveViewBG:GetFrame(), 0, 0);
                    end
                    lineZ:Show();
                    usedLines = usedLines + 1;
                    linePreviousZ = lineZ;
                end
            end
        end
        -- lines: hide unused
        for i = usedLines, #AM.CurvePool, 1 do
            if (AM.CurvePool[i]) then
                AM.CurvePool[i]:Hide();
            end
        end
        --]]
    end
end

function AM.RefreshKeyframes(keys, startMS, endMS, barWidth, trackIndex, componentIndex)
    local usedKeys = 0;

    if (keys) then
        for k = 1, #keys, 1 do
            local keyTime = keys[k].time;
            
            -- check if on screen or cropped out
            -- check if the point are on screen
            if (keyTime >= startMS and keyTime <= endMS) then
                local keyframeElement = AM.GetAvailableKeyframeElement();

                local xNorm = (keyTime - startMS) / (endMS - startMS);
                xNorm = min(1, max(0, xNorm));
                
                local startP = math.floor(barWidth * xNorm) - (xNorm * AM.keyframeElementH / 2) + 6;
                if (xNorm > 0) then startP = startP + 1; end

                keyframeElement:ClearAllPoints();
                keyframeElement:SetParent(AM.keyframeBars[componentIndex]);
                keyframeElement:SetPoint("CENTER", AM.keyframeBars[componentIndex], "LEFT", startP, 0);
                keyframeElement:Show();
                keyframeElement.ntex:SetTexCoord(AM.KeyframeInterpolationToTexCoords(keys[k]:GetInterpolationIn(), keys[k]:GetInterpolationOut()));
                
                -- store some information for lookup
                keyframeElement.trackIdx = trackIndex;
                keyframeElement.keyIdx = k;
                keyframeElement.componentIdx = componentIndex;
                

                local R = 1.0;
                local G = 1.0;
                local B = 1.0;
                local A = 0.4;
                if (componentIndex == 1 or componentIndex == 4) then
                    R = 1.0;
                    G = 0.4;
                    B = 0.4;
                elseif (componentIndex == 2 or componentIndex == 5) then
                    R = 0.4;
                    G = 1.0;
                    B = 0.4;
                elseif (componentIndex == 3 or componentIndex == 6) then
                    R = 0.4;
                    G = 0.4;
                    B = 1.0;
                elseif (componentIndex == 7) then
                    R = 1.0;
                    G = 1.0;
                    B = 0.4;
                elseif (componentIndex == 8) then
                    R = 1.0;
                    G = 1.0;
                    B = 1.0;
                end
                
                for c = 1, #AM.selectedKeys, 1 do
                    if (keys[k] == AM.selectedKeys[c]) then
                        A = 1.0;
                    end
                end

                keyframeElement.ntex:SetVertexColor(R, G, B, A);

                usedKeys = usedKeys + 1;
            end
        end
    end

    return usedKeys;
end

--- Converts a keyframe interpolation index to texture coordinates.
--- @param idx number The keyframe interpolation index.
--- @param flipX? boolean Whether to flip the X-axis.
--- @param flipY? boolean Whether to flip the Y-axis.
--- @return number x1, number x2, number y1, number y2 The texture coordinates.
function AM.KeyframeInterpolationIndexToTexCoords(idx, flipX, flipY)
    flipX = flipX or false;
    flipY = flipY or false;

    local x = math.fmod(idx, 4);
    local y = math.floor(idx / 4);
    local d = 0.25;

    local x1 = x * d;
    local x2 = (x + 1) * d;
    local y1 = y * d;
    local y2 = (y + 1) * d;

    if (flipX and flipY) then
        return x2, x1, y2, y1;
    end

    if (flipX) then
        return x2, x1, y1, y2;
    end

    if (flipY) then
        return x1, x2, y2, y1;
    end

    return x1, x2, y1, y2;
end

--- Converts keyframe interpolation types to texture coordinates needed to display the keyframe graphic based on interpolation type.
--- @param interpolationIn Keyframe.Interpolation The interpolation type of the incoming keyframe.
--- @param interpolationOut Keyframe.Interpolation The interpolation type of the outgoing keyframe.
--- @return number x1, number x2, number y1, number y2 The texture coordinates corresponding to the given interpolation types.
function AM.KeyframeInterpolationToTexCoords(interpolationIn, interpolationOut)
    if (interpolationIn == Keyframe.Interpolation.Bezier) then
        if (interpolationOut == Keyframe.Interpolation.Bezier) then
            return AM.KeyframeInterpolationIndexToTexCoords(2);
        elseif (interpolationOut == Keyframe.Interpolation.Linear) then
            return AM.KeyframeInterpolationIndexToTexCoords(4);
        elseif (interpolationOut == Keyframe.Interpolation.Step) then
            return AM.KeyframeInterpolationIndexToTexCoords(3);
        elseif (interpolationOut == Keyframe.Interpolation.Slow) then
            return AM.KeyframeInterpolationIndexToTexCoords(10, true, true);
        elseif (interpolationOut == Keyframe.Interpolation.Fast) then
            return AM.KeyframeInterpolationIndexToTexCoords(10, true);
        end
    elseif (interpolationIn == Keyframe.Interpolation.Linear) then
        if (interpolationOut == Keyframe.Interpolation.Bezier) then
            return AM.KeyframeInterpolationIndexToTexCoords(4, true);
        elseif (interpolationOut == Keyframe.Interpolation.Linear) then
            return AM.KeyframeInterpolationIndexToTexCoords(0);
        elseif (interpolationOut == Keyframe.Interpolation.Step) then
            return AM.KeyframeInterpolationIndexToTexCoords(1);
        elseif (interpolationOut == Keyframe.Interpolation.Slow) then
            return AM.KeyframeInterpolationIndexToTexCoords(11, true, true);
        elseif (interpolationOut == Keyframe.Interpolation.Fast) then
            return AM.KeyframeInterpolationIndexToTexCoords(11, true);
        end
    elseif (interpolationIn == Keyframe.Interpolation.Step) then
        if (interpolationOut == Keyframe.Interpolation.Bezier) then
            return AM.KeyframeInterpolationIndexToTexCoords(3, true);
        elseif (interpolationOut == Keyframe.Interpolation.Linear) then
            return AM.KeyframeInterpolationIndexToTexCoords(1, true);
        elseif (interpolationOut == Keyframe.Interpolation.Step) then
            return AM.KeyframeInterpolationIndexToTexCoords(5);
        elseif (interpolationOut == Keyframe.Interpolation.Slow) then
            return AM.KeyframeInterpolationIndexToTexCoords(9, true, true);
        elseif (interpolationOut == Keyframe.Interpolation.Fast) then
            return AM.KeyframeInterpolationIndexToTexCoords(9, true);
        end
    elseif (interpolationIn == Keyframe.Interpolation.Slow) then
        if (interpolationOut == Keyframe.Interpolation.Bezier) then
            return AM.KeyframeInterpolationIndexToTexCoords(10);
        elseif (interpolationOut == Keyframe.Interpolation.Linear) then
            return AM.KeyframeInterpolationIndexToTexCoords(11);
        elseif (interpolationOut == Keyframe.Interpolation.Step) then
            return AM.KeyframeInterpolationIndexToTexCoords(9);
        elseif (interpolationOut == Keyframe.Interpolation.Slow) then
            return AM.KeyframeInterpolationIndexToTexCoords(12);
        elseif (interpolationOut == Keyframe.Interpolation.Fast) then
            return AM.KeyframeInterpolationIndexToTexCoords(8);
        end
    elseif (interpolationIn == Keyframe.Interpolation.Fast) then
        if (interpolationOut == Keyframe.Interpolation.Bezier) then
            return AM.KeyframeInterpolationIndexToTexCoords(10, false, true);
        elseif (interpolationOut == Keyframe.Interpolation.Linear) then
            return AM.KeyframeInterpolationIndexToTexCoords(11, false, true);
        elseif (interpolationOut == Keyframe.Interpolation.Step) then
            return AM.KeyframeInterpolationIndexToTexCoords(9, false, true);
        elseif (interpolationOut == Keyframe.Interpolation.Slow) then
            return AM.KeyframeInterpolationIndexToTexCoords(8, false, true);
        elseif (interpolationOut == Keyframe.Interpolation.Fast) then
            return AM.KeyframeInterpolationIndexToTexCoords(12, false, true);
        end
    end
end

function AM.RefreshGroupKeyframes(track, startMS, endMS, barWidth, trackIndex)
    local usedKeys = 0;
    AM.keyframeGroups = {};

    for i = 1, #track.keysPx, 1 do
        local key = track.keysPx[i];
        if (key.time >= startMS and key.time <= endMS) then
            AM.keyframeGroups[key.time] = AM.keyframeGroups[key.time] or {};
            AM.keyframeGroups[key.time].px = key;
        end
    end

    for i = 1, #track.keysPy, 1 do
        local key = track.keysPy[i];
        if (key.time >= startMS and key.time <= endMS) then
            AM.keyframeGroups[key.time] = AM.keyframeGroups[key.time] or {};
            AM.keyframeGroups[key.time].py = key;
        end
    end

    for i = 1, #track.keysPz, 1 do
        local key = track.keysPz[i];
        if (key.time >= startMS and key.time <= endMS) then
            AM.keyframeGroups[key.time] = AM.keyframeGroups[key.time] or {};
            AM.keyframeGroups[key.time].pz = key;
        end
    end

    for i = 1, #track.keysRx, 1 do
        local key = track.keysRx[i];
        if (key.time >= startMS and key.time <= endMS) then
            AM.keyframeGroups[key.time] = AM.keyframeGroups[key.time] or {};
            AM.keyframeGroups[key.time].rx = key;
        end
    end

    for i = 1, #track.keysRy, 1 do
        local key = track.keysRy[i];
        if (key.time >= startMS and key.time <= endMS) then
            AM.keyframeGroups[key.time] = AM.keyframeGroups[key.time] or {};
            AM.keyframeGroups[key.time].ry = key;
        end
    end

    for i = 1, #track.keysRz, 1 do
        local key = track.keysRz[i];
        if (key.time >= startMS and key.time <= endMS) then
            AM.keyframeGroups[key.time] = AM.keyframeGroups[key.time] or {};
            AM.keyframeGroups[key.time].rz = key;
        end
    end

    for i = 1, #track.keysS, 1 do
        local key = track.keysS[i];
        if (key.time >= startMS and key.time <= endMS) then
            AM.keyframeGroups[key.time] = AM.keyframeGroups[key.time] or {};
            AM.keyframeGroups[key.time].s = key;
        end
    end

    for i = 1, #track.keysA, 1 do
        local key = track.keysA[i];
        if (key.time >= startMS and key.time <= endMS) then
            AM.keyframeGroups[key.time] = AM.keyframeGroups[key.time] or {};
            AM.keyframeGroups[key.time].a = key;
        end
    end

    for keyTime, value in pairs(AM.keyframeGroups) do
        local keyframeElement = AM.GetAvailableKeyframeElement();
        local xNorm = (keyTime - startMS) / (endMS - startMS);
        xNorm = min(1, max(0, xNorm));

        local startP = math.floor(barWidth * xNorm) - (xNorm * AM.keyframeElementH / 2) + 10;
        if (xNorm > 0) then startP = startP + 1; end

        keyframeElement:ClearAllPoints();
        keyframeElement:SetParent(AM.mainKeyframeBar);
        keyframeElement:SetPoint("CENTER", AM.mainKeyframeBar, "LEFT", startP, 0);
        keyframeElement.ntex:SetTexCoord(0, 0.25, 0, 0.25);
        keyframeElement:Show();

        -- store some information for lookup
        keyframeElement.trackIdx = trackIndex;
        keyframeElement.componentIdx = -1;
        keyframeElement.time = keyTime;

        if (AM.selectedKeyGroup == keyTime) then
            keyframeElement.ntex:SetVertexColor(1, 1, 1, 1);
        else
            keyframeElement.ntex:SetVertexColor(0.5, 0.5, 0.5, 1);
        end

        usedKeys = usedKeys + 1;
    end

    return usedKeys;
end

function AM.TimeValueToString(duration)
    duration = duration or 0;
    local durationS = duration / 1000;
    local durationM = math.floor(durationS / 60);
    durationS = durationS - (60 * durationM);
    return string.format("%02d:%02d", durationM, durationS);
end

function AM.AddAnim(track, animID, animVariant)
    if (not track) then
        return;
    end

    if (not track.animations) then
        track.animations = {};
    end

    Editor.StartAction(Actions.Action.Type.TrackAnimations, track, AM.loadedTimeline);

    animVariant = animVariant or 0;

    -- get length
    local obj = AM.GetObjectOfTrack(track);
    if (not obj) then
        return;
    end
    if (obj.fileID == nil or obj.fileID <= 0) then
        local ignore, ignore2, idString = strsplit(" ", obj.actor:GetModelPath());
        obj.fileID = tonumber(idString);
    end
    
    local anim = AnimationClip:New(animID, animVariant);

    local animData = SceneMachine.animationData[obj.fileID];
    local animLength = 3000;
    if (animData) then
        for i in pairs(animData) do
            local entry = animData[i];
            if (entry[1] == animID and entry[2] == animVariant) then
                animLength = entry[3];
            end
        end
    end

    anim:SetLength(animLength);

    local startT = 0;
    local endT = startT + animLength;
    if (#track.animations > 0) then
        startT = track.animations[#track.animations]:GetEndTime();
        endT = startT + animLength;
    end

    anim:SetStartTime(startT);
    anim:SetEndTime(endT);

    local name = SceneMachine.animationNames[animID];
    name = name or ("Anim_" .. animID);
    if (animVariant ~= 0) then
        name = name .. " " .. animVariant;
    end

    anim:SetName(name);
    anim:SetSpeed(1);

    table.insert(track.animations, anim);

    Editor.FinishAction();

    AM.RefreshWorkspace();
end

function AM.RemoveAnim(track, anim)
    if (not anim or not track) then
        return;
    end

    if (track == AM.selectedTrack and anim == AM.SelectAnimation) then
        -- deselect
        AM.SelectAnimation(-1);
    end

    Editor.StartAction(Actions.Action.Type.TrackAnimations, track, AM.loadedTimeline);

    for i in pairs(track.animations) do
        if (track.animations[i] == anim) then
            table.remove(track.animations, i);
        end
    end

    Editor.FinishAction();

    AM.RefreshWorkspace();
end

function AM.ReplaceAnim(track, currentAnim, newID, newVariant)
    Editor.StartAction(Actions.Action.Type.TrackAnimations, track, AM.loadedTimeline);

    -- get name
    local name = SceneMachine.animationNames[newID];
    name = name or ("Anim_" .. newID);
    if (newVariant ~= 0) then
        name = name .. " " .. newVariant;
    end

    -- get length
    local obj = AM.GetObjectOfTrack(track);
    if (not obj) then
        return;
    end
    if (obj.fileID == nil or obj.fileID <= 0) then
        local ignore, ignore2, idString = strsplit(" ", obj.actor:GetModelPath());
        obj.fileID = tonumber(idString);
    end
    
    local animData = SceneMachine.animationData[obj.fileID];
    local animLength = 3000;
    if (animData) then
        for i in pairs(animData) do
            local entry = animData[i];
            if (entry[1] == newID and entry[2] == newVariant) then
                animLength = entry[3];
            end
        end
    end

    currentAnim:SetID(newID);
    currentAnim:SetVariation(newVariant);
    currentAnim:SetLength(animLength);
    currentAnim:SetName(name);

    Editor.FinishAction();
    AM.RefreshWorkspace();
end

function AM.SelectAnimation(index)
    if (index <= 0) then
        AM.selectedAnim = nil;
        AM.animationSelectionBox:Hide();
        AM.RefreshWorkspace();
        return;
    end

    -- find which animation, track and elements were just selected
    local animElement = AM.AnimationPool[index];
    local trackElement = animElement.trackIdx;
    local track = AM.loadedTimeline:GetTrack(animElement.trackIdx);
    local anim = track.animations[animElement.animIdx];
    
    AM.SelectTrack(animElement.trackIdx);
    AM.selectedAnim = anim;

    Editor.lastSelectedType = Editor.SelectionType.Anim;

    AM.animationSelectionBox:ClearAllPoints();
    AM.animationSelectionBox:SetParent(animElement);
    AM.animationSelectionBox:SetPoint("LEFT", animElement, "LEFT", 0, 0);
    AM.animationSelectionBox:SetPoint("RIGHT", animElement);
    local width = animElement:GetWidth();
    AM.animationSelectionBox.lineTop:SetTexCoord(0, width / 20, 0, 1);
    AM.animationSelectionBox.lineBottom:SetTexCoord(0, width / 20, 0, 1);
    AM.animationSelectionBox:Show();

    AM.RefreshWorkspace();
end

function AM.Button_ChangeAnimation(index)
    AM.OpenAddAnimationWindow(AM.selectedTrack, AM.selectedAnim);
end

function AM.Button_DeleteAnimation(index)
    AM.RemoveAnim(AM.selectedTrack, AM.selectedAnim)
end

function AM.Button_SetAnimationSpeed(index)
    if (not AM.selectedAnim) then
        return;
    end

    -- using percentage in the text box, easier to type than floats
    local currentSpeed = AM.selectedAnim:GetSpeed() or 1;
    local action = function(text)
        local value = tonumber(text);
        if (value) then
            AM.selectedAnim:SetSpeed(value / 100);
        end
        AM.RefreshWorkspace();
    end
    Editor.OpenQuickTextbox(action, tostring(currentSpeed * 100), L["AM_SET_ANIMATION_SPEED_PERCENT"]);
end

function AM.Button_RandomizeAnimColor(index)
    AM.selectedAnim:RandomizeColor();

    -- use alpha to desaturate the animation bars
    -- so that they don't draw more attention than the scene
    -- calculate an alpha value based on percieved R,G,B
    local R, G, B, A = AM.selectedAnim:GetColor();
    local alpha = 1.0 - ((R + G + (B / 2)) / 3);
    alpha = max(0, min(1, alpha));

    AM.AnimationPool[index].ntex:SetVertexColor(R, G, B, alpha);
end

function AM.SetTime(timeMS, rounded)
    if (rounded == nil) then
        rounded = true;
    end

    -- force time selection to 30 fps ticks
    if rounded then
        timeMS = floor(floor(timeMS / 33.3333) * 33.3333);
    end

    -- move ze slider
    local groupBgH = AM.timebarGroup:GetWidth() - 26;
    local timeNorm = AM.GetTimeNormalized(timeMS);
    if (timeNorm < 0 or timeNorm > 1) then
        -- the slider is offscreen
        AM.TimeSlider:Hide();
    else
        AM.TimeSlider:Show();
        local pos = timeNorm * groupBgH + 10;
        AM.TimeSlider:ClearAllPoints();
        AM.TimeSlider:SetPoint("CENTER", AM.timebarGroup, "LEFT", pos, 0);
    end

    -- update timer
    if (AM.loadedTimeline) then
        AM.loadedTimeline:SetTime(timeMS);

        local totalTime = AM.TimeValueToString(AM.loadedTimeline:GetDuration());
        local currentTime = AM.TimeValueToString(AM.loadedTimeline:GetTime() or 0);
        AM.timerTextBox:SetText(currentTime .. "-" .. totalTime);
    end

    if (not SM.loadedScene) then
        return;
    end

    -- go through the timeline tracks
    local timeline = AM.loadedTimeline;
    if (timeline and timeline:HasTracks()) then
        for t = 1, timeline:GetTrackCount(), 1 do
            local track = timeline:GetTrack(t);
            -- also get object
            local obj = AM.GetObjectOfTrack(track);
            if (obj) then
                -- animate object
                if (obj:HasActor()) then
                    local animID, variationID, animMS, animSpeed = track:SampleAnimation(timeMS);

                    if (AM.playing) then
                        -- Sample playback
                        if (obj.currentAnimID ~= animID or obj.currentAnimVariationID ~= variationID) then
                            -- Animation switch
                            if (animID ~= -1) then
                                --obj.actor:SetAnimationBlendOperation(1);  -- 0: don't blend, 1: blend
                                obj.actor:SetAnimation(animID, variationID, animSpeed, animMS / 1000);
                            end
                            obj.currentAnimID = animID;
                            obj.currentAnimVariationID = variationID;
                        end
                    else
                        -- Sample single key
                        animSpeed = 0;
                        obj.currentAnimID = nil;
                        obj.currentAnimVariationID = nil;
                        if (animID ~= -1) then
                            obj.actor:SetAnimation(animID, variationID, animSpeed, animMS / 1000);
                        else
                            -- stop playback
                        end
                    end
                end
                -- animate keyframes
                local currentPos = obj:GetPosition();
                local posX = track:SamplePositionXKey(timeMS) or currentPos.x;
                local posY = track:SamplePositionYKey(timeMS) or currentPos.y;
                local posZ = track:SamplePositionZKey(timeMS) or currentPos.z;
                obj:SetPosition(posX, posY, posZ);

                local currentRot = obj:GetRotation();
                local rotX = track:SampleRotationXKey(timeMS) or currentRot.x;
                local rotY = track:SampleRotationYKey(timeMS) or currentRot.y;
                local rotZ = track:SampleRotationZKey(timeMS) or currentRot.z;
                obj:SetRotation(rotX, rotY, rotZ);

                local currentScale = obj:GetScale();
                local scale = track:SampleScaleKey(timeMS) or currentScale;
                obj:SetScale(scale);

                if (obj:IsVisible()) then
                    if (obj:HasActor()) then
                        local currentAlpha = obj:GetAlpha();
                        local alpha = track:SampleAlphaKey(timeMS) or currentAlpha;
                        obj:SetAlpha(alpha);
                    end
                end
            end
        end
    end

    if (CC.ControllingCameraObject ~= nil) then
        -- transfer object motion to camera controller
        local pos = CC.ControllingCameraObject:GetPosition();
        local rot = CC.ControllingCameraObject:GetRotation();
        CC.position:SetVector3(pos);
        Camera.position:SetVector3(pos);
        Camera.eulerRotation:SetVector3(rot);
        -- override direction
        CC.Direction = math.deg(Camera.eulerRotation.z);
    end

    OP.Refresh();
end

function AM.GetObjectOfTrack(track)
    if (not track) then return nil; end

    if (track.objectID) then
        return SM.loadedScene:GetObjectByID(track.objectID);
    end

    return nil;
end

function AM.GetTimeNormalized(timeMS)
    if (not AM.loadedTimeline) then
        return 0;
    end
    local totalTimeMS = AM.loadedTimeline:GetDuration();
    local startMS = AM.currentCrop.min * totalTimeMS;
    local endMS = AM.currentCrop.max * totalTimeMS;
    local timeNorm = (timeMS - startMS) / (endMS - startMS);
    return timeNorm;
end

function AM.OpenAddAnimationWindow(track, replaceAnim)
    if (not track) then
        if (#SM.selectedObjects > 0) then
            Editor.OpenMessageBox(SceneMachine.mainWindow:GetFrame(), L["AM_MSG_NO_TRACK_TITLE"], L["AM_MSG_NO_TRACK_MESSAGE"],
            true, true, function() AM.AddTracks({ SM.selectedObjects[1] }) AM.OpenAddAnimationWindow(AM.selectedTrack, replaceAnim) end, function() end);
        end
        return;
    end

    -- find available animations
    local obj = AM.GetObjectOfTrack(track);
    if (not obj) then
        return;
    end

    if (not obj:HasActor()) then
        -- can only add animation clips to objects that have actors
        return;
    end

    if (obj.fileID == nil or obj.fileID <= 0) then
        local _, _, idString = strsplit(" ", obj.actor:GetModelPath());
        obj.fileID = tonumber(idString);
    end

    local animData = SceneMachine.animationData[obj.fileID];
    if (animData) then
        AM.animScrollList:SetData(animData);
        AM.animSelectWindow.filterBox:SetText("");
        AM.animSelectWindow:Show();
        if (replaceAnim) then
            AM.animSelectWindow.loadAnimBtn:SetText(L["AM_BUTTON_CHANGE_ANIMATION"]);
        else
            AM.animSelectWindow.loadAnimBtn:SetText(L["AM_BUTTON_ADD_ANIMATION"]);
        end
        AM.animScrollList.replaceAnim = replaceAnim;
    else
        print("SceneMachine.animationData is missing key " .. obj.fileID);
    end
end

function AM.AddFullKey(track)
    if (not track) then
        if (#SM.selectedObjects > 0) then
            Editor.OpenMessageBox(SceneMachine.mainWindow:GetFrame(), L["AM_MSG_NO_TRACK_TITLE"], L["AM_MSG_NO_TRACK_MESSAGE"],
            true, true, function() AM.AddTracks({ SM.selectedObjects[1] }); AM.AddFullKey(AM.selectedTrack); end, function() end);
        end
        return;
    end

    Editor.StartAction(Actions.Action.Type.TrackKeyframes, track, AM.loadedTimeline);
    local timeMS = AM.loadedTimeline:GetTime();
    local obj = AM.GetObjectOfTrack(track);
    if (obj) then
        local alpha = 1;
        if (obj:HasActor()) then
            alpha = obj:GetAlpha();
        end
        track:AddFullKeyframe(timeMS, obj:GetPosition(), obj:GetRotation(), obj:GetScale(), alpha, AM.currentInterpolationIn, AM.currentInterpolationOut);
    end

    Editor.FinishAction();
    AM.RefreshWorkspace();
end

function AM.AddPosKey(track)
    if (not track) then
        if (#SM.selectedObjects > 0) then
            Editor.OpenMessageBox(SceneMachine.mainWindow:GetFrame(), L["AM_MSG_NO_TRACK_TITLE"], L["AM_MSG_NO_TRACK_MESSAGE"],
            true, true, function() AM.AddTracks({ SM.selectedObjects[1] }); AM.AddPosKey(AM.selectedTrack); end, function() end);
        end
        return;
    end

    Editor.StartAction(Actions.Action.Type.TrackKeyframes, track, AM.loadedTimeline);
    local timeMS = AM.loadedTimeline:GetTime();
    local obj = AM.GetObjectOfTrack(track);
    if (obj) then
        track:AddPositionKeyframe(timeMS, obj:GetPosition(), AM.currentInterpolationIn, AM.currentInterpolationOut);
    end

    Editor.FinishAction();
    AM.RefreshWorkspace();
end

function AM.AddRotKey(track)
    if (not track) then
        if (#SM.selectedObjects > 0) then
            Editor.OpenMessageBox(SceneMachine.mainWindow:GetFrame(), L["AM_MSG_NO_TRACK_TITLE"], L["AM_MSG_NO_TRACK_MESSAGE"],
            true, true, function() AM.AddTracks({ SM.selectedObjects[1] }); AM.AddRotKey(AM.selectedTrack); end, function() end);
        end
        return;
    end

    Editor.StartAction(Actions.Action.Type.TrackKeyframes, track, AM.loadedTimeline);
    local timeMS = AM.loadedTimeline:GetTime();
    local obj = AM.GetObjectOfTrack(track);
    if (obj) then
        track:AddRotationKeyframe(timeMS, obj:GetRotation(), AM.currentInterpolationIn, AM.currentInterpolationOut);
    end

    Editor.FinishAction();
    AM.RefreshWorkspace();
end

function AM.AddScaleKey(track)
    if (not track) then
        if (#SM.selectedObjects > 0) then
            Editor.OpenMessageBox(SceneMachine.mainWindow:GetFrame(), L["AM_MSG_NO_TRACK_TITLE"], L["AM_MSG_NO_TRACK_MESSAGE"],
            true, true, function() AM.AddTracks({ SM.selectedObjects[1] }); AM.AddScaleKey(AM.selectedTrack); end, function() end);
        end
        return;
    end

    Editor.StartAction(Actions.Action.Type.TrackKeyframes, track, AM.loadedTimeline);
    local timeMS = AM.loadedTimeline:GetTime();
    local obj = AM.GetObjectOfTrack(track);
    if (obj) then
        track:AddScaleKeyframe(timeMS, obj:GetScale(), AM.currentInterpolationIn, AM.currentInterpolationOut);
    end
    Editor.FinishAction();

    AM.RefreshWorkspace();
end

function AM.RemoveKeys(track, keys)
    if (not track) then
        return;
    end

    if (not keys) then
        return;
    end

    Editor.StartAction(Actions.Action.Type.TrackKeyframes, track, AM.loadedTimeline);
    for i = 1, #keys, 1 do
        AM.RemoveKey_internal(track, keys[i]);
    end
    Editor.FinishAction();
end

function AM.RemoveKey(track, key)
    if (not track) then
        return;
    end

    if (not key) then
        return;
    end

    Editor.StartAction(Actions.Action.Type.TrackKeyframes, track, AM.loadedTimeline);
    AM.RemoveKey_internal(track, key);
    Editor.FinishAction();
end

function AM.RemoveKey_internal(track, key)
    

    if (track.keysPx) then
        for i in pairs(track.keysPx) do
            if (track.keysPx[i] == key) then
                table.remove(track.keysPx, i);
            end
        end
    end

    if (track.keysPy) then
        for i in pairs(track.keysPy) do
            if (track.keysPy[i] == key) then
                table.remove(track.keysPy, i);
            end
        end
    end

    if (track.keysPz) then
        for i in pairs(track.keysPz) do
            if (track.keysPz[i] == key) then
                table.remove(track.keysPz, i);
            end
        end
    end

    if (track.keysRx) then
        for i in pairs(track.keysRx) do
            if (track.keysRx[i] == key) then
                table.remove(track.keysRx, i);
            end
        end
    end

    if (track.keysRy) then
        for i in pairs(track.keysRy) do
            if (track.keysRy[i] == key) then
                table.remove(track.keysRy, i);
            end
        end
    end

    if (track.keysRz) then
        for i in pairs(track.keysRz) do
            if (track.keysRz[i] == key) then
                table.remove(track.keysRz, i);
            end
        end
    end

    if (track.keysS) then
        for i in pairs(track.keysS) do
            if (track.keysS[i] == key) then
                table.remove(track.keysS, i);
            end
        end
    end

    if (track.keysA) then
        for i in pairs(track.keysA) do
            if (track.keysA[i] == key) then
                table.remove(track.keysA, i);
            end
        end
    end

    AM.RefreshWorkspace();
end

function AM.SelectKeyAtIndex(index)

    AM.selectedKeys = {};
    AM.selectedKeyComponents = {};
    AM.selectedKeyGroup = -1;

    if (index < 0) then
        AM.RefreshWorkspace();
        return;
    end

    -- find which track and elements were just selected
    local keyframeElement = AM.KeyframePool[index];
    local track = AM.loadedTimeline:GetTrack(keyframeElement.trackIdx);
    local keyIndex = keyframeElement.keyIdx;        -- only available in regular keys
    local keyTime = keyframeElement.time;           -- only available in keygroups
    local component = keyframeElement.componentIdx; -- available in regular keys, or -1

    Editor.lastSelectedType = Editor.SelectionType.Key;

    if (component == -1) then
        AM.selectedKeyGroup = keyTime;
        --print(keyTime)
        local grp = AM.keyframeGroups[keyTime];
        if (grp) then
            if (grp.px) then
                AM.selectedKeys[#AM.selectedKeys + 1] = grp.px;
                AM.selectedKeyComponents[#AM.selectedKeyComponents + 1] = 1;
            end
            if (grp.py) then
                AM.selectedKeys[#AM.selectedKeys + 1] = grp.py;
                AM.selectedKeyComponents[#AM.selectedKeyComponents + 1] = 2;
            end
            if (grp.pz) then
                AM.selectedKeys[#AM.selectedKeys + 1] = grp.pz;
                AM.selectedKeyComponents[#AM.selectedKeyComponents + 1] = 3;
            end

            if (grp.rx) then
                AM.selectedKeys[#AM.selectedKeys + 1] = grp.rx;
                AM.selectedKeyComponents[#AM.selectedKeyComponents + 1] = 4;
            end
            if (grp.ry) then
                AM.selectedKeys[#AM.selectedKeys + 1] = grp.ry;
                AM.selectedKeyComponents[#AM.selectedKeyComponents + 1] = 5;
            end
            if (grp.rz) then
                AM.selectedKeys[#AM.selectedKeys + 1] = grp.rz;
                AM.selectedKeyComponents[#AM.selectedKeyComponents + 1] = 6;
            end

            if (grp.s) then
                AM.selectedKeys[#AM.selectedKeys + 1] = grp.s;
                AM.selectedKeyComponents[#AM.selectedKeyComponents + 1] = 7;
            end

            if (grp.a) then
                AM.selectedKeys[#AM.selectedKeys + 1] = grp.a;
                AM.selectedKeyComponents[#AM.selectedKeyComponents + 1] = 8;
            end
        end
    else
        if (component == 1) then
            AM.selectedKeys[1] = track.keysPx[keyIndex];
        elseif (component == 2) then
            AM.selectedKeys[1] = track.keysPy[keyIndex];
        elseif (component == 3) then
            AM.selectedKeys[1] = track.keysPz[keyIndex];
        elseif (component == 4) then
            AM.selectedKeys[1] = track.keysRx[keyIndex];
        elseif (component == 5) then
            AM.selectedKeys[1] = track.keysRy[keyIndex];
        elseif (component == 6) then
            AM.selectedKeys[1] = track.keysRz[keyIndex];
        elseif (component == 7) then
            AM.selectedKeys[1] = track.keysS[keyIndex];
        elseif (component == 8) then
            AM.selectedKeys[1] = track.keysA[keyIndex];
        end

        AM.selectedKeyGroup = AM.selectedKeys[1].time;
        AM.selectedKeyComponents[#AM.selectedKeyComponents + 1] = component;
    end

    AM.selectedTrack = track;
    AM.RefreshWorkspace();
end

function AM.SelectTrackOfObject(obj)
	if (AM.loadedTimeline) then
		for i = 1, AM.loadedTimeline:GetTrackCount(), 1 do
			if (AM.loadedTimeline:GetTrack(i).objectID == obj.id) then
				AM.SelectTrack(i);
				return;
			end
		end
	end

    AM.SelectTrack(-1);
    AM.RefreshWorkspace();
end

function AM.TrackHasAnims(track)
    if (not track) then
        return false;
    end

    if (track.animations and #track.animations > 0) then
        return true;
    end

    return false;
end

function AM.TrackHasKeyframes(track)
    if (not track) then
        return false;
    end

    if (track.keysPx and #track.keysPx > 0) then
        return true;
    end

    if (track.keysPy and #track.keysPy > 0) then
        return true;
    end

    if (track.keysPz and #track.keysPz > 0) then
        return true;
    end

    if (track.keysRx and #track.keysRx > 0) then
        return true;
    end

    if (track.keysRy and #track.keysRy > 0) then
        return true;
    end

    if (track.keysRz and #track.keysRz > 0) then
        return true;
    end

    if (track.keysS and #track.keysS > 0) then
        return true;
    end

    if (track.keysA and #track.keysA > 0) then
        return true;
    end

    return false;
end

function AM.Play()
    AM.playing = true;

    if (AM.loopPlay) then
        -- find last keyed time
        AM.lastKeyedTime = 0;
        for t = 1, AM.loadedTimeline:GetTrackCount(), 1 do
            local track = AM.loadedTimeline:GetTrack(t);
            if (track.animations and #track.animations > 0) then
                local animEnd = track.animations[#track.animations]:GetEndTime();
                if (animEnd > AM.lastKeyedTime) then
                    AM.lastKeyedTime = animEnd;
                end
            end

            if (track.keysPx and #track.keysPx > 0) then
                local keyEnd = track.keysPx[#track.keysPx].time;
                if (keyEnd > AM.lastKeyedTime) then
                    AM.lastKeyedTime = keyEnd;
                end
            end

            if (track.keysPy and #track.keysPy > 0) then
                local keyEnd = track.keysPy[#track.keysPy].time;
                if (keyEnd > AM.lastKeyedTime) then
                    AM.lastKeyedTime = keyEnd;
                end
            end

            if (track.keysPz and #track.keysPz > 0) then
                local keyEnd = track.keysPz[#track.keysPz].time;
                if (keyEnd > AM.lastKeyedTime) then
                    AM.lastKeyedTime = keyEnd;
                end
            end

            if (track.keysRx and #track.keysRx > 0) then
                local keyEnd = track.keysRx[#track.keysRx].time;
                if (keyEnd > AM.lastKeyedTime) then
                    AM.lastKeyedTime = keyEnd;
                end
            end

            if (track.keysRy and #track.keysRy > 0) then
                local keyEnd = track.keysRy[#track.keysRy].time;
                if (keyEnd > AM.lastKeyedTime) then
                    AM.lastKeyedTime = keyEnd;
                end
            end

            if (track.keysRz and #track.keysRz > 0) then
                local keyEnd = track.keysRz[#track.keysRz].time;
                if (keyEnd > AM.lastKeyedTime) then
                    AM.lastKeyedTime = keyEnd;
                end
            end

            if (track.keysS and #track.keysS > 0) then
                local keyEnd = track.keysS[#track.keysS].time;
                if (keyEnd > AM.lastKeyedTime) then
                    AM.lastKeyedTime = keyEnd;
                end
            end

            if (track.keysA and #track.keysA > 0) then
                local keyEnd = track.keysA[#track.keysA].time;
                if (keyEnd > AM.lastKeyedTime) then
                    AM.lastKeyedTime = keyEnd;
                end
            end
        end

        if (AM.lastKeyedTime == 0) then
            AM.lastKeyedTime = AM.loadedTimeline:GetDuration();
        end
    end

    if (AM.cameraPlay) then
        -- find a suitable camera from tracks
        for t = 1, AM.loadedTimeline:GetTrackCount(), 1 do
            local track = AM.loadedTimeline:GetTrack(t);
            local obj = AM.GetObjectOfTrack(track);
            if (obj and obj:GetType() == SceneMachine.GameObjects.Object.Type.Camera) then
                CC.ControllingCameraObject = obj;
                -- set camera properties that don't need animating
                Camera.fov = obj:GetFoV();
                Camera.nearClip = obj:GetNearClip();
                Camera.farClip = obj:GetFarClip();
                SM.viewportButton:Show();
                break;
            end
        end
    end
end

function AM.Pause()
    AM.playing = false;

    if (AM.loadedTimeline) then
        AM.SetTime(AM.loadedTimeline:GetTime(), false);
    end

    if (AM.cameraPlay) then
        CC.ControllingCameraObject = nil;
        SM.viewportButton:Hide();
    end
end

function AM.PlayToggle_OnClick(on)
    if (on) then
        AM.Play();
    else
        AM.Pause();
    end
end

function AM.SeekToStartButton_OnClick()
    AM.SetTime(0);
end

function AM.SeekToEndButton_OnClick()
    if (AM.loadedTimeline) then
        AM.SetTime(AM.loadedTimeline:GetDuration());
    end
end

function AM.SkipFrameForwardButton_OnClick()
    if (AM.loadedTimeline) then
        local nextTime = AM.loadedTimeline:GetTime() + 35;
        if (nextTime > AM.loadedTimeline:GetDuration()) then
            nextTime = AM.loadedTimeline:GetDuration();
        end
        AM.SetTime(nextTime);
    end
end

function AM.SkipFrameBackwardButton_OnClick()
    if (AM.loadedTimeline) then
        local nextTime = AM.loadedTimeline:GetTime() - 33;
        if (nextTime < 0) then
            nextTime = 0;
        end
        AM.SetTime(nextTime);
    end
end

function AM.LoopToggle_OnClick(on)
    AM.loopPlay = on;
end

function AM.CameraToggle_OnClick(on)
    AM.cameraPlay = on;
end

function AM.Dropdown_SetUIMode(index)
    if (index == 1) then
        AM.ChangeUIMode(AM.Mode.Tracks);
    elseif(index == 2) then
        AM.ChangeUIMode(AM.Mode.Keyframes);
    elseif(index == 3) then
        AM.ChangeUIMode(AM.Mode.Curves);
    end
end

function AM.ChangeUIMode(mode)

    AM.mainKeyframeBar:Hide();
    AM.workAreaBG:Hide();
    AM.curveViewBG:Hide();
    AM.keyframeViewBG:Hide();

    if (mode == AM.Mode.Tracks) then
        -- switch to tracks view
        AM.mainKeyframeBar:Show();
        AM.workAreaBG:Show();
        AM.mainToolbar:ToggleGroupComponent(AM.mainToolbarGroup, "AddObject", true);
        AM.mainToolbar:ToggleGroupComponent(AM.mainToolbarGroup, "RemoveObject", true);
        AM.mainToolbar:ToggleGroupComponent(AM.mainToolbarGroup, "AddAnim", true);
        AM.mainToolbar:ToggleGroupComponent(AM.mainToolbarGroup, "RemoveAnim", true);
        AM.mainToolbar:ToggleGroupComponent(AM.mainToolbarGroup, "AddKey", true);
        AM.mainToolbar:ToggleGroupComponent(AM.mainToolbarGroup, "RemoveKey", true);
        AM.mainToolbar:ToggleGroupComponent(AM.mainToolbarGroup, "InterpolationIn", false);
        AM.mainToolbar:ToggleGroupComponent(AM.mainToolbarGroup, "InterpolationOut", false);
    elseif (mode == AM.Mode.Keyframes) then
        AM.mainToolbar:ToggleGroupComponent(AM.mainToolbarGroup, "AddObject", false);
        AM.mainToolbar:ToggleGroupComponent(AM.mainToolbarGroup, "RemoveObject", false);
        AM.mainToolbar:ToggleGroupComponent(AM.mainToolbarGroup, "AddAnim", false);
        AM.mainToolbar:ToggleGroupComponent(AM.mainToolbarGroup, "RemoveAnim", false);
        AM.mainToolbar:ToggleGroupComponent(AM.mainToolbarGroup, "AddKey", true);
        AM.mainToolbar:ToggleGroupComponent(AM.mainToolbarGroup, "RemoveKey", true);
        AM.mainToolbar:ToggleGroupComponent(AM.mainToolbarGroup, "InterpolationIn", true);
        AM.mainToolbar:ToggleGroupComponent(AM.mainToolbarGroup, "InterpolationOut", true);
        AM.mainKeyframeBar:Show();
        AM.keyframeViewBG:Show();
    elseif (mode == AM.Mode.Curves) then
        -- switch to curve view
        AM.mainToolbar:ToggleGroupComponent(AM.mainToolbarGroup, "AddObject", false);
        AM.mainToolbar:ToggleGroupComponent(AM.mainToolbarGroup, "RemoveObject", false);
        AM.mainToolbar:ToggleGroupComponent(AM.mainToolbarGroup, "AddAnim", false);
        AM.mainToolbar:ToggleGroupComponent(AM.mainToolbarGroup, "RemoveAnim", false);
        AM.mainToolbar:ToggleGroupComponent(AM.mainToolbarGroup, "AddKey", false);
        AM.mainToolbar:ToggleGroupComponent(AM.mainToolbarGroup, "RemoveKey", false);
        AM.mainToolbar:ToggleGroupComponent(AM.mainToolbarGroup, "InterpolationIn", false);
        AM.mainToolbar:ToggleGroupComponent(AM.mainToolbarGroup, "InterpolationOut", false);
        AM.curveViewBG:Show();
    end

    AM.uiMode = mode;
    AM.mainToolbar:RefreshGroup(AM.mainToolbarGroup);
    AM.RefreshWorkspace();
end

function AM.Button_SetModeToTracks()
    AM.ChangeUIMode(AM.Mode.Tracks);
end

function AM.Button_SetModeToKeyframes()
    AM.ChangeUIMode(AM.Mode.Keyframes);
end

function AM.Button_SetModeToCurves()
    AM.ChangeUIMode(AM.Mode.Curves);
end

function AM.Button_SetInterpolationInMode(value)
    local interpolation = Keyframe.Interpolation.Bezier;
    if (value == 1) then
        interpolation = Keyframe.Interpolation.Bezier;
    elseif (value == 2) then
        interpolation = Keyframe.Interpolation.Linear;
    elseif (value == 3) then
        interpolation = Keyframe.Interpolation.Step;
    elseif (value == 4) then
        interpolation = Keyframe.Interpolation.Slow;
    elseif (value == 5) then
        interpolation = Keyframe.Interpolation.Fast;
    end

    AM.currentInterpolationIn = interpolation;
end

function AM.Button_SetInterpolationOutMode(value)
    local interpolation = Keyframe.Interpolation.Bezier;
    if (value == 1) then
        interpolation = Keyframe.Interpolation.Bezier;
    elseif (value == 2) then
        interpolation = Keyframe.Interpolation.Linear;
    elseif (value == 3) then
        interpolation = Keyframe.Interpolation.Step;
    elseif (value == 4) then
        interpolation = Keyframe.Interpolation.Slow;
    elseif (value == 5) then
        interpolation = Keyframe.Interpolation.Fast;
    end

    AM.currentInterpolationOut = interpolation;
end

function AM.Button_SetKeyInterpolationIn()
    if (AM.selectedKeys) then
        for i = 1, #AM.selectedKeys, 1 do
            AM.selectedKeys[i]:SetInterpolationIn(AM.currentInterpolationIn);
        end
    end

    AM.RefreshWorkspace();
end

function AM.Button_SetKeyInterpolationOut()
    if (AM.selectedKeys) then
        for i = 1, #AM.selectedKeys, 1 do
            AM.selectedKeys[i]:SetInterpolationOut(AM.currentInterpolationOut);
        end
    end

    AM.RefreshWorkspace();
end

function AM.Button_SetKeyAddMode(value)
    local mode = AM.KeyAddMode.All;

    if (value == 1) then
        mode = AM.KeyAddMode.All;
    elseif (value == 2) then
        mode = AM.KeyAddMode.Position;
    elseif (value == 3) then
        mode = AM.KeyAddMode.Rotation;
    elseif (value == 4) then
        mode = AM.KeyAddMode.Scale;
    end

    AM.keyAddMode = mode;
end

function AM.Button_AddKey()
    if (AM.keyAddMode == AM.KeyAddMode.All) then
        AM.AddFullKey(AM.selectedTrack);
    elseif (AM.keyAddMode == AM.KeyAddMode.Position) then
        AM.AddPosKey(AM.selectedTrack);
    elseif (AM.keyAddMode == AM.KeyAddMode.Rotation) then
        AM.AddRotKey(AM.selectedTrack);
    elseif (AM.keyAddMode == AM.KeyAddMode.Scale) then
        AM.AddScaleKey(AM.selectedTrack);
    end
end

function AM.OnFinishedKeyRetiming()
    -- check for any time overlaps
    if (AM.toOverrideKeys) then
        for i = 1, #AM.toOverrideKeys, 1 do
            if (AM.toOverrideKeys[i]) then
                AM.RemoveKey_internal(AM.selectedTrack, AM.toOverrideKeys[i]);
            end
        end

        AM.toOverrideKeys = nil;
    end

    if (AM.clonedKeys and #AM.clonedKeys > 0) then
        if (AM.clonedKeys[1] == AM.selectedKeys[1]) then
            for i = 1, #AM.clonedKeys, 1 do
                AM.RemoveKey_internal(AM.selectedTrack, AM.clonedKeys[i]);
            end
        end
        AM.clonedKeys = nil;
    end

    AM.selectedTrack:SortAllKeyframes();
    Editor.FinishAction();
end
