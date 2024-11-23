--[[ LOAD FILES ]]

local Config = require("shared.sh_config")
local Locales = require("shared.sh_locales")

--[[ VARIABLES & TABLES ]]

local shopPeds = {}
local inShop = false

--[[ UTILITY FUNCTIONS ]]

local function CreateBlips(coords, blipSettings)
	local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
	SetBlipSprite(blip, blipSettings.Sprite)
	SetBlipDisplay(blip, 4)
	SetBlipScale(blip, blipSettings.Scale)
	SetBlipColour(blip, blipSettings.Color)
	SetBlipAsShortRange(blip, true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString(blipSettings.Name)
	EndTextCommandSetBlipName(blip)
end

local function SpawnPed(pedModel, pedPos, pedScenario)
	if not IsModelInCdimage(pedModel) or not IsModelAPed(pedModel) then
		DebugPrint("Ped hash is not valid, failed to spawn ped.")
		return false
	end

	RequestModel(pedModel)
	while not HasModelLoaded(pedModel) do
		Wait(100)
	end

	local shopPed = CreatePed(0, pedModel, pedPos.x, pedPos.y, pedPos.z - 1, pedPos.w, false, false)
	while not DoesEntityExist(shopPed) do
		Wait(10)
	end

	if shopPed then
		SetEntityAsMissionEntity(shopPed, true, true)
		SetPedFleeAttributes(shopPed, 0, false)
		SetBlockingOfNonTemporaryEvents(shopPed, true)
		SetEntityInvincible(shopPed, true)
		FreezeEntityPosition(shopPed, true)
		TaskStartScenarioInPlace(shopPed, pedScenario, 0, true)
		SetModelAsNoLongerNeeded(shopPed)
		table.insert(shopPeds, { ped = shopPed, pos = pedPos })

		return shopPed
	end
end

local function FindShopPed()
	local playerPos = GetEntityCoords(cache.ped)
	for i = 1, #shopPeds do
		local pedData = shopPeds[i]
		local ped = pedData.ped
		local pedPos = pedData.pos
		if DoesEntityExist(ped) then
			local distance = #(vector3(pedPos.x, pedPos.y, pedPos.z) - playerPos)
			if distance <= 5.0 then return ped end
		end
	end

	return nil
end

local function ApplySpeechToPed(speechName, speechParam)
	local shopPed = FindShopPed()
	if shopPed and DoesEntityExist(shopPed) then
		while IsAmbientSpeechPlaying(shopPed) do
			Wait(100)
		end
		PlayPedAmbientSpeechNative(shopPed, speechName, speechParam)
	else
		DebugPrint("Shop ped not found or doesnt exist")
	end
end

local function DeleteDistantPeds(maxDistance)
	local playerPos = GetEntityCoords(cache.ped)
	for i = #shopPeds, 1, -1 do
		local pedData = shopPeds[i]
		local ped = pedData.ped
		local pedPos = pedData.pos

		if DoesEntityExist(ped) then
			local distance = #(vector3(pedPos.x, pedPos.y, pedPos.z) - playerPos)
			if distance > maxDistance then
				DeleteEntity(ped)
				table.remove(shopPeds, i)
			end
		end
	end
end

local function DeletePeds()
	for i = #shopPeds, 1, -1 do
		local pedData = shopPeds[i]
		local ped = pedData.ped
		if DoesEntityExist(ped) then DeleteEntity(ped) end
	end
	table.wipe(shopPeds)
end

local function OpenShop(shopIndex)
	ToggleHud(false)
	SendNUIMessage({ action = "toggleShop", showShop = true })
	SetNuiFocus(true, true)
	inShop = true

	local currentShop = Config.Shops[shopIndex]
	DebugPrint(json.encode({ "Categories:", currentShop.Categories, "Items:", currentShop.Items }))
	SendNUIMessage({ action = "setShopData", categories = currentShop.Categories, items = currentShop.Items })

	lib.callback.await("cloud-shop:server:InShop", false, true)
	TriggerScreenblurFadeIn(0)

	ApplySpeechToPed("Generic_Hi", "Speech_Params_Force")
end

local function CloseShop()
	ToggleHud(true)
	SendNUIMessage({ action = "toggleShop", showShop = false })
	SetNuiFocus(false, false)
	inShop = false

	lib.callback.await("cloud-shop:server:InShop", false, false)
	TriggerScreenblurFadeOut(0)

	ApplySpeechToPed("Generic_Bye", "Speech_Params_Force")
end

--[[ MAIN LOGIC ]]

local function CreatePoints(shop, data, shopPos)
	local shopPoint = lib.points.new({
		coords = shopPos,
		distance = data.RenderDistance,
	})

	function shopPoint:onEnter()
		if not (Config.Target.Enabled and Config.Target.RemovePed) and data.NpcPed then SpawnPed(data.NpcPed.Model, shopPos, data.NpcPed.Scenario) end
	end

	function shopPoint:onExit()
		if inShop then CloseShop() end
		DeleteDistantPeds(self.distance)
	end

	function shopPoint:nearby()
		---@diagnostic disable-next-line: missing-parameter
		if not (Config.Target.Enabled and Config.Target.RemoveMarker) and data.Marker and not inShop then DrawMarker(data.Marker.Type, self.coords.x, self.coords.y, self.coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, data.Marker.Size.x, data.Marker.Size.y, data.Marker.Size.z, data.Marker.Color[1], data.Marker.Color[2], data.Marker.Color[3], data.Marker.Color[4], data.Marker.BobUpAndDown, data.Marker.FaceCamera, 2, data.Marker.Rotate) end
		if not Config.Target.Enabled then
			local playerPed = cache.ped
			if self.isClosest and self.currentDistance < Config.Interaction.TextUIDistance and not (IsPedDeadOrDying(playerPed, true) or IsPedFatallyInjured(playerPed)) and not IsPedInAnyVehicle(playerPed, false) then
				if not inShop then TextUI(Locales.TextUI.OpenShop) end
				if IsControlJustReleased(0, 38) then OpenShop(shop) end
			end
		end
	end
end

local function CreateTargets(shop, coords)
	exports.ox_target:addBoxZone({
		coords = coords,
		size = Config.Target.BoxZoneSize,
		drawSprite = Config.Target.DrawSprite,
		options = {
			icon = Config.Target.Icon,
			label = Locales.Target.OpenShop,
			onSelect = function()
				OpenShop(shop)
			end,
			distance = Config.Interaction.TargetDistance,
			canInteract = function()
				return not IsPedInAnyVehicle(cache.ped, false)
			end,
		},
	})
end

--[[ INITIALIZATION ]]

for shop, data in pairs(Config.Shops) do
	for _, shopPos in ipairs(data.Locations) do
		CreateBlips(shopPos, data.Blip)
		CreatePoints(shop, data, shopPos)
		if Config.Target.Enabled then CreateTargets(shop, shopPos) end
	end
end

-- [[ NUI LOGIC ]]

local function HandleTransaction(transactionType, cartArray)
	local success, reason = lib.callback.await("cloud-shop:server:ProcessTransaction", false, transactionType, cartArray)
	DebugPrint(reason)

	local sound = success and "ROBBERY_MONEY_TOTAL" or "CHECKPOINT_MISSED"
	local soundSet = success and "HUD_FRONTEND_CUSTOM_SOUNDSET" or "HUD_MINI_GAME_SOUNDSET"
	PlaySoundFrontend(-1, sound, soundSet, true)

	return success
end

RegisterNuiCallback("shop:fetchData", function(data, cb)
	local label = data.label
	if not label then return end

	local actions = {
		closeShop = function()
			local success = pcall(CloseShop)
			cb(success)
		end,
		initShopData = function()
			cb({ locales = Locales.UI, imagePath = Config.ImagePath })
		end,
		payCart = function()
			DebugPrint("Payment Type:", data.type)

			local success = HandleTransaction(data.type, data.cart)
			if success then ApplySpeechToPed("Generic_Thanks", "Speech_Params_Force_Shouted_Critical") end
			cb(success)
		end,
	}

	local action = actions[label]
	if action then action() end
end)

-- [[ EVENT HANDLERS ]]

AddEventHandler("onResourceStop", function(resourceName)
	if GetCurrentResourceName() ~= resourceName then return end
	if inShop then CloseShop() end
	DeletePeds()
end)

AddEventHandler("gameEventTriggered", function(event, data)
	if event ~= "CEventNetworkEntityDamage" then return end
	local player, playerDead = data[1], data[4]
	if not IsPedAPlayer(player) then return end
	local currentPlayer = cache.playerId
	if playerDead and NetworkGetPlayerIndexFromPed(player) == currentPlayer and (IsPedDeadOrDying(player, true) or IsPedFatallyInjured(player)) then
		if inShop then CloseShop() end
	end
end)
