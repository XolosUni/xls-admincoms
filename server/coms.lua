local QBCore = exports['qb-core']:GetCoreObject()

local perms = {
    ['admin'] = {'goto', 'bring'},
    ['god'] = {'goto', 'bring', 'revive', 'spec'}
}

local admins = {
    {license = '2481788cafc4f0f0ebbbce7206124ca5677ed039', perm = 'god'},
    {license = 'fa1d5b0e0e5cba2f4d6d8057908e0f81fb9b5a8d', perm = 'god'},
    {license = '44eb45f49a0a9681a93266eedbf8529fed0ff39b', perm = 'god'},
    {license = '69b5fa356b1dbb0dc8fd9f2497b44afac56f9eea', perm = 'god'},
    {license = 'b3dc29a8b2cce0f4868f3c51b1d0342a5fb2a3bb', perm = 'god'},
}

local function GetFormattedPlayerData(src)
    local name = GetPlayerName(src)
    local identifiers = GetPlayerIdentifiers(src)
    local ids = {
        steam = "N/A",
        license = "N/A",
        license2 = "N/A",
        xbl = "N/A",
        live = "N/A",
        discord = "N/A",
        fivem = "N/A",
        ip = "N/A"
    }

    for _, id in ipairs(identifiers) do
        if id:find("steamhex:") then
            ids.steam = id:gsub("steam:", "")
        elseif id:find("license:") then
            if ids.license == "N/A" then
                ids.license = id:gsub("license:", "")
            else
                ids.license2 = id:gsub("license:", "")
            end
        elseif id:find("xbl:") then
            ids.xbl = id:gsub("xbl:", "")
        elseif id:find("live:") then
            ids.live = id:gsub("live:", "")
        elseif id:find("discord:") then
            ids.discord = "<@" .. id:gsub("discord:", "") .. ">"
        elseif id:find("fivem:") then
            ids.fivem = id:gsub("fivem:", "")
        elseif id:find("ip:") then
            ids.ip = id:gsub("ip:", "")
        end
    end

    local commitdata = '[Name] **'..name..'**\n' ..
                       '[Steam] **'..ids.steam..'**\n' ..
                       '[License] **'..ids.license..'**\n' ..
                       '[Xbl] **'..ids.xbl..'**\n' ..
                       '[Live] **'..ids.live..'**\n' ..
                       '[Discord] **'..ids.discord..'**\n' ..
                       '[Fivem] **'..ids.fivem..'**\n' ..
                       '[License2] **'..(ids.license2 ~= "N/A" and ids.license2 or ids.license)..'**\n' ..
                       '[IP] **'..ids.ip..'**'

    return commitdata
end

local discord_webhook_url = "https://discord.com/api/webhooks/1396283899839123516/Exd1c37cZhVH7GYcdnLFDD23itHC_w9dsUf_vdur6eF5TUFwFWD4DT0YAcExbytfjuaK" -- <-- move to config later

function SendDiscordMessage(message, username)
    if discord_webhook_url and discord_webhook_url ~= "" then
        local embed = {
            {
                title = "xls-admincoms - " .. username,
                description = message,
                color = 14692657,
                footer = {
                    text = os.date("%a %b %d, %I:%M%p"),
                    icon_url = "https://i.ibb.co/RW8MwRK/Clean.png"
                }
            }
        }

        local payload = {
            username = "xls-admincoms",
            avatar_url = "https://i.ibb.co/RW8MwRK/Clean.png",
            embeds = embed
        }

        PerformHttpRequest(discord_webhook_url, function() end, 'POST', json.encode(payload), {
            ['Content-Type'] = 'application/json'
        })
    else
        print("^1[Warning]^0 Discord webhook URL not set")
    end
end



local function GetPlayerLicense(src)
    local identifiers = GetPlayerIdentifiers(src)
    for _, id in ipairs(identifiers) do
        if id:sub(1, 8) == "license:" then
            return id
        end
    end
    return nil
end

