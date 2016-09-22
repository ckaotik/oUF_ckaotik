local addonName, ns, _ = ...

-- GLOBALS:
--[[ local AceTimer = LibStub:GetLibrary("AceTimer-3.0", true)
local awayTimer, awayTimeInfo = nil, {}
local function UpdateAwayTime(unit)
	if UnitIsAFK(unit) then
		awayTimeInfo[unit] = (awayTimeInfo[unit] or 0) + 0.25
	else
		awayTimeInfo[unit] = nil
		if ns.Count(awayTimeInfo) < 1 then
			AceTimer:CancelTimer(awayTimer)
		end
	end
end --]]

-- local AbbreviateLargeNumbers
-- do
-- 	-- change ' K' to 'k'
-- 	SECOND_NUMBER_CAP = SECOND_NUMBER_CAP:trim():lower()
-- 	FIRST_NUMBER_CAP  = FIRST_NUMBER_CAP:trim():lower()
-- 	AbbreviateLargeNumbers = _G.AbbreviateLargeNumbers
-- end

local statusTexture = 'Interface\\AddOns\\'..addonName..'\\media\\statusicons'
oUF.Tags.Events['ckaotik:combat'] = 'PLAYER_REGEN_DISABLED PLAYER_REGEN_ENABLED'
oUF.Tags.SharedEvents["PLAYER_REGEN_DISABLED"] = true
oUF.Tags.SharedEvents["PLAYER_REGEN_ENABLED"]  = true
oUF.Tags.Methods['ckaotik:combat'] = function(unit)
	if UnitAffectingCombat(unit) then
		return '|T'..statusTexture..':24:24:0:0:256:32:0:24:0:24|t'
	end
end
oUF.Tags.Events['ckaotik:resting'] = 'PLAYER_UPDATE_RESTING'
oUF.Tags.SharedEvents["PLAYER_UPDATE_RESTING"] = true
oUF.Tags.Methods['ckaotik:resting'] = function(unit)
	if unit == 'player' and IsResting() then
		return '|T'..statusTexture..':24:24:0:0:256:32:24:48:0:24|t'
	end
end
oUF.Tags.Events['ckaotik:leader'] = 'PARTY_LEADER_CHANGED'
oUF.Tags.SharedEvents["PARTY_LEADER_CHANGED"] = true
oUF.Tags.Methods['ckaotik:leader'] = function(unit)
	if UnitIsGroupLeader(unit) then
		return '|T'..statusTexture..':24:24:0:0:256:32:48:72:0:24|t'
	end
end
oUF.Tags.Events['ckaotik:masterlooter'] = 'PARTY_LOOT_METHOD_CHANGED'
oUF.Tags.SharedEvents["PARTY_LOOT_METHOD_CHANGED"] = true
oUF.Tags.Methods['ckaotik:masterlooter'] = function(unit)
	if unit ~= 'player' then return end

	local method, partyMaster, raidMaster = GetLootMethod()
	if method == 'master' and (
		(unit == 'player' and partyMaster and partyMaster == 0)
		or (partyMaster and UnitIsUnit(unit, 'party'..partyMaster))
		or (raidMaster and UnitIsUnit(unit, 'raid'..raidMaster))) then
		return '|T'..statusTexture..':24:24:0:0:256:32:72:96:0:24|t'
	end
end
oUF.Tags.Events['ckaotik:pvp'] = 'UNIT_FACTION'
oUF.Tags.Methods['ckaotik:pvp'] = function(unit)
	if UnitIsPVP(unit) or UnitIsPVPFreeForAll(unit) then
		return '|T'..statusTexture..':24:24:0:0:256:32:96:120:0:24|t'
	end
end
oUF.Tags.Methods['ckaotik:assistant'] = function(unit)
	if UnitInRaid(unit) and UnitIsGroupAssistant(unit) and not UnitIsGroupLeader(unit) then
		return '|T'..statusTexture..':24:24:0:0:256:32:120:144:0:24|t'
	end
end

