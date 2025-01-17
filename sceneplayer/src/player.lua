
-- Create the renderer
local window = SceneMachine.UI.Window:New(0, 0, 640, 480, UIParent,  "CENTER", "CENTER", "Player");
local renderer = SceneMachine.Renderer.CreateRenderer(0, 0, 640, 480, window:GetFrame());