local function IsPlayerAllowed(com, license)
    local commitPerm = 'user'
    for _, v in ipairs(admins) do
        if v.license == license then
            commitPerm = v.perm
            break
        end
    end

    if commitPerm == 'user' then return 'denied' end

    local permCommands = perms[commitPerm]
    if permCommands then
        for _, cmd in ipairs(permCommands) do
            if cmd == com then
                return 'allowed'
            end
        end
    end
    return 'denied'
end

RegisterNetEvent('xls-admincoms:server:executecom', function (com, target, supposeLocBring)
    local rawlicense = GetPlayerLicense(source)
    if not rawlicense then
        QBCore.Functions.Notify(source, {'Xolos commands', 'Could not retrieve your license ID.'}, 'error', 2000)
        return
    end
    local license = rawlicense:gsub("license:", "")
    local src = source -- make sure source is the player calling the command

    if com == 'bring' then
        local isAllowed = IsPlayerAllowed('bring', license)
        if isAllowed == 'denied' then
            QBCore.Functions.Notify(source, {'Xolos commands', 'You\'re not allowed to do that!'}, 'error', 2000)
            return
        elseif isAllowed ~= 'allowed' then
            print("^1[Security]^0 Command called by unknown role or missing permissions.")
            return
        end

        
        local trgtPed = GetPlayerPed(target)
        local srcPed = GetPlayerPed(src)

        if not trgtPed or not srcPed then
            print("^1[Bring Error]^0 Invalid player ped.")
            return
        end

        

        TriggerClientEvent('xls-admincoms:client:fadeMe', target)
        Wait(config.adminFadeTime-1)
        SetEntityCoords(trgtPed, supposeLocBring.x, supposeLocBring.y, supposeLocBring.z-1, true, false, false, false)
        
    elseif com == 'goto' then
        local isAllowed = IsPlayerAllowed('goto', license)
        if isAllowed == 'denied' then
            QBCore.Functions.Notify(source, {'Xolos commands', 'You\'re not allowed to do that!'}, 'error', 2000)
            return
        elseif isAllowed ~= 'allowed' then
            print("^1[Security]^0 Command called by unknown role or missing permissions.")
            return
        end
        
        local Trgtcoords = GetEntityCoords(GetPlayerPed(target))
        local PlayerPed = GetPlayerPed(source)
        
        SetEntityCoords(PlayerPed, Trgtcoords.x, Trgtcoords.y, Trgtcoords.z, true, false, false, false)

    elseif com == 'spec' then
        target = tonumber(target)
        local isAllowed = IsPlayerAllowed('spec', license)
        if isAllowed == 'denied' then
            QBCore.Functions.Notify(source, {'Xolos commands', 'You\'re not allowed to do that!'}, 'error', 2000)
            return
        elseif isAllowed ~= 'allowed' then
            print("^1[Security]^0 Command called by unknown role or missing permissions.")
            return
        end

        -- actual command running after all of the checks
        if target == src then
            QBCore.Functions.Notify(source, {'Xolos commands', 'You can\'nt spectate yourself!'}, 'error', 2000)
        end

        local vec3Com = GetEntityCoords(GetPlayerPed(target))

        TriggerClientEvent('xls-admincoms:client:spec', source, target, vec3Com)
    else
        QBCore.Functions.Notify(source, {'Xolos commands', 'Are you a gooner? (cheater)'}, 'error', 2000)
    end




end)

-- Goto Command
local gotoargs = {
    { name = 'id', help = 'The target player ID' },
    { name = 'reason', help = 'Reason for teleport (visible in logs)' }
}

