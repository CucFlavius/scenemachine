local Packet = SceneMachine.Network.Packets.Packet;
SceneMachine.Network.Packets.InvitationAccepted = {};
local InvitationAccepted = SceneMachine.Network.Packets.InvitationAccepted;
InvitationAccepted.__index = InvitationAccepted;
setmetatable(InvitationAccepted, Packet)

function InvitationAccepted:New(playerName)
	local v = 
    {
        type = Packet.Type.InvitationAccepted,
        playerName = playerName;
    };

	setmetatable(v, InvitationAccepted);
	return v;
end