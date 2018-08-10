local addonName, ns, _ = ...

local function ApplyFontSettings(fontString, savedVars)
	if not savedVars then return end
	if savedVars.font or savedVars.fontSize or savedVars.fontStyle then
		local defaultFont, defaultSize, defaultStyle = fontString:GetFont()
		fontString:SetFont(savedVars.font or defaultFont,
			savedVars.fontSize or defaultSize,
			savedVars.fontStyle or defaultStyle)
		fontString:SetJustifyH(savedVars.justifyH or 'LEFT')
	end
end

local function PlayerStyle(self, unit)
	local _, class = UnitClass(unit)

	-- castbar
	-- self.Castbar = ns.Castbar(self, unit)
	-- self.Castbar:SetPoint('LEFT', '$parent', 'RIGHT')

	-- status icons
	local status = self:CreateFontString(nil, nil, 'GameFontNormalSmall')
	      status:SetPoint('BOTTOMRIGHT', self.powerThreat, 'TOPRIGHT')
	self:Tag(status, '[ckaotik:pvp][ckaotik:assistant][ckaotik:masterlooter][ckaotik:combat][ckaotik:leader][ckaotik:resting]')

	-- class specific things
	local bottomOffset = 0
	if class == 'DEATHKNIGHT' then
		--[[ self.Runes = ns.RuneBar(self, unit)
		self.Runes:SetPoint('TOPRIGHT', self, 'BOTTOMRIGHT')
		bottomOffset = self.Runes:GetHeight() --]]
		local extra = _G['RuneFrame']
		extra:SetScale(0.7)
		extra:SetParent(self)
		extra:ClearAllPoints()
		extra:SetPoint('TOPRIGHT', self, 'BOTTOMRIGHT', 0, 0)
	elseif class == 'MONK' then
		self.Stagger = CreateFrame('StatusBar', nil, self)
		self.Stagger:SetSize(120, 16)
		self.Stagger:SetPoint('TOPRIGHT', self, 'BOTTOMRIGHT')
	end

	if class == 'ROGUE' or class == 'WARLOCK' or class == 'MONK' or class == 'PALADIN' then
		self.ClassPower = ns.ClassIcons(self, unit)
		self.ClassPower:SetPoint('TOPRIGHT', self, 'BOTTOMRIGHT')
		bottomOffset = (bottomOffset or 0) + self.ClassPower:GetHeight()
	end

	self.Totems = ns.Totems(self, unit)
	self.Totems:SetPoint('TOPRIGHT', self, 'BOTTOMRIGHT', 0, -bottomOffset-2)
end

local function BossStyle(self, unit, isSingle)
	-- body
end

local function MiniStyle(self, unit, isSingle)
	-- body
end

local unitStyles = {
	-- single units
	player = PlayerStyle,
	-- styles
	boss = BossStyle,
	mini = MiniStyle,
}