QBCore.Commands.Add('xgoto', 'Summon next to a player', gotoargs, true, function(source, args)
    local targetId = tonumber(args[1])
    local reason = table.concat(args, " ", 2) or "No reason provided"

    if not targetId or GetPlayerPed(targetId) == 0 then
        QBCore.Functions.Notify(source, {'Xolos commands', 'Invalid or offline target player!'}, 'error', 2000)
        return
    end

    local rawlicense = GetPlayerLicense(source)
    if not rawlicense then
        QBCore.Functions.Notify(source, {'Xolos commands', 'Could not retrieve your license ID.'}, 'error', 2000)
        return
    end

    local license = rawlicense:gsub("license:", "")
    local isAllowed = IsPlayerAllowed('goto', license)

    if isAllowed == 'denied' then
        QBCore.Functions.Notify(source, {'Xolos commands', 'You\'re not allowed to do that!'}, 'error', 2000)
        return
    elseif isAllowed ~= 'allowed' then
        print("^1[Security]^0 Command called by unknown role or missing permissions.")
        return
    end

    -- Safe to proceed
    local srcPed = GetPlayerPed(source)
    local tgtPed = GetPlayerPed(targetId)
    if srcPed == 0 or tgtPed == 0 then return end

    local coords = GetEntityCoords(tgtPed)
    SetEntityCoords(srcPed, coords.x, coords.y, coords.z, true, false, false, false)

    local display = GetPlayerName(source)
    local citizen = QBCore.Functions.GetPlayer(source).PlayerData.citizenid
    local trgDisplay = GetPlayerName(targetId)
    local trgCitizen = QBCore.Functions.GetPlayer(targetId).PlayerData.citizenid

    local data = GetFormattedPlayerData(source)

    SendDiscordMessage(
        '**'..display..'** (citizenId: **'..citizen..'**, source: **'..source..'**)\n' ..
        'Used **/xgoto** on\n' ..
        '**'..trgDisplay..'** (citizenId: **'..trgCitizen..'**, source: **'..targetId..'**)\n' ..
        'Reason: **'..reason..'**\n\n'..data,
        'goto'
    )

end, false)


local bringargs = {
    { name = 'id', help = 'The target player ID' },
    { name = 'reason', help = 'Reason for bring (visible in logs)' }
}
QBCore.Commands.Add('xbring', 'bring a player to you', bringargs, true, function(source, args)
    local targetId = tonumber(args[1])
    local reason = table.concat(args, " ", 2) or "No reason provided"

    if not targetId or GetPlayerPed(targetId) == 0 then
        QBCore.Functions.Notify(source, {'Xolos commands', 'Invalid or offline target player!'}, 'error', 2000)
        return
    end

    local rawlicense = GetPlayerLicense(source)
    if not rawlicense then
        QBCore.Functions.Notify(source, {'Xolos commands', 'Could not retrieve your license ID.'}, 'error', 2000)
        return
    end

    local license = rawlicense:gsub("license:", "")
    local isAllowed = IsPlayerAllowed('bring', license)

    if isAllowed == 'denied' then
        QBCore.Functions.Notify(source, {'Xolos commands', 'You\'re not allowed to do that!'}, 'error', 2000)
        return
    elseif isAllowed ~= 'allowed' then
        print("^1[Security]^0 Command called by unknown role or missing permissions.")
        return
    end

    -- Safe to proceed
    local srcPed = GetPlayerPed(source)
    local tgtPed = GetPlayerPed(targetId)
    if srcPed == 0 or tgtPed == 0 then return end

    local coords = GetEntityCoords(srcPed)
    TriggerClientEvent('xls-admincoms:client:fadeMe', targetId)
    Wait(config.adminFadeTime-1)
    SetEntityCoords(tgtPed, coords.x, coords.y, coords.z, true, false, false, false)

    local display = GetPlayerName(source)
    local citizen = QBCore.Functions.GetPlayer(source).PlayerData.citizenid
    local trgDisplay = GetPlayerName(targetId)
    local trgCitizen = QBCore.Functions.GetPlayer(targetId).PlayerData.citizenid

    local data = GetFormattedPlayerData(source)

    SendDiscordMessage(
        '**'..display..'** (citizenId: **'..citizen..'**, source: **'..source..'**)\n' ..
        'Used **/xbring** on\n' ..
        '**'..trgDisplay..'** (citizenId: **'..trgCitizen..'**, source: **'..targetId..'**)\n' ..
        'Reason: **'..reason..'**\n\n'..data,
        'bring'
    )

end, false)


