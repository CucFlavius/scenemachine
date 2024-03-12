local Editor = SceneMachine.Editor;
local ColorPicker = Editor.ColorPicker;
local UI = SceneMachine.UI;
local Resources = SceneMachine.Resources;
local L = Editor.localization;

local saturationMax = 282;
local saturationMin = 84;
local lightnessMax = 264;
local lightnessMid = 150;
local lightnessMin = 36;

local function distance(x1, y1, x2, y2)
    return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end

local function pointInTriangle(px, py, p1x, p1y, p2x, p2y, p3x, p3y)
    local area = 0.5 * (-p2y * p3x + p1y * (-p2x + p3x) + p1x * (p2y - p3y) + p2x * p3y)
    local sign = area < 0 and -1 or 1
    local s = (p1y * p3x - p1x * p3y + (p3y - p1y) * px + (p1x - p3x) * py) * sign
    local t = (p1x * p2y - p1y * p2x + (p1y - p2y) * px + (p2x - p1x) * py) * sign

    return s > 0 and t > 0 and (s + t) < 2 * area * sign
end

local function closestPointOnEdge(px, py, p1x, p1y, p2x, p2y)
    local dx = p2x - p1x
    local dy = p2y - p1y
    local length = math.sqrt(dx^2 + dy^2)
    local nx = dx / length
    local ny = dy / length

    local t = math.max(0, math.min(1, ((px - p1x) * nx + (py - p1y) * ny) / length))

    local closestX = p1x + t * dx
    local closestY = p1y + t * dy

    return closestX, closestY
end

local function closestPointToTriangle(px, py, p1x, p1y, p2x, p2y, p3x, p3y)
    local insideTriangle = pointInTriangle(px, py, p1x, p1y, p2x, p2y, p3x, p3y)

    if insideTriangle then
        return px, py
    else
        local closestX, closestY
        local minDistance = math.huge

        local edgePoints = {
            { closestPointOnEdge(px, py, p1x, p1y, p2x, p2y) },
            { closestPointOnEdge(px, py, p2x, p2y, p3x, p3y) },
            { closestPointOnEdge(px, py, p3x, p3y, p1x, p1y) }
        }

        for _, point in ipairs(edgePoints) do
            local dist = distance(px, py, point[1], point[2])
            if dist < minDistance then
                minDistance = dist
                closestX, closestY = point[1], point[2]
            end
        end

        return closestX, closestY
    end
end

local function calculateAngle(cx, cy, x, y)
    -- Calculate the angle between the x-axis and the line joining the center of the circle and the clicked point
    local angle = math.atan2(y - cy, cx - x)
    angle = angle - math.rad(45);

    -- Convert the angle from radians to degrees
    local angleDegrees = math.deg(angle)
    
    -- Ensure the angle is within the range [0, 360)
    angleDegrees = angleDegrees % 360
    
    return angleDegrees
end

local function HueToRGB(h)
    local r, g, b
    
    local i = math.floor(h * 6)
    local f = h * 6 - i
    local p = 0;
    local q = 1 - f;
    local t = f;
    
    i = i % 6
    
    if i == 0 then r, g, b = 1, t, p
    elseif i == 1 then r, g, b = q, 1, p
    elseif i == 2 then r, g, b = p, 1, t
    elseif i == 3 then r, g, b = p, q, 1
    elseif i == 4 then r, g, b = t, p, 1
    elseif i == 5 then r, g, b = 1, p, q
    end
    
    return r, g, b
end

local function HSLtoRGB(h, s, l)
    local r, g, b

    local function hueToRGB(p, q, t)
        if t < 0 then t = t + 1 end
        if t > 1 then t = t - 1 end
        if t < 1/6 then return p + (q - p) * 6 * t end
        if t < 1/2 then return q end
        if t < 2/3 then return p + (q - p) * (2/3 - t) * 6 end
        return p
    end

    if s == 0 then
        r, g, b = l, l, l -- achromatic
    else
        local q = l < 0.5 and l * (1 + s) or l + s - l * s
        local p = 2 * l - q
        r = hueToRGB(p, q, h + 1/3)
        g = hueToRGB(p, q, h)
        b = hueToRGB(p, q, h - 1/3)
    end

    return r, g, b
end

local function RGBtoHSL(r, g, b)
    local vmax = math.max(r, g, b)
    local vmin = math.min(r, g, b)

    local h = (vmax + vmin) / 2.0;
    local s = (vmax + vmin) / 2.0;
    local l = (vmax + vmin) / 2.0;

    if (vmax == vmin) then
        return 0, 0, l; -- achromatic
    end

    local d = vmax - vmin;
    if (l > 0.5) then
        s = d / (2.0 - vmax - vmin);
    else
        s = d / (vmax + vmin)
    end

    if (vmax == r) then
        if (g < b) then
            h = (g - b) / d + 6.0;
        else
            h = (g - b) / d;
        end
    end
    if (vmax == g) then
        h = (b - r) / d + 2.0;
    end
    if (vmax == b) then
        h = (r - g) / d + 4.0;
    end

    h = h / 6.0;

    return h, s, l
