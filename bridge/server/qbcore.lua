local Config = require("shared.sh_config")
local Locales = require("locales." .. Config.Potatis144_Lang)

if Config.Framework ~= "qbcore" then return end

local QBCore = exports["qb-core"]:GetCoreObject()

local inShop = {}

local function GetPlayerId(source)
    if not source or source == 0 then return nil end
    return QBCore.Functions.GetPlayer(source)
end

local function GetPlayerJob(source)
    local Player = GetPlayerId(source)
    if not Player then return nil end
    return Player.PlayerData.job
end

local function GetPlayerGang(source)
    local Player = GetPlayerId(source)
    if not Player then return nil end
    return Player.PlayerData.gang
end

local function CanCarryItem(source, itemName, itemQuantity)
    if Config.OxInventory then
        return exports.ox_inventory:CanCarryItem(source, itemName, itemQuantity)
    else
        return exports["qb-inventory"]:CanAddItem(source, itemName, itemQuantity)
    end
end

local function AddItem(source, itemName, itemQuantity)
    if Config.OxInventory then
        return exports.ox_inventory:AddItem(source, itemName, itemQuantity)
    else
        local isWeapon = itemName:sub(1, 7):lower() == "weapon_"
        if isWeapon then return exports["qb-inventory"]:AddItem(source, itemName, itemQuantity, false, { quality = 100 }, "potatis-shop:AddWeapon") end
        return exports["qb-inventory"]:AddItem(source, itemName, itemQuantity, false, false, "potatis-shop:AddItem")
    end
end

local function HasLicense(source, licenseType)
	if not source or source == 0 then return false end
	if not licenseType then return false end

	local Player = GetPlayerId(source)
	if not Player then return false end

	return Player.PlayerData.metadata.licences[licenseType]
end

local function BuyLicense(source, shopData)
    if not source or source == 0 then return false, "Invalid source" end
    if not shopData or next(shopData) == nil then return false, "Invalid or empty shop data" end
    if not inShop[source] then return false, "Not in shop state" end

	local Player = GetPlayerId(source)
	if not Player then return false, "Player not found" end

	local licenseType = shopData.License.Type
	local amount = shopData.License.Price

	local moneyAvailable = Player.Functions.GetMoney("cash")
	local bankAvailable = Player.Functions.GetMoney("bank")

    local accountType
    if moneyAvailable >= amount then
        accountType = "cash"
    elseif bankAvailable >= amount then
        accountType = "bank"
    else
        Potatis144_ServerNotify(source, Locales.License.NoMoney:format(licenseType), "error")
        return false, "No money"
    end

	Player.Functions.RemoveMoney(accountType, amount)

	local licenseTable = Player.PlayerData.metadata.licences
	licenseTable[licenseType] = true
	Player.Functions.SetMetaData("licences", licenseTable)

    ServerNotify(source, Locales.License.PurchaseSuccess:format(licenseType, amount), "info")
	return true, "Successfully bought license"
end

if not Config.WeaponAsItem and not Config.OxInventory then
	function HasWeapon(source, weaponName)
		-- add your logic here
	end

	function AddWeapon(source, weaponName)
		-- add your logic here
	end
end

local function ProcessTransaction(source, type, cartArray)
    if not source or source == 0 then return false, "Invalid source" end
    if not cartArray or #cartArray == 0 then return false, "Invalid or empty cart array" end
    if not inShop[source] then return false, "Not in shop state" end

    local Player = GetPlayerId(source)
    if not Player then return false, "Player not found" end

    local accountType = type == "bank" and "bank" or "cash"
    local totalCartPrice = 0

    for _, item in ipairs(cartArray) do
        local availableMoney = Player.Functions.GetMoney(accountType) or 0
        local totalItemPrice = (item.price * item.quantity) or 0

        if availableMoney >= totalItemPrice then
            local isWeapon = item.name:sub(1, 7):lower() == "weapon_"
            if isWeapon and not Config.WeaponAsItem and not Config.OxInventory then
                if not HasWeapon(source, item.name) then
                    Player.Functions.RemoveMoney(accountType, totalItemPrice)
                    AddWeapon(source, item.name)
                    totalCartPrice = totalCartPrice + totalItemPrice
                else
                    Potatis144_ServerNotify(source, Locales.Notification.HasWeapon:format(item.label), "error")
                end
            else
                if CanCarryItem(source, item.name, item.quantity) then
                    Player.Functions.RemoveMoney(accountType, totalItemPrice)
                    AddItem(source, item.name, item.quantity)
                    totalCartPrice = totalCartPrice + totalItemPrice
                else
                    Potatis144_ServerNotify(source, Locales.Notification.CantCarry:format(item.label), "error")
                end
            end
        else
            Potatis144_ServerNotify(source, Locales.Notification.NoMoney:format(item.label), "error")
        end
    end

    if totalCartPrice > 0 then
        Potatis144_ServerNotify(source, Locales.Notification.PurchaseSuccess:format(totalCartPrice), "success")
        return true, ("Purchased item(s) for $%s"):format(totalCartPrice)
    end
    return false, "No items purchased"
