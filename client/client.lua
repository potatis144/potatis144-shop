---@diagnostic disable: need-check-nil, undefined-field

--[[ LOAD FILES ]]

local Config = require("shared.sh_config")
local Locales = require("locales." .. Config.Potatis144_Lang)

--[[ VARIABLES & TABLES ]]

local shopPeds = {}
local inShop = false
local currentShop = nil

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
    if not shopData then 
        DebugPrint("OpenShopUI called without valid shopData!")
        return 
    end -- Prevent errors

    DebugPrint("Shop Data Found:", json.encode(shopData))

    currentShop = shopData
    inShop = true

    ToggleHud(false)
    SendNUIMessage({ action = "toggleShop", showShop = true })
    SetNuiFocus(true, true)

    DebugPrint("[OpenShopUI]", json.encode({ "Categories:", currentShop.Categories, "Items:", currentShop.Items }))

    lib.callback.await("potatis-shop:server:InShop", false, true)
    TriggerScreenblurFadeIn(0)

    ApplySpeechToPed("Generic_Hi", "Speech_Params_Force")
end



local function BuyLicenseDialog()
	local buyLicenseDialog = lib.alertDialog({
		header = Locales.License.DialogHeader:format(currentShop.License.TypeLabel),
		content = Locales.License.DialogContent:format(currentShop.License.TypeLabel, currentShop.License.Price),
		centered = true,
		cancel = true,
		size = "xs",
	})
	if buyLicenseDialog == "confirm" then
		lib.callback.await("potatis-shop:server:InShop", false, true)

		local success, reason = lib.callback.await("potatis-shop:server:BuyLicense", false, currentShop)
		DebugPrint("[BuyLicenseDialog]", reason)

		local sound = success and "ROBBERY_MONEY_TOTAL" or "CHECKPOINT_MISSED"
		local soundSet = success and "HUD_FRONTEND_CUSTOM_SOUNDSET" or "HUD_MINI_GAME_SOUNDSET"
		PlaySoundFrontend(-1, sound, soundSet, true)

		lib.callback.await("potatis-shop:server:InShop", false, false)
	end
end

local function HandleShopWithLicense()
    if not currentShop or not currentShop.License then
        DebugPrint("HandleShopWithLicense: No valid shop or license data!")
        return
    end

    DebugPrint("Checking if player has license for:", currentShop.License.Type)

    local hasLicense = lib.callback.await("potatis-shop:server:HasLicense", false, currentShop.License.Type)
    if hasLicense then
        DebugPrint("Player has license, opening shop UI...")
        OpenShopUI(currentShop)
    else
        DebugPrint("Player does NOT have license.")
        if not currentShop.License.BuyDialog then 
			Potatis144_ClientNotify(Locales.License.LicenseRequired:format(currentShop.License.TypeLabel), "error")
        end
        if currentShop.License.BuyDialog then 
            BuyLicenseDialog() 
        end
    end
end

local function OpenShop(shopId)
    DebugPrint("OpenShop Triggered shopId:", shopId)

    local shopData = Config.Shops[shopId]
    if not shopData then
        DebugPrint("Invalid shopId:", shopId)
        return
    end

	if Config.Framework == "qbxcore" then -- qbxcore
    local playerData = exports.qbx_core:GetPlayerData()

    elseif Config.Framework == "esx" then -- esxcore
	local playerData = exports.ESX.GetPlayerData()

    elseif Config.Framework == "qbcore" then -- qbcore
    local playerData = exports.QBCore.GetPlayerData()

    elseif Config.Framework == "custom" then -- custom core
    local playerData = exports.custom.GetPlayerData()

    else
    DebugPrint("Error: Unknown framework in Change the config")
    return
