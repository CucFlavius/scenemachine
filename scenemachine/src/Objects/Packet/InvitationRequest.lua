local Packet = SceneMachine.Network.Packets.Packet;
SceneMachine.Network.Packets.InvitationRequest = {};

--- @class InvitationRequest : Packet
local InvitationRequest = SceneMachine.Network.Packets.InvitationRequest;

InvitationRequest.__index = InvitationRequest;
setmetatable(InvitationRequest, Packet)

--- Creates a new InvitationRequest object.
--- @param playerName string The name of the player who accepted the invitation.
--- @return InvitationRequest v The newly created InvitationRequest object.
function InvitationRequest:New(playerName)
	local v = 
    {
        type = Packet.Type.InvitationRequest;
        playerName = playerName;
    };

	setmetatable(v, InvitationRequest);
	return v;
end