end

local function calculatePointOnCircle(cx, cy, radius, angleDegrees)
    -- Convert the angle from degrees to radians
    local angleRadians = math.rad(angleDegrees) + math.rad(45);

    -- Calculate the coordinates of the point on the circle
    local pointX = cx - radius * math.cos(angleRadians)
    local pointY = cy + radius * math.sin(angleRadians)

    return pointX, pointY
end

local function calculateIntersection(x1, y1, x2, y2, x3, y3, x4, y4)
    -- Calculate slopes of both lines
    local slope1 = (y2 - y1) / (x2 - x1)
    local slope2 = (y4 - y3) / (x4 - x3)
    
    -- Check if the lines are parallel
    if slope1 == slope2 then
        return 0, 0 -- Lines are parallel, so they do not intersect
    end
    
    -- Calculate x-coordinate of the intersection point using the intersection formula
    local intersectionPoint_x = ((x1 * y2 - y1 * x2) * (x3 - x4) - (x1 - x2) * (x3 * y4 - y3 * x4)) /
                          ((x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4));
    
    -- Calculate y-coordinate of the intersection point using the x-coordinate
    local intersectionPoint_y = ((x1 * y2 - y1 * x2) * (y3 - y4) - (y1 - y2) * (x3 * y4 - y3 * x4)) /
                          ((x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4));
    
    return intersectionPoint_x, intersectionPoint_y;
end

local function normalizePointOnLine(x, y, x1, y1, x2, y2)
    -- Calculate the lengths of the line segments
    local totalLength = math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
    local distanceToPoint = math.sqrt((x - x1)^2 + (y - y1)^2)
    
    -- Calculate the normalized value
    local normalizedValue = distanceToPoint / totalLength
    
    return normalizedValue
end

