return function(_p)
	local Utilities = _p.Utilities
	local Create = Utilities.Create

	local surf = {
		surfing = false
	}

	local function getSurfWalls(map)	
		local surfWalls = {}
		while true do
			local wall = map:FindFirstChild("SurfWall", true) or map:FindFirstChild("NotSurfWall", true)
			if not wall then
				break
			end
			table.insert(surfWalls, wall)
			wall.Parent = nil
		end
		return surfWalls
	end

	local function makePhysics(p3)
		return Create("BodyPosition")({
			Position = p3.Position, 
			MaxForce = Vector3.new(math.huge, math.huge, math.huge), 
			Parent = p3
		}), Create("BodyGyro")({
			CFrame = CFrame.new(), 
			MaxTorque = Vector3.new(9000000, 10000, 9000000), 
			Parent = p3
		})
	end

	local function surfInternal(part, bp, bg, HumanoidRootPart, waterHeight, surfWalls)
		bp.MaxForce = Vector3.new(0, math.huge, 0)
		function surf.invalidateSurfWalls()
			surfWalls = nil
		end
		local MasterControl = _p.MasterControl
		local CurrentCamera = workspace.CurrentCamera
		local bv = Create("BodyVelocity")({
			MaxForce = Vector3.new(15000, 0, 15000), 
			Velocity = Vector3.new(0, 0, 0), 
			P = 800, 
			Parent = part
		})
		MasterControl:SetMoveFunc(function(_, dir, cameraRelative)
			if cameraRelative then
				local lookVector = CurrentCamera.CFrame.lookVector
				dir = -CFrame.new(Vector3.new(), Vector3.new(lookVector.X, 0, -lookVector.Z)):pointToObjectSpace(dir)
			end
			if dir.magnitude > 1 then
				dir = dir.unit
			end
			bv.Velocity = dir * 30
			if not (dir.magnitude > 0.1) then
				bg.CFrame = part.CFrame
				return
			end
			bg.CFrame = CFrame.new(Vector3.new(), dir)
		end)
		local touchingObj = nil
		local touchingThread = nil
		part.Touched:Connect(function(wall)
			if wall.Name ~= "SurfWall" then
				return
			end
			print('was surfwall')
			touchingObj = wall
			local thisThread = {}
			touchingThread = thisThread
			while touchingObj == wall and touchingThread == thisThread do
				local Position = HumanoidRootPart.Position
				local pttp = wall.CFrame:pointToObjectSpace(Position)
				if MasterControl.WalkEnabled--[[ and math.abs(pttp.X) < wall.Size.X / 2 - 2 ]]and math.deg(math.acos(part.CFrame.lookVector:Dot(wall.CFrame.lookVector))) < 30 then
					MasterControl:SetMoveFunc()
					MasterControl.WalkEnabled = false
					MasterControl:Stop()
					local wpr = wall.CFrame * CFrame.new(pttp.X, 0, -4)
					local characters = {}
					for i, pl in pairs(game:GetService("Players"):GetChildren()) do
						pcall(function()
							characters[#characters + 1] = pl.Character
						end)
					end
					local _, pos = workspace:FindPartOnRayWithIgnoreList(Ray.new(wpr.p, Vector3.new(0, -wall.Size.Y, 0)), characters)
					local map = _p.DataManager.currentChunk.map
					if not surfWalls then
						surfWalls = getSurfWalls(map)
					end
					for i, wall in pairs(surfWalls) do
						wall.Parent = nil
					end
					local ncf = (wpr + Vector3.new(0, pos.Y - wpr.y + waterHeight, 0)).p - Position
					local unit = (ncf * Vector3.new(1, 0, 1)).unit
					_p.Network:post("PDS", "unsurf")
					pcall(function()
						part:Remove()
					end)
					surf.surfAnim:Stop(0.5)
					Utilities.Tween(0.5, nil, function(p14)
						local p = Position + ncf * p14 + Vector3.new(0, 4 * math.sin(p14 * math.pi), 0)
						HumanoidRootPart.CFrame = CFrame.new(p, p + unit)
					end)
					surf.surfing = false
					for i, wall in pairs(surfWalls) do
						wall.Parent = map
					end
					surf.invalidateSurfWalls = nil
					pcall(function()
						Utilities.getHumanoid():ChangeState(Enum.HumanoidStateType.Freefall)
					end)
					MasterControl.WalkEnabled = true
					return
				end
				wait(0.15)
			end
		end)
		part.TouchEnded:connect(function(wall)
			if touchingObj == wall then
				touchingThread = nil
			end
		end)
	end

	function surf:surf(surfUser, surfWallPos, waterLevel)
		if self.surfing then
			return
		end
		self.surfing = true
		local HumanoidRootPart = _p.player.Character.HumanoidRootPart
		local surfPart = nil
		local weld = nil
		local Position = HumanoidRootPart.Position
		local bp = nil
		local bg = nil
		_p.NPCChat:say(surfUser.." used Surf!")
		spawn(function()
			local sp, w = _p.Network:get("PDS", "surf")
			surfPart = sp
			weld = w
			surfPart.CFrame = CFrame.new(Position + Vector3.new(0, -3, 0))
			bp, bg = makePhysics(surfPart)
		end)
		while not surfPart do
			wait()
		end
		self.surfPart = surfPart
		surfPart.Archivable = false
		local ptos = surfWallPos * CFrame.new(surfWallPos:pointToObjectSpace(Position).X, 0, 4) * CFrame.Angles(0, math.pi, 0)
		local ppt = ptos + Vector3.new(0, waterLevel - ptos.y - 0.25, 0)
		surfPart.CFrame = ppt
		bp.Position = ppt.p
		bg.CFrame = ppt
		local humanoid = Utilities.getHumanoid()
		humanoid:ChangeState(Enum.HumanoidStateType.Physics)
		local isR15 = (humanoid.RigType == Enum.HumanoidRigType.R15)
		local map = _p.DataManager.currentChunk.map
		local surfWalls = getSurfWalls(map)
		local vtos = ppt:vectorToObjectSpace(ppt.p - Position)
		local nv = Vector3.new(0, 2 + (isR15 and humanoid.HipHeight + HumanoidRootPart.Size.Y / 2 or 2), 0)
		weld.C0 = CFrame.new()
		weld.Part1 = HumanoidRootPart
		local prefix = ""
		if isR15 then
			prefix = "R15_"
		else
			prefix = ""
		end
		local anim = humanoid:LoadAnimation(Create "Animation" {
			AnimationId = "rbxassetid://6878281705"
		})
		anim:Play(0.5)
		self.surfAnim = anim
		Utilities.Tween(0.5, nil, function(a)
			weld.C1 = CFrame.new(vtos * (1 - a) - nv + Vector3.new(0, -4 * math.sin(a * math.pi), 0))
		end)
		_p.Network:post("PDS", "fixSurf")
		for i, wall in pairs(surfWalls) do
			wall.Parent = map
		end
		wait()
		surfInternal(surfPart, bp, bg, HumanoidRootPart, nv.Y, surfWalls)
	end

	function surf:forceSurf(pos)
		local hrp
		self.surfing = true
		while true do
			hrp = nil
			pcall(function()
				hrp = _p.player.Character.HumanoidRootPart
			end)
			if hrp then
				break
			end
			wait()
		end
		local part, weld = _p.Network:get("PDS", "surf", true)
		part.CFrame = pos
		part.Archivable = false
		local bp, bg = makePhysics(part)
		bp.Position = pos.p
		bg.CFrame = pos
		self.surfPart = part
		local humanoid = Utilities.getHumanoid()
		humanoid:ChangeState(Enum.HumanoidStateType.Physics)
		local isR15 = humanoid.RigType == Enum.HumanoidRigType.R15
		local prefix
		if isR15 then
			prefix = "R15_"
		else
			prefix = ""
		end
		local anim = humanoid:LoadAnimation(Create "Animation" {
			AnimationId = "rbxassetid://6878281705"
		})
		anim:Play(0)
		self.surfAnim = anim
		wait()
		surfInternal(part, bp, bg, hrp, 2 + (isR15 and humanoid.HipHeight + hrp.Size.Y / 2 or 3), nil)
	end
	function surf:forceUnsurf()
		_p.Network:post("PDS", "unsurf")
		pcall(function()
			self.surfPart:Remove()
		end)
		pcall(function()
			Utilities.getHumanoid():ChangeState(Enum.HumanoidStateType.Freefall)
		end)
		_p.MasterControl:SetMoveFunc()
		pcall(function()
			self.surfAnim:Stop(0)
		end)
		self.surfing = false
	end
	function surf:beforeFishing()
		self.surfAnim:Stop(0.3)
		wait(0.3)
	end
	function surf:afterFishing()
		self.surfAnim:Play(0.3)
		wait(0.3)
	end

	return surf end
