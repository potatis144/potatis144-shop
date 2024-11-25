local Config = require("shared.sh_config")
local Locales = require("shared.sh_locales")

if Config.Framework ~= "esx" then return end

local ESX = exports["es_extended"]:getSharedObject()

local inShop = {}

local function GetPlayerId(source)
	if not source or source == 0 then return nil end
	return ESX.GetPlayerFromId(source)
end

local function CanCarryItem(source, itemName, itemQuantity)
	if Config.OxInventory then
		return exports.ox_inventory:CanCarryItem(source, itemName, itemQuantity)
	else
		local xPlayer = GetPlayerId(source)
		if not xPlayer then return false end

		return xPlayer.canCarryItem(itemName, itemQuantity)
	end
end

local function AddItem(source, itemName, itemQuantity)
	if Config.OxInventory then
		return exports.ox_inventory:AddItem(source, itemName, itemQuantity)
	else
		local xPlayer = GetPlayerId(source)
		if not xPlayer then return false end

		return xPlayer.addInventoryItem(itemName, itemQuantity)
	end
end

local function HasLicense(source, licenseType)
	if not source or source == 0 then return false end
	if not licenseType then return false end

	local p = promise.new()
	TriggerEvent("esx_license:checkLicense", source, licenseType, function(hasLicense)
		p:resolve(hasLicense)
	end)

	local result = Citizen.Await(p)
	return result
end

local function BuyLicense(source, shopData)
	if not source or source == 0 then return false, "Invalid source" end
	if not shopData or next(shopData) == nil then return false, "Invalid or empty shop data" end
	if not inShop[source] then return false, "Not in shop state" end

	local xPlayer = GetPlayerId(source)
	if not xPlayer then return false, "Player not found" end

	local licenseType = shopData.License.Type
	local licenseTypeLabel = shopData.License.TypeLabel
	local amount = shopData.License.Price

	local moneyAvailable = xPlayer.getAccount("money").money
	local bankAvailable = xPlayer.getAccount("bank").money

	local accountType
	if moneyAvailable >= amount then
		accountType = "money"
	elseif bankAvailable >= amount then
		accountType = "bank"
	else
		ServerNotify(source, Locales.License.NoMoney:format(licenseTypeLabel), "error")
		return false, "No money"
	end

	xPlayer.removeAccountMoney(accountType, amount)
	TriggerEvent("esx_license:addLicense", source, licenseType)
	ServerNotify(source, Locales.License.PurchaseSuccess:format(licenseTypeLabel, amount), "info")
	return true, "Successfully bought license"
end

if not Config.WeaponAsItem and not Config.OxInventory then
	function HasWeapon(source, weaponName)
		local xPlayer = GetPlayerId(source)
		if not xPlayer then return false end

		return xPlayer.hasWeapon(weaponName)
	end

	function AddWeapon(source, weaponName)
		local xPlayer = GetPlayerId(source)
		if not xPlayer then return false end

		return xPlayer.addWeapon(weaponName, 120)
	end
end

local function ProcessTransaction(source, type, cartArray)
	if not source or source == 0 then return false, "Invalid source" end
	if not cartArray or #cartArray == 0 then return false, "Invalid or empty cart array" end
	if not inShop[source] then return false, "Not in shop state" end

	local xPlayer = GetPlayerId(source)
	if not xPlayer then return false, "Player not found" end

	local accountType = type == "bank" and "bank" or "money"
	local totalCartPrice = 0

	for _, item in ipairs(cartArray) do
		local availableMoney = xPlayer.getAccount(accountType).money
		local totalItemPrice = item.price * item.quantity

		if availableMoney >= totalItemPrice then
			if item.name:sub(1, 7):lower() == "weapon_" and not Config.WeaponAsItem and not Config.OxInventory then
				if not HasWeapon(source, item.name) then
					xPlayer.removeAccountMoney(accountType, totalItemPrice)
					AddWeapon(source, item.name)
					totalCartPrice = totalCartPrice + totalItemPrice
				else
					ServerNotify(source, Locales.Notification.HasWeapon:format(item.label), "error")
				end
			else
				if CanCarryItem(source, item.name, item.quantity) then
					xPlayer.removeAccountMoney(accountType, totalItemPrice)
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

lib.callback.register("cloud-shop:server:HasLicense", HasLicense)
lib.callback.register("cloud-shop:server:BuyLicense", function(source, shopData)
	local success, reason = BuyLicense(source, shopData)
	return success, reason
end)
lib.callback.register("cloud-shop:server:ProcessTransaction", function(source, type, cartArray)
	local success, reason = ProcessTransaction(source, type, cartArray)
	return success, reason
end)
lib.callback.register("cloud-shop:server:InShop", function(source, status)
	inShop[source] = status
end)
