local Packet = SceneMachine.Network.Packets.Packet;
SceneMachine.Network.Packets.SceneData = {};
local SceneData = SceneMachine.Network.Packets.SceneData;
SceneData.__index = SceneData;
setmetatable(SceneData, Packet)

function SceneData:New(sceneData)
	local v = 
    {
        type = Packet.Type.SceneData;
        sceneData = sceneData,
    };

	setmetatable(v, SceneData);
	return v;
end