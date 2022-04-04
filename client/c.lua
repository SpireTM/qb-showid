QBCore = nil
local QBCore = exports['qb-core']:GetCoreObject()
local proppi
local ekaPiirto = false
local tokaPiirto = false

Citizen.CreateThread(function()
	while QBCore == nil do
		TriggerEvent('QBCore:GetObject', function(obj) QBCore = obj end)
		Citizen.Wait(0)
	end
end)

function loadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Citizen.Wait(5)
    end
end

function Draw3DText(x, y, z, text)
	SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

function GetNeareastPlayers()
    local playerPed = PlayerPedId()
    local players, _ = QBCore.Functions.GetPlayers(GetEntityCoords(playerPed), Config.DrawDistance)

    local players_clean = {}
    local found_players = false

    for i = 1, #players, 1 do
        found_players = true
        table.insert(players_clean, { playerName = GetPlayerName(players[i]), playerId = GetPlayerServerId(players[i]), coords = GetEntityCoords(GetPlayerPed(players[i])) })
    end
    return players_clean
end

RegisterNetEvent('pdqb-showid:id')
AddEventHandler('pdqb-showid:id', function()
    ekaPiirto = not ekaPiirto
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if Config.Key.Enabled then
            tokaPiirto = IsControlPressed(0, Config.Key.pageUP)
        end
    end
end)

Citizen.CreateThread(function()
    local animaatio = false
    while true do
        Citizen.Wait(0)
        if animaatio ~= tokaPiirto then
            animaatio = tokaPiirto
            if animaatio then
                local playerPed = GetPlayerPed(-1)
                loadAnimDict("missheistdockssetup1clipboard@base")
                TaskPlayAnim(playerPed, 'missheistdockssetup1clipboard@base', 'base', 8.0, -8, -1, 49, 0, 0, 0, 0)
                proppi = CreateObject(GetHashKey("p_amb_clipboard_01"), x, y, z, true)
                coords = { x = 0.2, y = 0.1, z = 0.08 }
                rotation = { x = -80.0, y = -20.0, z = 0.0 }
                AttachEntityToEntity(proppi, GetPlayerPed(-1), GetPedBoneIndex(GetPlayerPed(PlayerId()), 18905), coords.x, coords.y, coords.z, rotation.x, rotation.y, rotation.z, 1, 1, 0, 1, 0, 1)
            else
                ClearPedTasks(GetPlayerPed(-1))
                if proppi ~= nil then
                    DeleteEntity(proppi)
                    proppi = nil
                end
            end
        end

        if tokaPiirto or ekaPiirto then
            local nearbyPlayers = GetNeareastPlayers()
            for k, v in pairs(nearbyPlayers) do
                local x, y, z = table.unpack(v.coords)
                Draw3DText(x, y, z + 1.1, v.playerId)
            end
        end
    end
end)