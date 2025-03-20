local Config = require("shared.sh_config")

-- Sends a notification to a specific player on the server.
-- source number -- Player's source ID
-- text string -- Notification message
-- type string -- Notification type (e.g., "success", "error", "info", "warning", "neutral", "phonemessage")
function Potatis144_ClientNotify(msg, type)
	--okok notify
	if Config.Potatis144_NotifySystem == 'okoknotify' then
		exports['okokNotify']:Alert('', msg, 1500, type, playSound)

	--ox notify
	elseif Config.Potatis144_NotifySystem == "oxnotify" then
		lib.notify({
			title = "",
			description = msg,
			type = type,
			position = "top-left",
			duration = 1500,
		})
	else
		DebugPrint("You need to select a notify system from the options of notify systems you can use.")
	end
end

function Potatis144_ServerNotify(source, msg, type)
	--okok notify
	if Config.Potatis144_NotifySystem == 'okoknotify' then
		TriggerClientEvent('okokNotify:Alert', source, '', msg, 1500, type, playSound)

		-- oxnotify
	elseif Config.Potatis144_NotifySystem == "oxnotify" then
	TriggerClientEvent("ox_lib:notify", source, {
		title = "",
		description = msg,
		type = type,
		position = "top-left",
		duration = 1500,
	})
else
	DebugPrint("You need to select a notify system from the options of notify systems you can use.")
end
end

CreateThread(function()
    local url = "https://raw.githubusercontent.com/potatis144/potatis144-shop/main/server/version.txt"
    local version = GetResourceMetadata('potatis144-shop', "version" )
     PerformHttpRequest(url, function(err, textver, headers)
         if (text ~= nil) then
                print('^2 Your Version:' .. version .. ' | Current Version:' .. textver .. '' )  
         end
     end, "GET", "", "")
end)

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
