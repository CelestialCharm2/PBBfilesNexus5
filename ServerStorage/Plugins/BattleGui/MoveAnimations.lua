return function(_p)
	local Utilities = _p.Utilities
	local Tween = Utilities.Tween
	local create = Utilities.Create
	local storage = game:GetService('ReplicatedStorage')
	local stepped = game:GetService('RunService').RenderStepped


	local function targetPoint(pokemon, dist)
		local sprite = pokemon.sprite or pokemon
		return sprite.cf * Vector3.new(0, sprite.part.Size.Y/2, (dist or 1) * (sprite.siden==1 and 1 or -1))
	end

	local function absorb(pokemon, target, amount, color)
		local from = targetPoint(pokemon)
		local to = targetPoint(target)
		local dif = from-to
		local cf = target.sprite.part.CFrame
		cf = cf-cf.p
		for i = 1, (amount or 6) do
			local a = math.random()*6.3
			local offset = (cf*Vector3.new(math.cos(a),math.sin(a),0))*.75
			local so = math.random()*6.3
			_p.Particles:new {
				Image = 5964827385,
				Color = (color or Color3.fromHSV((90+40*math.random())/360, 1, .75)),
				Lifetime = .9,
				Size = .7,
				OnUpdate = function(a, gui)
					gui.CFrame = CFrame.new(to+dif*a+(1-a*.6)*(offset+Vector3.new(0,math.sin(so+a*3),0)))
				end
			}
			wait(.06)
		end
		wait(.7)
	end

	local function bite(target, particle, pSize, isCrunch)
		local b = storage.Models.Misc.Bite:Clone()
		if isCrunch then
			Utilities.ScaleModel(b.Main, 1.3)
		end
		local top, btm = b.Top, b.Bottom
		local inv = b.Main.CFrame:inverse()
		local tc, bc = inv * top.CFrame, inv * btm.CFrame
		b.Main:Remove()
		b.Parent = workspace
		local mcf = CFrame.new(targetPoint(target, 2.5), targetPoint(target, 0))
		if particle then
			delay(.25, function()
				local p = _p.Particles
				local size = .5*(pSize or 1)
				for _ = 1, 5 do
					wait(.04)
					for _ = 1, 2 do
						local r = math.random()
						local t = math.random()*math.pi*2
						local d = Vector3.new(r*math.cos(t), r*.5*math.sin(t), 0)
						local v = ((mcf-mcf.p)*d).unit
						p:new {
							Position = mcf * (d + Vector3.new(0, 0, -1)),
							Rotation = -math.deg(t)+90,
							Velocity = v*6,
							Acceleration = -v*7,
							Lifetime = .7,
							Image = particle,
							OnUpdate = function(a, gui)
								local s = size*math.sin(a*math.pi)
								gui.BillboardGui.Size = UDim2.new(s, 0, s, 0)
							end,
						}
					end
				end
			end)
		end
		--	if isCrunch then
		--		Tween(2, nil, function(a)
		--			local s = (1+math.sin(.5+a*5.28))/2
		--			local m = CFrame.new(0, 0, -.6*(1-s))
		--			top.CFrame = mcf * m * CFrame.Angles( .7*s, 0, 0) * tc
		--			btm.CFrame = mcf * m * CFrame.Angles(-.7*s, 0, 0) * bc
		--		end)
		--	else
		Tween(.6, 'easeInOutQuad', function(a)
			local s = (1+math.sin(.5+a*5.28))/2
			--		local t = a<.1 and (1-10*a) or (a>.9 and ((a-.9)*10) or 0)
			--		top.Transparency = t
			--		btm.Transparency = t
			local m = CFrame.new(0, 0, -.6*(1-s))
			top.CFrame = mcf * m * CFrame.Angles( .7*s, 0, 0) * tc
			btm.CFrame = mcf * m * CFrame.Angles(-.7*s, 0, 0) * bc
		end)
		--	end
		b:Remove()
	end

	local function spikes(pokemon, modelName, color)
		-- get platforms
		local platforms = {}
		local names
		local battle = pokemon.side.battle
		if pokemon.side.n == 1 then
			names = {'pos21', 'pos22', 'pos23'}
			if battle.gameType ~= 'doubles' then -- todo: triples?
				names[4] = '_Foe'
			end
		else
			names = {'pos11', 'pos12', 'pos13'}
			if battle.gameType ~= 'doubles' then -- todo: triples?
				names[4] = '_User'
			end
		end
		for _, name in pairs(names) do
			local p = battle.scene:FindFirstChild(name)
			if p then
				platforms[#platforms+1] = p
			end
		end
		--
		local spike = create 'Part' {
			Anchored = true,
			CanCollide = false,
			BrickColor = BrickColor.new(color or 'Smoky grey'),
			Reflectance = .1,
			Size = Vector3.new(1, 1, 1),

			create 'SpecialMesh' {
				MeshType = Enum.MeshType.FileMesh,
				MeshId = 'rbxassetid://629819743',
				Scale = Vector3.new(.01, .01, .01)
			}
		}
		local spikeContainer = create 'Model' {
			Name = (modelName or 'Spikes')..(3-pokemon.side.n),
			Parent = battle.scene
		}
		delay(10, function() spike:Remove() end)
		local throwFrom = targetPoint(pokemon, 1.5)
		for _, platform in pairs(platforms) do
			spawn(function()
				local available = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12}
				local function r()
					local n = math.random(#available)
					local v = table.remove(available, n) -- middle
					table.remove(available, #available < n and 1 or n) -- right
					table.remove(available, n==1 and #available or n-1) -- left
					return v
				end
				local offset = math.random()*math.pi*2
				for _, v in pairs({r(), r(), r()}) do
					local angle = offset+(v+math.random())*math.pi/6
					local r = 2+math.random()
					local cf = platform.CFrame * CFrame.Angles(0, math.random()*6.28, 0) + Vector3.new(math.cos(angle)*r, -platform.Size.Y/2+.25, math.sin(angle)*r)
					local throw = throwFrom - cf.p
					local rx, ry, rz = (math.random()-.5)*3, (math.random()-.5)*3, (math.random()-.5)*3
					local sp = spike:Clone()
					sp.Parent = spikeContainer
					spawn(function()
						Tween(.5, 'easeOutQuad', function(a)
							local o = 1-a
							sp.CFrame = cf * CFrame.Angles(o*rx, o*ry, o*rz) + throw*o + Vector3.new(0, 2*math.sin(a*math.pi), 0)
						end)
					end)
					wait(.2)
				end
			end)
		end
	end

	local function shield(pokemon, color)
		local sprite = pokemon.sprite
		local part = sprite.part
		local s = create 'Part' {
			Anchored = true,
			CanCollide = false,
			Transparency = .3,
			Reflectance = .4,
			BrickColor = BrickColor.new(color or 'Alder'),
			Parent = part.Parent,

			create 'CylinderMesh' {Scale = Vector3.new(1, 0.01, 1)}
		}
		local cf = sprite.cf * CFrame.new(0, 1.5-(sprite.spriteData.inAir or 0), 2.5 * (sprite.siden==1 and 1 or -1)) * CFrame.Angles(math.pi/2, .5, 0)
		Tween(.6, 'easeOutCubic', function(a)
			s.Size = Vector3.new(3*a, .2, 3*a)
			s.CFrame = cf
		end)
		delay(1, function()
			Tween(.5, 'easeOutCubic', function(a)
				s.Transparency = .3 + .7*a
				s.Reflectance = .4 * (1-a)
			end)
			s:Remove()
		end)
	end

	local function cut(target, color, qty, pcolor1, pcolor2)
		local parts = {}
		local size
		local scale = .1
		local mscale = scale * 2
		if qty == 3 then
			for i = 1, 3 do
				local p = storage.Models.Misc.SlashEffect:Clone()
				size = p.Size * 4
				parts[p] = target.sprite.part.CFrame * CFrame.new(0, 0, -1) * CFrame.new(Vector3.new(.6, .6, 0)*(i-2))
				p.BrickColor = BrickColor.new(color or 'White')
				p.Parent = workspace
			end
		elseif qty == 2 then
			local p = storage.Models.Misc.SlashEffect:Clone()
			size = p.Size * 4
			parts[p] = target.sprite.part.CFrame * CFrame.new(0, 0, -1)
			p.BrickColor = BrickColor.new(color or 'White')
			p.Parent = workspace
			local p2 = p:Clone()
			parts[p2] = target.sprite.part.CFrame * CFrame.new(0, 0, -1) * CFrame.Angles(0, 0, -math.pi/2)
			p2.Parent = workspace
		else
			local p = storage.Models.Misc.SlashEffect:Clone()
			size = p.Size * 4
			parts[p] = target.sprite.part.CFrame * CFrame.new(0, 0, -1)
			p.BrickColor = BrickColor.new(color or 'White')
			p.Parent = workspace
		end
		--	local lastParticle = {}
		Utilities.Tween(.4, nil, function(a)
			for part, cf in pairs(parts) do
				part.Size = size*(0.2+1.2*math.sin(a*math.pi))*scale
				part.CFrame = cf * CFrame.new((-3+6*a)*mscale, (3-6*a)*mscale, 0) * CFrame.Angles(0, math.pi/2, 0) * CFrame.Angles(math.pi/4, 0, 0)
			end
		end)
		for part in pairs(parts) do
			part:Remove()
		end
	end

	local function tackle(pokemon, target)
		local sprite = pokemon.sprite
		local s = sprite.part.Position
		local e = target.sprite.part.Position
		local dir = ((e-s)*Vector3.new(1,0,1)).unit
		Tween(.1, nil, function(a)
			sprite.offset = dir*2*a
		end)
		spawn(function()
			Tween(.17, 'easeOutCubic', function(a)
				sprite.offset = dir*2*(1-a)
			end)
		end)
	end

	local function cParticle(image, size, color)
		local p = create 'Part' {
			Transparency = 1.0,
			Anchored = true,
			CanCollide = false,
			Size = Vector3.new(.2, .2, .2),
			Parent = workspace,
		}
		local bbg = create 'BillboardGui' {
			Adornee = p,
			Size = UDim2.new(size or 1, 0, size or 1, 0),
			Parent = p
		}
		local img = create 'ImageLabel' {
			BackgroundTransparency = 1.0,
			Image = type(image) == 'number' and ('rbxassetid://'..image) or image,
			ImageColor3 = color or nil,
			Size = UDim2.new(1.0, 0, 1.0, 0),
			ZIndex = 2,
			Parent = bbg
		}
		return p, bbg, img
	end

	return {
		setTweenFunc = function(fn) -- to fastforward
			Tween = fn
		end,

		-- STATUS ANIMS

		status = {
			psn = function(pokemon)
				local p = _p.Particles
				local isTox = pokemon.status=='tox'
				local part = pokemon.sprite.part
				for i = 1, 10 do
					wait(.1)
					p:new {
						Position = (part.CFrame*CFrame.new(part.Size.X*(math.random()-.5)*.7, -part.Size.Y/2*math.random()*.8, -.2)).p,
						Velocity = Vector3.new(0, 3, 0),
						Acceleration = false,
						Color = isTox and Color3.new(111/255, 9/255, 95/255) or Color3.new(175/255, 106/255, 206/255),
						Lifetime = .5,
						Image = 5965008190,
						OnUpdate = function(a, gui)
							local s = .8*math.sin(a*math.pi)
							gui.BillboardGui.Size = UDim2.new(s, 0, s, 0)
						end,
					}
				end
			end,
			brn = function(pokemon)
				local p = _p.Particles
				local part = pokemon.sprite.part
				for i = 1, 10 do
					wait(.1)
					p:new {
						Position = (part.CFrame*CFrame.new(part.Size.X*(math.random()-.5)*.7, -part.Size.Y/2*math.random()*.8, -.2)).p,
						Velocity = Vector3.new(0, 4, 0),
						Acceleration = false,
						Lifetime = .5,
						Image = 5964954818,
						OnUpdate = function(a, gui)
							local s = 1.2*math.cos(a*math.pi/2)
							gui.BillboardGui.Size = UDim2.new(s, 0, s, 0)
						end,
					}
				end
			end,
			par = function(pokemon)
				local p = _p.Particles
				local part = pokemon.sprite.part
				pokemon.sprite.animation:Pause()
				for i = 1, 10 do
					wait(.1)
					local rs = 360*math.random()
					p:new {
						Position = (part.CFrame*CFrame.new(part.Size.X*(math.random()-.5)*.7, -part.Size.Y*(math.random()-.5)*.7, -.2)).p,
						Size = .7+.4*math.random(),
						Acceleration = false,
						Lifetime = .2,
						Image = {5964959002, 5964966966, 5964972730},
						Rotation = rs,
					}
				end
				delay(.5, function()
					pokemon.sprite.animation:Play()
				end)
			end,
			slp = function(pokemon)
				local p = _p.Particles
				local part = pokemon.sprite.part
				local dir = 1
				if pokemon.side.n == 2 then
					dir = -1
				end
				for i = 1, 5 do
					p:new {
						Position = (part.CFrame*CFrame.new(part.Size.X*-.25*dir, part.Size.Y*.4, -.2)).p,
						Velocity = Vector3.new(0, 1, 0),
						Acceleration = false,
						Lifetime = 1,
						Color = Color3.new(.7, .7, .7),
						Image = 5964995500,
						OnUpdate = function(a, gui)
							local s = .2+.4*math.sin(a*math.pi/2)
							gui.BillboardGui.Size = UDim2.new(s, 0, s, 0)
							gui.BillboardGui.ImageLabel.Rotation = -30*a*dir
							if a > .6 then
								gui.BillboardGui.ImageLabel.ImageTransparency = (a-.6)/.4
							end
						end,
					}
					wait(.3)
				end
			end,
			confused = function(pokemon)
				local part = pokemon.sprite.part
				local cf = part.CFrame * CFrame.new(0, part.Size.Y/2+.25, 0)
				local duck1 = create 'Part' {
					Anchored = true,
					CanCollide = false,
					--				FormFactor = Enum.FormFactor.Custom,
					Size = Vector3.new(.2, .2, .2),
					Parent = workspace,

					create 'SpecialMesh' {
						MeshType = Enum.MeshType.FileMesh,
						MeshId = 'rbxassetid://9419831',
						TextureId = 'rbxassetid://9419827',
						Scale = Vector3.new(.5, .5, .5),
					}
				}
				local duck2, duck3 = duck1:Clone(), duck1:Clone()
				duck2.Parent, duck3.Parent = workspace, workspace
				local r = part.Size.X*.45
				local o2, o3 = math.pi*2/3, math.pi*4/3
				Tween(1.5, nil, function(a)
					local angle = a*7
					local a1 = angle
					local a2 = angle + o2
					local a3 = angle + o3
					duck1.CFrame = cf * CFrame.new(math.cos(a1)*r, 0, math.sin(a1)*r) * CFrame.Angles(0, a1*2, 0)
					duck2.CFrame = cf * CFrame.new(math.cos(a2)*r, 0, math.sin(a2)*r) * CFrame.Angles(0, a2*2, 0)
					duck3.CFrame = cf * CFrame.new(math.cos(a3)*r, 0, math.sin(a3)*r) * CFrame.Angles(0, a3*2, 0)
				end)
				duck1:Remove()
				duck2:Remove()
				duck3:Remove()
			end,

			heal = function(pokemon)
				local sprite = pokemon.sprite
				local cf = sprite.part.CFrame
				local size = sprite.part.Size
				for i = 1, 8 do
					_p.Particles:new {
						Rotation = math.random()*360,
						RotVelocity = (math.random(2)==1 and 1 or -1)*(80+math.random(80)),
						Image = 5965001429,
						Color = Color3.fromHSV((150+math.random()*20)/360, .5, 1),
						Position = cf*Vector3.new((math.random()-.5)*.8*size.X, (math.random()-.5)*.8*size.Y, -.5),
						Lifetime = .7,
						Acceleration = false,
						Velocity = Vector3.new(0, 1.5, 0),
						OnUpdate = function(a, gui)
							local s = math.sin(a*math.pi)
							gui.BillboardGui.Size = UDim2.new(.5*s, 0, .5*s, 0)
						end
					}
					wait(.06)
				end
			end
		},

		-- MOVE PREP ANIMS

		prepare = { -- args: pokemon, target, battle, move
			-- in-game, in essence: fall into purple puddle, then on second turn appear behind opponent (fall out of purple thing) and attack
			-- phantomforce  pokemon:getName() .. ' vanished instantly!'
			bounce = function(pokemon, _, _, _, ff)
				local sprite = pokemon.sprite
				if ff then sprite.offset = Vector3.new(0, 10, 0) return end
				for i = 1, 2 do
					Tween(.7, nil, function(a)
						sprite.offset = Vector3.new(0, 2*i*math.sin(a*math.pi), 0)
					end)
				end
				Tween(.5, 'easeOutCubic', function(a)
					sprite.offset = Vector3.new(0, 10*a, 0)
				end)
				return pokemon:getName() .. ' sprang up!'
			end,
			dig = function(pokemon, _, _, _, ff)
				local sprite = pokemon.sprite
				local y = sprite.part.Size.Y+(sprite.spriteData.inAir or 0)+.2
				if ff then sprite.offset = Vector3.new(0, -y, 0) return end
				local n = 5
				for i = 1, n do
					Tween(.25, 'easeOutCubic', function(a)
						sprite.offset = Vector3.new(0, (i-1+a)/n*-y, 0)
					end)
					wait(.1)
				end
				return pokemon:getName() .. ' burrowed its way under the ground!'
			end,
			dive = function(pokemon, _, _, _, ff)
				local sprite = pokemon.sprite
				local y = sprite.part.Size.Y+(sprite.spriteData.inAir or 0)
				if ff then sprite.offset = Vector3.new(0, -y, 0) return end
				Tween(.9, 'easeOutCubic', function(a)
					sprite.offset = Vector3.new(0, a*-y, 0)
				end)
				return pokemon:getName() .. ' hid underwater!'
			end,
			fly = function(pokemon, _, _, _, ff)
				local sprite = pokemon.sprite
				if ff then sprite.offset = Vector3.new(0, 10, 0) return end
				Tween(1, 'easeInCubic', function(a)
					sprite.offset = Vector3.new(0, 10*a, 0)
				end)
				return pokemon:getName() .. ' flew up high!'
			end,
			freezeshock = function(pokemon, _, _, _, ff)
				-- todo
				return pokemon:getName() .. ' became cloaked in a freezing light!'
			end,
			geomancy = function(pokemon, _, _, _, ff)
				-- todo?
				return pokemon:getName() .. ' is absorbing power!'
			end,
			iceburn = function(pokemon, _, _, _, ff)
				-- todo
				return pokemon:getName() .. ' became cloaked in freezing air!'
			end,
			razorwind = function(pokemon, _, _, _, ff)
				-- todo
				return pokemon:getName() .. ' whipped up a whirlwind!'
			end,
			shadowforce = function(pokemon, _, _, _, ff)
				local spriteLabel = pokemon.sprite.animation.spriteLabel
				if ff then spriteLabel.ImageTransparency = 1.0 return end
				Tween(.5, 'easeOutCubic', function(a)
					spriteLabel.ImageTransparency = a
				end)
				return pokemon:getName() .. ' vanished instantly!'
			end,
			solarbeam = function(pokemon, _, _, _, ff)
				-- todo
				return pokemon:getName() .. ' absorbed light!'
			end,
			skullbash = function(pokemon, _, _, _, ff)
				-- todo
				return pokemon:getName() .. ' tucked in its head!'
			end,
			skyattack = function(pokemon, _, _, _, ff)
				-- todo
				return pokemon:getName() .. ' became cloaked in a harsh light!'
			end,
			skydrop = function(pokemon, target, _, _, ff)
				if not target then return end
				target.skydropper = pokemon
				local sprite = pokemon.sprite
				local sp = sprite.offset
				local ep = (target.sprite.cf.p - sprite.cf.p)*Vector3.new(.9,0,.9)+Vector3.new(0, target.sprite.part.Size.Y*.3, 0)
				if ff then
					sprite.offset = ep + Vector3.new(0, 10, 0)
					target.sprite.offset = Vector3.new(0, 10, 0)
					return
				end
				Tween(.6, nil, function(a)
					sprite.offset = sp + (ep-sp)*a
				end)
				Tween(1, 'easeInCubic', function(a)
					local rise = Vector3.new(0, 10*a, 0)
					sprite.offset = ep+rise
					target.sprite.offset = rise
				end)
				return pokemon:getName() .. ' took ' .. target:getLowerName() .. ' into the sky!'
			end
		},

		-- REGULAR MOVE ANIMS

		absorb = function(pokemon, targets)
			local target = targets[1]; if not target then return end
			absorb(pokemon, target)
			return true
		end,
		aerialace = function(pokemon, targets)
			local target = targets[1]; if not target then return end
			cut(target, 'Medium blue')
			return 'sound'
		end,
		aurasphere = function(pokemon, targets)
			local target = targets[1]; if not target then return true end
			local sprite = pokemon.sprite
			local centroid = targetPoint(pokemon, 2.5)
			local cf = CFrame.new(centroid, centroid + workspace.CurrentCamera.CFrame.lookVector)
			local function makeParticle(hue)
				local p = create 'Part' {
					Transparency = 1.0,
					Anchored = true,
					CanCollide = false,
					Size = Vector3.new(.2, .2, .2),
					Parent = workspace,
				}
				local bbg = create 'BillboardGui' {
					Adornee = p,
					Size = UDim2.new(.7, 0, .7, 0),
					Parent = p,
					create 'ImageLabel' {
						BackgroundTransparency = 1.0,
						Image = 'rbxassetid://5964827385',
						ImageTransparency = .15,
						ImageColor3 = Color3.fromHSV(hue/360, 1, .85),
						Size = UDim2.new(1.0, 0, 1.0, 0),
						ZIndex = 2
					}
				}
				return p, bbg
			end
			local main, mbg = makeParticle(260)
			main.CFrame = cf
			local allParticles = {main}
			delay(.3, function()
				local rand = math.random
				for i = 2, 11 do
					local theta = rand()*6.28
					local offset = Vector3.new(math.cos(theta), math.sin(theta), .5)
					local p, b = makeParticle(rand(175, 230))
					allParticles[i] = p
					local r = math.random()*.35+.2
					spawn(function()
						local st = tick()
						local function o(r)
							local et = (tick()-st)*7
							p.CFrame = cf * CFrame.new(offset*r+.125*Vector3.new(math.cos(et), math.sin(et)*math.cos(et), 0))
						end
						Tween(.2, 'easeOutCubic', function(a)
							if not p.Parent then return false end
							b.Size = UDim2.new(.5*a, 0, .5*a, 0)
							o(r+.6)
						end)
						Tween(.25, 'easeOutCubic', function(a)
							if not p.Parent then return false end
							o(r+.6*(1-a))
						end)
						while p.Parent do
							o(r)
							stepped:wait()
						end
					end)
					wait(.1)
				end
			end)
			Tween(1.5, nil, function(a)
				mbg.Size = UDim2.new(2.5*a, 0, 2.5*a, 0)
			end)
			wait(.3)
			local targPos = targetPoint(target)
			local dp = targPos - centroid
			local v = 30
			local scf = cf
			Tween(dp.magnitude/v, nil, function(a)
				cf = scf + dp*a
				main.CFrame = cf
			end)
			for _, p in pairs(allParticles) do
				p:Remove()
			end
			return true -- perform usual hit anim
		end,
		bite = function(pokemon, targets)
			local target = targets[1]; if not target then return true end
			Utilities.fastSpawn(function() bite(target) end)
			wait(.35)--(1.5*3.14-.5) = (t*2/d-1)*...?
			return 'sound'
		end,
		bounce = function(pokemon, targets)
			local target = targets[1]; if not target then return true end
			local sprite = pokemon.sprite
			local ep = (target.sprite.cf.p - sprite.cf.p)*Vector3.new(.9,0,.9)
			local sp = ep+Vector3.new(0, 10, 0)--sprite.offset
			Tween(.3, nil, function(a)
				sprite.offset = sp + (ep-sp)*a
			end)
			spawn(function()
				wait(.1)
				Tween(1, 'easeOutCubic', function(a)
					sprite.offset = ep*(1-a)
				end)
			end)
			return true -- perform usual hit anim
		end,
		bubble = function(pokemon, targets)
			local target = targets[1]; if not target then return end
			local from = targetPoint(pokemon)
			local to = (pokemon.sprite.part.CFrame-pokemon.sprite.part.Position) + targetPoint(target)
			local ease = Utilities.Timing.easeOutCubic(.8)
			for i = 1, 6 do
				local st = tick()
				local dif = (to*Vector3.new((math.random()-.5)*3, (math.random()-.5)*3, (math.random()-.5)*.1))-from
				local size = .7+.3*math.random()
				_p.Particles:new {
					Image = 5965008190,
					Color = Color3.fromHSV(math.random(190, 220)/360, 1, 1),
					Lifetime = 1.2,
					OnUpdate = function(a, gui)
						gui.CFrame = CFrame.new(from + dif*(a>.8 and 1 or ease(a))) + Vector3.new(0, math.sin(tick()-st)*.2, 0)
						local s = (.7+.4*a)*size
						if a > .95 then
							s = s + (a-.95)*4
							gui.BillboardGui.ImageLabel.ImageTransparency = (a-.95)*20
						end
						gui.BillboardGui.Size = UDim2.new(s, 0, s, 0)
					end
				}
				wait(.1)
			end
			wait(.5)
			return true
		end,
		bubblebeam = function(pokemon, targets)
			local target = targets[1]; if not target then return end
			local from = targetPoint(pokemon)
			local to = (pokemon.sprite.part.CFrame-pokemon.sprite.part.Position) + targetPoint(target)
			local ease = Utilities.Timing.easeOutCubic(.8)
			for i = 1, 20 do
				local st = tick()
				local dif = (to*Vector3.new((math.random()-.5)*1.6, (math.random()-.5)*1.6, (math.random()-.5)*.1))-from
				local size = .7+.3*math.random()
				_p.Particles:new {
					Image = 5965008190,
					Color = Color3.fromHSV(math.random(190, 220)/360, 1, 1),
					Lifetime = 1.2,
					OnUpdate = function(a, gui)
						gui.CFrame = CFrame.new(from + dif*(a>.8 and 1 or ease(a))) + Vector3.new(0, math.sin(tick()-st)*.2, 0)
						local s = (.7+.4*a)*size
						if a > .95 then
							s = s + (a-.95)*4
							gui.BillboardGui.ImageLabel.ImageTransparency = (a-.95)*20
						end
						gui.BillboardGui.Size = UDim2.new(s, 0, s, 0)
					end
				}
				wait(.05)
			end
			wait(.5)
			return true
		end,
		closecombat = function(pokemon, targets)
			local target = targets[1]; if not target then return end
			local sprite = pokemon.sprite
			local ep = (target.sprite.cf.p - sprite.cf.p)*Vector3.new(1,0,1)
			ep = ep.unit*(ep.magnitude-3)
			Tween(.4, nil, function(a)
				sprite.offset = ep*a + Vector3.new(0, math.sin(a*math.pi)*1.5, 0)
			end)
			local ts = target.sprite
			local cf = ts.part.CFrame
			local cfo = cf-cf.p
			local size = ts.part.Size
			local offset = ts.offset
			local back = ep.unit*2
			--		cf = cf-cf.p
			for i = 1, 5 do
				local x = math.random()-.5
				local y = math.random()*.5
				_p.Particles:new {
					Acceleration = false,
					Image = 5965013884, -- 188x152
					Lifetime = .2,
					Color = Color3.fromRGB(194, 88, 61),
					Size = Vector2.new(1, .8),
					Position = cf * Vector3.new(x*size.X, y*size.Y, -.5),
					OnUpdate = function(a, gui)
						local img = gui.BillboardGui.ImageLabel
						if a < .25 and x < 0 then
							img.ImageRectSize = Vector2.new(-188, 152)
							img.ImageRectOffset = Vector2.new(188, 0)
						elseif a > .5 then
							img.ImageTransparency = (a-.5)*2
						end
					end
				}
				spawn(function()
					Tween(.23, nil, function(a)
						local s = math.sin(a*math.pi)
						ts.offset = offset + (cfo*Vector3.new(-x*size.X*.5*s,0,0)) + back*s
					end)
				end)
				if i < 5 then
					Tween(.23, nil, function(a)
						local s = math.sin(a*math.pi)
						sprite.offset = ep-back*s*.5
					end)
				end
			end
			spawn(function()
				Tween(.4, nil, function(a)
					sprite.offset = ep*(1-a) + Vector3.new(0, math.sin(a*math.pi)*1.5, 0)
				end)
			end)
			return true
		end,
		crosschop = function(pokemon, targets)
			local target = targets[1]; if not target then return end
			cut(target, 'Brown', 2)
			return 'sound'
		end,
		crosspoison = function(pokemon, targets)
			local target = targets[1]; if not target then return end
			cut(target, 'Magenta', 2)
			return 'sound'
		end,
		crunch = function(pokemon, targets)
			local target = targets[1]; if not target then return true end
			Utilities.fastSpawn(function() bite(target, nil, nil, true) end)
			wait(.35)
			return 'sound'
		end,
		cut = function(pokemon, targets)
			local target = targets[1]; if not target then return true end
			cut(target)
			return 'sound'
		end,
		dig = function(pokemon, targets)
			local target = targets[1]; if not target then return true end
			local sprite = pokemon.sprite
			local sp = sprite.offset
			local ep = (target.sprite.cf.p - sprite.cf.p)*Vector3.new(.9,0,.9)
			Tween(.3, nil, function(a)
				sprite.offset = sp + (ep-sp)*a
			end)
			spawn(function()
				wait(.1)
				Tween(1, 'easeOutCubic', function(a)
					sprite.offset = ep*(1-a)
				end)
			end)
			return true -- perform usual hit anim
		end,
		dive = function(pokemon, targets)
			local target = targets[1]; if not target then return true end
			local sprite = pokemon.sprite
			local sp = sprite.offset
			local ep = (target.sprite.cf.p - sprite.cf.p)*Vector3.new(.9,0,.9)
			Tween(.3, nil, function(a)
				sprite.offset = sp + (ep-sp)*a
			end)
			spawn(function()
				wait(.1)
				Tween(1, 'easeOutCubic', function(a)
					sprite.offset = ep*(1-a)
				end)
			end)
			return true -- perform usual hit anim
		end,
		doubleteam = function(pokemon)
			local sprite = pokemon.sprite
			-- v = v0 + a*t
			-- p = p0 + v0*t + a*t*t/2
			Tween(2, nil, function(a)
				sprite.offset = Vector3.new(math.sin(15*a + 34*a*a), 0, 0)
			end)
			local left, right = Vector3.new(-1, 0, 0), Vector3.new(1, 0, 0)
			Tween(1, 'easeInCubic', function(a, t)
				if t%.07 < .035 then
					sprite.offset = right * (1-a)
				else
					sprite.offset = left * (1-a)
				end
			end)
			sprite.offset = nil
		end,
		dragonclaw = function(pokemon, targets) -- todo: black/red particles
			local target = targets[1]; if not target then return end
			cut(target, 'Royal purple', 3)
			return 'sound'
		end,
		drainingkiss = function(pokemon, targets)
			local target = targets[1]; if not target then return end
			_p.Particles:new {
				Acceleration = false,
				Image = 5119915842,-- 271x186
				Lifetime = .4,
				--			Size = Vector2.new(2, 1.34),
				Position = target.sprite.part.CFrame * Vector3.new(0, 0, -.5),
				OnUpdate = function(a, gui)
					local s = math.sin(.5+1.6*a)
					gui.BillboardGui.Size = UDim2.new(2*s, 0, 1.34*s, 0)
					if a > .5 then
						gui.BillboardGui.ImageLabel.ImageTransparency = (a-.5)*2
					end
				end
			}
			wait(.25)
			absorb(pokemon, target, 12, Color3.new(.92, .7, .92))
			return true
		end,
		dualchop = function(pokemon, targets)
			local target = targets[1]; if not target then return end
			cut(target, 'Royal purple')
			return 'sound'
		end,
		ember = function(pokemon, targets)
			local target = targets[1]; if not target then return end
			local from = targetPoint(pokemon)
			local to = targetPoint(target)
			local dif = to-from
			for i = 1, 3 do
				_p.Particles:new {
					Image = 5964954818,
					Lifetime = .7,
					OnUpdate = function(a, gui)
						gui.CFrame = CFrame.new(from + dif*a)
						local s = 1+1.5*a
						gui.BillboardGui.Size = UDim2.new(s, 0, s, 0)
					end
				}
				wait(.05)
			end
			wait(.6)
			return true
		end,
		energyball = function(pokemon, targets)
			local target = targets[1]; if not target then return true end
			local sprite = pokemon.sprite
			local centroid = targetPoint(pokemon, 2.5)
			local cf = CFrame.new(centroid, centroid + workspace.CurrentCamera.CFrame.lookVector)
			local function makeParticle(hue)
				local p = create 'Part' {
					Transparency = 1.0,
					Anchored = true,
					CanCollide = false,
					Size = Vector3.new(.2, .2, .2),
					Parent = workspace,
				}
				local bbg = create 'BillboardGui' {
					Adornee = p,
					Size = UDim2.new(.7, 0, .7, 0),
					Parent = p,
					create 'ImageLabel' {
						BackgroundTransparency = 1.0,
						Image = 'rbxassetid://5964827385',
						ImageTransparency = .15,
						ImageColor3 = Color3.fromHSV(hue/360, 1, .85),
						Size = UDim2.new(1.0, 0, 1.0, 0),
						ZIndex = 2
					}
				}
				return p, bbg
			end
			local main, mbg = makeParticle(100)
			main.CFrame = cf
			local allParticles = {main}
			delay(.3, function()
				local rand = math.random
				for i = 2, 11 do
					local theta = rand()*6.28
					local offset = Vector3.new(math.cos(theta), math.sin(theta), .5)
					local p, b = makeParticle(rand(66, 156))
					allParticles[i] = p
					local r = math.random()*.35+.2
					spawn(function()
						local st = tick()
						local function o(r)
							local et = (tick()-st)*7
							p.CFrame = cf * CFrame.new(offset*r+.125*Vector3.new(math.cos(et), math.sin(et)*math.cos(et), 0))
						end
						Tween(.2, 'easeOutCubic', function(a)
							if not p.Parent then return false end
							b.Size = UDim2.new(.5*a, 0, .5*a, 0)
							o(r+.6)
						end)
						Tween(.25, 'easeOutCubic', function(a)
							if not p.Parent then return false end
							o(r+.6*(1-a))
						end)
						while p.Parent do
							o(r)
							stepped:wait()
						end
					end)
					wait(.1)
				end
			end)
			Tween(1.5, nil, function(a)
				mbg.Size = UDim2.new(2.5*a, 0, 2.5*a, 0)
			end)
			wait(.3)
			local targPos = targetPoint(target)
			local dp = targPos - centroid
			local v = 30
			local scf = cf
			Tween(dp.magnitude/v, nil, function(a)
				cf = scf + dp*a
				main.CFrame = cf
			end)
			for _, p in pairs(allParticles) do
				p:Remove()
			end
			return true -- perform usual hit anim
		end,
		explosion = function(pokemon, targets)
			pcall(function() pokemon.statbar:setHP(0, pokemon.maxhp) end)
			local e = create 'Explosion' {
				BlastPressure = 0,
				Position = pokemon.sprite.cf.p,
				Parent = workspace
			}
			delay(3, function() pcall(function() e:Remove() end) end)
			wait(.5)
			return true -- perform usual hit anim
		end,
		--[[similar to explosion]]selfdestruct = function(pokemon, targets)
			pcall(function() pokemon.statbar:setHP(0, pokemon.maxhp) end)
			local e = create 'Explosion' {
				BlastPressure = 0,
				Position = pokemon.sprite.cf.p,
				Parent = workspace
			}
			delay(3, function() pcall(function() e:Remove() end) end)
			wait(.5)
			return true -- perform usual hit anim
		end,
		falseswipe = function(pokemon, targets)
			local target = targets[1]; if not target then return end
			cut(target)
			return 'sound'
		end,
		firefang = function(pokemon, targets)
			local target = targets[1]; if not target then return true end
			Utilities.fastSpawn(function() bite(target, 5964954818, 2) end)
			wait(.35)
			return 'sound'
		end,
		flamethrower = function(pokemon, targets)
			local target = targets[1]; if not target then return true end
			local sprite = pokemon.sprite
			local s = targetPoint(pokemon, 2)
			local e = targetPoint(target)
			local dp = e-s
			local up = CFrame.new(s, e).upVector

			local tt = .7
			for n = 1, 20 do
				spawn(function()
					local p, b, i = cParticle(5965039110, 1.5)
					Tween(tt, nil, function(a)
						i.ImageColor3 = Color3.fromHSV(.138*(1-a), 1, 1)
						p.CFrame = CFrame.new(s) + up*math.sin(a*math.pi*1.5/tt+n*.2)*.4 + dp*a
					end)
					p:Remove()
				end)
				wait(.1)
			end
			wait(tt)
			return true--'sound' -- just play sound (single-target)
		end,
		fly = function(pokemon, targets)
			local target = targets[1]; if not target then return true end
			local sprite = pokemon.sprite
			local sp = sprite.offset
			local ep = (target.sprite.cf.p - sprite.cf.p)*Vector3.new(.9,0,.9)+Vector3.new(0,(sprite.spriteData.inAir or 0)*-.75,0)
			--		local sp = ep+Vector3.new(0, 10, 0)--sprite.offset
			Tween(.3, nil, function(a)
				sprite.offset = sp + (ep-sp)*a
			end)
			spawn(function()
				wait(.1)
				Tween(1, 'easeOutCubic', function(a)
					sprite.offset = ep*(1-a)
				end)
			end)
			return true -- perform usual hit anim
		end,
		furycutter = function(pokemon, targets)
			local target = targets[1]; if not target then return end
			cut(target, 'Medium green')
			return 'sound'
		end,
		furyswipes = function(pokemon, targets)
			local target = targets[1]; if not target then return end
			cut(target, nil, 3)
			return 'sound'
		end,
		gigadrain = function(pokemon, targets)
			local target = targets[1]; if not target then return end
			absorb(pokemon, target, 20)
			return true
		end,
		icebeam = function(pokemon, targets)
			local target = targets[1]; if not target then return true end
			local from = targetPoint(pokemon)
			local to = targetPoint(target)
			local dif = to-from
			local cf = target.sprite.part.CFrame
			cf = cf-cf.p
			local cam = workspace.CurrentCamera
			local fs = cam:WorldToScreenPoint(from)
			local ts = cam:WorldToScreenPoint(to)
			local rot = math.deg(math.atan2(ts.Y-fs.Y, ts.X-fs.X))+90
			for i = 1, 15 do
				local scale = math.random()*.5+.75
				local color = Color3.fromHSV(.5+.08*math.random(), math.random()*.75, 1)
				local offset = cf*(.25*Vector3.new(math.random()-.5, math.random()-.5, 0))
				_p.Particles:new {
					Color = color,
					Image = 5965043884,
					Lifetime = .7,
					Rotation = rot,
					OnUpdate = function(a, gui)
						gui.CFrame = CFrame.new(from + dif*a + offset)
						local s = (a<.2 and a*5 or 1)*scale
						gui.BillboardGui.Size = UDim2.new(s, 0, s, 0)
					end
				}
				delay(.7, function()
					for i = 1, 2 do
						local angle = math.random()*360
						_p.Particles:new {
							Color = color,
							Image = 644161227,--REPLACE IT WAS ICE
							Lifetime = .7,
							Rotation = angle+90,
							Size = .4*scale,
							Position = to,
							Velocity = 5*(cf*Vector3.new(math.cos(math.rad(angle)), math.sin(math.rad(angle)), 0)),
							Acceleration = false
						}
					end
				end)
				wait(.06)
			end
			wait(.5)
			return true
		end,
		icefang = function(pokemon, targets)
			local target = targets[1]; if not target then return true end
			Utilities.fastSpawn(function() bite(target, 5965117728) end)
			wait(.35)
			return 'sound'
		end,
		--	leafage = function(pokemon)
		--		
		--	end,
		lightscreen = function(pokemon)
			shield(pokemon, 'Pastel light blue')
		end,
		megadrain = function(pokemon, targets)
			local target = targets[1]; if not target then return end
			absorb(pokemon, target, 12)
			return true
		end,
		metalclaw = function(pokemon, targets)
			local target = targets[1]; if not target then return end
			cut(target, 'Smoky grey', 3)
			return 'sound'
		end,
		moonblast = function(pokemon, targets)
			local target = targets[1]; if not target then return end
			local from = targetPoint(pokemon, 2)
			local to = targetPoint(target)
			local dif = to-from

			local moon = create 'Part' {
				BrickColor = BrickColor.new('Carnation pink'),
				Material = Enum.Material.Neon,
				Anchored = true,
				CanCollide = false,
				TopSurface = Enum.SurfaceType.Smooth,
				BottomSurface = Enum.SurfaceType.Smooth,
				Size = Vector3.new(4, 4, 4),
				Shape = Enum.PartType.Ball,
				CFrame = CFrame.new(pokemon.sprite.cf.p+Vector3.new(0, 7-(pokemon.sprite.spriteData.inAir or 0), 0)),
				Parent = workspace
			}
			Tween(1, nil, function(a)
				moon.Transparency = 1-a
			end)
			local blast = moon:Clone()
			blast.BrickColor = BrickColor.new('Pink')
			blast.Parent = workspace
			local twoPi = math.pi*2
			local r = 4
			for i = 1, 20 do
				delay(.075*i, function()
					local beam = create 'Part' {
						Material = Enum.Material.Neon,
						BrickColor = BrickColor.new('White'),
						Anchored = true,
						CanCollide = false,
						TopSurface = Enum.SurfaceType.Smooth,
						BottomSurface = Enum.SurfaceType.Smooth,
						Parent = workspace,
					}
					local transform = CFrame.Angles(twoPi*math.random(),twoPi*math.random(),twoPi*math.random()).lookVector * r
					local cf = CFrame.new(from)*transform
					Tween(.25, nil, function(a)
						beam.Size = Vector3.new(.2, .2, r*a)
						beam.CFrame = CFrame.new(cf + (from-cf)/2*a, cf)
					end)
					Tween(.25, nil, function(a)
						beam.Size = Vector3.new(.2, .2, r*(1-a))
						beam.CFrame = CFrame.new(cf + (from-cf)*(.5+.5*a), cf)
					end)
					beam:Remove()
				end)
			end
			Tween(2, nil, function(a)
				blast.Size = Vector3.new(2.3,2.3,2.3)*a
				blast.CFrame = CFrame.new(from)
			end)
			wait(.2)
			Tween(.3, nil, function(a)
				blast.CFrame = CFrame.new(from+dif*a)
			end)
			blast:Remove()
			spawn(function()
				Tween(1, nil, function(a)
					moon.Transparency = a
				end)
				moon:Remove()
			end)
			return true
		end,
		nightslash = function(pokemon, targets)
			local target = targets[1]; if not target then return end
			cut(target, 'Black', 3)
			return 'sound'
		end,
		protect = function(pokemon)
			shield(pokemon)
		end,
		psychocut = function(pokemon, targets)
			local target = targets[1]; if not target then return end
			cut(target, 'Pink')
			return 'sound'
		end,
		razorleaf = function(pokemon, targets)
			local target = targets[1]; if not target then return end
			local orientation = pokemon.sprite.part.CFrame - pokemon.sprite.part.Position
			local from = orientation + targetPoint(pokemon, -.5)
			local to = orientation + targetPoint(target, .5)
			local psize = pokemon.sprite.part.Size
			local tsize = target.sprite.part.Size
			local p = _p.Particles
			local ease = Utilities.Timing.easeOutCubic(.3)
			local rot = target.sprite.siden==2 and 35 or 215
			for i = 1, 10 do -- 
				wait(.1)
				local x, y = math.random()-.5, math.random()-.5
				local thisfrom = from * CFrame.new(psize.X*x, psize.Y*y, 0)
				local thisto = to * CFrame.new(tsize.X*x, tsize.Y*y, 0)
				local dif = thisto.p - thisfrom.p
				p:new {
					Rotation = math.random(360),
					RotVelocity = 30,
					Acceleration = false,
					Lifetime = 1.45,
					Image = 5965129302,
					Size = .6,
					OnUpdate = function(a, gui)
						local t = a*1.45
						if t < .3 then
							gui.CFrame = thisfrom + Vector3.new(0, ease(t), 0)
						elseif t < 1.1 then
							gui.CFrame = thisfrom + Vector3.new(0, 1-.5*(t-.3)/.8, 0)
						else
							gui.BillboardGui.ImageLabel.Rotation = rot
							local o = (t-1.1)/.35
							gui.CFrame = thisfrom + Vector3.new(0, .5*(1-o), 0) + dif*o
						end
					end,
				}
			end
			wait(1.7)
			return true
		end,
		reflect = function(pokemon)
			shield(pokemon, 'Carnation pink')
		end,
		rockslide = function(pokemon, targets)
			for _, target in pairs(targets) do
				spawn(function()
					local cf = target.sprite.part.CFrame
					cf = cf-cf.p
					local dir = targetPoint(target, 0)-targetPoint(target, 1)
					local pos = target.sprite.part.Position+Vector3.new(0, -target.sprite.part.Size.Y/2-(target.sprite.spriteData.inAir or 0), 0)
					local rockcf = CFrame.new(pos - dir + Vector3.new(0, .7, 0), pos + Vector3.new(0, .7, 0))

					for _ = 1, 4 do
						local rock = create 'Part' {
							Anchored = true,
							CanCollide = false,
							BrickColor = BrickColor.new('Dirt brown'),
							Size = Vector3.new(1.4, 1.4, 1.4),
							Parent = workspace,

							create 'SpecialMesh' {
								MeshType = Enum.MeshType.FileMesh,
								MeshId = 'rbxassetid://1290033',
								Scale = Vector3.new(.8, .8, .8)
							}
						}
						local xoffset = cf*Vector3.new((math.random()-.5)*3, 0, 0)
						local rot = CFrame.Angles(math.random()*6.3, math.random()*6.3, math.random()*6.3)
						spawn(function()
							Tween(.5, nil, function(a)
								rock.CFrame = (rockcf + xoffset + Vector3.new(0, 8*(1-a), 0)) * rot
							end)
							Tween(.4, nil, function(a)
								rock.CFrame = (rockcf + xoffset + dir*2*a + Vector3.new(0, math.sin(a*math.pi*5/4)-a, 0)) * CFrame.Angles(-6*a, 0, 0) * rot
							end)
							rock:Remove()
						end)
						wait(.25)
					end
				end)
			end
			wait(1.3)
			return true
		end,
		sacredsword = function(pokemon, targets)
			local target = targets[1]; if not target then return end
			cut(target, 'Brown')
			return 'sound'
		end,
		scald = function(pokemon, targets)
			local target = targets[1]; if not target then return end
			local sprite = pokemon.sprite
			local s = targetPoint(pokemon, 2)
			local e = targetPoint(target, .5)
			local dp = e-s

			local tSprite = target.sprite
			local cf = tSprite.part.CFrame
			cf = cf-cf.p
			local tLabel; pcall(function() tLabel = tSprite.animation.spriteLabel end)
			delay(.7, function()
				Tween(.84, nil, function(a)
					local s = math.sin(a*math.pi)
					local m = (a*5)%1
					if m > .75 then
						m = m-1
					elseif m > .25 then
						m = .5-m
					end
					tSprite.offset = cf * Vector3.new(m*s, 0, 0)
					if tLabel then
						tLabel.ImageColor3 = Color3.new(1, 1-s, 1-s)
					end
				end)
			end)
			for n = 1, 15 do
				spawn(function()
					local p = cParticle(5965202235, 1, Color3.fromHSV((210+math.random()*20)/360, .8, .75))
					Tween(.7, nil, function(a)
						p.CFrame = CFrame.new(s + dp*a + Vector3.new(0, math.sin(a*math.pi)*.8, 0))
					end)
					p:Remove()
				end)
				wait(.06)
			end
			wait(.64)
			return true
		end,
		scratch = function(pokemon, targets)
			local target = targets[1]; if not target then return end
			cut(target, nil, 3)
			return 'sound'
		end,
		secretsword = function(pokemon, targets)
			local target = targets[1]; if not target then return end
			cut(target, 'Brown')
			return 'sound'
		end,
		shadowball = function(pokemon, targets)
			local target = targets[1]; if not target then return true end
			local sprite = pokemon.sprite
			local centroid = targetPoint(pokemon, 2.5)
			local cf = CFrame.new(centroid, centroid + workspace.CurrentCamera.CFrame.lookVector)
			local function makeParticle(hue)
				local p = create 'Part' {
					Transparency = 1.0,
					Anchored = true,
					CanCollide = false,
					Size = Vector3.new(.2, .2, .2),
					Parent = workspace,
				}
				local bbg = create 'BillboardGui' {
					Adornee = p,
					Size = UDim2.new(.7, 0, .7, 0),
					Parent = p,
					create 'ImageLabel' {
						BackgroundTransparency = 1.0,
						Image = 'rbxassetid://5964827385',
						ImageTransparency = .15,
						ImageColor3 = Color3.fromHSV(hue/360, .5, .5),
						Size = UDim2.new(1.0, 0, 1.0, 0),
						ZIndex = 2
					}
				}
				return p, bbg
			end
			local main, mbg = makeParticle(260)
			main.CFrame = cf
			local allParticles = {main}
			delay(.3, function()
				local rand = math.random
				for i = 2, 11 do
					local theta = rand()*6.28
					local offset = Vector3.new(math.cos(theta), math.sin(theta), .5)
					local p, b = makeParticle(rand(248, 310))
					allParticles[i] = p
					local r = math.random()*.35+.2
					spawn(function()
						local st = tick()
						local function o(r)
							local et = (tick()-st)*7
							p.CFrame = cf * CFrame.new(offset*r+.125*Vector3.new(math.cos(et), math.sin(et)*math.cos(et), 0))
						end
						Tween(.2, 'easeOutCubic', function(a)
							if not p.Parent then return false end
							b.Size = UDim2.new(.5*a, 0, .5*a, 0)
							o(r+.6)
						end)
						Tween(.25, 'easeOutCubic', function(a)
							if not p.Parent then return false end
							o(r+.6*(1-a))
						end)
						while p.Parent do
							o(r)
							stepped:wait()
						end
					end)
					wait(.1)
				end
			end)
			Tween(1.5, nil, function(a)
				mbg.Size = UDim2.new(2.5*a, 0, 2.5*a, 0)
			end)
			wait(.3)
			local targPos = targetPoint(target)
			local dp = targPos - centroid
			local v = 30
			local scf = cf
			Tween(dp.magnitude/v, nil, function(a)
				cf = scf + dp*a
				main.CFrame = cf
			end)
			for _, p in pairs(allParticles) do
				p:Remove()
			end
			return true -- perform usual hit anim
		end,
		shadowclaw = function(pokemon, targets)
			local target = targets[1]; if not target then return end
			cut(target, 'Dark indigo', 3)
			return 'sound'
		end,
		shadowforce = function(pokemon, targets)
			local target = targets[1]; if not target then return end
			local spriteLabel = pokemon.sprite.animation.spriteLabel
			spawn(function()
				Tween(.075, nil, function(a)
					spriteLabel.ImageTransparency = 1-a
				end)
			end)
			tackle(pokemon, target)
			return true -- perform usual hit anim
		end,
		skydrop = function(pokemon, targets, _, _, tMeta)
			local target = targets[1]; if not target then return end
			local sprite = pokemon.sprite
			local tp = target.sprite.offset
			Tween(.5, 'easeOutQuart', function(a)
				target.sprite.offset = tp*(1-a)
			end)
			if tMeta then
				Utilities.sound(tMeta.soundId[target] or 5893169531, .75, tMeta.effectiveness[target] == 1 and .5 or .6, 5)--normal damage again replace
				--			spawn(function()
				--				local sl = target.sprite.animation.spriteLabel
				--				for i = 1, 3 do
				--					wait(.03)
				--					sl.Visible = false
				--					wait(.03)
				--					sl.Visible = true
				--				end
				--			end)
			end
			spawn(function()
				Tween(1, 'easeOutCubic', function(a)
					sprite.offset = Vector3.new(0, 10*(1-a), 0)
				end)
			end)
		end,
		slash = function(pokemon, targets)
			local target = targets[1]; if not target then return end
			cut(target, nil, 3)
			return 'sound'
		end,
		solarbeam = function(pokemon, targets)
			local target = targets[1]; if not target then return end
			local from = targetPoint(pokemon, 2)
			local to = targetPoint(target)
			local dif = to-from

			local sun = create 'Part' {
				BrickColor = BrickColor.new('New Yeller'),
				Material = Enum.Material.Neon,
				Anchored = true,
				CanCollide = false,
				TopSurface = Enum.SurfaceType.Smooth,
				BottomSurface = Enum.SurfaceType.Smooth,
				Size = Vector3.new(4, 4, 4),
				Shape = Enum.PartType.Ball,
				CFrame = CFrame.new(pokemon.sprite.cf.p+Vector3.new(0, 7-(pokemon.sprite.spriteData.inAir or 0), 0)),
				Parent = workspace
			}
			Tween(1, nil, function(a)
				sun.Transparency = 1-a
			end)
			local blast = sun:Clone()
			blast.BrickColor = BrickColor.new('Bright green')
			blast.Size = Vector3.new(1, 1, 1)
			blast.CFrame = CFrame.new(from)
			blast.Parent = workspace
			local bmesh = create 'SpecialMesh' {
				MeshType = Enum.MeshType.Sphere,
				Parent = blast
			}
			local twoPi = math.pi*2
			local r = 4
			for i = 1, 20 do
				delay(.075*i, function()
					local beam = create 'Part' {
						Material = Enum.Material.Neon,
						BrickColor = BrickColor.new('Br. yellowish green'),
						Anchored = true,
						CanCollide = false,
						TopSurface = Enum.SurfaceType.Smooth,
						BottomSurface = Enum.SurfaceType.Smooth,
						Parent = workspace,
					}
					local transform = CFrame.Angles(twoPi*math.random(),twoPi*math.random(),twoPi*math.random()).lookVector * r
					local cf = CFrame.new(from)*transform
					Tween(.25, nil, function(a)
						beam.Size = Vector3.new(.2, .2, r*a)
						beam.CFrame = CFrame.new(cf + (from-cf)/2*a, cf)
					end)
					Tween(.25, nil, function(a)
						beam.Size = Vector3.new(.2, .2, r*(1-a))
						beam.CFrame = CFrame.new(cf + (from-cf)*(.5+.5*a), cf)
					end)
					beam:Remove()
				end)
			end
			Tween(2, nil, function(a)
				bmesh.Scale = Vector3.new(2.3,2.3,2.3)*a
			end)
			wait(.2)
			local sbeam = blast:Clone()
			sbeam.Shape = Enum.PartType.Block--Cylinder
			sbeam.Parent = workspace
			local smesh = Instance.new('CylinderMesh', sbeam)
			local len = dif.magnitude
			Tween(.3, nil, function(a)
				sbeam.Size = Vector3.new(.8, len*a, .8)
				sbeam.CFrame = CFrame.new(from+dif*.5*a, to) * CFrame.Angles(math.pi/2, 0, 0)
				local s = (2.3-1.5*a)
				bmesh.Scale = Vector3.new(s,s,s)
				--			blast.CFrame = CFrame.new(from)
			end)
			spawn(function()
				--			local ss, sc = sbeam.Size, sbeam.CFrame
				local bs, bc = blast.Size, blast.CFrame
				Tween(.4, 'easeOutQuad', function(a)
					local o = 1-a
					smesh.Scale = Vector3.new(o,1,o)
					--sbeam.Size = ss*Vector3.new(1,o,o)
					--sbeam.CFrame = sc
					bmesh.Scale = Vector3.new(o,o,o)
					--				blast.Size = bs*o
					--				blast.CFrame = bc
				end)
				sbeam:Remove()
				blast:Remove()
				wait(.2)
				Tween(1, nil, function(a)
					sun.Transparency = a
				end)
				sun:Remove()
			end)
			return true
		end,
		spikes = function(pokemon)
			spikes(pokemon)
		end,
		tackle = function(pokemon, targets)
			local target = targets[1]; if not target then return end
			tackle(pokemon, target)
			return true -- perform usual hit anim
		end,
		teleport = function(pokemon)
			pcall(function()
				local part = pokemon.sprite.part
				local cf = part.CFrame
				local x = part.Size.X
				local y = part.Size.Y
				Tween(.3, nil, function(a)
					part.Size = Vector3.new(x*math.cos(a*math.pi/2), y*(1+math.sin(a*math.pi/2)*1.5), .2)
					part.CFrame = cf
				end)
				part:Remove()
			end)
		end,
		thunderbolt = function(pokemon, targets)
			local target = targets[1]; if not target then return true end
			local cf = (target.sprite.part.CFrame-target.sprite.part.Position)+targetPoint(target, 0)
			local angles = {.3, -.3, 0}
			for i = 1, 3 do
				local p = create 'Part' {
					Anchored = true,
					CanCollide = false,
					Transparency = 1.0,
					Parent = workspace
				}
				local d = create 'Decal' {
					Texture = 'rbxassetid://5965241978',
					Face = Enum.NormalId.Front,
					Parent = p
				}
				local d2 = create 'Decal' {
					Texture = 'rbxassetid://5965241978',
					Face = Enum.NormalId.Front,
					Parent = p
				}
				local c = cf * CFrame.Angles(0, 0, angles[i])
				spawn(function()
					Tween(.25, 'easeOutCubic', function(a)
						p.Size = Vector3.new(2, 6*a, .2)
						p.CFrame = c * CFrame.new(0, 6-3*a, 0)
						if a > .8 then
							local t = (a-.8)*5
							d.Transparency = t
							d2.Transparency = t
						end
					end)
				end)
				wait(.16)
			end
			--		wait(.1)
			return true
		end,
		thunderfang = function(pokemon, targets)
			local target = targets[1]; if not target then return true end
			Utilities.fastSpawn(function() bite(target, {5964959002, 5964966966, 5964972730}) end)
			wait(.35)
			return 'sound'
		end,
		toxicspikes = function(pokemon)
			spikes(pokemon, 'ToxicSpikes', 'Mulberry')
		end,
		vinewhip = function(pokemon, targets)
			local target = targets[1]; if not target then return end
			cut(target, 'Bright green')
			return 'sound'
		end,
		watergun = function(pokemon, targets)
			local target = targets[1]; if not target then return end
			local sprite = pokemon.sprite
			local s = targetPoint(pokemon, 2)
			local e = targetPoint(target, .5)
			local dp = e-s

			local cf = target.sprite.part.CFrame
			cf = cf-cf.p
			for n = 1, 7 do
				spawn(function()
					local p, _, i = cParticle(5965202235, .65+math.random()*.05, Color3.fromHSV((180+math.random()*30)/360, .6, .9))
					i.Rotation = math.random(360)
					i.ImageTransparency = .1+.2*math.random()
					local offset = cf*(Vector3.new(math.random()-.5, math.random()-.5, 0)*.25)
					Tween(.5, nil, function(a)
						p.CFrame = CFrame.new(s + dp*a + offset)
					end)
					p:Remove()
				end)
				wait(.03)
			end
			wait(.47)
			return true
		end,
		watershuriken = function(pokemon, targets)
			local target = targets[1]; if not target then return end
			local s = create 'Part' {
				Anchored = true,
				CanCollide = false,
				BrickColor = BrickColor.new('Cyan'),
				Reflectance = .4,
				Transparency = .3,
				Size = Vector3.new(1, 1, 1),
				Parent = workspace,

				create 'SpecialMesh' {
					MeshType = Enum.MeshType.FileMesh,
					MeshId = 'rbxassetid://11376946',
					Scale = Vector3.new(1.6, 1.6, 1.6)
				}
			}
			local f = targetPoint(pokemon)
			local d = targetPoint(target)-f
			local cf = CFrame.new(f, f+d) * CFrame.Angles(0, 0, -.8)
			Tween(.5, nil, function(a)
				s.CFrame = (cf+d*a) * CFrame.Angles(0, -10*a, 0)
			end)
			s:Remove()
			return true
		end,
		xscissor = function(pokemon, targets)
			local target = targets[1]; if not target then return end
			cut(target, 'Br. yellowish green', 2)--'Moss'
			return 'sound'
		end,
		infernooverdrive = function(p420, p421, p422)
			local v655 = p421[1]
			if not v655 then
				return
			end
			local sprite_1 = p420.sprite
			local po_1 = targetPoint(p420, 2)
			local po_2 = targetPoint(v655, 0.5) - po_1
			local po_3 = Instance.new("Model", workspace)
			_p.DataManager:preload("Image", 879747500)
			for po_4, po_5 in pairs({ 165709404, 212966179 }) do
				local v662 = create("Part")({
					Anchored = true, 
					CanCollide = false, 
					CFrame = p422.CoordinateFrame2 + Vector3.new(0, -3, 0), 
					Parent = po_3,
					create("SpecialMesh")({
						MeshType = Enum.MeshType.FileMesh, 
						MeshId = "rbxassetid://" .. po_5, 
						Scale = Vector3.new(0.2, 0.2, 0.2)
					})
				})
			end
			local l__CFrame__663 = v655.sprite.part.CFrame
			local v664 = l__CFrame__663 - l__CFrame__663.p
			local v665 = {}
			for v666 = 1, 6 do
				local v667 = create("Part")({
					Transparency = 1, 
					Anchored = true, 
					CanCollide = false, 
					Size = Vector3.new(1, 1, 1), 
					CFrame = v664 * CFrame.Angles(0, 0, math.pi / 3 * v666) * CFrame.new(0, 3, 0) + po_1, 
					Parent = workspace
				})
				create("Trail")({
					Attachment0 = create("Attachment")({
						CFrame = CFrame.new(-0.3, 0.3, -0.3), 
						Parent = v667
					}), 
					Attachment1 = create("Attachment")({
						CFrame = CFrame.new(0.3, -0.3, 0.3), 
						Parent = v667
					}), 
					Color = ColorSequence.new(Color3.new(0.9, 0.1, 0), Color3.new(1, 1, 0)), 
					Transparency = NumberSequence.new(0.5, 1), 
					Lifetime = 1, 
					Parent = v667
				})
				v665[v666] = v667
			end
			local targetPoint38 = create("Part")({
				BrickColor = BrickColor.new("Bright orange"), 
				Material = Enum.Material.Neon, 
				Anchored = true, 
				CanCollide = false, 
				TopSurface = Enum.SurfaceType.Smooth, 
				BottomSurface = Enum.SurfaceType.Smooth, 
				Shape = Enum.PartType.Ball, 
				Parent = workspace
			})
			local l__Y__139 = sprite_1.part.Size.Y
			Tween(1, nil, function(p423)
				targetPoint38.Size = Vector3.new(p423, p423, p423) * l__Y__139
				targetPoint38.CFrame = CFrame.new(po_1)
				for v668, v669 in pairs(v665) do
					v669.CFrame = v664 * CFrame.Angles(0, 0, math.pi / 3 * v668 + 6 * p423) * CFrame.new(0, 2 * (1 - p423) + 1, 0) + po_1
				end
			end)
			local targetPoint40 = po_2 * Vector3.new(1, 0, 1).unit
			local targetPoint41 = sprite_1.spriteData.inAir and 0
			Tween(0.6, nil, function(p424)
				sprite_1.offset = targetPoint40 * -2 --[[* p424]] + Vector3.new(0, --[[math.sin(math.pi) ]] targetPoint41 --[[* p424]], 0)
			end)
			local v670 = Utilities.Signal()
			local l__Y__671 = sprite_1.part.Size.Y
			local v672 = create("Part")({
				BrickColor = BrickColor.new("CGA brown"), 
				Anchored = true, 
				CanCollide = false, 
				Size = Vector3.new(1, 1, 1), 
				Parent = workspace,
				create("SpecialMesh")({
					MeshType = Enum.MeshType.FileMesh, 
					MeshId = "rbxassetid://212966179", 
					Scale = Vector3.new(1.1, 1.8, 1.1) * l__Y__671
				})
			})
			local v673 = create("Part")({
				BrickColor = BrickColor.new("CGA brown"), 
				Transparency = 0.5, 
				Anchored = true, 
				CanCollide = false, 
				Size = Vector3.new(1, 1, 1), 
				Parent = workspace,
				create("SpecialMesh")({
					MeshType = Enum.MeshType.FileMesh, 
					MeshId = "rbxassetid://165709404", 
					Scale = Vector3.new(2, 2, 2) * l__Y__671
				})
			})
			local v674 = sprite_1.cf.p + Vector3.new(0, l__Y__671 / 2, 0)
			local v675 = CFrame.new(v674, v674 + targetPoint40) * CFrame.Angles(-math.pi / 2, 0, 0)
			local v676 = CFrame.Angles(math.pi, 0, 0)
			local targetPoint42 = v655.sprite.spriteData.inAir and 0
			local l__Y__143 = v655.sprite.part.Size.Y
			local targetPoint44 = v675 * CFrame.new(0, -0.48 * l__Y__671, 0) * v676
			local targetPoint45 = false
			local l__magnitude__146 = po_2.magnitude
			local function targetPoint47()
				local v677 = create("Part")({
					BrickColor = BrickColor.new("Bright orange"), 
					Material = Enum.Material.Neon, 
					Anchored = true, 
					CanCollide = false, 
					TopSurface = Enum.SurfaceType.Smooth, 
					BottomSurface = Enum.SurfaceType.Smooth, 
					Shape = Enum.PartType.Ball, 
					Parent = workspace
				})
				--	local I_Really_Dont_Know1 = 0
				local targetPoint48 = v655.sprite.cf + Vector3.new(0, targetPoint42, 0)
				spawn(function()
					local l__Color__678 = BrickColor.new("Bright yellow").Color
					for v679 = 1, 10 do
						spawn(function()
							local v680 = math.random() * math.pi * 2
							local v681 = math.random() * math.pi / 2
							local v682 = {
								Color = l__Color__678, 
								Image = 879747500, 
								Lifetime = 0.7, 
								Size = 1, 
								Position = targetPoint48.p + v677.Size.Y / 2 * Vector3.new(math.cos(v680) * math.cos(v681), math.sin(v681), math.sin(v680) * math.cos(v681)), 
								Rotation = math.random() * 360
							}
							if math.random(2) ~= 1 then
								o = -1
							end
							v682.RotVelocity = 100-- * o
							v682.Acceleration = false
							function v682.OnUpdate(p425, p426)
								if p425 > 0.7 then
									p426.BillboardGui.ImageLabel.ImageTransparency = 0.4 + 2 * (p425 - 0.7)
								end
							end
							_p.Particles:new(v682)
						end)
						wait(0.1)
					end
				end)
				local targetPoint49 = math.max(7, l__Y__143 * 2)
				Tween(0.5, "easeOutCubic", function(p427)
					v655.sprite.offset = Vector3.new(0, targetPoint42, 0)
					local v683 = targetPoint49 * p427
					v677.Size = Vector3.new(v683, v683, v683)
					v677.CFrame = targetPoint48
				end)
				spawn(function()
					Tween(0.5, nil, function(p428)
						local v684 = targetPoint49 + 0.5 * p428
						v677.Size = Vector3.new(v684, v684, v684)
						v677.CFrame = targetPoint48
					end)
					Tween(0.5, nil, function(p429)
						local v685 = targetPoint49 + 0.5 + 4 * p429
						v677.Size = Vector3.new(v685, v685, v685)
						v677.CFrame = targetPoint48
					end)
				end)
				local l__CurrentCamera__686 = workspace.CurrentCamera
				delay(0.5, function()
					Utilities.FadeOut(0.5, Color3.new(1, 1, 1))
				end)
				local l__CFrame__150 = l__CurrentCamera__686.CFrame
				Tween(1, nil, function(p430)
					local v687 = math.random() * p430 * 0.5
					local v688 = math.random() * math.pi * 2
					l__CurrentCamera__686.CFrame = l__CFrame__150 * CFrame.new(v687 * math.cos(v688), v687 * math.sin(v688), 0)
				end)
				wait(0.3)
				v677:Remove()
				l__CurrentCamera__686.CFrame = l__CFrame__150
				v670:fire()
			end
			Tween(1, nil, function(p431, p432)
				local v689 = 70 * p432 * p432 - 2 + 5 * p432
				local v690 = targetPoint40 * v689 + Vector3.new(0, targetPoint41, 0)
				sprite_1.offset = v690
				v672.CFrame = v675 + v690
				v673.CFrame = targetPoint44 + v690
				local v691 = math.min(1, p432 * 3)
				v672.Transparency = 1 - 0.2 * v691
				v673.Transparency = 1 - 0.5 * v691
				if v689 > 2 then
					targetPoint38.CFrame = CFrame.new(po_1 + targetPoint40 * (v689 - 2))
				end
				if not targetPoint45 and l__magnitude__146 <= v689 then
					targetPoint45 = true
					spawn(targetPoint47)
				end
			end)
			po_3:Remove()
			v670:wait()
			targetPoint38:Remove()
			for v692, v693 in pairs(v665) do
				v693:Remove()
			end
			sprite_1.offset = Vector3.new()
			v655.offset = Vector3.new()
			Utilities.FadeIn(0.5)
			return true
		end,









		savagespinout = function(p433, p434, p435)
			local targetPoint51 = nil
			local v694 = p434[1]
			if not v694 then
				return true
			end
			local v695 = targetPoint(p433)
			local v696 = targetPoint(v694)
			local v697 = v696 - v695
			local l__CFrame__698 = v694.sprite.part.CFrame
			local v699 = l__CFrame__698 - l__CFrame__698.p
			local l__sprite__700 = p433.sprite
			local v701 = create("Part")({
				Anchored = true, 
				CanCollide = false, 
				CFrame = p435.CoordinateFrame2 + Vector3.new(0, -3, 0), 
				Parent = workspace,
				create("SpecialMesh")({
					MeshType = Enum.MeshType.FileMesh, 
					MeshId = "rbxassetid://928522767", 
					TextureId = "rbxassetid://928525574", 
					Scale = Vector3.new(0.02, 0.02, 0.02)
				})
			})
			local v702 = create("Part")({
				Anchored = true, 
				CanCollide = false, 
				CFrame = v701.CFrame, 
				Parent = workspace,
				create("SpecialMesh")({
					MeshType = Enum.MeshType.FileMesh, 
					MeshId = "rbxassetid://1290033", 
					Scale = Vector3.new(0.2, 0.2, 0.2)
				})
			})
			local targetPoint52 = Vector3.new()
			local targetPoint53 = v694.sprite.spriteData.inAir and 0
			spawn(function()
				Tween(0.78, nil, function(p436)
					targetPoint52 = Vector3.new(0, targetPoint53, 0)
					v694.sprite.offset = targetPoint52
				end)
			end)
			for v703 = 1, 15 do
				targetPoint51 = v695
				spawn(function()
					local v704 = v696 + v699 * Vector3.new((math.random() - 0.5) * v694.sprite.part.Size.X, (math.random() - 0.5) * v694.sprite.part.Size.Y, 0) + targetPoint52
					local l__magnitude__705 = (v704 - targetPoint51).magnitude
					local v706 = create("Part")({
						Anchored = true, 
						CanCollide = false, 
						BrickColor = BrickColor.new("Pearl"), 
						TopSurface = Enum.SurfaceType.Smooth, 
						BottomSurface = Enum.SurfaceType.Smooth, 
						Parent = workspace
					})
					local v707 = CFrame.new(targetPoint51, v704)
					local targetPoint54 = l__magnitude__705 + 2.6
					Tween(0.5, nil, function(p437)
						local v708 = targetPoint54 * p437
						if l__magnitude__705 < v708 then
							v706.Size = Vector3.new(0.05, 0.05, targetPoint54 - v708)
							v706.CFrame = v707 * CFrame.new(0, 0, -l__magnitude__705 - (targetPoint54 - v708) / 2)
							return
						end
						if v708 < 2.6 then
							v706.Size = Vector3.new(0.05, 0.05, v708)
							v706.CFrame = v707 * CFrame.new(0, 0, v708 / -2)
							return
						end
						v706.Size = Vector3.new(0.05, 0.05, 2.6)
						v706.CFrame = v707 * CFrame.new(0, 0, -v708 + 1)
					end)
					v706:Remove()
				end)
				wait(0.06)
			end
			v701.CFrame = v694.sprite.part.CFrame
			Tween(0.6, nil, function(p438)
				local v709 = 0.05 * p438
				v701.Mesh.Scale = Vector3.new(v709, v709, v709)
			end)
			local l__spriteLabel__155 = v694.sprite.animation.spriteLabel
			Tween(0.3, nil, function(p439)
				local v710 = 1 - p439 * 0.55
				l__spriteLabel__155.Size = UDim2.new(v710, 0, v710, 0)
				l__spriteLabel__155.Position = UDim2.new(0.5 - v710 / 2, 0, 0.5 - v710 / 2, 0)
			end)
			l__spriteLabel__155.Visible = false
			local l__Position__711 = v701.Position
			local v712 = l__Position__711 - targetPoint51
			local targetPoint56 = create("Part")({
				Anchored = true, 
				CanCollide = false, 
				BrickColor = BrickColor.new("Pearl"), 
				TopSurface = Enum.SurfaceType.Smooth, 
				BottomSurface = Enum.SurfaceType.Smooth, 
				Parent = workspace
			})
			local l__magnitude__157 = v712.magnitude
			local targetPoint58 = CFrame.new(targetPoint51, l__Position__711)
			Tween(0.4, nil, function(p440)
				targetPoint56.Size = Vector3.new(0.2, 0.2, l__magnitude__157 * p440)
				targetPoint56.CFrame = targetPoint58 + v712 * p440 * 0.5
			end)
			local v713 = CFrame.new(l__Position__711, l__Position__711 + v712):inverse() * v701.CFrame
			spawn(function()
				local v714 = {}
				for v715 = 1, 5 do
					v714[v715] = targetPoint56:Clone()
					v714[v715].Parent = workspace
				end
				v714[6] = targetPoint56
				local function targetPoint59(p441)
					local l__Position__716 = v701.Position
					local l__magnitude__717 = (l__Position__716 - targetPoint51).magnitude
					local v718 = targetPoint51
					local v719 = CFrame.new(targetPoint51, l__Position__716)
					local l__upVector__720 = v719.upVector
					local l__lookVector__721 = v719.lookVector
					for v722, v723 in pairs(v714) do
						local v724 = targetPoint51 + l__lookVector__721 * l__magnitude__717 / 6 * v722 + l__upVector__720 * p441 * math.sin(math.pi / 6 * v722)
						v723.Size = Vector3.new(0.2, 0.2, (v718 - v724).magnitude)
						v723.CFrame = CFrame.new((v718 + v724) / 2, v724)
						v718 = v724
					end
				end
				Tween(0.5, nil, function(p442)
					targetPoint59(p442)
				end)
				Tween(0.7, nil, function(p443)
					targetPoint59(1 - 2 * p443)
				end)
				Tween(0.4, nil, function(p444)
					targetPoint59(-1 + p444)
				end)
				for v725, v726 in pairs(v714) do
					v726:Remove()
				end
			end)
			wait(0.4)
			Tween(0.8, "easeInOutQuad", function(p445)
				v701.CFrame = targetPoint58 * CFrame.Angles(1.2 * p445, 0, 0) * CFrame.new(0, 0, -l__magnitude__157) * v713
			end)
			Tween(0.4, "easeInQuad", function(p446)
				v701.CFrame = targetPoint58 * CFrame.Angles(1.2 * (1 - p446), 0, 0) * CFrame.new(0, 0, -l__magnitude__157) * v713
			end)
			local v727 = create("Model")({
				Parent = workspace
			})
			for v728 = 1, 12 do
				local v729 = create("Part")({
					Anchored = true, 
					CanCollide = false, 
					BrickColor = BrickColor.new("Dirt brown"), 
					CFrame = p435.CoordinateFrame2 * CFrame.Angles(math.random() * 6, math.random() * 6, math.random() * 6) + Vector3.new((1.2 + 0.3 * math.random()) * math.sin(0.53 * v728), -0.3, (1.2 + 0.3 * math.random()) * math.cos(0.53 * v728)), 
					Parent = v727,
					create("SpecialMesh")({
						MeshType = Enum.MeshType.FileMesh, 
						MeshId = "rbxassetid://1290033", 
						Scale = Vector3.new(0.8, 0.8, 0.8)
					})
				})
			end
			spawn(function()
				local l__CFrame__730 = workspace.CurrentCamera.CFrame
				Tween(1, nil, function(p447)
					local v731 = p447 * 10 % 1
					if v731 < 0.25 then
						return
					end
					if v731 < 0.75 then
						z2 = -1 + (v731 - 0.25) * 4
						return
					end
					z2 = 1 - (v731 - 0.75) * 4
				end)
			end)
			local targetPoint60 = v697 * Vector3.new(1, 0, 1).unit
			local targetPoint61 = l__sprite__700.spriteData.inAir and 0
			Tween(0.6, nil, function(p448)
				l__sprite__700.offset = targetPoint60 * -2 + Vector3.new(0, --[[math.sin(math.pi),]] targetPoint61, 0)
			end)
			local targetPoint62 = Utilities.Signal()
			local targetPoint63 = false
			local l__magnitude__164 = v697.magnitude
			local function targetPoint65()
				targetPoint62:fire()
				local v732 = CFrame.new(v701.Position, v701.Position + targetPoint60:Cross(Vector3.new(0, 1, 0)))
				local targetPoint66 = v732:inverse() * v701.CFrame
				Tween(0.6, nil, function(p449)
					if not v701.Parent then
						return false
					end
					v701.CFrame = v732 * CFrame.Angles(0, 0, 10 * p449) * targetPoint66 + targetPoint60 * p449 * 30 + Vector3.new(0, p449 * 12, 0)
				end)
			end
			spawn(function()
				Tween(1, nil, function(p450, p451)
					if not v701.Parent then
						return false
					end
					local v733 = 70 * p451 * p451 - 2 + 5 * p451
					l__sprite__700.offset = targetPoint60 * v733 + Vector3.new(0, targetPoint61, 0)
					if not targetPoint63 and l__magnitude__164 <= v733 then
						targetPoint63 = true
						spawn(targetPoint65)
					end
				end)
			end)
			targetPoint62:wait()
			Utilities.FadeOut(0.5, Color3.new(1, 1, 1))
			v727:Remove()
			v701:Remove()
			l__spriteLabel__155.Size = UDim2.new(1, 0, 1, 0)
			l__spriteLabel__155.Position = UDim2.new(0, 0, 0, 0)
			l__spriteLabel__155.Visible = true
			l__sprite__700.offset = Vector3.new()
			v694.sprite.offset = Vector3.new()
			Utilities.FadeIn(0.5)
			return true
		end,









		bloomdoom = function(p399, p400, p401)
			local targetPoint16 = nil
			local targetPoint17 = nil
			local v562 = p400[1]
			if not v562 then
				return
			end
			local l__sprite__563 = p399.sprite
			local v564 = targetPoint(p399, 2)
			local v565 = targetPoint(v562, 0.5)
			local v566 = create("Part")({
				Anchored = true, 
				CanCollide = false, 
				CFrame = p401.CoordinateFrame2 + Vector3.new(0, -3, 0), 
				Parent = workspace,
				create("SpecialMesh")({
					MeshType = Enum.MeshType.FileMesh, 
					MeshId = "rbxassetid://20329976", 
					Scale = Vector3.new(0.2, 0.2, 0.2)
				})
			})
			local l__Position__567 = l__sprite__563.part.Position
			local v568 = l__sprite__563.part.Size.Y / 2
			local v569 = {}
			for v570 = 1, 6 do
				local v571 = create("Part")({
					Transparency = 1, 
					Anchored = true, 
					CanCollide = false, 
					Size = Vector3.new(1, 1, 1), 
					CFrame = CFrame.new(l__Position__567 + Vector3.new(1.5 * math.cos(math.pi / 3 * v570), v568 * 0.5, 1.5 * math.sin(math.pi / 3 * v570)), l__Position__567 + Vector3.new(0, v568 * 0.5, 0)), 
					Parent = workspace
				})
				create("Trail")({
					Attachment0 = create("Attachment")({
						CFrame = CFrame.new(-0.3, 0.3, -0.3), 
						Parent = v571
					}), 
					Attachment1 = create("Attachment")({
						CFrame = CFrame.new(0.3, -0.3, 0.3), 
						Parent = v571
					}), 
					Color = ColorSequence.new(Color3.fromRGB(58, 173, 98), Color3.fromRGB(154, 212, 174)), 
					Transparency = NumberSequence.new(0.5, 1), 
					Lifetime = 1, 
					Parent = v571
				})
				v569[v570] = v571
			end
			spawn(function()
				Tween(1, nil, function(p402)
					for v572, v573 in pairs(v569) do
						local v574 = math.pi / 3 * v572 + 5 * p402
						local v575 = 1.5 + math.sin(p402 * math.pi)
						local v576 = l__Position__567 + Vector3.new(v575 * math.cos(v574), v568 * (0.5 - p402), v575 * math.sin(v574))
						v573.CFrame = CFrame.new(v576, Vector3.new(l__Position__567.x, v576.Y, l__Position__567.Z))
					end
				end)
			end)
			wait(0.3)
			local v577 = Instance.new("Model", workspace)
			local v578 = l__sprite__563.cf + Vector3.new(0, (l__sprite__563.spriteData.inAir and 0), 0)
			local v579 = v562.sprite.cf + Vector3.new(0, (v562.sprite.spriteData.inAir and 0), 0)
			local v580 = CFrame.new(v578.p, v579.p)
			local v581 = { "Alder", "Carnation pink", "Persimmon", "Daisy orange", "Pastel Blue" }
			while true do
				local targetPoint18 = nil
				for v582 = 1, 2 do
					targetPoint16 = v580
					targetPoint18 = 11
					targetPoint17 = v577
					spawn(function()
						local v583 = _p.storage.Models.Misc.Flower:Clone()
						local l__Main__584 = v583.Main
						local v585 = BrickColor.new(v581[math.random(#v581)])
						for v586, v587 in pairs(v583:GetChildren()) do
							if v587:IsA("BasePart") and v587 ~= l__Main__584 then
								v587.BrickColor = v585
							end
						end
						Utilities.MoveModel(l__Main__584, targetPoint16 * CFrame.Angles(0, -0.7 + 2.6 * math.random(), 0) * CFrame.new(0, 0, targetPoint18 * 1.2 + math.random()) * CFrame.Angles(0, math.random(), 0) + Vector3.new(0, 0.05, 0))
						v583.Parent = targetPoint17
						local targetPoint19 = 1
						Tween(0.5, nil, function(p403)
							local v588 = 0.2 + 0.4 * p403
							Utilities.ScaleModel(l__Main__584, v588 / targetPoint19)
							targetPoint19 = v588
						end)
						v583:Remove()
						l__Main__584:Remove()
					end)
				end
				wait(0.1)
				if not (targetPoint18 < 10) then
					break
				end		
			end
			local targetPoint20 = create("Part")({
				BrickColor = BrickColor.new("Bright green"), 
				Material = Enum.Material.Neon, 
				Anchored = true, 
				CanCollide = false, 
				Shape = Enum.PartType.Cylinder, 
				Size = Vector3.new(15, 3, 3), 
				Parent = workspace
			})
			local targetPoint21 = CFrame.Angles(0, 0, math.pi / 2)
			Tween(1, nil, function(p404)
				targetPoint20.CFrame = targetPoint16 * targetPoint21 + Vector3.new(0, p404 * 30 - 15, 0)
			end)
			wait(1)
			targetPoint20.Size = Vector3.new(15, 6, 6)
			Tween(0.5, nil, function(p405)
				targetPoint20.CFrame = v579 * targetPoint21 + Vector3.new(0, 22.5 - 15 * p405, 0)
			end)
			local v589 = _p.storage.Models.Misc.Mega.InnerEnergy:Clone()
			Utilities.ScaleModel(v589.Hinge, 0.35)
			local v590 = v589.Hinge.CFrame * CFrame.Angles(0, 0, math.pi / 2):inverse() * v589.EnergyPart.CFrame
			local v591 = _p.storage.Models.Misc.Mega.OuterEnergy:Clone()
			Utilities.ScaleModel(v591.Hinge, 0.35)
			v589.EnergyPart.BrickColor = BrickColor.new("Medium green")
			v591.EnergyPart.BrickColor = BrickColor.new("Sand green")
			v589.Parent = workspace
			v591.Parent = workspace
			local l__CurrentCamera__592 = workspace.CurrentCamera
			local l__CFrame__122 = l__CurrentCamera__592.CFrame
			local targetPoint23 = Vector3.new(0, -1.5, 0)
			local targetPoint24 = v591.Hinge.CFrame * CFrame.Angles(0, 0, math.pi / 2):inverse() * v591.EnergyPart.CFrame
			spawn(function()
				Tween(3, nil, function(p406)
					local v593 = math.random() * 0.5
					local v594 = math.random() * math.pi * 2
					l__CurrentCamera__592.CFrame = l__CFrame__122 * CFrame.new(v593 * math.cos(v594), v593 * math.sin(v594), 0)
					v589.EnergyPart.CFrame = v579 * CFrame.Angles(0, 10 * p406, 0) * v590 + targetPoint23
					v591.EnergyPart.CFrame = v579 * CFrame.Angles(0, -10 * p406, 0) * targetPoint24 + targetPoint23
				end)
			end)
			wait(2.5)
			Utilities.FadeOut(0.5, Color3.new(1, 1, 1))
			wait(0.3)
			l__CurrentCamera__592.CFrame = l__CFrame__122
			targetPoint17:Remove()
			for v595, v596 in pairs(v569) do
				v596:Remove()
			end
			v566:Remove()
			v589:Remove()
			v591:Remove()
			targetPoint20:Remove()
			Utilities.FadeIn(0.5)
			return true
		end,




		devastatingdrake = function(p407, p408, p409)
			local v597 = p408[1]
			if not v597 then
				return true
			end
			local v598 = targetPoint(v597) - targetPoint(p407)
			local l__CFrame__599 = v597.sprite.part.CFrame
			local v600 = l__CFrame__599 - l__CFrame__599.p
			local l__sprite__601 = p407.sprite
			if l__sprite__601.spriteData.inAir then

			end
			local v602 = v597.sprite.spriteData.inAir and 0
			_p.DataManager:preload("Image", 148101819, 879747500)
			local v603 = Instance.new("Model", workspace)
			local v604 = {}
			for v605, v606 in pairs({ { 94257616, "Head" }, { 94257586, "Body" }, { 94257664, "RWing" }, { 94257635, "LWing" } }) do
				v604[v606[2]] = create("Part")({
					Anchored = true, 
					CanCollide = false, 
					CFrame = p409.CoordinateFrame2 + Vector3.new(0, -4, 0), 
					Parent = v603,
					create("SpecialMesh")({
						MeshType = Enum.MeshType.FileMesh, 
						MeshId = "rbxassetid://" .. v606[1], 
						TextureId = "rbxassetid://94257533", 
						Scale = Vector3.new(1.2, 1.2, 1.2), 
						VertexColor = Vector3.new(1, 0.5, 1)
					})
				})
			end
			local v607 = CFrame.new(0, -0.272, 1, 1, 0, 0, 0, 0.928, 0.372, 0, -0.372, 0.928)
			local v608 = CFrame.new(0, 0.686, -1.786, 1, 0, 0, 0, 0.931, -0.364, 0, 0.364, 0.931)
			local v609 = CFrame.new(0.164, 0.427, -0.919, 1, 0, 0, 0, 0.941, -0.339, 0, 0.339, 0.941)
			local v610 = CFrame.new(-0.164, 0.427, -0.919, 1, 0, 0, 0, 0.941, -0.339, 0, 0.339, 0.941)
			local v611 = CFrame.new(1.314, 0.587, -0.25, 1, 0, 0, 0, 0.819, 0.574, 0, -0.574, 0.819)
			local v612 = CFrame.new(-1.314, 0.587, -0.25, 1, 0, 0, 0, 0.819, 0.574, 0, -0.574, 0.819)
			local v613 = {}
			for v614 = 1, 6 do
				local v615 = create("Part")({
					Transparency = 1, 
					Anchored = true, 
					CanCollide = false, 
					Size = Vector3.new(1, 1, 1), 
					Parent = workspace
				})
				create("Trail")({
					Attachment0 = create("Attachment")({
						CFrame = CFrame.new(-0.3, 0.3, -0.3), 
						Parent = v615
					}), 
					Attachment1 = create("Attachment")({
						CFrame = CFrame.new(0.3, -0.3, 0.3), 
						Parent = v615
					}), 
					Color = ColorSequence.new(Color3.fromRGB(174, 59, 197), Color3.fromRGB(252, 96, 255)), 
					Transparency = NumberSequence.new(0.5, 1), 
					Lifetime = 1, 
					Parent = v615
				})
				v613[v614] = v615
			end
			local l__Position__125 = l__sprite__601.part.Position
			local l__Y__126 = l__sprite__601.part.Size.Y
			Tween(1, nil, function(p410)
				for v616, v617 in pairs(v613) do
					local v618 = math.pi / 3 * v616 + 5 * p410
					local v619 = l__Position__125 + Vector3.new(2 * math.cos(v618), l__Y__126 * (0.5 - p410), 2 * math.sin(v618))
					v617.CFrame = CFrame.new(v619, Vector3.new(l__Position__125.x, v619.Y, l__Position__125.Z))
				end
			end)
			create("ParticleEmitter")({
				Texture = "rbxassetid://148101819", 
				Color = ColorSequence.new(Color3.fromRGB(194, 135, 216)), 
				Transparency = NumberSequence.new(0.5, 1), 
				Size = NumberSequence.new(0.25), 
				Acceleration = Vector3.new(), 
				LockedToPart = false, 
				Lifetime = NumberRange.new(1), 
				Rate = 50, 
				Rotation = NumberRange.new(0, 360), 
				Speed = NumberRange.new(0), 
				Parent = v604.Body
			})
			local v620 = CFrame.new()
			local v621 = CFrame.new()
			local v622 = CFrame.new()
			local v623 = (l__sprite__601.part.Position - v597.sprite.part.Position) * Vector3.new(1, 0, 1).unit
			local v624 = Vector3.new(0, -1, 0)
			local v625 = v623:Cross(v624)
			local l__Position__626 = l__sprite__601.part.Position
			local targetPoint27 = v620
			local targetPoint28 = v621
			local targetPoint29 = v622
			local targetPoint30 = CFrame.new(l__Position__626.X, l__Position__626.Y, l__Position__626.Z, v625.X, v623.X, v624.X, v625.Y, v623.Y, v624.Y, v625.Z, v623.Z, v624.Z)
			local function targetPoint31()
				local v627 = targetPoint27 * v607
				v604.Body.CFrame = v627
				v604.Head.CFrame = v627 * v608
				v604.RWing.CFrame = v627 * v609 * targetPoint28 * v611
				v604.LWing.CFrame = v627 * v610 * targetPoint29 * v612
			end
			Tween(0.7, nil, function(p411)
				targetPoint27 = targetPoint30 + Vector3.new(0, 10 * p411, 0)
				targetPoint31()
			end)
			wait(0.5)
			local v628 = (l__sprite__601.part.Position + v597.sprite.part.Position) / 2
			local v629 = v628 + Vector3.new(0, p409.CoordinateFrame2.y + 2.5 - v628.Y, 0)
			local v630 = CFrame.Angles(0, -1.4, 0) * CFrame.Angles(-1.1, 0, 0)
			local v631 = CFrame.Angles(0, 1.4, 0) * CFrame.Angles(-1.1, 0, 0)
			targetPoint28 = v630
			targetPoint29 = v631
			local targetPoint32 = select(2, Utilities.lerpCFrame(v630, CFrame.new()))
			local targetPoint33 = select(2, Utilities.lerpCFrame(v631, CFrame.new()))
			local targetPoint34 = Utilities.Timing.easeOutCubic(0.2)
			Tween(0.9, nil, function(p412)
				local v632 = math.pi * p412
				local v633 = math.sin(v632)
				local v634 = math.cos(v632)
				local v635 = v629 - v625 * (8 * v634 - 4) + Vector3.new(0, 6 * (1 - v633), 0)
				local v636 = v625 * v633 + Vector3.new(0, -v634, 0).unit
				local v637 = v623:Cross(v636)
				targetPoint27 = CFrame.new(v635.X, v635.Y, v635.Z, v623.X, v637.X, -v636.X, v623.Y, v637.Y, -v636.Y, v623.Z, v637.Z, -v636.Z)
				if p412 > 0.3 then
					if p412 < 0.6 then
						local v638 = (p412 - 0.3) / 0.3
						targetPoint28 = targetPoint32(v638)
						targetPoint29 = targetPoint33(v638)
					elseif p412 < 0.8 then
						local v639 = 1 - targetPoint34(p412 - 0.6)
						targetPoint28 = targetPoint32(v639)
						targetPoint29 = targetPoint33(v639)
					else
						targetPoint28 = v630
						targetPoint29 = v631
					end
				end
				targetPoint31()
			end)
			targetPoint28 = v630
			targetPoint29 = v631
			wait(0.5)
			local l__Position__640 = v597.sprite.part.Position
			targetPoint30 = CFrame.new(l__Position__640.X, l__Position__640.Y, l__Position__640.Z, v625.X, -v623.X, -v624.X, v625.Y, -v623.Y, -v624.Y, v625.Z, -v623.Z, -v624.Z)
			spawn(function()
				Tween(0.6, nil, function(p413)
					targetPoint27 = targetPoint30 * CFrame.Angles(0, 0, 7 * p413) + Vector3.new(0, 10 - 16 * p413, 0)
					targetPoint31()
				end)
			end)
			wait(0.5)
			local v641 = create("Part")({
				BrickColor = BrickColor.new("Alder"), 
				Material = Enum.Material.Neon, 
				Anchored = true, 
				CanCollide = false, 
				TopSurface = Enum.SurfaceType.Smooth, 
				BottomSurface = Enum.SurfaceType.Smooth, 
				Shape = Enum.PartType.Ball, 
				Parent = workspace
			})
			local targetPoint35 = v597.sprite.cf + Vector3.new(0, v602, 0)
			spawn(function()
				local l__Color__642 = BrickColor.new("Lilac").Color
				for v643 = 1, 10 do
					spawn(function()
						local v644 = math.random() * math.pi * 2
						local v645 = math.random() * math.pi / 2
						local v646 = {
							Color = l__Color__642, 
							Image = 879747500, 
							Lifetime = 0.7, 
							Size = 1, 
							Position = targetPoint35.p + v641.Size.Y / 2 * Vector3.new(math.cos(v644) * math.cos(v645), math.sin(v645), math.sin(v644) * math.cos(v645)), 
							Rotation = math.random() * 360
						}
						if math.random(2) ~= 1 then
							val = -1
						end
						v646.RotVelocity = 100 --* val
						v646.Acceleration = false
						function v646.OnUpdate(p414, p415)
							if p414 > 0.7 then
								p415.BillboardGui.ImageLabel.ImageTransparency = 0.4 + 2 * (p414 - 0.7)
							end
						end
						_p.Particles:new(v646)
					end)
					wait(0.1)
				end
			end)
			local targetPoint36 = math.max(7, v597.sprite.part.Size.Y * 2)
			Tween(0.5, "easeOutCubic", function(p416)
				v597.sprite.offset = Vector3.new(0, v602, 0)
				local v647 = targetPoint36 * p416
				v641.Size = Vector3.new(v647, v647, v647)
				v641.CFrame = targetPoint35
			end)
			spawn(function()
				Tween(0.5, nil, function(p417)
					local v648 = targetPoint36 + 0.5 * p417
					v641.Size = Vector3.new(v648, v648, v648)
					v641.CFrame = targetPoint35
				end)
				Tween(0.5, nil, function(p418)
					local v649 = targetPoint36 + 0.5 + 4 * p418
					v641.Size = Vector3.new(v649, v649, v649)
					v641.CFrame = targetPoint35
				end)
			end)
			local l__CurrentCamera__650 = workspace.CurrentCamera
			delay(0.5, function()
				Utilities.FadeOut(0.5, Color3.new(1, 1, 1))
			end)
			local l__CFrame__137 = l__CurrentCamera__650.CFrame
			Tween(1, nil, function(p419)
				local v651 = math.random() * p419 * 0.5
				local v652 = math.random() * math.pi * 2
				l__CurrentCamera__650.CFrame = l__CFrame__137 * CFrame.new(v651 * math.cos(v652), v651 * math.sin(v652), 0)
			end)
			wait(0.3)
			v641:Remove()
			l__CurrentCamera__650.CFrame = l__CFrame__137
			v603:Remove()
			for v653, v654 in pairs(v613) do
				v654:Remove()
			end
			Utilities.FadeIn(0.5)
			return true
		end,
		hydrovortex = function (pokemon, targets, move)
			local target = targets[1];
			if not target then
				return;
			end;
			local sprite = pokemon.sprite
			local from = targetPoint(pokemon, 2)
			local to = targetPoint(target, 0.5)
			local pos1 = target.sprite.spriteData.inAir or 0
			local model = Instance.new("Model", workspace)
			_p.DataManager:preload("Image", 650846795)
			for ab, ba in pairs({ 165709404, 212966179, 1051557 }) do
				local part1 = create("Part")({
					Anchored = true, 
					CanCollide = false, 
					CFrame = move.CoordinateFrame2 + Vector3.new(0, -3, 0), 
					Parent = model,
					create("SpecialMesh")({
						MeshType = Enum.MeshType.FileMesh, 
						MeshId = "rbxassetid://" .. ba, 
						Scale = Vector3.new(0.2, 0.2, 0.2)
					})
				});
			end;
			local cfr = target.sprite.part.CFrame
			local clr = BrickColor.new("Pastel Blue").Color
			local dif = to - from
			local cfp = cfr - cfr.p
			local function gui(a1)
				local part2 = create("Part")({
					Transparency = 1,
					Anchored = true, 
					CanCollide = false, 
					Parent = workspace
				})
				local bill = create("BillboardGui")({
					Parent = part2
				})
				return part2, bill, create("ImageLabel")({
					BackgroundTransparency = 1, 
					Image = "rbxassetid://".. a1,
					ZIndex = 2, 
					Parent = bill
				})
			end
			spawn(function()
				for i = 1, 50 do
					spawn(function()
						local bc, cb = gui(650846795, 1, Color3.fromHSV((210 + math.random() * 20) / 360, 0.8, 0.75))
						Tween(0.4, nil, function(a)
							bc.CFrame = CFrame.new(from + dif * a)
							cb.Size = UDim2.new(1 + 2 * a, 0, 1 + 2 * a, 0)
						end)
						bc:Remove()
						for n = 1, 2 do
							local rdom = math.random() * 360;
							_p.Particles:new({
								Color = clr, 
								Image = 650846795, 
								Lifetime = 0.5, 
								Size = 1, 
								Position = to, 
								Velocity = 5 * (cfp * Vector3.new(math.cos(math.rad(rdom)), math.sin(math.rad(rdom)), 0)), 
								Acceleration = false, 
								OnUpdate = function(ac, ca)
									ca.BillboardGui.ImageLabel.ImageTransparency = 0.3 + 0.7 * ac
								end
							})
						end
					end)
					wait(0.05)
				end
			end)
			wait(1.7)
			local part3 = create("Part")({
				BrickColor = BrickColor.new("Bright blue"), 
				Material = Enum.Material.Foil, 
				TopSurface = Enum.SurfaceType.Smooth, 
				BottomSurface = Enum.SurfaceType.Smooth, 
				CanCollide = false, 
				Anchored = true, 
				Size = Vector3.new(250, 50, 250), 
				Parent = workspace
			})
			local cfr2 = workspace.CurrentCamera.CFrame
			local cfr3 = CFrame.new((move.CoordinateFrame1.p + move.CoordinateFrame2.p) / 2) + Vector3.new(0, -10, 0)
			local v3c = Vector3.new(0, cfr2.y - cfr3.Y + 3, 0)
			local frame = create("Frame")({
				BorderSizePixel = 0, 
				BackgroundTransparency = 0.6, 
				BackgroundColor3 = part3.BrickColor.Color, 
				Size = UDim2.new(1, 0, 1, 36), 
				ZIndex = 10, 
				Parent = Utilities.frontGui
			});
			local view = cfr2.upVector.Y * 0.5 * math.tan(math.rad(workspace.CurrentCamera.FieldOfView) / 2)
			local v1 = cfr2.y + cfr2.lookVector.Y * 0.5 + view
			local v2 = view * 2
			Tween(1.6, nil, function(b)
				local camera = cfr3 + v3c * b
				part3.CFrame = camera + Vector3.new(0, -25, 0)
				local cam = math.max(0, (v1 - camera.y) / v2)
				frame.Position = UDim2.new(0, 0, cam, -36 * (1 - cam))
			end)
			if pos1 > 0 then
				Tween(1, nil, function(c)
					target.sprite.offset = Vector3.new(0, -pos1 * c, 0)
				end)
			end
			wait(0.5)
			local unt = dif * Vector3.new(1, 0, 1).unit
			local sp = sprite.spriteData.inAir or 0
			Tween(0.6, nil, function(c)
				sprite.offset = unt * -2 * c + Vector3.new(0, math.sin(c * math.pi) - sp * c, 0)
			end)
			local signal = Utilities.Signal()
			local y = sprite.part.Size.Y
			local part4 = create("Part")({
				BrickColor = BrickColor.new("Bright blue"), 
				Anchored = true, 
				CanCollide = false, 
				Size = Vector3.new(1, 1, 1), 
				Parent = workspace,
				create("SpecialMesh")({
					MeshType = Enum.MeshType.FileMesh, 
					MeshId = "rbxassetid://212966179", 
					Scale = Vector3.new(1.1, 1.8, 1.1) * y
				})
			})
			local part5 = create("Part")({
				BrickColor = BrickColor.new("Bright blue"), 
				Transparency = 0.5, 
				Anchored = true, 
				CanCollide = false, 
				Size = Vector3.new(1, 1, 1), 
				Parent = workspace,
				create("SpecialMesh")({
					MeshType = Enum.MeshType.FileMesh, 
					MeshId = "rbxassetid://165709404", 
					Scale = Vector3.new(2, 2, 2) * y
				})
			})
			local sf = sprite.cf.p + Vector3.new(0, y / 2, 0)
			local angle = CFrame.new(sf, sf + unt) * CFrame.Angles(-math.pi / 2, 0, 0)
			local an = angle * CFrame.new(0, -0.48 * y, 0) * CFrame.Angles(math.pi, 0, 0)
			local shift = false
			local magn = dif.magnitude
			local function storm()
				local part6 = create("Part")({
					BrickColor = BrickColor.new("Storm blue"), 
					Anchored = true, 
					CanCollide = false, 
					Size = Vector3.new(1, 1, 1), 
					Parent = workspace,
					create("SpecialMesh")({
						MeshType = Enum.MeshType.FileMesh, 
						MeshId = "rbxassetid://1051557", 
						Scale = Vector3.new(4, 4, 4)
					})
				})
				local part7 = part6:Clone()
				part7.Parent = workspace;
				local look = target.sprite.cf + Vector3.new(0, 3 - pos1, 0) + workspace.CurrentCamera.CFrame.lookVector * -0.3;
				Utilities.Tween(4, nil, function(o, p)
					if p < 0.7 then
						part6.Transparency = math.max(0, 1 - 2 * p);
						part7.Transparency = part6.Transparency;
					elseif p > 3 then
						part6.Transparency = p - 3;
						part7.Transparency = part6.Transparency;
					end;
					part6.CFrame = look * CFrame.Angles(0, -5 * p, 0);
					part7.CFrame = look * CFrame.Angles(0, -5 * p + 3.14, 0);
					target.sprite.offset = Vector3.new(0, 1 - math.cos(p * math.pi * 2) - pos1, 0);
					target.sprite.animation.spriteLabel.Rotation = 360 * p * 3;
				end)
				part6:Remove()
				part7:Remove()
				signal:fire()
			end;
			Tween(1, nil, function(q, r)
				local u1 = 70 * r * r - 2 + 5 * r
				local u2 = unt * u1 + Vector3.new(0, -sp, 0)
				sprite.offset = u2
				part4.CFrame = angle + u2
				part5.CFrame = an + u2
				local cal = math.min(1, r * 3)
				part4.Transparency = 1 - 0.2 * cal
				part5.Transparency = 1 - 0.5 * cal
				if not shift and magn <= u1 then
					shift = true
					spawn(storm)
				end
			end)
			part4:Remove()
			part5:Remove()
			signal:wait()
			model:Remove()
			Tween(2, nil, function(f)
				local f1 = cfr3 + v3c * (1 - f)
				part3.CFrame = f1 + Vector3.new(0, -25, 0)
				local f2 = math.max(0, (v1 - f1.y) / v2)
				frame.Position = UDim2.new(0, 0, f2, -36 * (1 - f2))
				sprite.offset = Vector3.new(0, math.max(0, f1.y - sprite.cf.y), 0);
			end)
			part3:Remove()
			frame:Remove()
			if pos1 > 0 then
				spawn(function()
					Tween(0.5, nil, function(g)
						target.sprite.offset = Vector3.new(0, -pos1 * (1 - g), 0);
					end)
				end)
			end
			return true
		end,
		darkpulse = function(pokemon, targets)
			local sprite = pokemon.sprite
			for i = 1, 3 do
				spawn(function()
					local dark = create 'Part' {
						BrickColor = BrickColor.new("Black"), 
						Transparency = 0.5, 
						Anchored = true, 
						CanCollide = false, 
						Size = Vector3.new(.1, .1, .1),
						Parent = workspace
					}
					dark.CFrame = pokemon.sprite.part.CFrame * CFrame.Angles(math.pi / 2, 0, 0);
					local pulse =  create 'SpecialMesh' {
						MeshType = Enum.MeshType.FileMesh, 
						MeshId = "rbxassetid://3270017", 
						Parent = dark
					}
					Tween(0.5, nil, function(a)
						local c = a * 25
						pulse.Scale = Vector3.new(c, c, 1);
						if a > 0.75 then
							dark.Transparency = 0.5 + 0.5 * ((a - 0.75) * 4)
						end
					end);
					dark:Remove()
				end);
				wait(0.1)
			end;
			wait(0.25)
			return true
		end;
		psychic = function(p333, p334)
			local v476 = p334[1];
			if not v476 then
				return;
			end;
			local v477 = targetPoint(p333);
			local v478 = targetPoint(v476);
			local v479 = v478 - v477;
			for v480 = 1, 3 do
				spawn(function()
					local v481 = create("Part")({
						BrickColor = BrickColor.new("Pink"), 
						Reflectance = 0.5, 
						Anchored = true, 
						CanCollide = false, 
						Size = Vector3.new(1, 1, 1), 
						Parent = workspace
					});
					local u151 = create("SpecialMesh")({
						MeshType = Enum.MeshType.FileMesh, 
						MeshId = "rbxassetid://3270017", 
						Parent = v481
					});
					Tween(0.8, nil, function(p335)
						v481.CFrame = CFrame.new(v477, v478) + v479 * p335;
						local v482 = 1.3 + 0.3 * math.sin(p335 * 8);
						u151.Scale = Vector3.new(v482, v482, v482);
					end);
					v481:Remove();
				end);
				wait(0.2);
			end;
			wait(0.6);
			return true;
		end;
		subzeroslammer = function(p37, p38, p39)
			local u36 = nil
			local v101 = p38[1]
			if not v101 then
				return true
			end
			local v102 = targetPoint(p37)
			local v103 = targetPoint(v101)
			local v104 = v103 - v102
			local l__CFrame__105 = v101.sprite.part.CFrame
			local v106 = l__CFrame__105 - l__CFrame__105.p
			local l__sprite__107 = p37.sprite
			local v108 = create("Part")({
				Anchored = true, 
				CanCollide = false, 
				CFrame = p39.CoordinateFrame2 + Vector3.new(0, -3, 0), 
				Parent = workspace,
				create("SpecialMesh")({
					MeshType = Enum.MeshType.FileMesh, 
					MeshId = "rbxassetid://818652045", 
					Scale = Vector3.new(0.05, 0.05, 0.05)
				})
			})
			local l__Lighting__109 = game:GetService("Lighting")
			local l__Ambient__37 = l__Lighting__109.Ambient
			local l__OutdoorAmbient__38 = l__Lighting__109.OutdoorAmbient
			local l__ColorShift_Bottom__39 = l__Lighting__109.ColorShift_Bottom
			local l__ColorShift_Top__40 = l__Lighting__109.ColorShift_Top
			local l__FogEnd__41 = l__Lighting__109.FogEnd
			local l__FogStart__42 = l__Lighting__109.FogStart
			spawn(function()
				local l__lerpColor3__110 = Utilities.lerpColor3
				l__Lighting__109.FogColor = Color3.fromRGB(85, 125, 139)
				local u43 = l__lerpColor3__110(l__Ambient__37, Color3.fromRGB(34, 49, 84))
				local u44 = l__lerpColor3__110(l__OutdoorAmbient__38, Color3.fromRGB(65, 87, 104))
				local u45 = l__lerpColor3__110(l__ColorShift_Bottom__39, Color3.fromRGB(118, 167, 241))
				local u46 = l__lerpColor3__110(l__ColorShift_Top__40, Color3.fromRGB(196, 225, 255))
				local u47 = 200 - l__FogEnd__41
				local u48 = 0 - l__FogStart__42
				Tween(0.8999999999999999, nil, function(p40)
					l__Lighting__109.Ambient = u43(p40)
					l__Lighting__109.OutdoorAmbient = u44(p40)
					l__Lighting__109.ColorShift_Bottom = u45(p40)
					l__Lighting__109.ColorShift_Top = u46(p40)
					l__Lighting__109.FogEnd = l__FogEnd__41 + u47 * p40
					l__Lighting__109.FogStart = l__FogStart__42 + u48 * p40
				end)
			end)
			local l__CurrentCamera__111 = workspace.CurrentCamera
			local v112 = l__CurrentCamera__111:WorldToScreenPoint(v102)
			local v113 = l__CurrentCamera__111:WorldToScreenPoint(v103)
			local v114 = math.deg(math.atan2(v113.Y - v112.Y, v113.X - v112.X)) + 90
			for v115 = 1, 30 do
				local v116 = math.random() * 0.5 + 0.75
				local v117 = Color3.fromHSV(0.55 + 0.08 * math.random(), 0.5 + math.random() * 0.25, 1)
				local v118 = {
					Color = v117, 
					Image = 644323665, 
					Lifetime = 0.4, 
					Rotation = v114
				}
				u36 = v104
				local u49 = v106 * (0.25 * Vector3.new(math.random() - 0.5, math.random() - 0.5, 0))
				function v118.OnUpdate(p41, p42)
					p42.CFrame = CFrame.new(v102 + u36 * p41 + u49)
					local v119 = (p41 < 0.2 and p41 * 5 or 1) * v116
					p42.BillboardGui.Size = UDim2.new(v119, 0, v119, 0)
				end
				_p.Particles:new(v118)
				delay(0.4, function()
					for v120 = 1, 2 do
						local v121 = math.random() * 360
						_p.Particles:new({
							Color = v117, 
							Image = 644161227, 
							Lifetime = 0.7, 
							Rotation = v121 + 90, 
							Size = 0.4 * v116, 
							Position = v103, 
							Velocity = 5 * (v106 * Vector3.new(math.cos(math.rad(v121)), math.sin(math.rad(v121)), 0)), 
							Acceleration = false
						})
					end
				end)
				wait(0.035)
			end
			local v122 = v101.sprite.cf + Vector3.new(0, (v101.sprite.spriteData.inAir), 0) - workspace.CurrentCamera.CFrame.lookVector * 0.2
			local v123 = create("Part")({
				Anchored = true, 
				CanCollide = false, 
				BrickColor = BrickColor.new("Electric blue"), 
				Reflectance = 0.5, 
				Transparency = 0.3, 
				Size = Vector3.new(5, 5, 5), 
				Parent = workspace
			})
			v123.CFrame = v122 * CFrame.Angles(0, 0, math.pi)
			local u50 = create("SpecialMesh")({
				MeshType = Enum.MeshType.FileMesh, 
				MeshId = "rbxassetid://818652045", 
				Parent = v123
			})
			Tween(0.5, nil, function(p43)
				local v124 = p43 * 0.15
				u50.Scale = Vector3.new(v124, v124, v124)
			end)
			pcall(function()
				v101.sprite.animation:Pause()
			end)
			local u51 = {}
			for v125 = 1, 6 do
				local v126 = v123:Clone()
				v126.Mesh.Scale = Vector3.new(0.1, 0.1, 0.1)
				u51[v126] = v122 * CFrame.Angles(0, math.pi / 3 * v125, 0) * CFrame.new(0, 0, -1) * CFrame.Angles(2.5, math.random() * 2 * math.pi, 0)
				v126.Parent = workspace
			end
			Tween(0.4, "easeOutQuad", function(p44)
				for v127, v128 in pairs(u51) do
					v127.CFrame = v128 * CFrame.new(0, 3 * (1 - p44), 0)
				end
			end)
			local u52 = u36 * Vector3.new(1, 0, 1).unit
			local u53 = l__sprite__107.spriteData.inAir
			Tween(0.6, nil, function(p45)
				l__sprite__107.offset = u52 * 2 + Vector3.new(0, math.sin(math.pi), 0)
			end)
			local u54 = false
			local u55 = Utilities.Signal()
			local l__magnitude__56 = u36.magnitude
			local function u57()
				u55:fire()
				local v129 = u52:Cross(Vector3.new(0, 1, 0))
				u51[v123] = true
				for v130, v131 in pairs(u51) do
					local l__CFrame__132 = v130.CFrame
					local v133 = CFrame.new(l__CFrame__132.p, l__CFrame__132.p + v129)
					u51[v130] = { v133, v133:inverse() * l__CFrame__132 }
				end
				Tween(0.4, nil, function(p46)
					if not v123.Parent then
						return false
					end
					v101.sprite.offset = u52 * p46 * 10 + Vector3.new(0, p46 * 4, 0)
					pcall(function()
						v101.sprite.animation.spriteLabel.Rotation = 500 * p46
					end)
					local v134 = CFrame.Angles(0, 0, p46 * 1.8)
					local v135 = u52 * p46 * 2 + Vector3.new(0, p46 * -5, 0)
					for v136, v137 in pairs(u51) do
						v136.CFrame = v137[1] * v134 * v137[2] + v135
					end
				end)
			end
			spawn(function()
				Tween(1, nil, function(p47, p48)
					if not v123.Parent then
						return false
					end
					local v138 = 70 * p48 * p48 - 2 + 5 * p48
					l__sprite__107.offset = u52 * v138 + Vector3.new(0, u53, 0)
					if not u54 and l__magnitude__56 <= v138 then
						u54 = true
						spawn(u57)
					end
				end)
			end)
			u55:wait()
			Utilities.FadeOut(0.35, Color3.new(1, 1, 1))
			v108:Remove()
			l__sprite__107.offset = Vector3.new()
			v101.sprite.offset = Vector3.new()
			pcall(function()
				v101.sprite.animation.spriteLabel.Rotation = 0
			end)
			l__Lighting__109.Ambient = l__Ambient__37
			l__Lighting__109.OutdoorAmbient = l__OutdoorAmbient__38
			l__Lighting__109.ColorShift_Bottom = l__ColorShift_Bottom__39
			l__Lighting__109.ColorShift_Top = l__ColorShift_Top__40
			l__Lighting__109.FogColor = l__Lighting__109.FogColor
			l__Lighting__109.FogEnd = l__FogEnd__41
			l__Lighting__109.FogStart = l__FogStart__42
			for v139, v140 in pairs(u51) do
				v139:Remove()
			end
			pcall(function()
				v101.sprite.animation:Play()
			end)
			wait(0.1)
			Utilities.FadeIn(0.5)
			return true
		end, 
		swordsdance = function(pokemon)
			local pp1 = pokemon.sprite.part.CFrame * CFrame.new(0, pokemon.sprite.part.Size.Y / 2, 0)
			local v631 = create("Part")({
				BrickColor = BrickColor.new("Dark stone grey"), 
				Reflectance = 0.4, 
				Anchored = true, 
				CanCollide = false, 
				Size = Vector3.new(1, 0.8, 4) * 0.6, 
				Parent = workspace,
				create("SpecialMesh")({
					MeshType = Enum.MeshType.FileMesh, 
					MeshId = "rbxasset://fonts/sword.mesh", 
					TextureId = "rbxasset://textures/SwordTexture.png", 
					Scale = Vector3.new(0.6, 0.6, 0.6)
				})
			})
			local v632 = {}
			for v633 = 1, 6 do
				local v634 = v633 == 1 and v631 or v631:Clone()
				v634.Parent = workspace
				v632[v634] = pp1 * CFrame.Angles(0, math.pi / 3 * v633, 0) * CFrame.new(0, 0, 2) * CFrame.Angles(-math.pi / 2, 0, 0)
			end
			local u190 = CFrame.new(Vector3.new(0, 0, 0.85) * 0.6)
			Tween(0.6, nil, function(p407)
				for v635, v636 in pairs(v632) do
					v635.CFrame = v636 * CFrame.Angles(0, -math.pi * p407, 0) * u190
				end
			end)
			for v637, v638 in pairs(v632) do
				v632[v637] = v638 * CFrame.Angles(0, -math.pi, 0)
			end
			Tween(0.6, nil, function(p408)
				for v639, v640 in pairs(v632) do
					v639.CFrame = v640 * CFrame.Angles(0, 0, math.pi / 2 * p408) * CFrame.Angles(0, -math.pi * p408, 0) * u190
				end
			end)
			for v641, v642 in pairs(v632) do
				v632[v641] = v642 * CFrame.Angles(0, 0, math.pi / 2) * CFrame.Angles(0, -math.pi, 0)
			end
			wait(0.3)
			delay(0.25, function()
				Utilities.sound("rbxasset://sounds/unsheath.wav", 1, nil, 2)
			end)
			Tween(0.4, nil, function(p409)
				for v643, v644 in pairs(v632) do
					v643.CFrame = v644 * CFrame.Angles(0, -0.9 * p409, 0) * CFrame.new(0, 0, 0.6 * p409) * u190 + Vector3.new(0, 0.3 * p409, 0)
				end
			end)
			wait(0.5)
			for v645, v646 in pairs(v632) do
				v645:Remove()
			end
		end,

	} end