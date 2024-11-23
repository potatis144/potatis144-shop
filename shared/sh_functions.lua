local Config = require("shared.sh_config")

--- Sends a notification to a specific player on the server.
---@param source number -- Player's source ID
---@param msg string -- Notification message
---@param type string -- Notification type (e.g., "success", "error", "info")
function ServerNotify(source, msg, type)
	TriggerClientEvent("ox_lib:notify", source, {
		title = "Shop",
		description = msg,
		type = type,
		position = "top-left",
		duration = 5000,
	})
end

--- Displays a text-based UI message for the current frame.
---@param text string -- The message to display
function TextUI(text)
	AddTextEntry("TextUI", text)
	DisplayHelpTextThisFrame("TextUI", false)
end

--- Toggles the visibility of the HUD and radar.
---@param state boolean -- True to enable, false to disable
function ToggleHud(state)
	DisplayHud(state)
	DisplayRadar(state)
end

--- Checks if the player can carry the specified item and quantity.
---@param source number -- Player's source ID
---@param itemName string -- The name of the item
---@param itemQuantity number -- The quantity of the item
---@return boolean -- True if the player can carry the item, false otherwise
function CanCarryItem(source, itemName, itemQuantity)
	return exports.ox_inventory:CanCarryItem(source, itemName, itemQuantity) -- ox_inventory example
end

--- Adds an item to the player's inventory.
---@param source number -- Player's source ID
---@param itemName string -- The name of the item
---@param itemQuantity number -- The quantity of the item
---@return boolean -- True if the item was successfully added, false otherwise
function AddItem(source, itemName, itemQuantity)
	return exports.ox_inventory:AddItem(source, itemName, itemQuantity) -- ox_inventory example
end

--- Adds a weapon to the player, with 120 ammo by default.
---@param source number -- Player's source ID
---@param weaponName string -- The name of the weapon
---@return any -- True if the weapon was successfully added, false otherwise
function AddWeapon(source, weaponName)
	if Config.Framework == "esx" then
		local xPlayer = ESX.GetPlayerFromId(source)
		return xPlayer.addWeapon(weaponName, 120)
	elseif Config.Framework == "qbcore" then
		-- Add your custom framework logic here
	elseif Config.Framework == "custom" then
		-- Add your custom framework logic here
	end
end

--- Checks if the player already has the specified weapon.
---@param source number -- Player's source ID
---@param weaponName string -- The name of the weapon
---@return boolean -- True if the player has the weapon, false otherwise
function HasWeapon(source, weaponName)
	if Config.Framework == "esx" then
		local xPlayer = ESX.GetPlayerFromId(source)
		return xPlayer.hasWeapon(weaponName)
	elseif Config.Framework == "qbcore" then
		return false -- Add your QBCore logic here
	elseif Config.Framework == "custom" then
		return false -- Add your custom framework logic here
	end
	return false
end

--- Prints debug information to the console if debug mode is enabled.
---@param ... any -- Arguments to print
function DebugPrint(...)
	if Config.DebugMode then print(...) end
end
