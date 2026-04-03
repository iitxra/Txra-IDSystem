--[[
https://discord.gg/8nCR8H3se2

████████╗██╗░░██╗██████╗░░█████╗░  ░██████╗████████╗░█████╗░██████╗░███████╗
╚══██╔══╝╚██╗██╔╝██╔══██╗██╔══██╗  ██╔════╝╚══██╔══╝██╔══██╗██╔══██╗██╔════╝
░░░██║░░░░╚███╔╝░██████╔╝███████║  ╚█████╗░░░░██║░░░██║░░██║██████╔╝█████╗░░
░░░██║░░░░██╔██╗░██╔══██╗██╔══██║  ░╚═══██╗░░░██║░░░██║░░██║██╔══██╗██╔══╝░░
░░░██║░░░██╔╝╚██╗██║░░██║██║░░██║  ██████╔╝░░░██║░░░╚█████╔╝██║░░██║███████╗
░░░╚═╝░░░╚═╝░░╚═╝╚═╝░░╚═╝╚═╝░░╚═╝  ╚═════╝░░░░╚═╝░░░░╚════╝░╚═╝░░╚═╝╚══════╝
]]

local QBCore = exports['qb-core']:GetCoreObject()
local players = {}
local names = {}
local isToggled = true
local talkingPlayers = {}

RegisterNetEvent('names:client:insert', function(source, id, name)
    players[source] = GetPlayerFromServerId(source)
    names[source] = name .. Config.IdColor .. id .. ' ~'
end)

RegisterNetEvent('names:client:update', function(source, id, name)
    TriggerServerEvent('names:server:addPlayer')
end)

RegisterNetEvent('names:client:remove', function(source)
    players[source] = nil
    names[source] = nil
end)

Citizen.CreateThread(function()
    while true do
        local playerList = GetActivePlayers()
        for _, player in ipairs(playerList) do
            if NetworkIsPlayerTalking(player) then
                talkingPlayers[player] = true
            else
                talkingPlayers[player] = false
            end
        end
        Citizen.Wait(100)
    end
end)

function GetPlayers()
    local players = {}
    local activePlayers = GetActivePlayers()
    for i = 1, #activePlayers do
        local player = activePlayers[i]
        local ped = GetPlayerPed(player)
        if DoesEntityExist(ped) then
            players[#players + 1] = player
        end
    end
    return players
end

function GetPlayersFromCoords(coords, distance)
    local players = GetPlayers()
    local closePlayers = {}

    coords = coords or GetEntityCoords(PlayerPedId())
    distance = distance or 5.0

    for i = 1, #players do
        local player = players[i]
        local target = GetPlayerPed(player)
        local targetCoords = GetEntityCoords(target)
        local targetdistance = #(targetCoords - vector3(coords.x, coords.y, coords.z))
        if targetdistance <= distance then
            closePlayers[#closePlayers + 1] = player
        end
    end

    return closePlayers
end

function DrawText3D(x, y, z, text, r, g, b, a)
    SetTextScale(0.29, 0.29)
    SetTextFont(8)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 255)
    BeginTextCommandDisplayText("STRING")
    SetTextCentre(true)
    AddTextComponentSubstringPlayerName(text)
    SetDrawOrigin(x, y, z, 0)
    SetTextColour(r, g, b, a)
    SetTextOutline()
    EndTextCommandDisplayText(0.0, 0.0)
    ClearDrawOrigin()
end

Citizen.CreateThread(function()
    while true do
        local time = 1
        if isToggled then
            local myCoords = GetEntityCoords(PlayerPedId())
            for _, player in pairs(GetPlayersFromCoords(myCoords, 10.0)) do
                local playerId = GetPlayerServerId(player)
                local playerPed = GetPlayerPed(player)
                local pos = GetEntityCoords(playerPed)
                
                local isTalking = talkingPlayers[player] or NetworkIsPlayerTalking(player) or MumbleIsPlayerTalking(player)
                
                if isTalking then
                    DrawText3D(pos.x, pos.y, pos.z + 0.9, names[playerId], 0, 255, 0, 255)
                else
                    DrawText3D(pos.x, pos.y, pos.z + 0.9, names[playerId], 255, 255, 255, 255)
                end
            end
        else
            time = 500
        end

        Citizen.Wait(time)
    end
end)

AddEventHandler('onResourceStart', function(resource)
    TriggerServerEvent('names:server:addPlayer')
    QBCore.Functions.TriggerCallback('names:server:getNames', function(sNames)
        for k, v in pairs(sNames) do
            players[tonumber(k)] = GetPlayerFromServerId(tonumber(k))
            names[tonumber(k)] = v
            isToggled = true
        end
    end)
end)

AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    TriggerServerEvent('names:server:addPlayer')
    QBCore.Functions.TriggerCallback('names:server:getNames', function(sNames)
        for k, v in pairs(sNames) do
            players[tonumber(k)] = GetPlayerFromServerId(tonumber(k))
            names[tonumber(k)] = v
            isToggled = true
        end
    end)
end)

Citizen.CreateThread(function()
    while true do
        QBCore.Functions.TriggerCallback('names:server:getNames', function(sNames)
            for k, v in pairs(sNames) do
                players[tonumber(k)] = GetPlayerFromServerId(tonumber(k))
                names[tonumber(k)] = v
            end
        end)
        Citizen.Wait(15000)
    end
end)

RegisterCommand('+toggleidssystem', function()
    isToggled = not isToggled
end, false)

RegisterKeyMapping('+toggleidssystem', 'Open Ids', 'keyboard', 'HOME')

--[[
https://discord.gg/8nCR8H3se2

████████╗██╗░░██╗██████╗░░█████╗░  ░██████╗████████╗░█████╗░██████╗░███████╗
╚══██╔══╝╚██╗██╔╝██╔══██╗██╔══██╗  ██╔════╝╚══██╔══╝██╔══██╗██╔══██╗██╔════╝
░░░██║░░░░╚███╔╝░██████╔╝███████║  ╚█████╗░░░░██║░░░██║░░██║██████╔╝█████╗░░
░░░██║░░░░██╔██╗░██╔══██╗██╔══██║  ░╚═══██╗░░░██║░░░██║░░██║██╔══██╗██╔══╝░░
░░░██║░░░██╔╝╚██╗██║░░██║██║░░██║  ██████╔╝░░░██║░░░╚█████╔╝██║░░██║███████╗
░░░╚═╝░░░╚═╝░░╚═╝╚═╝░░╚═╝╚═╝░░╚═╝  ╚═════╝░░░░╚═╝░░░░╚════╝░╚═╝░░╚═╝╚══════╝
]]