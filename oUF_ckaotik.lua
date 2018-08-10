local addonName, ns, _ = ...

-- GLOBALS: _G, oUF_ckaotikDB, GameTooltip, MAX_BOSS_FRAMES, oUF
-- GLOBALS: pairs, type, gsub

local Movable = LibStub('LibMovable-1.0', true)
local oUF = ns.oUF or oUF
assert(oUF, "<name> was unable to locate oUF install.")

-- TODO: Warlock bars, castbar

-- ================================================
--  Setup
-- ================================================
local function UpdateRaidIcon(self, unit)
	if unit == self.unit then
		self.RaidIcon.ForceUpdate(self.RaidIcon)
	end
end

local function Initialize()
	if not oUF_ckaotikDB then oUF_ckaotikDB = {} end
	ns.db = oUF_ckaotikDB

	-- set up default settings
	for key, value in pairs({
		position = {},
		auras = {
			showList = {},
			hideList = {},
		},
		name = {
			font = false,
			fontSize = false,
			fontStyle = false,
			justifyH = false,
		},
		powerThreat = {
			font = false,
			fontSize = false,
			fontStyle = false,
			justifyH = false,
		},
		powerPercent = {
			font = false,
			fontSize = false,
			fontStyle = false,
			justifyH = false,
		},
		comboTarget = {
			font = false,
			fontSize = false,
			fontStyle = false,
			justifyH = false,
		},
		-- showPercentSign = false,
	}) do
		if ns.db[key] == nil then
			ns.db[key] = value
		end
	end

	_G.SLASH_OUFCKAOTIK = "/oufckaotik"
	SlashCmdList.OUFCKAOTIK = function()
		if not Movable then return end
		if Movable.IsLocked(addonName) then
			Movable.Unlock(addonName)
		else
			Movable.Lock(addonName)
		end
	end

	oUF:RegisterStyle('ckaotik', ns.SharedStyle)
	oUF:Factory(function(self)
		self:SetActiveStyle('ckaotik')

		local unitFrames = {
			{ 'player',             'RIGHT', 'UIParent', 'CENTER', -290, -156 },
			{ 'pet',                'BOTTOMRIGHT', 'oUF_ckaotikPlayer', 'TOPRIGHT' },
			{ 'target',             'LEFT', 'UIParent', 'CENTER',  290, -156 },
			{ 'targettarget',       'BOTTOMLEFT', 'oUF_ckaotikTarget', 'TOPLEFT' },
			{ 'targettargettarget', 'BOTTOMLEFT', 'oUF_ckaotikTargetTarget', 'TOPLEFT' },
			{ 'focus',              'BOTTOM', 'UIParent', 'BOTTOM', 0, 360 },
			{ 'focustarget',        'BOTTOMLEFT',  'oUF_ckaotikFocus', 'TOPLEFT', 0, 5 },
			{ 'boss1',              'RIGHT',  'UIParent', -70, 0 },
		}
		for i = 2, MAX_BOSS_FRAMES do
			table.insert(unitFrames, { 'boss'..i,  'TOPRIGHT', 'oUF_ckaotikBoss'..(i-1), 'BOTTOMRIGHT', -80, -5 })
		end

		for i, info in ipairs(unitFrames) do
			local unit = info[1]
			local unitFrame = self:Spawn(unit)
			      unitFrame:SetPoint(select(2, unpack(info)))

			if not ns.db.position[unit] then ns.db.position[unit] = {} end
			Movable.RegisterMovable(addonName, unitFrame, ns.db.position[unit])
		end

		--[[
		self:SpawnHeader(nil, nil, 'custom [group:party] show; [@raid3,exists] show; [@raid26,exists] hide; hide',
			'showParty', true, 'showRaid', true, 'showPlayer', true, 'yOffset', -6,
			'oUF-initialConfigFunction', [=[
					self:SetHeight(16)
					self:SetWidth(126)
			]=]
		)SetPoint('TOP', Minimap, 'BOTTOM', 0, -10)
		--]]
	end)

	-- expose us
	_G[addonName] = ns
end

local frame = CreateFrame("Frame")
local function eventHandler(frame, event, arg1, ...)
	if event == 'ADDON_LOADED' and arg1 == addonName then
		Initialize()
		frame:UnregisterEvent(event)
	end
end
frame:SetScript("OnEvent", eventHandler)
frame:RegisterEvent("ADDON_LOADED")

-- ================================================
--  Little Helpers
-- ================================================
function ns.Print(text, ...)
	if ... and text:find("%%") then
		text = format(text, ...)
	elseif ... then
		text = join(", ", tostringall(text, ...))
	end
	DEFAULT_CHAT_FRAME:AddMessage("|cffE01B5D"..addonName.."|r "..text)
end

function ns.Debug(...)
  if true then
	ns.Print("! "..join(", ", tostringall(...)))
  end
end

function ns.ShowTooltip(self, altSelf)
	if not self.tiptext and not self.link then return end
	if altSelf and type(altSelf) == 'table' then
		self = altSelf
	end
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:ClearLines()

	if self.link then
		GameTooltip:SetHyperlink(self.link)
	elseif type(self.tiptext) == "string" and self.tiptext ~= "" then
		GameTooltip:SetText(self.tiptext, nil, nil, nil, nil, true)
	elseif type(self.tiptext) == "function" then
		self.tiptext(self, GameTooltip)
	end
	GameTooltip:Show()
end
function ns.HideTooltip() GameTooltip:Hide() end

-- counts table entries. for numerically indexed tables, use #table
function ns.Count(table)
	if not table or type(table) ~= "table" then return 0 end
	local i = 0
	for _ in pairs(table) do
		i = i + 1
	end
	return i
end

function ns.Find(where, what)
	for k, v in pairs(where) do
		if v == what then
			return k
		end
	end
end

function ns.GlobalStringToPattern(str)
	str = gsub(str, "([%(%)])", "%%%1")
	str = gsub(str, "%%%d?$?c", "(.+)")
	str = gsub(str, "%%%d?$?s", "(.+)")
	str = gsub(str, "%%%d?$?d", "(%%d+)")
	return str
end
