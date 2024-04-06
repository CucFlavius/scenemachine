SceneMachine.Keyframe = {}

--- @class Keyframe
local Keyframe = SceneMachine.Keyframe;

--- @enum Keyframe.Interpolation
Keyframe.Interpolation = {
    Bezier = 1,
    Linear = 2,
    Step = 3,
    Slow = 4,
    Fast = 5,
};

Keyframe.InterpolationNames = {
    "Bezier",
    "Linear",
    "Step",
    "Slow",
    "Fast",
};

setmetatable(Keyframe, Keyframe)

local fields = {}

--- Creates a new Keyframe object.
--- @param time? number The time value of the keyframe (optional, default is 0).
--- @param value? number The value of the keyframe (optional, default is 0).
--- @param interpolationIn? Keyframe.Interpolation The interpolation type for the incoming tangent (optional, default is Keyframe.Interpolation.Bezier).
--- @param interpolationOut? Keyframe.Interpolation The interpolation type for the outgoing tangent (optional, default is Keyframe.Interpolation.Bezier).
--- @return Keyframe v The newly created Keyframe object.
function Keyframe:New(time, value, interpolationIn, interpolationOut)
    local v = 
    {
        time = time or 0,
        value = value or 0,
        interpolationIn = interpolationIn or Keyframe.Interpolation.Bezier,
        interpolationOut = interpolationOut or Keyframe.Interpolation.Bezier,
    };

    setmetatable(v, Keyframe)
    return v
end

--- Creates a new clone of a Keyframe object.
--- @param keyframe Keyframe The Keyframe object to clone.
--- @return Keyframe: The cloned Keyframe object.
function Keyframe:NewClone(keyframe)
    local v = 
    {
        time = keyframe.time,
        value = keyframe.value,
        interpolationIn = keyframe.interpolationIn,
        interpolationOut = keyframe.interpolationOut,
    };

    setmetatable(v, Keyframe)
    return v
end

--- Export the Keyframe data
--- @return table data The exported Keyframe data
function Keyframe:Export()
    local data = {
        time = self.time,
        value = self.value,
        interpolationIn = self.interpolationIn,
        interpolationOut = self.interpolationOut,
    };

    return data;
end

function Keyframe:ExportPacked()
    local packed = {
        self.time,
        self.value,
        self.interpolationIn,
        self.interpolationOut,
    }
    return packed;
end

--- Imports data into the Keyframe object.
--- @param data? table The data to be imported.
function Keyframe:ImportData(data)
    if (data == nil) then
        print("Keyframe:ImportData() data was nil.");
        return;
    end

    self.time = data.time or 0;
    self.value = data.value or 0;
    self.interpolationIn = data.interpolationIn or Keyframe.Interpolation.Bezier;
    self.interpolationOut = data.interpolationOut or Keyframe.Interpolation.Bezier;
end

--- Imports packed data into the Keyframe object.
--- @param packed? table The packed data to be imported.
function Keyframe:ImportPacked(packed)
    if (packed == nil) then
        print("Keyframe:ImportPacked() packed was nil.");
        return;
    end

    self.time = packed[1] or 0;
    self.value = packed[2] or 0;
    self.interpolationIn = packed[3] or Keyframe.Interpolation.Bezier;
    self.interpolationOut = packed[4] or Keyframe.Interpolation.Bezier;
end

--- Sets the time of the keyframe.
--- @param time number The time value to set.
function Keyframe:SetTime(time)
    self.time = time;
end

--- Gets the time of the keyframe.
--- @return number time The time of the keyframe.
function Keyframe:GetTime()
    return self.time;
end

--- Compares the time of the keyframe with the specified time.
--- @param otherTime number The time to compare with.
--- @return boolean: Returns true if the keyframe time is equal to the specified time, false otherwise.
function Keyframe:CompareTime(otherTime)
    return self.time == otherTime;
end

--- Sets the value of the keyframe.
--- @param value number any The value to set.
function Keyframe:SetValue(value)
    self.value = value;
end

--- Gets the value of the keyframe.
--- @return number: The value of the keyframe.
function Keyframe:GetValue()
    return self.value;
end

--- Sets the interpolation type for the incoming segment of the keyframe.
--- @param interpolation Keyframe.Interpolation The interpolation type to set.
function Keyframe:SetInterpolationIn(interpolation)
    self.interpolationIn = interpolation;
end

--- Retrieves the interpolation value for the keyframe's incoming tangent.
--- @return Keyframe.Interpolation interpolation The interpolation value for the incoming tangent.
function Keyframe:GetInterpolationIn()
    return self.interpolationIn or Keyframe.Interpolation.Bezier;
end

--- Sets the interpolation out value for the keyframe.
--- @param interpolation Keyframe.Interpolation The interpolation value to set.
function Keyframe:SetInterpolationOut(interpolation)
    self.interpolationOut = interpolation;
end

--- Retrieves the interpolation value for the keyframe's outgoing tangent.
--- @return Keyframe.Interpolation interpolation interpolation out value.
function Keyframe:GetInterpolationOut()
    return self.interpolationOut or Keyframe.Interpolation.Bezier;
end

--- Converts an interpolation value to its corresponding name.
---@param interpolation? Keyframe.Interpolation The interpolation value to convert.
---@return string name The name of the interpolation value, or "Unknown" if the value is not found.
function Keyframe.InterpolationToName(interpolation)
    return Keyframe.InterpolationNames[interpolation] or "Unknown";
end

--- Checks if two Keyframe objects are equal, byt comparing time values.
--- @param a Keyframe The first Keyframe object.
--- @param b Keyframe The second Keyframe object.
--- @return boolean equal if the Keyframe objects are equal, false otherwise.
Keyframe.__eq = function(a,b)
    return a.time == b.time;
end

--- Returns a string representation of the Keyframe object.
--- @return string The string representation of the Keyframe object.
Keyframe.__tostring = function(self)
    return string.format("Keyframe: %i %f %s %s", self.time, self.value,
    Keyframe.InterpolationToName(self.interpolationIn), Keyframe.InterpolationToName(self.interpolationOut));
end

-- This function is used as the __index metamethod for the Keyframe table.
-- It is responsible for handling the indexing of Keyframe objects.
Keyframe.__index = function(t,k)
    local var = rawget(Keyframe, k)
        
    if var == nil then							
        var = rawget(fields, k)
        
        if var ~= nil then
            return var(t)	
        end
    end
    
    return var
end