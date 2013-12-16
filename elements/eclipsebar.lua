local addonName, ns, _ = ...

local _, unitClass = UnitClass('player')
if unitClass ~= 'DRUID' then return end

-- GLOBALS: SPELL_POWER_ECLIPSE, AnimateTexCoords, CreateFrame, GetEclipseDirection, UnitPower
local unpack, floor, ceil = unpack, math.floor, math.ceil

local function AnimateEclipse(texture, eclipse)
	texture.frame = nil

	local element = texture:GetParent()
	element:SetScript('OnUpdate', function(self, elapsed)
		-- Blizzard global function (UIParent.lua)
		AnimateTexCoords(texture, 256, 64, 22, 22, 11, elapsed, 0.025)
		if texture.frame > 6 then
			local r, g, b = unpack(self:GetParent().colors.power.ECLIPSE[eclipse])
			texture:SetVertexColor(r, g, b)
		end
		-- Stop animation on last frame
		if texture.frame >= 11 then
			self:SetScript('OnUpdate', nil)
			texture:SetTexCoord(0, 22/256, 0, 22/64)
		end
	end)
end

local function PostDirectionChange(element, unit)
	AnimateEclipse(element.direction, element.directionIsLunar and 'LUNAR' or 'SOLAR')
end

local wrath    = GetSpellInfo(5176)
local starfire = GetSpellInfo(2912)
local function PostUpdatePower(element, unit)
	local power = UnitPower(unit, SPELL_POWER_ECLIPSE)
	local currentPhase = power == 0 and GetEclipseDirection() or power > 0 and 'sun' or 'moon'

	-- animate/color big circle
	local eclipse = currentPhase == 'sun' and 'SOLAR' or 'LUNAR'
	if element.lastPhase ~= currentPhase then
		AnimateEclipse(element.bg, eclipse)
	else
		element.bg:SetVertexColor(unpack(element:GetParent().colors.power.ECLIPSE[eclipse]))
	end
	-- fill circle
	element.fill:SetTexCoord((10 + floor(power / 10)) * 22 / 256, (11 + floor(power / 10)) * 22 / 256, 22 / 64, 44 / 64)

	-- cast counter, but flags are only set in UnitAura which usually fires after UnitPower
	if element.hasLunarEclipse or power == -100 then
		element.counter:SetFormattedText('%d %s', ceil(100/40 - power/20), starfire)
	elseif element.hasSolarEclipse or power == 100 then
		local numCasts = ceil(power/15) -- until out of eclipse
			  numCasts = numCasts + ceil((100+power - numCasts*15)/30)
		element.counter:SetFormattedText('%d %s', numCasts, wrath)
	else
		if currentPhase == 'sun' then
			element.counter:SetFormattedText('%d %s', ceil((100 - power)/20/2), starfire)
		else
			element.counter:SetFormattedText('%d %s', ceil((100 + power)/15/2), wrath)
		end
	end
	element.lastPhase = currentPhase
end

local function PostUnitAura(element, unit)
	element.PostUpdatePower(element, unit)
	element.PostUnitAura = nil
end

function ns.EclipseBar(self, unit)
	local eclipseBar = CreateFrame('Frame', nil, self)
		  eclipseBar:SetSize(22, 22)
		  eclipseBar:SetPoint('TOPRIGHT', self, 'BOTTOMRIGHT')

	local background = eclipseBar:CreateTexture(nil, 'ARTWORK')
		  background:SetTexture('Interface\\AddOns\\'..addonName..'\\media\\eclipse')
		  background:SetAllPoints()
		  background:SetTexCoord(0, 22/256, 0, 22/64)
	eclipseBar.bg = background

	local fill = eclipseBar:CreateTexture(nil, 'OVERLAY')
		  fill:SetTexture('Interface\\AddOns\\'..addonName..'\\media\\eclipse')
		  fill:SetAllPoints()
	eclipseBar.fill = fill

	local direction = eclipseBar:CreateTexture(nil, 'OVERLAY')
		  direction:SetDrawLayer('OVERLAY', 1)
		  direction:SetSize(11, 11)
		  direction:SetTexture('Interface\\AddOns\\'..addonName..'\\media\\eclipse')
		  direction:SetPoint('BOTTOMRIGHT', eclipseBar, 'BOTTOMRIGHT', 3, -3)
		  direction:SetTexCoord(0, 22/256, 0, 22/64)
	eclipseBar.direction = direction

	local counter = eclipseBar:CreateFontString(nil, 'OVERLAY')
		  counter:SetFontObject('UFFontMedium')
		  counter:SetPoint('RIGHT', eclipseBar, 'LEFT', -5, 0)
	eclipseBar.counter = counter

	-- Initialize starting values
	local eclipse = GetEclipseDirection() == 'sun' and 'SOLAR' or 'LUNAR'
	eclipseBar.direction:SetVertexColor(unpack(self.colors.power.ECLIPSE[eclipse]))
	eclipseBar.lastPhase = UnitPower('player', SPELL_POWER_ECLIPSE) < 0 and 'sun' or 'moon'

	-- Play direction indicator animation on direction change (100% solar or lunar)
	eclipseBar.PostDirectionChange = PostDirectionChange
	eclipseBar.PostUpdatePower = PostUpdatePower
	-- make sure we initialize properly
	eclipseBar.PostUnitAura = PostUnitAura

	return eclipseBar
end
