local addonName, ns, _ = ...

-- GLOBALS: _G, oUF_ckaotikDB, GameTooltip, MAX_BOSS_FRAMES, oUF
-- GLOBALS: pairs, type, gsub

local Movable = LibStub('LibMovable-1.0', true)
local oUF = ns.oUF or oUF
assert(oUF, "<name> was unable to locate oUF install.")

-- TODO: Warlock bars, castbar

-- ================================================
--  Setup
-- ================================================
local function UpdateRaidIcon(self, unit)
	if unit == self.unit then
		self.RaidIcon.ForceUpdate(self.RaidIcon)
	end
end

local function Initialize()
	if not oUF_ckaotikDB then oUF_ckaotikDB = {} end
	ns.db = oUF_ckaotikDB

	-- set up default settings
	for key, value in pairs({
		position = {},
		auras = {
			showList = {},
			hideList = {},
		},
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
		if not Movable then return end
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
			{ 'player',             'RIGHT', 'UIParent', 'CENTER', -290, -156 },
			{ 'pet',                'BOTTOMRIGHT', 'oUF_ckaotikPlayer', 'TOPRIGHT' },
			{ 'target',             'LEFT', 'UIParent', 'CENTER',  290, -156 },
			{ 'targettarget',       'BOTTOMLEFT', 'oUF_ckaotikTarget', 'TOPLEFT' },
			{ 'targettargettarget', 'BOTTOMLEFT', 'oUF_ckaotikTargetTarget', 'TOPLEFT' },
			{ 'focus',              'BOTTOM', 'UIParent', 'BOTTOM', 0, 360 },
			{ 'focustarget',        'BOTTOMLEFT',  'oUF_ckaotikFocus', 'TOPLEFT', 0, 5 },
			{ 'boss1',              'RIGHT',  'UIParent', -70, 0 },
		}
		for i = 2, MAX_BOSS_FRAMES do
			table.insert(unitFrames, { 'boss'..i,  'TOPRIGHT', 'oUF_ckaotikBoss'..(i-1), 'BOTTOMRIGHT', -80, -5 })
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

--[[
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
--]]
