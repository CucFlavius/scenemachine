
SceneMachine.Network.Packets.Packet = 
{
    type = nil;
    data = nil;
}

local Net = SceneMachine.Network;
local Packet = SceneMachine.Network.Packets.Packet;

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

function Packet:New()
	local v = 
    {
        type = Packet.Type.None;
    };

	setmetatable(v, Packet)
	return v
end

function Packet:Serialize()
    local serialized = SceneMachine.Libs.LibSerialize:Serialize(self);
    if not serialized then return end
    local compressed = SceneMachine.Libs.LibDeflate:CompressDeflate(serialized)
    if not compressed then return end
    local addonChannelEncoded = SceneMachine.Libs.LibDeflate:EncodeForWoWAddonChannel(compressed);
    if not addonChannelEncoded then return end
    return addonChannelEncoded;
end

function Packet:Send(playerName)
    local data = self:Serialize();
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

Packet.__tostring = function(self)
	return string.format("Packet type:%i", self.type);
end

--Packet.__eq = function(a,b)
--    return a.x == b.x and a.y == b.y;
--end

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