function ColorPicker.Initialize(r, g, b)
    ColorPicker.enabled = false;
    ColorPicker.r = r;
    ColorPicker.g = g;
    ColorPicker.b = b;
    ColorPicker.hue, ColorPicker.saturation, ColorPicker.lightness = RGBtoHSL(ColorPicker.r, ColorPicker.g, ColorPicker.b);

    ColorPicker.window = UI.Window:New(0, 0, 350, 530, SceneMachine.mainWindow:GetFrame(),  "CENTER", "CENTER", L["COLP_WINDOW_TITLE"]);
    ColorPicker.window:MakeWholeWindowDraggable();
    ColorPicker.window:SetFrameStrata(Editor.SUB_FRAME_STRATA);
    ColorPicker.window:GetFrame():SetResizable(false);
    ColorPicker.window.resizeFrame:Hide();
    ColorPicker.window:SetFrameLevel(1);
    ColorPicker.window.closeButton:SetScript("OnClick", function() ColorPicker.Close(); end);

    ColorPicker.circleGroup = UI.Rectangle:New(25, -25, 300, 300, ColorPicker.window:GetFrame(), "TOPLEFT", "TOPLEFT", 0, 0, 0, 0);
    ColorPicker.circleGroup:SetFrameLevel(2);

    ColorPicker.circle = CreateFrame("Button", "ColorPicker.circle", ColorPicker.circleGroup:GetFrame())
	ColorPicker.circle:SetPoint("TOPLEFT", ColorPicker.circleGroup:GetFrame(), "TOPLEFT", 0, 0);
    ColorPicker.circle:SetPoint("BOTTOMRIGHT", ColorPicker.circleGroup:GetFrame(), "BOTTOMRIGHT", 0, 0);
    ColorPicker.circle.ntex = ColorPicker.circle:CreateTexture();
    ColorPicker.circle.ntex:SetTexture(Resources.textures["ColorPicker"]);
    ColorPicker.circle.ntex:SetTexCoord(0, 0.5, 0, 0.5);
    --element.ntex:SetTexCoord(0, 0.5, 0, 0.5);    -- (left,right,top,bottom)
    ColorPicker.circle.ntex:SetAllPoints();
    ColorPicker.circle:SetNormalTexture(ColorPicker.circle.ntex);
    ColorPicker.circle:SetFrameLevel(5);
    ColorPicker.circle:RegisterForClicks("LeftButtonUp", "LeftButtonDown");
    ColorPicker.circle:SetScript("OnMouseDown", function(self, button)
        local scale = ColorPicker.circle:GetEffectiveScale();
        local frameXMin = ColorPicker.circle:GetLeft();
        local frameYMin = ColorPicker.circle:GetBottom();

        local x, y = GetCursorPosition();
        local relativeX, relativeY = (x / scale) - frameXMin, (y / scale) - frameYMin;

        local radius = ColorPicker.circle:GetWidth() / 2;
        local cx = radius;
        local cy = radius;
        
        -- determine if within radius
        local dist = math.sqrt(math.pow((cx - (relativeX)), 2) + math.pow((cy - (relativeY)), 2));
        if (dist > 130 and dist < 150) then
            ColorPicker.circleInteract = true;
        elseif (dist < 130) then
            ColorPicker.triangleInteract = pointInTriangle(relativeX, relativeY, saturationMin, lightnessMin, saturationMin, lightnessMax, saturationMax, lightnessMid);
        end
    end);
    ColorPicker.circle:SetScript("OnMouseUp", function(self, button)
        ColorPicker.circleInteract = false;
        ColorPicker.triangleInteract = false
    end);

    ColorPicker.circleDot = UI.ImageBox:New(0, 0, 20, 20, ColorPicker.circle, "CENTER", "CENTER", Resources.textures["ColorPicker"], { 0.5, 0.5 + 0.0625, 0.5, 0.5 + 0.0625 });
    ColorPicker.circleDot:SetFrameLevel(10);

    ColorPicker.triangleDot = UI.ImageBox:New(0, 0, 20, 20, ColorPicker.circle, "CENTER", "CENTER", Resources.textures["ColorPicker"], { 0.5 + 0.0625, 0.5 + 0.125, 0.5, 0.5 + 0.0625 });
    ColorPicker.triangleDot:SetFrameLevel(10);

    ColorPicker.triangleColor = UI.ImageBox:New(0, 0, 1, 1, ColorPicker.circleGroup:GetFrame(), "TOPLEFT", "TOPLEFT", Resources.textures["ColorPicker"], { 0.5, 1.0, 0, 0.5 });
    ColorPicker.triangleColor:SetPoint("BOTTOMRIGHT", ColorPicker.circleGroup:GetFrame(), "BOTTOMRIGHT", 0, 1.1);
    ColorPicker.triangleColor:SetFrameLevel(4);
    ColorPicker.triangleColor:SetVertexColor(0, 0, 1, 1);

    ColorPicker.triangleLight = UI.ImageBox:New(0, 0, 1, 1, ColorPicker.circleGroup:GetFrame(), "CENTER", "CENTER", Resources.textures["ColorPicker"], { 0, 0.5, 0.5, 1 });
    ColorPicker.triangleLight:SetAllPoints(ColorPicker.circleGroup:GetFrame());
    ColorPicker.triangleLight:SetFrameLevel(6);

    ColorPicker.triangleDark = UI.ImageBox:New(0, 0, 1, 1, ColorPicker.circleGroup:GetFrame(), "CENTER", "CENTER", Resources.textures["ColorPicker"], { 0, 0.5, 1, 0.5 });
    ColorPicker.triangleDark:SetAllPoints(ColorPicker.circleGroup:GetFrame());
    ColorPicker.triangleDark:SetVertexColor(0, 0, 0, 1);
    ColorPicker.triangleDark:SetFrameLevel(7);

    ColorPicker.colorBox = UI.Rectangle:New(0, 0, 40, 40, ColorPicker.circleGroup:GetFrame(), "BOTTOMLEFT", "BOTTOMLEFT", 1, 1, 1, 1);
    ColorPicker.colorBox:SetFrameLevel(8);

    ColorPicker.window:Hide();

    local width = 240;
    
    local infoTextRGB = UI.Label:New(25, -350, 300, 20, ColorPicker.window:GetFrame(), "TOPLEFT", "TOPLEFT", L["COLP_RGB_NAME"]);

    ColorPicker.redScroll = ColorPicker.BuildSlider(25, -370, 300, 20, ColorPicker.window:GetFrame(), 8, "  " .. L["COLP_R"],
    function(value)
        ColorPicker.r = value;
        ColorPicker.hue, ColorPicker.saturation, ColorPicker.lightness = RGBtoHSL(ColorPicker.r, ColorPicker.g, ColorPicker.b);
        ColorPicker.RefreshCircle();
        ColorPicker.RefreshTriangle();
        ColorPicker.RefreshColorBox();
        ColorPicker.RefreshSliders();
    end,
    function(value)
        value = math.max(0, math.min(255, value));
        local valueNorm = value / 255;
        ColorPicker.redScroll.onValueChange(valueNorm);
    end);
    ColorPicker.redScroll.ntex:SetColorTexture(1, 1, 1, 1);
    ColorPicker.redScroll_Min = UI.ImageBox:New(0, 0, width, 10, ColorPicker.redScroll, "LEFT", "LEFT",
                                Resources.textures["ColorPicker"], { 0.5, 1.0, 0.5 + 0.09375, 0.5 + 0.125 });
    ColorPicker.redScroll_Min:SetFrameLevel(12);
    ColorPicker.redScroll_Max = UI.ImageBox:New(0, 0, width, 10, ColorPicker.redScroll, "LEFT", "LEFT",
                                Resources.textures["ColorPicker"], { 1, 0.5, 0.5 + 0.09375, 0.5 + 0.125 });
    ColorPicker.redScroll_Max:SetFrameLevel(11);

    ColorPicker.greenScroll = ColorPicker.BuildSlider(25, -390, 300, 20, ColorPicker.window:GetFrame(), 8, "  " .. L["COLP_G"],
    function(value)
        ColorPicker.g = value;
        ColorPicker.hue, ColorPicker.saturation, ColorPicker.lightness = RGBtoHSL(ColorPicker.r, ColorPicker.g, ColorPicker.b);
        ColorPicker.RefreshCircle();
        ColorPicker.RefreshTriangle();
        ColorPicker.RefreshColorBox();
        ColorPicker.RefreshSliders();
    end,
    function(value)
        value = math.max(0, math.min(255, value));
        local valueNorm = value / 255;
        ColorPicker.greenScroll.onValueChange(valueNorm);
    end);
    ColorPicker.greenScroll.ntex:SetColorTexture(1, 1, 1, 1);
    ColorPicker.greenScroll_Min = UI.ImageBox:New(0, 0, width, 10, ColorPicker.greenScroll, "LEFT", "LEFT",
                                Resources.textures["ColorPicker"], { 0.5, 1.0, 0.5 + 0.09375, 0.5 + 0.125 });
    ColorPicker.greenScroll_Min:SetFrameLevel(12);
    ColorPicker.greenScroll_Max = UI.ImageBox:New(0, 0, width, 10, ColorPicker.greenScroll, "LEFT", "LEFT",
                                Resources.textures["ColorPicker"], { 1, 0.5, 0.5 + 0.09375, 0.5 + 0.125 });
    ColorPicker.greenScroll_Max:SetFrameLevel(11);

    ColorPicker.blueScroll = ColorPicker.BuildSlider(25, -410, 300, 20, ColorPicker.window:GetFrame(), 8, "  " .. L["COLP_B"],
    function(value)
        ColorPicker.b = value;
        ColorPicker.hue, ColorPicker.saturation, ColorPicker.lightness = RGBtoHSL(ColorPicker.r, ColorPicker.g, ColorPicker.b);
        ColorPicker.RefreshCircle();
        ColorPicker.RefreshTriangle();
        ColorPicker.RefreshColorBox();
        ColorPicker.RefreshSliders();
    end,
    function(value)
        value = math.max(0, math.min(255, value));
        local valueNorm = value / 255;
        ColorPicker.blueScroll.onValueChange(valueNorm);
    end);
    ColorPicker.blueScroll.ntex:SetColorTexture(1, 1, 1, 1);
    ColorPicker.blueScroll_Min = UI.ImageBox:New(0, 0, width, 10, ColorPicker.blueScroll, "LEFT", "LEFT",
                                Resources.textures["ColorPicker"], { 0.5, 1.0, 0.5 + 0.09375, 0.5 + 0.125 });
    ColorPicker.blueScroll_Min:SetFrameLevel(12);
    ColorPicker.blueScroll_Max = UI.ImageBox:New(0, 0, width, 10, ColorPicker.blueScroll, "LEFT", "LEFT",
                                Resources.textures["ColorPicker"], { 1, 0.5, 0.5 + 0.09375, 0.5 + 0.125 });
    ColorPicker.blueScroll_Max:SetFrameLevel(11);

    local infoTextHSL = UI.Label:New(25, -430, 300, 20, ColorPicker.window:GetFrame(), "TOPLEFT", "TOPLEFT", L["COLP_HSL_NAME"]);

    -- Hue --
    ColorPicker.hueScroll = ColorPicker.BuildSlider(25, -450, 300, 20, ColorPicker.window:GetFrame(), 8, "  " .. L["COLP_H"],
    function(value)
        ColorPicker.hue = value;
        ColorPicker.r, ColorPicker.g, ColorPicker.b = HSLtoRGB(ColorPicker.hue, ColorPicker.saturation, ColorPicker.lightness);
        ColorPicker.RefreshCircle();
        ColorPicker.RefreshTriangle();
        ColorPicker.RefreshColorBox();
        ColorPicker.RefreshSliders();
    end,
    function(value)
        value = math.max(0, math.min(360, value));
        local valueNorm = value / 360;
        ColorPicker.hueScroll.onValueChange(valueNorm);
    end);
    ColorPicker.hueScroll_H =   UI.ImageBox:New(0, 0, width, 10, ColorPicker.hueScroll, "LEFT", "LEFT",
                                Resources.textures["ColorPicker"], { 0.5, 1, 0.5 + 0.0625, 0.5 + 0.09375 });
    ColorPicker.hueScroll_H:SetFrameLevel(9);
    ColorPicker.hueScroll_S =   UI.Rectangle:New(0, 0, width, 10, ColorPicker.hueScroll, "LEFT", "LEFT", 0.5, 0.5, 0.5, 1);
    ColorPicker.hueScroll_S:SetAlpha(0);
    ColorPicker.hueScroll_S:SetFrameLevel(10);
    ColorPicker.hueScroll_L =   UI.Rectangle:New(0, 0, width, 10, ColorPicker.hueScroll, "LEFT", "LEFT", 1, 1, 1, 1);
    ColorPicker.hueScroll_L:SetAlpha(0);
    ColorPicker.hueScroll_L:SetFrameLevel(11);
    ColorPicker.hueScroll_D =   UI.Rectangle:New(0, 0, width, 10, ColorPicker.hueScroll, "LEFT", "LEFT", 0, 0, 0, 1);
    ColorPicker.hueScroll_D:SetAlpha(0);
    ColorPicker.hueScroll_D:SetFrameLevel(12);

    -- Saturation --
    ColorPicker.saturationScroll = ColorPicker.BuildSlider(25, -470, 300, 20, ColorPicker.window:GetFrame(), 8, "  " .. L["COLP_S"],
    function(value)
        ColorPicker.saturation = value;
        ColorPicker.r, ColorPicker.g, ColorPicker.b = HSLtoRGB(ColorPicker.hue, ColorPicker.saturation, ColorPicker.lightness);
        ColorPicker.RefreshTriangle();
        ColorPicker.RefreshColorBox();
        ColorPicker.RefreshSliders();
    end,
    function(value)
        value = math.max(0, math.min(100, value));
        local valueNorm = value / 100;
        ColorPicker.saturationScroll.onValueChange(valueNorm);
    end);
    ColorPicker.saturationScroll.ntex:SetColorTexture(0.5, 0.5, 0.5, 1);
    ColorPicker.saturationScroll_C =    UI.ImageBox:New(0, 0, width, 10, ColorPicker.saturationScroll, "LEFT", "LEFT",
                                        Resources.textures["ColorPicker"], { 1, 0.5, 0.5 + 0.09375, 0.5 + 0.125 });
    ColorPicker.saturationScroll_C:SetFrameLevel(11);
    ColorPicker.saturationScroll_L =   UI.Rectangle:New(0, 0, width, 10, ColorPicker.saturationScroll, "LEFT", "LEFT", 1, 1, 1, 1);
    ColorPicker.saturationScroll_L:SetAlpha(0);
    ColorPicker.saturationScroll_L:SetFrameLevel(12);
    ColorPicker.saturationScroll_D =   UI.Rectangle:New(0, 0, width, 10, ColorPicker.saturationScroll, "LEFT", "LEFT", 0, 0, 0, 1);
    ColorPicker.saturationScroll_D:SetAlpha(0);
    ColorPicker.saturationScroll_D:SetFrameLevel(13);

    -- Lightness --
    ColorPicker.lightnessScroll = ColorPicker.BuildSlider(25, -490, 300, 20, ColorPicker.window:GetFrame(), 8, "  " .. L["COLP_L"],
    function(value)
        ColorPicker.lightness = value;
        ColorPicker.r, ColorPicker.g, ColorPicker.b = HSLtoRGB(ColorPicker.hue, ColorPicker.saturation, ColorPicker.lightness);
        ColorPicker.RefreshTriangle();
        ColorPicker.RefreshColorBox();
        ColorPicker.RefreshSliders();
    end,
    function(value)
        value = math.max(0, math.min(100, value));
        local valueNorm = value / 100;
        ColorPicker.lightnessScroll.onValueChange(valueNorm);
    end);
    ColorPicker.lightnessScroll_C = UI.Rectangle:New(0, 0, width, 10, ColorPicker.lightnessScroll, "LEFT", "LEFT", 1, 1, 1, 1);
    ColorPicker.lightnessScroll_L = UI.ImageBox:New(width / 2, 0, width / 2, 10, ColorPicker.lightnessScroll, "LEFT", "LEFT",
                                    Resources.textures["ColorPicker"], { 1, 0.5, 0.5 + 0.09375, 0.5 + 0.125 });
    ColorPicker.lightnessScroll_L:SetFrameLevel(10);
    ColorPicker.lightnessScroll_D = UI.ImageBox:New(0, 0, width / 2, 10, ColorPicker.lightnessScroll, "LEFT", "LEFT",
                                    Resources.textures["ColorPicker"], { 0.5, 1.0, 0.5 + 0.09375, 0.5 + 0.125 });
    ColorPicker.lightnessScroll_D:SetFrameLevel(11);
    ColorPicker.lightnessScroll_D:SetVertexColor(0, 0, 0, 1);
    ColorPicker.lightnessScroll_S =   UI.Rectangle:New(0, 0, width, 10, ColorPicker.lightnessScroll, "LEFT", "LEFT", 0.5, 0.5, 0.5, 1);
    ColorPicker.lightnessScroll_S:SetAlpha(0);
    ColorPicker.lightnessScroll_S:SetFrameLevel(9);

    ColorPicker.RefreshCircle();
    ColorPicker.RefreshTriangle();
    ColorPicker.RefreshColorBox();
    ColorPicker.RefreshSliders();
