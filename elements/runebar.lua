local addonName, ns, _ = ...

local _, unitClass = UnitClass('player')
if unitClass ~= 'DEATHKNIGHT' then return end

local MAX_RUNES = 6
local iconSize = 8
local padding = 4

local function CreateAnimationFlash(frame, index, rune)
	-- Shine effect
	local shinywheee = CreateFrame("Frame", nil, rune)
	-- shinywheee:SetAllPoints()
	shinywheee:SetPoint('TOPLEFT', -padding, padding)
	shinywheee:SetPoint('BOTTOMRIGHT', padding, -padding)
	shinywheee:SetAlpha(0)
	shinywheee:Hide()
	rune.shinywheee = shinywheee

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

function ns.RuneBar(self, unit)
	local runes = CreateFrame('Frame', nil, self)
	      runes:SetSize(MAX_RUNES * (iconSize + 2*padding), (iconSize + 2*padding))
	runes.PostUpdateRune = PostUpdateRune

	for index = 1, MAX_RUNES do
		local rune = CreateFrame('StatusBar', addonName..'Rune'..index, runes, nil, index)
		      rune:SetStatusBarTexture('Interface\\AddOns\\'..addonName..'\\media\\combo')
		      rune:SetRotatesTexture(false)
		      rune:SetOrientation('VERTICAL')
		      rune:SetSize(iconSize, iconSize)
		      rune:SetMinMaxValues(0, 1)
		      -- inverted y-axis to fill bottom->top
		      rune:GetStatusBarTexture():SetHorizTile(true)
		      rune:GetStatusBarTexture():SetVertTile(true)
		      rune:GetStatusBarTexture():SetTexCoord(0/64, 8/64, 8/16, 0/16)

		local border = rune:CreateTexture(nil, 'BACKGROUND', nil, -8)
		      border:SetPoint('TOPLEFT', -padding, padding)
		      border:SetPoint('BOTTOMRIGHT', padding, -padding)
		      border:SetTexture('Interface\\AddOns\\'..addonName..'\\media\\combo')
		      border:SetTexCoord(16/64, 32/64, 0/16, 16/16)
		rune.border = border

		if index == 1 then
			rune:SetPoint('TOPLEFT', runes, padding, -padding)
		else
			rune:SetPoint('LEFT', runes[index - 1], 'RIGHT', 2*padding, 0)
		end
		runes[index] = rune

		-- animations
		CreateAnimationFlash(self, index, rune)
	end

	return runes
end
