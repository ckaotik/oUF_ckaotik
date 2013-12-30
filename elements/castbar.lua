local addonName, ns, _ = ...

local function CustomTimeText(self, duration)
	if self.casting then
		self.Time:SetFormattedText("%.1f", self.max - duration)
	elseif self.channeling then
		self.Time:SetFormattedText("%.1f", duration)
	end
end

function ns.Castbar(self, unit)
	-- Position and size
	local castbar = CreateFrame("StatusBar", nil, self)
	      castbar:SetSize(50, 20)

	-- Add a background
	local background = castbar:CreateTexture(nil, 'BACKGROUND')
	      background:SetAllPoints(castbar)
	      background:SetTexture(1, 1, 1, .5)

	-- Add a spark
	local spark = castbar:CreateTexture(nil, "OVERLAY")
	      spark:SetSize(20, 20)
	      spark:SetBlendMode("ADD")

	-- Add a timer
	local time = castbar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	      time:SetPoint("RIGHT", castbar)

	-- Add spell text
	local text = castbar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	      text:SetPoint("LEFT", castbar)

	-- Add spell icon
	local icon = castbar:CreateTexture(nil, "OVERLAY")
	      icon:SetSize(20, 20)
	      icon:SetPoint("TOPLEFT", castbar, "TOPLEFT")

	-- Add Shield
	local shield = castbar:CreateTexture(nil, "OVERLAY")
	      shield:SetSize(20, 20)
	      shield:SetPoint("CENTER", castbar)

	-- Add safezone
	local safezone = castbar:CreateTexture(nil, "OVERLAY")

	castbar.bg = background
	castbar.Spark = spark
	castbar.Time = time
	castbar.Text = text
	castbar.Icon = icon
	castbar.Shield = shield
	castbar.SafeZone = safezone

	return castbar
end
