--[[
██████╗░░█████╗░████████╗░█████╗░████████╗██╗░██████╗░░███╗░░░░██╗██╗░░██╗██╗
██╔══██╗██╔══██╗╚══██╔══╝██╔══██╗╚══██╔══╝██║██╔════╝░████║░░░██╔╝██║░██╔╝██║
██████╔╝██║░░██║░░░██║░░░███████║░░░██║░░░██║╚█████╗░██╔██║░░██╔╝░██║██╔╝░██║
██╔═══╝░██║░░██║░░░██║░░░██╔══██║░░░██║░░░██║░╚═══██╗╚═╝██║░░███████║███████║
██║░░░░░╚█████╔╝░░░██║░░░██║░░██║░░░██║░░░██║██████╔╝███████╗╚════██║╚════██║
╚═╝░░░░░░╚════╝░░░░╚═╝░░░╚═╝░░╚═╝░░░╚═╝░░░╚═╝╚═════╝░╚══════╝░░░░░╚═╝░░░░░╚═╝
FORKED VERSION OF https://github.com/yiruzu/cloud-shop
-- For support, join our Discord server: https://discord.gg/jAnEnyGBef <---- not for the fork for the fork with the job lock there is no support
-- For icons, use Iconify: https://icon-sets.iconify.design
-- THIS IS A FORK THIS IS NOT THE ORIGINAL ALL CREDITS GOES TO: https://github.com/yiruzu
▒█▄░▒█ ▒█▀▀▀█ ▀▀█▀▀ 　 ▀▀█▀▀ ▒█░▒█ ▒█▀▀▀ 　 ▒█▀▀▀█ ▒█▀▀█ ▀█▀ ▒█▀▀█ ▀█▀ ▒█▄░▒█ ░█▀▀█ ▒█░░░ 
▒█▒█▒█ ▒█░░▒█ ░▒█░░ 　 ░▒█░░ ▒█▀▀█ ▒█▀▀▀ 　 ▒█░░▒█ ▒█▄▄▀ ▒█░ ▒█░▄▄ ▒█░ ▒█▒█▒█ ▒█▄▄█ ▒█░░░ 
▒█░░▀█ ▒█▄▄▄█ ░▒█░░ 　 ░▒█░░ ▒█░▒█ ▒█▄▄▄ 　 ▒█▄▄▄█ ▒█░▒█ ▄█▄ ▒█▄▄█ ▄█▄ ▒█░░▀█ ▒█░▒█ ▒█▄▄█]]
return {

	--[[ GENERAL CONFIGURATION ]]

	Framework = "qbxcore", -- Supported: "esx", "qbcore", "qbxcore" or "custom"
	Potatis144_NotifySystem = "okoknotify", -- Supported okoknotify or oxnotify
	DebugMode = true, -- Enable print statements for debugging
	WeaponAsItem = true, -- Treat weapons as inventory items (only supported inventorys)
	OxInventory = true, -- Uses ox_inventory exports if true -- if you dont use ox_inventory just install it and qbx needs oxinventory

	ImagePath = "nui://ox_inventory/web/images/",
	--[[
	Image Path Configuration Options:
	
	1. Local folder (relative to resource):
	   "img/items/"
	
	2. External resource (other resources' images):
	   "nui://RESOURCE_NAME/PATH_TO_IMAGES/"
	   Example: "nui://ox_inventory/web/images/" for ox_inventory images
	
	Note: Make sure the path ends with a forward slash "/"
	]]

	--[[ INTERACTION CONFIGURATION ]]

	-- Distance
	InteractionDistance = {
		TextUI = 3.0,
		Target = 3.5,
	},

	-- Target Settings (ox_target)
	Target = {
		Enabled = true,
		BoxZoneSize = vec3(4, 4, 4),
		DrawSprite = true,
		Icon = "fa-solid fa-cart-shopping", -- https://fontawesome.com

		DisablePeds = false, -- Disables all shop NPC Peds
		DisableMarkers = true, -- Disables all shop markers
	},

	--[[ SHOP CONFIGURATIONS ]]

	Shops = {
		["ica"] = {
			Locations = {
				vec4(372.8008, 328.1116, 103.5665, 262.1354), -- Clinton Ave
				vec4(2555.5110, 380.7313, 108.6229, 0.9597), -- Palomino Ave
				vec4(-3040.5376, 583.9359, 7.9089, 17.7445), -- Inseno Road
				vec4(-3243.9229, 1000.0519, 12.8307, 0.7583), -- Barbareno Rd
				vec4(-2193.4412, 4290.1064, 49.1743, 63.6331), -- Great Ocean Hwy
				vec4(1959.1536, 3741.4165, 32.3437, 298.7749), -- Niland Ave
				vec4(2676.5083, 3280.1863, 55.2411, 335.5104), -- Senora Fwy
				vec4(1728.5699, 6416.7671, 35.0372, 243.3380), -- Senora Fwy 2
				vec4(1134.2589, -983.0569, 46.4158, 278.9547), -- El Rancho Blvd
				vec4(-1486.7350, -377.5593, 40.1634, 132.9464), -- Prosperity St
				vec4(-2966.3162, 391.5883, 15.0433, 86.4455), -- Great Ocean Hwy
				vec4(24.5062, -1345.5989, 29.4970, 263.3659), -- Inoccence Blvd
				vec4(-561.7218, 286.8480, 82.1765, 266.4413), -- Milton Rd
				vec4(-47.2886, -1758.5280, 29.4210, 45.3676), -- Davis Ave
				vec4(1165.0068, -323.6485, 69.2051, 101.2836), -- West Mirrow Drive
				vec4(-706.0665, -914.6005, 19.2156, 82.3892), -- Palomino Ave
				vec4(-1819.4907, 793.5951, 138.0846, 132.5959), -- Banham Canyon Dr
				vec4(549.2471, 2669.6699, 42.1565, 96.9846), -- Route 68
				vec4(1392.0671, 3606.1155, 34.9809, 203.5101), -- Algonquin Blvd
				vec4(1984.2482, 3054.3589, 47.2151, 240.0611), -- Panorama Dr
				vec4(161.84, 6642.92, 31.71, 219.12) -- kevenze sandy
			},
			Categories = {
				{ name = "Alla produkter", type = "all", icon = "ic:round-clear-all" }, --! Required for all shops
				{ name = "Mat", type = "Mat", icon = "mdi:food-drumstick" },
				{ name = "Dryck", type = "Dryck", icon = "ion:water-sharp" },
				{ name = "Snus", type = "Snus", icon = "tabler:circle-letter-s" },
				{ name = "Hushåll", type = "hushall", icon = "material-symbols:shopping-bag-outline-sharp" },
			},
			Items = {
				-- Food
				{ name = "bread", label = "Bröd", category = "Mat", price = 17 },
				{ name = "burger", label = "Burgare", category = "Mat", price = 24 },
				{ name = "fries", label = "Pommes", category = "Mat", price = 20 },
				{ name = "pizza_margherita", label = "Pizza slice", category = "Mat", price = 25 },

				-- Drinks
				{ name = "water", label = "Vatten flaska", category = "Dryck", price = 12 },
				{ name = "cocacola", label = "Coca-Cola", category = "Dryck", price = 14 },
				{ name = "cocacola-zero", label = "Coca-Cola Zero", category = "Dryck", price = 14 },
				{ name = "pepsi-max", label = "Pepsi MAX", category = "Dryck", price = 14 },

				-- snus
				{ name = "siberia_black_white_dry_portion", label = "Siberia Black White Dry Portion", category = "Snus", price = 58 },
				{ name = "siberia_white_dry_portion", label = "Siberia White Dry Portion", category = "Snus", price = 58 },
				{ name = "helwit_cola_slim", label = "Helwit Cola Slim", category = "Snus", price = 41 },
				{ name = "xqs_tropical_slim_strong", label = "XQS Tropical Slim Strong", category = "Snus", price = 42 },
				{ name = "xqs_blueberry_mint_slim_strong", label = "XQS Blueberry Mint Slim Strong", category = "Snus", price = 42 },
				{ name = "goteborgs_rape_white_portion", label = "Göteborgs Rapé White Portion", category = "Snus", price = 39 },
				{ name = "velo_blue_raspberry", label = "VELO Blue Raspberry", category = "Snus", price = 41 },
				{ name = "lundgrens_skane_stark", label = "Lundgrens Skåne Stark", category = "Snus", price = 40 },

				--hushåll
				{ name = "bakingsoda", label = "Bakpulver", category = "hushall", price = 22 },
				{ name = "empty_weed_bag", label = "Tom Frys-påse", category = "hushall", price = 4 },
				{ name = "flour", label = "Mjöl", category = "hushall", price = 19 },


			},
			Locales = {
				title = "Ica",
				tag = "24/7",
				description = "Välkommen till din lokala Ica butik,",
			},

			Potatis144_JobLock = false, -- enkelt det är ju bara att den låser till ett jobb
			--Potatis144_JobName = "ica",

			Blip = {
				Name = "Ica",
				Sprite = 59,
				Color = 0,
				Scale = 0.8,
			},
			NpcPed = {
				Model = `mp_m_shopkeep_01`,
				Scenario = "WORLD_HUMAN_AA_SMOKE",
			},
			--[[
			Marker = {
				Type = 20,
				Size = vec3(0.7, 0.7, 0.7),
				Color = { 65, 133, 235, 120 },
				BobUpAndDown = false,
				FaceCamera = false,
				Rotate = true,
			},
			]]
			RenderDistance = 15.0, -- Distance at which the marker or NPCs are visible
			License = {
				Required = false, -- Whether a license is required to access the shop
				BuyDialog = true, -- Displays a dialog prompting the player to purchase the required license
				Type = "weapon", -- The type of the required license (e.g., "weapon")
				TypeLabel = "Weapon License", -- The display name of the required license
				Price = 1000, -- The cost of the license
			},
		},

		["systembolaget"] = {
			Locations = {
				vec4(-1221.4543, -908.0496, 12.3263, 36.5340), -- San Andreas Ave
			},
			Categories = {
				{ name = "alcohol", type = "all", icon = "ic:round-clear-all" }, --! Required for all shops
				{ name = "ÖL", type = "beer", icon = "mdi:bottle-soda-outline" },
				{ name = "Cider", type = "cider", icon = "mdi:bottle-soda-outline" },
				{ name = "Sprit", type = "sprit", icon = "mdi:bottle-soda-outline" },
				{ name = "Vit vin", type = "vit_vin", icon = "mdi:bottle-soda-outline" },
				{ name = "Röt vin", type = "röt_vin", icon = "mdi:bottle-soda-outline" },
				{ name = "Mousserande vin", type = "mousserande_vin", icon = "mdi:bottle-soda-outline" },
				{ name = "Rosé vin", type = "rose_vin", icon = "mdi:bottle-soda-outline" },

			},
			Items = {

				-- öl
				{ name = "Heineken", label = "Heineken", category = "beer", price = 16 },
				{ name = "carlsberg_export", label = "Carlsberg Export", category = "beer", price = 18 },
				{ name = "swedish_elk_brew", label = "Swedish Elk Brew", category = "beer", price = 15 },
				{ name = "bryggmastarens_basta_mellano", label = "Bryggmästarens Bästa Mellanöl", category = "beer", price = 15 },
				{ name = "mariestads_continental", label = "Mariestads Continental", category = "beer", price = 15 },
				{ name = "norrlands_guld_export", label = "Norrlands Guld Export", category = "beer", price = 14 },
				{ name = "eriksberg", label = "Eriksberg", category = "beer", price = 19 },

				--cider
				{ name = "briska_ananas", label = "Briska Ananas", category = "cider", price = 18 },
				{ name = "somersby_pear_cider", label = "Somersby Pear Cider", category = "cider", price = 18 },
				{ name = "ahlafors_lingon", label = "Ahlafors Lingon", category = "cider", price = 26 },

                --sprit
				{ name = "absolut_vodka", label = "Absolut Vodka", category = "sprit", price = 249 },
				{ name = "sierra_tequila_blanco", label = "Sierra Tequila Blanco", category = "sprit", price = 329 },
				{ name = "captain_morgan_spiced_gold", label = "Captain Morgan Spiced Gold", category = "sprit", price = 261 },
				{ name = "hallands_gin", label = "Hallands Gin", category = "sprit", price = 189 },
				{ name = "jim_beam_bourbon", label = "Jim Beam Bourbon", category = "sprit", price = 150 },

			    -- vit vin
				{ name = "louis_latour", label = "Louis Latour", category = "vit_vin", price = 999 },

			    -- röt vin
				{ name = "barolo_mosconi_pio_cesare", label = "Barolo Mosconi Pio Cesare", category = "röt_vin", price = 1178 },
				
				-- mousserande vin
				{ name = "guldkula_brut_reserve", label = "Guldkula Brut Resérve", category = "mousserande_vin", price = 299 },

				-- rose vin
				{ name = "perfect_day", label = "Perfect Day", category = "rose_vin", price = 99 },

			},
			Locales = {
				mainTitle = "Systembolaget",
				mainTag = "24/7",
				mainDescription = "Välkommen till Systembolaget.",
			},
			Blip = {
				Name = "Systembolaget",
				Sprite = 47,
				Color = 0,
				Scale = 0.8,
			},
			
			Potatis144_JobLock = false, -- enkelt det är ju bara att den låser till ett jobb
			--Potatis144_JobName = "systembolaget",

			NpcPed = {
				Model = `mp_m_shopkeep_01`,
				Scenario = "WORLD_HUMAN_AA_COFFEE",
			},
						--[[
			Marker = {
				Type = 20,
				Size = vec3(0.7, 0.7, 0.7),
				Color = { 65, 133, 235, 120 },
				BobUpAndDown = false,
				FaceCamera = false,
				Rotate = true,
			},
			]]
			RenderDistance = 15.0, -- Distance at which the marker or NPCs are visible
			License = {
				Required = false, -- Whether a license is required to access the shop
				BuyDialog = true, -- Displays a dialog prompting the player to purchase the required license
				Type = "weapon", -- The type of the required license (e.g., "weapon")
				TypeLabel = "Weapon License", -- The display name of the required license
				Price = 1000, -- The cost of the license
			},
		},

		["customs_shop"] = {
			Locations = {
				vec4(44.56, 6303.63, 31.22, 214.32), --paleto
				vec4(-2110.29, 3280.54, 38.73, 173.31), --shady
                vec4(1130.17, -1304.62, 34.74, 358.37) --mekonomen
			},
			Categories = {
				{ name = "Alla produkter", type = "all", icon = "ic:round-clear-all" }, --! Required for all shops
				{ name = "Uppgraderingar", type = "upg", icon = "carbon:tool-box" },
				{ name = "Reparation", type = "rep", icon = "material-symbols:service-toolbox-outline-sharp" },
				{ name = "Kosmetika", type = "cos", icon = "solar:remote-controller-2-outline" },

			},
			Items = {

				-- uppgraderingar
				{ name = "engine_s", label = "Motor", category = "upg", price = 12000 },
				{ name = "transmission_s", label = "Transmission", category = "upg", price = 12000 },
				{ name = "suspension_s", label = "Fjädring", category = "upg", price = 12000 },
				{ name = "turbo_s", label = "Turbo", category = "upg", price = 12000 },
				{ name = "armour_s", label = "Kaross", category = "upg", price = 12000 },
				{ name = "brake_s", label = "Bromsar", category = "upg", price = 12000 },

				--Reparationer
				{ name = "mechanic_toolbox", label = "Mechanics verktygslåda", category = "rep", price = 7000 },
				{ name = "engine_repair_kit", label = "Motor reparationskit", category = "rep", price = 7000 },
				{ name = "body_repair_kit", label = "Kaross reparationskit", category = "rep", price = 7000 },

				--Kosmetika
				{ name = "cosmetics", label = "Kosmetiska", category = "cos", price = 1000 },
				{ name = "neons_controller", label = "Neonskontroll", category = "cos", price = 500 },
				{ name = "extras_controller", label = "Fordons extrafunktioner", category = "cos", price = 500 },

			},
			Locales = {
				mainTitle = "Biltema",
				mainTag = "24/7",
				mainDescription = "Välkommen till Biltema.",
			},
			Blip = {
				Name = "Varuhuset",
				Sprite = 47,
				Color = 0,
				Scale = 0.0,
			},

			Potatis144_JobLock = true, -- enkelt det är ju bara att den låser till ett jobb
			Potatis144_JobName = "meko, taxi",

			NpcPed = {
				Model = `mp_m_shopkeep_01`,
				Scenario = "WORLD_HUMAN_AA_COFFEE",
			},

			RenderDistance = 15.0, -- Distance at which the marker or NPCs are visible
			License = {
				Required = false, -- Whether a license is required to access the shop
				BuyDialog = false, -- Displays a dialog prompting the player to purchase the required license
				Type = "weapon", -- The type of the required license (e.g., "weapon")
				TypeLabel = "Mekaniker Licens", -- The display name of the required license
				Price = 1000, -- The cost of the license
			},
		},
		

		["net_on_net"] = {
			Locations = {
				vec4(148.89, -234.61, 54.42, 340.12), -- Iphone store
			},
			Categories = {
				{ name = "Alla produkter", type = "all", icon = "ic:round-clear-all" },
				{ name = "Iphone", type = "Iphone", icon = "tabler:device-mobile" },
				{ name = "Sim kort", type = "simcard", icon = "tabler:device-sim" },
			},
			Items = {
				-- iphone
				{ name = "okokphone", label = "Iphone", category = "Iphone", price = 12000 },
				{ name = "simcard", label = "Sim kort", category = "simcard", price = 49 },
			},
			Locales = {
				mainTitle = "net on net",
				mainTag = "net on net",
				mainDescription = "Välkommen till din net on net butiken.",
			},
			Blip = {
				Name = "Net on net",
				Sprite = 94,
				Color = 0,
				Scale = 0.8,
			},

			Potatis144_JobLock = false, -- enkelt det är ju bara att den låser till ett jobb
			--Potatis144_JobName = "net_on_net",

			NpcPed = {
				Model = `a_m_m_bevhills_02`,
				Scenario = "WORLD_HUMAN_AA_COFFEE",
			},
						--[[
			Marker = {
				Type = 20,
				Size = vec3(0.7, 0.7, 0.7),
				Color = { 65, 133, 235, 120 },
				BobUpAndDown = false,
				FaceCamera = false,
				Rotate = true,
			},
			]]
			RenderDistance = 15.0,
			License = {
				Required = false, -- Whether a license is required to access the shop
				BuyDialog = true, -- Displays a dialog prompting the player to purchase the required license
				Type = "weapon", -- The type of the required license (e.g., "weapon")
				TypeLabel = "Weapon License", -- The display name of the required license
				Price = 1000, -- The cost of the license
			},
		},

	},
}
