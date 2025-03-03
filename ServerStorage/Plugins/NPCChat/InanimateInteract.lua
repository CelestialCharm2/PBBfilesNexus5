return function(_p)
local Utilities = _p.Utilities
local create = Utilities.Create

local manaphy = Utilities.rc4('Manaphy')

return {
	hackableShrubbery = function(model)
		if not _p.MasterControl.WalkEnabled then return end
		_p.DataManager:preload(316598829)
		local trunk = model.CutKit.Main
		local chat = _p.NPCChat
		_p.MasterControl.WalkEnabled = false
		_p.MasterControl:Stop()
		spawn(function() _p.MasterControl:LookAt(trunk.Position) end)
		local cutter, done
		Utilities.fastSpawn(function()
			cutter = _p.Network:get('PDS', 'getCutter')
			done = true
		end)
		chat:say('This tree looks like it can be cut down.')
		while not done do wait() end
		if not cutter or not chat:say('[y/n]Would you like ' .. cutter .. ' to use Cut?') then
			_p.MasterControl.WalkEnabled = true
			return
		end
		chat:say(cutter .. ' used Cut!')
		pcall(function() model['#InanimateInteract']:Remove() end)
		local slashEffect = model.CutKit.SlashEffect
		local size = slashEffect.Size
		slashEffect.Parent = model
		local playerPos = _p.player.Character.HumanoidRootPart.CFrame
		local cf = CFrame.new(trunk.Position, Vector3.new(playerPos.X, trunk.CFrame.Y, playerPos.Z))
		Utilities.sound(316598829, nil, nil, 5)
		Utilities.Tween(.35, nil, function(a)
			slashEffect.Size = size*(0.2+1.2*math.sin(a*math.pi))
			slashEffect.CFrame = cf * CFrame.new(-3+6*a, 3-6*a, -2.5) * CFrame.Angles(0, math.pi/2, 0) * CFrame.Angles(math.pi/4, 0, 0)
		end)
		slashEffect:Remove()
		model.Main:Remove()
		Utilities.MoveModel(trunk, cf)
		create 'Weld' {
			Part0 = model.CutKit.Top,
			Part1 = model.TreePart,
			C0 = CFrame.new(),
			C1 = model.TreePart.CFrame:inverse() * model.CutKit.Top.CFrame,
			Parent = model.CutKit.Top,
		}
		model.TreePart.Anchored = false
		model.CutKit.Top.Anchored = false
		local force = create 'BodyForce' {
			Force = -cf.lookVector * 5000,
			Parent = model.CutKit.Top,
		}
		local force2 = create 'BodyForce' {
			Force = -cf.lookVector * 9000,
			Parent = model.TreePart,
		}
		wait(.5)
--		pcall(function()
--			if model.Parent.Name == 'ChristmasTrees' then
--				local cutall = true
--				for _, tree in pairs(model.Parent:GetChildren()) do
--					if tree:FindFirstChild('#InanimateInteract') then
--						cutall = false
--						break
--					end
--				end
--				if cutall then
--					_p.Events.onCutAllChristmasTrees()
--				end
--			end
--		end)
		_p.MasterControl.WalkEnabled = true
		force:Remove()
		force2:Remove()
		wait(1)
		Utilities.Tween(1, nil, function(a)
			model.CutKit.Top.Transparency = a
			model.CutKit.Base.Transparency = a
			model.TreePart.Transparency = a
		end)
		model.CutKit:Remove()
		model.TreePart:Remove()
	end,
	
	durantHill = function(model)
		if not _p.MasterControl.WalkEnabled then return end
		local chat = _p.NPCChat
		_p.MasterControl.WalkEnabled = false
		_p.MasterControl:Stop()
		spawn(function() _p.MasterControl:LookAt(model.Main.Position) end)
		local digger, done
		Utilities.fastSpawn(function()
			digger = _p.Network:get('PDS', 'getDigger')
			done = true
		end)
		chat:say('This pile of dirt seems to have been made by a pokemon.')
		if not digger or not chat:say('[y/n]Would you like ' .. digger .. ' to use Dig?') then
			_p.MasterControl.WalkEnabled = true
			return
		end
		chat:say(digger .. ' used Dig!')
		pcall(function() model['#InanimateInteract']:Remove() end)
		model.Part:Remove()
		model.Main.Transparency = 1.0
		model.Main.CanCollide = false
		local smoke = create 'Smoke' {
			Color = BrickColor.new('Brown').Color,
			Parent = model.Main,
		}
		delay(10, function()
			smoke:Remove()
		end)
		wait(.5)
		smoke.Enabled = false
		wait(1.5)
		if math.random(10) <= 3 then
			_p.Battle:doWildBattle(_p.DataManager.currentChunk.regionData.Anthill, {battleSceneType = 'Safari'})
		end
		_p.MasterControl.WalkEnabled = true
	end,
	
	spiritombWell = function(model)
		if not _p.MasterControl.WalkEnabled then return end
		local chat = _p.NPCChat
		_p.MasterControl.WalkEnabled = false
		_p.MasterControl:Stop()
		spawn(function() _p.MasterControl:LookAt(model.Main.Position) end)
		
		if _p.PlayerData.hasOddKeystone then
			if chat:say('Whispers can be heard coming from deep within the well.',
				'The Odd Keystone in your Bag is rumbling...',
				'[y/n]Toss the Odd Keystone into the well?')
			  then
				chat:say('You tossed the Odd Keystone into the well.')
				model.SmokePart.Smoke.Enabled = true
				local cf = CFrame.new(model.Main.Position + Vector3.new(0, -model.Main.Size.X/2+.1, 0))
				for i = 1, 3 do
					local pulse = create 'Part' {
						Transparency = 1,
						Anchored = true,
						CanCollide = false,
						Parent = model,
					}
					local sg = create 'SurfaceGui' {
						CanvasSize = Vector2.new(600, 600),
						Face = Enum.NormalId.Top,
						Adornee = pulse,
						Parent = pulse,
					}
					local image = create 'ImageLabel' {
						BackgroundTransparency = 1.0,
						Image = 'rbxassetid://5120116026',
						ImageColor3 = Color3.new(.5, 0, 1),
						Size = UDim2.new(1.0, 0, 1.0, 0),
						Parent = sg,
					}
					spawn(function()
						Utilities.Tween(1.5, nil, function(a)
							pulse.Size = Vector3.new(5+a*10, 0.2, 5+a*10)
							pulse.CFrame = cf
							if a > .75 then
								image.ImageTransparency = (a-.75)*4
							end
						end)
						pulse:Remove()
					end)
					wait(1)
				end
				delay(5, function()
					model.SmokePart.Smoke.Enabled = false
				end)
				_p.Battle:doWildBattle(_p.DataManager.currentChunk.regionData.Well, {battleSceneType = 'SpiritombWell'})
				_p.PlayerData.hasOddKeystone = _p.Network:get('PDS', 'hasOKS')
			end
		else
			chat:say('This well looks really old...')
		end
		_p.MasterControl.WalkEnabled = true
	end,
	
	headbuttablePalmTree = function(model)
		if not _p.MasterControl.WalkEnabled then return end
		_p.DataManager:preload(330262909)-- preload sound
		local chat = _p.NPCChat
		_p.MasterControl.WalkEnabled = false
		_p.MasterControl:Stop()
		spawn(function() _p.MasterControl:LookAt(model.Main.Position) end)
		local headbutter, done
		Utilities.fastSpawn(function()
			headbutter = _p.Network:get('PDS', 'getHeadbutter')
			done = true
		end)
		chat:say('It\'s a large palm tree that could possibly be the home to small pokemon.')
		while not done do wait() end
		if headbutter and chat:say('[y/n]Would you like ' .. headbutter .. ' to use Headbutt?') then
			chat:say(headbutter .. ' used Headbutt!')
			local p = model.Main.Position + Vector3.new(0, -model.Main.Size.Y/2+0.8, 0)
			local cf = CFrame.new(p, p + (p-_p.player.Character.HumanoidRootPart.Position)*Vector3.new(1, 0, 1))
			local cfs = {}
			for _, ch in pairs(model:GetChildren()) do
				if ch:IsA('BasePart') then
					cfs[ch] = cf:toObjectSpace(ch.CFrame)
				end
			end
			local pow = _p.storage.Models.Misc.Pow:Clone()
			pow.Parent = workspace
			local ps = pow.Size*.7
			pow.CFrame = cf * CFrame.new(0, model.Main.Size.Y/2, model.Main.Size.Z/2+.4) * CFrame.Angles(0, math.pi/2, 0)
			local particlePart = create 'Part' {
				Transparency = 1.0,
				Anchored = true,
				CanCollide = false,
				Size = Vector3.new(10, 1, 10),
				CFrame = model.Main.CFrame * CFrame.new(0, 25, 0),
				Parent = workspace,
			}
			local emitter = create 'ParticleEmitter' {
				EmissionDirection = Enum.NormalId.Bottom,
				Color = ColorSequence.new(BrickColor.new('Bright green').Color),
				Lifetime = NumberRange.new(26),
				Rate = 12,
				Speed = NumberRange.new(5),
				RotSpeed = NumberRange.new(-50, 50),
				Texture = 'rbxassetid://5217700605',--330258890
				Parent = particlePart,
			}
			game:GetService('Debris'):AddItem(particlePart, 11)
			Utilities.sound(330262909, nil, nil, 5)
			Utilities.Tween(1.25, nil, function(a)
				if pow then
					if a > .4 then
						pow:Remove()
						pow = nil
						emitter.Enabled = false
					else
						if a > .2 then
							pow.Transparency = (a-.2)*5
						end
						pow.Size = ps * (1+a)
--						pow.CFrame = pcf * CFrame.Angles(a*2, 0, 0)
					end
				end
				local ncf = cf*CFrame.Angles(-math.sin(a*math.pi*2)*.4*(1-a), 0, 0)
				for part, rcf in pairs(cfs) do
					part.CFrame = ncf:toWorldSpace(rcf)
				end
			end)
			wait(1)
			local enc
			pcall(function() enc = _p.DataManager.currentChunk.regionData.PalmTree end)
			if enc and math.random(10) <= 5 then
				_p.Battle:doWildBattle(enc)
			end
		end
		_p.MasterControl.WalkEnabled = true
	end,
	
	headbuttablePineTree = function(model)
		if not _p.MasterControl.WalkEnabled then return end
		_p.DataManager:preload(330262909)
		local chat = _p.NPCChat
		_p.MasterControl.WalkEnabled = false
		_p.MasterControl:Stop()
		spawn(function() _p.MasterControl:LookAt(model.Main.Position) end)
		local headbutter, done
		Utilities.fastSpawn(function()
			headbutter = _p.Network:get('PDS', 'getHeadbutter')
			done = true
		end)
		chat:say('It\'s a tall tree that could possibly be the home to small pokemon.')
		while not done do wait() end
		if headbutter and chat:say('[y/n]Would you like ' .. headbutter .. ' to use Headbutt?') then
			chat:say(headbutter .. ' used Headbutt!')
			local p = model.Main.Position + Vector3.new(0, -model.Main.Size.Y/2+2, 0)
			local cf = CFrame.new(p, p + (p-_p.player.Character.HumanoidRootPart.Position)*Vector3.new(1, 0, 1))
			local cfs = {}
			for _, ch in pairs(model:GetChildren()) do
				if ch:IsA('BasePart') then
					cfs[ch] = cf:toObjectSpace(ch.CFrame)
				end
			end
			local pow = _p.storage.Models.Misc.Pow:Clone()
			pow.Parent = workspace
			local ps = pow.Size*.7
			pow.CFrame = cf * CFrame.new(0, 3.5, model.Main.Size.Z/2+1) * CFrame.Angles(0, math.pi/2, 0)
			local particlePart = create 'Part' {
				Transparency = 1.0,
				Anchored = true,
				CanCollide = false,
				Size = Vector3.new(10, 1, 10),
				CFrame = model.Main.CFrame * CFrame.new(0, 25, 0),
				Parent = workspace,
			}
			local emitter = create 'ParticleEmitter' {
				EmissionDirection = Enum.NormalId.Bottom,
--				Color = ColorSequence.new(BrickColor.new('Bright green').Color),
				Size = NumberSequence.new(.3),
				Lifetime = NumberRange.new(26),
				Rate = 12,
				Speed = NumberRange.new(5),
				RotSpeed = NumberRange.new(-50, 50),
				Texture = 'rbxassetid://5217702038',
				Parent = particlePart,
			}
			game:GetService('Debris'):AddItem(particlePart, 11)
			Utilities.sound(330262909, nil, nil, 5)
			Utilities.Tween(1.25, nil, function(a)
				if pow then
					if a > .4 then
						pow:Remove()
						pow = nil
						emitter.Enabled = false
					else
						if a > .2 then
							pow.Transparency = (a-.2)*5
						end
						pow.Size = ps * (1+a)
--						pow.CFrame = pcf * CFrame.Angles(a*2, 0, 0)
					end
				end
				local ncf = cf*CFrame.Angles(-math.sin(a*math.pi*2)*.4*(1-a), 0, 0)
				for part, rcf in pairs(cfs) do
					part.CFrame = ncf:toWorldSpace(rcf)
				end
			end)
			wait(1)
			local enc
			pcall(function() enc = _p.DataManager.currentChunk.regionData.PineTree end)
			if enc and math.random(10) <= 5 then
				_p.Battle:doWildBattle(enc)
			end
		end
		_p.MasterControl.WalkEnabled = true
	end,
	
	Water = function(_, pos)
		_p.Fishing:OnWaterClicked(pos)
	end,
	
	SpookyBook = function(model)
		pcall(function() model['#InanimateInteract']:Remove() end)
		local m = Instance.new('Model', model)
		local mm = Utilities.MoveModel
		for _, ch in pairs(model:GetChildren()) do
			if ch.Name == 'Top' then
				ch.Parent = m
			end
		end
		local hinge = model.Hinge
		hinge.Parent = m
		local hcf = hinge.CFrame
		Utilities.Tween(.5, 'easeOutCubic', function(a)
			mm(hinge, hcf * CFrame.Angles(0, -math.pi*0.5*a, 0))
		end)
		local button = model.Button
		local bm = Instance.new('Model', model)
		button.Parent = bm
		button.Name = 'Main'
		create 'StringValue' {
			Name = '#InanimateInteract',
			Value = 'SpookyBookButton',
			Parent = bm,
		}
	end,
	
	SpookyBookButton = function(model)
		if not _p.MasterControl.WalkEnabled then return end
		pcall(function() model['#InanimateInteract']:Remove() end)
		_p.MasterControl.WalkEnabled = false
		_p.MasterControl:Stop()
		
		local chunk = _p.DataManager.currentChunk
		local room = chunk:topRoom()
		
		local wardrobe = room.model.Wardrobe
		spawn(function() _p.MasterControl:LookAt(wardrobe.Main.Position) end)
		
		local cam = workspace.CurrentCamera
		chunk:unbindIndoorCam()
		do
			local startCF = cam.CoordinateFrame
			local p = Vector3.new(wardrobe.Main.Position.X + 10, room.model.Base.Position.Y + room.model.Base.Size.Y/2 + 4.5, wardrobe.Main.Position.Z)
			local angle = math.rad(40)
			local from = p + Vector3.new(0, math.sin(angle), -math.cos(angle))*18
			local endCF = CFrame.new(from, p)
			local lerp = select(2, Utilities.lerpCFrame(startCF, endCF))
			Utilities.Tween(.75, 'easeOutCubic', function(a)
				cam.CoordinateFrame = startCF + (from - startCF.p) * a
			end)
		end
		
		local main = wardrobe.Main
		local wcf = main.CFrame
		local lhp, rhp, lh, rh = wardrobe.LDoor.Hinge, wardrobe.RDoor.Hinge, wardrobe.LHinge, wardrobe.RHinge
		local mm = Utilities.MoveModel
		Utilities.sound(360064127, .8, nil, 5)
		Utilities.Tween(.75, 'easeOutCubic', function(a)
			mm(main, wcf * CFrame.Angles(math.sin(a*math.pi*2)*-0.1, 0, math.sin(a*math.pi)*0.2))
			mm(lhp, lh.CFrame * CFrame.Angles(0, 3*a, 0))
			mm(rhp, rh.CFrame * CFrame.Angles(0, -3*a, 0))
		end)
		
		do
			local startCF = cam.CoordinateFrame
			local p = room.model.Base.Position + Vector3.new(0, room.model.Base.Size.Y/2 + 4.5, 0)
			local angle = math.rad(30)
			local from = p + Vector3.new(0, math.sin(angle), -math.cos(angle))*25
			local endCF = CFrame.new(from, p)
			local lerp = select(2, Utilities.lerpCFrame(startCF, endCF))
			Utilities.Tween(.75, 'easeOutCubic', function(a)
				cam.CoordinateFrame = lerp(a)
			end)
		end
		
		local st = tick()
		local sucking = true
		local endPoint = wardrobe.Main.Position + Vector3.new(0, 2.5, 0)
		local function particle()
			local size = .4 + math.random()*.6
			local part = create 'Part' {
				Transparency = 1.0,
				Anchored = true,
				CanCollide = false,
--				FormFactor = Enum.FormFactor.Custom,
				Size = Vector3.new(.2, .2, .2),
				Parent = workspace,
			}
			local frame = create 'Frame' {
				BorderSizePixel = 0,
				BackgroundColor3 = Color3.new(.7, .7, .7),
				Size = UDim2.new(1.0, 0, 1.0, 0),
				Parent = create 'BillboardGui' {
					Size = UDim2.new(size, 0, size, 0),
					Adornee = part, Parent = part,
				}
			}
			local startRotation = math.random(360)
			local deltaRotation = math.random(-360, 360) * 3
			local startPoint = endPoint + Vector3.new(20 + math.random(10), math.random(-5, 5), math.random(-10, 10))
			local moveVector = endPoint - startPoint
			local duration = 1.5 - math.min(1, (tick() - st)/2)
			Utilities.Tween(duration, 'easeInCubic', function(a)
				if not sucking then return false end
				frame.BackgroundTransparency = 1-a
				frame.Rotation = startRotation + deltaRotation * a
				part.CFrame = CFrame.new(startPoint + moveVector * a)
			end)
			part:Remove()
		end
		local whoosh = Utilities.sound(360068426)
		spawn(function()
			while sucking do
				spawn(particle)
				wait(.1)
			end
		end)
		wait(2)
		for _, wedge in pairs(room.model.Funnel:GetChildren()) do
			wedge.CanCollide = true
		end
		local hGoal = endPoint + Vector3.new(2, 0, 0)
		local humanoid = Utilities.getHumanoid()
		local psc = humanoid.Changed:connect(function()
			humanoid.PlatformStand = true
		end)
		humanoid.PlatformStand = true
		local hroot = _p.player.Character.HumanoidRootPart
		local force = create 'BodyForce' {
			Parent = hroot,
		}
		local mf = 3000
		Utilities.Tween(.5, 'easeInCubic', function(a)
			force.Force = (hGoal - hroot.Position).unit * mf * a
		end)
		local antigravs = {}
		local function antigrav(obj)
			if obj:IsA('BasePart') then
				table.insert(antigravs, create 'BodyForce' {
					Force = Vector3.new(0, 196.2 * obj:GetMass(), 0),
					Parent = obj,
				})
			end
			for _, ch in pairs(obj:GetChildren()) do
				antigrav(ch)
			end
		end
		antigrav(_p.player.Character)
		local stepped = game:GetService('RunService').RenderStepped
		while hroot.Position.X > hGoal.X do
			stepped:wait()
			force.Force = (hGoal - hroot.Position).unit * mf
			if force.Force.X > 0 then
				force.Force = force.Force * Vector3.new(0, 1, 1)
			end
		end
		force:Remove()
		local bp = create 'BodyPosition' {
			Position = endPoint,
			Parent = hroot,
		}
		spawn(function()
			local v = whoosh.Volume
			Utilities.Tween(1, nil, function(a)
				whoosh.Volume = v * (1-a)
			end)
			whoosh:Remove()
		end)
		Utilities.FadeOut(1, Color3.new(0, 0, 0))
		sucking = false
		Utilities.TeleportToSpawnBox()
		chunk:popSubRoom(true)
		room = chunk:stackSubRoom('HMUpperHall', chunk:topRoom().model.SubRoom, true)
		room = chunk:stackSubRoom('HMBadBedroom', room:getDoor('HMBadBedroom'), true)
		bp:Remove()
		for _, ag in pairs(antigravs) do ag:Remove() end
		local tp = room.model.WardrobeBase.Position + Vector3.new(0, 2.5, 0)
		do
			local p = room.model.Base.Position + Vector3.new(0, room.model.Base.Size.Y/2 + 4.5, 0)
			local angle = math.rad(30)
			local from = p + Vector3.new(0, math.sin(angle), -math.cos(angle))*25
			cam.CoordinateFrame = CFrame.new(from, p)
		end
		wait(1)
		Utilities.FadeIn(1)
		Utilities.Teleport(CFrame.new(tp.x, tp.y, tp.z, 0, 1, 0, 0, 0, 1, 1, 0, 0))
		hroot.RotVelocity = Vector3.new()
		hroot.Velocity = Vector3.new(50, 0, 0)
		do
			local startCF = cam.CoordinateFrame
			local angle = math.rad(40)
			local offset = Vector3.new(0, math.sin(angle), -math.cos(angle))*18
			local lcf = Utilities.lerpCFrame
			Utilities.Tween(.75, 'easeOutCubic', function(a)
				local p = hroot.CFrame * Vector3.new(0, 1.5, 0)
				p = Vector3.new(math.max(room.indoorCamMinX, math.min(room.indoorCamMaxX, p.x)), p.y, p.z)
				local from = p + offset
				cam.CoordinateFrame = select(2, lcf(startCF, CFrame.new(from, p)))(a)
			end)
		end
		chunk:bindIndoorCam()
		_p.MasterControl.WalkEnabled = true
		psc:disconnect()
		humanoid.PlatformStand = false
	end,
	
	-- Rotom Event Click-Helpers
	HauntedJukebox = function(model)
		if not _p.MasterControl.WalkEnabled then return end
		_p.MasterControl.WalkEnabled = false
		_p.MasterControl:Stop()
		pcall(function() model['#InanimateInteract']:Remove() end)
		spawn(function() _p.MasterControl:LookAt(model.Main.Position) end)
		_p.Events.onHauntedJukeboxClicked(model)
		_p.MasterControl.WalkEnabled = true
	end,
	HauntedComputer = function(model)
		if not _p.MasterControl.WalkEnabled then return end
		_p.MasterControl.WalkEnabled = false
		_p.MasterControl:Stop()
		pcall(function() model['#InanimateInteract']:Remove() end)
		spawn(function() _p.MasterControl:LookAt(model.Main.Position) end)
		_p.Events.onHauntedComputerClicked(model)
		_p.MasterControl.WalkEnabled = true
	end,
	HauntedToaster = function(model)
		if not _p.MasterControl.WalkEnabled then return end
		_p.MasterControl.WalkEnabled = false
		_p.MasterControl:Stop()
		pcall(function() model['#InanimateInteract']:Remove() end)
		spawn(function() _p.MasterControl:LookAt(model.Main.Position) end)
		_p.Events.onHauntedToasterClicked(model)
		_p.MasterControl.WalkEnabled = true
	end,
	HauntedTelevision = function(model)
		if not _p.MasterControl.WalkEnabled then return end
		_p.MasterControl.WalkEnabled = false
		_p.MasterControl:Stop()
		pcall(function() model['#InanimateInteract']:Remove() end)
		spawn(function() _p.MasterControl:LookAt(model.Main.Position) end)
		_p.Events.onHauntedTelevisionClicked(model)
		_p.MasterControl.WalkEnabled = true
	end,
	HauntedHairDryer = function(model)
		if not _p.MasterControl.WalkEnabled then return end
		_p.MasterControl.WalkEnabled = false
		_p.MasterControl:Stop()
		pcall(function() model['#InanimateInteract']:Remove() end)
		spawn(function() _p.MasterControl:LookAt(model.Main.Position) end)
		_p.Events.onHauntedHairDryerClicked(model)
		_p.MasterControl.WalkEnabled = true
	end,
	HauntedBabyMonitor = function(model)
		if not _p.MasterControl.WalkEnabled then return end
		_p.MasterControl.WalkEnabled = false
		_p.MasterControl:Stop()
		pcall(function() model['#InanimateInteract']:Remove() end)
		spawn(function() _p.MasterControl:LookAt(model.Main.Position) end)
		_p.Events.onHauntedBabyMonitorClicked(model)
		_p.MasterControl.WalkEnabled = true
	end,
	HauntedGameBoy = function(model)
		if not _p.MasterControl.WalkEnabled then return end
		_p.MasterControl.WalkEnabled = false
		_p.MasterControl:Stop()
		pcall(function() model['#InanimateInteract']:Remove() end)
		spawn(function() _p.MasterControl:LookAt(model.Main.Position) end)
		_p.Events.onHauntedGameBoyClicked(model)
		_p.MasterControl.WalkEnabled = true
	end,
	
	JirachiMonument = function(model)
		if not _p.MasterControl.WalkEnabled then return end
		local chat = _p.NPCChat
		_p.MasterControl.WalkEnabled = false
		_p.MasterControl:Stop()
		chat:say('"Under sky alight with stars shall the wish made upon the pedestal of dreams come true."')
		_p.MasterControl.WalkEnabled = true
	end,
	
	Pansage = function(model)
		if not _p.MasterControl.WalkEnabled then return end
		local chunk = _p.DataManager.currentChunk
		if not chunk or chunk.id ~= 'chunk14' then return end
		local enc
		pcall(function() enc = chunk.regionData.Sage end)
		if not enc then return end
		
		pcall(function() model['#InanimateInteract']:Remove() end)
		_p.MasterControl.WalkEnabled = false
		_p.MasterControl:Stop()
		_p.NPCChat:say(model.Main, 'Sa sa sage!')
		delay(3, function() model:Remove() end)
		_p.Battle:doWildBattle(enc)
		_p.MasterControl.WalkEnabled = true
	end,
	
	Pansear = function(model)
		if not _p.MasterControl.WalkEnabled then return end
		local chunk = _p.DataManager.currentChunk
		if not chunk or chunk.id ~= 'chunk14' then return end
		local enc
		pcall(function() enc = chunk.regionData.Sear end)
		if not enc then return end
		
		pcall(function() model['#InanimateInteract']:Remove() end)
		_p.MasterControl.WalkEnabled = false
		_p.MasterControl:Stop()
		_p.NPCChat:say(model.Main, 'Sear sear!')
		delay(3, function() model:Remove() end)
		_p.Battle:doWildBattle(enc)
		_p.MasterControl.WalkEnabled = true
	end,
	
	Panpour = function(model)
		if not _p.MasterControl.WalkEnabled then return end
		local chunk = _p.DataManager.currentChunk
		if not chunk or chunk.id ~= 'chunk14' then return end
		local enc
		pcall(function() enc = chunk.regionData.Pour end)
		if not enc then return end
		
		pcall(function() model['#InanimateInteract']:Remove() end)
		_p.MasterControl.WalkEnabled = false
		_p.MasterControl:Stop()
		_p.NPCChat:say(model.Main, 'Po pour!')
		delay(3, function() model:Remove() end)
		_p.Battle:doWildBattle(enc)
		_p.MasterControl.WalkEnabled = true
	end,
	
--[[	ManaphyEgg = function(model)
		if not _p.MasterControl.WalkEnabled then return end
		local chunk = _p.DataManager.currentChunk
		if not chunk or chunk.id ~= 'chunk11' then return end
		
--		pcall(function() model['#InanimateInteract']:Remove() end)
		_p.MasterControl.WalkEnabled = false
		_p.MasterControl:Stop()
		if #_p.PlayerData.party >= 6 then
			_p.NPCChat:say('It\'s a mysterious pokemon Egg.',
				'There\'s no room in your party for it.')
		elseif _p.Network:get('GrabManaphyEgg') then--_p.storage.Remote.PickUpManaphyEgg:InvokeServer() then
			table.insert(_p.PlayerData.party, _p.Pokemon:new {
				name = Utilities.rc4(manaphy),
				egg = true,
				shinyChance = 4096,
			})
			Utilities.sound(304774035, nil, nil, 8)
			_p.NPCChat:say(_p.PlayerData.trainerName .. ' found an Egg!',
				_p.PlayerData.trainerName .. ' put the Egg in the party.')
		end
		_p.MasterControl.WalkEnabled = true
	end,]]
	
	Drifloon = function(model)
		if not _p.MasterControl.WalkEnabled then return end
		local chunk = _p.DataManager.currentChunk
		if not chunk or chunk.id ~= 'chunk15' then return end
		local enc
		pcall(function() enc = chunk.regionData.Windmill end)
		if not enc then return end
		
		pcall(function() model['#InanimateInteract']:Remove() end)
		_p.MasterControl.WalkEnabled = false
		_p.MasterControl:Stop()
		_p.NPCChat:say(model.Main, 'Floooooon!')
		delay(3, function() model:Remove() end)
		_p.Battle:doWildBattle(enc, {battleSceneType = 'DrifWindmill'})
		_p.MasterControl.WalkEnabled = true
	end,
	
	HoneyTree = function(model)
		if not _p.MasterControl.WalkEnabled then return end
		local chunk = _p.DataManager.currentChunk
		if not chunk or chunk.id ~= 'chunk15' then return end
		_p.MasterControl.WalkEnabled = false
		_p.MasterControl:Stop()
		
		local chat = _p.NPCChat
		local honeyData = _p.PlayerData.honey
		if honeyData then
			if honeyData.status > 1 then
				delay(3, function()
					honeyData.status = 0
					model.SlatheredHoney.Transparency = 1.0
					pcall(function() model.HoneyTeddiursa:Remove() end)
				end)
				_p.Battle:doWildBattle(_p.DataManager.currentChunk.regionData.HoneyTree)
			elseif honeyData.status == 1 then
				chat:say('There is honey slathered on this tree.')
			else
				chat:say('This tree looks like a good place to slather honey to attract wild pokemon.')
				if honeyData.has then
					if chat:say('[y/n]Would you like to slather some honey?') then
						honeyData.status = 1
						_p.Network:post('PDS', 'slatherHoney')
						chat:say('You slathered honey on the tree.')
						pcall(function() model.SlatheredHoney.Transparency = .2 end)
					end
				end
			end
		end
		_p.MasterControl.WalkEnabled = true
	end,
	
	gym4tool = function(model)
		local chat = _p.NPCChat
		if model.Name == 'MeasuringTape' then
			chat:say('It\'s a measuring tape.')
			model:Remove()
			chat:say('This might come in handy.')
			_p.PlayerData:completeEvent('G4FoundTape')
		elseif model.Name == 'Wrench' then
			chat:say('It\'s a wrench with worm gear adjustment.')
			model:Remove()
			chat:say('This might come in handy.')
			_p.PlayerData:completeEvent('G4FoundWrench')
		elseif model.Name == 'Hammer' then
			chat:say('It\'s an ordinary hammer.')
			model:Remove()
			chat:say('This might come in handy.')
			_p.PlayerData:completeEvent('G4FoundHammer')
		end
	end,
	
	EmptyDumpster = function(model)
		if not _p.MasterControl.WalkEnabled then return end
		local chat = _p.NPCChat
		_p.MasterControl.WalkEnabled = false
		_p.MasterControl:Stop()
		chat:say('It\'s a stinky dumpster.')
		_p.MasterControl.WalkEnabled = true
	end,
	
	FullDumpster = function(model)
		if not _p.MasterControl.WalkEnabled then return end
		local chat = _p.NPCChat
		_p.MasterControl.WalkEnabled = false
		_p.MasterControl:Stop()
		spawn(function() _p.MasterControl:LookAt(model.Main.Position) end)
		pcall(function() model['#InanimateInteract'].Value = 'EmptyDumpster' end)
		spawn(function() _p.Battle._SpriteClass:playCry(nil, {id = 301816307, startTime = 57.68, duration = 1.24}) end)--cr10
		wait(.8)
		spawn(function()
			local lid = model.Lid
			local parts = {}
			local main = lid.Hinge
			local mcf = main.CFrame
			local function index(obj)
				for _, ch in pairs(obj:GetChildren()) do
					if ch:IsA('BasePart') and ch ~= main then
						parts[ch] = mcf:toObjectSpace(ch.CFrame)
					end
				end
			end
			index(lid)
			Utilities.Tween(.7, 'easeOutCubic', function(a)
				local cf = mcf * CFrame.Angles(0, 0, -math.pi*3/2*a)
				for p, rcf in pairs(parts) do
					p.CFrame = cf:toWorldSpace(rcf)
				end
				main.CFrame = cf
			end)
			delay(3, function()
				for p, rcf in pairs(parts) do
					p.CFrame = mcf:toWorldSpace(rcf)
				end
				main.CFrame = mcf
			end)
		end)
		wait(.7)
		_p.Battle:doWildBattle(_p.DataManager.currentChunk.regionData.Dumpster, {battleSceneType = 'Trash'})
		_p.MasterControl.WalkEnabled = true
	end,
	
--[[	SantaClaus = function(model) -- to make it easy to unify the 3 santas in different chunks
		local santa = _p.DataManager.currentChunk.npcs.Santa
		if not santa or not _p.MasterControl.WalkEnabled then return end
		_p.MasterControl.WalkEnabled = false
		_p.MasterControl:Stop()
		
		local chunkId = model.Parent.Name
		_p.DataManager:preload(576438342, 576461904)
		
		spawn(function() santa:LookAt(_p.player.Character.Head.Position) end)
		spawn(function() _p.MasterControl:LookAt(model.Head.Position) end)
		
		if not _p.PlayerData.completedEvents.BeatSanta then
			if chunkId == 'chunk5' then _p.NPCChat.bottom = true end
			santa:Say('Ho ho ho, look who it is, little '.._p.PlayerData.trainerName..'.',
				'You\'ve been very good this year.', 'Oh what\'s that?',
				'You\'re not here to settle your own account?',
				'You wanna know about the lawyer from Anthian City, eh?',
				'He\'s been very naughty lately.',
				'I went to court a few years ago for a reindeer speeding violation and it was his fault I lost and I had to pay the ticket.',
				'I haven\'t forgiven him since.',
				'I\'ll make a deal with you though, for working so hard to find me.',
				'If you beat me in a battle, I will put him back on the nice list.',
				'I can\'t resist a good battle.')
			_p.NPCChat.bottom = nil
			local win = _p.Battle:doTrainerBattle {
				musicId = 576461904,
				PreventMoveAfter = true,
				vs = {name = 'Santa', id = 576438342, hue = 0, sat = .5, val = .7},
				trainerModel = model,
				num = 120
			}
			
			if win then
				if chunkId == 'chunk5' then _p.NPCChat.bottom = true end
				santa:Say('Well, I made a deal and I\'m a man of my word.',
					'You let that lawyer know that he\'ll be put back on the nice list this year.',
					'You can also let him know that he\'s terrible at his job and charges way too much money.',
					'Anyways, I better be off for now.', 'I\'m very busy this time of year.',
					'Maybe I\'ll see you again next year.')
				_p.NPCChat.bottom = nil
				Utilities.FadeOut(.5)
				santa:Remove()
				wait(.5)
				Utilities.FadeIn(.5)
			end
		end
		-- these all 3 need to be enabled, I think, because we use tag "PreventMoveAfter"
		_p.NPCChat:enable()
		_p.MasterControl.WalkEnabled = true
		spawn(function() _p.Menu:enable() end)
		end,]]
		
--[[		
		Xov_Dev = function(model) -- 
		local bob = _p.DataManager.currentChunk.npcs.Bob
		if not bob or not _p.MasterControl.WalkEnabled then return end
		_p.MasterControl.WalkEnabled = false
		_p.MasterControl:Stop()
		
		local chunkId = model.Parent.Name
		_p.DataManager:preload(5589806258, 315131669)
		
		spawn(function() bob:LookAt(_p.player.Character.Head.Position) end)
		spawn(function() _p.MasterControl:LookAt(model.Head.Position) end)
		
		if not _p.PlayerData.completedEvents.BeatBob2 then
			if chunkId == 'chunk21' then _p.NPCChat.bottom = true end
			bob:Say('Well look who it is, it\'s '.._p.PlayerData.trainerName..'.',
					'I\'ve heard you\'ve done many great things on your adventure up to this point.', 
					'You look like a very capable trainer if I say so myself.',
					'Oh what\'s that?',
				'You spoke to the guy over at the housing district?',
				'You wanna know about him?',
				'He\'s been very mean lately.',
				'He has taken a few of my favorite Mons from me and I haven\'t seen it since.',
				
				'I\'ll make a deal since you worked so hard to try to find me.',
				'If you beat me in a battle, I will forgive him.',
				'I just can\'t resist a good battle!')
			_p.NPCChat.bottom = nil
		local win = _p.Battle:doTrainerBattle {
				battleScene = 'BattleDistrict',
				musicId = 315131669,
				PreventMoveAfter = true,
				vs = {name = 'Xov_Dev', id = 5589806258, hue = 0, sat = .5, val = .7},
				trainerModel = model,
				num = 188
			}
			
			if win then
				if chunkId == 'chunk21' then _p.NPCChat.bottom = true end
				bob:Say('Well, I made a deal and you won.',
					'You let that guy know I forgive him.',
					'You also let him know that he\'s can\'t do this again.',
					'Anyways, that was a nice battle but I got to get going.', 'I\'m actually behind my schedule.',
					'Maybe I\'ll see you again soon!')
				_p.NPCChat.bottom = nil
				Utilities.FadeOut(.5)
				bob:Remove()
				wait(.5)
				Utilities.FadeIn(.5)
			end
		end
		
		_p.NPCChat:enable()
		_p.MasterControl.WalkEnabled = true
		spawn(function() _p.Menu:enable() end)
	end,
--]]		
		

	
	ShayminEncounter = function(model)
		if not _p.MasterControl.WalkEnabled then return end
		local chunk = _p.DataManager.currentChunk
		if not chunk or chunk.id ~= 'chunk17' then return end
		local enc
		pcall(function() enc = chunk.regionData.Grace end)
		if not enc then return end
		
		pcall(function() model['#InanimateInteract']:Remove() end)
		_p.MasterControl.WalkEnabled = false
		_p.MasterControl:Stop()
		spawn(function() _p.Battle._SpriteClass:playCry(nil, {id = 301816205, startTime = 25.60, duration = 1.82}) end)--cr9
		_p.NPCChat:say(model.Main, 'Shayyyyy!')
		delay(3, function() model:Remove() end)
		_p.Battle:doWildBattle(enc, {musicId = 380888758})--jb
		_p.NPCChat:say('Shaymin can now be found roaming in the wild.')
		_p.MasterControl.WalkEnabled = true
	end,
	
	mashableMineral = function(model)
		if not _p.MasterControl.WalkEnabled then return end
--		_p.DataManager:preload(TODO)
		local chat = _p.NPCChat
		_p.MasterControl.WalkEnabled = false
		_p.MasterControl:Stop()
		local main = model.Main
		spawn(function() _p.MasterControl:LookAt(main.Position) end)
		local smasher, rm, enc, done
		Utilities.fastSpawn(function()
			smasher, rm, enc = _p.Network:get('PDS', 'getSmasher')
			done = true
		end)
		chat:say('It\'s a cracked boulder.', 'A pokemon may be able to break it.')
		while not done do wait() end
		if not smasher or not rm or not chat:say('[y/n]Would you like ' .. smasher .. ' to use Rock Smash?') then
			_p.MasterControl.WalkEnabled = true
			return
		end
		local isKey = model.Name == 'KeyRockSmash'
		chat:say(smasher .. ' used Rock Smash!')
--		pcall(function() model['#InanimateInteract']:Remove() end)
		
		local cf = main.CFrame
		local scale = main.Size.Magnitude / 14.847123146057
--		Utilities.sound(TODO, nil, nil, 5)
		Utilities.ScaleModel(rm.Main, scale)
		Utilities.MoveModel(rm.Main, cf)
		rm.Main:Remove()--rm.Main.Transparency = 1; rm.Main.Size = Vector3.new(1,1,1); rm.Main.CanCollide = true--
		model:Remove()
		rm.Parent = workspace
		for _, p in pairs(rm:GetChildren()) do
			if p:IsA('BasePart') then
				p.Anchored = false
				local dir = (p.Position-cf.p+Vector3.new(0,1,0)).unit
				p.Velocity = dir * 20
				local force = create 'BodyForce' {
					Force = dir * 50 * p:GetMass(),
					Parent = p
				}
				delay(.25, function() force:Remove() end)
			end
		end
		wait(1)
		Utilities.Tween(.5, nil, function(a)
			for _, p in pairs(rm:GetChildren()) do
				if p:IsA('BasePart') then
					p.Transparency = a
				end
			end
		end)
		rm:Remove()
		if enc and not isKey then
			_p.Battle:doWildBattle(enc)
		else
			_p.MasterControl.WalkEnabled = true
		end
	end,
	
	jewelStand = function(model)
		if not _p.MasterControl.WalkEnabled then return end
		_p.MasterControl.WalkEnabled = false
		_p.MasterControl:Stop()
		local chat = _p.NPCChat
		local events = _p.PlayerData.completedEvents
		if not events.RJO then
			chat:say('It\'s a column with strange indentations.', 'It is unclear what purpose it serves.')
		else
			if events.RJO and not events.RJP then
				spawn(function() _p.PlayerData:completeEvent('RJP') end)
				chat:say('You placed the King\'s Red Jewel in the slot on the column.')
				model.RedJewel.Transparency = 0
				-- TODO: rumble sound/camera?
				chat:say('A rumble can be heard from deep within the ruins.')
			elseif events.GJO and not events.GJP then
				spawn(function() _p.PlayerData:completeEvent('GJP') end)
				chat:say('You placed the King\'s Green Jewel in the slot on the column.')
				model.GreenJewel.Transparency = 0
				-- TODO: rumble sound/camera?
				chat:say('A rumble can be heard from deep within the ruins.')
			elseif events.PJO and not events.PJP then
				spawn(function() _p.PlayerData:completeEvent('PJP') end)
				chat:say('You placed the King\'s Purple Jewel in the slot on the column.')
				model.PurpleJewel.Transparency = 0
				-- TODO: rumble sound/camera?
				chat:say('A rumble can be heard from deep within the ruins.')
			elseif events.BJO and not events.BJP then
				spawn(function() _p.PlayerData:completeEvent('BJP') end)
				chat:say('You placed the King\'s Blue Jewel in the slot on the column.')
				model.BlueJewel.Transparency = 0
				-- TODO: rumble sound/camera?
				chat:say('A rumble can be heard from somewhere else in the ruins.')
			end
		end
		_p.MasterControl.WalkEnabled = true
	end,
	
	restartPuzzleJ = function()
		-- implemented in PuzzleJ module
	end,
	
	ancientSarcophagus = function(model)
		if not _p.MasterControl.WalkEnabled then return end
		_p.MasterControl.WalkEnabled = false
		_p.MasterControl:Stop()
		
		pcall(function() model['#InanimateInteract']:Remove() end)
--		spawn(function() _p.PlayerData:completeEvent('BJO') end)
		local main = model.Main
		local lidcf = model.LidEndLocation.CFrame
		model.LidEndLocation:Remove()
		local mcf = main.CFrame
		Utilities.Teleport(CFrame.new(mcf * Vector3.new(3.5, 1, 0), mcf.p))
		local cam = workspace.CurrentCamera
		cam.CameraType = Enum.CameraType.Scriptable
		cam.CFrame = CFrame.new(mcf * Vector3.new(4, 10, 6), mcf.p)
		Utilities.Tween(2, nil, function(a)
			Utilities.MoveModel(main, mcf * CFrame.new(-1.8*a, 0, 0))
		end)
		local lerp = select(2, Utilities.lerpCFrame(main.CFrame, lidcf))
		Utilities.Tween(.4, 'easeInCubic', function(a)
			Utilities.MoveModel(main, lerp(a))
		end)
		wait(1)
		_p.NPCChat:say(_p.PlayerData.trainerName .. ' found one of the King\'s Jewels!',
			'It glimmers a soothing blue color.')
		local chunk = _p.DataManager.currentChunk
		local map = chunk.map
		map.BlueJewel:Remove()
		wait(.5)
		Utilities.lookBackAtMe()
		
		local players = game:GetService('Players')
		local cn; cn = map.MummyBattleTrigger.Touched:connect(function(p)
			if not p or not p.Parent or players:GetPlayerFromCharacter(p.Parent) ~= _p.player then return end
			cn:disconnect()
			_p.Events.onActivateMummy(map.Mummy)
		end)
		
		_p.MasterControl.WalkEnabled = true
	end,
	
	vicSeal = function(model)
		if not _p.MasterControl.WalkEnabled then return end
		_p.MasterControl.WalkEnabled = false
		_p.MasterControl:Stop()
		
		local main = model.Main
		local mcf = main.CFrame
		pcall(function() model['#InanimateInteract']:Remove() end)
		Utilities.Teleport(mcf * CFrame.new(0, 2.5, 8))
		local cam = workspace.CurrentCamera
		cam.CameraType = Enum.CameraType.Scriptable
		cam.CFrame = CFrame.new(mcf.p + Vector3.new(9, 7, -7), mcf.p + Vector3.new(0, 4, 0))
		
		_p.MusicManager:stackMusic(608811548, 'BattleMusic', .4)--v
		
		wait(.5)
		local decal = model.Inscription.Decal
		Utilities.Tween(1, 'easeInCubic', function(a)
			decal.Transparency = a
		end)
		wait(.5)
		
		local vic = _p.DataManager.currentChunk.map.Victini
		vic.Eyes.Glow1.Transparency = 1
		vic.Eyes.Glow2.Transparency = 1
		_p.DataManager:loadModule('AnchoredRig')
		local vcf = vic.Main.CFrame
		local rig = _p.DataManager:loadModule('AnchoredRig'):new(vic)
		rig:connect(vic, vic.Eyes)
		rig:connect(vic, vic.Mouth)
		rig:connect(vic, vic.RightArm)
		rig:connect(vic, vic.LeftArm)
		
		rig:reset()
		rig:pose('Victini', vcf)
		rig:pose('Victini', vcf + Vector3.new(0, 7, 0), 3.5, 'easeOutCubic')
		
--		wait(.5)
		local orb = create 'Part' {
			Anchored = true,
			CanCollide = false,
			Shape = Enum.PartType.Ball,
			BrickColor = BrickColor.new('Neon orange'),
			TopSurface = Enum.SurfaceType.Smooth,
			BottomSurface = Enum.SurfaceType.Smooth,
			Parent = workspace
		}
		local ocf = vcf + Vector3.new(0, 7, 0)
		Utilities.Tween(.25, nil, function(a)
			orb.Size = Vector3.new(6, 6, 6)*a
			orb.CFrame = ocf
		end)
		vic.Eyes.Main.BrickColor = BrickColor.new('Deep blue')
		vic.Eyes.LBlue.BrickColor = BrickColor.new('Pastel Blue')
		vic.Eyes.LBlue.Material = Enum.Material.Ice
		vic.Eyes.Glow1.Transparency = .75
		vic.Eyes.Glow2.Transparency = .75
		vic.Mouth.Closed1:Remove()
		vic.Mouth.Closed2:Remove()
		spawn(function() _p.Battle._SpriteClass:playCry(nil, {id = 301816205, startTime = 31.13, duration = .81}) end)--cr9
		Utilities.Tween(.25, nil, function(a)
			orb.Size = Vector3.new(6, 6, 6)*(1+a)
			orb.CFrame = ocf
			orb.Transparency = a
		end)
		orb:Remove()
		
		rig:poses(
			{'Victini', vcf + Vector3.new(0, 5.5, 0), 2, 'easeOutCubic'},
			{'LeftArm',  CFrame.Angles(0, 0, -.8),  2, 'easeOutCubic'},
			{'RightArm', CFrame.Angles(0, 0,  .8),  2, 'easeOutCubic'})
		wait(.5)
		delay(3, function()
			vic:Remove()
			decal.Transparency = 0
		end)
		_p.Battle:doWildBattle(_p.DataManager.currentChunk.regionData.Victory, {battleSceneType = 'VicBattle', musicId = 'none'})
		_p.NPCChat:say('Victini can now be found roaming in the wild.')
		_p.MasterControl.WalkEnabled = true
	end,
	
	Snorlax = function(model)
		if not _p.MasterControl.WalkEnabled then return end
		_p.MasterControl.WalkEnabled = false
		_p.MasterControl:Stop()
		local chat = _p.NPCChat
		spawn(function() _p.MasterControl:LookAt(model.Main.Position) end)
		local has, done
		Utilities.fastSpawn(function()
			has = _p.Network:get('PDS', 'hasFlute')
			done = true
		end)
		chat:say('It\'s an enormous, sleeping pokemon.')
		while not done do wait() end
		if has then _p.DataManager:preload(610093998) end--pf
		if has and chat:say('[y/n]Would you like to use the Poke Flute?') then
			Utilities.sound(610093998, nil, nil, 10)--pf
			delay(6, function() chat:manualAdvance() end)
			delay(2, function() model.Mouth.PE.Enabled = false end)
			chat:say('[ma]'.._p.PlayerData.trainerName .. ' played the Poke Flute.')
			wait(.5)
			spawn(function() _p.Battle._SpriteClass:playCry(.5, {id = 301815895, startTime = 43.94, duration = .42}) end)--cr3
			wait(1)
			delay(3, function() model:Remove() end)
			_p.Battle:doWildBattle(_p.DataManager.currentChunk.regionData.Snore)
		end
		_p.MasterControl.WalkEnabled = true
	end,
	
	Landorus = function(model)
		if not _p.MasterControl.WalkEnabled then return end
		_p.MasterControl.WalkEnabled = false
		_p.MasterControl:Stop()
		local chat = _p.NPCChat
		spawn(function() _p.MasterControl:LookAt(model.Main.Position) end)
		spawn(function() chat:say(model.Mouth, '[ma]Grrrraaghrraaah!') end)
		spawn(function() _p.Battle._SpriteClass:playCry(nil, {id = 301816397, startTime = 104.50, duration = 1.68}) end)--cr11
		wait(1.7)
		chat:manualAdvance()
		wait(.5)
		delay(3, function() model:Remove() end)
		_p.Battle:doWildBattle(_p.DataManager.currentChunk.regionData.Landforce, {musicId = 380888758})--jb
		_p.NPCChat:say('Landorus can now be found roaming in the wild.')
		_p.MasterControl.WalkEnabled = true
	end,
	
	sign = function(model)
		if not _p.MasterControl.WalkEnabled then return end
		_p.MasterControl.WalkEnabled = false
		_p.MasterControl:Stop()
		local chat = _p.NPCChat
		spawn(function() _p.MasterControl:LookAt(model.Main.Position) end)
		chat:say(unpack(Utilities.jsonDecode(model.SignText.Value)))
		_p.MasterControl.WalkEnabled = true
	end,
	
	motorized = function(model)
		if not _p.MasterControl.WalkEnabled then return end
		_p.MasterControl.WalkEnabled = false
		_p.MasterControl:Stop()
		local chat = _p.NPCChat
		
		local forme = model.Name
		local appliance = ({
			fan = 'Electric Fan',
			frost = 'Refrigerator',
			heat = 'Microwave Oven',
			mow = 'Lawn Mower',
			wash = 'Washing Machine'
		})[forme]
		chat:say('It\'s '..Utilities.aOrAn(appliance)..'.')
		local nRotom = _p.PlayerData.nRotom
		if nRotom and nRotom > 0 then
			chat:say('Oh? Rotom would like to investigate the circuits of the '..appliance..'.')
			if chat:say('[y/n]Is that OK?') then
				local slot
				if nRotom > 1 then
					chat:say('Which Rotom will you allow to investigate the circuits of the '..appliance..'?')
					slot = _p.BattleGui:choosePokemon('Choose')
					if not slot then
						_p.MasterControl.WalkEnabled = true
						return
					end
				end
				local r = _p.Network:get('PDS', 'motorize', forme, slot)
				if r then
					chat:say(r.n..' entered the motor.')
					if r.r then
						chat:say(r.n..' reverted to its original state.')
					end
					if r.f then
						chat:say(r.n..' forgot '..r.f..'...')
					end
					if r.l then
						chat:say(r.n..' learned '..r.l..'!')
					elseif r.t then
						_p.Pokemon:processMovesAndEvolution({
							pokeName = r.n,
							moves = r.t,
							known = r.k
						}, false)
					end
				end
			end
		end
		
		_p.MasterControl.WalkEnabled = true
	end,
	
	rockClimb = function(model)
		if not _p.MasterControl.WalkEnabled then return end
--		_p.DataManager:preload(316598829)
		local chat = _p.NPCChat
		_p.MasterControl.WalkEnabled = false
		_p.MasterControl:Stop()
		local main = model.Main
		local normals = {
			[Enum.NormalId.Right ] = Vector3.new( 1, 0, 0),
			[Enum.NormalId.Left  ] = Vector3.new(-1, 0, 0),
			[Enum.NormalId.Top   ] = Vector3.new(0,  1, 0),
			[Enum.NormalId.Bottom] = Vector3.new(0, -1, 0),
			[Enum.NormalId.Back  ] = Vector3.new(0, 0,  1),
			[Enum.NormalId.Front ] = Vector3.new(0, 0, -1),
		}
		local function getDirection(part, surfaceType)
			for id, vec in pairs(normals) do
				if part[id.Name..'Surface'] == surfaceType then
					return vec--(part.CFrame*vec)-part.Position
				end
			end
		end
		local out = getDirection(main, Enum.SurfaceType.Weld)
		spawn(function() _p.MasterControl:LookAt(main.CFrame*(out*((main.Size*out).magnitude/2))) end)
		local climber, done
		Utilities.fastSpawn(function()
			climber = _p.Network:get('PDS', 'getClimber')
			done = true
		end)
		chat:say('These rocks look like they can be scaled by a Pokemon.')
		while not done do wait() end
		if not climber or not chat:say('[y/n]Would you like ' .. climber .. ' to use Rock Climb?') then
			_p.MasterControl.WalkEnabled = true
			return
		end
		chat:say(climber .. ' used Rock Climb!')
		local up = getDirection(main, Enum.SurfaceType.Studs)
		local yDist = (main.Size*up).magnitude
--		print(yDist)
		local top = main.CFrame*(up*(yDist/2))
		local hDist = 3+(main.Size*out).magnitude/2
		local bottom = main.CFrame*(out*hDist-up*(yDist/2))
		out = (main.CFrame*out)-main.CFrame.p -- convert `out` to world space
		local hipHeight = 3
		local root = _p.player.Character.HumanoidRootPart
		pcall(function()
			local human = Utilities.getHumanoid()
			if human.RigType == Enum.HumanoidRigType.R15 then
				hipHeight = root.Size.Y/2 + human.HipHeight
			end
		end)
		local smokePart = create 'Part' {
			Anchored = true,
			CanCollide = false,
			Transparency = 1.0,
			Size = Vector3.new(.2, .2, .2)
		}
		local smoke = create 'Smoke' {
			Color = Color3.fromRGB(83, 67, 56),
			Opacity = .5,
			RiseVelocity = 0,
			Size = .6,
			Parent = smokePart
		}
		local smokeTransform = CFrame.new(0, 2-hipHeight, 0)
		local climbspeed = 22
		local extraheight = 2
		if top.Y > root.Position.Y then
			-- up
			local pos = bottom + Vector3.new(0, hipHeight, 0)
			local endcf = CFrame.new(pos, pos - out)
			local lerper = select(2, Utilities.lerpCFrame(root.CFrame, endcf))
			smokePart.Parent = workspace
			Utilities.Tween(yDist/climbspeed, nil, function(a)
				root.CFrame = lerper(a) + Vector3.new(0, yDist*a, 0)
				smokePart.CFrame = root.CFrame * smokeTransform
			end, 150)
			smoke.Enabled = false
			Utilities.Tween(math.pi/climbspeed*extraheight, nil, function(a)
				root.CFrame = endcf + Vector3.new(0, yDist+extraheight*math.sin(math.pi*a), 0) - out*hDist*a
			end, 150)
		else
			-- down
			local pos = top + Vector3.new(0, hipHeight, 0)
			local endcf = CFrame.new(pos, pos + out)
			local lerper = select(2, Utilities.lerpCFrame(root.CFrame, endcf))
			Utilities.Tween(math.pi/climbspeed*extraheight, nil, function(a)
				root.CFrame = lerper(a) + Vector3.new(0, extraheight*math.sin(math.pi*a), 0) + out*hDist*a
			end, 150)
			smokePart.Parent = workspace
			Utilities.Tween(yDist/climbspeed, nil, function(a)
				root.CFrame = endcf + out*hDist + Vector3.new(0, -yDist*a, 0)
				smokePart.CFrame = root.CFrame * smokeTransform
			end, 150)
			smoke.Enabled = false
		end
		delay(10, function() smokePart:Remove() end)
		_p.MasterControl.WalkEnabled = true
	end,
	
	heatran = function(model)
		if not _p.MasterControl.WalkEnabled then return end
		_p.MasterControl.WalkEnabled = false
		_p.MasterControl:Stop()
		local roar = model.AnimationController:LoadAnimation(create 'Animation' { AnimationId = 'rbxassetid://'.._p.animationId.heatranRoar })
		local chat = _p.NPCChat
		spawn(function() _p.MasterControl:LookAt(model.Jaw.Position) end)
		spawn(function() chat:say(model.Jaw, '[ma]Grrawraayuuuh!') end)
		spawn(function() _p.Battle._SpriteClass:playCry(nil, {id = 301816205, startTime = 7.41, duration = 1.72}) end)--cr9
		roar:Play()
		wait(1.7)
		chat:manualAdvance()
		wait(.5)
		delay(3, function() model:Remove() end)
		_p.Battle:doWildBattle(_p.DataManager.currentChunk.regionData.Heat, {musicId = 380888758})--jb
		_p.NPCChat:say('Heatran can now be found roaming in the wild.')
		_p.MasterControl.WalkEnabled = true
	end,
	
	jDoor = function(model)
		if not _p.MasterControl.WalkEnabled then return end
		_p.MasterControl.WalkEnabled = false
		_p.MasterControl:Stop()
		local chat = _p.NPCChat
		spawn(function() _p.MasterControl:LookAt(model.Main.Position) end)
		chat:say('There are some strange markings written in the wall.')
		if _p.PlayerData.hasjkey then
			spawn(function() _p.PlayerData:completeEvent('OpenJDoor') end)
			local main = model.Main
			local mcf = main.CFrame
			Utilities.Tween(2, nil, function(a)
				Utilities.MoveModel(main, mcf + Vector3.new(0, 16*a, 0))
			end)
			model:Remove()
			pcall(function()
				local chunk = _p.DataManager.currentChunk
				local door = chunk.map.CD41
				door.Name = 'CaveDoor:chunk41'
				chunk:hookupCaveDoor(door)
			end)
		end
		_p.MasterControl.WalkEnabled = true
	end,
	
	diancie = function(model)
		if not _p.MasterControl.WalkEnabled then return end
		_p.MasterControl.WalkEnabled = false
		_p.MasterControl:Stop()
		local chat = _p.NPCChat
		spawn(function() _p.MasterControl:LookAt(model.Main.Position) end)
		spawn(function() _p.Battle._SpriteClass:playCry(nil, {id = 301816578, startTime = 27.79, duration = 1.93}) end)--cr13
		wait(1.8)
		delay(3, function() model:Remove() end)
		_p.Battle:doWildBattle(_p.DataManager.currentChunk.regionData.Jewel, {musicId = 380888758})--jb
		_p.NPCChat:say('Diancie can now be found roaming in the wild.')
		_p.MasterControl.WalkEnabled = true
	end,
	
	rDoor = function(model)
		if not _p.MasterControl.WalkEnabled then return end
		_p.MasterControl.WalkEnabled = false
		_p.MasterControl:Stop()
		_p.NPCChat:say('The Three Protectors shall awaken the Titan.')
		_p.MasterControl.WalkEnabled = true
	end,
	
	ReleaseMew = function(model)
		if not _p.MasterControl.WalkEnabled then return end
		local chunk = _p.DataManager.currentChunk
		local map = chunk.map
		_p.MasterControl.WalkEnabled = false
		_p.MasterControl:Stop()
		spawn(function() _p.MasterControl:LookAt(Vector3.new(model.Main.Position)) end)
		local chat = _p.NPCChat
		chat:say('This computer is running a machine that is trapping Mew.')
		if not chat:say('[y/n]Shut down the computer?') then
			_p.MasterControl.WalkEnabled = true
			return
		end
		model:Remove()
		spawn(function() _p.PlayerData:completeEvent('Mew') end)
		chat:say('...')
		chat:say('Shut down sequence activated.')
		map.Computer.BrickColor = BrickColor.new("Ghost grey")
		map.Computer.Material = "Plastic"
		spawn(function() _p.MasterControl:LookAt(Vector3.new(map.Mew.BasePart.Position)) end)
		local cam = workspace.CurrentCamera
		cam.CameraType = Enum.CameraType.Scriptable
		cam.CFrame = CFrame.new(map.Mew.BasePart.Position + Vector3.new(9, 7, -7), map.Mew.BasePart.Position + Vector3.new(0, 4, 0))
		wait(1)
		local tube = map.Tube
		for i = 1,7 do
			wait(0.1)
			tube.Transparency = tube.Transparency + 0.1
		end
		wait(.5)
		local ball = Instance.new("Part",game.Workspace)
		ball.BrickColor = BrickColor.new("Hot pink")
		ball.Shape = "Ball"
		ball.TopSurface = "Smooth"
		ball.BottomSurface = "Smooth"
		ball.Material = "Neon"
		ball.CanCollide = false
		ball.Anchored = true
		ball.Transparency = 1
		ball.Position = map.Mew:FindFirstChild('BasePart').Position
		spawn(function()
			for i = 1,5 do
				wait(0.02)
				ball.Size = ball.Size + Vector3.new(1,1,1)
			end
		end)
		spawn(function()
			for i = 1,10 do
				wait(0.01)
				ball.Transparency = ball.Transparency - 0.1
			end
		end)
		wait(1)
		map.Mew:Remove()
		wait(.5)
		spawn(function()
			for i = 1,5 do
				wait(0.02)
				ball.Size = ball.Size - Vector3.new(1,1,1)
			end
		end)
		spawn(function()
			for i = 1,10 do
				wait(0.01)
				ball.Transparency = ball.Transparency + 0.1
			end
		end)
		wait(1)
		_p.NPCChat:say('Mew used Teleport!')
		_p.NPCChat:say('Mew can now be found roaming in the wild.')
		Utilities.lookBackAtMe()
		_p.MasterControl.WalkEnabled = true
	end,

    Volcanion = function(model)
			if not _p.MasterControl.WalkEnabled then return end
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			local chat = _p.NPCChat
			spawn(function() _p.MasterControl:LookAt(model.Main.Position) end)
			spawn(function() _p.Battle._SpriteClass:playCry(nil, {id = 0, startTime = 0, duration = 0}) end)
			wait(1.8)
			delay(3, function() model:Remove() end)
			_p.Battle:doWildBattle(_p.DataManager.currentChunk.regionData.Volcan, {musicId = 608811548})
			_p.NPCChat:say('Volcanion can now be found roaming in the wild.')
			_p.MasterControl.WalkEnabled = true
		end,
		
		
} end