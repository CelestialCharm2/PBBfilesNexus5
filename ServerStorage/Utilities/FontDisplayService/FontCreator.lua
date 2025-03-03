--SynapseX Decompiler

local TextService = game:GetService("TextService")
local fontCreator = {}
local out = {}
local loaderBin = script
setmetatable(out, {
	__index = function(out, index)
		if fontCreator[index] then
			return fontCreator[index]
		else
			error(tostring(index) .. " is not a valid member of FontCreator")
		end
	end,
	__newindex = function(out, index, value)
		error("FontCreator." .. tostring(index) .. " cannot be set")
	end
})
local loadedFonts = {}
local fontObjs = {}
local fontMeta = {
	__index = function(fout, index)
		if fontObjs[fout][index] ~= nil then
			return fontObjs[fout][index]
		else
			error(tostring(index) .. " is not a valid member of font")
		end
	end,
	__newindex = function(fout, index, value)
		error("font." .. tostring(index) .. " cannot be set")
	end
}
local iterateGraphemes = function(str, font)
	local instancesOfSpecials = {}
	for _, specialChar in pairs(font.specialCharacters) do
		local start = 1
		local len = #specialChar
		while true do
			local s, e = str:find(specialChar, start, true)
			if not s then
				break
			end
			start = e + 1
			table.insert(instancesOfSpecials, {
				s,
				len,
				specialChar
			})
		end
	end
	table.sort(instancesOfSpecials, function(a, b)
		return a[1] < b[1]
	end)
	local specialIndex = 1
	local nextSpecialStart = instancesOfSpecials[specialIndex]
	nextSpecialStart = nextSpecialStart and nextSpecialStart[1]
	local skip
	return coroutine.wrap(function()
		for s, e in utf8.graphemes(str) do
			if skip then
				skip = skip - 1
				if skip == 0 then
					skip = nil
				end
			elseif nextSpecialStart and s == nextSpecialStart then
				local special = instancesOfSpecials[specialIndex]
				local ch = special[3]
				skip = special[2] - 1
				specialIndex = specialIndex + 1
				nextSpecialStart = instancesOfSpecials[specialIndex]
				nextSpecialStart = nextSpecialStart and nextSpecialStart[1]
				coroutine.yield(ch, s, true)
			else
				coroutine.yield(str:sub(s, e), s, false)
			end
		end
	end)
end
fontCreator.iterateGraphemes = iterateGraphemes
function fontCreator.load(name)
	if type(name) == "string" and loadedFonts[name] then
		return loadedFonts[name]
	else
		do
			local f = {}
			local fout = {}
			setmetatable(fout, fontMeta)
			fontObjs[fout] = f
			local info
			if type(name) == "string" then
				local loaderObj = loaderBin:FindFirstChild(name)
				if loaderObj == nil then
					error(tostring(name) .. " is not a valid font name")
				end
				info = require(loaderObj)
			elseif type(name) == "table" then
				info = name
				name = info.name
			end
			for i, v in next, info, nil do
				f[i] = v
			end
			local isV2 = f.isV2 or false
			f.isV2 = isV2
			f.letterSpacing = f.letterSpacing or 0
			f.baselineOffset = f.baselineOffset or 0
			if not f.extensions then
				f.extensions = {}
			end
			f.specialCharacters = {}
			f.yScale = f.yScale or false
			for char, data in next, f.map, nil do
				if utf8.len(char) > 1 then
					table.insert(f.specialCharacters, char)
				end
				local scale = data[6]
				if scale then
					local w, h = data[3], data[4]
					data[8] = w
					data[9] = h
					data[3] = w * scale
					data[4] = h * scale
				end
				if isV2 and not data.NoHeightFix then
					local h = data.ImageRectSize.Y
					local y = data.SpriteOffset.Y
					local m = f.modeBaselineToTop
					local tp = m > -y and m + y or 0
					local bp = y + h < 0 and -y - h or 0
					if tp > 0 or bp > 0 then
						data.ImageRectSize = data.ImageRectSize + Vector2.new(0, tp + bp)
						data.ImageRectOffset = data.ImageRectOffset + Vector2.new(0, -tp)
						data.SpriteOffset = data.SpriteOffset + Vector2.new(0, -tp)
					end
				end
			end
			if not f.baseHeight then
				local maxCharHeight = 0
				for char, bounds in next, f.map, nil do
					maxCharHeight = math.max(maxCharHeight, bounds[4])
				end
				f.baseHeight = maxCharHeight
			end
			f.substitutionWidths = f.substitutionWidths or {}
			f.specialWordCharacters = {}
			for index, char in next, f.specialWordCharactersList or {}, nil do
				f.specialWordCharacters[char] = true
			end
			if f.extraAdvance then
				local extraAdvance = f.extraAdvance
				for _, char in pairs(f.map) do
					char.Advance = char.Advance + extraAdvance
				end
			end
			function f.transformCharacter(char)
				if f.lowercase == "none" or f.lowercase == nil then
					return char
				elseif f.lowercase == "determinate" then
					if f.map[char] ~= nil then
						return char
					elseif f.map[char:upper()] ~= nil then
						return char:upper()
					elseif f.map[char:lower()] ~= nil then
						return char:lower()
					end
					return char
				elseif f.lowercase == "all" then
					return char:lower()
				end
			end
			function f.getCharBounds(char)
				local bounds = f.map[f.transformCharacter(char)]
				if bounds then
					return bounds, false
				end
				bounds = f.substitutionWidths[char]
				if not bounds then
					local bounds = TextService:GetTextSize(char, math.min(100, f.substitutionSize), f.substitutionFont, Vector2.new(9999, 500))
					if 100 < f.substitutionSize then
						local scale = f.substitutionSize / 100
						bounds = Vector2.new(math.floor(bounds.X * scale + 0.5), math.floor(bounds.Y * scale + 0.5))
					end
					f.substitutionWidths[char] = bounds
				end
				return bounds, true
			end
			function f.getStringSize(str, fontSize)
				local scaleFactor = fontSize / f.baseHeight
				local totalWidth = 0
				local maxHeight = 0
				for char in iterateGraphemes(str, f) do
					local bounds, subs = f.getCharBounds(char)
					local advance = subs and bounds.X or isV2 and bounds.Advance or bounds[3]
					local imgHt = subs and bounds.Y or isV2 and bounds.ImageRectSize.Y or bounds[4]
					local endScaleY = scaleFactor * imgHt / f.baseHeight
					local relativeHeight = imgHt * endScaleY
					local ext = f.extensions[char]
					if ext then
						relativeHeight = relativeHeight + (ext[1] + ext[2]) * endScaleY
					end
					totalWidth = totalWidth + (advance + f.letterSpacing) * scaleFactor
					maxHeight = math.max(maxHeight, relativeHeight)
				end
				return Vector2.new(totalWidth, maxHeight)
			end
			f.loaded = false
			function f.setLoaded()
				f.loaded = true
			end
			loadedFonts[name] = fout
			return fout
		end
	end
end
return out
