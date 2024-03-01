local Packet = SceneMachine.Network.Packets.Packet;
SceneMachine.Network.Packets.PlayerState = {};
local PlayerState = SceneMachine.Network.Packets.PlayerState;
PlayerState.__index = PlayerState;
setmetatable(PlayerState, Packet)

function PlayerState:New(playerName, x, y, z, vx, vy, vz, rx, ry, rz, vrx, vry, vrz)
	local v = 
    {
        type = Packet.Type.PlayerState;
        playerName = playerName;
        x = x;
        y = y;
        z = z;
        vx = vx;
        vy = vy;
        vz = vz;
        rx = rx;
        ry = ry;
        rz = rz;
        vrx = vrx;
        vry = vry;
        vrz = vrz;
    };

	setmetatable(v, PlayerState);
	return v;
end