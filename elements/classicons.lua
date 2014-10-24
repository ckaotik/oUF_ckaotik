local addonName, ns, _ = ...

-- TODO: Warlock
-- http://wow.go-hero.net/framexml/17688/ShardBar.lua
-- Interface\\PLAYERFRAME\\Warlock-DestructionUI-Green / Interface\\PLAYERFRAME\\Warlock-DestructionUI / Interface\\PLAYERFRAME\\Warlock-DemonologyUI

local MAX_CLASS_ICONS = 5
local config = {
	['PALADIN'] = {
		bg   = {'Interface\\AddOns\\'..addonName..'\\media\\HolyPower', { 18/64, 36/64, 0, 18/32 }},
		fill = {'Interface\\AddOns\\'..addonName..'\\media\\HolyPower', { 0, 18/64, 13/32, 32/32 }},
		size = {18, 19},
		padding = 0,
		glowPadding = 0,
		showEmpty = true,
	},
	['PRIEST'] = {
		-- inverted y-coords to allow filling the texture bottom->top. texture matches the crazyness
		fill = {'Interface\\PlayerFrame\\Priest-ShadowUI', { 0.45703125, 0.60546875, 0.44531250, 0.73437500 }},
		bg 	 = {'Interface\\PlayerFrame\\Priest-ShadowUI', { 0.30078125, 0.44921875, 0.44531250, 0.73437500 }},
		glow = {'Interface\\PlayerFrame\\Priest-ShadowUI', { 0.00390625, 0.29296875, 0.44531250, 0.78906250 }},
		size = {26, 26},
		padding = 0,
		glowPadding = 0,
		showEmpty = true,
	},
	['MONK'] = { -- Interface\\PLAYERFRAME\\MonkUI
		fill = {'Interface\\PlayerFrame\\MonkLightPower', { 0, 1, 0, 1 }},
		bg   = {'Interface\\PLAYERFRAME\\MonkNoPower',    { 0, 1, 0, 1 }},
		glow = nil,
		size = {20, 20},
		padding = 0,
		glowPadding = 0,
		showEmpty = true,
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

local _, unitClass = UnitClass('player')
local data = config[unitClass] or config.default
local iconWidth, iconHeight = data.size[1], data.size[2]
local padding, glowPadding = data.padding, data.glowPadding or data.padding

local function CreateAnimationFlash(frame, index, parent)
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
	      alphaIn:SetChange(0.3)
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
	      alphaOut:SetChange(-0.5)
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

local lastNumPoints = 0
local function PostUpdate(element, cur, max, hasMaxChanged)
	if hasMaxChanged then
		if max == 0 then
			element:Hide()
			return
		else
			element:Show()
		end
	end

	for index = 1, MAX_CLASS_ICONS do
		local classIcon = element[index]
		-- print(element:GetName(), cur, max, hasMaxChanged)
		if index > (max or 0) then
			classIcon.border:Hide()
			classIcon:Hide()
		else
			classIcon.border:Show()
			if index <= cur and index > lastNumPoints then
				classIcon.animator:Show()
			end
		end
	end

	lastNumPoints = cur
	element:SetWidth(max * (iconWidth + 2*padding))
end

function ns.ClassIcons(self, unit)
	local classIcons = CreateFrame('Frame', nil, self)
	      classIcons:SetSize(MAX_CLASS_ICONS * (iconWidth + 2*padding), (iconHeight + 2*padding))
	classIcons.PostUpdate = PostUpdate
	-- classIcons.UpdateTexture = UpdateTexture

	for index = 1, MAX_CLASS_ICONS do
		local cIcon = classIcons:CreateTexture(nil, 'ARTWORK')
		      cIcon:SetTexture(data.fill[1])
		      cIcon:SetTexCoord(unpack(data.fill[2]))
		      cIcon:SetSize(iconWidth, iconHeight)
		--[[
		local cIcon = CreateFrame('StatusBar', nil, classIcons, nil, index)
		      cIcon:SetStatusBarTexture('Interface\\AddOns\\'..addonName..'\\media\\combo')
		      cIcon:SetRotatesTexture(false)
		      cIcon:SetOrientation('VERTICAL')
		      cIcon:SetSize(iconWidth, iconHeight)
		      cIcon:SetMinMaxValues(0, 1)
		      -- inverted y-axis to fill bottom->top
		      cIcon:GetStatusBarTexture():SetHorizTile(true)
		      cIcon:GetStatusBarTexture():SetVertTile(true)
		      cIcon:GetStatusBarTexture():SetTexCoord(0/64, 8/64, 8/64, 0/64)
		--]]

		local border = classIcons:CreateTexture(nil, 'BACKGROUND')
		      border:SetPoint('TOPLEFT', cIcon, 'TOPLEFT', -padding, padding)
		      border:SetPoint('BOTTOMRIGHT', cIcon, 'BOTTOMRIGHT', padding, -padding)
		      border:SetTexture(data.bg[1])
		      border:SetTexCoord(unpack(data.bg[2]))
		cIcon.border = border

		if index == 1 then
			cIcon:SetPoint('TOPLEFT', classIcons, padding, -padding)
		else
			cIcon:SetPoint('LEFT', classIcons[index - 1], 'RIGHT', 2*padding, 0)
		end
		classIcons[index] = cIcon

		-- animations
		CreateAnimationFlash(self, index, cIcon)
	end

	return classIcons
end