end

    local job = playerData and playerData.job or nil
    local gang = playerData and playerData.gang or nil

    DebugPrint("Opening Shop:", shopId, "Gang:", gang and gang.name, "Required Gang:", shopData.Potatis144_GangName)
    DebugPrint("Opening Shop:", shopId, "Job:", job and job.name, "Required Job:", shopData.Potatis144_JobName)

    currentShop = shopData -- Set current shop properly

    -- Check for license requirements
    if shopData.License.Required then
        DebugPrint("Handling shop with license...")
        HandleShopWithLicense()
        return
    end

    -- Job lock
    if shopData.Potatis144_JobLock then
        local Potatis144_JobLock = {}
        for Potatis144_JobName in string.gmatch(shopData.Potatis144_JobName, "[^, ]+") do
            table.insert(Potatis144_JobLock, Potatis144_JobName)
        end
        
        local hasRequiredJob = false
        for _, requiredJob in ipairs(Potatis144_JobLock) do
            if job and job.name == requiredJob then
                hasRequiredJob = true
                break
            end
        end

        if hasRequiredJob then
            DebugPrint("Player has one of the required jobs, opening shop UI...")
            OpenShopUI(shopData)
        else
            DebugPrint("Player does not have the required job.")
            Potatis144_ClientNotify(Locales.Notification.WrongJob, "error")
<<<<<<< Updated upstream
=======
            return
>>>>>>> Stashed changes
        end
    end

    -- Gang lock
    if shopData.Potatis144_GangLock then
        local Potatis144_GangLock = {}
        for Potatis144_GangName in string.gmatch(shopData.Potatis144_GangName, "[^, ]+") do
            table.insert(Potatis144_GangLock, Potatis144_GangName)
        end
        
        local hasRequiredGang = false
        for _, requiredGang in ipairs(Potatis144_GangLock) do
            if gang and gang.name == requiredGang then
                hasRequiredGang = true
                break
            end
        end

        if hasRequiredGang then
            DebugPrint("Player has one of the required gangs, opening shop UI...")
            OpenShopUI(shopData)
        else
            DebugPrint("Player does not have the required gang.")
            Potatis144_ClientNotify(Locales.Notification.WrongGang, "error")
            return
        end
    end

    -- Om ingen gang- eller jobblockering finns, öppna butiken direkt
    DebugPrint("No job or gang requirement, opening shop UI...")
    OpenShopUI(shopData)
end		

local function CloseShopUI()
    ToggleHud(true)
    SendNUIMessage({ action = "toggleShop", showShop = false })
    SetNuiFocus(false, false)
    inShop = false
    currentShop = nil -- Reset the shop state

    lib.callback.await("potatis-shop:server:InShop", false, false)
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
			local isDead = IsPlayerDead(cache.playerId)
			if self.isClosest and self.currentDistance < Config.InteractionDistance.TextUI and not isDead and not IsPedInAnyVehicle(playerPed, false) then
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
	local success, reason = lib.callback.await("potatis-shop:server:ProcessTransaction", false, transactionType, cartArray)
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
		payCart = function()
			DebugPrint("[NUI:payCart] Payment Type:", data.type, "Cart Array:", json.encode(data.cart))

			local success = HandleTransaction(data.type, data.cart)
			if success then ApplySpeechToPed("Generic_Thanks", "Speech_Params_Force_Shouted_Critical") end
			cb(success)
		end,
		getCategories = function()
			cb({ categories = currentShop.Categories })
		end,
		getItems = function()
			cb({ items = currentShop.Items })
		end,
		getLocales = function()
			Locales.UI.mainHeader = currentShop.Locales
			cb({ imagePath = Config.ImagePath, locales = Locales.UI })
		end,
	}

	local action = actions[label]
	if action then action() end
end)

-- [[ EVENT HANDLERS ]]

AddEventHandler("onResourceStop", function(resourceName)
	if GetCurrentResourceName() ~= resourceName then return end
	if inShop then
		TriggerScreenblurFadeOut(0)
		CloseShopUI()
	end
	DeletePeds()
end)

AddEventHandler("gameEventTriggered", function(event, data)
	if event ~= "CEventNetworkEntityDamage" then return end
	local player, playerDead = data[1], data[4]
	if not IsPedAPlayer(player) then return end
	local currentPlayer = cache.playerId
	if playerDead and NetworkGetPlayerIndexFromPed(player) == currentPlayer and IsPlayerDead(cache.playerId) then
		if inShop then CloseShopUI() end
		TriggerScreenblurFadeOut(0)
	end
end)
