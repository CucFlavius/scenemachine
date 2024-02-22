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

local tabButtonHeight = 20;
local tabPool = {};

AM.needlePoolSize = 10;
AM.usedNeedles = 0;
AM.minShownNeedles = 10;
AM.maxShownNeedles = 25;
AM.needles = {};
AM.currentCrop = {
    min = 0;
    max = 0.3;
};

AM.inputState = {
    minFramePosStart = 0;
    maxFramePosStart = 0;
    centerFramePosStart = 0;
    timebarFramePosStart = 0;
    mousePosStartX = 0;
    mousePosStartY = 0;
    movingMin = false;
    movingMax = false;
    movingCenter = false;
    movingTime = false;
    movingAnim = -1;
    movingAnimHandleL = -1;
    movingAnimHandleR = -1;

    movingScrollbar = false;
    scrollbarFramePosStart = 0;
};
AM.loadedTimelineIndex = 1;
AM.loadedTimeline = nil;
AM.selectedTrack = nil;
AM.selectedAnim = nil;
AM.selectedKey = nil;

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

AM.uiMode = 0;      -- 0 = keyframe/anims, 1 = curve view

AM.CurvePoolSize = 30;
AM.usedCurveLines = 0;

AM.colors = {
    {242, 240, 161},
    {252, 174, 187},
    {241, 178, 220},
    {191, 155, 222},
    {116, 209, 234},
    {157, 231, 215},
    {158, 151, 142},
    {0, 154, 206},
    {68, 214, 44},
    {255, 233, 0},
    {255, 170, 77},
    {255, 114, 118},
    {255, 62, 181},
    {234, 39, 194}
}