end

function ColorPicker.Open(r, g, b, a, onColorChanged, onStartAction, onFinishAction)
    ColorPicker.Close();
    ColorPicker.enabled = true;
    ColorPicker.window:Show();

    if (onStartAction) then
        onStartAction();
        onStartAction = nil;
    end
    ColorPicker.onFinishAction = onFinishAction;

    ColorPicker.r = r;
    ColorPicker.g = g;
    ColorPicker.b = b;
    ColorPicker.a = a;
    ColorPicker.hue, ColorPicker.saturation, ColorPicker.lightness = RGBtoHSL(ColorPicker.r, ColorPicker.g, ColorPicker.b);

    ColorPicker.RefreshCircle();
    ColorPicker.RefreshTriangle();
    ColorPicker.RefreshColorBox();
    ColorPicker.RefreshSliders();
    
    ColorPicker.onColorChanged = onColorChanged;
end

function ColorPicker.Close()
    ColorPicker.enabled = false;
    ColorPicker.window:Hide();

    if (ColorPicker.onFinishAction) then
        ColorPicker.onFinishAction();
        ColorPicker.onFinishAction = nil;
    end

    ColorPicker.onColorChanged = nil;
end

function ColorPicker.BuildSlider(x, y, w, h, parent, startLevel, text, onValueChange, onEditBoxValueChange)
    local sliderGroup = UI.Rectangle:New(x, y, w, h, parent, "TOPLEFT", "TOPLEFT", 0, 0, 0, 0);
    sliderGroup:SetFrameLevel(startLevel);

    local label = UI.Label:New(0, 0, 20, 20, sliderGroup:GetFrame(), "LEFT", "LEFT", text);
    label:SetFrameLevel(startLevel + 1);

    local slider = CreateFrame("Button", "slider", sliderGroup:GetFrame())
	slider:SetPoint("LEFT", sliderGroup:GetFrame(), "LEFT", 20, 0);
    slider:SetPoint("RIGHT", sliderGroup:GetFrame(), "RIGHT", -40, 0);
    slider:SetHeight(10);
    slider.ntex = slider:CreateTexture();
    slider.ntex:SetColorTexture(1,1,1,0.1);
    slider.ntex:SetAllPoints();
    slider:SetNormalTexture(slider.ntex);
    slider:SetFrameLevel(startLevel + 2);
    slider:RegisterForClicks("LeftButtonUp", "LeftButtonDown");
    slider:SetScript("OnMouseDown", function(self, button)
        ColorPicker.sliderInteract = slider;
    end);
    slider:SetScript("OnMouseUp", function(self, button)
        ColorPicker.sliderInteract = nil;
    end);

    slider.bar = UI.ImageBox:New(0, 0, 20, 20, slider, "CENTER", "CENTER", Resources.textures["ColorPicker"], { 0.5, 0.5 + 0.0625, 0.5, 0.5 + 0.0625 });
    slider.bar:SetFrameLevel(startLevel + 10);
    slider.onValueChange = onValueChange;

    slider.editBox = UI.TextBox:New(0, 0, 30, 20, sliderGroup:GetFrame(), "RIGHT", "RIGHT", "0");
    slider.editBox:SetScript('OnEnterPressed', function(self)
        -- set value
        local valText = self:GetText();
        if (valText == nil or valText == "") then
            return;
        end
        local val = tonumber(valText);
        if (val ~= nil) then
            if (onEditBoxValueChange) then
                onEditBoxValueChange(val);
            end
        end
        self:ClearFocus();
        Editor.ui.focused = false;
    end);

    return slider;
