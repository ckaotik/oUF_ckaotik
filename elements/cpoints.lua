local addonName, ns, _ = ...

-- GLOBALS: MAX_COMBO_POINTS, CreateFrame
-- GLOBALS: unpack

local iconSize = 8
local padding = 4

local function CreateAnimationFlash(frame, index, parent)
	local animator = CreateFrame("Frame", nil, parent)
	      animator:SetPoint('TOPLEFT', -padding, padding)
	      animator:SetPoint('BOTTOMRIGHT', padding, -padding)
	      animator:SetAlpha(0)
	      animator:Hide()
	parent.animator = animator

	local shine = animator:CreateTexture(nil, "OVERLAY")
	      shine:SetAllPoints()
	      shine:SetPoint("CENTER")
	      shine:SetTexture("Interface\\Cooldown\\star4")
	      shine:SetBlendMode("ADD")

	local anim = animator:CreateAnimationGroup()
	      anim:SetScript("OnFinished", function(self, requested) self:GetParent():Hide() end)
	animator.animation = anim
	animator:SetScript("OnShow", function(self) self.animation:Play() end)

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
end

local lastNumPoints, lastTarget = 0, nil
local function PostUpdate(element, numPoints)
	-- animate newly gained combo points
	for i = lastNumPoints+1, numPoints do
		element[i].animator:Show()
	end
	lastNumPoints = numPoints
end

function ns.CPoints(self, unit)
	local points = CreateFrame('Frame', nil, self)
	      points:SetSize(MAX_COMBO_POINTS * (iconSize + 2*padding), (iconSize + 2*padding))
	points.PostUpdate = PostUpdate

	for index = 1, MAX_COMBO_POINTS do
		local point = CreateFrame('Frame', nil, points, nil, index)
		      point:SetSize(iconSize, iconSize)

		local fill = point:CreateTexture(nil, 'BACKGROUND')
		      fill:SetAllPoints()
		      fill:SetTexture('Interface\\AddOns\\'..addonName..'\\media\\combo')
		      fill:SetTexCoord(0/64, 8/64, 0/16, 8/16)
		      fill:SetVertexColor(unpack(self.colors.power['ENERGY']))
		point.fill = fill

		local border = points:CreateTexture(nil, 'BACKGROUND')
		      border:SetPoint('TOPLEFT', point, 'TOPLEFT', -padding, padding)
		      border:SetPoint('BOTTOMRIGHT', point, 'BOTTOMRIGHT', padding, -padding)
		      border:SetTexture('Interface\\AddOns\\'..addonName..'\\media\\combo')
		      border:SetTexCoord(16/64, 32/64, 0/16, 16/16)
		point.border = border

		if index == 1 then
			point:SetPoint('TOPLEFT', points, padding, -padding)
		else
			point:SetPoint('LEFT', points[index - 1], 'RIGHT', 2*padding, 0)
		end
		points[index] = point

		-- animations
		CreateAnimationFlash(self, index, point)
	end

	return points
end