AM.playing = false;
AM.loopPlay = true;
AM.lastKeyedTime = 0;

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

    if (AM.loadedTimeline) then
        if (AM.playing) then
            local deltaTimeMS = math.floor(deltaTime * 1000);
            local nextTime = AM.loadedTimeline.currentTime + deltaTimeMS;

            if (not AM.loopPlay) then
                -- if stop at the end
                if (nextTime >= AM.loadedTimeline.duration) then
                    AM.SetTime(AM.loadedTimeline.duration);
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

            AM.SetTime(nextTime);
        end
    end

    if (AM.inputState.movingMin) then
        local groupBgW = AM.workAreaViewport:GetWidth() + 6;
        local mouseDiff = (AM.inputState.mousePosStartX - Input.mouseXRaw) * Renderer.scale;
        local nextPoint = AM.inputState.minFramePosStart - mouseDiff;
        local newPoint = 0;
        if (nextPoint >= 0 and nextPoint < AM.inputState.maxFramePosStart - 32) then
            AM.cropperLeftDrag:ClearAllPoints();
            newPoint = nextPoint;
            AM.cropperLeftDrag:SetPoint("LEFT", nextPoint, 0);
        else
            if (nextPoint <= 0) then
                AM.cropperLeftDrag:ClearAllPoints();
                newPoint = 0;
                AM.cropperLeftDrag:SetPoint("LEFT", 0, 0);
            end
            if (nextPoint >= AM.inputState.maxFramePosStart - 32) then
                AM.cropperLeftDrag:ClearAllPoints();
                newPoint = AM.inputState.maxFramePosStart - 32;
                AM.cropperLeftDrag:SetPoint("LEFT", AM.inputState.maxFramePosStart - 32, 0);
            end
        end

        AM.cropperSlider:ClearAllPoints();
        AM.cropperSlider:SetPoint("LEFT", AM.cropperBg:GetFrame(), "LEFT", newPoint + 16, 0);
        AM.cropperSlider:SetPoint("RIGHT", AM.cropperBg:GetFrame(), "LEFT", AM.inputState.maxFramePosStart, 0);
        local newPointNormalized = newPoint / groupBgW;
        AM.currentCrop.min = newPointNormalized;
        AM.RefreshTimebar();
        AM.RefreshWorkspace();
    end

    if (AM.inputState.movingMax) then
        local groupBgW = AM.workAreaViewport:GetWidth() + 6;
        local mouseDiff = (AM.inputState.mousePosStartX - Input.mouseXRaw) * Renderer.scale;
        local nextPoint = AM.inputState.maxFramePosStart - mouseDiff;
        local newPoint = 0;
        if (nextPoint > AM.inputState.minFramePosStart + 32 and nextPoint < groupBgW) then
            AM.cropperRightDrag:ClearAllPoints();
            newPoint = nextPoint;
            AM.cropperRightDrag:SetPoint("LEFT", nextPoint, 0);
        else
            if (nextPoint <= AM.inputState.minFramePosStart + 32) then
                AM.cropperRightDrag:ClearAllPoints();
                newPoint = AM.inputState.minFramePosStart + 32;
                AM.cropperRightDrag:SetPoint("LEFT", AM.inputState.minFramePosStart + 32, 0);
            end
            if (nextPoint > groupBgW) then
                AM.cropperRightDrag:ClearAllPoints();
                newPoint = groupBgW;
                AM.cropperRightDrag:SetPoint("LEFT", groupBgW, 0);
            end
        end

        AM.cropperSlider:ClearAllPoints();
        AM.cropperSlider:SetPoint("RIGHT", AM.cropperBg:GetFrame(), "LEFT", newPoint, 0);
        AM.cropperSlider:SetPoint("LEFT", AM.cropperBg:GetFrame(), "LEFT", AM.inputState.minFramePosStart + 16, 0);
        local newPointNormalized = newPoint / groupBgW;
        AM.currentCrop.max = newPointNormalized;
        AM.RefreshTimebar();
        AM.RefreshWorkspace();
    end

    if (AM.inputState.movingCenter) then
        local groupBgW = AM.workAreaViewport:GetWidth() + 6;
        local sliderSize = AM.inputState.maxFramePosStart - AM.inputState.minFramePosStart;
        local mouseDiff = (AM.inputState.mousePosStartX - Input.mouseXRaw) * Renderer.scale;
        local nextPoint = AM.inputState.centerFramePosStart - mouseDiff;
        local newPoint = 0;
        if (nextPoint > 0 and nextPoint < (groupBgW) - sliderSize) then
            newPoint = nextPoint;
        else
            if (nextPoint <= 0) then
                newPoint = 0;
            end
            if (nextPoint > groupBgW - sliderSize) then
                newPoint = groupBgW - sliderSize;
            end
        end

        AM.cropperSlider:ClearAllPoints();
        AM.cropperSlider:SetPoint("RIGHT", AM.cropperBg:GetFrame(), "LEFT", newPoint + sliderSize, 0);
        AM.cropperSlider:SetPoint("LEFT", AM.cropperBg:GetFrame(), "LEFT", newPoint + 16, 0);
        
        AM.cropperRightDrag:ClearAllPoints();
        AM.cropperRightDrag:SetPoint("LEFT", newPoint + sliderSize, 0);
        
        AM.cropperLeftDrag:ClearAllPoints();
        AM.cropperLeftDrag:SetPoint("LEFT", newPoint, 0);

        local newPointMinNormalized = newPoint / groupBgW;
        local newPointMaxNormalized = (newPoint + sliderSize) / groupBgW;
        AM.currentCrop.max = newPointMaxNormalized;
        AM.currentCrop.min = newPointMinNormalized;
        AM.RefreshTimebar();
        AM.RefreshWorkspace();
    end

    if (AM.inputState.movingTime) then
        
        local groupBgH = AM.timebarGroup:GetWidth() - 26;
        local mouseDiff = (AM.inputState.timebarFramePosStart + 10) - Input.mouseXRaw * Renderer.scale;
        local newPoint = -mouseDiff;

        -- Scroll the items list --
        local newPointNormalized = newPoint / groupBgH;
        local totalTimeMS = AM.loadedTimeline.duration;
        local startMS = AM.currentCrop.min * totalTimeMS;
        local endMS = AM.currentCrop.max * totalTimeMS;
        local lengthMS = endMS - startMS;

        local timeMS = startMS + (newPointNormalized * lengthMS);
        timeMS = max(startMS, min(endMS, timeMS));  -- clamp

        AM.SetTime(math.floor(timeMS));
    end

    if (AM.inputState.movingAnim ~= -1) then

        local groupBgH = AM.timebarGroup:GetWidth() - 26;
        local mouseDiff = (AM.inputState.mousePosStartX - Input.mouseXRaw) * Renderer.scale;
        local newPoint = -mouseDiff;

        -- Scroll the items list --
        local newPointNormalized = newPoint / groupBgH;
        local totalTimeMS = AM.loadedTimeline.duration;
        local startMS = AM.currentCrop.min * totalTimeMS;
        local endMS = AM.currentCrop.max * totalTimeMS;
        --print(startMS .. " " .. endMS);
        local lengthMS = endMS - startMS;

        local diffTimeMS = (newPointNormalized * lengthMS);

        if (diffTimeMS ~= 0) then

            local animElement = AM.AnimationPool[AM.inputState.movingAnim];
            local trackElement = animElement.trackIdx;
            local track = AM.loadedTimeline.tracks[animElement.trackIdx];
            local anim = track.animations[animElement.animIdx];
            local desiredStartT = math.floor(anim.startT + diffTimeMS);
            local desiredEndT = math.floor(anim.endT + diffTimeMS);

            -- check each side
            local animL = track.animations[animElement.animIdx - 1];
            local animR = track.animations[animElement.animIdx + 1];

            local length = anim.endT - anim.startT;

            local savePrevMouse = AM.inputState.mousePosStartX;

            if (animL and not animR) then
                if (desiredStartT > animL.endT) then
                    anim.startT = desiredStartT;
                    anim.endT = desiredEndT;
                    AM.inputState.mousePosStartX = Input.mouseXRaw;
                else
                    -- check if mouse past whole of animL, and swap them
                    -- sL     eL s          e
                    -- sL          eL s     e
                    if (desiredStartT < animL.startT) then
                        -- swap
                        local startT = anim.startT;
                        local endT = anim.endT;
                        local lStartT = animL.startT;
                        local lEndT = animL.endT;
                        animL.endT = lStartT + (endT - startT);
                        anim.startT = animL.endT;
                        AM.SwapAnimData(anim, animL);
                        -- select the other
                        AM.inputState.movingAnim = AM.inputState.movingAnim - 1;
                        AM.SelectAnimation(AM.inputState.movingAnim);
                        AM.inputState.mousePosStartX = Input.mouseXRaw;
                        isSquashing = false;
                        squashIndex = AM.inputState.movingAnim + 1;
                    else
                        anim.startT = animL.endT;
                        anim.endT = anim.startT + length;
                        squash = (AM.inputState.mousePosStartX - Input.mouseXRaw) * squashStrength;
                        isSquashing = true;
                        squashIndex = AM.inputState.movingAnim - 1;
                    end
                end
            elseif (animR and not animL) then
                if (desiredEndT < animR.startT) then
                    anim.startT = desiredStartT;
                    anim.endT = desiredEndT;
                    AM.inputState.mousePosStartX = Input.mouseXRaw;
                else
                    -- check if mouse past whole of animR, and swap them
                    -- s     e sR          eR
                    -- s          e sR     eR
                    if (desiredEndT > animR.endT) then
                        -- swap
                        local startT = anim.startT;
                        local endT = anim.endT;
                        local rStartT = animR.startT;
                        local rEndT = animR.endT;
                        anim.endT = startT + (rEndT - rStartT);
                        animR.startT = anim.endT;
                        AM.SwapAnimData(anim, animR);
                        -- select the other
                        AM.inputState.movingAnim = AM.inputState.movingAnim + 1;
                        AM.SelectAnimation(AM.inputState.movingAnim);
                        AM.inputState.mousePosStartX = Input.mouseXRaw;
                        isSquashing = false;
                        squashIndex = AM.inputState.movingAnim - 1;
                    else
                        anim.endT = animR.startT;
                        anim.startT = anim.endT - length;
                        squash = -(AM.inputState.mousePosStartX - Input.mouseXRaw) * squashStrength;
                        isSquashing = true;
                        squashIndex = AM.inputState.movingAnim + 1;
                    end
                end
            elseif (animL and animR) then
                if (desiredStartT > animL.endT) and (desiredEndT < animR.startT) then
                    anim.startT = desiredStartT;
                    anim.endT = desiredEndT;
                    AM.inputState.mousePosStartX = Input.mouseXRaw;
                else
                    if (desiredStartT <= animL.endT) then
                        -- check if mouse past whole of animR, and swap them
                        -- sL     eL s          e
                        -- sL          eL s     e
                        if (desiredStartT < animL.startT) then
                            -- swap
                            local startT = anim.startT;
                            local endT = anim.endT;
                            local lStartT = animL.startT;
                            local lEndT = animL.endT;
                            animL.endT = lStartT + (endT - startT);
                            anim.startT = animL.endT;
                            AM.SwapAnimData(anim, animL);
                            -- select the other
                            AM.inputState.movingAnim = AM.inputState.movingAnim - 1;
                            AM.SelectAnimation(AM.inputState.movingAnim);
                            AM.inputState.mousePosStartX = Input.mouseXRaw;
                            isSquashing = false;
                            squashIndex = AM.inputState.movingAnim + 1;
                        else
                            anim.startT = animL.endT;
                            anim.endT = anim.startT + length;
                            squash = (AM.inputState.mousePosStartX - Input.mouseXRaw) * squashStrength;
                            isSquashing = true;
                            squashIndex = AM.inputState.movingAnim - 1;
                        end
                    elseif (desiredEndT >= animR.startT) then
                        -- check if mouse past whole of animR, and swap them
                        -- s     e sR          eR
                        -- s          e sR     eR
                        if (desiredEndT > animR.endT) then
                            -- swap
                            local startT = anim.startT;
                            local endT = anim.endT;
                            local rStartT = animR.startT;
                            local rEndT = animR.endT;
                            anim.endT = startT + (rEndT - rStartT);
                            animR.startT = anim.endT;
                            AM.SwapAnimData(anim, animR);
                            -- select the other
                            AM.inputState.movingAnim = AM.inputState.movingAnim + 1;
                            AM.SelectAnimation(AM.inputState.movingAnim);
                            AM.inputState.mousePosStartX = Input.mouseXRaw;
                            isSquashing = false;
                            squashIndex = AM.inputState.movingAnim - 1;
                        else
                            anim.endT = animR.startT;
                            anim.startT = anim.endT - length;
                            squash = -(AM.inputState.mousePosStartX - Input.mouseXRaw) * squashStrength;
                            isSquashing = true;
                            squashIndex = AM.inputState.movingAnim + 1;
                        end
                    end
                end
            elseif (not animL and not animR) then
                anim.startT = desiredStartT;
                anim.endT = desiredEndT;
                AM.inputState.mousePosStartX = Input.mouseXRaw;
            end

            if (anim.startT < 0) then
                anim.startT = 0;
                anim.endT = anim.startT + length;
                AM.inputState.mousePosStartX = savePrevMouse;
            elseif(anim.endT > totalTimeMS) then
                anim.endT = totalTimeMS;
                anim.startT = anim.endT - length;
                AM.inputState.mousePosStartX = savePrevMouse;
            end

            AM.SetTime(AM.loadedTimeline.currentTime);
            AM.RefreshWorkspace();
        end
    end

    if (AM.inputState.movingAnimHandleL ~= -1) then
        local groupBgH = AM.timebarGroup:GetWidth() - 26;
        local mouseDiff = (AM.inputState.mousePosStartX - Input.mouseXRaw) * Renderer.scale;
        local newPoint = -mouseDiff;

        -- Scroll the items list --
        local newPointNormalized = newPoint / groupBgH;
        local totalTimeMS = AM.loadedTimeline.duration;
        local startMS = AM.currentCrop.min * totalTimeMS;
        local endMS = AM.currentCrop.max * totalTimeMS;
        local lengthMS = endMS - startMS;

        local diffTimeMS = (newPointNormalized * lengthMS);

        if (diffTimeMS ~= 0) then
            local animElement = AM.AnimationPool[AM.inputState.movingAnimHandleL];
            local trackElement = animElement.trackIdx;
            local track = AM.loadedTimeline.tracks[animElement.trackIdx];
            local anim = track.animations[animElement.animIdx];
            local desiredStartT = math.floor(anim.startT + diffTimeMS);

            -- check left
            local animL = track.animations[animElement.animIdx - 1];
            local length = anim.endT - anim.startT;
            local savePrevMouse = AM.inputState.mousePosStartX;

            if (animL) then
                if (desiredStartT > animL.endT) then
                    anim.startT = desiredStartT;
                    AM.inputState.mousePosStartX = Input.mouseXRaw;
                else
                    anim.startT = animL.endT;
                end
            else
                anim.startT = desiredStartT;
                AM.inputState.mousePosStartX = Input.mouseXRaw;
            end

            -- limit anim to start and end of track
            if (anim.startT < 0) then
                anim.startT = 0;
                AM.inputState.mousePosStartX = savePrevMouse;
            elseif(anim.endT > totalTimeMS) then
                anim.startT = totalTimeMS - length;
                AM.inputState.mousePosStartX = savePrevMouse;
            end

            -- limit anim min size to 100 miliseconds
            if (anim.startT > anim.endT - 100) then
                anim.startT = anim.endT - 100;
                AM.inputState.mousePosStartX = savePrevMouse;
            end

            AM.SetTime(AM.loadedTimeline.currentTime);
            AM.RefreshWorkspace();
        end
    end

    if (AM.inputState.movingAnimHandleR ~= -1) then
        local groupBgH = AM.timebarGroup:GetWidth() - 26;
        local mouseDiff = (AM.inputState.mousePosStartX - Input.mouseXRaw) * Renderer.scale;
        local newPoint = -mouseDiff;

        -- Scroll the items list --
        local newPointNormalized = newPoint / groupBgH;
        local totalTimeMS = AM.loadedTimeline.duration;
        local startMS = AM.currentCrop.min * totalTimeMS;
        local endMS = AM.currentCrop.max * totalTimeMS;
        local lengthMS = endMS - startMS;

        local diffTimeMS = (newPointNormalized * lengthMS);

        if (diffTimeMS ~= 0) then
            local animElement = AM.AnimationPool[AM.inputState.movingAnimHandleR];
            local trackElement = animElement.trackIdx;
            local track = AM.loadedTimeline.tracks[animElement.trackIdx];
            local anim = track.animations[animElement.animIdx];
            local desiredEndT = math.floor(anim.endT + diffTimeMS);

            -- check right
            local animR = track.animations[animElement.animIdx + 1];
            local length = anim.endT - anim.startT;
            local savePrevMouse = AM.inputState.mousePosStartX;

            if (animR) then
                if (desiredEndT < animR.startT) then
                    anim.endT = desiredEndT;
                    AM.inputState.mousePosStartX = Input.mouseXRaw;
                else
                    anim.endT = animR.startT;
                end
            else
                anim.endT = desiredEndT;
                AM.inputState.mousePosStartX = Input.mouseXRaw;
            end

            -- limit anim to start and end of track
            if (anim.startT < 0) then
                anim.endT = length;
                AM.inputState.mousePosStartX = savePrevMouse;
            elseif(anim.endT > totalTimeMS) then
                anim.endT = totalTimeMS;
                AM.inputState.mousePosStartX = savePrevMouse;
            end

            -- limit anim min size to 100 miliseconds
            if (anim.startT > anim.endT - 100) then
                anim.endT = anim.startT + 100;
                AM.inputState.mousePosStartX = savePrevMouse;
            end

            AM.SetTime(AM.loadedTimeline.currentTime);
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

