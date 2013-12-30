local addonName, ns, _ = ...

local LibMasque = LibStub('Masque', true)
local LibDispellable = LibStub('LibDispellable-1.0')

local NO_BUFFS_HEIGHT = -4 -- 0.000000001

local function OnEnter(self)
	local bigSize = (self:GetParent().size or 16) * 2
	self:SetSize(bigSize, bigSize)
	self:SetFrameStrata('HIGH')
	if LibMasque then
		LibMasque:Group(addonName, 'Auras'):ReSkin()
	end
end
local function OnLeave(self)
	local size = self:GetParent().size or 16
	self:SetSize(size, size)
	self:SetFrameStrata('MEDIUM')
	if LibMasque then
		LibMasque:Group(addonName, 'Auras'):ReSkin()
	end
end
local function OnClick(self, btn, up)
	if not InCombatLockdown() and self.filter == 'HELPFUL' then
		CancelUnitBuff(self.owner, self:GetID())
	end
end

local function PostCreateIcon(element, icon)
	icon.cd:SetReverse(true)
	if LibMasque then
		icon:SetSize(element.size or 16, element.size or 16)
		LibMasque:Group(addonName, 'Auras'):AddButton(icon, {
			Icon = icon.icon,
			Cooldown = icon.cd,
			Count = icon.count,
			Border = icon.overlay,
		})
	end

	icon:HookScript('OnEnter', OnEnter)
	icon:HookScript('OnLeave', OnLeave)
	icon:HookScript('OnClick', OnClick)
end

local function PostUpdateBuffs(element, unit)
	local numBuffs = element.visibleBuffs
	if numBuffs and numBuffs > 0 then
		local lastBuff = element[numBuffs]
		element:SetHeight(math.abs(lastBuff:GetBottom() - element:GetTop()))
	else
		element:SetHeight(NO_BUFFS_HEIGHT)
	end
end

--[[
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
	elseif icons.filter == "HARMFUL" and not UnitCanAttack("player", unit) and canDispel[ ({UnitClass("player")})[2] ][dtype] and cfg["Auras" .. upper(unit)].StickyAuras.curableDebuffs then
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
--]]
local function CustomFilter(element, unit, icon, ...)
	local name, rank, texture, count, debuffType, duration, timeLeft, caster, canStealOrPurge, shouldConsolidate, spellID, canApplyAura, isBossDebuff, isCastByPlayer = ... -- UnitAura(unit, _index)

	-- global lists
	if ns.Find(ns.db.auras.showList, spellID) or ns.Find(ns.db.auras.showList, name) then
		return true
	elseif ns.Find(ns.db.auras.hideList, spellID) or ns.Find(ns.db.auras.hideList, name) then
		return false
	end

	local isMine = caster == 'player' or caster == 'pet' or caster == 'vehicle'
	local isEnemy = UnitIsEnemy(unit, 'player')

	-- blizzard visibility settings
	local hasCustom, alwaysShowMine, showForMySpec = SpellGetVisibilityInfo(spellID, "ENEMY_TARGET")
	if hasCustom and (showForMySpec or (alwaysShowMine and isMine)) then
		return true
	end

	-- our own visibility rules
	if caster == 'player' or caster == 'pet' or caster == 'vehicle' then
		-- our own effects
		return true
	elseif isBossDebuff then -- or not isCastByPlayer then
		return true
	elseif caster and UnitIsUnit(caster, unit) then
		-- self-buffs & procs
		return true
	elseif canStealOrPurge or LibDispellable:CanDispel(unit, isEnemy, debuffType, spellID) then
		-- TODO: show any stealable or only those we can dispell?
		return true
	end

	-- print('hiding', unit, isEnemy, name, debuffType, caster, isCastByPlayer, canStealOrPurge, isBossDebuff, spellID)
	return false
end

function ns.Auras(self, unit, isDebuffs)
	local size, spacing = 20, 2
	local auras = CreateFrame('Frame', nil, self)
	      auras:SetSize((size+spacing)*8, isDebuffs and (size+spacing)*2 or NO_BUFFS_HEIGHT)
	      auras.size 		  = size
	      auras.spacing 	  = spacing
	      auras.initialAnchor = 'TOPLEFT'
	      auras['growth-x']   = 'RIGHT'
	      auras['growth-y']   = 'DOWN'

	auras.CustomFilter = CustomFilter
	auras.PostCreateIcon = PostCreateIcon

	if not isDebuffs then
		auras.PostUpdate = PostUpdateBuffs
	end

	return auras
end
