local Math = SceneMachine.Math;
local Vector3 = SceneMachine.Vector3;
local Quaternion = SceneMachine.Quaternion;

SceneMachine.Track = 
{
    objectID = nil, -- keeping a reference for when loading saved data
    name = "New Track",
    animations = {},
    keyframes = {},
}

local Track = SceneMachine.Track;

setmetatable(Track, Track)

local fields = {}

function Track:New(object)
	local v = 
    {
        -- Don't store an object reference, no reason for duplicates in saved data
        --object = object or nil,
        animations = {},
        keyframes = {},
    };
    
    if (object) then
        v.objectID = object.id;
        v.name = object.name;
    end

	setmetatable(v, Track)
	return v
end

function Track:ExportData()
    local data = {
        objectID = self.object.id;
        animations = self.animations;
        keyframes = self.keyframes;
    };

    return data;
end

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

    if (data.keyframes ~= nil) then
        self.keyframes = {};

        for k in pairs(data.keyframes) do
            local key = data.keyframes[k];

            self.keyframes[k] = {
                time = key.time,
                position = Vector3:New(key.position.x, key.position.y ,key.position.z),
                rotation = Quaternion:New(key.rotation.x, key.rotation.y, key.rotation.z, key.rotation.w),
                scale = key.scale,
            };
        end
    end
end

function Track:SampleAnimation(timeMS)
    -- find anim in range
    if (self.animations) then
        for a in pairs(self.animations) do
            local animation = self.animations[a];
            --{ id, variation, animLength, startT, endT, colorId, name }
            if (animation.startT <= timeMS and animation.endT > timeMS) then
                -- anim is in range
                local animMS = mod(timeMS - animation.startT, animation.animLength);
                local animID = animation.id;
                local variationID = animation.variation;

                return animID, variationID, animMS;
            end
        end
    end

    return -1, -1
end

function Track:AddKeyframe(time, position, rotation, scale)
    if (not self.keyframes) then
        self.keyframes = {};
    end

    local pos = Vector3:New(position.x, position.y, position.z);
    local rot = Quaternion:New();
    rot:SetFromEuler(rotation);
    self.keyframes[#self.keyframes + 1] = {
        time = time,
        position = pos,
        rotation = rot,
        scale = scale,
    };
    self:SortKeyframes();
end

function Track:SortKeyframes()
    if (self.keyframes) then
        table.sort(self.keyframes, function(a,b) return a.time < b.time end)
    end
end

function Track:SampleKeyframes(timeMS)

    local pos = self:SamplePositionKey(timeMS);
    local rot = self:SampleRotationKey(timeMS);
    local scale = self:SampleScaleKey(timeMS);
    return pos, rot, scale;
end

function Track:SamplePositionKey(timeMS)
    if (not self.keyframes) then
        return Vector3.zero;
    end

    if (#self.keyframes == 0) then
        return Vector3.zero;
    end

    if (#self.keyframes == 1) then
        return self.keyframes[1].position;
    end

    local idx = 1;
    local numTimes = #self.keyframes;

    for i = 1, numTimes, 1 do
        if (i + 1 <= numTimes) then
            if (timeMS >= self.keyframes[i].time and timeMS < self.keyframes[i + 1].time) then
                idx = i;
                break;
            end
        else
            idx = 1;
            break;
        end
    end

    local t1 = self.keyframes[idx].time;
    local t2 = self.keyframes[idx + 1].time;

    if (t1 ~= t2) then
        r = Track:InterpolateAutoBezier(t1, t2, timeMS);
    end

    if (r >= 1) then
        return self.keyframes[#self.keyframes].position;
    elseif(r < 0) then
        return self.keyframes[1].position;
    end

    return Vector3.Interpolate(self.keyframes[idx].position, self.keyframes[idx + 1].position, r);
end

function Track:InterpolateLinear(t1, t2, timeMS)
    return (timeMS - t1) / (t2 - t1);
end

function Track:InterpolateAutoBezier(tA, tB, timeMS)
    local t = (timeMS - tA) / (tB - tA)
    
    --t = interpolationValue
    local t2 = t * t
    local t3 = t2 * t
    
    local previousPoint = 0;
    local nextPoint = 1;
    local previousTangent = 0--tA + (tB - tA) / 3
    local nextTangent = 0--tB - (tB - tA) / 3

    local p = (2 * t3 - 3 * t2 + 1) * previousPoint +
           (t3 - 2 * t2 + t) * previousTangent +
           (-2 * t3 + 3 * t2) * nextPoint +
           (t3 - t2) * nextTangent;

    return p;
end

function Track:SampleRotationKey(timeMS)
    if (not self.keyframes) then
        return Quaternion.identity;
    end

    if (#self.keyframes == 0) then
        return Quaternion.identity;
    end

    if (#self.keyframes == 1) then
        return self.keyframes[1].rotation;
    end

    local idx = 1;
    local numTimes = #self.keyframes;

    for i = 1, numTimes, 1 do
        if (i + 1 <= numTimes) then
            if (timeMS >= self.keyframes[i].time and timeMS < self.keyframes[i + 1].time) then
                idx = i;
                break;
            end
        else
            idx = 1;
            break;
        end
    end

    local t1 = self.keyframes[idx].time;
    local t2 = self.keyframes[idx + 1].time;

    if (t1 ~= t2) then
        r = (timeMS - t1) / (t2 - t1);
    end
    if (r >= 1) then
        return self.keyframes[#self.keyframes].rotation;
    elseif(r < 0) then
        return self.keyframes[1].rotation;
    end
    
    return Quaternion.Interpolate(self.keyframes[idx].rotation, self.keyframes[idx + 1].rotation, r);
end

function Track:SampleScaleKey(timeMS)
    if (not self.keyframes) then
        return 1;
    end

    if (#self.keyframes == 0) then
        return 1;
    end

    if (#self.keyframes == 1) then
        return self.keyframes[1].scale;
    end

    local idx = 1;
    local numTimes = #self.keyframes;

    for i = 1, numTimes, 1 do
        if (i + 1 <= numTimes) then
            if (timeMS >= self.keyframes[i].time and timeMS < self.keyframes[i + 1].time) then
                idx = i;
                break;
            end
        else
            idx = 1;
            break;
        end
    end

    local t1 = self.keyframes[idx].time;
    local t2 = self.keyframes[idx + 1].time;

    if (t1 ~= t2) then
        r = (timeMS - t1) / (t2 - t1);
    end

    if (r >= 1) then
        return self.keyframes[#self.keyframes].scale;
    elseif(r < 0) then
        return self.keyframes[1].scale;
    end

    local v1 = self.keyframes[idx].scale;
    local v2 = self.keyframes[idx + 1].scale;
    local result = (v1 + (v2 - v1) * r);
    return result;
end

Track.__tostring = function(self)
	return string.format("Track: %s Anims: %i Keys: %i", self.name, #self.animations, #self.keyframes);
end

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