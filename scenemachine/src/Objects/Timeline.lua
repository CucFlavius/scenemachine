SceneMachine.Timeline = {}

--- @class Timeline
local Timeline = SceneMachine.Timeline;
--- @class Track
local Track = SceneMachine.Track;

setmetatable(Timeline, Timeline)

local fields = {}

--- Creates a new Timeline object.
--- @param name string The name of the timeline.
--- @param duration? number (optional) The duration of the timeline in milliseconds. Defaults to 30000 (30 seconds).
--- @return Timeline: The newly created Timeline object.
function Timeline:New(name, duration, scene)
    --- @class Timeline
    local v = 
    {
        --- @type string
        name = name,
        --- @type number
        currentTime = 0,
        --- @type number
        duration = duration or 30000, -- 30000 miliseconds, 30 seconds
        --- @type Track[]
        tracks = {},
        --- @type Scene
        scene = scene,
    };

    setmetatable(v, Timeline)

    return v
end

--- Sets the scene for the timeline.
---@param scene Scene The scene to set.
function Timeline:SetScene(scene)
    self.scene = scene;
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

--- Exports the timeline data in a packed format.
--- @return table: The packed timeline data.
function Timeline:ExportPacked()
    local packed = {
        self.name,
        self.duration,
        self.currentTime,
    }

    local packedTracks = {};
    for i = 1, #self.tracks, 1 do
        table.insert(packedTracks, self.tracks[i]:ExportPacked());
    end
    packed[4] = packedTracks;

    return packed;
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
                track:SetTimeline(self);
                self.tracks[j] = track;
            end
        end
    end
end

--- Imports packed data into the Timeline object.
--- @param data table The packed data to import.
function Timeline:ImportPacked(data)
    self.name = data[1];
    self.duration = data[2];
    self.currentTime = data[3];
    self.tracks = {};
    if (data[4]) then
        if (#data[4] > 0) then
            for j = 1, #data[4], 1 do
                local track = SceneMachine.Track:New();
                track:ImportPacked(data[4][j]);
                track:SetTimeline(self);
                self.tracks[j] = track;
            end
        end
    end
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

--- Clears the runtime data of the timeline.
--- Is called right before saving the variables to file.
function Timeline:ClearRuntimeData()
    self.width = nil;
    self.scene = nil;

    if (self.tracks) then
        for i = 1, #self.tracks, 1 do
            self.tracks[i]:ClearRuntimeData();
        end
    end
end

--- Plays the timeline.
function Timeline:Play()
    self.playing = true;
end

--- Pauses the timeline.
function Timeline:Pause()
    self.playing = false;
end

--- Sets the current time of the timeline.
--- @param timeMS number The time in milliseconds.
--- @param rounded boolean Whether to round the time to the nearest 30 fps tick. Defaults to true.
function Timeline:SetTime(timeMS, rounded)
    if (rounded == nil) then
        rounded = true;
    end

    -- force time selection to 30 fps ticks
    if (rounded) then
        timeMS = math.floor(math.floor(timeMS / 33.3333) * 33.3333);
    end

    self.currentTime = timeMS;

    if (not self:HasTracks()) then
        return;
    end

    for t = 1, self:GetTrackCount(), 1 do
        local track = self:GetTrack(t);

        if (track) then
            track:SetTime(timeMS, self.playing);
        end
    end
end

--- Retrieves the last keyed time in the timeline.
--- This function iterates through all tracks in the timeline and returns the maximum keyed time found.
--- If no keyed time is found, it returns the duration of the timeline.
--- @return number: The last keyed time in the timeline.
function Timeline:GetLastKeyedTime()
    local lastKeyedTime = 0;
    for t = 1, self:GetTrackCount(), 1 do
        local track = self:GetTrack(t);
        if (track) then
            local newKeyedTime = track:GetLastKeyedTime();
            if (newKeyedTime > lastKeyedTime) then
                lastKeyedTime = newKeyedTime;
            end
        end
    end

    if (lastKeyedTime == 0) then
        lastKeyedTime = self:GetDuration();
    end

    return lastKeyedTime;
end

--- Returns a string representation of the duration of the timeline.
--- @return string: The duration of the timeline as a string.
function Timeline:GetDurationString()
    return Timeline.TimeValueToString(self:GetDuration());
end

--- Returns a string representation of the timeline's time value.
--- @return string: The current time as a string
function Timeline:GetTimeString()
    return Timeline.TimeValueToString(self:GetTime());
end

--- Returns the current time normalized by the duration of the timeline.
--- @return number: The normalized time value.
function Timeline:GetTimeNormalized()
    return self.currentTime / self.duration;
end

--- Converts a time value in milliseconds to a formatted string in the format "MM:SS".
--- @param duration number The time value in milliseconds.
--- @return string: The formatted time string.
function Timeline.TimeValueToString(duration)
    duration = duration or 0;
    local durationS = duration / 1000;
    local durationM = math.floor(durationS / 60);
    durationS = durationS - (60 * durationM);
    return string.format("%02d:%02d", durationM, durationS);
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