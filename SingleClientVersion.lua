
-- SingleClientVersion.lua

-- Implements the entire plugin





--- The only allowed client version number
local g_AllowedVersion





--- Maps version name ("1.7.10") to version number (5)
local g_VersionMap =
{
	["1.7.2"]  = 4,
	["1.7.4"]  = 4,
	["1.7.6"]  = 5,
	["1.7.9"]  = 5,
	["1.7.10"] = 5,
	["1.8"]    = 47,
	["1.8.1"]  = 47,
}





--- Handles the HOOK_SERVER_PING hook, kicking all unwanted versions
local function OnServerPing(a_Client, a_ServerDesc, a_OnlinePlayerCount, a_MaxPlayerCount, a_FavIcon)
	if (a_Client:GetProtocolVersion() ~= g_AllowedVersion) then
		a_Client:Kick("Unwanted client version")
		return true
	end
end





--- Handles the HOOK_HANDSHAKE hook, kicking all unwanted versions
local function OnHandshake(a_Client)
	if (a_Client:GetProtocolVersion() ~= g_AllowedVersion) then
		a_Client:Kick("Unwanted client version")
		return true
	end
end





function Initialize(a_Plugin)
	-- Load the single allowed version from the config file:
	local ini = cIniFile:new()
	ini:ReadFile("SingleClientVersion.ini")
	local version = ini:GetValueSet("SingleVersion", "AllowedVersion", "1.7.2")
	if (version:match(".*\..*")) then  -- if there's a dot in the string
		g_AllowedVersion = g_VersionMap[version]
	else
		g_AllowedVersion = versions
	end
	if (g_AllowedVersion == nil) then
		LOGWARNING("SingleClientVersion: Unknown version: '" .. version .. "', using '1.8' instead.")
		g_AllowedVersion = g_VersionMap["1.8"]
	end
	ini:WriteFile("SingleClientVersion.ini")
	
	-- Add the hooks:
	local pm = cPluginManager
	pm.AddHook(pm.HOOK_SERVER_PING, OnServerPing)
	pm.AddHook(pm.HOOK_HANDSHAKE,   OnHandshake)
	
	-- Report to the admin that we're active:
	LOG("SingleClientVersion: Only clients with version " .. cRoot:GetProtocolVersionTextFromInt(g_AllowedVersion) .. " are allowed to join.")
	return true
end




