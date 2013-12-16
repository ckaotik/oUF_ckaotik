local addonName, ns, _ = ...

-- GLOBALS: oUF_ckaotikDB
local Movable = LibStub('LibMovable-1.0')

-- ================================================
--  Setup
-- ================================================
local function Initialize()
	if not oUF_ckaotikDB then oUF_ckaotikDB = {} end
	ns.db = oUF_ckaotikDB

	-- set up default settings
	for key, value in pairs({
		position = {},
		name = {
			font = false,
			fontSize = false,
			fontStyle = false,
			justifyH = false,
		},
		powerThreat = {
			font = false,
			fontSize = false,
			fontStyle = false,
			justifyH = false,
		},
		powerPercent = {
			font = false,
			fontSize = false,
			fontStyle = false,
			justifyH = false,
		},
		comboTarget = {
			font = false,
			fontSize = false,
			fontStyle = false,
			justifyH = false,
		},
		-- showPercentSign = false,
	}) do
		if ns.db[key] == nil then
			ns.db[key] = value
		end
	end

	_G.SLASH_OUFCKAOTIK = "/oufckaotik"
	SlashCmdList.OUFCKAOTIK = function()
		if Movable.IsLocked(addonName) then
			Movable.Unlock(addonName)
		else
			Movable.Lock(addonName)
		end
	end

	oUF:RegisterStyle('ckaotik', ns.SharedStyle)
	oUF:Factory(function(self)
		self:SetActiveStyle('ckaotik')

		local unitFrames = {
			{ 'player',             'RIGHT', 'UIParent', 'CENTER', -200, -300 },
			{ 'pet',                'BOTTOMRIGHT', 'oUF_ckaotikPlayer', 'TOPRIGHT' },
			{ 'target',             'LEFT', 'UIParent', 'CENTER',  200, -300 },
			{ 'targettarget',       'BOTTOMLEFT', 'oUF_ckaotikTarget', 'TOPLEFT' },
			{ 'targettargettarget', 'BOTTOMLEFT', 'oUF_ckaotikTargetTarget', 'TOPLEFT' },
			-- { 'focus',              'CENTER', 'UIParent', 'CENTER', -cfg.FocusFrameMargin[1], -cfg.FocusFrameMargin[2] },
			-- { 'focustarget',        'BOTTOMLEFT',  'oUF_ckaotikFocus', 'TOPLEFT', 0, 5 },
			{ 'boss1',              'RIGHT',  'UIParent', -70, 0 },
		}
		for i = 2, MAX_BOSS_FRAMES do
			table.insert(unitFrames, { 'boss'..i,  'TOPRIGHT', 'oUF_ckaotikBoss'..(i-1), 'BOTTOMRIGHT', 0, -5 })
		end

		for i, info in ipairs(unitFrames) do
			local unit = info[1]
			local unitFrame = self:Spawn(unit)
			      unitFrame:SetPoint(select(2, unpack(info)))

			if not ns.db.position[unit] then ns.db.position[unit] = {} end
			Movable.RegisterMovable(addonName, unitFrame, ns.db.position[unit])
		end

		--[[
		self:SpawnHeader(nil, nil, 'custom [group:party] show; [@raid3,exists] show; [@raid26,exists] hide; hide',
			'showParty', true, 'showRaid', true, 'showPlayer', true, 'yOffset', -6,
			'oUF-initialConfigFunction', [=[
					self:SetHeight(16)
					self:SetWidth(126)
			]=]
		)SetPoint('TOP', Minimap, 'BOTTOM', 0, -10)
		--]]
	end)

	-- expose us
	_G[addonName] = ns
end

local frame = CreateFrame("Frame")
local function eventHandler(frame, event, arg1, ...)
	if event == 'ADDON_LOADED' and arg1 == addonName then
		Initialize()
		frame:UnregisterEvent(event)
	end
end
frame:SetScript("OnEvent", eventHandler)
frame:RegisterEvent("ADDON_LOADED")

-- ================================================
--  Little Helpers
-- ================================================
function ns.Print(text, ...)
	if ... and text:find("%%") then
		text = format(text, ...)
	elseif ... then
		text = join(", ", tostringall(text, ...))
	end
	DEFAULT_CHAT_FRAME:AddMessage("|cffE01B5D"..addonName.."|r "..text)
end

function ns.Debug(...)
  if true then
	ns.Print("! "..join(", ", tostringall(...)))
  end
end

function ns.ShowTooltip(self, altSelf)
	if not self.tiptext and not self.link then return end
	if altSelf and type(altSelf) == 'table' then
		self = altSelf
	end
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:ClearLines()

	if self.link then
		GameTooltip:SetHyperlink(self.link)
	elseif type(self.tiptext) == "string" and self.tiptext ~= "" then
		GameTooltip:SetText(self.tiptext, nil, nil, nil, nil, true)
	elseif type(self.tiptext) == "function" then
		self.tiptext(self, GameTooltip)
	end
	GameTooltip:Show()
end
function ns.HideTooltip() GameTooltip:Hide() end

-- counts table entries. for numerically indexed tables, use #table
function ns.Count(table)
	if not table or type(table) ~= "table" then return 0 end
	local i = 0
	for _ in pairs(table) do
		i = i + 1
	end
	return i
end

function ns.Find(where, what)
	for k, v in pairs(where) do
		if v == what then
			return k
		end
	end
end

function ns.GlobalStringToPattern(str)
	str = gsub(str, "([%(%)])", "%%%1")
	str = gsub(str, "%%%d?$?c", "(.+)")
	str = gsub(str, "%%%d?$?s", "(.+)")
	str = gsub(str, "%%%d?$?d", "(%%d+)")
	return str
end












if true then return end


local addonName, oUF_Hank, _ = ...
local cfg = oUF_Hank_config

