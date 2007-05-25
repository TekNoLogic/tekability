
local _G = getfenv(0)
local tip = CreateFrame("GameTooltip")
tip:SetOwner(WorldFrame, "ANCHOR_NONE")

-- Our global, change as needed
tekabilityTooltip = tip


local lcache, rcache = {}, {}
for i=1,30 do
	lcache[i], rcache[i] = tip:CreateFontString(), tip:CreateFontString()
	lcache[i]:SetFontObject(GameFontNormal); rcache[i]:SetFontObject(GameFontNormal)
	tip:AddFontStrings(lcache[i], rcache[i])
end


-- GetText cache tables, provide fast access to the tooltip's text
tip.L = setmetatable({}, {
	__index = function(t, key)
		if tip:NumLines() >= key and lcache[key] then
			local v = lcache[key]:GetText()
			t[key] = v
			return v
		end
		return nil
	end,
})


local orig = tip.SetInventoryItem
tip.SetInventoryItem = function(self, ...)
	self:ClearLines() -- Ensures tooltip's NumLines is reset
	for i in pairs(self.L) do self.L[i] = nil end -- Flush the metatable cache
	if not self:IsOwned(WorldFrame) then self:SetOwner(WorldFrame, "ANCHOR_NONE") end
	return orig(self, ...)
end

