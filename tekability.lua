

local tooltip = tekabilityTooltip
--~ tekabilityTooltip = nil
local SLOTTYPES, SLOTIDS = {"Head", "Shoulder", "Chest", "Waist", "Legs", "Feet", "Wrist", "Hands", "MainHand", "SecondaryHand", "Ranged"}, {}
for _,slot in pairs(SLOTTYPES) do SLOTIDS[slot] = GetInventorySlotInfo(slot .. "Slot") end
local FINDSTRING = string.gsub(DURABILITY_TEMPLATE, "%%[^%s]+", "(.+)")
local FONTSIZE = 12
local fontstrings = {}
local _G = getfenv(0)
local frame = CreateFrame("Frame")
local tip = CreateFrame("GameTooltip")


local function ColorGradient(perc, ...)
	if perc >= 1 then
		local r, g, b = select(select('#', ...) - 2, ...)
		return r, g, b
	elseif perc <= 0 then
		local r, g, b = ...
		return r, g, b
	end

	local num = select('#', ...) / 3

	local segment, relperc = math.modf(perc*(num-1))
	local r1, g1, b1, r2, g2, b2 = select((segment*3)+1, ...)

	return r1 + (r2-r1)*relperc, g1 + (g2-g1)*relperc, b1 + (b2-b1)*relperc
end


for _,slot in ipairs(SLOTTYPES) do
	local gslot = _G["Character"..slot.."Slot"]
	assert(gslot, "Character"..slot.."Slot does not exist")

	local fstr = gslot:CreateFontString("Character"..slot.."SlotDurability", "OVERLAY")
	local font, _, flags = NumberFontNormal:GetFont()
	fstr:SetFont(font, FONTSIZE, flags)
	fstr:SetPoint("CENTER", gslot, "BOTTOM", 0, 8)
	fontstrings[slot] = fstr
end


local function FindDurability()
	for i=1,tooltip:NumLines() do
		local str = tooltip.L[i]
		local _, _, v1, v2 = string.find(str or "", FINDSTRING)
		if v1 and v2 then return tonumber(v1), tonumber(v2) end
	end
	return 0, 0
end


CharacterFrame:HookScript("OnShow", function()
	frame:RegisterEvent("UNIT_INVENTORY_CHANGED")
	frame:GetScript("OnEvent")()
end)


CharacterFrame:HookScript("OnHide", function()
	frame:UnregisterEvent("UNIT_INVENTORY_CHANGED")
end)


frame:SetScript("OnEvent", function()
	if not CharacterFrame:IsVisible() then return end

	for _,slot in ipairs(SLOTTYPES) do
		local hasitem, str = tooltip:SetInventoryItem("player", SLOTIDS[slot]), fontstrings[slot]

		if not hasitem then str:SetText("")
		else
			local text, v1, v2 = "", FindDurability()

			if v2 ~= 0 then
				str:SetTextColor(ColorGradient(v1/v2, 1,0,0, 1,1,0, 0,1,0))
				text = string.format("%d%%", v1/v2*100)
			end
			str:SetText(text)
		end
	end
end)