-- GLOBALS: _G, oUFHankDB, oUF, MIRRORTIMER_NUMTIMERS, SPELL_POWER_HOLY_POWER, MAX_TOTEMS, MAX_COMBO_POINTS, DebuffTypeColor
-- GLOBALS: UnitIsUnit, GetTime, AnimateTexCoords, GetEclipseDirection, MirrorTimerColors, GetSpecialization, UnitHasVehicleUI, UnitHealth, UnitHealthMax, UnitPower, UnitIsDead, UnitIsGhost, UnitIsConnected, UnitAffectingCombat, GetLootMethod, UnitIsGroupLeader, UnitIsPVPFreeForAll, UnitIsPVP, UnitInRaid, IsResting, UnitAura, UnitCanAttack, UnitIsGroupAssistant, GetRuneCooldown, UnitClass, CancelUnitBuff, CreateFrame, IsAddOnLoaded, UnitFrame_OnEnter, UnitFrame_OnLeave
local upper, strlen, strsub, gmatch, match = string.upper, string.len, string.sub, string.gmatch, string.match
local unpack, pairs, ipairs, select, tinsert = unpack, pairs, ipairs, select, table.insert
local ceil, floor = math.ceil, math.floor

local LibMasque = LibStub("Masque", true)

oUF_Hank.digitTexCoords = {
	["1"] = {  1, 20},
	["2"] = { 21, 31},
	["3"] = { 53, 30},
	["4"] = { 84, 33},
	["5"] = {118, 30},
	["6"] = {149, 31},
	["7"] = {181, 30},
	["8"] = {212, 31},
	["9"] = {244, 31},
	["0"] = {276, 31},
	["%"] = {308, 17},
	["X"] = {326, 31}, 	 -- Dead
	["G"] = {358, 36}, 	 -- Ghost
	["Off"] = {395, 23}, -- Offline
	["B"] = {419, 42},   -- Boss
	["height"] = 42,
	["texWidth"] = 512,
	["texHeight"] = 128
}

oUF_Hank.classResources = {
	['PALADIN'] = {
		resource = SPELL_POWER_HOLY_POWER,
		inactive = {'Interface\\AddOns\\oUF_Hank_v3\\textures\\HolyPower.blp', { 0, 18/64, 0, 18/32 }},
		active   = {'Interface\\AddOns\\oUF_Hank_v3\\textures\\HolyPower.blp', { 18/64, 36/64, 0, 18/32 }},
		size     = {18, 18},
	},
	['MONK'] = {
		resource = SPELL_POWER_CHI,
		inactive = {'Interface\\PlayerFrame\\MonkNoPower'},
		active   = {'Interface\\PlayerFrame\\MonkLightPower'},
		size     = {20, 20},
	},
	['PRIEST'] = {
		resource = SPELL_POWER_SHADOW_ORBS,
		inactive = {'Interface\\PlayerFrame\\Priest-ShadowUI', { 76/256, 112/256, 57/128, 94/128 }},
		active   = {'Interface\\PlayerFrame\\Priest-ShadowUI', { 116/256, 152/256, 57/128, 94/128 }},
		size     = {28, 28},
	},
	-- ['WARLOCK'] = { SPELL_POWER_BURNING_EMBERS, SPELL_POWER_DEMONIC_FURY }
}
oUF_Hank.classTotems = {
	-- totems are handled differently
	['SHAMAN'] = {
		inactive = {'Interface\\AddOns\\oUF_Hank_v3\\textures\\blank.blp', { 0, 23/128, 0, 20/32 }},
		active   = {'Interface\\AddOns\\oUF_Hank_v3\\textures\\totems.blp', { (1+23)/128, ((23*2)+1)/128, 0, 20/32 }},
		size     = {23, 20},
	},
	-- TODO: DRUID mushrooms, DEATHKNIGHT ghoul, PALADIN hammer, ...
}

local fntBig = CreateFont("UFFontBig")
fntBig:SetFont(unpack(cfg.FontStyleBig))
local fntMedium = CreateFont("UFFontMedium")
fntMedium:SetFont(unpack(cfg.FontStyleMedium))
fntMedium:SetTextColor(unpack(cfg.colors.text))
fntMedium:SetShadowColor(unpack(cfg.colors.textShadow))
fntMedium:SetShadowOffset(1, -1)
local fntSmall = CreateFont("UFFontSmall")
fntSmall:SetFont(unpack(cfg.FontStyleSmall))
fntSmall:SetTextColor(unpack(cfg.colors.text))
fntSmall:SetShadowColor(unpack(cfg.colors.textShadow))
fntSmall:SetShadowOffset(1, -1)

local canDispel = {}

-- Functions -------------------------------------
-- Party frames be gone!
oUF_Hank.HideParty = function()
	for i = 1, 4 do
		local party = "PartyMemberFrame" .. i
		local frame = _G[party]

		frame:UnregisterAllEvents()
		frame.Show = function() end
		frame:Hide()

		_G[party .. "HealthBar"]:UnregisterAllEvents()
		_G[party .. "ManaBar"]:UnregisterAllEvents()
	end
end