local reviveargs = {
    { name = 'id', help = 'The target player ID' },
    { name = 'reason', help = 'Reason for bring (visible in logs)' }
}
QBCore.Commands.Add('xrevive', 'revive a player', reviveargs, true, function(source, args)
    local targetId = tonumber(args[1])
    local reason = table.concat(args, " ", 2) or "No reason provided"

    if not targetId or GetPlayerPed(targetId) == 0 then
        QBCore.Functions.Notify(source, {'Xolos commands', 'Invalid or offline target player!'}, 'error', 2000)
        return
    end

    local rawlicense = GetPlayerLicense(source)
    if not rawlicense then
        QBCore.Functions.Notify(source, {'Xolos commands', 'Could not retrieve your license ID.'}, 'error', 2000)
        return
    end

    local license = rawlicense:gsub("license:", "")
    local isAllowed = IsPlayerAllowed('revive', license)

    if isAllowed == 'denied' then
        QBCore.Functions.Notify(source, {'Xolos commands', 'You\'re not allowed to do that!'}, 'error', 2000)
        return
    elseif isAllowed ~= 'allowed' then
        print("^1[Security]^0 Command called by unknown role or missing permissions.")
        return
    end

    TriggerClientEvent('hospital:client:Revive', targetId)

    local display = GetPlayerName(source)
    local citizen = QBCore.Functions.GetPlayer(source).PlayerData.citizenid
    local trgDisplay = GetPlayerName(targetId)
    local trgCitizen = QBCore.Functions.GetPlayer(targetId).PlayerData.citizenid

    local data = GetFormattedPlayerData(source)

    SendDiscordMessage(
        '**'..display..'** (citizenId: **'..citizen..'**, source: **'..source..'**)\n' ..
        'Used **/xrevive** on\n' ..
        '**'..trgDisplay..'** (citizenId: **'..trgCitizen..'**, source: **'..targetId..'**)\n' ..
        'Reason: **'..reason..'**\n\n'..data,
        'revive'
    )

end, false)


local reviveargs = {
    { name = 'id', help = 'The target player ID' },
    { name = 'reason', help = 'Reason for bring (visible in logs)' }
}
QBCore.Commands.Add('xrevive', 'revive a player', reviveargs, true, function(source, args)
    local targetId = tonumber(args[1])
    local reason = table.concat(args, " ", 2) or "No reason provided"

    if not targetId or GetPlayerPed(targetId) == 0 then
        QBCore.Functions.Notify(source, {'Xolos commands', 'Invalid or offline target player!'}, 'error', 2000)
        return
    end

    local rawlicense = GetPlayerLicense(source)
    if not rawlicense then
        QBCore.Functions.Notify(source, {'Xolos commands', 'Could not retrieve your license ID.'}, 'error', 2000)
        return
    end

    local license = rawlicense:gsub("license:", "")
    local isAllowed = IsPlayerAllowed('revive', license)

    if isAllowed == 'denied' then
        QBCore.Functions.Notify(source, {'Xolos commands', 'You\'re not allowed to do that!'}, 'error', 2000)
        return
    elseif isAllowed ~= 'allowed' then
        print("^1[Security]^0 Command called by unknown role or missing permissions.")
        return
    end

    TriggerClientEvent('hospital:client:Revive', targetId)

    local display = GetPlayerName(source)
    local citizen = QBCore.Functions.GetPlayer(source).PlayerData.citizenid
    local trgDisplay = GetPlayerName(targetId)
    local trgCitizen = QBCore.Functions.GetPlayer(targetId).PlayerData.citizenid

    local data = GetFormattedPlayerData(source)

    SendDiscordMessage(
        '**'..display..'** (citizenId: **'..citizen..'**, source: **'..source..'**)\n' ..
        'Used **/xrevive** on\n' ..
        '**'..trgDisplay..'** (citizenId: **'..trgCitizen..'**, source: **'..targetId..'**)\n' ..
        'Reason: **'..reason..'**\n\n'..data,
        'revive'
    )

end, false)




