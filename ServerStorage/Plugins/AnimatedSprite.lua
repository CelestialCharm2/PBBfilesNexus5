-- Animated Sprites v3.3
return function(_p)

local stepped = game:GetService('RunService').Stepped
local steppedConnection
local active_animations = {}

--pcall(function() game.Players.LocalPlayer:GetMouse().KeyDown:connect(function(k) if k == 'y' then print(#active_animations) end end) end)

local urlPrefix = 'rbxassetid://'


local animation = _p.Utilities.class({
	className = 'AnimatedSprite',
	
	border = 1,
	startPixelY = 0,
	speed = 0.03,
	
	paused = true,
	startTime = 0,
	currentFrame = 0,
	
	nCaches = 0,
}, function (o)
	local n = {spriteData = o, startTime = tick()}
	
	local spriteLabel = Instance.new(o.button and 'ImageButton' or 'ImageLabel')
	spriteLabel.BackgroundTransparency = 1
	spriteLabel.Size = UDim2.new(1.0, 0, 1.0, 0)
	spriteLabel.ImageRectSize = Vector2.new(o.fWidth, o.fHeight)
	
	n.spriteLabel = spriteLabel
	
	if #o.sheets > 1 then
		n.nCaches = 1
		
		-- Cache negates flicker for animations that cycle through multiple sheets; particularly bad with more than 5, like Mega Charizard Y
		local cache = Instance.new('ImageLabel', spriteLabel)
		cache.ImageTransparency = 0.9
		cache.Image = urlPrefix..o.sheets[1].id
		cache.BackgroundTransparency = 1
		cache.Size = UDim2.new(0.0, 1, 0.0, 1)
		
		n.cache = cache
	end
	
	return n
end)

animation.New = animation.new


-- IMPORTANT - complete steps in this order:
-- Call AnimatedSprite:New()
-- Parent the new animation object's spriteLabel
-- Invoke :Play() on the animation object
-- 
-- If the spriteLabel ever does not have a parent (while
-- playing), the animation will automatically clean itself
-- up. If for some reason you decide to de-parent it and
-- wish to keep it, one way to do this, albeit hacky, is
-- to parent it to an arbitrary object which does not have
-- a parent. This, however, will cause the animation to
-- still update its image each heartbeat. If this
-- functionality is legitimately needed at some point, I
-- will write API for it.


local updateFrameFunction
local function update()
	if #active_animations == 0 then
		steppedConnection:disconnect()
		steppedConnection = nil
		return
	end
	for _, a in pairs(active_animations) do
		updateFrameFunction(a)
	end
end


function animation:Play(speed)
	if not self.paused then return end
	self.relativeSpeed = speed or 1
	self.paused = false
	if self.pauseOffset then
		self.startTime = tick()-self.pauseOffset
		self.pauseOffset = nil
	end
	for _, a in pairs(active_animations) do
		if self == a then return end
	end
	
	if not self.frameData then
		local f = 0
		local sd = self.spriteData
		local fd = {}
		for sheetNumber, sheet in pairs(sd.sheets) do
			local framesBeforeSheet = f
			local f_end = f + sheet.rows * sd.framesPerRow
			for frame = f, math.min(f_end, sd.nFrames)-1 do
				local frameNumberSheet = frame - framesBeforeSheet
				local col, row = frameNumberSheet % sd.framesPerRow, math.floor(frameNumberSheet / sd.framesPerRow)
				local cacheId
				if self.nCaches > 0 then
					if sheetNumber == #sd.sheets then
						cacheId = sd.sheets[1].id
					else
						cacheId = sd.sheets[sheetNumber + 1].id
					end
				end
				fd[frame+1] = {
					urlPrefix..sheet.id,
					Vector2.new(col*(sd.fWidth+(sd.border or self.border)), row*(sd.fHeight+(sd.border or self.border))+(sheet.startPixelY or self.startPixelY)),
					(cacheId and urlPrefix..cacheId or nil)
				}
			end
			f = f_end
		end
		self.frameData = fd
	end
	
	table.insert(active_animations, self)
	if not steppedConnection then
		steppedConnection = stepped:connect(update)
	end
end

function animation:Pause()
	if self.paused then return end
	self.paused = true
	self.pauseOffset = tick()-self.startTime
	for i = #active_animations, 1, -1 do
		if active_animations[i] == self then
			table.remove(active_animations, i)
		end
	end
	--
end

function animation:UpdateFrame()
	if self.paused then return end
	local sl = self.spriteLabel
	if not sl.Parent then
		self:Remove()
		return
	end
	if not sl.Visible then return end
	local sd = self.spriteData
	local frameNumber = math.floor((tick()-self.startTime)/(sd.speed or self.speed)*self.relativeSpeed) % sd.nFrames + 1
	if frameNumber == self.currentFrame then return end
	self.currentFrame = frameNumber
	local fd = self.frameData[frameNumber]
	sl.Image = fd[1]
	sl.ImageRectOffset = fd[2]
	if fd[3] then
		self.cache.Image = fd[3]
	end
	if self.updateCallback then
		self.updateCallback(frameNumber / sd.nFrames)
	end
end
updateFrameFunction = animation.UpdateFrame

function animation:RenderFirstFrame()
	local sl = self.spriteLabel
	local sd = self.spriteData
	local sheet = sd.sheets[1]
	sl.Image = urlPrefix..sheet.id
	sl.ImageRectOffset = Vector2.new(0, sheet.startPixelY or 0)
end

function animation:Remove() self:Remove() end
function animation:Remove()
--	print('animation::Remove')
	for i = #active_animations, 1, -1 do
		if active_animations[i] == self then
			table.remove(active_animations, i)
		end
	end
	
	pcall(function() self.spriteLabel:Remove() end)
	
	for i in pairs(self.frameData) do
		self.frameData[i] = nil
	end
	for i in pairs(self) do
		self[i] = nil
	end
end


return animation end