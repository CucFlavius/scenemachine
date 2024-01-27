-------------------------- Zee's Window API ---------------------------
-- Developed it for use in my addons, but feel free to use in yours ---
-----------------------------------------------------------------------

--Item List--
local Win = ZWindowAPI;

function Win.ItemList(itemSizeX, itemSizeY, parent, onSelect)
	local itemList = {
		selectedIndex = -1,
		pool = {},
		SetItem = function(self, index, text)
			if (self.pool[index] == nil) then
				self.pool[index] = Win.ItemList_CreateNewItem(0, -(index - 1) * (itemSizeY + 1.0001), itemSizeX, itemSizeY, parent);
				self.pool[index].text:SetText(text);
				self.pool[index]:SetScript("OnClick", function(self2) 
				    -- deselect all other --
					for idx in pairs(self.pool) do
						self.pool[idx].ntex:SetColorTexture(0.1757, 0.1757, 0.1875 ,1);
					end

					-- select current --
					self.pool[index].ntex:SetColorTexture(0, 0.4765, 0.7968,1);
				
					-- set index --
					self.selectedIndex = index;

					-- trigger action --
					onSelect(index);
				end);
			else
				self.pool[index]:Show();
				self.pool[index].text:SetText(text);
			end
		end,
		GetSelected = function(self)
			return self.selectedIndex;
		end,
		Clear = function(self)
			for idx in pairs(self.pool) do
				self.pool[idx]:Hide();
			end
			selectedIndex = -1;
			-- deselect all other --
			for idx in pairs(self.pool) do
				self.pool[idx].ntex:SetColorTexture(0.1757, 0.1757, 0.1875 ,1);
			end
		end,
		GetSize = function(self)
			
		end,
	};

	return itemList;
end

function Win.ItemList_CreateNewItem(x, y, w, h, parent)
	local ButtonFont = Win.defaultFont;
	local ButtonFontSize = 9;

	-- main button frame --
	local item = CreateFrame("Button", "Zee.WindowAPI.Button", parent)
	item:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y);
	item:SetWidth(w);
	item:SetHeight(h)
	item.ntex = item:CreateTexture()
	item.htex = item:CreateTexture()
	item.ptex = item:CreateTexture()
	item.ntex:SetColorTexture(0.1757, 0.1757, 0.1875 ,1);
	item.htex:SetColorTexture(0.242, 0.242, 0.25,1);
	item.ptex:SetColorTexture(0, 0.4765, 0.7968,1);
	item.ntex:SetAllPoints()	
	item.ptex:SetAllPoints()
	item.htex:SetAllPoints()
	item:SetNormalTexture(item.ntex)
	item:SetHighlightTexture(item.htex)
	item:SetPushedTexture(item.ptex)

	-- project name text --
	item.text = item:CreateFontString("Zee.WindowAPI.Button Text");
	item.text:SetFont(ButtonFont, ButtonFontSize, "NORMAL");
	item.text:SetPoint("LEFT", item, "LEFT", 10, 0);
	item.text:SetText(name);

	return item;
end