---@diagnostic disable: undefined-field

local Config = require("shared.sh_config")
local Locales = require("locales." .. Config.Potatis144_Lang)

if Config.Framework ~= "custom" then return end

local inShop = {}

--- Retrieves the Player ID for the given source
---@param source number -- Player's source ID
---@return number -- The Player ID
local function GetPlayerId(source)
	---@diagnostic disable-next-line: return-type-mismatch
	if not source or source == 0 then return nil end
	return Your_Framework.GetPlayer(source) -- example
end

--- Checks if the player can carry the specified item and quantity.
---@param source number -- Player's source ID
---@param itemName string -- The name of the item
---@param itemQuantity number -- The quantity of the item
---@return boolean -- True if the player can carry the item, false otherwise
local function CanCarryItem(source, itemName, itemQuantity)
	if Config.OxInventory then
		return exports.ox_inventory:CanCarryItem(source, itemName, itemQuantity)
	else
		local Player = GetPlayerId(source)
		return Player.CanCarryItem(source, itemName, itemQuantity) -- example
	end
end

--- Adds an item to the player's inventory.
---@param source number -- Player's source ID
---@param itemName string -- The name of the item
---@param itemQuantity number -- The quantity of the item
---@return boolean -- True if the item was successfully added, false otherwise
local function AddItem(source, itemName, itemQuantity)
	if Config.OxInventory then
		return exports.ox_inventory:AddItem(source, itemName, itemQuantity)
	else
		local Player = GetPlayerId(source)
		return Player.AddItem(source, itemName, itemQuantity) -- example
	end
end

--- Checks if the player has the specific license.
---@param source number -- Player's source ID
---@param licenseType string -- License type (e.g., "weapon")
---@return boolean -- True if the player has the license, false otherwise
local function HasLicense(source, licenseType)
	if not source or source == 0 then return false end
	if not licenseType then return false end

	local Player = GetPlayerId(source)
	if not Player then return false end

	return Player.HasLicense(licenseType) -- example
end

--- Buys a specific license for the player.
---@param source number -- Player's source ID
---@param shopData table -- Table with shop data
---@return boolean -- True if the license was successfully bought, false otherwise
---@return string -- Reason for transaction outcome
local function BuyLicense(source, shopData)
	if not source or source == 0 then return false, "Invalid source" end
	if not shopData or next(shopData) == nil then return false, "Invalid or empty shop data" end
	if not inShop[source] then return false, "Not in shop state" end

	local Player = GetPlayerId(source)
	if not Player then return false, "Player not found" end

	local licenseType = shopData.License.Type
	local amount = shopData.License.Price

	local moneyAvailable = Player.GetMoney("cash") -- example
	local bankAvailable = Player.GetMoney("bank") -- example

	local accountType
	if moneyAvailable >= amount then
		accountType = "cash"
	elseif bankAvailable >= amount then
		accountType = "bank"
	else
		ServerNotify(source, Locales.License.NoMoney:format(licenseType), "error")
		return false, "No money"
	end

	Player.RemoveMoney(accountType, amount) -- example
	Player.AddLicense(licenseType) -- example
	ServerNotify(source, Locales.License.PurchaseSuccess:format(licenseType, amount), "info")
	return true, "Successfully bought license"
end

if not Config.WeaponAsItem and not Config.OxInventory then
	--- Checks if the player already has the specified weapon.
	---@param source number -- Player's source ID
	---@param weaponName string -- The name of the weapon
	---@return boolean -- True if the player has the weapon, false otherwise
	function HasWeapon(source, weaponName)
		if not source or source == 0 then return false end
		local Player = GetPlayerId(source)
		return Player.HasWeapon(weaponName) -- example
	end

	--- Adds a weapon to the player.
	---@param source number -- Player's source ID
	---@param weaponName string -- The name of the weapon
	---@return boolean -- True if the item was successfully added, false otherwise
	function AddWeapon(source, weaponName)
		if not source or source == 0 then return false end
		local Player = GetPlayerId(source)
		return Player.AddWeapon(weaponName) -- example
	end
end

--- Processes a shop transaction for a player
---@param source number -- Player's source ID
---@param type string -- Transaction type ("bank" or "money")
---@param cartArray table -- Array of items to purchase
---@return boolean -- Success status of transaction
---@return string -- Reason for transaction outcome
local function ProcessTransaction(source, type, cartArray)
	if not source or source == 0 then return false, "Invalid source" end
	if not cartArray or #cartArray == 0 then return false, "Invalid or empty cart array" end
	if not inShop[source] then return false, "Not in shop state" end

	local Player = GetPlayerId(source)
	if not Player then return false, "Player not found" end

	local accountType = type == "bank" and "bank" or "money"
	local totalCartPrice = 0

	for _, item in ipairs(cartArray) do
		local availableMoney = Player.GetMoney(accountType) or 0 -- example
		local totalItemPrice = (item.price * item.quantity) or 0

		if availableMoney >= totalItemPrice then
			local isWeapon = item.name:sub(1, 7):lower() == "weapon_"
			if isWeapon and not Config.WeaponAsItem and not Config.OxInventory then
				if not HasWeapon(source, item.name) then
					Player.RemoveMoney(accountType, totalItemPrice) -- example
					AddWeapon(source, item.name)
					totalCartPrice = totalCartPrice + totalItemPrice
				else
					ServerNotify(source, Locales.Notification.HasWeapon:format(item.label), "error")
				end
			else
				if CanCarryItem(source, item.name, item.quantity) then
					Player.RemoveMoney(accountType, totalItemPrice) -- example
					AddItem(source, item.name, item.quantity)
					totalCartPrice = totalCartPrice + totalItemPrice
				else
					ServerNotify(source, Locales.Notification.CantCarry:format(item.label), "error")
				end
			end
		else
			ServerNotify(source, Locales.Notification.NoMoney:format(item.label), "error")
		end
	end

	if totalCartPrice > 0 then
		ServerNotify(source, Locales.Notification.PurchaseSuccess:format(totalCartPrice), "success")
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

    local playerData = exports.custom_core:GetPlayerData()
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