-- Set up the mirror bars (breath, exhaustion etc.)
oUF_Hank.AdjustMirrorBars = function()
	for k, v in pairs(MirrorTimerColors) do
		MirrorTimerColors[k].r = cfg.colors.castbar.bar[1]
		MirrorTimerColors[k].g = cfg.colors.castbar.bar[2]
		MirrorTimerColors[k].b = cfg.colors.castbar.bar[3]
	end

	for i = 1, MIRRORTIMER_NUMTIMERS do
		local mirror = _G["MirrorTimer" .. i]
		local statusbar = _G["MirrorTimer" .. i .. "StatusBar"]
		local backdrop = select(1, mirror:GetRegions())
		local border = _G["MirrorTimer" .. i .. "Border"]
		local text = _G["MirrorTimer" .. i .. "Text"]

		mirror:ClearAllPoints()
		mirror:SetPoint("BOTTOM", (i == 1) and _G["oUF_HankPlayer"].Castbar or _G["MirrorTimer" .. i - 1], "TOP", 0, 5 + ((i == 1) and 5 or 0))
		mirror:SetSize(cfg.CastbarSize[1], 12)
		statusbar:SetStatusBarTexture(cfg.CastbarTexture)
		statusbar:SetAllPoints(mirror)
		backdrop:SetTexture(cfg.CastbarBackdropTexture)
		backdrop:SetVertexColor(0.22, 0.22, 0.19, 0.8)
		backdrop:SetAllPoints(mirror)
		border:Hide()
		text:SetFont(unpack(cfg.CastBarMedium))
		text:SetJustifyH("LEFT")
		text:SetJustifyV("MIDDLE")
		text:ClearAllPoints()
		text:SetPoint("TOPLEFT", statusbar, "TOPLEFT", 10, 0)
		text:SetPoint("BOTTOMRIGHT", statusbar, "BOTTOMRIGHT", -10, 0)
	end
end

-- Update the dispel table after talent changes
oUF_Hank.UpdateDispel = function()
	canDispel = {
		["DEATHKNIGHT"] = {},
		["DRUID"] = {["Poison"] = true, ["Curse"] = true, ["Magic"] = (GetSpecialization() == 4)},
		["HUNTER"] = {},
		["MAGE"] = {["Curse"] = true},
		["MONK"] = {["Poison"] = true, ["Disease"] = true, ["Magic"] = (GetSpecialization() == 2)},
		["PALADIN"] = {["Poison"] = true, ["Disease"] = true, ["Magic"] = (GetSpecialization() == 1)},
		["PRIEST"] = {["Disease"] = true, ["Magic"] = (GetSpecialization() ~= 3)},
		["ROGUE"] = {},
		["SHAMAN"] = {["Curse"] = true, ["Magic"] = (GetSpecialization() == 3)},
		["WARLOCK"] = {["Magic"] = true},
		["WARRIOR"] = {},
	}
end

-- Sticky aura colors
oUF_Hank.PostUpdateIcon = function(icons, unit, icon, index, offset)
	-- We want the border, not the color for the type indication
	icon.overlay:SetVertexColor(1, 1, 1)

	local _, _, _, _, dtype, _, _, caster, _, _, _ = UnitAura(unit, index, icon.filter)
	if caster == "vehicle" then caster = "player" end

	if icon.filter == "HELPFUL" and not UnitCanAttack("player", unit) and caster == "player" and cfg["Auras" .. upper(unit)].StickyAuras.myBuffs then
		-- Sticky aura: myBuffs
		icon.icon:SetVertexColor(unpack(cfg.AuraStickyColor))
		icon.icon:SetDesaturated(false)
	elseif icon.filter == "HARMFUL" and UnitCanAttack("player", unit) and caster == "player" and cfg["Auras" .. upper(unit)].StickyAuras.myDebuffs then
		-- Sticky aura: myDebuffs
		icon.icon:SetVertexColor(unpack(cfg.AuraStickyColor))
		icon.icon:SetDesaturated(false)
	elseif icon.filter == "HARMFUL" and UnitCanAttack("player", unit) and caster == "pet" and cfg["Auras" .. upper(unit)].StickyAuras.petDebuffs then
		-- Sticky aura: petDebuffs
		icon.icon:SetVertexColor(unpack(cfg.AuraStickyColor))
		icon.icon:SetDesaturated(false)
	elseif icon.filter == "HARMFUL" and not UnitCanAttack("player", unit) and canDispel[({UnitClass("player")})[2]][dtype] and cfg["Auras" .. upper(unit)].StickyAuras.curableDebuffs then
		-- Sticky aura: curableDebuffs
		icon.icon:SetVertexColor(DebuffTypeColor[dtype].r, DebuffTypeColor[dtype].g, DebuffTypeColor[dtype].b)
		icon.icon:SetDesaturated(false)
	elseif icon.filter == "HELPFUL" and UnitCanAttack("player", unit) and UnitIsUnit(unit, caster or "") and cfg["Auras" .. upper(unit)].StickyAuras.enemySelfBuffs then
		-- Sticky aura: enemySelfBuffs
		icon.icon:SetVertexColor(unpack(cfg.AuraStickyColor))
		icon.icon:SetDesaturated(false)
	else
		icon.icon:SetVertexColor(1, 1, 1)
		icon.icon:SetDesaturated(true)
	end

	if LibMasque then
		-- size only gets set in update so we need to refresh
		LibMasque:Group("oUF_Hank", "Auras"):ReSkin()
	end
end

