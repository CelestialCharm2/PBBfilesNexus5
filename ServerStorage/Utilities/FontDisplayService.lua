--SynapseX Decompiler

local DEFAULT_FONT = "R1"
local fds = {}
local out = {}
local FontCreator = require(script.FontCreator)
local ContentProvider = game:GetService("ContentProvider")
local stepped = game:GetService("RunService").RenderStepped
local iterateGraphemes = FontCreator.iterateGraphemes
local wordCharactersString = "abcdefghijklmnopqrstuvwxyz.?!1234567890/-'\";:,[]{}()<>"
local wordCharacters = {}
for i = 1, #wordCharactersString do
	local char = wordCharactersString:sub(i, i)
	wordCharacters[char:lower()] = true
end
setmetatable(out, {
	__index = function(out, index)
		if fds[index] then
			return fds[index]
		else
			error(tostring(index) .. " is not a valid member of fontDisplayService")
		end
	end,
	__newindex = function(out, index, value)
		error("fontDisplayService." .. tostring(index) .. " cannot be set")
	end
})
local function tween(duration, fn)
	local st = tick()
	while true do
		stepped:wait()
		local et = tick() - st
		if duration <= et then
			fn(1)
			return
		end
		local a = et / duration
		fn(a)
	end
end
function fds:Preload(name)
	local font = FontCreator.load(name)
	local source = font.source
	spawn(function()
		local preloadObjects = {}
		if type(source) == "table" then
			for i = 1, #source do
				local image = Instance.new("ImageLabel")
				image.Image = source[i]
				preloadObjects[i] = image
			end
		else
			local image = Instance.new("ImageLabel")
			image.Image = source
			preloadObjects[1] = image
		end
		ContentProvider:PreloadAsync(preloadObjects)
		for _, obj in ipairs(preloadObjects) do
			obj:Remove()
		end
		font.setLoaded()
	end)
