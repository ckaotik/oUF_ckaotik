local addonName, ns, _ = ...

-- GLOBALS: _G, type, pairs, wipe

local SharedMedia = LibStub("LibSharedMedia-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
if not AceConfig or not AceConfigDialog then return end

local function GetSetting(info)
	local db = _G[ info[1] ]
	local data = db
	for i = 2, #info do
		data = data[ info[i] ]
	end
	return data
end

local function SetSetting(info, value)
	-- FOO = info; SlashCmdList['SPEW']('FOO')
	local db = _G[ info[1] ]
	local data = db
	for i = 2, #info - 1 do
		data = data[ info[i] ]
	end
	data[ info[#info] ] = value
end

function ns:LSM_GetMediaKey(mediaType, value)
	local keyList = SharedMedia:List(mediaType)
	for _, key in pairs(keyList) do
		if SharedMedia:Fetch(mediaType, key) == value then
			return key
		end
	end
end

local function Widget(key, option)
	local widget
	if key == 'justifyH' then
		widget = {
			type = "select",
			name = "Text Justification",

			values = {["LEFT"] = "LEFT", ["CENTER"] = "CENTER", ["RIGHT"] = "RIGHT"},
		}
	elseif key == 'fontSize' then
		widget = {
			type = "range",
			name = "Font Size",
			step = 1,
			min = 5,
			max = 24,
		}
	elseif key == 'font' then
		widget = {
			type = "select",
			dialogControl = "LSM30_Font",
			name = "Font Family",

			values = SharedMedia:HashTable("font"),
			get = function(info) return ns:LSM_GetMediaKey("font", GetSetting(info)) end,
			set = function(info, value)
				SetSetting(info, SharedMedia:Fetch("font", value))
			end,
		}
	elseif key == 'fontStyle' then
		widget = {
			type = "select",
			name = "Font Style",

			values = {["NONE"] = "NONE", ["OUTLINE"] = "OUTLINE", ["THICKOUTLINE"] = "THICKOUTLINE", ["MONOCHROME"] = "MONOCHROME"},
		}
	elseif type(option) == 'string' then
		widget = {
			type = "input",
		}
	end

	return widget
end

local function ParseOption(key, option)
	local widget = Widget(key, option)
	if widget then
		widget.name = widget.name or key
		return widget
	elseif type(option) == 'boolean' then
		return {
			type = 'toggle',
			name = key,
			-- desc = '',
		}
	elseif type(option) == 'number' then
		return {
			type = 'range',
			name = key,
			-- desc = '',
			min = -200,
			max = 200,
			bigStep = 10,
		}
	elseif type(option) == 'table' then
		-- TODO: FIXME: create nested AceConfig table
		local data = {
			type 	= 'group',
			inline 	= true,
			name 	= key,
			args 	= {},
		}

		for subkey, value in pairs(option) do
			data.args[subkey] = ParseOption(subkey, value)
		end
		return data
	end
end

-- oUF_ckaotik.args.oUF_ckaotikDB.args.position.type: expected a string, got a nil
local optionsTable = {
	type = 'group',
	args = {
		['oUF_ckaotikDB'] = {
			type 	= 'group',
			name 	= 'Shared Settings',
			order 	= 2,
			args 	= {},
		},
	},
	get = GetSetting,
	set = SetSetting,
}

local function GenerateOptions()
	for namespace, _ in pairs(optionsTable.args) do
		wipe(optionsTable.args[namespace].args)
		for key, value in pairs(_G[namespace]) do
			optionsTable.args[namespace].args[key] = ParseOption(key, value)
			optionsTable.args[namespace].args[key].inline = false
		end
	end
	return optionsTable
end

AceConfig:RegisterOptionsTable(addonName, GenerateOptions)
AceConfigDialog:AddToBlizOptions(addonName)