function AM.SwapAnimData(A, B)
    local id = A.id;
    local name = A.name;
    local colorId = A.colorId;
    local variation = A.variation;
    local animLength = A.animLength

    A.id = B.id;
    A.name = B.name;
    A.colorId = B.colorId;
    A.variation = B.variation;
    A.animLength = B.animLength;


    B.id = id;
    B.name = name;
    B.colorId = colorId;
    B.variation = variation;
    B.animLength = animLength;
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

    AM.groupBG = UI.Rectangle:New(x, y, w, h, parent, "TOPLEFT", "TOPLEFT",  0, 0, 0, 0);
    AM.groupBG:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 0, 0);
    AM.groupBG:SetFrameLevel(startLevel);
    AM.groupBG:GetFrame():SetScript("OnSizeChanged",
    function(_, width, height)
        AM.RefreshTimebar();
        AM.RefreshWorkspace();
        if (AM.workAreaScrollbar) then
            AM.workAreaScrollbar:Resize(height - 106, AM.workAreaList:GetHeight());
        end
        if (AM.TimeSliderBar) then
            AM.TimeSliderBar:SetHeight(height - 80);
        end
    end);

    AM.parentFrame = parent;
    AM.groupBGy = y;
    AM.addTimelineButtonTab = AM.CreateNewTimelineTab(0, 0, timelineTabH, tabButtonHeight, AM.groupBG:GetFrame(), startLevel + 1);
    AM.addTimelineButtonTab.text:SetText("+");
    AM.addTimelineButtonTab.ntex:SetColorTexture(0, 0, 0 ,0);
    AM.addTimelineButtonTab.text:SetAllPoints(AM.addTimelineButtonTab);
    AM.addTimelineButtonTab:Hide();
    --TextBox:New(x, y, w, h, parent, point, parentPoint, text, textHeight, textFont)
    AM.addTimelineEditBox = UI.TextBox:New(0, 0, 100, tabButtonHeight, AM.groupBG:GetFrame(), "TOPLEFT", "TOPLEFT", "Timeline Name");
    AM.addTimelineEditBox:Hide();
    AM.addTimelineEditBox:SetFrameLevel(startLevel + 2);

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
    AM.CreateTimebar(0, timebarY, w, timebarH, AM.groupBG:GetFrame(), startLevel + 3);
    AM.CreateTimeSlider(workAreaH, startLevel + 5);
    AM.CreateToolbar(0, toolbarY, w, toolbarH, AM.groupBG:GetFrame(), startLevel + 3);
    AM.CreateKeyframeBar(keyframeBarX, keyframeBarY, keyframeBarW, keyframeBarH, AM.groupBG:GetFrame(), startLevel + 3)
    AM.CreateWorkArea(workAreaX - 6, workAreaY, workAreaW, workAreaH, AM.groupBG:GetFrame(), startLevel + 3);
    AM.CreateCropperBar(0, cropperBarY, w - 14, cropperBarH, AM.groupBG:GetFrame(), startLevel + 3);

    local curveViewH = h - (timelineTabH + timebarH + cropperBarH + bottomPad + toolbarH);
    local curveViewY = -(timebarH + timelineTabH + toolbarH);
    AM.CreateCurveView(workAreaX - 6, curveViewY, workAreaW, curveViewH, AM.groupBG:GetFrame(), startLevel + 3);

    AM.CreateAnimationSelectWindow(0, 0, 300, 500);

    AM.RefreshTimelineTabs();
    AM.RefreshTimebar();

    AM.ChangeUIMode(AM.uiMode);
    AM.RefreshWorkspace();
end

