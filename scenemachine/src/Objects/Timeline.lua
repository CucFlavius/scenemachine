SceneMachine.Timeline = {}

--- @class Timeline
local Timeline = SceneMachine.Timeline;

setmetatable(Timeline, Timeline)

local fields = {}

--- Creates a new Timeline object.
--- @param name string The name of the timeline.
--- @param duration? number (optional) The duration of the timeline in milliseconds. Defaults to 30000 (30 seconds).
--- @return Timeline: The newly created Timeline object.
function Timeline:New(name, duration)
    --- @class Timeline
    local v = 
    {
        name = name,
        currentTime = 0,
        duration = duration or 30000, -- 30000 miliseconds, 30 seconds
        --- @type Track[]
        tracks = {},
    };

    setmetatable(v, Timeline)

    return v
end

--- Export the Timeline data
--- @return table data The exported Timeline data
function Timeline:Export()
    local data = {
        name = self.name,
        duration = self.duration,
        currentTime = self.currentTime,
        tracks = self.tracks,
    }
    return data;
end

--- Imports data into the Timeline object.
--- @param data? table The data to be imported.
function Timeline:ImportData(data)
    if (data == nil) then
        print("Timeline:ImportData() data was nil.");
        return;
    end

    self.name = data.name;
    self.duration = data.duration;
    self.currentTime = data.currentTime;
    self.tracks = {};
    if (data.tracks) then
        if (#data.tracks > 0) then
            for j = 1, #data.tracks, 1 do
                local track = SceneMachine.Track:New();
                track:ImportData(data.tracks[j]);
                self.tracks[j] = track;
            end
        end
    end
end

--- Clears the runtime data of the timeline.
--- Is called right before saving the variables to file.
function Timeline:ClearRuntimeData()
    self.width = nil;
end

--- Gets the duration of the timeline in miliseconds.
--- @return number duration The duration of the timeline.
function Timeline:GetDuration()
    return self.duration;
end

--- Sets the duration of the timeline in miliseconds.
--- @param duration number The duration of the timeline.
function Timeline:SetDuration(duration)
    self.duration = duration;
end

--- Gets the current time of the timeline in milliseconds.
--- @return number currentTime The current time.
function Timeline:GetTime()
    return self.currentTime;
end

--- Sets the current time of the timeline in miliseconds.
--- @param time number The new time value.
function Timeline:SetTime(time)
    self.currentTime = time;
end

--- Adds a track to the timeline.
--- @param track Track The track to be added.
--- @return number: The index of the added track.
function Timeline:AddTrack(track)
    if (not self.tracks) then
        self.tracks = {};
    end

    table.insert(self.tracks, track);

    return #self.tracks;
end

--- Removes a track from the timeline.
--- @param track Track The track to be removed.
function Timeline:RemoveTrack(track)
    if (#self.tracks > 0) then
        for i in pairs(self.tracks) do
            if (self.tracks[i] == track) then
                table.remove(self.tracks, i);
                return;
            end
        end
    end
end

--- Retrieves the track at the specified index.
--- @param index number The index of the track to retrieve.
--- @return Track?: The track at the specified index, or nil if the index is out of range.
function Timeline:GetTrack(index)
    if (index > 0 and index <= #self.tracks) then
        return self.tracks[index];
    end
    return nil;
end

--- Checks if the timeline has any tracks.
--- @return boolean: True if the timeline has tracks, false otherwise.
function Timeline:HasTracks()
    if (not self.tracks) then
        return false;
    end

    return #self.tracks > 0;
end

--- Gets the number of tracks in the timeline.
--- @return number: The number of tracks.
function Timeline:GetTrackCount()
    if (not self.tracks) then
        return 0;
    end

    return #self.tracks;
end

--- Returns a string representation of the Timeline object.
--- @return string The string representation of the Timeline object.
Timeline.__tostring = function(self)
    return string.format("Timeline: %s %iMs %i Tracks", self.name, self.duration, #self.tracks);
end

-- This function is used as the __index metamethod for the Timeline table.
-- It is responsible for handling the indexing of Timeline objects.
Timeline.__index = function(t,k)
    local var = rawget(Timeline, k)
        
    if var == nil then							
        var = rawget(fields, k)
        
        if var ~= nil then
            return var(t)	
        end
    end
    
    return var
end