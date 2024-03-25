
SceneMachine.Network.Packets.Packet = 
{
    type = nil;
    data = nil;
}

local Net = SceneMachine.Network;

--- @class Packet
local Packet = SceneMachine.Network.Packets.Packet;

--- @enum Packet.Type
Packet.Type = {
    None = 0,
    InvitationRequest = 1,
    InvitationAccepted = 2,
    SceneData = 3,
    ReadyToWork = 4,
    PlayerState = 5,
}

Packet.HeaderSize = 12;
Packet.MaxSize = 255 - Packet.HeaderSize;

setmetatable(Packet, Packet)

local fields = {}

--- Creates a new Packet object.
--- @return Packet v The newly created Packet object.
function Packet:New()
    local v = 
    {
        type = Packet.Type.None;
    };

    setmetatable(v, Packet)
    return v
end

--- Serializes the Packet object.
--- @return string? The serialized and compressed packet data.
function Packet:Serialize()
    local serialized = SceneMachine.Libs.LibSerialize:Serialize(self);
    if not serialized then return nil end
    local compressed = SceneMachine.Libs.LibDeflate:CompressDeflate(serialized)
    if not compressed then return nil end
    local addonChannelEncoded = SceneMachine.Libs.LibDeflate:EncodeForWoWAddonChannel(compressed);
    if not addonChannelEncoded then return nil end
    return addonChannelEncoded;
end

--- Sends the packet data to a specific player.
--- @param playerName string The name of the player to send the packet to.
function Packet:Send(playerName)
    local data = self:Serialize();
    if (not data) then return end

    local packetID = Net.GeneratePacketID();

    if (string.len(data) < Packet.MaxSize) then
        local finalData = string.format("%s%.2d%.2d%s", packetID, 0, 0, data);
        ChatThrottleLib:SendAddonMessage("NORMAL", SceneMachine.prefix, finalData, "WHISPER", playerName);
    else
        local splitData = Net.SplitPacketDataByChunk(data, Packet.MaxSize);
        for i = 1, #splitData, 1 do
            local part = i;
            local totalParts = #splitData;
            local finalData = string.format("%s%.2d%.2d%s", packetID, part, totalParts, splitData[i]);
            ChatThrottleLib:SendAddonMessage("NORMAL", SceneMachine.prefix, finalData, "WHISPER", playerName);
        end
    end
end

-- Returns a string representation of the Packet.
--- @return string: A string representation of the packet.
Packet.__tostring = function(self)
    return string.format("Packet type:%i", self.type);
end

-- This function is used as the __index metamethod for the Packet table.
-- It is called when a key is not found in the Packet table.
Packet.__index = function(t,k)
	local var = rawget(Packet, k)
		
	if var == nil then							
		var = rawget(fields, k)
		
		if var ~= nil then
			return var(t)	
		end
	end
	
	return var
end