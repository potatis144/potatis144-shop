---@diagnostic disable: undefined-field

local Config = require("shared.sh_config")
local Locales = require("shared.sh_locales")

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

    -- Check if Potatis144_JobLock is false; skip job check if so
    if shopConfig.Potatis144_JobLock == false then
        inShop[source] = status
        return true
    end

    -- If Potatis144_JobLock is nil or empty, allow access as well
    if not shopConfig.Potatis144_JobLock or shopConfig.Potatis144_JobLock == "" then
        inShop[source] = status
        return true
    end

    -- Potatis144_JobLock is true, so we need to check the specific jobs
    if shopConfig.Potatis144_JobLock == true then
        if not shopConfig.Potatis144_JobName then
            DebugPrint("Error: Potatis144_JobName is not defined while Potatis144_JobLock is true.")
            return false
        end

        local job = GetPlayerJob(source)
        DebugPrint("Player's Job: " .. (job and job.name or "None"))

        local Potatis144_JobLock = {}
        for Potatis144_JobName in string.gmatch(shopConfig.Potatis144_JobName, "[^, ]+") do -- Split jobs by comma
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
            inShop[source] = status
            return true
        else
            -- Botify the player they do not have the required job
            Potatis144_Notify(Locales.Notification.WrongJob, "error")
            return false
        end
    end
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
