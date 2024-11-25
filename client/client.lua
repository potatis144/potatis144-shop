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
		DebugPrint("[SpawnPed] Ped hash is not valid, failed to spawn ped.")
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
		local ped, pedPos = pedData.ped, pedData.pos

		if DoesEntityExist(ped) then
			local distance = #(vector3(pedPos.x, pedPos.y, pedPos.z) - playerPos)
			if distance <= 5.0 then return ped end
		else
			DebugPrint("[FindShopPed] Ped does not exist.")
			return nil
		end
	end
	DebugPrint("[FindShopPed] No shop peds nearby.")
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
		DebugPrint("[ApplySpeechToPed] No valid shop ped to apply speech.")
	end
end

local function DeleteDistantPeds(maxDistance)
	local playerPos = GetEntityCoords(cache.ped)
	for i = #shopPeds, 1, -1 do
		local pedData = shopPeds[i]
		local ped, pedPos = pedData.ped, pedData.pos

		if DoesEntityExist(ped) then
			local distance = #(vector3(pedPos.x, pedPos.y, pedPos.z) - playerPos)
			if distance > maxDistance then
				DeleteEntity(ped)
				table.remove(shopPeds, i)
			end
		else
			DebugPrint("[DeleteDistantPeds] Ped does not exist.")
		end
	end
end

local function DeletePeds()
	for i = #shopPeds, 1, -1 do
		local pedData = shopPeds[i]
		local ped = pedData.ped
		if DoesEntityExist(ped) then
			DeleteEntity(ped)
		else
			DebugPrint("[DeletePeds] Ped does not exist.")
		end
	end
	table.wipe(shopPeds)
end

--[[ MAIN FUNCTIONS ]]

local function OpenShopUI(shopData)
	ToggleHud(false)
	SendNUIMessage({ action = "toggleShop", showShop = true })
	SetNuiFocus(true, true)
	inShop = true

	DebugPrint("[OpenShopUI]", json.encode({ "Categories:", shopData.Categories, "Items:", shopData.Items }))
	SendNUIMessage({
		action = "setShopData",
		locales = shopData.Locales,
		categories = shopData.Categories,
		items = shopData.Items,
	})

	lib.callback.await("cloud-shop:server:InShop", false, true)
	TriggerScreenblurFadeIn(0)

	ApplySpeechToPed("Generic_Hi", "Speech_Params_Force")
end

local function BuyLicenseDialog(shopData)
	local buyLicenseDialog = lib.alertDialog({
		header = Locales.License.DialogHeader:format(shopData.License.TypeLabel),
		content = Locales.License.DialogContent:format(shopData.License.TypeLabel, shopData.License.Price),
		centered = true,
		cancel = true,
		size = "xs",
	})
	if buyLicenseDialog == "confirm" then
		lib.callback.await("cloud-shop:server:InShop", false, true)

		local success, reason = lib.callback.await("cloud-shop:server:BuyLicense", false, shopData)
		DebugPrint("[BuyLicenseDialog]", reason)

		local sound = success and "ROBBERY_MONEY_TOTAL" or "CHECKPOINT_MISSED"
		local soundSet = success and "HUD_FRONTEND_CUSTOM_SOUNDSET" or "HUD_MINI_GAME_SOUNDSET"
		PlaySoundFrontend(-1, sound, soundSet, true)

		lib.callback.await("cloud-shop:server:InShop", false, false)
	end
end

local function HandleShopWithLicense(shopData)
	local hasLicense = lib.callback.await("cloud-shop:server:HasLicense", false, shopData.License.Type)
	if hasLicense then
		OpenShopUI(shopData)
	else
		if not shopData.License.BuyDialog then ClientNotify(Locales.License.LicenseRequired:format(shopData.License.TypeLabel), "error") end
		if shopData.License.BuyDialog then BuyLicenseDialog(shopData) end
	end
end

local function OpenShop(shopId)
	local shopData = Config.Shops[shopId]
	if shopData.License.Required then
		HandleShopWithLicense(shopData)
	else
		OpenShopUI(shopData)
	end
end