oUF.Tags.Events['ckaotik:power'] = strjoin(' ', oUF.Tags.Events['curpp'], oUF.Tags.Events['maxpp'])
oUF.Tags.Methods['ckaotik:power'] = function(unit)
	if UnitIsGhost(unit) or not UnitIsConnected(unit) then return end
	local current, max = UnitPower(unit), UnitPowerMax(unit)
	local powerType, powerToken, altR, altG, altB = UnitPowerType(unit)
	if powerType ~= ADDITIONAL_POWER_BAR_INDEX then
		-- Display mana instead of special power.
		powerToken = _G.ADDITIONAL_POWER_BAR_NAME
		current = UnitPower(unit, ADDITIONAL_POWER_BAR_INDEX)
		max = UnitPowerMax(unit, ADDITIONAL_POWER_BAR_INDEX)
	end

	local text = AbbreviateLargeNumbers(max)
	if max == 0 then
		return
	elseif current == max then
		text = AbbreviateLargeNumbers(max)
	elseif current ~= max then
		text = string.format('%s/%s', AbbreviateLargeNumbers(current), text)
	end

	local colorTable = _COLORS.power[powerToken]
	return (colorTable and Hex(colorTable)
		or altR and RGBToColorCode(altR, altG, altB)
		or '') .. text .. '|r'
end

oUF.Tags.Events['ckaotik:health'] = strjoin(' ', oUF.Tags.Events['curhp'], oUF.Tags.Events['maxhp'])
oUF.Tags.Methods['ckaotik:health'] = function(unit)
	local current, max = UnitHealth(unit), UnitHealthMax(unit)
	local text = AbbreviateLargeNumbers(max)
	if current ~= max then
		text = string.format('%s/%s', AbbreviateLargeNumbers(current), text)
	end
	return text
end

oUF.Tags.Events['ckaotik:unitcolor'] = 'UNIT_REACTION UNIT_FACTION'
oUF.Tags.Methods['ckaotik:unitcolor'] = function(unit)
	local color
	if UnitIsPlayer(unit) then
		-- or (health.colorClassNPC and not UnitIsPlayer(unit))
		-- or (health.colorClassPet and UnitPlayerControlled(unit) and not UnitIsPlayer(unit)) then
		local _, class = UnitClass(unit)
		color = _COLORS.class[class]
	elseif not UnitPlayerControlled(unit) and UnitIsTapDenied(unit) then
		color = _COLORS.tapped
	elseif not UnitIsConnected(unit) then
		color = _COLORS.disconnected
	elseif UnitFactionGroup(unit) and not UnitIsPVP('player') and UnitIsPVP(unit) and UnitIsEnemy(unit, 'player') then
        color = _COLORS.reaction[1] -- hostile
    elseif UnitReaction(unit, 'player') then
		color = _COLORS.reaction[UnitReaction(unit, 'player')]
	else
		color = _COLORS.health
	end
	return Hex(color)
end

oUF.Tags.Events['ckaotik:youname'] = oUF.Tags.Events['name']
oUF.Tags.Methods['ckaotik:youname'] = function(unit)
	local color = _TAGS['ckaotik:unitcolor'](unit)
	local name = UnitName(unit)

	if UnitIsUnit(unit, 'player') or (UnitHasVehicleUI('player') and UnitIsUnit(unit, 'vehicle')) then
		name = _G.UNIT_YOU

		local target = unit:find('target$')
		if target and target ~= 1 then
			target = unit:sub(1, target-1)
			if UnitIsEnemy(target, 'player') then
				color = Hex(_COLORS.reaction[1])
			end
		end
	end
	return color .. name .. '|r'
end

oUF.Tags.Events['ckaotik:cptarget'] = 'UNIT_COMBO_POINTS' -- oUF.Tags.Events['cpoints']
oUF.Tags.Methods['ckaotik:cptarget'] = function(unit)
	local points = GetComboPoints(UnitHasVehicleUI(unit) and 'vehicle' or unit, 'target')
	if points > 0 then
		local color = _TAGS['ckaotik:unitcolor']('target')
		local name = UnitName('target')

		return color .. name .. '|r'
	else
		-- return _G.GRAY_FONT_COLOR_CODE .. _G.SPELL_FAILED_BAD_IMPLICIT_TARGETS .. '|r'
	end
end

