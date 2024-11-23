local Config = require("shared.sh_config")
local Locales = require("shared.sh_locales")

if Config.Framework ~= "custom" then return end

local inShop = {}

--- Processes a shop transaction for a player
---@param source number -- Player's source ID
---@param type string -- Transaction type ("bank" or "money")
---@param cartArray table -- Array of items to purchase
---@return boolean -- Success status of transaction
---@return string -- Reason for transaction outcome
local function ProcessTransaction(source, type, cartArray)
	if not source or source == 0 then return false, "Invalid source" end
	if not cartArray or #cartArray == 0 then return false, "Empty cart" end
	if not inShop[source] then return false, "Not in shop state" end

	local Player = Your_Framework.GetPlayer(source)
	if not Player then return false, "Player not found" end

	local accountType = type == "bank" and "bank" or "money"
	local totalCartPrice = 0

	for _, item in ipairs(cartArray) do
		local availableMoney = Player.GetMoney(accountType)
		local totalItemPrice = item.price * item.quantity

		if availableMoney >= totalItemPrice then
			if item.name:sub(1, 7):lower() == "weapon_" and not Config.WeaponAsItem then
				if not HasWeapon(source, item.name) then
					Player.RemoveMoney(accountType, totalItemPrice)
					AddWeapon(source, item.name)
					totalCartPrice = totalCartPrice + totalItemPrice
				else
					ServerNotify(source, Locales.Notification.HasWeapon:format(item.label), "error")
				end
			else
				if CanCarryItem(source, item.name, item.quantity) then
					Player.RemoveMoney(accountType, totalItemPrice)
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

lib.callback.register("cloud-shop:server:ProcessTransaction", function(source, type, cartArray)
	local success, reason = ProcessTransaction(source, type, cartArray)
	return success, reason
end)
lib.callback.register("cloud-shop:server:InShop", function(source, status)
	inShop[source] = status
end)
