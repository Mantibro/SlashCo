{
	"Manifest": {
		"comment": "Every setting in this individual config is optional, but all maps need a name and spawnpoints to work.",
		"Name": "Template",
		"Author": "Manti, Octo, textstack",
		"Default": true,
		"MinimumPlayers": 1,
		"aalComment": "AlwaysAddLegacySettings - Maps with SlashCo entities will ignore all legacy config positions/settings. This option bypasses this.",
		"AlwaysAddLegacySettings": false,
		"dnuComment": "DoNotUseThisConfig - prevents this config from being used in-game at all.",
		"DoNotUseThisConfig": true
	},
	"comment": "All settings below are legacy settings. You don't need any of these if you are using Hammer to make maps.",
	"Spawnpoints": {
		"comment": "The positions that employees/survivors and slashers spawn at.",
		"Slasher": {
			"comment": "Spawnpoint configs are in a numbered list, with position and angle.",
			"comment1": "Position is the world position of the spawn point.".
			"comment2": "Angle can either be a number for yaw or a list of pitch/yaw/roll.",
			"1": {
				"pos": [0, 0, 0],
				"ang": 0
			},
			"2": {
				"pos": [0, 0, 0],
				"ang": 0
			}

		},
		"Survivor": {
			"1": {
				"pos": [0, 0, 0],
				"ang": 0
			}
		}
	},
	"Generators": {
		"cComment": "Count - Number of generators that spawn.",
		"comment": "When set to -1, the game will use the default setting. Alternatively, remove this line entirely.",
		"Count": -1,
		"nComment": "Needed - Number of generators that are needed for an escape helicopter to arrive.",
		"Needed": -1,
		"Spawnpoints": {
			"1": {
				"pos": [0, 0, 0],
				"ang": [0, 0, 0],
				"comment": "Weight and Forced can be specified for generator, gas can, item, battery, and exposure gas can spawns.",
				"wComment": "Weight - Determine how rare this spawn is selected. Lower values mean more rare. Default is 10.",
				"Weight": 10,
				"fComment": "Forced - If true, this spawnm is always prioritized first for spawning.",
				"Forced": true
			},
			"2": {
				"pos": [0, 0, 0],
				"ang": [0, 0, 0],
			}
		}
	},
	"Helicopter": {
		"IntroLocation": {
			"comment": "The start location for the intro helicopter at the start of the round.",
			"pos":  [0, 0, 0],
			"ang":  [0, 0, 0]
		},
		"StartLocation": {
			"comment": "The intro helicopter deletes itself after reaching this position.",
			"comment1": "The escape helicopter both spawns at this position and ends the round when it returns to this position.",
			"pos":  [0, 0, 0]
		},
		"Spawnpoints": {
			"1": {
				"pos":  [0, 0, 0],
				"ang":  [0, 0, 0]
			}
		}
	},
	"GasCans": {
		"cComment": "Count - Number of gas cans to spawn. Should never be below the generator count multiplied by the gas cans needed per generator.",
		"Count": -1,
		"nComment": "NeededPerGenerator - Number of gas cans needed to fully fuel a generator.",
		"NeededPerGenerator": -1,
		"Spawnpoints": {
			"1": {
				"pos":  [0, 0, 0],
				"ang":  [0, 0, 0]
			},
			"2": {
				"pos": [0, 0, 0],
				"ang": [0, 0, 0]
			},
			"3": {
				"pos": [0, 0, 0],
				"ang": [0, 0, 0]
			},
			"4": {
				"pos": [0, 0, 0],
				"ang": [0, 0, 0]
			},
			"5": {
				"pos": [0, 0, 0],
				"ang": [0, 0, 0]
			},
			"6": {
				"pos": [0, 0, 0],
				"ang": [0, 0, 0]
			},
			"7": {
				"pos": [0, 0, 0],
				"ang": [0, 0, 0]
			},
			"8": {
				"pos": [0, 0, 0],
				"ang": [0, 0, 0]
			},
			"9": {
				"pos": [0, 0, 0],
				"ang": [0, 0, 0]
			},
			"10": {
				"pos": [0, 0, 0],
				"ang": [0, 0, 0]
			}
		}
	},
	"Items": {
		"igcComment": "IncludeGasCanSpawns - Set to allow these spawn points to also act as spawns for gas cans.",
		"IncludeGasCanSpawns": false,
		"Spawnpoints": {
			"1": {
				"pos": [0, 0, 0],
				"ang": [0, 0, 0]
			}
		}
	},
	"Batteries": {
		"Spawnpoints": {
			"comment": "The outer list corresponds to a generator spawn (specified above). Each generator has its own list of batteries.",
			"1": {
				"1": {
					"pos": [0, 0, 0],
					"ang": [0, 0, 0]
				}
			}
		}
	},
	"Offerings": {
		"Exposure": {
			"comment": "These are gas can spawns that should be out in the open and easy to reach.",
			"Spawnpoints": {
				"1": {
					"pos": [0, 0, 0],
					"ang": [0, 0, 0]
				}
			}
		}
	}
}