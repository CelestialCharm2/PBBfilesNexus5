-- Buildthomas (2013 + 2016)
-- Voltorb Flip minigame module

local voltorbflip = {}

-- For first return value of 'flip' function:

voltorbflip.LOSE			= 0
voltorbflip.POINTS			= 1
voltorbflip.ALREADYFLIPPED	= 2

-- Flip method:

local function flip(self, row, col)
	
	-- If already flipped, we return
	-- indicator for already flipped:
	if self.Flipped[row][col] then
		return voltorbflip.ALREADYFLIPPED
	end
	
	-- Set position as flipped:
	self.Flipped[row][col] = true
	self.TilesFlipped = self.TilesFlipped + 1
	
	if self.Board[row][col] == 0 then -- Voltorb!
		
		-- No points this round:
		self.Score = 0
		
		-- Return indicator for losing:
		return voltorbflip.LOSE
		
	else -- Points! (1/2/3)
		
		-- Multiply/add score using found value:
		self.Score = (self.Score == 0) and (self.Board[row][col]) or (self.Score * self.Board[row][col])
		
		-- Check if game is finished:
		if self.Score == self.MaxScore then
			self.Complete = true
		end
		
		-- Return indicator and points value:
		return voltorbflip.POINTS, self.Board[row][col]
		
	end
end

-- Create a new level with at least "voltorbAmount" Voltorbs
-- which will give at least "scoreThreshold" amount of points:

function voltorbflip.new(voltorbAmount, scoreThreshold)
	
	voltorbAmount = voltorbAmount and math.min(25, voltorbAmount) or 8
	scoreThreshold = scoreThreshold or 150	
	
	-- Level data:
	
	local level = {
		Score = 0,								-- The current score
		MaxScore = 1,							-- Maximum score that can be achieved
		TilesFlipped = 0,						-- Amount of turns in current game
		Complete = false,						-- Whether user has won yet
		Rows = {},								-- Will contain row counters
		Columns = {},							-- Will contain column counters
		Board = {								-- Board data (0 = voltorb, 1/2/3 = point count)
			{1,1,1,1,1},
			{1,1,1,1,1},
			{1,1,1,1,1},
			{1,1,1,1,1},
			{1,1,1,1,1}
		},
		Flipped = {								-- Whether a position has been flipped
			{false,false,false,false,false},
			{false,false,false,false,false},
			{false,false,false,false,false},
			{false,false,false,false,false},
			{false,false,false,false,false}
		},
		flip = flip								-- Flip method (see above)
	}
	
	-- Make a list of all positions that still contain a 1:
	local indicesAvailable = {}
	for row = 1, 5 do
		for col = 1, 5 do
			table.insert(indicesAvailable, {row, col})
		end
	end
	
	-- Overwrite random positions that contain 1s with voltorbs:
	for i = 1, voltorbAmount do
		
		-- Get random available position:
		local index = math.random(1, #indicesAvailable)
		local coords = table.remove(indicesAvailable, index)
		
		-- Set to 0 (voltorb):
		level.Board[coords[1]][coords[2]] = 0
		
	end
	
	-- Keep randomly adding 2s and 3s to the board until the
	-- scoreThreshold is achieved, or until no 1s left:
	while level.MaxScore < scoreThreshold and #indicesAvailable > 0 do
		
		-- Get random available position:
		local index = math.random(1, #indicesAvailable)
		local coords = table.remove(indicesAvailable, index)
		
		-- Get random value of 2 or 3:
		local value = math.random(2,3)
		
		-- Update maximum achievable score:
		level.MaxScore = level.MaxScore * value
		
		-- Update board position:
		level.Board[coords[1]][coords[2]] = value
		
	end
	
	-- Give warning if we did not achieve threshold:
	if level.MaxScore < scoreThreshold then
		warn(("VoltorbFlip - Could not achieve score threshold (voltorbAmount: %d, scoreThreshold: %d)"):format(voltorbAmount, scoreThreshold))
	end
	
	-- Count voltorbs/score in each row:
	for row = 1, 5 do
		
		local voltorbs = 0
		local points = 0
		
		for col = 1, 5 do
			if level.Board[row][col] == 0 then
				voltorbs = voltorbs + 1
			else
				points = points + level.Board[row][col]
			end
		end
		
		level.Rows[row] = {
			Voltorbs = voltorbs,
			Points = points
		}
		
	end
	
	-- Count voltorbs/score in each column:
	for col = 1, 5 do
		
		local voltorbs = 0
		local points = 0
		
		for row = 1, 5 do
			if level.Board[row][col] == 0 then
				voltorbs = voltorbs + 1
			else
				points = points + level.Board[row][col]
			end
		end
		
		level.Columns[col] = {
			Voltorbs = voltorbs,
			Points = points
		}
		
	end
	
	return level
	
end

return voltorbflip
