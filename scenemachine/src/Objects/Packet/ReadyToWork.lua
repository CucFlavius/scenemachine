local Packet = SceneMachine.Network.Packets.Packet;
SceneMachine.Network.Packets.ReadyToWork = {};
local ReadyToWork = SceneMachine.Network.Packets.ReadyToWork;
ReadyToWork.__index = ReadyToWork;
setmetatable(ReadyToWork, Packet)

function ReadyToWork:New(playerName)
	local v = 
    {
        type = Packet.Type.ReadyToWork;
        playerName = playerName;
    };

	setmetatable(v, ReadyToWork);
	return v;
end