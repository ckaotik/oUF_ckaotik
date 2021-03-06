local addonName, ns, _ = ...

-- TODO: Warlock
-- http://wow.go-hero.net/framexml/17688/ShardBar.lua
-- Interface\\PLAYERFRAME\\Warlock-DestructionUI-Green / Interface\\PLAYERFRAME\\Warlock-DestructionUI / Interface\\PLAYERFRAME\\Warlock-DemonologyUI

--[[
	AlternatePowerBar
		https://www.townlong-yak.com/framexml/beta/AlternatePowerBar.lua
	UnitPowerBarAlt
		https://www.townlong-yak.com/framexml/beta/UnitPowerBarAlt.lua
	ClassPowerBar
		https://www.townlong-yak.com/framexml/beta/ClassPowerBar.lua
	ComboFrame
		https://www.townlong-yak.com/framexml/beta/ComboFrame.lua
	ComboFramePlayer
		https://www.townlong-yak.com/framexml/beta/ComboFramePlayer.lua
	EclipseBarFrame
		https://www.townlong-yak.com/framexml/beta/EclipseBarFrame.lua
	InsanityBar
		https://www.townlong-yak.com/framexml/beta/InsanityBar.lua
	MageArcaneChargesBar
		https://www.townlong-yak.com/framexml/beta/MageArcaneChargesBar.lua
	PaladinPowerBar
		https://www.townlong-yak.com/framexml/beta/PaladinPowerBar.lua
	PriestBar
		https://www.townlong-yak.com/framexml/beta/PriestBar.lua
	RuneFrame
		https://www.townlong-yak.com/framexml/beta/RuneFrame.lua
	ShardBar
		https://www.townlong-yak.com/framexml/beta/ShardBar.lua
	TotemFrame
		https://www.townlong-yak.com/framexml/beta/TotemFrame.lua
	DestinyFrame
		https://www.townlong-yak.com/framexml/beta/DestinyFrame.lua
--]]

-- Icons are tiled horizontally, thus the .fill graphic must be on the left
-- edge of the texture file and .size must match the actual width.
local config = {
	['PALADIN'] = {
		bg   = {'Interface\\AddOns\\'..addonName..'\\media\\HolyPower', {18/64, 36/64, 0, 18/32 }},
		fill = {'Interface\\AddOns\\'..addonName..'\\media\\HolyPower', {0, 18/64, 13/32, 32/32 }},
		size = {18, 19},
		padding = 0,
		glowPadding = 0,
		showEmpty = true,
		power = _G.Enum.PowerType.HolyPower,
	},
	--[[['PRIEST'] = {
		-- inverted y-coords to allow filling the texture bottom->top. texture matches the crazyness
		fill = {'Interface\\PlayerFrame\\Priest-ShadowUI', { 0.45703125, 0.60546875, 0.44531250, 0.73437500 }},
		bg 	 = {'Interface\\PlayerFrame\\Priest-ShadowUI', { 0.30078125, 0.44921875, 0.44531250, 0.73437500 }},
		glow = {'Interface\\PlayerFrame\\Priest-ShadowUI', { 0.00390625, 0.29296875, 0.44531250, 0.78906250 }},
		size = {26, 26},
		padding = 0,
		glowPadding = 0,
		showEmpty = true,
		power = _G.Enum.PowerType.ShadowOrbs,
	},--]]
	['MONK'] = { -- Interface\\PLAYERFRAME\\MonkUI
		fill = {'Interface\\AddOns\\'..addonName..'\\media\\combo', {0/64, 64/64, 0/16, 16/16}},
		bg   = {'Interface\\AddOns\\'..addonName..'\\media\\combo', {16/64, 32/64, 0/16, 16/16}},
		glow = {'Interface\\AddOns\\'..addonName..'\\media\\combo', {32/64, 48/64, 0/16, 16/16}},
		size = {16, 16},
		padding = 0,
		glowPadding = 0,
		showEmpty = true,
		power = _G.Enum.PowerType.Chi,
	},
	 ['WARLOCK'] = {
		-- fill = {'Interface\\PlayerFrame\\ClassOverlayWarlockShards', { 0, 1, 0, 1 }},
		-- bg   = {'Interface\\PlayerFrame\\ClassOverlayWarlockShards', { 0, 1, 0, 1 }},
		-- glow = nil,
		fill = {'Interface\\AddOns\\'..addonName..'\\media\\combo', {0/64, 64/64, 0/16, 16/16}},
		bg   = {'Interface\\AddOns\\'..addonName..'\\media\\combo', {16/64, 32/64, 0/16, 16/16}},
		glow = {'Interface\\AddOns\\'..addonName..'\\media\\combo', {32/64, 48/64, 0/16, 16/16}},
		size = {16, 16},
		padding = 0,
		glowPadding = 0,
		showEmpty = true,
		power = _G.Enum.PowerType.SoulShards,
	},
	default = {
		fill = {'Interface\\AddOns\\'..addonName..'\\media\\combo', {0/64, 64/64, 0/16, 16/16}},
		bg   = {'Interface\\AddOns\\'..addonName..'\\media\\combo', {16/64, 32/64, 0/16, 16/16}},
		glow = {'Interface\\AddOns\\'..addonName..'\\media\\combo', {32/64, 48/64, 0/16, 16/16}},
		size = {16, 16},
		padding = 4,
		glowPadding = 6,
		showEmpty = nil,
		power = _G.Enum.PowerType.ComboPoints,
	}
}

