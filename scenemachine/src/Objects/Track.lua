SceneMachine.Track = {}

--- @class Track
local Track = SceneMachine.Track;

local Keyframe = SceneMachine.Keyframe;
local AnimationClip = SceneMachine.AnimationClip;

setmetatable(Track, Track)

local fields = {}

-- Creates a new Track object.
--- @param object? Object The object to associate with the track.
--- @return Track v The newly created Track object.
function Track:New(object, timeline)
    --- @class Track
    local v = 
    {
        --- @type AnimationClip[]?
        animations = {};
        --- @type Keyframe[]?
        keysPx = {};
        --- @type Keyframe[]?
        keysPy = {};
        --- @type Keyframe[]?
        keysPz = {};
        --- @type Keyframe[]?
        keysRx = {};
        --- @type Keyframe[]?
        keysRy = {};
        --- @type Keyframe[]?
        keysRz = {};
        --- @type Keyframe[]?
        keysS = {};
        --- @type Keyframe[]?
        keysA = {};
        --- @type Timeline
        timeline = timeline;
    };

    setmetatable(v, Track)

    if (object) then
        v.objectID = object.id;
        v.name = object.name;
    end

    return v
end

--- Sets the timeline for the track.
--- @param timeline Timeline The timeline to associate with the track.
function Track:SetTimeline(timeline)
    self.timeline = timeline;
end

--- Export the track data
--- @return table data The exported track data
function Track:Export()
    local data = {
        name = self.name;
        objectID = self.objectID;
        animations = self.animations;
        keysPx = self.keysPx;
        keysPy = self.keysPy;
        keysPz = self.keysPz;
        keysRx = self.keysRx;
        keysRy = self.keysRy;
        keysRz = self.keysRz;
        keysS = self.keysS;
        keysA = self.keysA;
    };

    return data;
end

function Track:ExportPacked()
    local packed = {
        self.name,
        self.objectID,
    }

    local packedAnimations = {};
    for i = 1, #self.animations, 1 do
        table.insert(packedAnimations, self.animations[i]:ExportPacked());
    end
    packed[3] = packedAnimations;

    local packedKeysPx = {};
    for i = 1, #self.keysPx, 1 do
        table.insert(packedKeysPx, self.keysPx[i]:ExportPacked());
    end
    packed[4] = packedKeysPx;

    local packedKeysPy = {};
    for i = 1, #self.keysPy, 1 do
        table.insert(packedKeysPy, self.keysPy[i]:ExportPacked());
    end
    packed[5] = packedKeysPy;

    local packedKeysPz = {};
    for i = 1, #self.keysPz, 1 do
        table.insert(packedKeysPz, self.keysPz[i]:ExportPacked());
    end
    packed[6] = packedKeysPz;

    local packedKeysRx = {};
    for i = 1, #self.keysRx, 1 do
        table.insert(packedKeysRx, self.keysRx[i]:ExportPacked());
    end
    packed[7] = packedKeysRx;

    local packedKeysRy = {};
    for i = 1, #self.keysRy, 1 do
        table.insert(packedKeysRy, self.keysRy[i]:ExportPacked());
    end
    packed[8] = packedKeysRy;

    local packedKeysRz = {};
    for i = 1, #self.keysRz, 1 do
        table.insert(packedKeysRz, self.keysRz[i]:ExportPacked());
    end
    packed[9] = packedKeysRz;

    local packedKeysS = {};
    for i = 1, #self.keysS, 1 do
        table.insert(packedKeysS, self.keysS[i]:ExportPacked());
    end
    packed[10] = packedKeysS;

    local packedKeysA = {};
    for i = 1, #self.keysA, 1 do
        table.insert(packedKeysA, self.keysA[i]:ExportPacked());
    end
    packed[11] = packedKeysA;

    return packed;
end

--- Imports data into the Track object.
--- @param data table The data to be imported.
function Track:ImportData(data)
    if (data == nil) then
        print("Track:ImportData() data was nil.");
        return;
    end

    -- verifying all elements upon import because sometimes the saved variables get corrupted --
    self.objectID = data.objectID or nil;
    self.name = data.name or nil;
   

    self:ImportAnimationData(data);

    self:ImportKeyframeArray("keysPx", data.keysPx);
    self:ImportKeyframeArray("keysPy", data.keysPy);
    self:ImportKeyframeArray("keysPz", data.keysPz);
    self:ImportKeyframeArray("keysRx", data.keysRx);
    self:ImportKeyframeArray("keysRy", data.keysRy);
    self:ImportKeyframeArray("keysRz", data.keysRz);
    self:ImportKeyframeArray("keysS", data.keysS);
    self:ImportKeyframeArray("keysA", data.keysA);