function AM.CreateAnimationSelectWindow(x, y, w, h)
    AM.animSelectWindow = UI.Window:New(x, y, w, h, SceneMachine.mainWindow:GetFrame(), "CENTER", "CENTER", "AnimationList");
    AM.animSelectWindow:SetFrameStrata(Editor.SUB_FRAME_STRATA);

    AM.animScrollList = UI.PooledScrollList:New(0, 0, w, h - 30, AM.animSelectWindow:GetFrame(), "TOPLEFT", "TOPLEFT");
    AM.animScrollList:SetPoint("BOTTOMRIGHT", AM.animSelectWindow:GetFrame(), "BOTTOMRIGHT", 0, 30);
	AM.animScrollList:SetItemTemplate(
		{
			height = 20,
			buildItem = function(item)
				-- main button --
				item.components[1] = UI.Button:New(0, 0, 50, 18, item:GetFrame(), "CENTER", "CENTER", "");
				item.components[1]:ClearAllPoints();
				item.components[1]:SetAllPoints(item:GetFrame());

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

    AM.animScrollList:SetFrameLevel(10);
	AM.animScrollList:MakePool();

    AM.animSelectWindow.loadAnimBtn = UI.Button:New(5, 5, 60, 20, AM.animSelectWindow:GetFrame(), "BOTTOMLEFT", "BOTTOMLEFT", "Add Anim", nil);
    AM.animSelectWindow.loadAnimBtn:SetScript("OnClick", function(_) AM.AddAnim(AM.selectedTrack, AM.selectedAnimID, AM.selectedAnimVariant); AM.animSelectWindow:Hide(); end);
    AM.animSelectWindow.filterBox = UI.TextBox:New(70, 5, 100, 20, AM.animSelectWindow:GetFrame(), "BOTTOMLEFT", "BOTTOMLEFT", "", 9);
    AM.animSelectWindow.filterBox:SetPoint("BOTTOMRIGHT", AM.animSelectWindow:GetFrame(), "BOTTOMRIGHT", -5, 0);
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

function AM.CreateKeyframeBar(x, y, w, h, parent, startLevel)
    AM.KeyframeBar = UI.Rectangle:New(0, y, w, h, parent, "TOPLEFT", "TOPLEFT",  0, 0, 0, 0.5);
    AM.KeyframeBar:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, y);
    AM.KeyframeBar:SetFrameLevel(startLevel);

    AM.KeyframePool = {};
    for i = 1, AM.KeyframePoolSize, 1 do
        AM.KeyframePool[i] = AM.GenerateKeyframeElement(i, 0, 0, AM.keyframeElementH, AM.keyframeElementH, AM.KeyframeBar:GetFrame(), 0.5, 0.5, 0.5, 1);
        AM.KeyframePool[i]:SetFrameLevel(startLevel + 1);
        AM.KeyframePool[i]:Hide();
    end
end

function AM.GenerateKeyframeElement(index, x, y, w, h, parent, R, G, B, A)
    local element = CreateFrame("Button", "AM.KeyframeElement"..index, parent)
	element:SetPoint("LEFT", parent, "LEFT", x, y);
	element:SetSize(w, h);
    element:SetFrameLevel(10);
    element.ntex = element:CreateTexture();
    element.ntex:SetTexture(Resources.textures["Keyframe"]);
    element.ntex:SetTexCoord(0, 0.25, 0, 0.25);
    element.ntex:SetAllPoints();
    element.ntex:SetVertexColor(R, G, B, A);
    element:SetNormalTexture(element.ntex);
    element:RegisterForClicks("LeftButtonUp", "LeftButtonDown");
    element:SetScript("OnMouseDown", function(self, button)
        --AM.inputState.movingAnim = index;
        --AM.inputState.mousePosStartX = Input.mouseXRaw;
    end);
    element:SetScript("OnMouseUp", function(self, button)
        --AM.inputState.movingAnim = -1;
    end);
    element:SetScript("OnClick", function (self, button, down)
        if (button == "LeftButton" and down) then
            AM.SelectKeyframe(index);
        end
    end)

    return element;
end

function AM.GetAvailableKeyframeElement()
    local i = AM.usedKeyframes + 1;
    AM.usedKeyframes = AM.usedKeyframes + 1;

    if (i >= #AM.KeyframePool) then
        AM.KeyframePool[i] = AM.GenerateKeyframeElement(i, 0, 0, AM.keyframeElementH, AM.keyframeElementH, AM.KeyframeBar:GetFrame(), 0.5, 0.5, 0.5, 1);
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
    local needle = UI.Rectangle:New(0, 0, 1, 4, AM.timebarGroup, "TOPLEFT", "TOPLEFT",  1, 1, 1, 0.5);
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
    local toolbar = UI.Toolbar:New(x, y, w, h, parent, 0.16, SceneMachine.mainWindow);
    toolbar:SetFrameLevel(startLevel);
    local mainGroup = toolbar:CreateGroup(x, 0, w, h,
    {
        { type = "DragHandle" },
        { type = "Button", name = "TimeSettings", icon = toolbar:GetIcon("timesettings"), action = function(self) end },
        { type = "Separator" },
        { type = "Button", name = "AddObject", icon = toolbar:GetIcon("addobj"), action = function(self) AM.AddTrack(SM.selectedObject); end },
        { type = "Button", name = "RemoveObject", icon = toolbar:GetIcon("removeobj"), action = function(self) AM.RemoveTrack(AM.selectedTrack) end },
        { type = "Separator" },
        { type = "Button", name = "AddAnim", icon = toolbar:GetIcon("addanim"), action = function(self) AM.OpenAddAnimationWindow(AM.selectedTrack); end },
        { type = "Button", name = "RemoveAnim", icon = toolbar:GetIcon("removeanim"), action = function(self) AM.RemoveAnim(AM.selectedTrack, AM.selectedAnim); end },
        { type = "Separator" },
        { type = "Button", name = "AddKey", icon = toolbar:GetIcon("addkey"), action = function(self) AM.AddKey(AM.selectedTrack); end },
        { type = "Button", name = "RemoveKey", icon = toolbar:GetIcon("removekey"), action = function(self) AM.RemoveKey(AM.selectedTrack, AM.selectedKey); end },
        { type = "DragHandle" },
        { type = "Button", name = "SeekToStart", icon = toolbar:GetIcon("skiptoend", true), action = function(self) AM.SeekToStartButton_OnClick(); end },
        { type = "Button", name = "SkipOneFrameBack", icon = toolbar:GetIcon("skiponeframe", true), action = function(self) AM.SkipFrameBackwardButton_OnClick(); end },
        { type = "Toggle", name = "PlayPause", iconOn = toolbar:GetIcon("pause"), iconOff = toolbar:GetIcon("play"), action = function(self, on) AM.PlayToggle_OnClick(on); end, default = false },
        { type = "Button", name = "SkipOneFrameForward", icon = toolbar:GetIcon("skiponeframe"), action = function(self) AM.SkipFrameForwardButton_OnClick(); end },
        { type = "Button", name = "SeekToEnd", icon = toolbar:GetIcon("skiptoend"), action = function(self) AM.SeekToEndButton_OnClick(); end },
        { type = "Separator" },
        { type = "Toggle", name = "Loop", iconOn = toolbar:GetIcon("loop"), iconOff = toolbar:GetIcon("loopoff"), action = function(self, on) AM.LoopToggle_OnClick(on); end, default = true },
        { type = "Separator" },
        { type = "Button", name = "UIMode", icon = toolbar:GetIcon("scale"), action = function(self) AM.ToggleUIMode(); end },
    });
    mainGroup:SetFrameLevel(startLevel + 1);
    AM.mainToolbar = toolbar;

    -- timer
    AM.timerTextBox = UI.Label:New(0, 0, 90, h, mainGroup:GetFrame(), "RIGHT", "RIGHT", "00:00 / 00:00", 16, Resources.fonts["Digital"]);
    AM.timerTextBox:SetFrameLevel(startLevel + 2);
end

function AM.CreateWorkArea(x, y, w, h, parent, startLevel)
    AM.workAreaBG = UI.Rectangle:New(x, y, w, h, parent, "TOPLEFT", "TOPLEFT",  0, 0, 0, 0);
    AM.workAreaBG:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -6, 20);
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
            AM.SelectKeyframe(-1);
            SH.SelectObject(nil);
        end
    end)

    AM.workAreaList = UI.Rectangle:New(0, 0, w, h, AM.workAreaViewport, "TOPLEFT", "TOPLEFT",  c4[1], c4[2], c4[3], 1);
    AM.workAreaList:SetPoint("TOPRIGHT", AM.workAreaViewport, "TOPRIGHT", 0, 0);
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

	AM.workAreaScrollbar = UI.Scrollbar:New(0, y, 16, h, AM.groupBG:GetFrame(),
	function(value)
		-- on scroll
        --AM.workAreaScrollbar:Resize(AM.groupBG:GetHeight() - 106, AM.workAreaList:GetHeight());
        local height = AM.workAreaList:GetHeight() - AM.workAreaViewport:GetHeight();
        local pos = value * height;
        --AM.workAreaList:SetSinglePoint("TOPLEFT", 0, math.floor(pos));
        AM.workAreaList:ClearAllPoints();
        AM.workAreaList:SetPoint("TOPLEFT", AM.workAreaViewport, "TOPLEFT", 0, math.floor(pos));
        AM.workAreaList:SetPoint("TOPRIGHT", AM.workAreaViewport, "TOPRIGHT", 0, math.floor(pos));
	end);
    AM.workAreaScrollbar:SetPoint("BOTTOMRIGHT", AM.groupBG:GetFrame(), "BOTTOMRIGHT", 0, 20);
    AM.workAreaScrollbar:SetFrameLevel(startLevel + 6);

    AM.workAreaCreated = true;
    AM.RefreshWorkspace();
end

function AM.CreateCurveView(x, y, w, h, parent)
    AM.curveViewBG = UI.Rectangle:New(x, y, w, h, parent, "TOPLEFT", "TOPLEFT",  0, 0, 0, 1);

    -- create line pool
    AM.CurvePool = {};
    for i = 1, AM.CurvePoolSize, 1 do
        AM.CurvePool[i] = AM.CreateCurveLineElement();
    end
