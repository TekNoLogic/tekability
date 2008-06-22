

local SLOTTYPES, SLOTIDS = {"Head", "Shoulder", "Chest", "Waist", "Legs", "Feet", "Wrist", "Hands", "MainHand", "SecondaryHand", "Ranged"}, {}
for _,slot in pairs(SLOTTYPES) do SLOTIDS[slot] = GetInventorySlotInfo(slot .. "Slot") end
local FINDSTRING = string.gsub(DURABILITY_TEMPLATE, "%%[^%s]+", "(.+)")
local FONTSIZE = 12
local fontstrings = {}
local _G = getfenv(0)
local frame = CreateFrame("Frame")
local tip = CreateFrame("GameTooltip")


local function RYGColorGradient(perc)
	local relperc = perc*2 % 1
	if perc <= 0 then       return           1,       0, 0
	elseif perc < 0.5 then  return           1, relperc, 0
	elseif perc == 0.5 then return           1,       1, 0
	elseif perc < 1.0 then  return 1 - relperc,       1, 0
	else                    return           0,       1, 0 end
end


for _,slot in ipairs(SLOTTYPES) do
	local gslot = _G["Character"..slot.."Slot"]
	assert(gslot, "Character"..slot.."Slot does not exist")

	local fstr = gslot:CreateFontString("Character"..slot.."SlotDurability", "OVERLAY")
	local font, _, flags = NumberFontNormal:GetFont()
	fontstrings[slot] = fstr
end


CharacterFrame:HookScript("OnShow", function()
	frame:RegisterEvent("UNIT_INVENTORY_CHANGED")
	frame:GetScript("OnEvent")()
end)


CharacterFrame:HookScript("OnHide", function()
	frame:UnregisterEvent("UNIT_INVENTORY_CHANGED")
end)


frame:SetScript("OnEvent", function(self, event)
	if event == "ADDON_LOADED" then
		for i,fstr in pairs(fontstrings) do
			-- Re-apply the font, so that we catch any changes to NumberFontNormal by addons like ClearFont
			local font, _, flags = NumberFontNormal:GetFont()
			fstr:SetFont(font, FONTSIZE, flags)
		end
		return
	end

	if not CharacterFrame:IsVisible() then return end

	for _,slot in ipairs(SLOTTYPES) do
		local str = fontstrings[slot]
		local text, v1, v2 = "", GetInventoryItemDurability(SLOTIDS[slot])

		if v1 and v2 and v2 ~= 0 then
			str:SetTextColor(RYGColorGradient(v1/v2))
			text = string.format("%d%%", v1/v2*100)
		end

		str:SetText(text)
	end
end)

frame:RegisterEvent("ADDON_LOADED")

-- Handle LoD
if CharacterFrame:IsVisible() then frame:GetScript("OnEvent")() end