end

function ColorPicker.Update()
    if (ColorPicker.circleInteract) then
        local scale = ColorPicker.circle:GetEffectiveScale();
        local frameXMin = ColorPicker.circle:GetLeft();
        local frameYMin = ColorPicker.circle:GetBottom();

        local x, y = GetCursorPosition();
        local relativeX, relativeY = (x / scale) - frameXMin, (y / scale) - frameYMin;

        local radius = ColorPicker.circle:GetWidth() / 2;
        local cx = radius;
        local cy = radius;

        local angleDeg = calculateAngle(cx, cy, relativeX, relativeY);
        local h = angleDeg / 360;
        --local s = 1 -- For full saturation
        --local v = 1 -- For full value
        
        local pointX, pointY = calculatePointOnCircle(cx, cy, radius - 8.5, angleDeg);

        ColorPicker.circleDot:SetSinglePoint("BOTTOMLEFT", pointX - 10, pointY - 10);
        ColorPicker.circleDot.frame.texture:SetRotation(math.rad(-angleDeg + 45));

        ColorPicker.hue = h;
        ColorPicker.r, ColorPicker.g, ColorPicker.b = HSLtoRGB(ColorPicker.hue, ColorPicker.saturation, ColorPicker.lightness);
        
        local r, g, b = HueToRGB(h);
        ColorPicker.triangleColor:SetVertexColor(r, g, b, 1);

        ColorPicker.RefreshColorBox();
        ColorPicker.RefreshSliders();
    end

    if (ColorPicker.triangleInteract) then
        local scale = ColorPicker.circle:GetEffectiveScale();
        local frameXMin = ColorPicker.circle:GetLeft();
        local frameYMin = ColorPicker.circle:GetBottom();

        local x, y = GetCursorPosition();
        local relativeX, relativeY = (x / scale) - frameXMin, (y / scale) - frameYMin;
        local closestX, closestY = closestPointToTriangle(relativeX, relativeY, saturationMin, lightnessMin, saturationMin, lightnessMax, saturationMax, lightnessMid);

        -- calculate a point on the triangle > lines based on vertical position
        local x1 = closestX - 1000;
        local y1 = closestY;
        local x2 = closestX + 1000;
        local y2 = closestY;
        local x3 = 0;
        local y3 = 0;
        local x4 = saturationMax;
        local y4 = lightnessMid;
        if (closestY >= lightnessMid) then
            -- |¯¯
            x3 = saturationMin;
            y3 = lightnessMax;
        elseif (closestY < lightnessMid) then
            -- |__
            x3 = saturationMin;
            y3 = lightnessMin;
        end

        local ix, iy = calculateIntersection(x1, y1, x2, y2, x3, y3, x4, y4);
        ColorPicker.saturation = (closestX - saturationMin) / (ix - saturationMin);

        -- calculate a point on the mid ---- line of the triangle
        x1 = saturationMin;
        y1 = lightnessMid;
        x2 = saturationMax;
        y2 = lightnessMid;
        x4 = closestX;
        y4 = closestY;
        local i2x, i2y = calculateIntersection(x1, y1, x2, y2, x3, y3, x4, y4);

        local t = normalizePointOnLine(closestX, closestY, x3, y3, i2x, i2y);
        if (closestY >= lightnessMid) then
            -- |¯¯
            t = ((1.0 - t) / 2) + 0.5;
        elseif (closestY < lightnessMid) then
            -- |__
            t = t / 2;
        end

        ColorPicker.lightness = t;
        ColorPicker.r, ColorPicker.g, ColorPicker.b = HSLtoRGB(ColorPicker.hue, ColorPicker.saturation, ColorPicker.lightness);

        ColorPicker.triangleDot:SetSinglePoint("BOTTOMLEFT", closestX - 10, closestY - 10);
        ColorPicker.RefreshColorBox();
        ColorPicker.RefreshSliders();
    end

    if (ColorPicker.sliderInteract) then
        local scale = ColorPicker.circle:GetEffectiveScale();
        local frameXMin = ColorPicker.sliderInteract:GetLeft();
        local x, y = GetCursorPosition();
        local relativeX = (x / scale) - frameXMin;
        local w = ColorPicker.sliderInteract:GetWidth();
        local normalized = relativeX / w;
        normalized = math.max(0.0, math.min(1.0, normalized));
        ColorPicker.sliderInteract.bar:SetSinglePoint("LEFT", (normalized * w) - 10, 0);
        if (ColorPicker.sliderInteract.onValueChange) then
            ColorPicker.sliderInteract.onValueChange(normalized);
        end
    end
