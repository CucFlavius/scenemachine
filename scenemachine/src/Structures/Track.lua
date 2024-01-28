local Math = SceneMachine.Math;
local Vector3 = SceneMachine.Vector3;


SceneMachine.Track = 
{

}

local Track = SceneMachine.Track;

setmetatable(Track, Track)

local fields = {}

function Track:New(_)
	local v = 
    {
        _ = _ or 0
    };

	setmetatable(v, Track)
	return v
end

function Track:ExportData()
    local data = {
        _ = self.MAIN_FRAME_STRATA;
    };

    return data;
end

function Track:ImportData(data)
    if (data == nil) then
        print("Track:ImportData() data was nil.");
        return;
    end

    -- verifying all elements upon import because sometimes the saved variables get corrupted --
    if (data._ ~= nil) then
        self._ = data._;
    end
end

--Track.__tostring = function(self)
--	return string.format("%s %i p(%f,%f,%f)", self.name, self.fileID, self.position.x, self.position.y, self.position.z);
--end

--Track.__eq = function(a,b)
--    return a.id == b.id;
--end

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