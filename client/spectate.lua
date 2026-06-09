local QBCore = exports['qb-core']:GetCoreObject()
local isSpectating = false
local specTargetIdServ = nil
local specedPlayer = nil
local pastPlayerVector 



local textUIOptions = {
    position = "right-center",
        icon = 'fa-solid fa-bars',
        style = {
            ["background-color"] = "#222222",
            ["color"] = "white",
            ["font-size"] = "14px",
            ["padding"] = "10px",
            ["white-space"] = "pre-line" -- 👈 this is what makes line breaks work
        }
}

-- Main spectate handler
RegisterNetEvent('xls-admincoms:client:spec', function(targetServerId, trgtCoords)
    pastPlayerVector = GetEntityCoords(PlayerPedId())
    SetEntityCoords(PlayerPedId(), trgtCoords.x, trgtCoords.y, trgtCoords.z - 5.0, true, false, false, false)
    FreezeEntityPosition(PlayerPedId(), true)

    specTargetIdServ = targetServerId
    local targetClientId = GetPlayerFromServerId(targetServerId)

    local targetPed = nil
    local startTime = GetGameTimer()

    -- Try to get targetPed for up to 1000ms
    while not targetPed and (GetGameTimer() - startTime) < 1000 do
        targetClientId = GetPlayerFromServerId(targetServerId) -- in case it loads later
        if targetClientId ~= -1 then
            targetPed = GetPlayerPed(targetClientId)
            if DoesEntityExist(targetPed) then break end
        end
        Wait(50) -- small delay
    end

    FreezeEntityPosition(PlayerPedId(), false)
    if targetPed then
        SetEntityCoords(PlayerPedId(), pastPlayerVector.x, pastPlayerVector.y, pastPlayerVector.z, true, false, false, false)
        pastPlayerVector = nil
    end
    if not targetPed or not DoesEntityExist(targetPed) then
        SetEntityCoords(PlayerPedId(), pastPlayerVector.x, pastPlayerVector.y, pastPlayerVector.z, true, false, false, false)
        pastPlayerVector = nil
        -- notify that player couldn't be streamed
        QBCore.Functions.Notify({'Xolos commands', 'You are rendering the game too slow...'}, 'error', 2000)
        return
    end

    if PlayerPedId() == targetPed then
        QBCore.Functions.Notify({'Xolos commands', 'You can\'t spectate yourself!'}, 'error', 2000)
        return
    end

    isSpectating = true
    specedPlayer = targetPed
    pastPlayerVector = GetEntityCoords(PlayerPedId())
    NetworkSetInSpectatorMode(true, targetPed)
    QBCore.Functions.Notify({'Xolos commands', 'Now spectating player: ' .. targetServerId}, 'primary', 2500)
    SetEntityInvincible(PlayerPedId(), true)
    -- Loop for showing keybinds while spectating
    CreateThread(function()
        lib.showTextUI('KeyBinds:\nExit spectate: ⌫\nGoto player: G\n Bring Player: B', textUIOptions)
        while isSpectating do
            Wait(0)
            local targetCoords = GetEntityCoords(targetPed)
            SetEntityCoords(PlayerPedId(), targetCoords.x, targetCoords.y, targetCoords.z -5, true, false, false, false)
            SetEntityVisible(PlayerPedId(), false, 0)
            DisableControlAction(0, 194, true)
            if IsDisabledControlJustPressed(0, 194) then -- Default BACKSPACE (INPUT_FRONTEND_RRIGHT)
                DisableControlAction(0, 194, false)
                lib.hideTextUI()
                StopSpectate('backspace')
            end
            DisableControlAction(0, 29, true)
            if IsDisabledControlJustPressed(0, 29) then -- Default B (INPUT_SPECIAL_ABILITY_SECONDARY)
                DisableControlAction(0, 47, false)
                lib.hideTextUI()
                StopSpectate('B')
            end
            DisableControlAction(0, 47, true)
            if IsDisabledControlJustPressed(0, 47) then
                print('g')
                DisableControlAction(0, 47, false)
                lib.hideTextUI()
                StopSpectate('G')
            end
        end
    end)
end)


