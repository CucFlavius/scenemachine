local Packet = SceneMachine.Network.Packets.Packet;
SceneMachine.Network.Packets.InvitationRequest = {};
local InvitationRequest = SceneMachine.Network.Packets.InvitationRequest;
InvitationRequest.__index = InvitationRequest;
setmetatable(InvitationRequest, Packet)

function InvitationRequest:New(playerName)
	local v = 
    {
        type = Packet.Type.InvitationRequest;
        playerName = playerName;
    };

	setmetatable(v, InvitationRequest);
	return v;
end