local _, unitClass = UnitClass('player')
local data = config[unitClass] or config.default
local iconWidth, iconHeight = data.size[1], data.size[2]
local padding, glowPadding = data.padding, data.glowPadding or data.padding

local function CreateAnimationFlash(parent)
	local animator = CreateFrame('Frame', nil, parent:GetObjectType() ~= 'Texture' and parent or parent:GetParent())
	      animator:SetPoint('TOPLEFT', parent, 'TOPLEFT', -padding, padding)
	      animator:SetPoint('BOTTOMRIGHT', parent, 'BOTTOMRIGHT', padding, -padding)
	      animator:SetAlpha(0)
	      animator:Hide()
	parent.animator = animator

	local shine = animator:CreateTexture(nil, 'OVERLAY')
	      shine:SetAllPoints()
	      shine:SetPoint('CENTER')
	      shine:SetTexture('Interface\\Cooldown\\star4')
	      shine:SetBlendMode('ADD')

	local anim = animator:CreateAnimationGroup()
	      anim:SetScript('OnFinished', function(self, requested) self:GetParent():Hide() end)
	animator.animation = anim
	animator:SetScript('OnShow', function(self) self.animation:Play() end)

	local alphaIn = anim:CreateAnimation('Alpha')
	      alphaIn:SetToAlpha(0.3)
	      alphaIn:SetDuration(0.4)
	      alphaIn:SetOrder(1)
	local rotateIn = anim:CreateAnimation('Rotation')
	      rotateIn:SetDegrees(-90)
	      rotateIn:SetDuration(0.4)
	      rotateIn:SetOrder(1)
	local scaleIn = anim:CreateAnimation('Scale')
	      scaleIn:SetScale(2, 2)
	      scaleIn:SetOrigin('CENTER', 0, 0)
	      scaleIn:SetDuration(0.4)
	      scaleIn:SetOrder(1)

	local alphaOut = anim:CreateAnimation('Alpha')
	      alphaOut:SetFromAlpha(-0.5)
	      alphaOut:SetDuration(0.4)
	      alphaOut:SetOrder(2)
	local rotateOut = anim:CreateAnimation('Rotation')
	      rotateOut:SetDegrees(-90)
	      rotateOut:SetDuration(0.3)
	      rotateOut:SetOrder(2)
	local scaleOut = anim:CreateAnimation('Scale')
	      scaleOut:SetScale(-2, -2)
	      scaleOut:SetOrigin('CENTER', 0, 0)
	      scaleOut:SetDuration(0.4)
	      scaleOut:SetOrder(2)
end

local function CreateClassIcon(element, index)
	local cIcon = CreateFrame('StatusBar', nil, element, nil, index)
	      cIcon:SetRotatesTexture(false)
	      cIcon:SetOrientation('VERTICAL')
	      cIcon:SetSize(iconWidth, iconHeight)
	      cIcon:SetMinMaxValues(0, 1)
	      cIcon:SetStatusBarTexture(data.fill[1], 'ARTWORK')
	      cIcon:GetStatusBarTexture():SetTexCoord(unpack(data.fill[2]))
		  -- As soon as tiling is enabled, texture coordinates are moot.
		  -- So only tile what needs to be tiled.
	      cIcon:GetStatusBarTexture():SetHorizTile(true)
	      cIcon:GetStatusBarTexture():SetVertTile(false)

	local border = element:CreateTexture(nil, 'BACKGROUND')
	      border:SetPoint('TOPLEFT', cIcon, 'TOPLEFT', -padding, padding)
	      border:SetPoint('BOTTOMRIGHT', cIcon, 'BOTTOMRIGHT', padding, -padding)
	      border:SetTexture(data.bg[1])
	      border:SetTexCoord(unpack(data.bg[2]))
	cIcon.bg = border
	cIcon.bg.multiplier = 0.5

	if index == 1 then
		cIcon:SetPoint('TOPLEFT', element, padding, -padding)
	else
		cIcon:SetPoint('LEFT', element[index - 1], 'RIGHT', 2*padding, 0)
	end
	element[index] = cIcon

	-- animations
	CreateAnimationFlash(cIcon)

	-- Make sure that colors and stuff are applied.
	element:ForceUpdate()
end

local function PreUpdate(element)
	-- Ensure we catch changes in power capacity.
	for index = 1, UnitPowerMax('player', data.power) or 0 do
		if not element[index] then
			CreateClassIcon(element, index)
		end
	end
end

local lastNumPoints = 0
local function PostUpdate(element, cur, max, hasMaxChanged, powerType)
	max = max or 0 -- why would this even be nil?

	if hasMaxChanged then
		if max == 0 then
			element:Hide()
			return
		else
			-- Show/hide icons in case max has changed.
			for index, classIcon in ipairs(element) do
				classIcon:SetShown(index <= max)
			end
			element:Show()
		end
	end

	-- Flash for new resources.
	for index = 1, max do
		if index <= cur and index > lastNumPoints then
			element[index].animator:Show()
		end
	end
	element:SetWidth(max * (iconWidth + 2*padding))

	lastNumPoints = cur
end

function ns.ClassIcons(self, unit)
	local classIcons = CreateFrame('Frame', nil, self)
	      classIcons:SetHeight(iconHeight + 2*padding)
	classIcons.PreUpdate = PreUpdate
	classIcons.PostUpdate = PostUpdate

	return classIcons
end
