local Config = require("shared.sh_config")

--- Sends a notification to a specific player on the client.
---@param msg string -- Notification message
---@param type string -- Notification type (e.g., "success", "error", "info")
function ClientNotify(msg, type)
	lib.notify({
		title = "Shop",
		description = msg,
		type = type,
		position = "top-left",
		duration = 5000,
	})
end

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

--- Prints debug information to the console if debug mode is enabled.
---@param ... any -- Arguments to print
function DebugPrint(...)
	if Config.DebugMode then print(...) end
end
