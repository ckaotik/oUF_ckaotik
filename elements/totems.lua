local addonName, ns, _ = ...

-- GLOBALS: MAX_TOTEMS, CreateFrame, GetTime, unpack
local _, unitClass = UnitClass('player')
-- TODO: restoration druid: add glow when mushroom is fully charged

local config = {
	['SHAMAN'] = {
		-- inverted y-coords to allow filling the texture bottom->top. texture matches the crazyness
		fill = {'Interface\\AddOns\\'..addonName..'\\media\\totems', {  0/128, 16/128, 12/32, 0/32 }},
		bg 	 = {'Interface\\AddOns\\'..addonName..'\\media\\totems', { 24/128, 48/128, 0/32, 20/32 }},
		glow = {'Interface\\AddOns\\'..addonName..'\\media\\totems', { 48/128, 72/128, 0/32, 20/32 }},
		size = {16, 12},
		padding = 4,
		glowPadding = 4,
		showEmpty = true,
	},
	['DRUID'] = {
		-- inverted y-coords to allow filling the texture bottom->top. texture matches the crazyness
		fill = {'Interface\\AddOns\\'..addonName..'\\media\\mushroom', { 0/64,  8/64, 8/16,  0/16}},
		bg   = {'Interface\\AddOns\\'..addonName..'\\media\\mushroom', {16/64, 32/64, 0/16, 16/16}},
		glow = {'Interface\\AddOns\\'..addonName..'\\media\\mushroom', {32/64, 48/64, 0/16, 16/16}},
		size = {8, 8},
		padding = 4,
		glowPadding = 6,
		showEmpty = nil,
	},
	default = {
		-- inverted y-coords to allow filling the texture bottom->top. texture matches the crazyness
		fill = {'Interface\\AddOns\\'..addonName..'\\media\\combo', { 0/64,  8/64, 8/16,  0/16}},
		bg   = {'Interface\\AddOns\\'..addonName..'\\media\\combo', {16/64, 32/64, 0/16, 16/16}},
		glow = {'Interface\\AddOns\\'..addonName..'\\media\\combo', {32/64, 48/64, 0/16, 16/16}},
		size = {8, 8},
		padding = 4,
		glowPadding = 6,
		showEmpty = nil,
	}
}
local data = config[unitClass] or config.default
local iconWidth, iconHeight = data.size[1], data.size[2]
local padding, glowPadding = data.padding, data.glowPadding or data.padding

local function CreateAnimationGlow(frame, index, target)
	local animation = target:CreateAnimationGroup()
	target.animation = animation

	-- fast fade-in to 100% alpha
	local alphaIn = animation:CreateAnimation("Alpha")
	      alphaIn:SetChange(1)
	      alphaIn:SetSmoothing("OUT")
	      alphaIn:SetDuration(0.5)
	      alphaIn:SetOrder(1)
	-- then, slowly return to 50% alpha
	local alphaOut = animation:CreateAnimation("Alpha")
	      alphaOut:SetChange(-0.5)
	      alphaOut:SetSmoothing("OUT")
	      alphaOut:SetDuration(1.5)
	      alphaOut:SetOrder(2)

	-- and stay at that alpha
	animation:SetScript("OnFinished", function(self)
		self:GetParent():SetAlpha(0.5)
	end)
end

local function OnUpdate(self, elapsed)
	local now = GetTime()
	local remaining = self.expires - now

	if remaining <= 0 then
		self:SetValue(0)
		self:SetScript('OnUpdate', nil)
	else
		self:SetValue(remaining)
	end
end

local function PostUpdate(element, index, haveTotem, name, start, duration, icon)
	local totem = element[index]
	if haveTotem or data.showEmpty then
		totem:Show()
	end

	if haveTotem then
		totem.expires = start + duration
		totem:SetMinMaxValues(0, duration)
		totem:SetScript('OnUpdate', OnUpdate)
		totem.glow:SetAlpha(0)
	else
		totem:SetValue(0)
		totem:SetScript('OnUpdate', nil)
		if totem.glow.animation then
			totem.glow.animation:Play()
		end
	end
end

function ns.Totems(self, unit)
	local totems = CreateFrame('Frame', nil, self)
	      totems:SetSize(MAX_TOTEMS * (iconWidth + 2*padding), (iconHeight + 2*padding))
	      totems.PostUpdate = PostUpdate

	local sharedR, sharedG, sharedB
	if unitClass == 'DRUID' then
		sharedR, sharedG, sharedB = unpack(self.colors.power.ECLIPSE.SOLAR)
	elseif unitClass == 'DEATHKNIGHT' then
		sharedR, sharedG, sharedB = unpack(self.colors.runes[4])
	elseif unitClass == 'PALADIN' then
		sharedR, sharedG, sharedB = unpack(self.colors.power.HOLY_POWER)
	elseif unitClass == 'MONK' then
		sharedR, sharedG, sharedB = unpack(self.colors.power.CHI)
	end

	for index = 1, MAX_TOTEMS do
		local altR, altG, altB = unpack(self.colors.totems[index])
		local r, g, b = sharedR or altR, sharedG or altG, sharedB or altB

		local texture = data.fill[1]
		local totem = CreateFrame('StatusBar', nil, totems, nil, index)
		      totem:SetStatusBarTexture(texture)
		      totem:SetStatusBarColor(r, g, b)
		      totem:SetRotatesTexture(false)
		      totem:SetOrientation('VERTICAL')
		      totem:SetSize(iconWidth, iconHeight)
		      totem:SetMinMaxValues(0, 1)
		      totem:SetValue(0)
		      totem:EnableMouse(true) -- to enable tooltips

		if data.fill[2] then
			totem:GetStatusBarTexture():SetHorizTile(true)
			totem:GetStatusBarTexture():SetVertTile(true)
			totem:GetStatusBarTexture():SetTexCoord( unpack(data.fill[2]) )
		end

		texture = data.bg[1]
		local bg = totem:CreateTexture(nil, 'BACKGROUND')
		      bg:SetPoint('TOPLEFT', totem, 'TOPLEFT', -padding, padding)
		      bg:SetPoint('BOTTOMRIGHT', totem, 'BOTTOMRIGHT', padding, -padding)
		      bg:SetTexture(texture)
		totem.bg = bg
		if data.bg[2] then
			bg:SetTexCoord( unpack(data.bg[2]) )
		end

		texture = data.glow[1]
		local glow = totem:CreateTexture(nil, 'BORDER')
		      glow:SetPoint('TOPLEFT', totem, 'TOPLEFT', -glowPadding, glowPadding)
		      glow:SetPoint('BOTTOMRIGHT', totem, 'BOTTOMRIGHT', glowPadding, -glowPadding)
		      glow:SetTexture(texture)
		      glow:SetVertexColor(r, g, b)
		      glow:SetAlpha(0)
		totem.glow = glow
		if data.glow[2] then
			glow:SetTexCoord( unpack(data.glow[2]) )
		end

		if data.showEmpty then
			CreateAnimationGlow(self, index, totem.glow)
		end

		if index == 1 then
			totem:SetPoint('TOPLEFT', totems, padding, -padding)
		else
			totem:SetPoint('LEFT', totems[index - 1], 'RIGHT', 2*padding, 0)
		end
		totems[index] = totem
	end

	return totems
end
