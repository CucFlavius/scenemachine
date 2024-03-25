SceneMachine.Track = 
{
    objectID = nil, -- keeping a reference for when loading saved data
    name = "New Track",
    animations = {},
    keysPx = {},
    keysPy = {},
    keysPz = {},
    keysRx = {},
    keysRy = {},
    keysRz = {},
    keysS = {},
    keysA = {},
}

--- @class Track
local Track = SceneMachine.Track;

--- @enum Track.Interpolation
Track.Interpolation = {
    Bezier = 1,
    Linear = 2,
    Step = 3,
    Slow = 4,
    Fast = 5,
}

setmetatable(Track, Track)

local fields = {}

-- Creates a new Track object.
--- @param object? Object The object to associate with the track.
--- @return Track v The newly created Track object.
function Track:New(object)
    local v = 
    {
        animations = {},
        keysPx = {},
        keysPy = {},
        keysPz = {},
        keysRx = {},
        keysRy = {},
        keysRz = {},
        keysS = {},
        keysA = {},
    };
    
    if (object) then
        v.objectID = object.id;
        v.name = object.name;
    end

    setmetatable(v, Track)
    return v
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

--- Imports data into the Track object.
--- @param data table The data to be imported.
function Track:ImportData(data)
    if (data == nil) then
        print("Track:ImportData() data was nil.");
        return;
    end

    -- verifying all elements upon import because sometimes the saved variables get corrupted --
    if (data.objectID ~= nil) then
        self.objectID = data.objectID;
    end

    if (data.name ~= nil) then
        self.name = data.name;
    end

    if (data.animations ~= nil) then
        self.animations = data.animations;
    end

    if (data.keysPx) then
        self.keysPx = {};
        for k in pairs(data.keysPx) do
            local key = data.keysPx[k];
            self.keysPx[k] = {
                time = key.time,
                value = key.value,
                interpolationIn = key.interpolationIn,
                interpolationOut = key.interpolationOut,
            };
        end
    end

    if (data.keysPy) then
        self.keysPy = {};
        for k in pairs(data.keysPy) do
            local key = data.keysPy[k];
            self.keysPy[k] = {
                time = key.time,
                value = key.value,
                interpolationIn = key.interpolationIn,
                interpolationOut = key.interpolationOut,
            };
        end
    end

    if (data.keysPz) then
        self.keysPz = {};
        for k in pairs(data.keysPz) do
            local key = data.keysPz[k];
            self.keysPz[k] = {
                time = key.time,
                value = key.value,
                interpolationIn = key.interpolationIn,
                interpolationOut = key.interpolationOut,
            };
        end
    end

    if (data.keysRx) then
        self.keysRx = {};
        for k in pairs(data.keysRx) do
            local key = data.keysRx[k];
            self.keysRx[k] = {
                time = key.time,
                value = key.value,
                interpolationIn = key.interpolationIn,
                interpolationOut = key.interpolationOut,
            };
        end
    end

    if (data.keysRy) then
        self.keysRy = {};
        for k in pairs(data.keysRy) do
            local key = data.keysRy[k];
            self.keysRy[k] = {
                time = key.time,
                value = key.value,
                interpolationIn = key.interpolationIn,
                interpolationOut = key.interpolationOut,
            };
        end
    end

    if (data.keysRz) then
        self.keysRz = {};
        for k in pairs(data.keysRz) do
            local key = data.keysRz[k];
            self.keysRz[k] = {
                time = key.time,
                value = key.value,
                interpolationIn = key.interpolationIn,
                interpolationOut = key.interpolationOut,
            };
        end
    end

    if (data.keysS) then
        self.keysS = {};
        for k in pairs(data.keysS) do
            local key = data.keysS[k];
            self.keysS[k] = {
                time = key.time,
                value = key.value,
                interpolationIn = key.interpolationIn,
                interpolationOut = key.interpolationOut,
            };
        end
    end

    if (data.keysA) then
        self.keysA = {};
        for k in pairs(data.keysA) do
            local key = data.keysA[k];
            self.keysA[k] = {
                time = key.time,
                value = key.value,
                interpolationIn = key.interpolationIn,
                interpolationOut = key.interpolationOut,
            }
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
            if (animation.startT <= timeMS and animation.endT > timeMS) then
        ---- anim is in range
                local animSpeed = animation.speed or 1;
                local animMS = mod((timeMS - animation.startT) * animSpeed, animation.animLength);
                local animID = animation.id;
                local variationID = animation.variation;

                return animID, variationID, animMS, animSpeed;
            end
        end
    end

    return -1, -1, 1, 1;
end

