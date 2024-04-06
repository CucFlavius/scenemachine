SceneMachine.AnimationClip = {}

--- @class AnimationClip
local AnimationClip = SceneMachine.AnimationClip;

AnimationClip.colors = {
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

setmetatable(AnimationClip, AnimationClip)

local fields = {}

--- Creates a new AnimationClip object.
--- @param id number? (optional) - The ID of the animation clip.
--- @param variation number? (optional) - The variation of the animation clip.
--- @param track Track - The track of the animation clip.
--- @param startT number? (optional) - The start time of the animation clip.
--- @param endT number? (optional) - The end time of the animation clip.
--- @param name string? (optional) - The name of the animation clip.
--- @param speed number? (optional) - The speed of the animation clip.
--- @return AnimationClip - The newly created AnimationClip object.
function AnimationClip:New(id, variation, track, startT, endT, name, speed)
    --- @class AnimationClip
    local v = 
    {
        id = id or 0,
        variation = variation or 0,
        startT = startT or 0,
        endT = endT or 3000,
        animLength = 3000,
        name = name or "Anim",
        speed = speed or 1,
        colorId = 0,
        track = track,
    };

    setmetatable(v, AnimationClip)

    v:RandomizeColor();

    return v
end

--- Creates a new clone of an AnimationClip object.
--- @param anim AnimationClip The AnimationClip object to clone.
--- @return AnimationClip The cloned AnimationClip object.
function AnimationClip:NewClone(anim)
    local v = 
    {
        id = anim.id,
        variation = anim.variation,
        startT = anim.startT,
        endT = anim.endT,
        animLength = anim.animLength,
        name = anim.name,
        speed = anim.speed,
        colorId = anim.colorId,
        track = anim.track,
    };

    setmetatable(v, AnimationClip)

    return v
end

--- Sets the animation properties of the AnimationClip.
--- @param anim AnimationClip The animation object containing the properties to set.
function AnimationClip:SetAnim(anim)
    self.id = anim.id;
    self.variation = anim.variation;
    self.animLength = anim.animLength;
    self.colorId = anim.colorId;
    self.startT = anim.startT;
    self.endT = anim.endT;
    self.name = anim.name;
    self.speed = anim.speed;
end

function AnimationClip:SetTrack(track)
    self.track = track;
end

--- Export the AnimationClip data
--- @return table data The exported AnimationClip data
function AnimationClip:Export()
    local data = {
        id = self.id,
        variation = self.variation,
        animLength = self.animLength,
        colorId = self.colorId,
        startT = self.startT,
        endT = self.endT,
        name = self.name,
        speed = self.speed,
    };

    return data;
end

--- Export the AnimationClip data in a packed format.
--- @return table packed The packed AnimationClip data.
function AnimationClip:ExportPacked()
    local packed = {
        self.id,
        self.variation,
        self.animLength,
        self.colorId,
        self.startT,
        self.endT,
        self.name,
        self.speed,
    };

    return packed;
end

--- Imports data into the AnimationClip object.
--- @param data? table The data to be imported.
function AnimationClip:ImportData(data)
    if (data == nil) then
        print("AnimationClip:ImportData() data was nil.");
        return;
    end

    self.id = data.id;
    self.variation = data.variation;
    self.animLength = data.animLength;
    self.colorId = data.colorId;
    self.startT = data.startT;
    self.endT = data.endT;
    self.name = data.name;
    self.speed = data.speed;
end

--- Imports packed data into the AnimationClip object.
--- @param packed? table The packed data to be imported.
function AnimationClip:ImportPacked(packed)
    if (packed == nil) then
        print("AnimationClip:ImportPacked() packed was nil.");
        return;
    end

    self.id = packed[1];
    self.variation = packed[2];
    self.animLength = packed[3];
    self.colorId = packed[4];
    self.startT = packed[5];
    self.endT = packed[6];
    self.name = packed[7];
    self.speed = packed[8];
end

--- Sets the ID of the animation clip.
--- @param id number The ID to set.
function AnimationClip:SetId(id)
    self.id = id;
end

--- Retrieves the ID of the animation clip.
---@return number: The ID of the animation clip.
function AnimationClip:GetId()
    return self.id;
end

--- Sets the variation of the animation clip.
--- @param variation number The variation value to set.
function AnimationClip:SetVariation(variation)
    self.variation = variation;
end

--- Gets the variation of the animation clip.
--- @return number: The variation of the animation clip.
function AnimationClip:GetVariation()
    return self.variation;
end

--- Sets the length of the animation clip.
--- @param length number The actual length of the animation clip from the animation data.
function AnimationClip:SetLength(length)
    self.animLength = length;
end

--- Gets the length of the animation clip, this is the actual length in the animation data.
--- @return number: The length of the animation clip.
function AnimationClip:GetLength()
    return self.animLength;
end

--- Gets the duration of the animation clip. This is the current duration in the timeline.
--- @return number: The duration of the animation clip.
function AnimationClip:GetDuration()
    return self.endT - self.startT;
end

--- Sets the speed of the animation clip.
--- Values between 0 and 1 will slow down the animation.
--- Values greater than 1 will speed up the animation.
--- @param speed number The speed value to set.
function AnimationClip:SetSpeed(speed)
    self.speed = speed;
end

--- Gets the speed of the animation clip.
--- @return number: The speed of the animation clip.
function AnimationClip:GetSpeed()
    return self.speed;
end

--- Sets the start time of the animation clip.
--- @param timeMS number The start time in miliseconds.
function AnimationClip:SetStartTime(timeMS)
    self.startT = timeMS;
end

--- Gets the start time of the animation clip.
--- @return number: The start time of the animation clip in miliseconds.
function AnimationClip:GetStartTime()
    return self.startT;
end

--- Sets the end time of the animation clip.
--- @param timeMS number The end time in milliseconds.
function AnimationClip:SetEndTime(timeMS)
    self.endT = timeMS;
end

--- Gets the end time of the animation clip.
--- @return number: The end time of the animation clip in miliseconds.
function AnimationClip:GetEndTime()
    return self.endT;
end

--- Sets the name of the animation clip.
--- @param name string The new name for the animation clip.
function AnimationClip:SetName(name)
    self.name = name;
end

--- Gets the name of the animation clip.
--- @return string: The name of the animation clip.
function AnimationClip:GetName()
    return self.name;
end

--- Sets the color ID of the animation clip.
--- @param colorId number The color ID to set.
function AnimationClip:SetColorId(colorId)
    self.colorId = colorId;
end

--- Retrieves the color ID of the animation clip.
--- @return number: The color ID of the animation clip.
function AnimationClip:GetColorId()
    return self.colorId;
end

--- Retrieves the color of the animation clip.
--- @return number r, number g, number b, number a - The color components (red, green, blue, alpha) normalized between 0 and 1.
function AnimationClip:GetColor()
    return  AnimationClip.colors[self.colorId][1] / 255,
            AnimationClip.colors[self.colorId][2] / 255,
            AnimationClip.colors[self.colorId][3] / 255,
            1
end

--- Randomizes the colorId property of the AnimationClip object.
function AnimationClip:RandomizeColor()
    self.colorId = math.random(1, #AnimationClip.colors);
end

--- Checks if the given time is within the range of the animation clip.
--- @param timeMS number The time in milliseconds.
--- @return boolean: True if the time is within the range, false otherwise.
function AnimationClip:TimeIsInRange(timeMS)
    return timeMS >= self.startT and timeMS < self.endT;
end

--- Samples the animation clip at the given time.
--- @param timeMS number The time in milliseconds.
--- @return number animID, number variationID, number animMS, number animSpeed The animation ID, variation ID, sampled time, and animation speed.
function AnimationClip:Sample(timeMS)
    local animSpeed = self.speed or 1;
    local animMS = mod((timeMS - self.startT) * animSpeed, self.animLength);
    local animID = self.id;
    local variationID = self.variation;
    return animID, variationID, animMS, animSpeed;
end

--- Swaps the left animation clip with the given animation clip.
--- @param anim AnimationClip The animation clip to swap with.
--- @param animL AnimationClip The left animation clip.
function AnimationClip.SwapLeft(anim, animL)
    -- sL     eL s          e
    -- sL          eL s     e
    local startT = anim.startT;
    local endT = anim.endT;
    local lStartT = animL.startT;
    local lEndT = animL.endT;
    animL:SetEndTime(lStartT + (endT - startT));
    anim:SetStartTime(animL.endT);
    AnimationClip.SwapAnimData(anim, animL);
end

--- Swaps the timing and animation data between two animation clips.
--- @param anim AnimationClip The first animation clip.
--- @param animR AnimationClip The second animation clip.
function AnimationClip.SwapRight(anim, animR)
    -- s     e sR          eR
    -- s          e sR     eR
    local startT = anim.startT;
    local endT = anim.endT;
    local rStartT = animR.startT;
    local rEndT = animR.endT;
    anim:SetEndTime(startT + (rEndT - rStartT));
    animR:SetStartTime(anim.endT);
    AnimationClip.SwapAnimData(anim, animR);
end

--- Swaps the animation data between two AnimationClip objects.
--- @param A AnimationClip The first AnimationClip object.
--- @param B AnimationClip The second AnimationClip object.
function AnimationClip.SwapAnimData(A, B)
    local id = A.id;
    local name = A.name;
    local colorId = A.colorId;
    local variation = A.variation;
    local animLength = A.animLength

    A:SetId(B:GetId());
    A:SetName(B:GetName());
    A:SetColorId(B:GetColorId());
    A:SetVariation(B:GetVariation());
    A:SetLength(B:GetLength());

    B:SetId(id);
    B:SetName(name);
    B:SetColorId(colorId);
    B:SetVariation(variation);
    B:SetLength(animLength);
end

--- Clears the runtime data of the animation clip.
function AnimationClip:ClearRuntimeData()
    self.track = nil;
end

--- Checks if two AnimationClip objects are equal, byt comparing time values.
--- @param a AnimationClip The first AnimationClip object.
--- @param b AnimationClip The second AnimationClip object.
--- @return boolean equal if the AnimationClip objects are equal, false otherwise.
AnimationClip.__eq = function(a,b)
    return a.id == b.id;
end

--- Returns a string representation of the AnimationClip object.
--- @return string The string representation of the AnimationClip object.
AnimationClip.__tostring = function(self)
    return string.format("AnimationClip: %s %i(%i) [%i - %i] s:%f", self.name, self.id, self.variation, self.startT, self.endT, self.speed);
end

-- This function is used as the __index metamethod for the AnimationClip table.
-- It is responsible for handling the indexing of AnimationClip objects.
AnimationClip.__index = function(t,k)
    local var = rawget(AnimationClip, k)
        
    if var == nil then							
        var = rawget(fields, k)
        
        if var ~= nil then
            return var(t)	
        end
    end
    
    return var
end