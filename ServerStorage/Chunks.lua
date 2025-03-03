local _f = require(game:GetService('ServerScriptService'):WaitForChild('SFramework'))

local kmanVolume = 1
local routeMusicVolume = kmanVolume

local uid = require(game:GetService('ServerStorage').Utilities).uid

local encounterLists = {}
local function EncounterList(list)
	local isMetadata = false
	-- check a random key, if it is not a number then this is metadata
	for i in pairs(list) do if type(i) ~= 'number' then isMetadata = true end break end
	if isMetadata then
		return function(actualList)
			local eld = EncounterList(actualList)
			local t = encounterLists[eld.id]
			for k, v in pairs(list) do
				t[k] = v
			end
			return eld
		end
	end
	-- modify lists here (e.g. for a new version of October2k16's Haunter event)
	local id = uid()--#encounterLists + 1 -- prefer uid, because it prevents guessing and makes every server unique
	while encounterLists[id] do id = uid() end
	encounterLists[id] = {id = id, list = list}
	local levelDistributionDay   = {}
	local levelDistributionNight = {}
	for _, entry in pairs(list) do
		-- day
		if entry[5] ~= 'night' then
			local chancePerLevel = entry[4] / (entry[3] - entry[2] + 1)
			for level = entry[2], entry[3] do
				levelDistributionDay  [level] = (levelDistributionDay  [level] or 0) + chancePerLevel
			end
		end
		-- night
		if entry[5] ~= 'day' then
			local chancePerLevel = entry[4] / (entry[3] - entry[2] + 1)
			for level = entry[2], entry[3] do
				levelDistributionNight[level] = (levelDistributionNight[level] or 0) + chancePerLevel
			end
		end
	end
	local function convert(t)
		local new = {}
		for level, chance in pairs(t) do
			new[#new+1] = {level, chance}
		end
		return new
	end
	return {
		id = id,
		ld = {convert(levelDistributionDay),
			convert(levelDistributionNight)}
	}
end

local function ConstantLevelList(list, level)
	for _, entry in pairs(list) do
		entry[5] = entry[3] -- [5] day / night
		entry[4] = entry[2] -- [4] chance
		entry[2] = level    -- [2] min level
		entry[3] = level    -- [3] max level
	end
	return EncounterList(list)
end

local function OldRodList(list)
	local ed = ConstantLevelList(list, 10)
	encounterLists[ed.id].rod = 'old'
	return ed
end

local function GoodRodList(list)
	local ed = ConstantLevelList(list, 20)
	encounterLists[ed.id].rod = 'good'
	return ed
end

local ruinsEncounter = EncounterList {
	{'Baltoy',   29, 32, 25},
	{'Natu',     29, 32, 20},
	{'Elgyem',   29, 32, 20},
	{'Sigilyph', 29, 32, 10},
	{'Ekans',    29, 32,  8},
	{'Darumaka', 29, 32,  4},
	{'Zorua',    29, 32,  2},
}

local chunks = {
	['chunk1'] = {
		buildings = {
			'Gate1',
		},
		regions = {
			['Mitis Town'] = {
				SignColor = BrickColor.new('Bronze').Color,
				Music = {18721712920},--//6002770940\--
				MusicVolume = kmanVolume,
				OldRod = OldRodList {
					{'Magikarp', 100},
				},
				GoodRod = GoodRodList {
					{'Magikarp', 50},
					{'Gyarados', 5},
				},
			},
			['Route 1'] = {
				Music = 18721717726,--301381728,
				MusicVolume = kmanVolume,
				Grass = EncounterList {
					
					{'Pidgey',     2, 4, 25},
					{'Zigzagoon',  2, 4, 20},
					{'Bunnelby', 2, 4, 11},
					{'Fletchling',   2, 4, 24},
					{'Wurmple',    2, 4, 11},
					{'Sentret',    2, 4,  5, 'day'},
					--]]
				},
			},
		},
	},
	['chunk2'] = {
		buildings = {
			['PokeCenter'] = {
				NPCs = {
					{
						appearance = 'Camper',
						cframe = CFrame.new(10, 0, 0),
						interact = { 'See that girl over there behind the counter?', 'She heals your pokemon.' }
					},
				},
			},
			'Gate1',
			'Gate2',
			['SawsbuckCoffee'] = {
				DoorViewAngle = 15,
			},
		},
		regions = {
			['Cheshma Town'] = {
				SignColor = BrickColor.new('Deep blue').Color,
				Music = 18721805244,--296982245,
				MusicVolume = kmanVolume,
			},
			['Gale Forest'] = {
				SignColor = BrickColor.new('Dark green').Color,
				Music = {18721808473},--2164151015,
				BattleScene = 'Forest1',
				IsDark = true,
				Grass = EncounterList {
					{'Caterpie',   3, 5, 20},
					{'Metapod',    5, 6, 10},
					{'Kakuna',     5, 6, 10},
					{'Nidoran[F]', 3, 5, 10},
					{'Nidoran[M]', 3, 5, 10},
					{'Ledyba',     3, 5, 15, 'day'},
					{'Spinarak',   3, 5, 15, 'night'},
					{'Hoothoot',   4, 6, 10, 'night'},
					{'Pikachu',    4, 6,  3},
				},
			},
			['Route 2'] = {
				RTDDisabled = true,
				Music = 2269965903,--301381862,
				MusicVolume = routeMusicVolume,
				Grass = EncounterList {
					{'Pidgey',     4, 6, 10},
					{'Fletchling', 4, 6, 10},
					{'Zigzagoon',   4, 6,  8},
					{'Plusle',     4, 6,  2},
					{'Minun',      4, 6,  2},
				},
				OldRod = OldRodList {
					{'Magikarp', 50},
					{'Feebas', 50},
					{'Barboach', 15},

					
				},
				
				GoodRod = GoodRodList {
					{'Barboach', 50},
					{'Magikarp', 20},
					{'Gyarados', 5},
					{'Whiscash', 5},
				},
				
				
			},
		},
	},
	['chunk3'] = {
		buildings = {
			['Gym1'] = {
				Music = 2706924206,
				BattleScene = 'Gym1',
			},
			['PokeCenter'] = {
				NPCs = {
					{
						appearance = 'Rich Boy',
						cframe = CFrame.new(-23, 0, 8) * CFrame.Angles(0, -math.pi/3, 0),
						interact = { 'This PC has been acting awfully strange lately.', 'I think it needs an upgrade...' }
					},
				},
			},
			'Gate2',
			'Gate3',
		},
		regions = {
			['Route 3'] = {
				BlackOutTo = 'chunk2',
				Music = 1782378614,--301381862,
				MusicVolume = routeMusicVolume,
				Grass = EncounterList {
					{'Kricketot', 5, 7, 20},
					{'Budew', 5, 7, 20},
					{'Poochyena', 5, 7, 20},
					{'Shinx',     5, 7, 20},
					{'Electrike', 5, 7, 20},
					{'Mareep',    5, 7, 20},
					{'Nincada',   5, 7, 10},
					{'Abra',      5, 7, 10},--I FIXED THE SPRITE :D!!...
					{'Pachirisu', 6, 8,  4},

				}
			},
			['Silvent City'] = {
				Music = {456109734, 456110519},--296993609,
				SignColor = BrickColor.new('Bright yellow').Color,
				PCEncounter = EncounterList {PDEvent = 'PCPorygonEncountered'} {{'Porygon', 5, 5, 1}}
			},
			['Route 4'] = {
				RTDDisabled = true,
				Music = 301381862,--301381862,
				MusicVolume = routeMusicVolume,
				Grass = EncounterList {
					{'Pidgey', 7,  9, 25},
					{'Shinx',  7,  9, 20},
					{'Mareep', 7,  9, 20},
					{'Stunky', 7,  9, 15},
					{'Skiddo', 7, 10, 10},
					{'Marill', 7, 10, 10},
				}
			},
		},
	},
	['chunk4'] = {
		blackOutTo = 'chunk3',
		buildings = {
			'Gate3',
			'Gate4',
		},
		regions = {
			['Route 5'] = {
				RTDDisabled = true,
				Music = 301381959,--1782382452,
				MusicVolume = .8,
				BattleScene = 'Safari',
				Grass = EncounterList {
					{'Patrat',     8, 10, 25},
					{'Phanpy',     8, 10, 20},
					{'Blitzle',    8, 10, 20},
					{'Litleo',     8, 10, 20},
					{'Hippopotas', 8, 10, 15},
					{'Girafarig',  9, 11,  5},
				}
			},
			['Old Graveyard'] = {
				Music = 497404578,
				RTDDisabled = true,
				SignColor = Color3.new(.5, .5, .5),
				BattleScene = 'Graveyard',
				GrassEncounterChance = 9,
				Grass = EncounterList {
					{'Cubone',  8, 10, 40},
					{'Gothita', 8, 10, 15},
					{'Gastly',  8, 10, 30, 'night'},
					{'Murkrow', 8, 10, 20, 'night'},
					{'Yamask',  8, 10,  5, 'night'},
				}
			},
		},
	},
	['chunk5'] = {
		buildings = {
			'Gate4', 'Gate5', 'Gate6',
			'PokeCenter',
			['Gym2'] = {
				Music = 317836326,
				BattleScene = 'Gym2',
			},
		},
		regions = {
			['Brimber City'] = {
				Music = 527347414,--316929443,
				SignColor = BrickColor.new('Crimson').Color,
				BattleScene = 'Safari', -- for Santa, if nothing else
			}
		},
	},
	['chunk6'] = {
		blackOutTo = 'chunk5',
		buildings = {
			'Gate5',
		},
		regions = {
			['Route 6'] = {
				Music = 142298969,--301381959,
				MusicVolume = .8,
				BattleScene = 'Safari',
				Grass = EncounterList {
					{'Litleo',  9, 11, 20},
					{'Blitzle', 9, 11, 20},
					{'Ponyta',  9, 11, 15},
					{'Rhyhorn', 9, 11, 10},
					{'Zubat',   9, 11, 30, 'night'},
				},
				Anthill = EncounterList {Locked = true} {{'Durant', 5, 8, 1}}
			}
		}
	},
	['chunk7'] = {
		blackOutTo = 'chunk5',
		canFly = false,
		regions = {
			['Mt. Igneus'] = {
				Music = 583126552,--317351319,
				MusicVolume = .8,
				SignColor = BrickColor.new('Cocoa').Color,
				BattleScene = 'LavaCave',
				IsDark = true,
				GrassNotRequired = true,
				GrassEncounterChance = 4,
				Grass = EncounterList {
					{'Numel',   9, 11, 20},
					{'Nosepass',   9, 11, 20},
					{'Slugma',  9, 11, 20},
					{'Torkoal', 9, 11, 17},
					{'Zubat',   9, 11, 30, 'day'},
				}
			}
		}
	},
	['chunk8'] = {
		blackOutTo = 'chunk5',
		buildings = {
			'Gate6',
			'Gate7',
			['SawMill'] = {
				BattleScene = 'SawMill',
			},
		},
		regions = {
			['Route 7'] = {
				Music = 469639805,
				MusicVolume = .575,
				RTDDisabled = true,
				Grass = EncounterList {
					--[[
					{'Medicham',  12, 14, 20},
					{'Ditto',  12, 14, 20},
					{'Aegislash',  12, 14, 20},
					{'Abra',  12, 14, 20},
					{'Mammoswine',  12, 14, 20},
					{'Kyogre',  12, 14, 20},
					{'Shinx',  12, 14, 20},
					{'Shroomish',  12, 14, 20},
					{'Tympole',  12, 14, 20},
					{'Glaceon',  12, 14, 20},
					{'Porygon',  12, 14, 20},
					{'Porygon-Z',  12, 14, 20},
					{'Porygon2',  12, 14, 20},
					{'Munchlax',  12, 14, 20},
					{'Zapdos',  12, 14, 20},
					{'Articuno',  12, 14, 20},
					{'Chikorita',  12, 14, 20},
					{'Totodile',  12, 14, 20},
					{'Suicune',  12, 14, 20},
					{'Entei',  12, 14, 20},
					{'Celebi',  12, 14, 20},
					{'Froslass',  12, 14, 20},
					{'Rotom',  12, 14, 20},
					{'Manaphy',  12, 14, 20},
					{'Togetic',  12, 14, 20},
					{'Vigoroth',  12, 14, 20},
					{'Arcanine',  12, 14, 20},
					--]]
					-- [[
					{'Bidoof',  12, 14, 20},
					{'Poliwag', 12, 14, 15},
					{'Marill',  12, 14, 15},
					{'Wooper',  12, 14, 15},
					{'Sunkern', 12, 14, 12},
					{'Surskit', 12, 14, 10},
					{'Skitty',  12, 14, 8},
					{'Yanma',   12, 14, 8},
					{'Ralts',   13, 15, 5},
					--]]
				},
				OldRod = OldRodList {
					{'Magikarp', 40},
					{'Tympole',  20},
					{'Corphish', 5},
				},
								GoodRod = GoodRodList {
					{'Tympole', 50},
					{'Corphish', 20},
					{'Magikarp', 5},
					{'Whiscash', 5},
				},
			}
		}
	},
	['chunk9'] = {
        buildings = {
            'Gate7',
            'Gate8',
            'PokeCenter',
        },
        regions = {
            ['Lagoona Lake'] = {
                SignColor = BrickColor.new('Deep blue').Color,
                Music = {527348762,527351446},--323074713,
                OldRod = OldRodList {
                    {'Tentacool', 50},
                    {'Goldeen',  10},
                },
                Surf = EncounterList { 
                    {'Magikarp', 13, 16, 40}
                }
            },
        },
    },
	['chunk10'] = {
		blackOutTo = 'chunk9',
		buildings = {
			'Gate8',
			'Gate9',
		},
		regions = {
			['Route 8'] = {
				RTDDisabled = true,
				Music = 2269965903,
				Grass = EncounterList {
					{'Oddish',     13, 16, 40},
					{'Bellsprout', 13, 16, 40},
					{'Buneary',    13, 16, 35},
					{'Starly',     13, 16, 35},
					{'Lillipup',   13, 16, 35},
					{'Espurr',     13, 16, 25},
					{'Swablu',     13, 16, 20},
					{'Staravia',   14, 16, 15},
					{'Herdier',    14, 16, 15},
					{'Riolu',      13, 16,  4},
				},
				Well = EncounterList
					{Verify = function(PlayerData) return PlayerData:incrementBagItem('oddkeystone', -1) end}
					{{'Spiritomb', 15, 15, 1}}
			},
		},
	},
	['chunk11'] = {
		buildings = {
			'Gate9',
			'Gate10',
			'PokeCenter',
			['Gym3'] = {
				Music = 337187287,
				BattleScene = 'Gym3',
			},
		},
		regions = {
			['Rosecove City'] = {
				SignColor = BrickColor.new('Storm blue').Color,
				Music = 148607753,--330353519,
				BattleScene = 'Gym3', -- for Santa, if nothing else
			},
			['Rosecove Beach'] = {
				SignColor = BrickColor.new('Brick yellow').Color,
				Music = 330353665,--337086384,--533466642
				MusicVolume = 0.4,
				BattleScene = 'Beach',
				RodScene = 'Beach',
				RTDDisabled = true,
				Grass = EncounterList {
					{'Shellos',  15, 17, 20},
					{'Slowpoke', 15, 17, 15},
					{'Wingull',  15, 17, 10},
					{'Psyduck',  15, 17, 10},
				},
				OldRod = OldRodList {
					{'Tentacool', 4},
					{'Finneon',   1},
				},
				GoodRod = GoodRodList {
					{'Tentacool', 4},
					{'Finneon', 3},
					{'Tentacruel', 1},		
				},
				Surf = EncounterList { 
					{'Tentacool', 27, 32, 40},
					{'Finneon', 27, 32, 30},
					{'Lumineon', 27, 32, 1},
				},
		        		
				PalmTree = EncounterList {Locked = true} {
					{'Exeggcute', 15, 17, 4},
					{'Aipom',     15, 17, 1},
				},
				MiscEncounter = EncounterList {Locked = true} { -- waves
					{'Krabby', 15, 17, 3},
					{'Staryu', 15, 17, 2},
				},
			}
		}
	},
	['chunk12'] = {
		blackOutTo = 'chunk11',
		buildings = {
			'Gate10',
			['Gate11'] = {
				Music = 456107045,
			},
			'Gate12',
			'Gate13',
		},
		regions = {
			['Route 9'] = {
				SignColor = BrickColor.new('Dark green').Color,
				Music = 2392929710,
				MusicVolume = 0.7,
				BattleScene = 'Forest1',
				IsDark = true,
				Grass = EncounterList {
					{'Sewaddle',  19, 21, 30},
					{'Venipede',  19, 21, 25},
					{'Shroomish', 19, 21,  2},
					{'Paras',     19, 21, 35, 'day'},
					{'Roselia',   19, 21,  5, 'day'},
					{'Kricketot', 19, 21, 35, 'night'},
					{'Venonat',   19, 21,  5, 'night'},
				},
				PineTree = EncounterList {Locked = true} {
					{'Pineco',    19, 21, 30},
					{'Spewpa',    19, 21, 20},
					{'Kakuna',    19, 21, 10},
					{'Metapod',   19, 21, 10},
					{'Heracross', 20, 22,  2, 'night'},
					{'Pinsir',    20, 22,  2, 'day'},
				}
			}
		}
	},
	['chunk13'] = {
		blackOutTo = 'chunk11',
		lighting = {
			FogColor = Color3.fromHSV(5/6, .2, .5),
			FogStart = 45,
			FogEnd = 200,
		},
		buildings = {
			['Gate11'] = {
				Music = 456107045,
			},
			['HMFoyer'] = {
				BattleScene = 'HauntedMansion',
				Music = 456101011,
			},
			['HMStub1'] = { DoorViewAngle = 10 },
			['HMStub2'] = { DoorViewAngle = 10 },
			['HMAttic'] = {
				BattleScene = 'HauntedMansion',
				Music = 456101011,
			},
			['HMBabyRoom'] = {BattleScene = 'HauntedMansion'},
			['HMBadBedroom'] = {BattleScene = 'HauntedMansion'},
			['HMBathroom'] = {BattleScene = 'HauntedMansion'},
			['HMBedroom'] = {BattleScene = 'HauntedMansion'},
			['HMDiningRoom'] = {BattleScene = 'HauntedMansion'},
			['HMLibrary'] = {BattleScene = 'HauntedMansion'},
			['HMMotherLounge'] = {BattleScene = 'HauntedMansion'},
			['HMMusicRoom'] = {BattleScene = 'HauntedMansion'},
			['HMUpperHall'] = {BattleScene = 'HauntedMansion'},
		},
		regions = {
			['Fortulose Manor'] = { -- Well-Mannered Manure Manor
				SignColor = BrickColor.new('Mulberry').Color,
				Music = {456101869, 456102907},--346708311,
--				IsDark = true,
				Grass = EncounterList {
					{'Phantump',  20, 22, 30},
					{'Pumpkaboo', 20, 22, 30},
					{'Golett',    21, 23,  4},
				},
				OldRod = OldRodList {
					{'Magikarp', 18},
					{'Feebas',    1},
				},
								GoodRod = GoodRodList {
					{'Magikarp', 18},
					{'Feebas', 1},

				},
				
				
				InsideEnc = EncounterList {
					{'Rattata',    20, 22, 30},
					{'Shuppet',    20, 22, 20},
					{'Duskull',    20, 22, 20},
					{'Misdreavus', 20, 22,  8},
					{'Honedge',    20, 22,  2},
				},
				Candle = EncounterList {Locked = true} {{'Litwick', 20, 20, 1}},
				Gameboy = EncounterList {PDEvent = 'Rotom7'} {{'Rotom', 25, 25, 1}}
			}
		}
	},
	['chunk14'] = {
		blackOutTo = 'chunk11',
		buildings = {
			'PokeCenter',
			'Gate12',
		},
		regions = {
			['Grove of Dreams'] = {
				Music = 379873128,
				Grass = EncounterList {
					{'Venipede',  20, 22, 25},
					{'Mankey',    20, 22, 15},
					{'Snubbull',  20, 22, 10},
					{'Chatot',    20, 22,  5},
					{'Pancham',   21, 23,  2},
					{'Minccino',  20, 22, 10, 'day'},
					{'Kricketot', 20, 22, 35, 'night'},
				},
				OldRod = OldRodList {
					{'Magikarp', 49},
				
				},
								GoodRod = GoodRodList {
					{'Magikarp', 40},
					{'Dratini', 3},
					
				},
				
				
				Wish = EncounterList {PDEvent = 'Jirachi'} {{'Jirachi', 25, 25, 1}},
				Sage = EncounterList {Locked = true} {{'Pansage', 25, 25, 1}},
				Sear = EncounterList {Locked = true} {{'Pansear', 25, 25, 1}},
				Pour = EncounterList {Locked = true} {{'Panpour', 25, 25, 1}}
			}
		}
	},
	['chunk15'] = {
		blackOutTo = 'chunk11',
		buildings = {
			'Gate13',
			['CableCars'] = {
				DoorViewAngle = 15,
			},
		},
		regions = {
			['Route 10'] = {
				SignColor = BrickColor.new('Linen').Color,
				Music = 2269965903,
				MusicVolume = routeMusicVolume,
				BattleScene = 'Flowers',
				Grass = EncounterList {
					{'Hoppip',     20, 22, 30},
					{'Spoink',     20, 22, 25},
					{'Growlithe',  20, 22, 15},
					{'Chimecho',   20, 22, 10},
					{'Pawniard',   20, 22,  8},
					{'Helioptile', 20, 22,  4},
					{'Scyther',    21, 23,  2},
				},
				MiscEncounter = EncounterList {
					{'Floette',    20, 22, 30},
					{'Hoppip',     20, 22, 30},
					{'Spoink',     20, 22, 25},
					{'Petilil',    20, 22, 15},
				},
				HoneyTree = EncounterList
					{GetPokemon = function(PlayerData)
						local foe = PlayerData.honey.foe
						PlayerData.honey = nil -- ok to completely remove?
						return foe
					end}
					{{'Teddiursa', 19, 20, 10}, {'Combee', 19, 19, 90}},
				Windmill = EncounterList 
					{Verify = function(PlayerData)
						if not PlayerData.flags.DinWM then return false end
						PlayerData.flags.DinWM = nil
						PlayerData.lastDrifloonEncounterWeek = _f.Date:getWeekId()
						return true
					end}
					{{'Drifloon', 25, 25, 1}}
			}
		}
	},
	chunk16 = {
		blackOutTo = 'chunk11', -- dynamic
		canFly = false,
		regions = {
			['Cragonos Mines'] = {
				SignColor = BrickColor.new('Smoky grey').Color,
				Music = 247881988,
				BattleScene = 'CragonosMines',
				IsDark = true,
				GrassNotRequired = true,
				GrassEncounterChance = 2,
				Grass = EncounterList {
					{'Woobat',     21, 24, 35, 'day'},
					{'Geodude',    21, 24, 30},
					{'Roggenrola', 21, 24, 30},
					{'Meditite',   21, 24, 15},
					{'Diglett',    21, 24, 10},
					{'Onix',       21, 24,  7},
					{'Drilbur',    22, 25,  3},
					{'Larvitar',   22, 24,  2},
				},
				RodScene = 'CragonosMines',
				OldRod = OldRodList {
					{'Magikarp', 20},
					{'Goldeen',  10},
					{'Chinchou',  2},
				},
				
				GoodRod = GoodRodList {
					{'Magikarp', 20},
					{'Goldeen', 10},
					{'Chinchou', 6},
					
				},
				
				
			}
		}
	},
	chunk17 = {
		buildings = {
			'PokeCenter',
		},
		regions = {
			['Cragonos Cliffs'] = {
				SignColor = BrickColor.new('Sand green').Color,
				Music = 490041168,
				MusicVolume = routeMusicVolume,
				BattleScene = 'Cliffs',
				Grass = EncounterList {
					{'Woobat',    21, 24, 30, 'night'},
					{'Spearow',   21, 24, 30},
					{'Pidgeotto', 21, 24, 20},
					{'Skiddo',    21, 24, 20},
					{'Vullaby',   21, 24, 10},
					{'Gligar',    21, 24,  5},
					{'Bagon',     21, 24,  1},
				},
				Grace = EncounterList
					{Verify = function(PlayerData)
						return PlayerData:getBagDataById('gracidea', 5) and true or false
					end, PDEvent = 'Shaymin'}
					{{'Shaymin', 30, 30, 1}}
			}
		}
	},
	chunk18 = {
		blackOutTo = 'chunk17',
				buildings = {
			'PokeCenter',
		},
		regions = {
			['Cragonos Peak'] = {
				SignColor = Color3.new(1, 1, 1),
				Music = 1782382452,
				BattleScene = 'Cliffs',
				Grass = EncounterList {
					--[
					{'Skiddo',   22, 25, 30},
					{'Doduo',    22, 25, 30},
					{'Spearow',  22, 25, 30},
					{'Inkay',    22, 25, 10},
					{'Stantler', 23, 26,  6},
					{'Rufflet',  22, 26,  2},
					--]]
				}
			}
		}
	},
	chunk19 = {
		blackOutTo = 'chunk21',
		regions = {
			['Anthian City - Housing District'] = {
				SignColor = BrickColor.new('Steel blue').Color,
				Music = 506504476,
--				MusicVolume = 1, -- ?
				Dumpster = EncounterList 
					{Verify = function(PlayerData)
						if not PlayerData.flags.TinD then return false end
						PlayerData.flags.TinD = nil
						PlayerData.lastTrubbishEncounterWeek = _f.Date:getWeekId()
						return true
					end}
					{{'Trubbish', 22, 25, 1}}
			}
		}
	},
	chunk20 = {
		blackOutTo = 'chunk21',
		buildings = {
			['PokeBallShop'] = {
				DoorViewAngle = 25
			},
			['LudiLoco'] = {
				Music = 511833360,
				DoorViewAngle = 20
			},
			['C_chunk23'] = {
				DoorViewAngle = 60,
				DoorViewZoom = 15
			}
		},
		regions = {
			['Anthian City - Shopping District'] = {
				SignColor = BrickColor.new('Fossil').Color, -- Daisy orange
				Music = {6423231278, 6423235693},
				MusicVolume = 1.2,
				
			}
		}
	},
	chunk21 = {
		buildings = {
			['Gym4'] = {
				Music = 494378223,
				BattleScene = 'Gym4',
				DoorViewZoom = 35,
			},
			'PokeCenter'
		},
		regions = {
			['Anthian City - Battle District'] = {
				SignColor = BrickColor.new('Crimson').Color,
				BattleScene = 'Gym4',
				Music = 240790316,
				
			}
		}
	},
	chunk22 = {
		blackOutTo = 'chunk21',
		buildings = {
			['PowerPlant'] = {DoorViewAngle = 20}
		},
		regions = {
			['Anthian Park'] = {--['Anthian City - Park District'] = {
				SignColor = BrickColor.new('Bright green').Color,
				Music = 627901899,
				
			}
		}
	},
	chunk23 = {
		blackOutTo = 'chunk21',
		canFly = false,
		buildings = {
			['C_chunk20'] = {
--				DoorViewAngle = 25,
				DoorViewZoom = 14,
			},
			['C_chunk22'] = {
				DoorViewAngle = 30,
				DoorViewZoom = 14,
			},
			['EnergyCore'] = {
				DoorViewAngle = 20,
				DoorViewZoom = 12,
				BattleScene = 'CoreRoom',
			}
		},
		lighting = {
			Ambient = Color3.fromRGB(145, 145, 145),
			OutdoorAmbient = Color3.fromRGB(108, 108, 108),
--			TimeOfDay = '06:00:00',
		},
		regions = {
			['Anthian Sewer'] = { -- IF THE NAME OF THIS CHANGES, EDIT Events.onLoad_chunk23 !
				SignColor = BrickColor.new('Slime green').Color,
				Music = 498677393,
				BattleScene = 'Sewer',
--				IsDark = true,
				GrassNotRequired = true,
				GrassEncounterChance = 2,
				Grass = EncounterList {
					{'Voltorb',   27, 30, 25},
					{'Magnemite', 27, 30, 25},
					{'Klink',     27, 30, 20},
					{'Koffing',   27, 30, 10},
					{'Grimer',    27, 30, 10},
					{'Elekid',    28, 29,  2},
				}
			}
		}
	},
	chunk24 = {
		blackOutTo = 'chunk21',
		buildings = {
			['CableCars'] = {DoorViewAngle = 15},
			'Gate14',
		},
		lighting = {
			FogColor = Color3.fromRGB(216, 194, 114), -- transition implemented in Events
			FogEnd = 200,
			FogStart = 40,
		},
		regions = {
			['Route 11'] = {
				SignColor = BrickColor.new('Brick yellow').Color,
				Music = 517287759,
				BattleScene = 'Desert',
				Grass = EncounterList
					{Weather = 'sandstorm'}
					{
						{'Cacnea',    28, 31, 20},
						{'Trapinch',  28, 31, 20},
						{'Hippowdon', 28, 31, 15},
						{'Sandslash', 28, 31, 10},
						{'Krokorok',  28, 31,  8},
						{'Maractus',  28, 31,  3}
					}
			}
		}
	},
	--this is where i need to add more music below me vvv
	chunk25 = {
		buildings = {
			'Gate14',
			'Gate15',
			'Gate16',
			['PokeCenter'] = {DoorViewAngle = 25},
			['House4'] = {DoorViewAngle = 25},
			['Palace'] = {Music = {615714813, 608877390}}
		},
		regions = {
			['Aredia City'] = {
				SignColor = BrickColor.new('Flint').Color,
				Music = {602836512, 602839466},
				BattleScene = 'Aredia',
				Snore = EncounterList
					{Verify = function(PlayerData)
						return PlayerData:hasFlute()
					end, PDEvent = 'Snorlax'}
					{{'Snorlax', 30, 30, 1}}
			}
		}
	},
	chunk26 = {
		blackOutTo = 'chunk5',
		canFly = false,
		regions = {
			['Glistening Grotto'] = {
				SignColor = BrickColor.new('Smoky grey').Color,
				Music = 611071632,
				MusicVolume = .45,
				BattleScene = 'CrystalCave',
				RodScene = 'CrystalCave',
				IsDark = true,
				GrassNotRequired = true,
				GrassEncounterChance = 2,
				Grass = EncounterList {
					{'Zubat',   25, 30, 25, 'day'},
					{'Bronzor', 25, 30, 25},
					{'Boldore', 25, 30, 20},
					{'Carbink', 25, 30, 15},
					{'Elgyem',  25, 30, 10},
					{'Mawile',  25, 30,  5},
					{'Sableye', 25, 30,  5},
					{'Aron',    25, 30,  3},
				},
				OldRod = OldRodList {
					{'Goldeen',  30},
					{'Shellder', 15},
					--{'Relicanth', 1},
				},
								GoodRod = GoodRodList {
					{'Goldeen', 30},
					{'Shellder', 20},
					{'Relicanth', 6},
					
				},
			}
		}
	},
	chunk27 = {
		blackOutTo = 'chunk25',
		buildings = {
			'Gate15'
		},
		regions = {
			['Old Aredia'] = {
				SignColor = BrickColor.new('Cashmere').Color,
				Music = 517287759,
				BattleScene = 'Desert',
				Grass = EncounterList {
					--[[
					{'Ditto', 29, 32, 25},
					{'Clauncher', 29, 32, 25},
					{'Larvesta', 29, 32, 25},
					{'Darkrai', 29, 32, 25},
					

					--]]
					-- [[
					{'Hippowdon', 29, 32, 25},
					{'Cacnea',    29, 32, 20},
					{'Trapinch',  29, 32, 20},
					{'Sandslash', 29, 32, 15},
					{'Dunsparce', 29, 32, 10},
					{'Gible',     29, 32,  1},
					--]]
				}
			}
		}
	},
	chunk28 = {blackOutTo = 'chunk25', canFly = false, regions = {c = {NoSign = true, Music = 602846198, BattleScene = 'DesertCastleRuins', RTDDisabled = true, GrassNotRequired = true, GrassEncounterChance = 1, Grass = ruinsEncounter}}},
	chunk29 = {blackOutTo = 'chunk25', canFly = false, regions = {c = {NoSign = true, Music = 602846198, BattleScene = 'DesertCastleRuins', RTDDisabled = true, GrassNotRequired = true, GrassEncounterChance = 1, Grass = ruinsEncounter}}},
	chunk30 = {blackOutTo = 'chunk25', canFly = false, regions = {c = {NoSign = true, Music = 602846198, BattleScene = 'DesertCastleRuins', RTDDisabled = true, GrassNotRequired = true, GrassEncounterChance = 1, Grass = ruinsEncounter}}},
	chunk31 = {blackOutTo = 'chunk25', canFly = false, regions = {c = {NoSign = true, Music = 602846198, BattleScene = 'DesertCastleRuins', RTDDisabled = true, GrassNotRequired = true, GrassEncounterChance = 1, Grass = ruinsEncounter}}},
	chunk32 = {blackOutTo = 'chunk25', canFly = false, regions = {c = {NoSign = true, Music = 602846198, BattleScene = 'DesertCastleRuins', RTDDisabled = true, GrassNotRequired = true, GrassEncounterChance = 1, Grass = ruinsEncounter}}},
	chunk33 = {blackOutTo = 'chunk25', canFly = false, regions = {c = {NoSign = true, Music = 602846198, BattleScene = 'DesertCastleRuins', RTDDisabled = true, GrassNotRequired = true, GrassEncounterChance = 1, Grass = ruinsEncounter}}},
	chunk34 = {blackOutTo = 'chunk25', canFly = false, regions = {c = {NoSign = true, Music = 602846198, BattleScene = 'DesertCastleRuins', RTDDisabled = true, GrassNotRequired = true, GrassEncounterChance = 1, Grass = ruinsEncounter,
		Victory = EncounterList
			{Verify = function(PlayerData)
				if not PlayerData.badges[5] then return false end
				return PlayerData.completedEvents.BJP and true or false
			end, PDEvent = 'Victini'}
			{{'Victini', 35, 35, 1}}}}},
	gym5 = {
		noHover = true,
		canFly = false,
		blackOutTo = 'chunk25',
		-- lighting ?
		regions = {
			['Aredia City Gym'] = {
				RTDDisabled = true,
				NoSign = true,
				Music = {615714813, 608877390},
				BattleScene = 'Gym5'
			}
		}
	},
	chunk35 = {
		blackOutTo = 'chunk25',
		regions = {
			['Desert Catacombs'] = {
				SignColor = BrickColor.new('Black').Color,
				Music = 611070133,
				MusicVolume = .8,
				BattleScene = 'UnownRuins',
				IsDark = true,
				GrassNotRequired = true,
				GrassEncounterChance = 2,
				Grass = EncounterList {
					{'Unown', 25, 30, 1}
				}
			}
		}
	},
	chunk36 = {
		buildings = {
			'Gate16'
		},
		blackOutTo = 'chunk25',
		regions = {
			['Route 12'] = {
				SignColor = BrickColor.new('Mint').Color,
				Music = 424133191,
				MusicVolume = routeMusicVolume,
				Grass = EncounterList {
--					{'Tranquill',  31, 34, 20},
					{'Houndour',   31, 34, 20},
					{'Vulpix',     31, 34, 15},
					{'Sawk',       31, 35, 15},
					{'Throh',      31, 35, 15},
					{'Scraggy',    31, 34, 10},
					{'Miltank',    31, 34,  5},
					{'Tauros',     31, 34,  5},
					{'Bouffalant', 31, 34,  3},
				},
				OldRod = OldRodList {
					{'Magikarp', 10},
					{'Goldeen',   5},
					{'Qwilfish',  1}
				},
								GoodRod = GoodRodList {
					{'Goldeen', 10},
					{'Magikarp', 5},
					{'Qwilfish', 2},
					
				},
				
			}
		}
	},
	chunk37 = {
		blackOutTo = 'chunk25',
		canFly = false,
		regions = {
			['Nature\'s Den'] = {
				SignColor = BrickColor.new('Moss').Color,
				Music = 441184012,
				BattleScene = 'NatureDen',
				Landforce = EncounterList
					{Verify = function(PlayerData)
						if not PlayerData.completedEvents.RNatureForces then return false end
						return PlayerData.flags.landorusEnabled and true or false -- flagged by DataService
					end, PDEvent = 'Landorus'}
					{{'Landorus', 40, 40, 1}}
			}
		}
	},
	
-- [[
	chunk38 = {
		buildings = {'Gate17'},
		canFly = false,
		blackOutTo = 'chunk25',
		regions = {
			['Route 13'] = {
				SignColor = BrickColor.new('Moss').Color,
				Music = 660444233,
				BattleScene = 'BioCave',
				IsDark = true,
				NoGrassIndoors = true,
				GrassNotRequired = true,
				GrassEncounterChance = 2,
				Grass = EncounterList {
					{'Foongus',  32, 36, 20},
					{'Duosion',  32, 36, 20},
					{'Tangela',  32, 36, 15},
					{'Volbeat',  32, 36, 10},
					{'Illumise', 32, 36, 10},
					{'Joltik',   32, 36, 10},
					{'Tynamo',   32, 36,  3}
				}
			}
		}
	},
	chunk39 = {
		buildings = {'Gate17', 'Gate18', 'PokeCenter'},
		regions = {
			['Fluoruma City'] = {
				SignColor = BrickColor.new('Mint').Color,
				Music = 658614238
			}
		}
	},
	gym6 = {
		noHover = true,
		canFly = false,
		blackOutTo = 'chunk39',
		regions = {
			['Fluoruma City Gym'] = {
				RTDDisabled = true,
				NoSign = true,
				Music = 494378223,
				BattleScene = 'Gym6'
			}
		}
	},
	chunk40 = {
		blackOutTo = 'chunk5',
		canFly = false,
		regions = {
			['Igneus Depths'] = {
				Music = 497197006,--317351319,
				MusicVolume = .8,
				SignColor = BrickColor.new('Burgundy').Color,
				BattleScene = 'LavaCave',
				IsDark = true,
				GrassNotRequired = true,
				GrassEncounterChance = 4,
				Grass = EncounterList {
					{'Numel',   25, 27, 17},
					{'Slugma',  25, 27, 20},
					{'Torkoal', 25, 27, 17},
					{'Magmar',  25, 27,  5},
					{'Heatmor', 25, 27,  8},
				},
				Heat = EncounterList
					{PDEvent = 'Heatran'}
					{{'Heatran', 40, 40, 1}}
			}
		}
	},
	chunk41 = {
		canFly = false,
		blackOutTo = 'chunk39', -- cuz requires rock climb
		regions = {
			['Chamber of the Jewel'] = {
				SignColor = BrickColor.new('Pink').Color,
				BattleScene = 'BioCave',
				Music = 660444233,
				IsDark = true,
				GrassNotRequired = true,
				GrassEncounterChance = 3,
				Grass = EncounterList {
					{'Foongus',  32, 36, 20},
					{'Duosion',  32, 36, 20},
					{'Tangela',  32, 36, 15},
					{'Volbeat',  32, 36, 10},
					{'Illumise', 32, 36, 10},
					{'Joltik',   32, 36, 10},
					{'Tynamo',   32, 36,  3}
				},
				Jewel = EncounterList
					{Verify = function(PlayerData) return PlayerData.completedEvents.OpenJDoor and true or false end,
					 PDEvent = 'Diancie'}
					{{'Diancie', 40, 40, 1}}
			}
		}
	},
	chunk42 = {
		buildings = {'Gate18'},
		canFly = false,
		blackOutTo = 'chunk39',
		regions = {
			['Route 14'] = {
				SignColor = BrickColor.new('Flint').Color,
				BattleScene = 'Rt14Ruins',
				Music = 667226783,
				IsDark = true,
				NoGrassIndoors = true,
				GrassNotRequired = true,
				GrassEncounterChance = 3,
				Grass = EncounterList {
					{'Loudred',  32, 36, 300},
					{'Makuhita', 32, 36, 300},
					{'Nosepass', 32, 36, 250},
					{'Mr. Mime', 32, 36, 150},
					{'Clefairy', 32, 36, 125},
					{'Noibat',   32, 36,  75},
					{'Beldum',   32, 36,  40},
					{'Onix',     32, 36,   1, nil, false, 'crystal'},
				}
			}
		}
	},
	chunk43 = {
		canFly = false,
		blackOutTo = 'chunk39',
		regions = {
			['Route 14'] = {
				SignColor = BrickColor.new('Teal').Color,
				BattleScene = 'Rt14Ice',
				Music = 667226783,
				IsDark = true,
				GrassNotRequired = true,
				GrassEncounterChance = 3,
				Grass = EncounterList {
					{'Loudred',  32, 36, 30},
					{'Makuhita', 32, 36, 40},
					{'Nosepass', 32, 36, 40},
					{'Mr. Mime', 32, 36, 20},
					{'Clefairy', 32, 36, 40},
					{'Noibat',   32, 36, 20},
					{'Beldum',   32, 36,  5},
					{'Onix',     32, 36,   1, nil, false, 'crystal'}
				}
			}
		}
	},
	chunk44 = {
		canFly = false,
		blackOutTo = 'chunk17',
		regions = {
			['Cragonos Sanctuary'] = {
				SignColor = BrickColor.new('Hurricane grey').Color,
				Music = 441184012,
			}
		}
	},
	chunk45 = {
		buildings = {'Gate19'},
		canFly = true,
		blackOutTo = 'chunk43',
		lighting = {
			FogColor = Color3.fromRGB(187, 223, 224),
			FogStart = 180,
			FogEnd = 800,
		},
		regions = {
			['Route 15'] = {
				Music = 2889686701,--301381728,
				BattleScene = 'Snow',
				RodScene = 'Snow',
				RTDDisabled = true,
				MusicVolume = 0.81,
				Grass = EncounterList {
					-- [[
					{'Snover',  34, 38, 50},
					{'Swinub',  34, 38, 50},
					{'Vanillite',  34, 38, 30},
					{'Snorunt',  34, 38, 20},
					{'Sneasel',  34, 38, 5, 'night'},
					--]]
				},
					OldRod = OldRodList {
					{'Magikarp', 50},
					{'Spheal',   30},
					{'Seel',  10},
					{'Bergmite',   1}
				},
				
					GoodRod = GoodRodList {
					{'Spheal', 50},
					{'Seel', 30},
					{'Bergmite', 10},
					
				},
		},
		},--]]
		},
chunk46 = {
		buildings = {'Gate19','Gate20','PokeCenter'},
		canFly = true,
		blackOutTo = 'chunk45',
		lighting = {
			FogColor = Color3.fromRGB(184, 212, 227),
			FogStart = 200,
			FogEnd = 1000,
		},
		regions = {
			['Frostveil City'] = {
				Music = 3861098815,--301381728,
				BattleScene = 'Frostveil',
				MusicVolume = 0.81,
				},
			},
		},
chunk47 = {
        buildings = {'Gate20', 'Gate21'}, --SkittyLodge
        canFly = true,
        regions = {
            ['Route 16'] = {
                SignColor = BrickColor.new('Smoky grey').Color,
                Music = 3099468912,
                Grass = EncounterList {
                    {'Jigglypuff',  35, 39, 50},
                    {'Swellow',  35, 39, 45},
                    {'Furfrou',  35, 39, 35},
                    {'Nuzleaf',  35, 39, 35},
                    {'Dedenne',  35, 39, 10},
                    {'Emolga',  35, 39, 10},
              
                },
            }
        }
    },
chunk51 = {
		buildings = {'Gate21','Gate22'--[['Gate21',]] --[['Gate23']]},
		canFly = true,
		regions = {
			['Cosmeos Valley'] = {
				SignColor = BrickColor.new('Dark green').Color,
				Music = 3806946726,
				BattleScene = 'Forest1',
				RodScene = 'Forest1',
		        Grass = EncounterList {
					{'Munna',       36, 40, 35}, -- Remove forewarn from Munna or try to fix it
					{'Cottonee',    36, 40, 30},
					{'Vigoroth',    36, 40, 30},
					--{'Minior',      36, 40, 20},
					{'Skarmory',    36, 40, 20},
					{'Hawlucha',    36, 40,  5},
					{'Shelmet',     36, 40,  4},
					{'Karrablast',  36, 40,  4},
		        },
		        OldRod = OldRodList {
					{'Magikarp', 50},
					{'Goldeen',   30},
					{'Basculin',  10},
					--{'Luvdisc',   5}
				},
				
					GoodRod = GoodRodList {
					{'Goldeen', 50},
					{'Magikarp', 30},
					{'Basculin', 10},
					{'Luvdisc',   5},
					{'Magikarp', 1, 12, 1, nil, false, 'rainbow'}
                    
				},
		 --[[GoodRod = GoodRodList {
					{'Magikarp', 10},
					{'Goldeen',   5},
					{'Basculin',  3},
					{'Luvdisc',  1}]]
			}
		}
	},
chunk52 = {
		buildings = {'Gate22', 'PokeCenter', 'Gate23'},
		canFly = true,
		blackOutTo = 'chunk51',
		lighting = {
			FogColor = Color3.fromRGB(184, 212, 227),
			FogStart = 0,
			FogEnd = 100000,
		},
		regions = {
			['Port Decca'] = {
				SignColor = BrickColor.new('Teal').Color,
				Music = 4668636704,--301381728,
				BattleScene = 'Docks',
				RodScene = 'Docks',
				MusicVolume = 0.81,
				},
			},
	},
['LostIslands'] = {
        blackOutTo = 'chunk52',
        canFly = true,
        regions = {
            ['Lost Islands'] = {
                Music = 6355088088,--317351319,
                MusicVolume = .8,
                SignColor = BrickColor.new('Brick yellow').Color,
                BattleScene = 'Docks',
                Grass = EncounterList {
                    {'Rockruff', 15, 20, 1},
					{'Yungoos', 15, 18, 7},
					{'Bounsweet', 13, 20, 4},
					{'Pikipek', 15, 20, 7},
					{'Sandygast',   15, 20, 15, 'night'},
					{'Crabrawler', 10, 20, 7},
					{'Cutiefly', 15, 20, 7},
                    {'Grubbin', 20, 21, 3},
                    {'Rattata', 20, 30,   2, nil, true, 'alola'},
                    },
				OldRod = OldRodList {
					{'Magikarp', 50},
				},
				GoodRod = GoodRodList {
					{'Tapu Fini', 1},
					{'Tentacool', 20},
					{'Finneon', 30},
					{'Gyarados', 2},
					{'Luvdisc',   2},
					
				    },

			    Surf = EncounterList { 
				    {'Magikarp', 13, 16, 40},
					{'Goldeen', 13, 16, 20},
					{'Krabby', 13, 16, 35},
				    }
            }
        }
    },	
chunk53 = {
		buildings = {'Gate23'},
		canFly = true,
		blackOutTo = 'chunk52',
		lighting = {
			FogColor = Color3.fromRGB(184, 212, 227),
			FogStart = 0,
			FogEnd = 10000000,
		},
		regions = {
			['Decca Beach'] = {
				SignColor = BrickColor.new('Gold').Color,
				Music = 3099452984,
				BattleScene = 'Decca',
				RodScene = 'Decca',
				MusicVolume = routeMusicVolume,
				    OldRod = OldRodList {
					{'Tentacool', 60},
					{'Finneon',   20},
				},
					GoodRod = GoodRodList {
					{'Tentacool', 60},
					{'Finneon', 20},
					{'Gyarados', 8},
					{'Luvdisc',   2},
				},
                    Surf = EncounterList { 
					{'Tentacruel', 30, 40, 5},
					{'Carvanha', 30, 40, 5},
					{'Lumineon', 30, 40, 3},
					{'Mantine', 30, 40, 1}
				}
				
				
				},
			},
		},
chunk69 = {
        blackOutTo = 'chunk52',
        regions = {
            ['Route 17'] = {
                SignColor = BrickColor.new('Deep blue').Color,
                Music = 3099465642,
                BattleScene = 'Docks',
                RodScene = 'Docks',
                OldRod = OldRodList {
                    {'Tentacool', 50},
                    {'Goldeen',  10},
                    {'Finneon',   5},
                    {'Buizel',   1},
                },
                GoodRod = GoodRodList {
                    {'Wailmer', 5},
                    {'Tentacool',  5},
                    {'Goldeen',   3},
                    {'Skrelp',   3},
                    {'Finneon',   3},
                    {'Horsea',   3},
					{'Pyukumuku',   1},
					{'Buizel',   1},
					{'Bruxish',   1},
                },
				Surf = EncounterList { 
					{'Wailmer', 31, 39, 5},
					{'Tentacruel', 31, 39, 5},
					{'Lumineon', 31, 39, 3},
					{'Seaking', 31, 39, 3},
					{'Skrelp', 31, 39, 3},
					{'Horsea', 31, 39, 3},
					{'Pyukumuku', 31, 39, 1},
					{'Floatzel', 31, 39, 1},
				}    
            }
        }
    },
chunk54 = {
		buildings = {'Gate24','PokeCenter'},
		canFly = true,
		blackOutTo = 'chunk53',
		lighting = {
			FogColor = Color3.fromRGB(184, 212, 227),
			FogStart = 0,
			FogEnd = 10000000,
		},
		regions = {
			['Crescent Town'] = {
				Music = 3861092894,--301381728,
				BattleScene = 'Docks',
				RodScene = 'Docks',
				MusicVolume = 0.81,
				 OldRod = OldRodList {
					{'Finneon', 60},
					{'Goldeen',   20},
					{'Tentacool',   20},
					{'Clamperl',   3},
					--{'Remoraid',  2}
				},
					GoodRod = GoodRodList {
					{'Binacle', 20},
					{'Tentacool', 20},
					{'Frillish', 20},
					{'Goldeen',   5},
					{'Finneon',   5},
					{'Clamperl',   3},
					--{'Dhelmise',   3},
				},
				},
			},
		},		
chunk55 = {
		buildings = {'Gate24'},
		canFly = true,
		blackOutTo = 'chunk54',
		lighting = {
			FogColor = Color3.fromRGB(32, 116, 19),
			FogStart = 0,
			FogEnd = 200,
		},
		regions = {
			['Route 18'] = {
			Music = 660444233,--301381728,
			 Grass = EncounterList {
					{'Swalot',     34, 42,  10},
					{'Croagunk',  34, 42,  5},
					{'Toxicroak',  36, 42,  5},
					--{'Ribombee',  34, 42,  2},
					{'Skorupi',  34, 42,  5},
					{'Drapion',  34, 42,  5},
					{'Carnivine',  34, 42,  5},
					{'Grimer',  34, 42,  2},
					{'Goomy',  34, 42,  2},

		        },
				BattleScene = 'Swamp',
				MusicVolume = 0.81,
				},
			},
		},
chunk56 = {
		canFly = false,
		blackOutTo = 'chunk55',
		lighting = {
			FogColor = Color3.fromRGB(47, 191, 7),
			FogStart = 0,
			FogEnd = 100000,
		},
		regions = {
			['Aborille Outpost'] = {
				Music = 4549058855,--301381728,
				BattleScene = 'Swamp',
				MusicVolume = 0.81,
					GrassNotRequired = true,
					RTDDisabled = true,
				GrassEncounterChance = 3,
				Grass = EncounterList {
					{'Mienfoo',     36, 40,  7},
					{'Wobbuffet',  36, 40,  6},
					{'Solrock',  36, 40,  4},
					{'Lunatone',  36, 40,  2},
		        },
					Hoops = EncounterList {{'Hoopa', 65, 65, 1, nil, false, 'Unbound'}}
					}
				},
			},
chunk57 = {
		canFly = false,
		blackOutTo = 'chunk54',
		lighting = {
			FogColor = Color3.fromRGB(47, 191, 7),
			FogStart = 0,
			FogEnd = 10000000,
		},
		regions = {
			['Eclipse Base'] = {
				Music = 3861109574,--301381728,
				BattleScene = 'Docks',
				MusicVolume = 0.81,
				},
			},
		},
chunk58 = {
		canFly = false,
		blackOutTo = 'chunk45',
		lighting = {
			FogColor = Color3.fromRGB(47, 191, 7),
			FogStart = 0,
			FogEnd = 100000,
		},
		regions = {
			['Martensite Chamber'] = {
				Music = 3861659188,--301381728,
				GrassNotRequired = true,
				GrassEncounterChance = 3,
				Grass = EncounterList {
					{'Unown',     10, 40,  99},
		        },
				BattleScene = 'RegisCave',
				MusicVolume = 0.81,
				},
			},
		},
chunk59 = {
		canFly = false,
		blackOutTo = 'chunk14',
		lighting = {
			FogColor = Color3.fromRGB(47, 191, 7),
			FogStart = 0,
			FogEnd = 100000,
		},
		regions = {
			['Dendrite Chamber'] = {
				Music = 3861659188,--301381728,
				GrassNotRequired = true,
				GrassEncounterChance = 3,
				Grass = EncounterList {
					{'Unown',     10, 40,  99},
		        },
				BattleScene = 'RegiceCave',
				MusicVolume = 0.81,
				},
			},
		},
		gym7 = {
		noHover = true,
		canFly = false,
		blackOutTo = 'chunk46',
		regions = {
			['Frostveil City Gym'] = {
				RTDDisabled = true,
				NoSign = true,
				Music = 4095177828,
				MusicVolume = 0.81,
				BattleScene = 'Gym7'
			}
		}
	},
chunk60 = {
		canFly = false,
		blackOutTo = 'chunk57',
		lighting = {
			FogColor = Color3.fromRGB(47, 191, 7),
			FogStart = 0,
			FogEnd = 10000000,
		},
		regions = {
			['Eclipse Base'] = {
				NoSign = true,
				Music = 316929620,--301381728,
				BattleScene = 'Docks',
				MusicVolume = 0.81,
				},
			},
		},
chunk61 = {
		canFly = false,
		blackOutTo = 'chunk6',
		lighting = {
			FogColor = Color3.fromRGB(47, 191, 7),
			FogStart = 0,
			FogEnd = 10000000,
		},
		regions = {
			['Calcite Chamber'] = {
				Music = 3861659188,--301381728,
				GrassNotRequired = true,
				GrassEncounterChance = 3,
				Grass = EncounterList {
					{'Unown',     10, 40,  99},
		        },
				BattleScene = 'RegirockCave',
				MusicVolume = 0.81,
				},
			},
		},
chunk62 = {
		canFly = true,
		buildings = {'PokeCenter'},
		lighting = {
			FogColor = Color3.fromRGB(47, 191, 7),
			FogStart = 0,
			FogEnd = 10000000,
		},
		regions = {
			['Rustboro City'] = {
				NoSign = false,
				Music = 5114397957,--301381728,
				BattleScene = 'CustomBeach',
				MusicVolume = 0.81,
				},
			},
		},
chunk63 = {
		canFly = false,
		blackOutTo = 'chunk6',
		lighting = {
			FogColor = Color3.fromRGB(47, 191, 7),
			FogStart = 0,
			FogEnd = 10000000,
		},
		regions = {
			['Titans Throng'] = {
				Music = 3861659188,--301381728,
				GrassNotRequired = true,
				GrassEncounterChance = 3,
				Grass = EncounterList {
					{'Unown',     40, 40,  10},
		        },
				BattleScene = 'RegirockCave',
				MusicVolume = 0.81,
				},
			},
		},
 chunk65 = {
		blackOutTo = 'chunk3',
		regions = {
			['Secret Lab'] = {
				RTDDisabled = true,
				CanFly = false,
				NoSign = true,
				IsDark = true,
				Music = 498677393,
				BattleScene = 'SecretLab',
			}
		}
	},
	
	chunk75 = {
		blackOutTo = 'chunk5',
		canFly = false,
		regions = {
			['Steam Chamber'] = {
				Music = 497197006,--317351319,
				MusicVolume = .8,
				SignColor = BrickColor.new('Burgundy').Color,
				BattleScene = 'Steamchamber',
				IsDark = true,
				GrassNotRequired = true,
				GrassEncounterChance = 4,
				Grass = EncounterList {
					{'Camerupt',   36, 40, 17},
					{'Torkoal',  36, 40, 20},
					{'Heatmor', 36, 40, 17},
					{'Magcargo',  36, 40,  8},
					{'Larvesta', 36, 40,  7},
				},
				Volcan = EncounterList
				{PDEvent = 'Volcanion'}
				{{'Volcanion', 60, 60, 1}}
			}
		}
	},
	
	gym8 = {
		noHover = true,
		canFly = false,
		blackOutTo = 'chunk54',
		regions = {
			['Cresent Island Gym'] = {
				RTDDisabled = true,
				NoSign = true,
				Music = 494378223,
				MusicVolume = 0.81,
				BattleScene = 'Docks'
			}
		}
	},
	UrAnthianHouse = {
		noHover = true,
		canFly = false,
		blackOutTo = 'chunk19',
		-- lighting ?
		regions = {
			['Your House'] = {
				RTDDisabled = false,
				NoSign = true,
				Music = {615714813, 608877390},
				BattleScene = 'Gym5'
			}
		}
	},
	Arcade = {
		noHover = true,
		canFly = false,
		blackOutTo = 'chunk19',
		-- lighting ?
		regions = {
			['Golden Pokeball - Arcade'] = {
				SignColor = BrickColor.new('Bright green').Color,
				RTDDisabled = false,
				NoSign = false,
				Music = {3861573765},
				BattleScene = 'Arcade',
				lighting = {
			Ambient = Color3.fromRGB(255, 12, 190),
			OutdoorAmbient = Color3.fromRGB(255, 12, 190),
--			TimeOfDay = '06:00:00',
				},
			}
		}
	},	
--]]
	--[[


	--]]
	
	
	['mining'] = {
		noHover = true,
		canFly = false,
		regions = {
			['Lagoona Trenches'] = {
				RTDDisabled = true,
				SignColor = Color3.new(78/400, 133/400, 191/400),--BrickColor.new('Smoky grey').Color,--'Reddish brown').Color,
				Music = 323075164,
			},
		},
	},
	-- sub-contexts
	['colosseum'] = {
		canFly = false,
		regions = {
			['Battle Colosseum'] = {
				SignColor = BrickColor.new('Light orange').Color,
				Music = 440053692,
			}
		}
	},
	['resort'] = {
		canFly = false,
		regions = {
			['Trade Resort'] = {
				SignColor = BrickColor.new('Pastel blue-green').Color,
				Music = {435780183, 435780736},
--				MusicVolume = .3,
			}
		}
	},
	rockSmashEncounter = EncounterList {Locked = true} {
		{'Dwebble', 15, 20, 7},
		{'Shuckle', 15, 20, 1},
	},
	roamingEncounter = { -- all @ lv 40
		Jirachi = {{'Jirachi', 4}},
		Shaymin = {{'Shaymin', 4}},
		Victini = {{'Victini', 4}},
		RNatureForces = {{'Thundurus', 3},
		                 {'Tornadus',  3}},
		Landorus = {{'Landorus', 2}},
		Heatran = {{'Heatran', 4}},
		Diancie = {{'Diancie', 4}},
		RBeastTrio = {{'Raikou',  3},
		              {'Entei',   3},
		              {'Suicune', 3}},
		LatiosLatias = {{'Latias',3},
		{'Latios',3}},
		Mew = {{'Mew', 3}},
		DefeatHoopa = {{'Hoopa',  3}},
		Volcanion = {{'Volcanion', 3}}
	}
}

chunks.encounterLists = encounterLists
return chunks