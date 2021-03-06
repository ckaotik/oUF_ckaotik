local addonName, ns, _ = ...

local LibMasque = LibStub('Masque', true)
local LibDispellable = LibStub('LibDispellable-1.0')

local NO_BUFFS_HEIGHT = 0.000000001

local function OnEnter(self)
	local bigSize = (self:GetParent().size or 16) * 2
	self:SetFrameStrata('HIGH')
	self:SetSize(bigSize, bigSize)
	if LibMasque then
		LibMasque:Group(addonName, 'Auras'):ReSkin()
	end
end
local function OnLeave(self)
	local size = self:GetParent().size or 16
	self:SetFrameStrata('MEDIUM')
	self:SetSize(size, size)
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
	if LibMasque then
		icon:SetSize(element.size or 16, element.size or 16)
		LibMasque:Group(addonName, 'Auras'):AddButton(icon, {
			Icon = icon.icon,
			Cooldown = icon.cd,
			Count = icon.count,
			Border = icon.overlay,
		})
	end

	local point, relativeTo, relativePoint, xOffset, yOffset = icon.count:GetPoint()
	icon.count:SetPoint(point, relativeTo, relativePoint, 0, yOffset)
	icon.cd:SetReverse(true)

	icon:HookScript('OnEnter', OnEnter)
	icon:HookScript('OnLeave', OnLeave)
	icon:HookScript('OnClick', OnClick)
end

local function PostUpdateIcon(element, unit, button, index, offset)
	-- local name, texture, count, debuffType, duration, timeLeft, caster, canStealOrPurge, shouldConsolidate, spellID, canApplyAura, isBossDebuff, isCastByPlayer = UnitAura(unit, index, element.filter)

	if button.owner == 'player' or button.isPlayer then
		button.icon:SetDesaturated(false)
	else
		button.icon:SetDesaturated(true)
	end
end

local function PostUpdateBuffs(element, unit)
	local numBuffs = element.visibleBuffs
	if numBuffs and numBuffs > 0 then
		local lastBuff = element[numBuffs]
		element:SetHeight(math.abs((lastBuff:GetBottom() or element.size) - (element:GetTop() or 0)))
	else
		element:SetHeight(NO_BUFFS_HEIGHT)
	end
end

local function CustomFilter(element, unit, icon, ...)
	local name, texture, count, debuffType, duration, timeLeft, caster, canStealOrPurge, shouldConsolidate, spellID, canApplyAura, isBossDebuff, isCastByPlayer = ... -- UnitAura(unit, _index)

	-- global lists
	if ns.Find(ns.db.auras.showList, spellID) or ns.Find(ns.db.auras.showList, name) then
		return true
	elseif ns.Find(ns.db.auras.hideList, spellID) or ns.Find(ns.db.auras.hideList, name) then
		return false
	end

	local isMine = caster == 'player' or caster == 'pet' or caster == 'vehicle'
	local isEnemy = not UnitCanAssist(unit, 'player')

	-- blizzard visibility settings
	local hasCustom, alwaysShowMine, showForMySpec = SpellGetVisibilityInfo(spellID,
		(isEnemy and "ENEMY_TARGET") or (InCombatLockdown() and "RAID_INCOMBAT") or "RAID_OUTOFCOMBAT")
	if hasCustom and (showForMySpec or (alwaysShowMine and isMine)) then
		return true
	end

	if isEnemy and not icon.isDebuff then
		return true
	end

	-- our own visibility rules
	if caster == 'player' or caster == 'pet' or caster == 'vehicle' then
		-- our own effects
		return true
	elseif isBossDebuff and not isCastByPlayer then
		return true
	elseif (caster and UnitIsUnit(caster, unit)) then
		-- self-buffs & procs
		return true
	elseif canStealOrPurge or LibDispellable:CanDispel(unit, isEnemy, debuffType, spellID) then
		-- TODO: show any stealable or only those we can dispell?
		return true
	end

	-- print('hiding', unit, isEnemy, name, debuffType, caster, isCastByPlayer, canStealOrPurge, isBossDebuff, spellID)
	return false
end

local function CustomBossFilter(element, unit, icon, ...)
	local name, texture, count, debuffType, duration, timeLeft, caster, canStealOrPurge, shouldConsolidate, spellID, canApplyAura, isBossDebuff, isCastByPlayer = ... -- UnitAura(unit, _index)

	local isMine = caster == 'player' or caster == 'pet' or caster == 'vehicle'
	local hasCustom, alwaysShowMine, showForMySpec = SpellGetVisibilityInfo(spellID, 'ENEMY_TARGET')
	if hasCustom then
		return showForMySpec or (alwaysShowMine and isMine)
	else
		return isMine or isBossDebuff
	end
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

	auras.CustomFilter   = unit:find('^boss') and CustomBossFilter or CustomFilter
	auras.PostCreateIcon = PostCreateIcon
	auras.PostUpdateIcon = PostUpdateIcon

	if not isDebuffs then
		auras.PostUpdate = PostUpdateBuffs
	end

	return auras
end
