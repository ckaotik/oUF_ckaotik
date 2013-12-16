local addonName, ns, _ = ...

local MAX_CLASS_ICONS = 5
local iconSize = 8
local padding = 4

local function CreateAnimationFlash(frame, index, parent)
	-- Shine effect
	local shinywheee = CreateFrame("Frame", nil, parent)
	-- shinywheee:SetAllPoints()
	shinywheee:SetPoint('TOPLEFT', -padding, padding)
	shinywheee:SetPoint('BOTTOMRIGHT', padding, -padding)
	shinywheee:SetAlpha(0)
	shinywheee:Hide()
	parent.shinywheee = shinywheee

	local shine = shinywheee:CreateTexture(nil, "OVERLAY")
	shine:SetAllPoints()
	shine:SetPoint("CENTER")
	shine:SetTexture("Interface\\Cooldown\\star4")
	shine:SetBlendMode("ADD")

	local anim = shinywheee:CreateAnimationGroup()
	local alphaIn = anim:CreateAnimation("Alpha")
	alphaIn:SetChange(0.3)
	alphaIn:SetDuration(0.4)
	alphaIn:SetOrder(1)
	local rotateIn = anim:CreateAnimation("Rotation")
	rotateIn:SetDegrees(-90)
	rotateIn:SetDuration(0.4)
	rotateIn:SetOrder(1)
	local scaleIn = anim:CreateAnimation("Scale")
	scaleIn:SetScale(2, 2)
	scaleIn:SetOrigin("CENTER", 0, 0)
	scaleIn:SetDuration(0.4)
	scaleIn:SetOrder(1)
	local alphaOut = anim:CreateAnimation("Alpha")
	alphaOut:SetChange(-0.5)
	alphaOut:SetDuration(0.4)
	alphaOut:SetOrder(2)
	local rotateOut = anim:CreateAnimation("Rotation")
	rotateOut:SetDegrees(-90)
	rotateOut:SetDuration(0.3)
	rotateOut:SetOrder(2)
	local scaleOut = anim:CreateAnimation("Scale")
	scaleOut:SetScale(-2, -2)
	scaleOut:SetOrigin("CENTER", 0, 0)
	scaleOut:SetDuration(0.4)
	scaleOut:SetOrder(2)

	anim:SetScript("OnFinished", function() shinywheee:Hide() end)
	shinywheee:SetScript("OnShow", function() anim:Play() end)
end

local function PostUpdateRune(self, rune, rid, start, duration, runeReady)
	if runeReady then
		rune:GetStatusBarTexture():SetAlpha(1)
		rune.shinywheee:Show()
	else
		rune:GetStatusBarTexture():SetAlpha(0.3)
	end
end

function ns.ClassIcons(self, unit)
	local classIcons = CreateFrame('Frame', nil, self)
	      classIcons:SetSize(MAX_CLASS_ICONS * (iconSize + 2*padding), (iconSize + 2*padding))
	-- classIcons.PostUpdateRune = PostUpdateRune

	local _, unitClass = UnitClass('player')
	if unitClass ~= "MONK" or unitClass ~= "PRIEST" or unitClass ~= "PALADIN" or unitClass ~= 'WARLOCK' then
		classIcons:SetSize(0, 0)
		return classIcons
	end

	for index = 1, MAX_CLASS_ICONS do
		local cIcon = CreateFrame('StatusBar', nil, classIcons, nil, index)
		      cIcon:SetStatusBarTexture('Interface\\AddOns\\'..addonName..'\\media\\combo')
		      cIcon:SetRotatesTexture(false)
		      cIcon:SetOrientation('VERTICAL')
		      cIcon:SetSize(iconSize, iconSize)
		      cIcon:SetMinMaxValues(0, 1)
		      -- inverted y-axis to fill bottom->top
		      cIcon:GetStatusBarTexture():SetHorizTile(true)
		      cIcon:GetStatusBarTexture():SetVertTile(true)
		      cIcon:GetStatusBarTexture():SetTexCoord(0/64, 8/64, 8/64, 0/64)

		local border = cIcon:CreateTexture(nil, 'BACKGROUND', nil, -8)
		      border:SetPoint('TOPLEFT', -padding, padding)
		      border:SetPoint('BOTTOMRIGHT', padding, -padding)
		      border:SetTexture('Interface\\AddOns\\'..addonName..'\\media\\combo')
		      border:SetTexCoord(16/64, 32/64, 0/16, 16/16)
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
