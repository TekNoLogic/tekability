

local tooltip = tekabilityTooltip
--~ tekabilityTooltip = nil
local SLOTTYPES = {"Head", "Shoulder", "Chest", "Waist", "Legs", "Feet", "Wrist", "Hands", "MainHand", "SecondaryHand", "Ranged"}
local FINDSTRING = string.gsub(DURABILITY_TEMPLATE, "%%[^%s]+", "(.+)")
local FONTSIZE = 12
local fontstrings = {}
local crayon = AceLibrary("Crayon-2.0")
local gratuity = AceLibrary("Gratuity-2.0")
local _G = getfenv(0)
local frame = CreateFrame("Frame")
local tip = CreateFrame("GameTooltip")


for _,slot in ipairs(SLOTTYPES) do
	local gslot = _G["Character"..slot.."Slot"]
	assert(gslot, "Character"..slot.."Slot does not exist")

	local fstr = gslot:CreateFontString("Character"..slot.."SlotDurability", "OVERLAY")
	local font, _, flags = NumberFontNormal:GetFont()
	fstr:SetFont(font, FONTSIZE, flags)
	fstr:SetPoint("CENTER", gslot, "BOTTOM", 0, 8)
	fontstrings[slot] = fstr
end


CharacterFrame:HookScript("OnShow", function()
	frame:RegisterEvent("UNIT_INVENTORY_CHANGED")
	frame:GetScript("OnEvent")()
end)


CharacterFrame:HookScript("OnHide", function()
	frame:UnregisterEvent("UNIT_INVENTORY_CHANGED")
end)


local function FindDurability()
	for i=1,tooltip:NumLines() do
		local str = tooltip.L[i]
		local _, _, v1, v2 = string.find(str or "", FINDSTRING)
		if v1 and v2 then return tonumber(v1), tonumber(v2) end
	end
	return 0, 0
end


frame:SetScript("OnEvent", function()
	if not CharacterFrame:IsVisible() then return end

	for _,slot in ipairs(SLOTTYPES) do
		local id, _ = GetInventorySlotInfo(slot .. "Slot")
		local hasitem = tooltip:SetInventoryItem("player", id)
		local str = fontstrings[slot]

		if not hasitem then str:SetText("")
		else
			local text, v1, v2 = "xxx", FindDurability()

			if v2 ~= 0 then
				str:SetTextColor(crayon:GetThresholdColor(v1/v2))
				text = string.format("%d%%", v1/v2*100)
			end
			str:SetText(text)
		end
	end
end)