-- Custom filters
oUF_Hank.customFilter = function(icons, unit, icon, name, rank, texture, count, dtype, duration, timeLeft, caster)
	if caster == "vehicle" then caster = "player" end
	if icons.filter == "HELPFUL" and not UnitCanAttack("player", unit) and caster == "player" and cfg["Auras" .. upper(unit)].StickyAuras.myBuffs then
		-- Sticky aura: myBuffs
		return true
	elseif icons.filter == "HARMFUL" and UnitCanAttack("player", unit) and caster == "player" and cfg["Auras" .. upper(unit)].StickyAuras.myDebuffs then
		-- Sticky aura: myDebuffs
		return true
	elseif icons.filter == "HARMFUL" and UnitCanAttack("player", unit) and caster == "pet" and cfg["Auras" .. upper(unit)].StickyAuras.petDebuffs then
		-- Sticky aura: petDebuffs
		return true
	elseif icons.filter == "HARMFUL" and not UnitCanAttack("player", unit) and canDispel[({UnitClass("player")})[2]][dtype] and cfg["Auras" .. upper(unit)].StickyAuras.curableDebuffs then
		-- Sticky aura: curableDebuffs
		return true
	-- Usage of UnitIsUnit: Call from within focus frame will return "target" as caster if focus is targeted (player > target > focus)
	elseif icons.filter == "HELPFUL" and UnitCanAttack("player", unit) and UnitIsUnit(unit, caster or "") and cfg["Auras" .. upper(unit)].StickyAuras.enemySelfBuffs then
		-- Sticky aura: enemySelfBuffs
		return true
	else
		-- Aura is not sticky, filter is set to blacklist
		if cfg["Auras" .. upper(unit)].FilterMethod[icons.filter == "HELPFUL" and "Buffs" or "Debuffs"] == "BLACKLIST" then
			for _, v in ipairs(cfg["Auras" .. upper(unit)].BlackList) do
				if v == name then
					return false
				end
			end
			return true
		-- Aura is not sticky, filter is set to whitelist
		elseif cfg["Auras" .. upper(unit)].FilterMethod[icons.filter == "HELPFUL" and "Buffs" or "Debuffs"] == "WHITELIST" then
			for _, v in ipairs(cfg["Auras" .. upper(unit)].WhiteList) do
				if v == name then
					return true
				end
			end
			return false
		-- Aura is not sticky, filter is set to none
		else
			return true
		end
	end
end

-- Aura mouseover
oUF_Hank.OnEnterAura = function(self, icon)
	local baseSize = (icon.isDebuff and cfg.DebuffSize or cfg.BuffSize)
	local size = baseSize * cfg.AuraMagnification

	icon.cd:Hide()
	self.HighlightAura:SetSize(size, size)
	self.HighlightAura.icon:SetSize(size, size)
	self.HighlightAura.border:SetSize(size * 1.1, size * 1.1)
	self.HighlightAura:SetPoint("TOPLEFT", icon, "TOPLEFT", -1 * (size - baseSize) / 2, (size - baseSize) / 2)
	self.HighlightAura.icon:SetTexture(icon.icon:GetTexture())
	self.HighlightAura:Show()
end

-- Aura mouseout
oUF_Hank.OnLeaveAura = function(self, icon)
	icon.cd:Show()
	self.HighlightAura:Hide()
end

-- Hook aura scripts, set aura border
oUF_Hank.PostCreateIcon = function(icons, icon)
	if cfg.AuraBorder then
		-- Custom aura border
		icon.overlay:SetTexture(cfg.AuraBorder)
		icon.overlay:SetPoint("TOPLEFT", icon, "TOPLEFT", -2, 2)
		icon.overlay:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 2, -2)
		icon.overlay:SetTexCoord(0, 1, 0, 1)
		icons.showType = true
	end
	if LibMasque then
		local iconInfo = {
			Icon = icon.icon,
			Cooldown = icon.cd,
			Count = icon.count,
			Border = icon.overlay,
		}
		LibMasque:Group("oUF_Hank", "Auras"):AddButton(icon, iconInfo)
	end
	icon.cd:SetReverse(true)

	-- Aura magnification
	icon:HookScript("OnEnter", function(self) oUF_Hank.OnEnterAura(icons:GetParent(), self) end)
	icon:HookScript("OnLeave", function(self) oUF_Hank.OnLeaveAura(icons:GetParent(), self) end)
	-- Cancel player buffs on right click
	icon:HookScript("OnClick", function(_, button, down)
		if button == "RightButton" and down == false then
			if icon.filter == "HELPFUL" and UnitIsUnit("player", icons:GetParent().unit) then
				CancelUnitBuff("player", icon:GetID())
				oUF_Hank.OnLeaveAura(icons:GetParent())
			end
		end
	end)
end

-- Debuff anchoring
oUF_Hank.PreSetPosition = function(buffs, max)
	if buffs.visibleBuffs > 0 then
		-- Anchor debuff frame to bottomost buff icon, i.e the last buff row
		buffs:GetParent().Debuffs:SetPoint("TOP", buffs[buffs.visibleBuffs], "BOTTOM", 0, -cfg.AuraSpacing -2)
	else
		-- No buffs
		if buffs:GetParent().CPoints then
			buffs:GetParent().Debuffs:SetPoint("TOP", buffs:GetParent().CPoints[1], "BOTTOM", 0, -10)
		else
			buffs:GetParent().Debuffs:SetPoint("TOP", buffs:GetParent(), "BOTTOM", 0, -10)
		end
	end
end

-- Castbar
oUF_Hank.PostCastStart = function(castbar, unit, name, rank, castid)
	castbar.castIsChanneled = false
	if unit == "vehicle" then unit = "player" end

	-- Latency display
	if unit == "player" then
		-- Time between cast transmission and cast start event
		local latency = GetTime() - (castbar.castSent or 0)
		latency = latency > castbar.max and castbar.max or latency
		castbar.Latency:SetText(("%dms"):format(latency * 1e3))
		castbar.PreciseSafeZone:SetWidth(castbar:GetWidth() * latency / castbar.max)
		castbar.PreciseSafeZone:ClearAllPoints()
		castbar.PreciseSafeZone:SetPoint("TOPRIGHT")
		castbar.PreciseSafeZone:SetPoint("BOTTOMRIGHT")
		castbar.PreciseSafeZone:SetDrawLayer("BACKGROUND")
	end

	if unit ~= "focus" then
		-- Cast layout
		castbar.Text:SetJustifyH("LEFT")
		castbar.Time:SetJustifyH("LEFT")
		if cfg.CastbarIcon then castbar.Dummy.Icon:SetTexture(castbar.Icon:GetTexture()) end
	end

	-- Uninterruptible spells
	if castbar.Shield:IsShown() and UnitCanAttack("player", unit) then
		castbar.Background:SetBackdropBorderColor(unpack(cfg.colors.castbar.noInterrupt))
	else
		castbar.Background:SetBackdropBorderColor(0, 0, 0)
	end