local function CloseShopUI()
	ToggleHud(true)
	SendNUIMessage({ action = "toggleShop", showShop = false })
	SetNuiFocus(false, false)
	inShop = false

	lib.callback.await("cloud-shop:server:InShop", false, false)
	TriggerScreenblurFadeOut(0)

	ApplySpeechToPed("Generic_Bye", "Speech_Params_Force")
end

--[[ MAIN LOGIC ]]

local function CreatePoints(shopId, shopData, shopPos)
	local shopPoint = lib.points.new({
		coords = shopPos,
		distance = shopData.RenderDistance,
	})

	function shopPoint:onEnter()
		if not (Config.Target.Enabled and Config.Target.DisablePeds) and shopData.NpcPed then SpawnPed(shopData.NpcPed.Model, shopPos, shopData.NpcPed.Scenario) end
	end

	function shopPoint:onExit()
		if inShop then CloseShopUI() end
		DeleteDistantPeds(self.distance)
	end

	function shopPoint:nearby()
		---@diagnostic disable-next-line: missing-parameter
		if not (Config.Target.Enabled and Config.Target.DisableMarkers) and shopData.Marker and not inShop then DrawMarker(shopData.Marker.Type, self.coords.x, self.coords.y, self.coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, shopData.Marker.Size.x, shopData.Marker.Size.y, shopData.Marker.Size.z, shopData.Marker.Color[1], shopData.Marker.Color[2], shopData.Marker.Color[3], shopData.Marker.Color[4], shopData.Marker.BobUpAndDown, shopData.Marker.FaceCamera, 2, shopData.Marker.Rotate) end
		if not Config.Target.Enabled then
			local playerPed = cache.ped
			if self.isClosest and self.currentDistance < Config.InteractionDistance.TextUI and not (IsPedDeadOrDying(playerPed, true) or IsPedFatallyInjured(playerPed)) and not IsPedInAnyVehicle(playerPed, false) then
				if not inShop then TextUI(Locales.OpenShop.TextUI) end
				if IsControlJustReleased(0, 38) then OpenShop(shopId) end
			end
		end
	end
end

local function CreateTargets(shopId, shopPos)
	exports.ox_target:addBoxZone({
		coords = shopPos,
		size = Config.Target.BoxZoneSize,
		drawSprite = Config.Target.DrawSprite,
		options = {
			icon = Config.Target.Icon,
			label = Locales.OpenShop.Target,
			onSelect = function()
				OpenShop(shopId)
			end,
			distance = Config.InteractionDistance.Target,
			canInteract = function()
				return not IsPedInAnyVehicle(cache.ped, false)
			end,
		},
	})
end

--[[ INITIALIZATION ]]

for shopId, shopData in pairs(Config.Shops) do
	for _, shopPos in ipairs(shopData.Locations) do
		CreateBlips(shopPos, shopData.Blip)
		CreatePoints(shopId, shopData, shopPos)
		if Config.Target.Enabled then CreateTargets(shopId, shopPos) end
	end
end

-- [[ NUI LOGIC ]]

local function HandleTransaction(transactionType, cartArray)
	local success, reason = lib.callback.await("cloud-shop:server:ProcessTransaction", false, transactionType, cartArray)
	DebugPrint("[BuyLicenseDialog]", reason)

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
			local success = pcall(CloseShopUI)
			cb(success)
		end,
		initShopData = function()
			cb({ locales = Locales.UI, imagePath = Config.ImagePath })
		end,
		payCart = function()
			DebugPrint("[NUI:payCart] Payment Type:", data.type, "Cart Array:", json.encode(data.cart))

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
	if inShop then CloseShopUI() end
	TriggerScreenblurFadeOut(0)
	DeletePeds()
end)

AddEventHandler("gameEventTriggered", function(event, data)
	if event ~= "CEventNetworkEntityDamage" then return end
	local player, playerDead = data[1], data[4]
	if not IsPedAPlayer(player) then return end
	local currentPlayer = cache.playerId
	if playerDead and NetworkGetPlayerIndexFromPed(player) == currentPlayer and (IsPedDeadOrDying(player, true) or IsPedFatallyInjured(player)) then
		if inShop then CloseShopUI() end
		TriggerScreenblurFadeOut(0)
	end
end)