end

function Track:ImportPacked(data)
    self.name = data[1];
    self.objectID = data[2];
    self.animations = {};
    if (data[3]) then
        if (#data[3] > 0) then
            for j = 1, #data[3], 1 do
                local anim = AnimationClip:New();
                anim:ImportPacked(data[3][j]);
                anim:SetTrack(self);
                self.animations[j] = anim;
            end
        end
    end

    self:ImportPackedKeyframeArray("keysPx", data[4]);
    self:ImportPackedKeyframeArray("keysPy", data[5]);
    self:ImportPackedKeyframeArray("keysPz", data[6]);
    self:ImportPackedKeyframeArray("keysRx", data[7]);
    self:ImportPackedKeyframeArray("keysRy", data[8]);
    self:ImportPackedKeyframeArray("keysRz", data[9]);
    self:ImportPackedKeyframeArray("keysS", data[10]);
    self:ImportPackedKeyframeArray("keysA", data[11]);
end

function Track:ImportAnimationData(data)
    if (data and data.animations) then
        --- @type AnimationClip[]
        self.animations = {};
        for k in pairs(data.animations) do
            self.animations[k] = AnimationClip:New();
            self.animations[k]:ImportData(data.animations[k]);
            self.animations[k]:SetTrack(self);
        end
    end
end

--- Imports an array of keyframes for a given type.
--- @param typeName string The type name of the keyframe array, eg. "keysPx".
--- @param data table The data containing the keyframes to import.
function Track:ImportKeyframeArray(typeName, data)
    if (data) then
        self[typeName] = {};
        for k in pairs(data) do
            self[typeName][k] = Keyframe:New();
            self[typeName][k]:ImportData(data[k]);
        end
    end
end

function Track:ImportPackedKeyframeArray(typeName, data)
    if (data) then
        self[typeName] = {};
        for k in pairs(data) do
            self[typeName][k] = Keyframe:New();
            self[typeName][k]:ImportPacked(data[k]);
        end
    end
end

--- Samples the animation at the given time.
--- @param timeMS number The time in milliseconds.
--- @return number animID, number variationID, number animMS, number animSpeed The animation ID, variation ID, animation time, and animation speed.
function Track:SampleAnimation(timeMS)
    -- find anim in range
    if (self.animations) then
        for a in pairs(self.animations) do
            local animation = self.animations[a];
            ----{ id, variation, animLength, startT, endT, colorId, name }
            if (animation:TimeIsInRange(timeMS)) then
                ---- anim is in range
                return animation:Sample(timeMS);
            end
        end
    end

    return -1, -1, 1, 1;
end

--- Adds a keyframe to the track.
--- @param time number The time of the keyframe.
--- @param value number The value of the keyframe.
--- @param keyframes? Keyframe[] (optional) The array of existing keyframes. If not provided, a new array will be created.
--- @param interpolationIn? Keyframe.Interpolation (optional) The interpolation type for the incoming tangent of the keyframe. Defaults to Keyframe.Interpolation.Bezier.
--- @param interpolationOut? Keyframe.Interpolation (optional) The interpolation type for the outgoing tangent of the keyframe. Defaults to Keyframe.Interpolation.Bezier.
function Track:AddKeyframe(time, value, keyframes, interpolationIn, interpolationOut)
    if (not keyframes) then keyframes = {}; end

    for i = 1, #keyframes, 1 do
        if (keyframes[i]:CompareTime(time)) then
            keyframes[i]:SetValue(value);
            return;
        end
    end

    keyframes[#keyframes + 1] = Keyframe:New(time, value, interpolationIn, interpolationOut);
end

--- Adds a full keyframe to the track.
--- @param time number The time of the keyframe.
--- @param position Vector3 The position of the keyframe.
--- @param rotation Vector3 The rotation of the keyframe.
--- @param scale number The scale of the keyframe.
--- @param alpha number The alpha value of the keyframe.
--- @param interpolationIn? Keyframe.Interpolation (optional) The interpolation type for the keyframe's incoming tangent.
--- @param interpolationOut? Keyframe.Interpolation (optional) The interpolation type for the keyframe's outgoing tangent.
function Track:AddFullKeyframe(time, position, rotation, scale, alpha, interpolationIn, interpolationOut)
    self:AddPositionKeyframe(time, position, interpolationIn, interpolationOut);
    self:AddRotationKeyframe(time, rotation, interpolationIn, interpolationOut);
    self:AddScaleKeyframe(time, scale, interpolationIn, interpolationOut);
    self:AddAlphaKeyframe(time, alpha, interpolationIn, interpolationOut);
end

--- Adds a position keyframe to the track.
--- @param time number The time at which the keyframe occurs.
--- @param position Vector3 The position value of the keyframe.
--- @param interpolationIn? Keyframe.Interpolation (optional) The interpolation type for the keyframe's incoming tangent.
--- @param interpolationOut? Keyframe.Interpolation (optional) The interpolation type for the keyframe's tangent.
function Track:AddPositionKeyframe(time, position, interpolationIn, interpolationOut)
    self:AddKeyframe(time, position.x, self.keysPx, interpolationIn, interpolationOut);
    self:AddKeyframe(time, position.y, self.keysPy, interpolationIn, interpolationOut);
    self:AddKeyframe(time, position.z, self.keysPz, interpolationIn, interpolationOut);
    self:SortPositionKeyframes();
end

--- Adds a rotation keyframe to the track.
--- @param time number The time at which the keyframe occurs.
--- @param rotation Vector3 The rotation values for the keyframe.
--- @param interpolationIn? Keyframe.Interpolation (optional) The interpolation type for the keyframe's incoming tangent.
--- @param interpolationOut? Keyframe.Interpolation (optional) The interpolation type for the keyframe's outgoing tangent.
function Track:AddRotationKeyframe(time, rotation, interpolationIn, interpolationOut)
    self:AddKeyframe(time, rotation.x, self.keysRx, interpolationIn, interpolationOut);
    self:AddKeyframe(time, rotation.y, self.keysRy, interpolationIn, interpolationOut);
    self:AddKeyframe(time, rotation.z, self.keysRz, interpolationIn, interpolationOut);
    self:SortRotationKeyframes();
end

--- Adds a scale keyframe to the track.
--- @param time number The time of the keyframe.
--- @param scale number The scale value of the keyframe.
--- @param interpolationIn? Keyframe.Interpolation (optional) The interpolation type for the keyframe's incoming tangent.
--- @param interpolationOut? Keyframe.Interpolation (optional) The interpolation type for the keyframe's outgoing tangent.
function Track:AddScaleKeyframe(time, scale, interpolationIn, interpolationOut)
    self:AddKeyframe(time, scale, self.keysS, interpolationIn, interpolationOut);
    self:SortScaleKeyframes();
end

--- Adds an alpha keyframe to the track.
--- @param time number The time of the keyframe.
--- @param alpha number The alpha value of the keyframe.
--- @param interpolationIn? Keyframe.Interpolation (optional) The interpolation type for the keyframe's incoming tangent.
--- @param interpolationOut? Keyframe.Interpolation (optional) The interpolation type for the keyframe's outgoing tangent.
function Track:AddAlphaKeyframe(time, alpha, interpolationIn, interpolationOut)
    self:AddKeyframe(time, alpha, self.keysA, interpolationIn, interpolationOut);
    self:SortAlphaKeyframes();
end

--- Sorts the keyframes of a specific type in the track.
--- @param typeName string The type of keyframes to sort.
function Track:SortKeyframes(typeName)
    if (self[typeName]) then
        table.sort(self[typeName], function(a,b) return a.time < b.time end)
    end
end

--- Sorts the position keyframes of the track based on their time.
function Track:SortPositionKeyframes()
    self:SortKeyframes("keysPx");
    self:SortKeyframes("keysPy");
    self:SortKeyframes("keysPz");
end

-- Sorts the rotation keyframes of the track.
function Track:SortRotationKeyframes()
    self:SortKeyframes("keysRx");
    self:SortKeyframes("keysRy");
    self:SortKeyframes("keysRz");
end

--- Sorts the scale keyframes of the track based on their time.
function Track:SortScaleKeyframes()
    self:SortKeyframes("keysS");
end

--- Sorts the alpha keyframes of the track based on their time.
function Track:SortAlphaKeyframes()
    self:SortKeyframes("keysA");
end

--- Sorts all the keyframes of the track.
function Track:SortAllKeyframes()
    self:SortPositionKeyframes();
    self:SortRotationKeyframes();
    self:SortScaleKeyframes();
    self:SortAlphaKeyframes();
end

--- SampleKey function is used to sample a value from a set of keys based on a given time.
--- This function assumes that the keys are sorted in ascending order based on time.
--- @param timeMS number The time in milliseconds at which to sample the value.
--- @param keys Keyframe[] The array of keys containing time, value, and interpolation information.
--- @return number? The sampled value at the given time, or nil if no value is found.:
function Track:SampleKey(timeMS, keys)
    if (not keys) then return nil; end
    if (#keys == 0) then return nil; end

    if (#keys == 1) then
        if (keys[1]:CompareTime(timeMS)) then
            return keys[1].value;
        else
            return nil;
        end
    end

    local idx = 1;
    local numTimes = #keys;

    for i = 1, numTimes, 1 do
        if (i + 1 <= numTimes) then
            if (timeMS >= keys[i]:GetTime() and timeMS < keys[i + 1]:GetTime()) then
                idx = i;
                break;
            end
        end
        if (i == numTimes) then
            return keys[#keys].value;
        end
        if (i == 1 and timeMS < keys[1]:GetTime()) then
            return keys[1].value;
        end
    end

    local t1 = keys[idx].time;
    local t2 = keys[idx + 1].time;

    local i1 = keys[idx].interpolationOut;
    local i2 = keys[idx + 1].interpolationIn;

    local r = 0;
    if (i1 == i2) then
        if (i1 == Keyframe.Interpolation.Bezier) then
            r = Track:InterpolateBezierAuto(t1, t2, timeMS);
        elseif (i1 == Keyframe.Interpolation.Linear) then
            r = Track:InterpolateLinear(t1, t2, timeMS);
        elseif (i1 == Keyframe.Interpolation.Step) then
            r = Track:InterpolateStep(t1, t2, timeMS);
        elseif (i1 == Keyframe.Interpolation.Slow) then
            r = Track:InterpolateBezierSlow(t1, t2, timeMS);
        elseif (i1 == Keyframe.Interpolation.Fast) then
            r = Track:InterpolateBezierFast(t1, t2, timeMS);
        end
    else
        if (i1 == Keyframe.Interpolation.Step or i2 == Keyframe.Interpolation.Step) then
            r = Track:InterpolateStep(t1, t2, timeMS);
        else
            local alpha = Track:InterpolateLinear(t1, t2, timeMS);
            local A = 0;
            local B = 0;
            if (i1 == Keyframe.Interpolation.Bezier) then
                A = Track:InterpolateBezierAuto(t1, t2, timeMS);
            elseif (i1 == Keyframe.Interpolation.Linear) then
                A = Track:InterpolateLinear(t1, t2, timeMS);
            elseif (i1 == Keyframe.Interpolation.Slow) then
                A = Track:InterpolateBezier(t1, t2, timeMS, 0, 1, 0, 2);
            elseif (i1 == Keyframe.Interpolation.Fast) then
                A = Track:InterpolateBezier(t1, t2, timeMS, 0, 1, 2, 0);
            end

            if (i2 == Keyframe.Interpolation.Bezier) then
                B = Track:InterpolateBezierAuto(t1, t2, timeMS);
            elseif (i2 == Keyframe.Interpolation.Linear) then
                B = Track:InterpolateLinear(t1, t2, timeMS);
            elseif (i2 == Keyframe.Interpolation.Slow) then
                B = Track:InterpolateBezier(t1, t2, timeMS, 0, 1, 2, 0);
            elseif (i2 == Keyframe.Interpolation.Fast) then
                B = Track:InterpolateBezier(t1, t2, timeMS, 0, 1, 0, 2);
            end

            r = (A + (B - A) * alpha);
        end
    end

    local v1 = keys[idx].value;
    local v2 = keys[idx + 1].value;
    local result = (v1 + (v2 - v1) * r);
    return result;
end

--- Samples the X position key at the given time in milliseconds.
--- @param timeMS number The time in milliseconds.
--- @return number? value The sampled X position key.
function Track:SamplePositionXKey(timeMS)
    return Track:SampleKey(timeMS, self.keysPx);
end

--- Samples the Y position key at the given time in milliseconds.
--- @param timeMS number The time in milliseconds.
--- @return number? value The sampled Y position key.
function Track:SamplePositionYKey(timeMS)
    return Track:SampleKey(timeMS, self.keysPy);
end

--- Samples the Z position key at the given time in milliseconds.
--- @param timeMS number The time in milliseconds.
--- @return number? value The sampled Z position key.
function Track:SamplePositionZKey(timeMS)
    return Track:SampleKey(timeMS, self.keysPz);
end

--- Samples the rotation X key at the specified time.
--- @param timeMS number The time in milliseconds.
--- @return number? value The sampled X rotation key.
function Track:SampleRotationXKey(timeMS)
    return Track:SampleKey(timeMS, self.keysRx);
end

--- Samples the rotation Y key at the specified time.
--- @param timeMS number The time in milliseconds.
--- @return number? value The sampled Y rotation key.
function Track:SampleRotationYKey(timeMS)
    return Track:SampleKey(timeMS, self.keysRy);
end

--- Samples the rotation Z key at the specified time.
--- @param timeMS number The time in milliseconds.
--- @return number? value The sampled Z rotation key.
function Track:SampleRotationZKey(timeMS)
    return Track:SampleKey(timeMS, self.keysRz);
end

--- Samples the scale key at the specified time.
--- @param timeMS number The time in milliseconds.
--- @return number? value The sampled scale key.
function Track:SampleScaleKey(timeMS)
    return Track:SampleKey(timeMS, self.keysS);
end

--- Samples the alpha key at the specified time.
--- @param timeMS number The time in milliseconds.
--- @return number? value The sampled alpha key.
function Track:SampleAlphaKey(timeMS)
    return Track:SampleKey(timeMS, self.keysA);
end

--- Interpolates linearly between two values based on a given time.
--- @param t1 number The starting time.
--- @param t2 number The ending time.
--- @param timeMS number The current time in milliseconds.
--- @return number interpolatedTime The interpolated value between 0 and 1.
function Track:InterpolateLinear(t1, t2, timeMS)
    return (timeMS - t1) / (t2 - t1);
end

--- Interpolates between two points using a Bezier curve.
--- @param tA number The starting point.
--- @param tB number The ending point.
--- @param timeMS number The time in milliseconds.
--- @return number interpolatedValue The interpolated value.
function Track:InterpolateBezierAuto(tA, tB, timeMS)
    
    local previousPoint = 0;
    local nextPoint = 1;
    local previousTangent = 0;
    local nextTangent = 0;
    
    return Track:InterpolateBezier(tA, tB, timeMS, previousPoint, nextPoint, previousTangent, nextTangent);
end

--- Interpolates a value along a Bezier curve using a Slow curve.
--- @param tA number The starting value of the curve.
--- @param tB number The ending value of the curve.
--- @param timeMS number The time in milliseconds.
--- @return number interpolatedValue The interpolated value.
function Track:InterpolateBezierSlow(tA, tB, timeMS)
    local previousPoint = 0;
    local nextPoint = 1;
    local previousTangent = 0;
    local nextTangent = 2;
    
    return Track:InterpolateBezier(tA, tB, timeMS, previousPoint, nextPoint, previousTangent, nextTangent);
end

--- Interpolates a value along a Bezier curve using a Fast curve.
--- @param tA number The starting value of the curve.
--- @param tB number The ending value of the curve.
--- @param timeMS number The time in milliseconds.
--- @return number interpolatedValue The interpolated value.
function Track:InterpolateBezierFast(tA, tB, timeMS)
    local previousPoint = 0;
    local nextPoint = 1;
    local previousTangent = 2;
    local nextTangent = 0;
    
    return Track:InterpolateBezier(tA, tB, timeMS, previousPoint, nextPoint, previousTangent, nextTangent);
end

--- Interpolates a point on a Bezier curve between two given points.
--- @param tA number The starting time value.
--- @param tB number The ending time value.
--- @param timeMS number The current time value.
--- @param previousPoint number The point at tA.
--- @param nextPoint number The point at tB.
--- @param previousTangent number The tangent at tA.
--- @param nextTangent number The tangent at tB.
--- @return number interpolatedValue The interpolated point on the Bezier curve.
function Track:InterpolateBezier(tA, tB, timeMS, previousPoint, nextPoint, previousTangent, nextTangent)
    local t = (timeMS - tA) / (tB - tA)
    local t2 = t * t
    local t3 = t2 * t
    local p = (2 * t3 - 3 * t2 + 1) * previousPoint +
           (t3 - 2 * t2 + t) * previousTangent +
           (-2 * t3 + 3 * t2) * nextPoint +
           (t3 - t2) * nextTangent;

    return p;
end

--- Interpolates the step between two time values.
--- @param t1 number The first time value.
--- @param t2 number The second time value.
--- @param timeMS number The current time in milliseconds.
--- @return number interpolatedValue The interpolation step between t1 and t2.
function Track:InterpolateStep(t1, t2, timeMS)
    if (timeMS == t2) then
        return 1;
    end

    return 0;
end

function Track:AddAnimation(animID, variant)
    if (not self.animations) then
        self.animations = {};
    end

    variant = variant or 0;

    -- get length
    local obj = self.timeline.scene:GetObjectByID(self.objectID);
    if (not obj) then
        return;
    end
    if (obj.fileID == nil or obj.fileID <= 0) then
        local _, _, idString = strsplit(" ", obj.actor:GetModelPath());
        local fileID = tonumber(idString);
        if (fileID) then
            obj.fileID = fileID;
        end
    end
    
    local anim = AnimationClip:New(animID, variant, self);

    local animData = SceneMachine.animationData[obj.fileID];
    local animLength = 3000;
    if (animData) then
        for i in pairs(animData) do
            local entry = animData[i];
            if (entry[1] == animID and entry[2] == variant) then
                animLength = entry[3];
            end
        end
    end

    anim:SetLength(animLength);

    local startT = 0;
    local endT = startT + animLength;
    if (#self.animations > 0) then
        startT = self.animations[#self.animations]:GetEndTime();
        endT = startT + animLength;
    end

    anim:SetStartTime(startT);
    anim:SetEndTime(endT);

    local name = SceneMachine.animationNames[animID];
    name = name or ("Anim_" .. animID);
    if (variant ~= 0) then
        name = name .. " " .. variant;
    end

    anim:SetName(name);
    anim:SetSpeed(1);

    table.insert(self.animations, anim);
end

function Track:RemoveAnimation(anim)
    for i in pairs(self.animations) do
        if (self.animations[i] == anim) then
            table.remove(self.animations, i);
        end
    end
end

function Track:ReplaceAnimation(currentAnim, newID, newVariant)
    -- get name
    local name = SceneMachine.animationNames[newID];
    name = name or ("Anim_" .. newID);
    if (newVariant ~= 0) then
        name = name .. " " .. newVariant;
    end

    -- get length
    local obj = self.timeline.scene:GetObjectByID(self.objectID);
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
end

function Track:SetCurrentlyPlayingAnim(animID, variant)
    self.currentAnimID = animID;
    self.currentAnimVariationID = variant;
end

function Track:SetTime(timeMS, playback)
    -- also get object
    local obj = self.timeline.scene:GetObjectByID(self.objectID);

    if (not obj) then
        return;
    end

    -- animate object
    if (obj:HasActor()) then
        local animID, variationID, animMS, animSpeed = self:SampleAnimation(timeMS);

        if (playback) then
            -- Sample playback
            if (self.currentAnimID ~= animID or self.currentAnimVariationID ~= variationID) then
                -- Animation switch
                if (animID ~= -1) then
                    --obj.actor:SetAnimationBlendOperation(1);  -- 0: don't blend, 1: blend
                    obj.actor:SetAnimation(animID, variationID, animSpeed, animMS / 1000);
                end
                self:SetCurrentlyPlayingAnim(animID, variationID);
            end
        else
            -- Sample single key
            animSpeed = 0;
            self:SetCurrentlyPlayingAnim(nil, nil);
            if (animID ~= -1) then
                obj.actor:SetAnimation(animID, variationID, animSpeed, animMS / 1000);
            else
                -- stop playback
            end
        end
    end
    
    -- animate keyframes
    local currentPos = obj:GetPosition();
    local posX = self:SamplePositionXKey(timeMS) or currentPos.x;
    local posY = self:SamplePositionYKey(timeMS) or currentPos.y;
    local posZ = self:SamplePositionZKey(timeMS) or currentPos.z;
    obj:SetPosition(posX, posY, posZ);

    local currentRot = obj:GetRotation();
    local rotX = self:SampleRotationXKey(timeMS) or currentRot.x;
    local rotY = self:SampleRotationYKey(timeMS) or currentRot.y;
    local rotZ = self:SampleRotationZKey(timeMS) or currentRot.z;
    obj:SetRotation(rotX, rotY, rotZ);

    local currentScale = obj:GetScale();
    local scale = self:SampleScaleKey(timeMS) or currentScale;
    obj:SetScale(scale);

    if (obj:IsVisible()) then
        if (obj:HasActor()) then
            local currentAlpha = obj:GetAlpha();
            local alpha = self:SampleAlphaKey(timeMS) or currentAlpha;
            obj:SetAlpha(alpha);
        end
    end
end

function Track:GetLastKeyedTime()
    local lastKeyedTime = 0;

    if (self.animations and #self.animations > 0) then
        local animEnd = self.animations[#self.animations]:GetEndTime();
        if (animEnd > lastKeyedTime) then
            lastKeyedTime = animEnd;
        end
    end

    lastKeyedTime = self:GetEndKeyTime(self.keysPx, lastKeyedTime);
    lastKeyedTime = self:GetEndKeyTime(self.keysPy, lastKeyedTime);
    lastKeyedTime = self:GetEndKeyTime(self.keysPz, lastKeyedTime);

    lastKeyedTime = self:GetEndKeyTime(self.keysRx, lastKeyedTime);
    lastKeyedTime = self:GetEndKeyTime(self.keysRy, lastKeyedTime);
    lastKeyedTime = self:GetEndKeyTime(self.keysRz, lastKeyedTime);

    lastKeyedTime = self:GetEndKeyTime(self.keysS, lastKeyedTime);
    lastKeyedTime = self:GetEndKeyTime(self.keysA, lastKeyedTime);

    return lastKeyedTime;
end

function Track:GetEndKeyTime(keys, compareWith)
    if (keys and #keys > 0) then
        local keyEnd = keys[#keys].time;
        if (compareWith and keyEnd > compareWith) then
            return keyEnd;
        else
            return compareWith;
        end

        return keyEnd;
    end

    return compareWith or 0;
end

function Track:ClearRuntimeData()
    self.timeline = nil;
    self.currentAnimID = nil;
    self.currentAnimVariationID = nil;

    for i in pairs(self.animations) do
        self.animations[i]:ClearRuntimeData();
    end
end

function Track:HasAnimations()
    if (self.animations and #self.animations > 0) then
        return true;
    end

    return false;
end

function Track:HasKeyframes()
    if (self.keysPx and #self.keysPx > 0) then
        return true;
    end

    if (self.keysPy and #self.keysPy > 0) then
        return true;
    end

    if (self.keysPz and #self.keysPz > 0) then
        return true;
    end

    if (self.keysRx and #self.keysRx > 0) then
        return true;
    end

    if (self.keysRy and #self.keysRy > 0) then
        return true;
    end

    if (self.keysRz and #self.keysRz > 0) then
        return true;
    end

    if (self.keysS and #self.keysS > 0) then
        return true;
    end

    if (self.keysA and #self.keysA > 0) then
        return true;
    end

    return false;
end

function Track:RemoveKey(key)
    self:RemoveKeyFromList(key, self.keysPx);
    self:RemoveKeyFromList(key, self.keysPy);
    self:RemoveKeyFromList(key, self.keysPz);

    self:RemoveKeyFromList(key, self.keysRx);
    self:RemoveKeyFromList(key, self.keysRy);
    self:RemoveKeyFromList(key, self.keysRz);

    self:RemoveKeyFromList(key, self.keysS);
    self:RemoveKeyFromList(key, self.keysA);
end

function Track:RemoveKeyFromList(key, keyList)
    if (keyList) then
        for i in pairs(keyList) do
            if (keyList[i] == key) then
                table.remove(keyList, i);
            end
        end
    end
end

--- Returns a string representation of the Track object.
--- @return string The string representation of the Track object.
Track.__tostring = function(self)
    return string.format("Track: %s Anims: %i Keys: %i", self.name, #self.animations,
        #self.keysPx + #self.keysPy + #self.keysPz + #self.keysRx +
        #self.keysRy + #self.keysRz + #self.keysS + #self.keysA);
end

-- This function is used as the __index metamethod for the Track table.
-- It is responsible for handling the indexing of Track objects.
Track.__index = function(t,k)
    local var = rawget(Track, k)
        
    if var == nil then							
        var = rawget(fields, k)
        
        if var ~= nil then
            return var(t)	
        end
    end
    
    return var
end