oUF.Tags.Events["ckaotik:threat"] = "UNIT_THREAT_LIST_UPDATE"
oUF.Tags.Methods["ckaotik:threat"] = function(unit)
	local tankThreat, tankUnit = 0, nil
	local otherThreat, otherUnit

	-- our own threat
	local isTanking, status, playerThreat = UnitDetailedThreatSituation('player', unit)
	if playerThreat and playerThreat > tankThreat then
		otherThreat, otherUnit = tankThreat, tankUnit
		tankThreat = playerThreat
		tankUnit = 'player'
	end
	-- our pet's threat
	local _, _, unitThreat = UnitDetailedThreatSituation('pet', unit)
	if unitThreat and unitThreat > tankThreat then
		otherThreat, otherUnit = tankThreat, tankUnit
		tankThreat = unitThreat
		tankUnit = 'pet'
	end

	local unitPrefix = IsInRaid() and 'raid' or 'party'
	for i = 1, GetNumGroupMembers() do
		-- check group units for their threat
		_, _, unitThreat = UnitDetailedThreatSituation(unitPrefix..i, unit)
		if unitThreat and unitThreat > tankThreat then
			otherThreat, otherUnit = tankThreat, tankUnit
			tankThreat = unitThreat
			tankUnit = unitPrefix..i
		end
		-- check their pets, too
		_, _, unitThreat = UnitDetailedThreatSituation(unitPrefix..'pet'..i, unit)
		if unitThreat and unitThreat > tankThreat then
			otherThreat, otherUnit = tankThreat, tankUnit
			tankThreat = unitThreat
			tankUnit = unitPrefix..i
		end
	end

	-- local isTank = GetSpecializationRole(GetSpecialization()) == 'TANK'
	-- local isOkay = (isTanking and true or false) == isTank
	-- local nameColor = Hex(isOkay and _COLORS.reaction[8] or _COLORS.reaction[1])

	if tankUnit and otherUnit then
		if tankUnit ~= 'player' then
			-- make sure our threat is visible
			otherUnit = 'player'
			otherThreat = playerThreat
		end

		return string.format('%2$s @%3$s%4$d%%|r', '', _TAGS['ckaotik:youname'](otherUnit), _TAGS['threatcolor']('player'), otherThreat)

		-- Mrtank > Aggromage @99%
		-- return string.format('%1$s|r › %2$s @%3$s%4$d%%|r', _TAGS['ckaotik:youname'](tankUnit),
		--	_TAGS['ckaotik:youname'](otherUnit), _TAGS['threatcolor']('player'), otherThreat)
	end
end

oUF.Tags.Events['ckaotik:altpower']  = 'UNIT_POWER_BAR_SHOW UNIT_POWER_BAR_HIDE UNIT_POWER UNIT_MAXPOWER'
oUF.Tags.Methods['ckaotik:altpower'] = function(unit)
	local barType, minPower, startInset, endInset, smooth, hideFromOthers, showOnRaid, opaqueSpark, opaqueFlash, powerName, powerTooltip = UnitAlternatePowerInfo(unit)
	if not barType then return end

	local current = UnitPower(unit, _G.ALTERNATE_POWER_INDEX)
	local max  = UnitPowerMax(unit, _G.ALTERNATE_POWER_INDEX)

	local text = AbbreviateLargeNumbers(max)
	if max == 0 then
		return
	elseif current == max then
		text = AbbreviateLargeNumbers(max)
	elseif current ~= max then
		text = string.format('%s/%s', AbbreviateLargeNumbers(current), text)
	end

	local texture, altR, altG, altB, altA = UnitAlternatePowerTextureInfo(unit, 2) -- textureIndex: 2
	local colorTable = nil -- _COLORS.power[powerToken]
	return (colorTable and Hex(colorTable)
		or altR and RGBToColorCode(altR, altG, altB, altA)
		or '') .. text .. '|r'
end


-- Blizzard bug: boss frames don't update on UNIT_HEALTH but only UNIT_HEALTH_FREQUENT
oUF.Tags.Events['perhp:boss']  = oUF.Tags.Events['perhp'] .. ' UNIT_HEALTH_FREQUENT UNIT_TARGETABLE_CHANGED INSTANCE_ENCOUNTER_ENGAGE_UNIT'
oUF.Tags.Methods['perhp:boss'] = oUF.Tags.Methods['perhp']

oUF.Tags.Events['name:boss']  = 'UNIT_NAME_UPDATE UNIT_TARGETABLE_CHANGED INSTANCE_ENCOUNTER_ENGAGE_UNIT'
oUF.Tags.SharedEvents['INSTANCE_ENCOUNTER_ENGAGE_UNIT'] = true
oUF.Tags.Methods['name:boss'] = oUF.Tags.Methods['name']
--[[ function(unit, ...)
	local name = UnitName(unit)
	return name
end --]]

oUF.Tags.Events['afkdnd'] = 'PLAYER_FLAGS_CHANGED'
oUF.Tags.Methods['afkdnd'] = function(unit)
	if UnitIsAFK(unit) then
		--[[ if AceTimer and not awayTimer then
			awayTimer = AceTimer:ScheduleRepeatingTimer(UpdateAwayTime, unit)
		end --]]
		return CHAT_FLAG_AFK
	elseif UnitIsDND(unit) then
		return CHAT_FLAG_DND
	end
end