end

oUF_Hank.PostChannelStart = function(castbar, unit, name, rank)
	castbar.castIsChanneled = true
	if unit == "vehicle" then unit = "player" end

	if unit == "player" then
		local latency = GetTime() - (castbar.castSent or 0) -- Something happened with UNIT_SPELLCAST_SENT for vehicles
		latency = latency > castbar.max and castbar.max or latency
		castbar.Latency:SetText(("%dms"):format(latency * 1e3))
		castbar.PreciseSafeZone:SetWidth(castbar:GetWidth() * latency / castbar.max)
		castbar.PreciseSafeZone:ClearAllPoints()
		castbar.PreciseSafeZone:SetPoint("TOPLEFT")
		castbar.PreciseSafeZone:SetPoint("BOTTOMLEFT")
		castbar.PreciseSafeZone:SetDrawLayer("OVERLAY")
	end

	if unit ~= "focus" then
		-- Channel layout
		castbar.Text:SetJustifyH("RIGHT")
		castbar.Time:SetJustifyH("RIGHT")
		if cfg.CastbarIcon then castbar.Dummy.Icon:SetTexture(castbar.Icon:GetTexture()) end
	end

	if castbar.Shield:IsShown() and UnitCanAttack("player", unit) then
		castbar.Background:SetBackdropBorderColor(unpack(cfg.colors.castbar.noInterrupt))
	else
		castbar.Background:SetBackdropBorderColor(0, 0, 0)
	end
end

-- Castbar animations
oUF_Hank.PostCastSucceeded = function(castbar, spell)
	-- No animation on instant casts (castbar text not set)
	if castbar.Text:GetText() == spell then
		castbar.Dummy.Fill:SetVertexColor(unpack(cfg.colors.castbar.castSuccess))
		castbar.Dummy:Show()
		castbar.Dummy.anim:Play()
	end
end

oUF_Hank.PostCastStop = function(castbar, unit, spellname, spellrank, castid)
	if not castbar.Dummy.anim:IsPlaying() then
		castbar.Dummy.Fill:SetVertexColor(unpack(cfg.colors.castbar.castFail))
		castbar.Dummy:Show()
		castbar.Dummy.anim:Play()
	end
end

oUF_Hank.PostChannelStop = function(castbar, unit, spellname, spellrank)
	if not spellname then
		castbar.Dummy.Fill:SetVertexColor(unpack(cfg.colors.castbar.castSuccess))
		castbar.Dummy:Show()
		castbar.Dummy.anim:Play()
	else
		castbar.Dummy.Fill:SetVertexColor(unpack(cfg.colors.castbar.castFail))
		castbar.Dummy:Show()
		castbar.Dummy.anim:Play()
	end
end

-- Frame constructor -----------------------------

