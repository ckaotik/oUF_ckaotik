local addonName, ns, _ = ...

-- GLOBALS: CreateFrame, UnitIsConnected, UnitIsDead, UnitIsGhost, UnitIsConnected
local floor, ceil, min, max = math.ceil, math.floor, math.min, math.max
local tostring, strlen, strsub = tostring, string.len, string.sub

local textureWidth, textureHeight = 512, 128
local digitHeight, digitInfo = 42, {
	-- [character] = { offset, width }
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
	["BOSS"]  = {419, 42},
	["DEAD"]  = {326, 31},
	["GHOST"] = {358, 36},
	["OFFLINE"] = {395, 23},
}

--[[ how this works:
	1) we let oUF update our fake health bar
	2) we create digits (being vertical statusbars) with a
	   background ("empty texture") and an overlay ("fill texture")
	2) after oUF has determined colors, values etc we gather
	   those and apply them to our own digits & their textures
--]]
local function PostUpdateHealth(element, unit, currentHealth, maxHealth)
	if not element.digits then return end

	local percentage = 0
	if maxHealth ~= 0 then
		percentage = element:GetValue() / maxHealth
	end

	local percentString = percentage*100
	      percentString = UnitIsEnemy(unit, 'player') and ceil(percentString) or floor(percentString)
	local numDigits     = #element.digits

	local overrideCharacter = UnitIsDead(unit)  and 'DEAD'
		or unit:find('^boss') and 'BOSS'
		or UnitIsGhost(unit) and 'GHOST'
		or not UnitIsConnected(unit) and 'OFFLINE'
		or nil

	-- relay changes to single digits
	local healthWidth = 0
	for i = 1, numDigits do
		local digit = element.digits[i]
		local character = overrideCharacter or strsub(percentString, -i, -i)

		if (overrideCharacter and i ~= 1) or not digitInfo[character] then
			-- digit is not used
			digit:SetWidth(0)
			digit:Hide()
		else
			local digitLeft   = (digitInfo[character][1]) / textureWidth
			local digitRight  = (digitInfo[character][1]+digitInfo[character][2]) / textureWidth
			local digitTop    = (2 + 2 * digitHeight - digitHeight * percentage) / textureHeight
			local digitBottom = (2 + 2 * digitHeight) / textureHeight

			digit.bg:SetTexCoord(digitLeft, digitRight, 1/textureHeight, (1+digitHeight) / textureHeight)
			digit.tex:SetTexCoord(digitLeft, digitRight, digitTop, digitBottom)
			digit.tex:SetVertexColor( element:GetStatusBarColor() )

			digit:SetValue(percentage)
			digit:SetWidth(digitInfo[character][2])
			digit:Show()

			healthWidth = healthWidth + digitInfo[character][2]
		end
	end
	element:SetWidth(healthWidth)
end

function ns.Health(self, unit)
	local maxDigitWidth, maxCharacterWidth = 0, 0
	for character, info in pairs(digitInfo) do
		if tonumber(character) then
			maxDigitWidth = max(maxDigitWidth, info[2])
		end
		maxCharacterWidth = max(maxCharacterWidth, info[2])
	end

	local numDigits = (unit:find('^boss') and 1) or 3
	local healthWidth = numDigits == 1 and maxCharacterWidth or (numDigits - 1) * maxDigitWidth + digitInfo['1'][2]

	self.colors.health = {1, 0.65, 0.16}

	local health = CreateFrame('StatusBar', nil, self) -- fake
	if not (unit == 'player' or unit == 'target' or unit == 'focus' or unit:find('^boss')) then return health end

	      health:SetSize(healthWidth, digitHeight)
	      health:SetStatusBarTexture('Interface\\AddOns\\'..addonName..'\\media\\blank')
	      health.digits = {}
	      health.PostUpdate = PostUpdateHealth

	for i = 1, numDigits do
		local digit = CreateFrame('StatusBar', nil, health, nil, i)
		      digit:SetStatusBarTexture('Interface\\AddOns\\'..addonName..'\\media\\digits')
		      digit:SetStatusBarColor(1, 1, 1, 0)
		      digit:SetRotatesTexture(false)
		      digit:SetOrientation('VERTICAL')
		      digit:SetHeight(digitHeight)
		      digit:SetMinMaxValues(0, 1)
		      -- digit:GetStatusBarTexture():SetHorizTile(true)
		      -- digit:GetStatusBarTexture():SetVertTile(true)

		      digit:SetWidth(30)

		if i == 1 then
			digit:SetPoint('RIGHT')
		else
			digit:SetPoint('RIGHT', health.digits[i - 1], 'LEFT')
		end

		local bg = digit:CreateTexture(nil, 'BACKGROUND')
		      bg:SetPoint('BOTTOM')
		      bg:SetPoint('LEFT')
		      bg:SetPoint('RIGHT')
		      bg:SetHeight(digitHeight)
		      bg:SetTexture('Interface\\AddOns\\'..addonName..'\\media\\digits')
		digit.bg = bg

		-- wth ... why can't I use a statusbar and :SetWidth() together with :GetStatusBarTexture():SetTexCood() ???
		local tex = digit:CreateTexture(nil, 'BORDER')
		      tex:SetAllPoints(digit:GetStatusBarTexture())
		      tex:SetHeight(digitHeight)
		      tex:SetTexture('Interface\\AddOns\\'..addonName..'\\media\\digits')
		digit.tex = tex

		health.digits[i] = digit
	end

	return health
end