end

lib.callback.register("potatis-shop:server:HasLicense", HasLicense)
lib.callback.register("potatis-shop:server:BuyLicense", function(source, shopData)
	local success, reason = BuyLicense(source, shopData)
	return success, reason
end)
lib.callback.register("potatis-shop:server:ProcessTransaction", function(source, type, cartArray)
	local success, reason = ProcessTransaction(source, type, cartArray)
	return success, reason
end)


function GetNearestShop(playerCoords)
    for shopId, shopConfig in pairs(Config.Shops) do
        for _, location in ipairs(shopConfig.Locations) do
            local shopCoords = vec3(location.x, location.y, location.z)
            if #(playerCoords - shopCoords) < 5.0 then -- Adjust distance threshold as necessary
                return shopId, shopConfig
            end
        end
    end
    return nil, nil -- No nearby shop found
end

lib.callback.register("potatis-shop:server:InShop", function(source, status)
    local playerCoords = GetEntityCoords(GetPlayerPed(source))
    local shopId, shopConfig = GetNearestShop(playerCoords)

    if not shopConfig then
        DebugPrint("Error: No nearby shop found for the player.")
        return false
    end

    -- Allow access if Job Lock is disabled or not set
    if shopConfig.Potatis144_JobLock == false or shopConfig.Potatis144_JobLock == nil or shopConfig.Potatis144_JobLock == "" then
        inShop[source] = status
        return true
    end

    -- Job Lock is enabled, so check for required job
    if shopConfig.Potatis144_JobLock == true then
        if not shopConfig.Potatis144_JobName then
            DebugPrint("Error: Potatis144_JobName is not defined while Potatis144_JobLock is true.")
            return false
        end

        local job = GetPlayerJob(source)
        DebugPrint("Player's Job: " .. (job and job.name or "None"))

        -- Convert job names into a table
        local requiredJobs = {}
        for jobName in string.gmatch(shopConfig.Potatis144_JobName, "[^, ]+") do
            table.insert(requiredJobs, jobName)
        end

        -- Check if the player has the required job
        local hasRequiredJob = false
        for _, requiredJob in ipairs(requiredJobs) do
            if job and job.name == requiredJob then
                hasRequiredJob = true
                break
            end
        end

        if not hasRequiredJob then
            Potatis144_ServerNotify(source, Locales.Notification.WrongJob, "error") -- Ensure source is passed
            return false
        end
    end

    -- Allow access if Gang Lock is disabled or not set
    if shopConfig.Potatis144_GangLock == false or shopConfig.Potatis144_GangLock == nil or shopConfig.Potatis144_GangLock == "" then
        inShop[source] = status
        return true
    end

    -- Gang Lock is enabled, so check for required gang
    if shopConfig.Potatis144_GangLock == true then
        if not shopConfig.Potatis144_GangName then
            DebugPrint("Error: Potatis144_GangName is not defined while Potatis144_GangLock is true.")
            return false
        end

        local gang = GetPlayerGang(source)
        DebugPrint("Player's Gang: " .. (gang and gang.name or "None"))

        -- Convert gang names into a table
        local requiredGangs = {}
        for gangName in string.gmatch(shopConfig.Potatis144_GangName, "[^, ]+") do
            table.insert(requiredGangs, gangName)
        end

        -- Check if the player has the required gang
        local hasRequiredGang = false
        for _, requiredGang in ipairs(requiredGangs) do
            if gang and gang.name == requiredGang then
                hasRequiredGang = true
                break
            end
        end

        if not hasRequiredGang then
            Potatis144_ServerNotify(source, Locales.Notification.WrongGang, "error") -- Ensure source is passed
            return false
        end
    end

    -- Player has met all conditions
    inShop[source] = status
    return true
end)

local function OpenShop(shopId)
    local shopData = Config.Shops[shopId]
    if not shopData then
        DebugPrint("Invalid shopId:", shopId)
        return
    end

    local playerData = QBCore.Functions.GetPlayerData()
    local job = playerData and playerData.job or nil

    currentShop = shopData -- Set current shop

    if shopData.License.Required then
        -- Check if you should handle it here or trigger UI to buy license
        return HandleShopWithLicense() -- Ensure this function is defined
    elseif job and job.name == shopData.Potatis144_JobLock then
        OpenShopUI(shopData)
    else
        Potatis144_Notify(Locales.Notification.WrongJob, "error")
    end
end