oUF_Hank.sharedStyle = function(self, unit, isSingle)
	self:SetScript("OnEnter", UnitFrame_OnEnter)
	self:SetScript("OnLeave", UnitFrame_OnLeave)
	self:RegisterForClicks("AnyDown")

	self.colors = cfg.colors

	-- Update dispel table on talent update
	if unit == "player" then self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED", oUF_Hank.UpdateDispel) end

	-- XP, reputation
	if unit == "player" and cfg.ShowXP then
		local xprep = self:CreateFontString(nil, "OVERLAY")
		xprep:SetFontObject("UFFontMedium")
		xprep:SetPoint("RIGHT", power, "RIGHT")
		xprep:SetAlpha(0)
		self:Tag(xprep, "[xpRep]")
		self.xprep = xprep

		-- Some animation dummies
		local xprepDummy = self:CreateFontString(nil, "OVERLAY")
		xprepDummy:SetFontObject("UFFontMedium")
		xprepDummy:SetAllPoints(xprep)
		xprepDummy:SetAlpha(0)
		xprepDummy:Hide()
		local powerDummy = self:CreateFontString(nil, "OVERLAY")
		powerDummy:SetFontObject("UFFontMedium")
		powerDummy:SetAllPoints(power)
		powerDummy:Hide()
		local raidIconDummy = self:CreateTexture(nil, "OVERLAY")
		raidIconDummy:SetTexture("Interface\\AddOns\\oUF_Hank_v3\\textures\\raidicons.blp")
		raidIconDummy:SetAllPoints(self.RaidIcon)
		raidIconDummy:Hide()

		local animXPFadeIn = xprepDummy:CreateAnimationGroup()
		-- A short delay so the user needs to mouseover a short time for the xp/rep display to show up
		local delayXP = animXPFadeIn:CreateAnimation("Alpha")
		delayXP:SetChange(0)
		delayXP:SetDuration(cfg.DelayXP)
		delayXP:SetOrder(1)
		local alphaInXP = animXPFadeIn:CreateAnimation("Alpha")
		alphaInXP:SetChange(1)
		alphaInXP:SetSmoothing("OUT")
		alphaInXP:SetDuration(1.5)
		alphaInXP:SetOrder(2)

		local animPowerFadeOut = powerDummy:CreateAnimationGroup()
		local delayPower = animPowerFadeOut:CreateAnimation("Alpha")
		delayPower:SetChange(0)
		delayPower:SetDuration(cfg.DelayXP)
		delayPower:SetOrder(1)
		local alphaOutPower = animPowerFadeOut:CreateAnimation("Alpha")
		alphaOutPower:SetChange(-1)
		alphaOutPower:SetSmoothing("OUT")
		alphaOutPower:SetDuration(1.5)
		alphaOutPower:SetOrder(2)

		local animRaidIconFadeOut = raidIconDummy:CreateAnimationGroup()
		local delayIcon = animRaidIconFadeOut:CreateAnimation("Alpha")
		delayIcon:SetChange(0)
		delayIcon:SetDuration(cfg.DelayXP * .75)
		delayIcon:SetOrder(1)
		local alphaOutIcon = animRaidIconFadeOut:CreateAnimation("Alpha")
		alphaOutIcon:SetChange(-1)
		alphaOutIcon:SetSmoothing("OUT")
		alphaOutIcon:SetDuration(0.5)
		alphaOutIcon:SetOrder(2)

		animXPFadeIn:SetScript("OnFinished", function()
			xprep:SetAlpha(1)
			xprepDummy:Hide()
		end)
		animPowerFadeOut:SetScript("OnFinished", function() powerDummy:Hide() end)
		animRaidIconFadeOut:SetScript("OnFinished", function() raidIconDummy:Hide() end)

		self:HookScript("OnEnter", function(_, motion)
			if motion then
				self.power:SetAlpha(0)
				self.RaidIcon:SetAlpha(0)
				powerDummy:SetText(self.power:GetText())
				powerDummy:Show()
				xprepDummy:SetText(self.xprep:GetText())
				xprepDummy:Show()
				raidIconDummy:SetTexCoord(self.RaidIcon:GetTexCoord())
				if self.RaidIcon:IsShown() then raidIconDummy:Show() end
				animXPFadeIn:Play()
				animPowerFadeOut:Play()
				if self.RaidIcon:IsShown() then animRaidIconFadeOut:Play() end
			end
		end)

		self:HookScript("OnLeave", function()
			if animXPFadeIn:IsPlaying() then animXPFadeIn:Stop() end
			if animPowerFadeOut:IsPlaying() then animPowerFadeOut:Stop() end
			if animRaidIconFadeOut:IsPlaying() then animRaidIconFadeOut:Stop() end
			powerDummy:Hide()
			xprepDummy:Hide()
			raidIconDummy:Hide()
			self.xprep:SetAlpha(0)
			self.power:SetAlpha(1)
			self.RaidIcon:SetAlpha(1)
		end)
	end

	-- Auras
	if unit == "target" or unit == "focus" then
		-- Buffs
		self.Buffs = CreateFrame("Frame", unit .. "_Buffs", self) -- ButtonFacade needs a name
		if self.CPoints then
			self.Buffs:SetPoint("TOPLEFT", self.CPoints[1], "BOTTOMLEFT", 0, -5)
		else
			self.Buffs:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -5)
		end
		self.Buffs:SetHeight(cfg.BuffSize)
		self.Buffs:SetWidth(225)
		self.Buffs.size = cfg.BuffSize
		self.Buffs.spacing = cfg.AuraSpacing
		self.Buffs.initialAnchor = "LEFT"
		self.Buffs["growth-y"] = "DOWN"
		self.Buffs.num = cfg["Auras" .. upper(unit)].MaxBuffs
		self.Buffs.filter = "HELPFUL" -- Explicitly set the filter or the first customFilter call won't work

		self.Buffs.PostUpdateIcon = oUF_Hank.PostUpdateIcon
		self.Buffs.PostCreateIcon = oUF_Hank.PostCreateIcon
		self.Buffs.PreSetPosition = oUF_Hank.PreSetPosition
		self.Buffs.CustomFilter = oUF_Hank.customFilter

		-- Debuffs
		self.Debuffs = CreateFrame("Frame", unit .. "_Debuffs", self)
		self.Debuffs:SetPoint("LEFT", self, "LEFT", 0, 0)
		self.Debuffs:SetPoint("TOP", self, "TOP", 0, 0) -- We will reanchor this in PreAuraSetPosition
		self.Debuffs:SetHeight(cfg.DebuffSize)
		self.Debuffs:SetWidth(225)
		self.Debuffs.size = cfg.DebuffSize
		self.Debuffs.spacing = cfg.AuraSpacing
		self.Debuffs.initialAnchor = "LEFT"
		self.Debuffs["growth-y"] = "DOWN"
		self.Debuffs.num = cfg["Auras" .. upper(unit)].MaxDebuffs
		self.Debuffs.filter = "HARMFUL"

		self.Debuffs.PostUpdateIcon = oUF_Hank.PostUpdateIcon
		self.Debuffs.PostCreateIcon = oUF_Hank.PostCreateIcon
		self.Debuffs.CustomFilter = oUF_Hank.customFilter

		-- Buff magnification effect on mouseover
		self.HighlightAura = CreateFrame("Frame", nil, self)
		self.HighlightAura:SetFrameLevel(5) -- Above auras (level 3) and their cooldown overlay (4)
		self.HighlightAura:SetBackdrop({bgFile = cfg.AuraBorder})
		self.HighlightAura:SetBackdropColor(0, 0, 0, 1)
		self.HighlightAura.icon = self.HighlightAura:CreateTexture(nil, "ARTWORK")
		self.HighlightAura.icon:SetPoint("CENTER")
		self.HighlightAura.border = self.HighlightAura:CreateTexture(nil, "OVERLAY")
		self.HighlightAura.border:SetTexture(cfg.AuraBorder)
		self.HighlightAura.border:SetPoint("CENTER")
	end

	-- Class Icons
	if unit ~= "player" then
		-- nothing
	elseif playerClass == "WARLOCK" then
		-- Soul Shards / Burning Embers / Demonic Fury (reuse Blizzard's)
		local extra = _G["WarlockPowerFrame"]
		extra:SetScale(0.6)
		extra:SetParent(self)
		extra:ClearAllPoints()
		extra:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", -16, 2)
	elseif playerClass == "MONK" or playerClass == "PRIEST" or playerClass == "PALADIN" then
		-- ClassIcons: Harmony Orbs / Shadow Orbs / Holy Power
		local data = oUF_Hank.classResources[playerClass]
		self.ClassIcons = {}
		self.ClassIcons.animations = {}
		self.ClassIcons.animLastState = UnitPower("player", data.resource)

		local function initClassIconAnimation(self, i)
			self.animations[i] = self[i]:CreateAnimationGroup()
			local alphaIn = self.animations[i]:CreateAnimation("Alpha")
			alphaIn:SetChange(1)
			alphaIn:SetSmoothing("OUT")
			alphaIn:SetDuration(1)
			alphaIn:SetOrder(1)

			self.animations[i]:SetScript("OnFinished", function() self[i]:SetAlpha(1) end)
		end
		local function updateClassIconAnimation(self, current, max)
			self.animLastState = self.animLastState or 0
			if current > 0 then
				if self.animLastState < current then
					-- Play animation only when we gain power
					self[current]:SetAlpha(0)
					self.animations[current]:Play();
				end
			else
				for i = 1, max do
					-- no holy power, stop all running animations
					self.animLastState = current
					if self.animations[i]:IsPlaying() then
						self.animations[i]:Stop()
					end
				end
			end
			self.animLastState = current
		end

		for index = 1, 5 do
			local texture = self:CreateTexture(nil, "OVERLAY")
			texture:SetSize(data.size[1] or 28, data.size[2] or 28)
			texture:SetTexture(data.active[1])
			if data.active[2] then
				texture:SetTexCoord(unpack(data.active[2]))
			end

			if playerClass == "PALADIN" then
				texture:SetVertexColor(unpack(cfg.colors.power.HOLY_POWER))
			end

			local background = self:CreateTexture(nil, "ARTWORK")
			background:SetAllPoints(texture)
			background:SetTexture(data.inactive[1])
			if data.inactive[2] then
				background:SetTexCoord(unpack(data.inactive[2]))
			end
			texture.bg = background

			if index == 1 then
				texture:SetPoint("TOPLEFT", self, "BOTTOMRIGHT", -1*(data.size[1] or 28)*5, 0)
			else
				texture:SetPoint("LEFT", self.ClassIcons[index - 1], "RIGHT", 0, 0)
			end

			self.ClassIcons[index] = texture
			if initClassIconAnimation then initClassIconAnimation(self.ClassIcons, index) end
		end

		self.ClassIcons.PostUpdate = function(self, current, max, maxHasChanged)
			if maxHasChanged then
				local mine, anchor, yours = self[1]:GetPoint()
				self[1]:SetPoint(mine, anchor, yours, -1*(data.size[1] or 28)*max, 0)
				for i = 1, 5 do
					if i <= max then self[i].bg:Show() else self[i].bg:Hide() end
				end
			end
			if updateClassIconAnimation then
				updateClassIconAnimation(self, current, max)
			end
		end
	end

	-- Support for oUF_SpellRange. The built-in oUF range check sucks :/
	if (unit == "target" or unit == "focus") and cfg.RangeFade and IsAddOnLoaded("oUF_SpellRange") then
		self.SpellRange = {
			insideAlpha = 1,
			outsideAlpha = cfg.RangeFadeOpacity
		}
	end

	-- Castbar
	if cfg.Castbar and (unit == "player" or unit == "target" or unit == "focus") then
		-- StatusBar
		local cb = CreateFrame("StatusBar", nil, self)
		cb:SetStatusBarTexture(cfg.CastbarTexture)
		cb:SetStatusBarColor(unpack(cfg.colors.castbar.bar))
		cb:SetSize(cfg.CastbarSize[1], cfg.CastbarSize[2])
		if unit == "player" then
			cb:SetPoint("LEFT", self, "RIGHT", (cfg.CastbarIcon and (cfg.CastbarSize[2] + 5) or 0) + 5 + cfg.CastbarMargin[1], cfg.CastbarMargin[2])
		elseif unit == "focus" then
			cb:SetSize(0.8 * cfg.CastbarSize[1], cfg.CastbarSize[2])
			cb:SetPoint("LEFT", self, "RIGHT", -10 - cfg.CastbarFocusMargin[1], cfg.CastbarFocusMargin[2])
		else
			cb:SetPoint("RIGHT", self, "LEFT", (cfg.CastbarIcon and (-cfg.CastbarSize[2] - 5) or 0) - 5 - cfg.CastbarMargin[1], cfg.CastbarMargin[2])
		end

		-- BG
		cb.Background = CreateFrame("Frame", nil, cb)
		cb.Background:SetFrameStrata("BACKGROUND")
		cb.Background:SetPoint("TOPLEFT", cb, "TOPLEFT", -5, 5)
		cb.Background:SetPoint("BOTTOMRIGHT", cb, "BOTTOMRIGHT", 5, -5)

		local backdrop = {
			bgFile = cfg.CastbarBackdropTexture,
			edgeFile = cfg.CastbarBorderTexture,
			tileSize = 16, edgeSize = 16, tile = true,
			insets = {left = 4, right = 4, top = 4, bottom = 4}
		}

		cb.Background:SetBackdrop(backdrop)
		cb.Background:SetBackdropColor(0.22, 0.22, 0.19)
		cb.Background:SetBackdropBorderColor(0, 0, 0, 1)
		cb.Background:SetAlpha(0.8)

		-- Spark
		cb.Spark = cb:CreateTexture(nil, "OVERLAY")
		cb.Spark:SetSize(20, 35 * 2.2)
		cb.Spark:SetBlendMode("ADD")

		-- Spell name
		cb.Text = cb:CreateFontString(nil, "OVERLAY")
		cb.Text:SetTextColor(unpack(cfg.colors.castbar.text))
		if unit == "focus" then
			cb.Text:SetFont(unpack(cfg.CastBarBig))
			cb.Text:SetShadowOffset(1.5, -1.5)
			cb.Text:SetPoint("LEFT", 3, 0)
			cb.Text:SetPoint("RIGHT", -3, 0)
		else
			cb.Text:SetFont(unpack(cfg.CastBarMedium))
			cb.Text:SetShadowOffset(0.8, -0.8)
			cb.Text:SetPoint("LEFT", 3, 9)
			cb.Text:SetPoint("RIGHT", -3, 9)
		end

		if unit ~= "focus" then
			-- Icon
			if cfg.CastbarIcon then
				cb.Icon = cb:CreateTexture(nil, "OVERLAY")
				cb.Icon:SetSize(cfg.CastbarSize[2], cfg.CastbarSize[2])
				cb.Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
				if unit == "player" or unit == "focus" then
					cb.Icon:SetPoint("RIGHT", cb, "LEFT", -5, 0)
				else
					cb.Icon:SetPoint("LEFT", cb, "RIGHT", 5, 0)
				end
			end

			-- Cast time
			cb.Time = cb:CreateFontString(nil, "OVERLAY")
			cb.Time:SetFont(unpack(cfg.CastBarBig))
			cb.Time:SetTextColor(unpack(cfg.colors.castbar.text))
			cb.Time:SetShadowOffset(0.8, -0.8)
			cb.Time:SetPoint("TOP", cb.Text, "BOTTOM", 0, -3)
			cb.Time:SetPoint("LEFT", 3, 9)
			cb.Time:SetPoint("RIGHT", -3, 9)
			cb.CustomTimeText = function(_, t)
				cb.Time:SetText(("%.2f / %.2f"):format(cb.castIsChanneled and t or cb.max - t, cb.max))
			end
			cb.CustomDelayText = function(_, t)
				cb.Time:SetText(("%.2f |cFFFF5033%s%.2f|r"):format(cb.castIsChanneled and t or cb.max - t, cb.castIsChanneled and "-" or "+", cb.delay))
			end
		end

		-- Latency
		if unit == "player" then
			cb.PreciseSafeZone = cb:CreateTexture(nil, "BACKGROUND")
			cb.PreciseSafeZone:SetTexture(cfg.CastbarBackdropTexture)
			cb.PreciseSafeZone:SetVertexColor(unpack(cfg.colors.castbar.latency))

			cb.Latency = cb:CreateFontString(nil, "OVERLAY")
			cb.Latency:SetFont(unpack(cfg.CastBarSmall))
			cb.Latency:SetTextColor(unpack(cfg.colors.castbar.latencyText))
			cb.Latency:SetShadowOffset(0.8, -0.8)
			cb.Latency:SetPoint("CENTER", cb.PreciseSafeZone)
			cb.Latency:SetPoint("BOTTOM", cb.PreciseSafeZone)

			self:RegisterEvent("UNIT_SPELLCAST_SENT", function(_, _, caster)
				if caster == "player" or caster == "vehicle" then
					cb.castSent = GetTime()
				end
			end)
		end

		-- Animation dummy
		cb.Dummy = CreateFrame("Frame", nil, self)
		cb.Dummy:SetAllPoints(cb.Background)
		cb.Dummy:SetBackdrop(backdrop)
		cb.Dummy:SetBackdropColor(0.22, 0.22, 0.19)
		cb.Dummy:SetBackdropBorderColor(0, 0, 0, 1)
		cb.Dummy:SetAlpha(0.8)

		cb.Dummy.Fill = cb.Dummy:CreateTexture(nil, "OVERLAY")
		cb.Dummy.Fill:SetTexture(cfg.CastbarTexture)
		cb.Dummy.Fill:SetAllPoints(cb)

		if unit ~= "focus" and cfg.CastbarIcon then
			cb.Dummy.Icon = cb.Dummy:CreateTexture(nil, "OVERLAY")
			cb.Dummy.Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
			cb.Dummy.Icon:SetAllPoints(cb.Icon)
		end

		cb.Dummy:Hide()

		cb.Dummy.anim = cb.Dummy:CreateAnimationGroup()
		local alphaOut = cb.Dummy.anim:CreateAnimation("Alpha")
		alphaOut:SetChange(-1)
		alphaOut:SetDuration(1)
		alphaOut:SetOrder(0)

		cb:SetScript("OnShow", function()
			if cb.Dummy.anim:IsPlaying() then cb.Dummy.anim:Stop() end
			cb.Dummy:Hide()
		end)

		cb.Dummy.anim:SetScript("OnFinished", function() cb.Dummy:Hide() end)

		self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", function(_, _, unit, spell, rank)
			if UnitIsUnit(unit, self.unit) and not cb.castIsChanneled then
				oUF_Hank.PostCastSucceeded(cb, spell)
			end
		end)

		-- Shield dummy
		cb.Shield = cb:CreateTexture(nil, "BACKGROUND")

		cb.PostCastStart = oUF_Hank.PostCastStart
		cb.PostChannelStart = oUF_Hank.PostChannelStart
		cb.PostCastStop = oUF_Hank.PostCastStop
		cb.PostChannelStop = oUF_Hank.PostChannelStop

		self.Castbar = cb
	end

	-- Initial size
	if unit == "player" then
		self:SetSize(175, 50)
	elseif  unit == "target" or unit == "focus" then
		self:SetSize(250, 50)
	elseif unit== "pet" or unit == "targettarget" or unit == "targettargettarget" or unit == "focustarget" then
		self:SetSize(125, 16)
	elseif unit:find("boss") then
		self:SetSize(250, 50)
	end
end