--- Adds a keyframe to the track.
--- @param time number The time of the keyframe.
--- @param value number The value of the keyframe.
--- @param keyframes? table (optional) The array of existing keyframes. If not provided, a new array will be created.
--- @param interpolationIn? Track.Interpolation (optional) The interpolation type for the incoming tangent of the keyframe. Defaults to Track.Interpolation.Bezier.
--- @param interpolationOut? Track.Interpolation (optional) The interpolation type for the outgoing tangent of the keyframe. Defaults to Track.Interpolation.Bezier.
function Track:AddKeyframe(time, value, keyframes, interpolationIn, interpolationOut)
    if (not keyframes) then keyframes = {}; end

    interpolationIn = interpolationIn or Track.Interpolation.Bezier;
    interpolationOut = interpolationOut or Track.Interpolation.Bezier;
    
    for i = 1, #keyframes, 1 do
        if (keyframes[i].time == time) then
            keyframes[i].value = value;
            return;
        end
    end

    keyframes[#keyframes + 1] = { time = time, value = value, interpolationIn = interpolationIn, interpolationOut = interpolationOut};
end

--- Adds a full keyframe to the track.
--- @param time number The time of the keyframe.
--- @param position Vector3 The position of the keyframe.
--- @param rotation Vector3 The rotation of the keyframe.
--- @param scale number The scale of the keyframe.
--- @param alpha number The alpha value of the keyframe.
--- @param interpolationIn? Track.Interpolation (optional) The interpolation type for the keyframe's incoming tangent.
--- @param interpolationOut? Track.Interpolation (optional) The interpolation type for the keyframe's outgoing tangent.
function Track:AddFullKeyframe(time, position, rotation, scale, alpha, interpolationIn, interpolationOut)
    self:AddPositionKeyframe(time, position, interpolationIn, interpolationOut);
    self:AddRotationKeyframe(time, rotation, interpolationIn, interpolationOut);
    self:AddScaleKeyframe(time, scale, interpolationIn, interpolationOut);
    self:AddAlphaKeyframe(time, alpha, interpolationIn, interpolationOut);
end

--- Adds a position keyframe to the track.
--- @param time number The time at which the keyframe occurs.
--- @param position Vector3 The position value of the keyframe.
--- @param interpolationIn? Track.Interpolation (optional) The interpolation type for the keyframe's incoming tangent.
--- @param interpolationOut? Track.Interpolation (optional) The interpolation type for the keyframe's tangent.
function Track:AddPositionKeyframe(time, position, interpolationIn, interpolationOut)
    self:AddKeyframe(time, position.x, self.keysPx, interpolationIn, interpolationOut);
    self:AddKeyframe(time, position.y, self.keysPy, interpolationIn, interpolationOut);
    self:AddKeyframe(time, position.z, self.keysPz, interpolationIn, interpolationOut);
    self:SortPositionKeyframes();
end

--- Adds a rotation keyframe to the track.
--- @param time number The time at which the keyframe occurs.
--- @param rotation Vector3 The rotation values for the keyframe.
--- @param interpolationIn? Track.Interpolation (optional) The interpolation type for the keyframe's incoming tangent.
--- @param interpolationOut? Track.Interpolation (optional) The interpolation type for the keyframe's outgoing tangent.
function Track:AddRotationKeyframe(time, rotation, interpolationIn, interpolationOut)
    self:AddKeyframe(time, rotation.x, self.keysRx, interpolationIn, interpolationOut);
    self:AddKeyframe(time, rotation.y, self.keysRy, interpolationIn, interpolationOut);
    self:AddKeyframe(time, rotation.z, self.keysRz, interpolationIn, interpolationOut);
    self:SortRotationKeyframes();
end

--- Adds a scale keyframe to the track.
--- @param time number The time of the keyframe.
--- @param scale number The scale value of the keyframe.
--- @param interpolationIn? Track.Interpolation (optional) The interpolation type for the keyframe's incoming tangent.
--- @param interpolationOut? Track.Interpolation (optional) The interpolation type for the keyframe's outgoing tangent.
function Track:AddScaleKeyframe(time, scale, interpolationIn, interpolationOut)
    self:AddKeyframe(time, scale, self.keysS, interpolationIn, interpolationOut);
    self:SortScaleKeyframes();
end

--- Adds an alpha keyframe to the track.
--- @param time number The time of the keyframe.
--- @param alpha number The alpha value of the keyframe.
--- @param interpolationIn? Track.Interpolation (optional) The interpolation type for the keyframe's incoming tangent.
--- @param interpolationOut? Track.Interpolation (optional) The interpolation type for the keyframe's outgoing tangent.
function Track:AddAlphaKeyframe(time, alpha, interpolationIn, interpolationOut)
    self:AddKeyframe(time, alpha, self.keysA, interpolationIn, interpolationOut);
    self:SortAlphaKeyframes();
end

--- Sorts the position keyframes of the track based on their time.
function Track:SortPositionKeyframes()
    if (self.keysPx) then
        table.sort(self.keysPx, function(a,b) return a.time < b.time end)
    end
    if (self.keysPy) then
        table.sort(self.keysPy, function(a,b) return a.time < b.time end)
    end
    if (self.keysPz) then
        table.sort(self.keysPz, function(a,b) return a.time < b.time end)
    end
end

-- Sorts the rotation keyframes of the track.
function Track:SortRotationKeyframes()
    -- Sort the x-axis rotation keyframes if they exist
    if (self.keysRx) then
        table.sort(self.keysRx, function(a,b) return a.time < b.time end)
    end
    -- Sort the y-axis rotation keyframes if they exist
    if (self.keysRy) then
        table.sort(self.keysRy, function(a,b) return a.time < b.time end)
    end
    -- Sort the z-axis rotation keyframes if they exist
    if (self.keysRz) then
        table.sort(self.keysRz, function(a,b) return a.time < b.time end)
    end
end

--- Sorts the scale keyframes of the track based on their time.
function Track:SortScaleKeyframes()
    if (self.keysS) then
        table.sort(self.keysS, function(a,b) return a.time < b.time end)
    end
end

--- Sorts the alpha keyframes of the track based on their time.
function Track:SortAlphaKeyframes()
    if (self.keysA) then
        table.sort(self.keysA, function(a,b) return a.time < b.time end)
    end
end

--- Sorts all the keyframes of the track.
function Track:SortKeyframes()
    self:SortPositionKeyframes();
    self:SortRotationKeyframes();
    self:SortScaleKeyframes();
    self:SortAlphaKeyframes();
end

--- SampleKey function is used to sample a value from a set of keys based on a given time.
--- This function assumes that the keys are sorted in ascending order based on time.
--- @param timeMS number The time in milliseconds at which to sample the value.
--- @param keys table The array of keys containing time, value, and interpolation information.
--- @return number? The sampled value at the given time, or nil if no value is found.:
function Track:SampleKey(timeMS, keys)
    if (not keys) then return nil; end
    if (#keys == 0) then return nil; end

    if (#keys == 1) then
        if (keys[1].time == timeMS) then
            return keys[1].value;
        else
            return nil;
        end
    end

    local idx = 1;
    local numTimes = #keys;

    for i = 1, numTimes, 1 do
        if (i + 1 <= numTimes) then
            if (timeMS >= keys[i].time and timeMS < keys[i + 1].time) then
                idx = i;
                break;
            end
        end
        if (i == numTimes) then
            return keys[#keys].value;
        end
        if (i == 1 and timeMS < keys[1].time) then
            return keys[1].value;
        end
    end

    local t1 = keys[idx].time;
    local t2 = keys[idx + 1].time;

    local i1 = keys[idx].interpolationOut;
    local i2 = keys[idx + 1].interpolationIn;

    local r = 0;
    if (i1 == i2) then
        if (i1 == Track.Interpolation.Bezier) then
            r = Track:InterpolateBezierAuto(t1, t2, timeMS);
        elseif (i1 == Track.Interpolation.Linear) then
            r = Track:InterpolateLinear(t1, t2, timeMS);
        elseif (i1 == Track.Interpolation.Step) then
            r = Track:InterpolateStep(t1, t2, timeMS);
        elseif (i1 == Track.Interpolation.Slow) then
            r = Track:InterpolateBezierSlow(t1, t2, timeMS);
        elseif (i1 == Track.Interpolation.Fast) then
            r = Track:InterpolateBezierFast(t1, t2, timeMS);
        end
    else
        if (i1 == Track.Interpolation.Step or i2 == Track.Interpolation.Step) then
            r = Track:InterpolateStep(t1, t2, timeMS);
        else
            local alpha = Track:InterpolateLinear(t1, t2, timeMS);
            local A = 0;
            local B = 0;
            if (i1 == Track.Interpolation.Bezier) then
                A = Track:InterpolateBezierAuto(t1, t2, timeMS);
            elseif (i1 == Track.Interpolation.Linear) then
                A = Track:InterpolateLinear(t1, t2, timeMS);
            elseif (i1 == Track.Interpolation.Slow) then
                A = Track:InterpolateBezier(t1, t2, timeMS, 0, 1, 0, 2);
            elseif (i1 == Track.Interpolation.Fast) then
                A = Track:InterpolateBezier(t1, t2, timeMS, 0, 1, 2, 0);
            end

            if (i2 == Track.Interpolation.Bezier) then
                B = Track:InterpolateBezierAuto(t1, t2, timeMS);
            elseif (i2 == Track.Interpolation.Linear) then
                B = Track:InterpolateLinear(t1, t2, timeMS);
            elseif (i2 == Track.Interpolation.Slow) then
                B = Track:InterpolateBezier(t1, t2, timeMS, 0, 1, 2, 0);
            elseif (i2 == Track.Interpolation.Fast) then
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