end

function ColorPicker.RefreshColorBox()
    ColorPicker.colorBox.frame.texture:SetVertexColor(ColorPicker.r, ColorPicker.g, ColorPicker.b, 1);

    if (ColorPicker.onColorChanged) then
        ColorPicker.onColorChanged(ColorPicker.r, ColorPicker.g, ColorPicker.b, 1);
    end
end

function ColorPicker.RefreshTriangle()
    local r, g, b = HueToRGB(ColorPicker.hue);
    ColorPicker.triangleColor:SetVertexColor(r, g, b, 1);

    local saturationPoint = saturationMin + (saturationMax - saturationMin) * ColorPicker.saturation;

    local x = 0;
    local y = 0;
    local p1x = 0;
    local p1y = 0;
    local p0x = 0;
    local p0y = 0;
    local t = ColorPicker.lightness;
    if (t < 0.5) then
        -- |__
        p1x = saturationPoint;
        p1y = lightnessMid;
        p0x = saturationMin;
        p0y = lightnessMin;
        t = t * 2;
    elseif (t >= 0.5) then
        -- |¯¯
        p0x = saturationPoint;
        p0y = lightnessMid;
        p1x = saturationMin;
        p1y = lightnessMax;
        t = (t - 0.5) * 2;
    end

    x = p0x + (p1x - p0x) * t;
    y = p0y + (p1y - p0y) * t;

    ColorPicker.triangleDot:SetSinglePoint("BOTTOMLEFT", x - 10, y - 10);