-- Stop spectating logicc
function StopSpectate(type)
    if type == 'backspace' then
        NetworkSetInSpectatorMode(false, specedPlayer)
        SetEntityInvincible(PlayerPedId(), false)
        SetEntityCoords(PlayerPedId(), pastPlayerVector.x, pastPlayerVector.y, pastPlayerVector.z, true, false, false, false)
        SetEntityVisible(PlayerPedId(), true, 0)
        pastPlayerVector = nil
        specedPlayer = nil
        isSpectating = false
        
        QBCore.Functions.Notify({'Xolos commands', 'Stopped spectating'}, 'success', 2000)

        
    elseif type == 'G' then
        NetworkSetInSpectatorMode(false, specedPlayer)
        SetEntityInvincible(PlayerPedId(), false)
        SetEntityCoords(PlayerPedId(), pastPlayerVector.x, pastPlayerVector.y, pastPlayerVector.z, true, false, false, false)
        SetEntityVisible(PlayerPedId(), true, 0)
        pastPlayerVector = nil
        specedPlayer = nil
        isSpectating = false
        
        QBCore.Functions.Notify({'Xolos commands', 'Stopped spectating'}, 'success', 2000)
        QBCore.Functions.Notify({'Xolos commands', 'TP\'ng player'}, 'success', 2000)
        
        TriggerServerEvent('xls-admincoms:server:executecom', 'goto', specTargetIdServ)
        
    elseif type == 'B' then
        NetworkSetInSpectatorMode(false, specedPlayer)
        SetEntityInvincible(PlayerPedId(), false)
        SetEntityCoords(PlayerPedId(), pastPlayerVector.x, pastPlayerVector.y, pastPlayerVector.z, true, false, false, false)
        TriggerServerEvent('xls-admincoms:server:executecom', 'bring', specTargetIdServ, pastPlayerVector)
        SetEntityVisible(PlayerPedId(), true, 0)
        pastPlayerVector = nil
        specedPlayer = nil
        isSpectating = false
        
        QBCore.Functions.Notify({'Xolos commands', 'Stopped spectating'}, 'success', 2000)
        QBCore.Functions.Notify({'Xolos commands', 'TP\'ng player'}, 'success', 2000)
        
    end
    
end

RegisterNetEvent('xls-admincoms:client:fadeMe', function ()
    QBCore.Functions.Notify({'Xolos commands', 'You have been bringed by an admin!'}, 'success', 2000)

    -- Start fading out
    DoScreenFadeOut(config.adminFadeTime) -- fade out over 500ms
    while not IsScreenFadedOut() do
        Wait(10)
    end

    -- Short wait while screen is fully black
    Wait(250)

    -- Fade back in
    DoScreenFadeIn(1000) -- fade in over 1s
end)

RegisterNetEvent('xls-admincoms:client:openmenu', function (players)
    local opt = {}

    for _, playerData in pairs(players) do
        table.insert(opt, {
            label = '['..playerData.id..'] - '.. playerData.display,
            icon = 'user-secret',
            description = 'Spectate this player',
            args = { targetId = playerData.id }
        })
    end

    if next(opt) == nil then
        QBCore.Functions.Notify({'Xolos commands', 'There aren\'t any players in the server'}, 'error', 2000)
        return
    end

    lib.registerMenu({
        id = 'playerspec',
        title = 'Spectate menu',
        options = opt,
    }, function(selected, scrollIndex, args)
        print('Selected player ID:', args.targetId)
        TriggerServerEvent('xls-admincoms:server:executecom', 'spec', args.targetId, vector3(0, 0, 0))
    end)

    lib.showMenu('playerspec')
end)