function ns.SharedStyle(self, unit, isSingle)
	if not isSingle then return end
	self:SetScript("OnEnter", UnitFrame_OnEnter)
	self:SetScript("OnLeave", UnitFrame_OnLeave)

	-- only list our override colors. see http://wowpedia.org/Power_colors
	self.colors.power['AMMOSLOT'] 		= {0.8, 0.6, 0}
	self.colors.power['FUEL'] 			= {0, 0.55, 0.5}
	self.colors.power['MANA'] 			= {0.31, 0.45, 0.63}
	self.colors.power['RAGE'] 			= {0.69, 0.31, 0.31}
	self.colors.power['ENERGY'] 		= {0.65, 0.63, 0.35}
	self.colors.power['FOCUS'] 			= {0.71, 0.43, 0.27}
	self.colors.power['RUNIC_POWER'] 	= {0, 0.82, 1}
	self.colors.power['SOUL_SHARDS'] 	= {0.83, 0.6, 1}
	self.colors.power['HOLY_POWER'] 	= {1, 1, 0.4}
	self.colors.power['LUNAR_POWER']    = {0.3, 1, 1}
	--[[self.colors.power['ECLIPSE'] = {
		['SOLAR'] = {1, 1, 0.3},
		['LUNAR'] = {0.3, 1, 1},
	}--]]
	self.colors.runes = {
		{0.69, 0.31, 0.31}, -- Blood
		{0.31, 0.45, 0.63}, -- Frost
		{0.33, 0.59, 0.33}, -- Unholy
		-- {0.84, 0.75, 0.65}, -- Death
	}
	self.colors.totems = {
		{0.80, 0.72, 0.29},	-- Earth
		{0.81, 0.26, 0.10},	-- Fire
		{0.17, 0.50, 1.00},	-- Water
		{0.17, 0.73, 0.80},	-- Air
	}

	-- TODO: use these variables!
	local isBoss = unit:find('^boss')
	local side   = (unit == 'player' or unit == 'pet' or isBoss) and 'RIGHT' or 'LEFT'
	local style  = (unit == 'player' or unit == 'target' or unit == 'focus') and 'default'
		or isBoss and 'boss'
		or 'mini'

	-- element: health
	self.Health = ns.Health(self, unit)
	self.Health:SetPoint(side == 'RIGHT' and 'RIGHT' or 'LEFT')

	self.Health.frequentUpdates = isBoss
	self.Health.colorDisconnected 	= true
	self.Health.colorTapping 		= true
	self.Health.colorHealth 		= true

	-- element: power
	self.Power = ns.Power(self, unit)
	self.Power:SetPoint('BOTTOMRIGHT', self.Health, 2, -2)
	self.Power:SetFrameLevel( self.Health:GetFrameLevel() + 1 )
	if self.Power.text then ApplyFontSettings(self.Power.text, ns.db.powerPercent) end

	self.Power.colorDisconnected	= true
	self.Power.colorTapping			= false
	self.Power.colorPower			= true

	-- long power/threat text
	local powerThreat = self:CreateFontString(nil, nil, 'GameFontNormalLarge')
	ApplyFontSettings(powerThreat, ns.db.powerThreat)
	self.powerThreat = powerThreat

	if side == 'RIGHT' then
		powerThreat:SetPoint('BOTTOMRIGHT', self.Health, 'BOTTOMLEFT', -4, 0)
	else
		powerThreat:SetPoint('BOTTOMLEFT', self.Health, 'BOTTOMRIGHT',  4, 0)
	end
	-- ‹›
	if unit == 'player' then
		self:Tag(powerThreat, '[ckaotik:power< · ][ckaotik:health]')
	elseif isBoss then
		self:Tag(powerThreat, '[ckaotik:threat< · ][ckaotik:altpower< · ][ckaotik:power< · ][perhp:boss]%')
	else
		self:Tag(powerThreat, '[ckaotik:health][ · >ckaotik:power][ · >ckaotik:altpower][ · >ckaotik:threat]')
	end

	-- unit name
	local name = self:CreateFontString(nil, nil, 'GameFontNormalHuge')
	ApplyFontSettings(name, ns.db.name)
	self.name = name

	if style == 'mini' then
		name:SetFontObject(_G.GameFontNormal)
		name:SetPoint(side)
	elseif side == 'RIGHT' then
		name:SetPoint('BOTTOMRIGHT', self.powerThreat, 'TOPRIGHT')
	else
		name:SetPoint('BOTTOMLEFT', self.powerThreat, 'TOPLEFT')
	end
	if isBoss then
		self:Tag(name, '[ckaotik:unitcolor][name:boss]')
	elseif style == 'mini' then
		self:Tag(name, '[ >ckaotik:youname< ][@>perhp<%]')
	elseif unit ~= 'player' then
		self:Tag(name, '[ckaotik:unitcolor][name]|r[afkdnd]')
	end

	-- raid marker
	local raidIcon = self:CreateTexture(nil, 'ARTWORK', nil, 1)
	      raidIcon:SetTexture('Interface\\AddOns\\'..addonName..'\\media\\raidicons')
	self.RaidTargetIndicator = raidIcon

	if isBoss then
		raidIcon:SetSize(24, 24)
		raidIcon:SetParent(self.Health.digits[1])
		raidIcon:SetPoint('BOTTOMRIGHT', self.Health, 4, -4)
	else
		raidIcon:SetSize(40, 40)
		if side == 'RIGHT' then
			raidIcon:SetPoint('LEFT', self.Health, 'RIGHT', 4, 0)
		else
			raidIcon:SetPoint('RIGHT', self.Health, 'LEFT', -4, 0)
		end
	end

	-- auras
	if unit == 'target' or unit == 'focus' then
		self.Buffs = ns.Auras(self, unit)
		self.Buffs:SetPoint('TOPLEFT', self, 'BOTTOMLEFT', 0, -4)
		self.Buffs.showStealableBuffs = true
		self.Buffs.showBuffType = false

		self.Debuffs = ns.Auras(self, unit, true)
		self.Debuffs:SetPoint('TOPLEFT', self.Buffs, 'BOTTOMLEFT', 0, -4)
		self.Debuffs.showDebuffType = true
	elseif isBoss then
		local auras = ns.Auras(self, unit)
		      auras.initialAnchor = 'TOPRIGHT'
		      auras['growth-x']   = 'LEFT'
		      auras['growth-y']   = 'DOWN'
		self.Auras = auras
		self.Auras.gap = false -- 4
		self.Auras.showType = true
		self.Auras.showStealableBuffs = true
		self.Auras.PostUpdate = nil
		self.Auras:SetPoint('TOPRIGHT', self.name, 'TOPLEFT', -4, 0)
	end

	-- unit specific styles
	if unitStyles[unit] then
		unitStyles[unit](self, unit)
	end

	-- general frame settings
	if style == 'default' or style == 'boss' then
		self:SetSize(175, 50)
	elseif style == 'mini' then
		self:SetSize(125, 20)
	end
end
