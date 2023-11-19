-------------------------- Zee's Window API ---------------------------
-- Developed it for use in my addons, but feel free to use in yours ---
-----------------------------------------------------------------------

-- Collapsable Box --
local Win = ZWindowAPI;

function Win.CreateCollapsableList(posX, posY, sizeX, sizesY, parent, windowPoint, parentPoint, titles, R, G, B, A)
    local bars = {};
    for c = 1, #titles, 1 do
        bars[c] = Win.CreateCollapsableBox(posX, y, sizeX, sizesY[c], parent, windowPoint, parentPoint, titles[c], R, G, B, A, bars)
    end

    Win.SortCollapsableBoxes(bars);

    return bars;
end

function Win.CreateCollapsableBox(posX, posY, sizeX, sizeY, parent, windowPoint, parentPoint, title, R, G, B, A, list)
    local bar = Win.CreateButton(0, 0, sizeX, 12, parent, "TOP", "TOP", title);
    bar.isCollapsed = false;
    bar.text:SetJustifyH("CENTER");
    bar.text:SetFont(Win.defaultFont, 9, "NORMAL");
    bar.list = list;
    bar.parent = parent;
    bar.posX = posX;
    bar:SetScript("OnClick", function (self, button, down)
        self.isCollapsed = not self.isCollapsed;
        if (self.isCollapsed) then
            self.panel:Hide();
            Win.SortCollapsableBoxes(self.list);
        else
            self.panel:Show();
            Win.SortCollapsableBoxes(self.list);
        end
    end);

    local panel = Win.CreateRectangle(0, -12, sizeX, sizeY, bar, "TOP", "TOP", R, G, B, A)
    bar.panel = panel;

	return bar;
end

function Win.SortCollapsableBoxes(list)
    local y = 0;
    for c = 1, #list, 1 do
        local bar = list[c];
        if (bar.panel:IsVisible()) then
            bar:ClearAllPoints();
            bar:SetPoint("TOP", bar.parent, "TOP", bar.posX, y);
            y = y - (bar.panel:GetHeight() + 13);
        else
            y = y - 13;
        end
    end
end