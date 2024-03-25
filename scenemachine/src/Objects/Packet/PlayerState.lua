local Packet = SceneMachine.Network.Packets.Packet;
SceneMachine.Network.Packets.PlayerState = {};

--- @class PlayerState : Packet
local PlayerState = SceneMachine.Network.Packets.PlayerState;

PlayerState.__index = PlayerState;
setmetatable(PlayerState, Packet)

--- Creates a new instance of the PlayerState class.
---@param playerName string The name of the player.
---@param x number The x-coordinate of the player's position.
---@param y number The y-coordinate of the player's position.
---@param z number The z-coordinate of the player's position.
---@param vx number The velocity along the x-axis.
---@param vy number The velocity along the y-axis.
---@param vz number The velocity along the z-axis.
---@param rx number The rotation around the x-axis.
---@param ry number The rotation around the y-axis.
---@param rz number The rotation around the z-axis.
---@param vrx number The rotational velocity around the x-axis.
---@param vry number The rotational velocity around the y-axis.
---@param vrz number The rotational velocity around the z-axis.
---@return PlayerState v The new instance of the PlayerState class.
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