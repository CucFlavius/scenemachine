local Win = ZWindowAPI;
local WHelpers = ZWindowAPI.Helpers;

function Win.CreateSlider (parent, name, title, minVal, maxVal, valStep)

    local backdropInfo =
    {
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
         edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
         tile = true,
         tileEdge = true,
         tileSize = 8,
         edgeSize = 8,
         insets = { left = 1, right = 1, top = 1, bottom = 1 },
    }


    local slider = CreateFrame("Slider", name, parent, "OptionsSliderTemplate")
    local editbox = Win.CreateEditBox(15, 0, 50, 20, slider, "LEFT", "RIGHT", slider:GetValue(), 9);
    --local editbox = CreateFrame("EditBox", "$parentEditBox", slider, "InputBoxTemplate")
    slider:SetMinMaxValues(minVal, maxVal)
    slider:SetValueStep(valStep)
    slider.text = _G[name.."Text"]
    slider.text:SetFont("Segoe UI.TTF", 9);
    slider.text:SetText(title)
    slider.text:SetJustifyV("CENTER");
	slider.text:SetJustifyH("LEFT");
    slider.textLow = _G[name.."Low"]
    slider.textHigh = _G[name.."High"]
    slider.textLow:SetText(floor(minVal))
    slider.textHigh:SetText(floor(maxVal))
    slider.textLow:SetFont("Segoe UI.TTF", 9);
    slider.textHigh:SetFont("Segoe UI.TTF", 9);
    slider.textLow:SetTextColor(0.4,0.4,0.4)
    slider.textHigh:SetTextColor(0.4,0.4,0.4)
    
    --slider:SetThumbTexture("interface/buttons/ui-sliderbar-button-horizontal");
    slider:SetThumbTexture(Win.textureResources["SliderThumb"]);
    --removed in 9.0--slider:SetBackdrop({ bgFile = "Interface\\Buttons\\grad1c", tile = false, tileSize = 1, edgeSize = 0, insets = { left = 15, right = 15, top = 7, bottom = 7 } });
    --editbox:SetSize(50,30)
    --editbox:ClearAllPoints()
    --editbox:SetPoint("LEFT", slider, "RIGHT", 15, 0)
    --editbox:SetText(slider:GetValue())
    editbox:SetAutoFocus(false);
    slider:SetScript("OnValueChanged", function(self,value)
        self.editbox:SetText(WHelpers.SimpleRound(value,valStep))
    end)
    editbox:SetScript("OnTextChanged", function(self)
        local val = self:GetText()
        if tonumber(val) then
            self:GetParent():SetValue(val)
        end
    end)
    editbox:SetScript("OnEnterPressed", function(self)
        local val = self:GetText()
        if tonumber(val) then
            self:GetParent():SetValue(val)
            self:ClearFocus()
        end
    end)
    slider.editbox = editbox
    return slider

end