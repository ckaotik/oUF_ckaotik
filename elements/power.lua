local addonName, ns, _ = ...

-- GLOBALS:

local function PostUpdatePower(element, unit, current, max)
	if not element.text then return end
	if element.disconnected or UnitIsDeadOrGhost(unit) then
		element:Hide()
	else
		element.text:SetTextColor( element:GetStatusBarColor() )
		element:Show()
	end
end

function ns.Power(self, unit)
	local power = CreateFrame('StatusBar', nil, self) -- fake
	      power:SetStatusBarTexture('Interface\\AddOns\\'..addonName..'\\media\\blank.blp')
	      -- power:SetSize()
	if unit ~= 'player' and unit ~= 'target' then
		return power
	end

	local powerString = power:CreateFontString(nil, nil, 'PVPInfoTextFont') -- NumberFontNormalHuge, GameFontNormalHuge
	      powerString:SetAllPoints()
	      powerString:SetJustifyH('RIGHT')
	      powerString:SetText('888')

	power:SetSize( powerString:GetSize() )
	self:Tag(powerString, '[perpp]')

	power.text = powerString
	power.PostUpdate = PostUpdatePower

	return power
end