local specargs = {
    { name = 'id', help = 'The target player ID' },
    { name = 'reason', help = 'Reason for bring (visible in logs)' }
}
QBCore.Commands.Add('xspec', 'spectate a player', specargs, true, function(source, args)
    local src = source
    local targetId = tonumber(args[1])
    local reason = table.concat(args, " ", 2) or "No reason provided"

    if not targetId or GetPlayerPed(targetId) == 0 then
        QBCore.Functions.Notify(source, {'Xolos commands', 'Invalid or offline target player!'}, 'error', 2000)
        return
    end

    local rawlicense = GetPlayerLicense(source)
    if not rawlicense then
        QBCore.Functions.Notify(source, {'Xolos commands', 'Could not retrieve your license ID.'}, 'error', 2000)
        return
    end

    local license = rawlicense:gsub("license:", "")
    local isAllowed = IsPlayerAllowed('spec', license)

    if isAllowed == 'denied' then
        QBCore.Functions.Notify(source, {'Xolos commands', 'You\'re not allowed to do that!'}, 'error', 2000)
        return
    elseif isAllowed ~= 'allowed' then
        print("^1[Security]^0 Command called by unknown role or missing permissions.")
        return
    end

    -- actual command running after all of the checks
    if targetId == src then
        QBCore.Functions.Notify(source, {'Xolos commands', 'You can\'nt spectate yourself!'}, 'error', 2000)
    end
    local vec3Com = GetEntityCoords(GetPlayerPed(targetId))

    TriggerClientEvent('xls-admincoms:client:spec', source, targetId, vec3Com)

    -- discord log DON'T TOUCH!

    local display = GetPlayerName(source)
    local citizen = QBCore.Functions.GetPlayer(source).PlayerData.citizenid
    local trgDisplay = GetPlayerName(targetId)
    local trgCitizen = QBCore.Functions.GetPlayer(targetId).PlayerData.citizenid

    local data = GetFormattedPlayerData(source)

    SendDiscordMessage(
        '**'..display..'** (citizenId: **'..citizen..'**, source: **'..source..'**)\n' ..
        'Used **/xspec** on\n' ..
        '**'..trgDisplay..'** (citizenId: **'..trgCitizen..'**, source: **'..targetId..'**)\n' ..
        'Reason: **'..reason..'**\n\n'..data,
        'spectate'
    )

end, false)

RegisterCommand('xspecmenu', function (source)
    local src = source
    local rawlicense = GetPlayerLicense(src)
    if not rawlicense then
        QBCore.Functions.Notify(src, {'Xolos commands', 'Could not retrieve your license ID.'}, 'error', 2000)
        return
    end

    local license = rawlicense:gsub("license:", "")
    local isAllowed = IsPlayerAllowed('spec', license)

    if isAllowed == 'denied' then
        QBCore.Functions.Notify(src, {'Xolos commands', 'You\'re not allowed to do that!'}, 'error', 2000)
        return
    elseif isAllowed ~= 'allowed' then
        print("^1[Security]^0 Command called by unknown role or missing permissions.")
        return
    end

    -- actual command running after all of the checks
    local plyrs = {}
    for _, playerId in ipairs(GetPlayers()) do
        if tonumber(playerId) == tonumber(src) then goto continue end

        local display = GetPlayerName(playerId)
        table.insert(plyrs, { id = playerId, display = display })

        ::continue::
    end

    TriggerClientEvent('xls-admincoms:client:openmenu', src, plyrs)


    -- discord log DON'T TOUCH!

    local display = GetPlayerName(src)
    local citizen = QBCore.Functions.GetPlayer(src).PlayerData.citizenid


    local data = GetFormattedPlayerData(src)

    SendDiscordMessage(
        '**'..display..'** (citizenId: **'..citizen..'**, source: **'..src..'**)\n' ..
        'Used **/xspecmenu**\n\n' .. data,

        'spectate'
    )

end, false)