end
function fds:WriteToFrame(fontname, size, text, wraps, frame, wordDetectionEnabled, settings)
	local color, writingToChatBox, animationRate, animationFadeDisabled, transparency, scaled, textXAlignment, fadeAfter
	if settings then
		color = settings.Color
		writingToChatBox = settings.WritingToChatBox
		animationRate = settings.AnimationRate
		animationFadeDisabled = settings.AnimationFadeDisabled
		transparency = settings.Transparency
		scaled = settings.Scaled and true or false
		textXAlignment = settings.TextXAlignment
		fadeAfter = settings.FadeAfter
	end
	if text == "" then
		return {}
	end
	local originalText = text
	local font = FontCreator.load(fontname)
	local fontIsV2 = font.isV2
	local substitutionFont = font.substitutionFont
	local fontSubstitutionSize = font.substitutionSize
	local substitutionAlignment = font.substitutionAlignment
	local source = font.source
	local sourceIsTable = type(source) == "table"
	if font.yScale then
		local nframe = Instance.new("Frame")
		nframe.BackgroundTransparency = 1
		nframe.Size = UDim2.new(1, 0, font.yScale, 0)
		nframe.AnchorPoint = Vector2.new(0, 0.5)
		nframe.Position = UDim2.new(0, 0, 0.5, 0)
		nframe.ZIndex = frame.ZIndex
		nframe.Parent = frame
		frame = nframe
		size = math.floor(size * font.yScale + 0.5)
	end
	local substitutionSize = math.floor(fontSubstitutionSize * size / font.baseHeight + 0.5)
	local baselineOffset = Vector2.new(0, font.baselineOffset)
	local maxBounds = Vector2.new()
	local currentPosition = Vector2.new(0, 0)
	local absoluteCurrentPosition = Vector2.new(0, 0)
	local wrappingBounds = frame.AbsoluteSize
	local sizeMultiplierX = size / font.baseHeight
	local wraps = wraps and true or false
	local wordDetectionEnabled = wordDetectionEnabled and true or false
	local currentWord = {}
	local visualCharacters = {}
	local vSize = {}
	local vPosition = {}
	local vTransparentProperty = {}
	local vRise = {}
	local function advancePositionForCharacter(charSize, absoluteCharSize)
		if wraps and currentPosition.X + charSize > wrappingBounds.X then
			currentPosition = Vector2.new(0, currentPosition.Y + font.letterSpacing * sizeMultiplierX + size + font.lineSpacing * sizeMultiplierX)
			absoluteCurrentPosition = Vector2.new(0, absoluteCurrentPosition.Y + font.letterSpacing + font.baseHeight + font.lineSpacing)
		else
			currentPosition = currentPosition + Vector2.new(charSize, 0)
			absoluteCurrentPosition = absoluteCurrentPosition + Vector2.new(absoluteCharSize, 0)
		end
	end
	local function addCharacter(char)
		if char == " " or char == "\t" then
			local unitLength = char == " " and 1 or char == "\t" and 3
			local realSize = (font.spaceWidth + font.letterSpacing) * unitLength * sizeMultiplierX
			advancePositionForCharacter(realSize, (font.spaceWidth + font.letterSpacing) * unitLength)
		elseif char == "\n" then
			currentPosition = Vector2.new(0, currentPosition.y + font.letterSpacing * sizeMultiplierX + size + font.lineSpacing * sizeMultiplierX)
			absoluteCurrentPosition = Vector2.new(0, absoluteCurrentPosition.y + font.letterSpacing + font.baseHeight + font.lineSpacing)
		else
			local bounds, substitute = font.getCharBounds(char)
			local charIsV2 = fontIsV2 and not substitute
			local imgWd = charIsV2 and bounds.ImageRectSize.X or substitute and bounds.X or bounds[3]
			local imgHt = charIsV2 and bounds.ImageRectSize.Y or substitute and bounds.Y or bounds[4]
			local sizeMultiplierY = sizeMultiplierX / (imgHt / font.baseHeight)
			local advance = charIsV2 and bounds.Advance or imgWd
			local elementAbsPosition = absoluteCurrentPosition + baselineOffset
			if charIsV2 then
				elementAbsPosition = elementAbsPosition + bounds.SpriteOffset
			end
			local visual
			if substitute then
				visual = Instance.new("TextLabel")
				visual.Name = tostring(#visualCharacters + 1)
				visual.BackgroundTransparency = 1
				visual.Font = font.substitutionFont
				visual.Text = char
				visual.TextSize = substitutionSize
				visual.Position = UDim2.new(0, elementAbsPosition.X * sizeMultiplierX, 0, (elementAbsPosition.Y + substitutionAlignment) * sizeMultiplierX)
				visual.Size = UDim2.new(0, imgWd * sizeMultiplierX, 0, size)
				vSize[visual] = Vector2.new(imgWd, font.baseHeight)
				vPosition[visual] = elementAbsPosition + Vector2.new(0, substitutionAlignment)
				vTransparentProperty[visual] = "TextTransparency"
				visual.ZIndex = frame.ZIndex
				visual.TextColor3 = color or Color3.new(1, 1, 1)
				if animationRate then
					visual.TextTransparency = 1
				elseif transparency then
					visual.TextTransparency = transparency
				end
			else
				visual = Instance.new("ImageLabel")
				visual.Name = tostring(#visualCharacters + 1)
				visual.BackgroundTransparency = 1
				visual.Image = bounds[5] or sourceIsTable and source[bounds.Sheet or 1] or source
				visual.ImageRectOffset = fontIsV2 and bounds.ImageRectOffset or Vector2.new(bounds[1], bounds[2])
				visual.ImageRectSize = fontIsV2 and bounds.ImageRectSize or Vector2.new(bounds[8] or bounds[3], bounds[9] or bounds[4])
				local postScale = fontIsV2 and bounds.PostScale or bounds[7]
				local x = elementAbsPosition.X * sizeMultiplierX
				local y = elementAbsPosition.Y * sizeMultiplierX
				local w = imgWd * sizeMultiplierX
				local h = imgHt * sizeMultiplierX
				if postScale then
					x = x - w * 0.5 * (postScale - 1)
					y = y - h * 0.5 * (postScale - 1)
					w = w * postScale
					h = h * postScale
					local sp = fontIsV2 and visual.ImageRectSize or Vector2.new(bounds[3], bounds[4])
					vSize[visual] = sp * postScale
					vPosition[visual] = elementAbsPosition - 0.5 * sp * (postScale - 1)
				else
					vSize[visual] = visual.ImageRectSize
					vPosition[visual] = elementAbsPosition
				end
				visual.Position = UDim2.new(0, x, 0, y)
				local dontColor
				if fontIsV2 then
					if postScale then
						visual.Size = UDim2.new(0, w, 0, h)
					else
						visual.Size = UDim2.new(0, w, 0, h)
						vRise[visual] = bounds.SpriteOffset.Y
					end
					dontColor = bounds.NoColor
				else
					visual.Size = UDim2.new(0, w, 0, h)
					dontColor = bounds[5]
				end
				vTransparentProperty[visual] = "ImageTransparency"
				visual.ZIndex = frame.ZIndex
				if color and not dontColor then
					visual.ImageColor3 = color
				end
				if animationRate then
					visual.ImageTransparency = 1
				elseif transparency then
					visual.ImageTransparency = transparency
				end
				if not fontIsV2 then
					local ext = font.extensions[char]
					if ext then
						local top, bottom = ext[1] or 0, ext[2] or 0
						visual.ImageRectOffset = visual.ImageRectOffset + Vector2.new(0, -top)
						visual.ImageRectSize = visual.ImageRectSize + Vector2.new(0, top + bottom)
						visual.Position = visual.Position + UDim2.new(0, 0, 0, sizeMultiplierY * -top)
						visual.Size = visual.Size + UDim2.new(0, 0, 0, sizeMultiplierY * (top + bottom))
						vPosition[visual] = vPosition[visual] + Vector2.new(0, -top)
						vSize[visual] = vSize[visual] + Vector2.new(0, top + bottom)
					end
				end
			end
			table.insert(visualCharacters, visual)
			advancePositionForCharacter((advance + font.letterSpacing) * sizeMultiplierX, advance + font.letterSpacing)
		end
		return true
	end
	local lastWord
	local wordWidth = 0
	local function addWord()
		if lastWord == "\n" and writingToChatBox then
			return false
		end
		lastWord = table.concat(currentWord, "")
		if currentPosition.X + wordWidth > wrappingBounds.X and currentPosition.X > 0 then
			if writingToChatBox then
				return false
			elseif wraps and wordDetectionEnabled then
				currentPosition = Vector2.new(0, currentPosition.Y + font.letterSpacing * sizeMultiplierX + size + font.lineSpacing * sizeMultiplierX)
				absoluteCurrentPosition = Vector2.new(0, absoluteCurrentPosition.Y + font.letterSpacing + font.baseHeight + font.lineSpacing)
			end
		end
		for i, ch in pairs(currentWord) do
			addCharacter(ch)
		end
		currentWord = {}
		wordWidth = 0
		return true
	end
	local overflow, wordStartIndex
	for char, index, isCustom in iterateGraphemes(text, font) do
		if wordCharacters[char:lower()] or font.specialWordCharacters[char] then
			table.insert(currentWord, char)
			if #currentWord == 1 then
				wordStartIndex = index
			end
			wordWidth = wordWidth + font.getStringSize(char, size).X
		else
			if #currentWord > 0 and not addWord() then
				overflow = text:sub(wordStartIndex)
				break
			end
			if char == " " or char == "\t" or char == "\n" then
				addCharacter(char)
			else
				wordStartIndex = index
				currentWord = {char}
				wordWidth = font.getStringSize(char, size).X
				if not addWord() then
					overflow = text:sub(index)
					break
				end
			end
		end
	end
	if #currentWord > 0 and not addWord() then
		overflow = text:sub(wordStartIndex)
	end
	local absoluteMaxBounds
	do
		local mbx, mby = 0, 0
		local amx, amy = 0, 0
		for index, visual in next, visualCharacters, nil do
			mbx = math.max(mbx, visual.Position.X.Offset + visual.Size.X.Offset)
			mby = math.max(mby, visual.Position.Y.Offset + visual.Size.Y.Offset)
			local vp = vPosition[visual]
			local vs = vSize[visual]
			amx = math.max(amx, vp.X + vs.X)
			amy = math.max(amy, vp.Y + vs.Y)
		end
		maxBounds = Vector2.new(mbx, mby)
		absoluteMaxBounds = Vector2.new(amx, amy)
	end
	local container
	if scaled then
		local mbx = maxBounds.X
		local amx = absoluteMaxBounds.X
		local ht = font.baseHeight
		local f = Instance.new("Frame")
		f.BackgroundTransparency = 1
		f.SizeConstraint = Enum.SizeConstraint.RelativeYY
		f.Size = UDim2.new(amx / ht, 0, 1, 0)
		f.Parent = frame
		if textXAlignment == Enum.TextXAlignment.Left then
		elseif textXAlignment == Enum.TextXAlignment.Right then
			f.AnchorPoint = Vector2.new(1, 0)
			f.Position = UDim2.new(1, 0, 0, 0)
		else
			f.AnchorPoint = Vector2.new(0.5, 0)
			f.Position = UDim2.new(0.5, 0, 0, 0)
		end
		for index, visual in pairs(visualCharacters) do
			do
				local vs = vSize[visual]
				local vp = vPosition[visual]
				visual.Size = UDim2.new(vs.X / amx, 0, vs.Y / ht, 0)
				if vRise[visual] then
					local rise = vRise[visual]
					visual.Position = UDim2.new(vp.X / amx, 0, (vp.Y - rise) / ht, 0)
					visual.AnchorPoint = Vector2.new(0, -rise / visual.ImageRectSize.Y)
				else
					visual.Position = UDim2.new(vp.X / amx, 0, vp.Y / ht, 0)
				end
				visual.Parent = f
				if visual:IsA("TextLabel") then
					visual:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
						visual.TextSize = math.floor(fontSubstitutionSize * visual.AbsoluteSize.Y / font.baseHeight + 0.5)
					end)
				end
			end
		end
		container = f
	else
		for index, visual in next, visualCharacters, nil do
			visual.Parent = frame
		end
	end
	if animationRate then
		do
			local subject = settings.Subject
			local talking = true
			local blip = subject and subject.blip or settings.Blip
			if blip then
				do
					local lt = 0
					coroutine.wrap(function()
						local stepped = game:GetService("RunService").RenderStepped
						while talking do
							local now = tick()
							if now - lt > 0.06 then
								blip.Play()
								lt = now
							end
							stepped:wait()
						end
					end)()
				end
			end
			local mbx = maxBounds.x
			if subject and subject.face then
				subject.face:StartTalking()
			end
			if scaled then
				do
					local amx = absoluteMaxBounds.X
					tween(amx / sizeMultiplierX / font.baseHeight / animationRate, function(a)
						local c = amx * a
						for _, v in pairs(visualCharacters) do
							local s = vSize[v].X
							local p = vPosition[v].X
							local propertyName = vTransparentProperty[v]
							if animationFadeDisabled then
								v[propertyName] = c >= p + s / 2 and 0 or 1
							elseif c >= p + s then
								v[propertyName] = 0
							elseif c > p then
								v[propertyName] = 1 - (c - p) / s
							end
						end
					end)
				end
			else
				tween(mbx / sizeMultiplierX / font.baseHeight / animationRate, function(a)
					local c = mbx * a
					for _, v in pairs(visualCharacters) do
						local p = v.Position.X.Offset
						local s = v.Size.X.Offset
						local propertyName = vTransparentProperty[v]
						if c >= p + s then
							v[propertyName] = 0
						elseif c > p then
							v[propertyName] = 1 - (c - p) / s
						end
					end
				end)
			end
			talking = false
			if subject and subject.face and (not overflow or not settings.Line1) then
				subject.face:SetMouthGoal(0)
			end
			if fadeAfter then
				delay(fadeAfter, function()
					tween(mbx / sizeMultiplierX / font.baseHeight / animationRate, function(a)
						local c = mbx * a
						for _, v in pairs(visualCharacters) do
							local p = v.Position.X.Offset
							local s = v.Size.X.Offset
							local propertyName = vTransparentProperty[v]
							if c >= p + s then
								v[propertyName] = 1
							elseif c > p then
								v[propertyName] = (c - p) / s
							end
						end
					end)
				end)
			end
		end
	end
	local thing = {
		Frame = container,
		MaxBounds = maxBounds,
		AbsoluteMaxBounds = absoluteMaxBounds,
		Labels = visualCharacters
	}
	function thing:Remove()
		for _, v in pairs(visualCharacters) do
			v:Remove()
		end
	end
	function thing:Remove()
		self:Remove()
	end
	if writingToChatBox then
		return overflow, thing
	end
	return thing
end
function fds:Write(str)
	return function(settings)
		local wde = settings.WordDetectionEnabled
		if wde == nil then
			wde = true
		end
		return self:WriteToFrame(settings.Font or DEFAULT_FONT, settings.Size or settings.Frame.AbsoluteSize.Y, str, settings.Wraps or false, settings.Frame, wde, settings)
	end
end
return out