end

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

    if (i >= #AM.TrackPool) then
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
    element.ntex:SetVertexColor(AM.colors[colIdx][1] / 255, AM.colors[colIdx][2] / 255, AM.colors[colIdx][3] / 255,1);
    element:SetNormalTexture(element.ntex);
    element:RegisterForClicks("LeftButtonUp", "LeftButtonDown");
    element:SetScript("OnMouseDown", function(self, button)
        AM.inputState.movingAnim = index;
        AM.inputState.mousePosStartX = Input.mouseXRaw;
    end);
    element:SetScript("OnMouseUp", function(self, button)
        AM.inputState.movingAnim = -1;
    end);
    element:SetScript("OnClick", function (self, button, down)
        if (button == "LeftButton" and down) then
            AM.SelectAnimation(index);
            AM.SelectKeyframe(-1);
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
    element.handleL:RegisterForClicks("LeftButtonUp", "LeftButtonDown");
    element.handleL:SetScript("OnMouseDown", function(self, button)
        AM.inputState.movingAnimHandleL = index;
        AM.inputState.mousePosStartX = Input.mouseXRaw;
    end);
    element.handleL:SetScript("OnMouseUp", function(self, button)
        AM.inputState.movingAnimHandleL = -1;
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
    element.handleR:RegisterForClicks("LeftButtonUp", "LeftButtonDown");
    element.handleR:SetScript("OnMouseDown", function(self, button)
        AM.inputState.movingAnimHandleR = index;
        AM.inputState.mousePosStartX = Input.mouseXRaw;
    end);
    element.handleR:SetScript("OnMouseUp", function(self, button)
        AM.inputState.movingAnimHandleR = -1;
    end);
    element.handleR:SetScript("OnClick", function (self, button, down)
        if (button == "LeftButton" and down) then
            AM.SelectAnimation(index);
        end
    end)

    -- name
    element.name = UI.Label:New(2, 0, 100, 10, element, "CENTER", "CENTER", index, 8);
    element.name:ClearAllPoints();
    element.name:SetPoint("LEFT", element, "LEFT", 10, 0);
    element.name:SetPoint("RIGHT", element);
    element.name:SetAlpha(0.7);
    element.name:SetTextColor(0, 0, 0, 1);
    element:Hide();

    return element;
end

function AM.GetAvailableAnimationElement()
    local i = AM.usedAnimations + 1;
    AM.usedAnimations = AM.usedAnimations + 1;

    if (i >= #AM.AnimationPool) then
        AM.AnimationPool[i] = AM.GenerateAnimationElement(i, 0, 0, AM.trackElementH, AM.trackElementH, AM.workAreaList:GetFrame(), 0, 0, 0, 1);
    end

    return AM.AnimationPool[i];
end

function AM.CreateCropperBar(x, y, w, h, parent)
    AM.cropperBg = UI.Rectangle:New(x, y, w, h, parent, "BOTTOMLEFT", "BOTTOMLEFT",  0, 0, 0, 0);
    AM.cropperBg:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", x, y);

    AM.cropperBgCenter = UI.ImageBox:New(h, 0, w - (h * 2), h, AM.cropperBg:GetFrame(), "LEFT", "LEFT", Resources.textures["CropBar"], { 0.25 + 0.125, 0.75 - 0.125, 0, 0.5 });
    AM.cropperBgCenter:SetPoint("RIGHT", AM.cropperBg:GetFrame(), "RIGHT", -h, y);
    AM.cropperBgCenter:SetVertexColor(0.18,0.18,0.18,1);

    AM.cropperBgLeft = UI.ImageBox:New(0, 0, h, h, AM.cropperBg:GetFrame(), "LEFT", "LEFT", Resources.textures["CropBar"], { 0, 0.5, 0, 0.5 });
    AM.cropperBgLeft:SetVertexColor(0.18,0.18,0.18,1);

    AM.cropperBgRight = UI.ImageBox:New(0, 0, h, h, AM.cropperBg:GetFrame(), "RIGHT", "RIGHT", Resources.textures["CropBar"], { 0.5, 1.0, 0, 0.5 });
    AM.cropperBgRight:SetVertexColor(0.18,0.18,0.18,1);

    local initialSliderLength = w * (AM.currentCrop.max - AM.currentCrop.min) - 10;

    -- Left handle
    AM.cropperLeftDrag = CreateFrame("Button", "AM.cropperLeftDrag", AM.cropperBg:GetFrame())
	AM.cropperLeftDrag:SetPoint("LEFT", AM.cropperBg:GetFrame(), "LEFT", 0, 0);
	AM.cropperLeftDrag:SetSize(h, h);
    --AM.cropperLeftDrag:SetAlpha(0.5);
    AM.cropperLeftDrag.ntex = AM.cropperLeftDrag:CreateTexture();
    AM.cropperLeftDrag.ntex:SetTexture(Resources.textures["CropBar"]);
    AM.cropperLeftDrag.ntex:SetTexCoord(0, 0.5, 0, 0.5);    -- (left,right,top,bottom)
    AM.cropperLeftDrag.ntex:SetAllPoints();
    AM.cropperLeftDrag.ntex:SetVertexColor(0.3,0.3,0.3,1);
    AM.cropperLeftDrag:SetNormalTexture(AM.cropperLeftDrag.ntex);
    AM.cropperLeftDrag:RegisterForClicks("LeftButtonUp", "LeftButtonDown");
    AM.cropperLeftDrag:SetScript("OnMouseDown", function(self, button)
        AM.inputState.movingMin = true;
        local gpointL, grelativeToL, grelativePointL, gxOfsL, gyOfsL = AM.cropperLeftDrag:GetPoint(1);
        AM.inputState.minFramePosStart = gxOfsL;
        local gpointR, grelativeToR, grelativePointR, gxOfsR, gyOfsR = AM.cropperRightDrag:GetPoint(1);
        AM.inputState.maxFramePosStart = gxOfsR;
        AM.inputState.mousePosStartX = Input.mouseXRaw;
    end);
    AM.cropperLeftDrag:SetScript("OnMouseUp", function(self, button) AM.inputState.movingMin = false; end);
    local burgerLD = UI.ImageBox:New(0, 0, h, h, AM.cropperLeftDrag, "CENTER", "CENTER", Resources.textures["CropBar"], { 0, 0.5, 0.5, 1 });
    burgerLD:SetAlpha(0.2);

    -- Right handle
    AM.cropperRightDrag = CreateFrame("Button", "AM.cropperRightDrag", AM.cropperBg:GetFrame())
	AM.cropperRightDrag:SetPoint("LEFT", AM.cropperBg:GetFrame(), "LEFT", initialSliderLength, 0);
	AM.cropperRightDrag:SetSize(h, h);
    --AM.cropperRightDrag:SetAlpha(0.5);
    AM.cropperRightDrag.ntex = AM.cropperRightDrag:CreateTexture();
    AM.cropperRightDrag.ntex:SetTexture(Resources.textures["CropBar"]);
    AM.cropperRightDrag.ntex:SetTexCoord(0.5, 1.0, 0, 0.5);    -- (left,right,top,bottom)
    AM.cropperRightDrag.ntex:SetAllPoints();
    AM.cropperRightDrag.ntex:SetVertexColor(0.3,0.3,0.3,1);
    AM.cropperRightDrag:SetNormalTexture(AM.cropperRightDrag.ntex);
    AM.cropperRightDrag:RegisterForClicks("LeftButtonUp", "LeftButtonDown");
    AM.cropperRightDrag:SetScript("OnMouseDown", function(self, button)
        AM.inputState.movingMax = true;
        local gpointL, grelativeToL, grelativePointL, gxOfsL, gyOfsL = AM.cropperLeftDrag:GetPoint(1);
        AM.inputState.minFramePosStart = gxOfsL;
        local gpointR, grelativeToR, grelativePointR, gxOfsR, gyOfsR = AM.cropperRightDrag:GetPoint(1);
        AM.inputState.maxFramePosStart = gxOfsR;
        AM.inputState.mousePosStartX = Input.mouseXRaw;
    end);
    AM.cropperRightDrag:SetScript("OnMouseUp", function(self, button) AM.inputState.movingMax = false; end);
    local burgerRD = UI.ImageBox:New(0, 0, h, h, AM.cropperRightDrag, "CENTER", "CENTER", Resources.textures["CropBar"], { 0, 0.5, 0.5, 1 })
    burgerRD:SetAlpha(0.2);

    -- Middle handle
    AM.cropperSlider = CreateFrame("Button", "AM.cropperSlider", AM.cropperBg:GetFrame())
	AM.cropperSlider:SetPoint("LEFT", AM.cropperBg:GetFrame(), "LEFT", h, 0);
	AM.cropperSlider:SetSize(initialSliderLength-h, h);
    --AM.cropperSlider:SetAlpha(0.5);
    AM.cropperSlider.ntex = AM.cropperSlider:CreateTexture();
    AM.cropperSlider.ntex:SetTexture(Resources.textures["CropBar"]);
    AM.cropperSlider.ntex:SetTexCoord(0.25 + 0.125, 0.75 - 0.125, 0, 0.5);    -- (left,right,top,bottom)
    AM.cropperSlider.ntex:SetAllPoints();
    AM.cropperSlider.ntex:SetVertexColor(0.3,0.3,0.3,1);
    AM.cropperSlider:SetNormalTexture(AM.cropperSlider.ntex);
    AM.cropperSlider:SetScript("OnMouseDown", function(self, button)
        AM.inputState.movingCenter = true;
        local gpointC, grelativeToC, grelativePointC, gxOfsC, gyOfsC = AM.cropperSlider:GetPoint(1);
        AM.inputState.centerFramePosStart = gxOfsC - 16;
        local gpointL, grelativeToL, grelativePointL, gxOfsL, gyOfsL = AM.cropperLeftDrag:GetPoint(1);
        AM.inputState.minFramePosStart = gxOfsL;
        local gpointR, grelativeToR, grelativePointR, gxOfsR, gyOfsR = AM.cropperRightDrag:GetPoint(1);
        AM.inputState.maxFramePosStart = gxOfsR;
        AM.inputState.mousePosStartX = Input.mouseXRaw;
    end);
    AM.cropperSlider:SetScript("OnMouseUp", function(self, button) AM.inputState.movingCenter = false; end);
end

function AM.CreateDefaultTimeline()
    return AM.CreateTimeline();
end

function AM.TimelineTabButton_OnClick(index)
    AM.LoadTimeline(index);
end

function AM.TimelineTabButton_OnRightClick(index, x, y)
    --local gpoint, grelativeTo, grelativePoint, gxOfs, gyOfs = AM.parentFrame:GetPoint(1);
    --gyOfs = gyOfs - (SceneMachine.mainWindow:GetHeight() - AM.parentFrame:GetHeight());

    local rx = x + (AM.parentFrame:GetLeft() - SceneMachine.mainWindow:GetLeft());
    local ry = (y * Renderer.scale) + (AM.parentFrame:GetTop() - SceneMachine.mainWindow:GetTop());

	local menuOptions = {
        [1] = { ["Name"] = "Rename", ["Action"] = function() AM.Button_RenameTimeline(index, x) end },
        [2] = { ["Name"] = "Edit", ["Action"] = function()  AM.Button_EditTimeline(index) end },
        [3] = { ["Name"] = "Delete", ["Action"] = function() AM.Button_DeleteTimeline(index) end },
	};

    --SceneMachine.mainWindow:PopupWindowMenu(x + gxOfs, y + gyOfs, menuOptions);
    SceneMachine.mainWindow:PopupWindowMenu(rx, ry, menuOptions);
end

function AM.Button_RenameTimeline(index, x)
    AM.addTimelineEditBox:Show();
    AM.addTimelineEditBox:SetText("Timeline " .. (#SM.loadedScene.timelines));
    AM.addTimelineButtonTab:Hide();
    AM.addTimelineEditBox:SetPoint("TOPLEFT", AM.groupBG:GetFrame(), "TOPLEFT", x, 0);
    AM.addTimelineEditBox:SetFocus();

    local previousName = "";
    if (index ~= -1) then
        -- copy current text to edit box
        previousName = tabPool[index].text:GetText();
        AM.addTimelineEditBox:SetText(previousName);
        AM.addTimelineEditBox:SetPoint("TOPLEFT", AM.groupBG:GetFrame(), "TOPLEFT", x + 10, 0);
        -- clearing current visible name
        tabPool[index].text:SetText("");
    end

    AM.addTimelineEditBox:SetScript('OnEscapePressed', function(self1) 
        self1:ClearFocus();
        Editor.ui.focused = false;
        self1:Hide();
        AM.addTimelineButtonTab:Show();
        if (index ~= -1) then
            -- restore previous visible name
            tabPool[index].text:SetText(previousName);
        end
    end);
    AM.addTimelineEditBox:SetScript('OnEnterPressed', function(self1)
        self1:ClearFocus();
        Editor.ui.focused = false;
        local text = self1:GetText();
        if (text ~= nil and text ~= "") then
            if (index == -1) then
                -- create a new timeline
                SM.loadedScene.timelines[#SM.loadedScene.timelines + 1] = AM.CreateTimeline(text);
            else
                -- rename existing timeline
                --PM.currentProject.scenes[index].name = text;
                SM.loadedScene.timelines[index].name = text;
            end
            AM.RefreshTimelineTabs();
        end
        self1:Hide();
        AM.addTimelineButtonTab:Show();
    end);
end

function AM.Button_EditTimeline()
    -- not sure what this will do
end

function AM.Button_DeleteTimeline()
    Editor.OpenMessageBox(SceneMachine.mainWindow:GetFrame(), "Delete Timeline", "Are you sure you wish to continue?", true, true, function() AM.DeleteTimeline(index); end, function() end);
end

function AM.CreateTimeline(timelineName)
    if (timelineName == nil) then
        timelineName = "Timeline " .. #SM.loadedScene.timelines;
    end

    return {
        name = timelineName,
        currentTime = 0,
        duration = 30000, -- 30000 miliseconds, 30 seconds
        tracks = {},
    }
end

function AM.AddTrack(object)
    if (not object) then
        return;
    end

    if (not AM.loadedTimeline) then
        return;
    end

    if (not AM.loadedTimeline.tracks) then
        AM.loadedTimeline.tracks = {};
    end

    -- check if we already have a track for this object
    --[[
    if (AM.loadedTimeline) then
		for i in pairs(AM.loadedTimeline.tracks) do
			if (AM.loadedTimeline.tracks[i].objectID == object.id) then
				AM.SelectTrack(i);
				return;
			end
		end
	end
    --]]
    -- even simpler, when adding a track the selected object would have current track selected anyway
    if (AM.selectedTrack) then
        if (AM.selectedTrack.objectID == object.id) then
            return;
        end
    end

    local track = Track:New(object);
    AM.loadedTimeline.tracks[#AM.loadedTimeline.tracks + 1] = track;

    AM.SelectTrack(#AM.loadedTimeline.tracks);
    AM.RefreshWorkspace();
end

function AM.RemoveTrack(track)
    if (not AM.loadedTimeline) then
        return;
    end
    if (AM.selectedTrack == track) then
        AM.selectedTrack = nil;
    end
    if (#AM.loadedTimeline.tracks > 0) then
        for i in pairs(AM.loadedTimeline.tracks) do
            if (AM.loadedTimeline.tracks[i] == track) then
                table.remove(AM.loadedTimeline.tracks, i);
            end
        end
    end

    --AM.SelectTrack(#AM.loadedTimeline.tracks);
    AM.RefreshWorkspace();
end

function AM.SelectTrack(index)
    if (index == -1) then
        AM.selectedTrack = nil;
        AM.SelectAnimation(-1);
        return;
    end

    if (not AM.loadedTimeline.tracks[index]) then
        return;
    end

    if (AM.loadedTimeline.tracks[index] ~= AM.selectedTrack) then
        AM.SelectKeyframe(-1);
    end

    AM.selectedTrack = AM.loadedTimeline.tracks[index];

    Editor.lastSelectedType = "track";

    -- also select object
    local obj = AM.GetObjectOfTrack(AM.selectedTrack);
    if (obj) then
        SM.selectedObject = obj;
        SH.RefreshHierarchy();
        OP.Refresh();
    end

    AM.SelectAnimation(-1);
    AM.RefreshTimebar();
    AM.RefreshWorkspace();
end

function AM.LoadTimeline(index)
    AM.loadedTimelineIndex = index;

    if (#SM.loadedScene.timelines == 0) then
        -- current project has no timelines, create a default one
        SM.loadedScene.timelines[1] = AM.CreateDefaultTimeline();
        AM.RefreshTimelineTabs();
    end

    -- unload current --
    AM.UnloadTimeline();

    -- load new --
    local timeline = SM.loadedScene.timelines[index];
    AM.loadedTimeline = timeline;

    -- refresh the ui
    AM.SetTime(0);
    AM.RefreshTimelineTabs();
    AM.RefreshTimebar();
    AM.RefreshWorkspace();

    SM.selectedObject = nil;
end

function AM.UnloadTimeline()
    SM.selectedObject = nil;
end

function AM.DeleteTimeline()
    -- switch to a different timeline because the currently loaded is being deleted
    -- load first that isn't this one
    for i in pairs(SM.loadedScene.timelines) do
        local timeline = SM.loadedScene.timelines[i];
        if (i ~= index) then
            AM.LoadTimeline(i);
            break;
        end
    end

    -- delete it
    table.remove(SM.loadedScene.timelines, index);

    -- if this was the only scene then create a new default one
    if (#SM.loadedScene.timelines == 1) then
        AM.CreateDefaultTimeline();
        AM.LoadTimeline(1);
    end

    -- refresh ui
    AM.RefreshTimelineTabs();
    AM.RefreshWorkspace();
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
    -- clear --
    for idx in pairs(tabPool) do
        tabPool[idx]:Hide();
    end

    -- add available timelines --
    local x = 0;
    if (SM.loadedScene ~= nil) then
        for i in pairs(SM.loadedScene.timelines) do
            local timeline = SM.loadedScene.timelines[i];
            if (tabPool[i] == nil) then
                tabPool[i] = AM.CreateNewTimelineTab(x, 0, 50, tabButtonHeight, AM.groupBG:GetFrame(), 10);
                tabPool[i].text:SetText(timeline.name);
                tabPool[i]:SetWidth(tabPool[i].text:GetStringWidth() + 20);
                tabPool[i]:RegisterForClicks("LeftButtonUp", "RightButtonUp");
                tabPool[i]:SetScript("OnClick", function(self, button, down)
                    if (button == "LeftButton") then
                        AM.TimelineTabButton_OnClick(i);
                    elseif (button == "RightButton") then
                        local point, relativeTo, relativePoint, xOfs, yOfs = tabPool[i]:GetPoint(1);
                        AM.TimelineTabButton_OnClick(i);
                        AM.TimelineTabButton_OnRightClick(i, xOfs, -20);
                    end
                end);
            else
                tabPool[i].text:SetText(timeline.name);
                tabPool[i]:SetWidth(tabPool[i].text:GetStringWidth() + 20);
            end

            tabPool[i]:Show();

            if (AM.loadedTimelineIndex == i) then
                tabPool[i].ntex:SetColorTexture(0.1757, 0.1757, 0.1875 ,1);
            else
                tabPool[i].ntex:SetColorTexture(0, 0, 0 ,0);
            end

            x = x + tabPool[i]:GetWidth() + 1;
        end
    end

    -- add new scene button --
    AM.addTimelineButtonTab:Show();
    AM.addTimelineEditBox:Hide();
    AM.addTimelineButtonTab:SetPoint("TOPLEFT", AM.groupBG:GetFrame(), "TOPLEFT", x, 0);
    AM.addTimelineButtonTab:SetScript("OnClick", function(self) 
        AM.Button_RenameTimeline(-1, x);
    end);
end

function AM.RefreshTimebar()
    if (not AM.loadedTimeline) then return; end

    -- Clear needles
    AM.usedNeedles = 0;
    for i = 1, #AM.needles, 1 do
        AM.needles[i]:Hide();
    end

    -- Refresh needles
    local timeBarW = AM.timebarGroup:GetWidth();
    local workAreaW = AM.workAreaViewport:GetWidth() - 8;
    local totalTimeMs = AM.loadedTimeline.duration or 0;
    
    local startTimeMs = AM.currentCrop.min * totalTimeMs;
    local startTimeS = startTimeMs / 1000;
    local endTimeMs = AM.currentCrop.max * totalTimeMs;
    local endTimeS = endTimeMs / 1000;
    local croppedTimeMs = endTimeMs - startTimeMs;
    local croppedTimeS = croppedTimeMs / 1000;

    local needlesNeededF = croppedTimeS + 1;
    local needleSpacing = workAreaW / (needlesNeededF - 1);
    
    local needleTimeSpacing = 1;    -- 1 second
    while (needlesNeededF < AM.minShownNeedles) do
        needlesNeededF = needlesNeededF * 2;
        needleTimeSpacing = needleTimeSpacing / 2;
    end
    while (needlesNeededF > AM.maxShownNeedles) do
        needlesNeededF = needlesNeededF / 2;
        needleTimeSpacing = needleTimeSpacing * 2;
    end

    local needleStartOffs = 0;
    local numberOffs = 0;
    local dif = (math.ceil(startTimeS, 1) - startTimeS);
    if (needleTimeSpacing > 1) then
        dif = (math.ceil(startTimeS, (1 / needleTimeSpacing)) - startTimeS);
    end

    if (dif ~= 0) then
        needleStartOffs = -needleSpacing * (1.0 - dif);
        numberOffs = 1;
        if (needleTimeSpacing > 1) then
            needleStartOffs = -needleSpacing * (1.0 - dif);
        end
        --print(dif)
        --print(needleStartOffs)
    end

    local needlesNeededCount = math.ceil(needlesNeededF);
    if (needleTimeSpacing < 1) then
        needlesNeededCount = needlesNeededCount - (1 / needleTimeSpacing);
    end

    if (needleStartOffs ~= 0 and needleTimeSpacing < 1) then
        needlesNeededCount = needlesNeededCount + (1 / needleTimeSpacing);
    end

    needleSpacing = needleSpacing * needleTimeSpacing * 1.003;

    if (needleTimeSpacing > 1) then
        --needleStartOffs = needleStartOffs * needleTimeSpacing;
        --startTimeS = startTimeS + 1.0
    end

    for i = 1, needlesNeededCount, 1 do
        local pos = needleStartOffs + ((i - 1) * needleSpacing) + 9.5;
        local text = math.ceil(startTimeS) + ((i - 1) * needleTimeSpacing) - numberOffs .. "s";
        local needle = AM.GetNeedle();
        needle:SetSinglePoint("BOTTOMLEFT", pos, 0);
        needle.text:SetText(text);
        needle:Show();

        -- hide last one if out of bounds
        if (pos > timeBarW) then
            needle:Hide();
        end

        -- hide first one if out of bounds
        if (i == 1) then
            if (pos < 0) then
                needle:Hide();
            end
        end
    end

    -- move ze slider
    local groupBgH = AM.timebarGroup:GetWidth() - 26;
    local timeNorm = AM.GetTimeNormalized(AM.loadedTimeline.currentTime);
    if (timeNorm < 0 or timeNorm > 1) then
        -- the slider is offscreen
        AM.TimeSlider:Hide();
    else
        AM.TimeSlider:Show();
        local pos = timeNorm * groupBgH + 10;
        AM.TimeSlider:ClearAllPoints();
        AM.TimeSlider:SetPoint("CENTER", AM.timebarGroup, "LEFT", pos, 0);
    end
end

function AM.RefreshWorkspace()
    if (not AM.workAreaCreated) then
        return;
    end

    -- reset used
    AM.usedTracks = 0;
    AM.usedAnimations = 0;
    AM.usedKeyframes = 0;
    AM.usedCurveLines = 0;

    AM.trackSelectionBox:Hide();

    if (AM.uiMode == 0) then
        -- load tracks
        local usedTracks = 0;
        local usedAnimations = 0;
        local usedKeyframes = 0;
        if (AM.loadedTimeline) then
            if (not AM.loadedTimeline.tracks) then
                AM.loadedTimeline.tracks = {};
            end

            -- tracks
            if (AM.loadedTimeline.tracks) then
                usedTracks = #AM.loadedTimeline.tracks;
                for t = 1, #AM.loadedTimeline.tracks, 1 do
                    local track = AM.loadedTimeline.tracks[t];
                    local trackElement = AM.GetAvailableTrackElement();
                    local trackElementW = trackElement:GetWidth();
                    trackElement.name:SetText(track.name);
                    trackElement:Show();

                    -- animations
                    if (track.animations) then
                        for a = 1, #track.animations, 1 do
                            local animElement = AM.GetAvailableAnimationElement();
                            usedAnimations = usedAnimations + 1;
                            local startMS = AM.currentCrop.min * AM.loadedTimeline.duration;
                            local endMS = AM.currentCrop.max * AM.loadedTimeline.duration;
                            local xMS = track.animations[a].startT;
                            local yMS = track.animations[a].endT;
                            local colorID = track.animations[a].colorId;
                
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
                                local R = AM.colors[colorID][1] / 255;
                                local G = AM.colors[colorID][2] / 255;
                                local B = AM.colors[colorID][3] / 255;
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

                    -- keyframes
                    if (track.keyframes) then
                        --print(track.name .. " " .. #track.keyframes)
                        for k = 1, #track.keyframes, 1 do
                            local keyframeElement = AM.GetAvailableKeyframeElement();
                            usedKeyframes = usedKeyframes + 1;
                            local startMS = AM.currentCrop.min * AM.loadedTimeline.duration;
                            local endMS = AM.currentCrop.max * AM.loadedTimeline.duration;
                            local xMS = track.keyframes[k].time;

                            -- check if ghost key
                            local keyAlpha = 1.0;
                            if (track ~= AM.selectedTrack) then
                                -- ghost frame (of another track)
                                keyAlpha = 0.3;
                                keyframeElement:RegisterForClicks();
                            else
                                keyframeElement:RegisterForClicks("LeftButtonUp", "LeftButtonDown");
                            end

                            -- check if on screen or cropped out
                            -- check if the point are on screen
                            if (xMS >= startMS and xMS <= endMS) then
                                local xNorm = (xMS - startMS) / (endMS - startMS);
                                xNorm = max(0, xNorm);
                                xNorm = min(1, xNorm);
                
                                local startP = math.floor(trackElementW * xNorm + 10);

                                keyframeElement:ClearAllPoints();
                                keyframeElement:SetPoint("CENTER", AM.KeyframeBar:GetFrame(), "LEFT", startP, 0);
                                keyframeElement.ntex:SetVertexColor(0.5, 0.5, 0.5, keyAlpha);
                                -- use alpha to desaturate the animation bars
                                -- so that they don't draw more attention than the scene
                                -- calculate an alpha value based on percieved R,G,B
                            
                                keyframeElement:Show();
                
                                -- store some information for lookup
                                keyframeElement.trackIdx = t;
                                keyframeElement.keyIdx = k;

                                if (track.keyframes[k] == AM.selectedKey and track == AM.selectedTrack) then
                                    keyframeElement.ntex:SetVertexColor(1, 1, 1, keyAlpha);
                                end
                            else
                                keyframeElement:Hide();
                            end
                        end
                    end

                    -- keyframes: hide unused
                    for i = usedKeyframes + 1, #AM.KeyframePool, 1 do
                        if (AM.KeyframePool[i]) then
                            AM.KeyframePool[i]:Hide();
                        end
                    end

                    if (track == AM.selectedTrack) then
                        AM.trackSelectionBox:Show();
                        AM.trackSelectionBox:SetSinglePoint("TOPLEFT", 0, (t - 1) * -(AM.trackElementH + Editor.pmult));
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
            end
        end
        
        -- make list fit elements
        local workAreaListHeight = usedTracks * (AM.trackElementH + Editor.pmult);
        AM.workAreaList:SetHeight(workAreaListHeight);
        
        -- resize scrollbar
        AM.workAreaScrollbar:Resize(AM.groupBG:GetHeight() - 106, workAreaListHeight);

    elseif (AM.uiMode == 1) then
        local usedLines = 0;
        local viewScale = 20;
        if (AM.loadedTimeline and AM.selectedTrack) then
            local track = AM.selectedTrack;
            --local trackElement = AM.GetAvailableTrackElement();
            --local trackElementW = trackElement:GetWidth() - 6;
            local trackElementW = AM.workAreaList:GetWidth() - 6;
            if (track.keyframes) then
                local linePreviousX = nil;
                local linePreviousY = nil;
                local linePreviousZ = nil;
                for k = 1, #track.keyframes - 1, 1 do
                    local startMS = AM.currentCrop.min * AM.loadedTimeline.duration;
                    local endMS = AM.currentCrop.max * AM.loadedTimeline.duration;

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
        end
    end

    -- update timer
    if (AM.loadedTimeline) then
        local totalTime = AM.TimeValueToString(AM.loadedTimeline.duration);
        local currentTime = AM.TimeValueToString(AM.loadedTimeline.currentTime or 0);
        AM.timerTextBox:SetText(currentTime .. "-" .. totalTime);
    end
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

    animVariant = animVariant or 0;

    -- place after last in time
    local colorId = math.random(1, #AM.colors);

    -- get length
    local obj = AM.GetObjectOfTrack(track);
    if (obj.fileID == nil or obj.fileID <= 0) then
        local ignore, ignore2, idString = strsplit(" ", obj.actor:GetModelPath());
        obj.fileID = tonumber(idString);
    end
    
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

    local startT = 0;
    local endT = startT + animLength;
    if (#track.animations > 0) then
        startT = track.animations[#track.animations].endT;
        endT = startT + animLength;
    end

    local name = SceneMachine.animationNames[animID];
    name = name or ("Anim_" .. animID);
    if (animVariant ~= 0) then
        name = name .. " " .. animVariant;
    end

    track.animations[#track.animations + 1] = {
        id = animID,
        variation = animVariant,
        animLength = animLength,
        startT = startT,
        endT = endT,
        colorId = colorId,
        name = name,
    };

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

    for i in pairs(track.animations) do
        if (track.animations[i] == anim) then
            table.remove(track.animations, i);
        end
    end

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
    local track = AM.loadedTimeline.tracks[animElement.trackIdx];
    local anim = track.animations[animElement.animIdx];
    
    AM.SelectTrack(animElement.trackIdx);
    AM.selectedAnim = anim;

    Editor.lastSelectedType = "anim";

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

function AM.SetTime(timeMS)

    -- force time selection to 30 fps ticks
    --timeMS = floor(floor(timeMS / 33.3333) * 33.3333);

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
        AM.loadedTimeline.currentTime = timeMS;

        local totalTime = AM.TimeValueToString(AM.loadedTimeline.duration);
        local currentTime = AM.TimeValueToString(AM.loadedTimeline.currentTime or 0);
        AM.timerTextBox:SetText(currentTime .. "-" .. totalTime);
    end

    if (not SM.loadedScene) then
        return;
    end

    -- go through the timeline tracks
    local timeline = AM.loadedTimeline;
    if (timeline and timeline.tracks) then
        for t in pairs(timeline.tracks) do
            local track = timeline.tracks[t];
            -- also get object
            local obj = AM.GetObjectOfTrack(track);
            if (obj) then
                -- animate object
                local animID, variationID, animMS = track:SampleAnimation(timeMS);
                local animSpeed = 0;
                if (animID ~= -1) then
                    obj.actor:SetAnimation(animID, variationID, animSpeed, animMS / 1000);
                else
                    -- stop playback
                end

                -- animate keyframes
                if (track.keyframes and #track.keyframes > 0) then
                    local pos, rot, scale = track:SampleKeyframes(timeMS);
                    if (pos) then
                        obj:SetPositionVector3(pos);
                    end
                    if (rot) then
                        obj:SetRotationQuaternion(rot);
                    end
                    if (scale) then
                        obj:SetScale(scale);
                    end
                else
                    -- no keyframes, don't animate
                end
            end
        end
    end
end

function AM.GetObjectOfTrack(track)
    if (track.objectID) then
        if (not SM.loadedScene.objects) then
            return nil;
        end
    
        for i in pairs(SM.loadedScene.objects) do
            if (SM.loadedScene.objects[i].id == track.objectID) then
                return SM.loadedScene.objects[i];
            end
        end
    end

    return nil;
end

function AM.GetTimeNormalized(timeMS)
    if (not AM.loadedTimeline) then
        return 0;
    end
    local totalTimeMS = AM.loadedTimeline.duration;
    local startMS = AM.currentCrop.min * totalTimeMS;
    local endMS = AM.currentCrop.max * totalTimeMS;
    local timeNorm = (timeMS - startMS) / (endMS - startMS);
    return timeNorm;
end

function AM.OpenAddAnimationWindow(track)

    if (not track) then
        return;
    end

    -- find available animations
    local obj = AM.GetObjectOfTrack(track);
    if (not obj) then
        return;
    end

    if (obj.fileID == nil or obj.fileID <= 0) then
        local _, _, idString = strsplit(" ", obj.actor:GetModelPath());
        obj.fileID = tonumber(idString);
    end

    local animData = SceneMachine.animationData[obj.fileID];
    AM.animScrollList:SetData(animData);
    AM.animSelectWindow.filterBox:SetText("");
    AM.animSelectWindow:Show();
end

function AM.AddKey(track)
    if (not track) then
        return;
    end

    if (not track.keyframes) then
        track.keyframes = {};
    end

    local timeMS = AM.loadedTimeline.currentTime;
    local obj = AM.GetObjectOfTrack(track);
    if (obj) then
        track:AddKeyframe(timeMS, obj:GetPosition(), obj:GetRotation(), obj:GetScale());
    end

    AM.RefreshWorkspace();
end

function AM.RemoveKey(track, key)
    if (not track) then
        return;
    end

    if (not key) then
        return;
    end

    if (not track.keyframes) then
        track.keyframes = {};
        return;
    end

    for i in pairs(track.keyframes) do
        if (track.keyframes[i] == key) then
            table.remove(track.keyframes, i);
        end
    end

    AM.RefreshWorkspace();
end

function AM.SelectKeyframe(index)
    if (index < 0) then
        AM.selectedKey = nil;
        AM.RefreshWorkspace();
        return;
    end

    -- find which track and elements were just selected
    local keyframeElement = AM.KeyframePool[index];
    local track = AM.loadedTimeline.tracks[keyframeElement.trackIdx];
    local keyIndex = keyframeElement.keyIdx;

    Editor.lastSelectedType = "key";
    AM.selectedKey = track.keyframes[keyIndex];
    AM.selectedTrack = track;
    AM.RefreshWorkspace();
end

function AM.SelectTrackOfObject(obj)
	if (AM.loadedTimeline) then
		for i in pairs(AM.loadedTimeline.tracks) do
			if (AM.loadedTimeline.tracks[i].objectID == obj.id) then
				AM.SelectTrack(i);
				return;
			end
		end
	end

    AM.SelectTrack(-1);
    AM.RefreshWorkspace();
end

function AM.TrackHasAnims(track)
    if (track.animations and #track.animations > 0) then
        return true;
    end

    return false;
end

function AM.TrackHasKeyframes(track)
    if (track.keyframes and #track.keyframes > 0) then
        return true;
    end

    return false;
end

function AM.Play()
    AM.playing = true;

    if (AM.loopPlay) then
        -- find last keyed time
        AM.lastKeyedTime = 0;
        for t = 1, #AM.loadedTimeline.tracks, 1 do
            local track = AM.loadedTimeline.tracks[t];
            if (track.animations and #track.animations > 0) then
                local animEnd = track.animations[#track.animations].endT;
                if (animEnd > AM.lastKeyedTime) then
                    AM.lastKeyedTime = animEnd;
                end
            end
            if (track.keyframes and #track.keyframes > 0) then
                local keyEnd = track.keyframes[#track.keyframes].time;
                if (keyEnd > AM.lastKeyedTime) then
                    AM.lastKeyedTime = keyEnd;
                end
            end
        end

        if (AM.lastKeyedTime == 0) then
            AM.lastKeyedTime = AM.loadedTimeline.duration;
        end
    end
end

function AM.Pause()
    AM.playing = false;
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
        AM.SetTime(AM.loadedTimeline.duration);
    end
end

function AM.SkipFrameForwardButton_OnClick()
    if (AM.loadedTimeline) then
        local nextTime = AM.loadedTimeline.currentTime + 33.3333;
        if (nextTime > AM.loadedTimeline.duration) then
            nextTime = AM.loadedTimeline.duration;
        end
        AM.SetTime(nextTime);
    end
end

function AM.SkipFrameBackwardButton_OnClick()
    if (AM.loadedTimeline) then
        local nextTime = AM.loadedTimeline.currentTime - 33.3333;
        if (nextTime < 0) then
            nextTime = 0;
        end
        AM.SetTime(nextTime);
    end
end

function AM.LoopToggle_OnClick(on)
    AM.loopPlay = on;
end

function AM.ChangeUIMode(mode)
    if (mode == 0) then
        -- switch to key view
        AM.uiMode = 0;
        AM.KeyframeBar:Show();
        AM.workAreaBG:Show();
        AM.curveViewBG:Hide();
    elseif (mode == 1) then
        -- switch to curve view
        AM.uiMode = 1;
        AM.KeyframeBar:Hide();
        AM.workAreaBG:Hide();
        AM.curveViewBG:Show();
    end

    AM.RefreshWorkspace();
end

function AM.ToggleUIMode()
    if (AM.uiMode == 0) then
        AM.uiMode = 1;
    elseif (AM.uiMode == 1) then
        AM.uiMode = 0;
    end
    AM.ChangeUIMode(AM.uiMode)
end