end

function ColorPicker.RefreshCircle()
    local radius = ColorPicker.circle:GetWidth() / 2;
    local cx = radius;
    local cy = radius;
    local angleDeg = ColorPicker.hue * 360;
    local pointX, pointY = calculatePointOnCircle(cx, cy, radius - 8.5, angleDeg);
    ColorPicker.circleDot:SetSinglePoint("BOTTOMLEFT", pointX - 10, pointY - 10);
    ColorPicker.circleDot.frame.texture:SetRotation(math.rad(-angleDeg + 45));
end

function ColorPicker.RefreshSliders()
    local w = ColorPicker.redScroll:GetWidth();
    local saturationInv = 1.0 - ColorPicker.saturation;
    saturationInv = math.max(0.0, math.min(1.0, saturationInv));
    local r, g, b = HueToRGB(ColorPicker.hue);  -- nonsaturated, notlit

    ColorPicker.redScroll.bar:SetSinglePoint("LEFT", (ColorPicker.r * w) - 10, 0);
    ColorPicker.redScroll_Min:SetVertexColor(0, ColorPicker.g, ColorPicker.b, 1);
    ColorPicker.redScroll_Max:SetVertexColor(1, ColorPicker.g, ColorPicker.b, 1);
    ColorPicker.redScroll.editBox:SetText(tostring(math.ceil(ColorPicker.r * 255)));

    ColorPicker.greenScroll.bar:SetSinglePoint("LEFT", (ColorPicker.g * w) - 10, 0);
    ColorPicker.greenScroll_Min:SetVertexColor(ColorPicker.r, 0, ColorPicker.b, 1);
    ColorPicker.greenScroll_Max:SetVertexColor(ColorPicker.r, 1, ColorPicker.b, 1);
    ColorPicker.greenScroll.editBox:SetText(tostring(math.ceil(ColorPicker.g * 255)));

    ColorPicker.blueScroll.bar:SetSinglePoint("LEFT", (ColorPicker.b * w) - 10, 0);
    ColorPicker.blueScroll_Min:SetVertexColor(ColorPicker.r, ColorPicker.g, 0, 1);
    ColorPicker.blueScroll_Max:SetVertexColor(ColorPicker.r, ColorPicker.g, 1, 1);
    ColorPicker.blueScroll.editBox:SetText(tostring(math.ceil(ColorPicker.b * 255)));

    ColorPicker.hueScroll.bar:SetSinglePoint("LEFT", (ColorPicker.hue * w) - 10, 0);
    ColorPicker.hueScroll_S:SetAlpha(saturationInv);
    if (ColorPicker.lightness >= 0.5) then
        ColorPicker.hueScroll_L:SetAlpha((ColorPicker.lightness - 0.5) * 2);
        ColorPicker.hueScroll_D:SetAlpha(0);
        ColorPicker.saturationScroll_L:SetAlpha((ColorPicker.lightness - 0.5) * 2);
        ColorPicker.saturationScroll_D:SetAlpha(0);
    else
        ColorPicker.hueScroll_L:SetAlpha(0);
        ColorPicker.hueScroll_D:SetAlpha(1.0 - (ColorPicker.lightness * 2));
        ColorPicker.saturationScroll_L:SetAlpha(0);
        ColorPicker.saturationScroll_D:SetAlpha(1.0 - (ColorPicker.lightness * 2));
    end
    ColorPicker.hueScroll.editBox:SetText(tostring(math.ceil(ColorPicker.hue * 360)));

    ColorPicker.saturationScroll.bar:SetSinglePoint("LEFT", (ColorPicker.saturation * w) - 10, 0);
    ColorPicker.saturationScroll_C:SetVertexColor(r, g, b, 1);
    ColorPicker.saturationScroll.editBox:SetText(tostring(math.ceil(ColorPicker.saturation * 100)));

    ColorPicker.lightnessScroll.bar:SetSinglePoint("LEFT", (ColorPicker.lightness * w) - 10, 0);
    ColorPicker.lightnessScroll_C.frame.texture:SetVertexColor(r, g, b, 1);
    ColorPicker.lightnessScroll_S:SetAlpha(saturationInv);
    ColorPicker.lightnessScroll.editBox:SetText(tostring(math.ceil(ColorPicker.lightness * 100)));
end