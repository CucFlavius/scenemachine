local Packet = SceneMachine.Network.Packets.Packet;
SceneMachine.Network.Packets.InvitationAccepted = {};

--- @class InvitationAccepted : Packet
local InvitationAccepted = SceneMachine.Network.Packets.InvitationAccepted;

InvitationAccepted.__index = InvitationAccepted;
setmetatable(InvitationAccepted, Packet)

--- Creates a new InvitationAccepted object.
--- @param playerName string The name of the player who accepted the invitation.
--- @return InvitationAccepted v The newly created InvitationAccepted object.
function InvitationAccepted:New(playerName)
    local v = 
    {
        type = Packet.Type.InvitationAccepted,
        playerName = playerName;
    };

    setmetatable(v, InvitationAccepted);
    return v;
end