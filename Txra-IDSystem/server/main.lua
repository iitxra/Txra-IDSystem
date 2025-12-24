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
local names = {}
local nextID = 1000

local function GetNextID()
    local result = nextID
    nextID = nextID + 1
    return result
end

RegisterNetEvent('names:server:addPlayer', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if Player then
        if not Player.PlayerData.metadata.serverid or Player.PlayerData.metadata.serverid == 0 then
            local newID = GetNextID()
            Player.Functions.SetMetaData('serverid', newID)
        end
        TriggerClientEvent('names:client:insert', -1, src, Player.PlayerData.metadata.serverid, GetPlayerName(src))
        names[src] = GetPlayerName(src) .. Config.IdColor .. Player.PlayerData.metadata.serverid .. ' ~'
    end
    Wait(250)
    TriggerClientEvent('qb-admin:client:updateCache', -1)
end)

AddEventHandler("playerDropped", function()
    local src = source
    local xPlayer = QBCore.Functions.GetPlayer(src)
    if xPlayer then
        names[src] = nil
        TriggerClientEvent("names:client:remove", -1, src)
    end
    Wait(250)
    TriggerClientEvent('qb-admin:client:updateCache', -1)
end)

RegisterCommand('changeid', function(source, args, rawCommand)
    local src = source
    
    if not QBCore.Functions.HasPermission(src, 'admin') then
        TriggerClientEvent('QBCore:Notify', src, 'No Permission', 'error')
        return
    end
    
    local currentID = tonumber(args[1])
    local newID = tonumber(args[2])
    
    if not currentID or not newID then
        TriggerClientEvent('QBCore:Notify', src, 'Usage: /ChangeId [Current ID] [New ID]', 'error')
        return
    end
    
    local targetPlayer = nil
    local Players = QBCore.Functions.GetQBPlayers()
    
    for k, v in pairs(Players) do
        if v.PlayerData.metadata.serverid == currentID then
            targetPlayer = v
            break
        end
    end
    
    if targetPlayer then
        targetPlayer.Functions.SetMetaData('serverid', newID)
        TriggerClientEvent('QBCore:Notify', targetPlayer.PlayerData.source, 'Your ID changed to: ' .. newID, 'success')
        TriggerClientEvent('QBCore:Notify', src, 'ID changed from ' .. currentID .. ' to ' .. newID, 'success')
        TriggerClientEvent('names:client:update', targetPlayer.PlayerData.source)
        TriggerEvent('names:server:addPlayer')
    else
        TriggerClientEvent('QBCore:Notify', src, 'Player with ID ' .. currentID .. ' not found', 'error')
    end
end, false)

QBCore.Functions.CreateCallback('names:server:getNames', function(source, cb)
    cb(names)
end)

--[[
https://discord.gg/8nCR8H3se2

████████╗██╗░░██╗██████╗░░█████╗░  ░██████╗████████╗░█████╗░██████╗░███████╗
╚══██╔══╝╚██╗██╔╝██╔══██╗██╔══██╗  ██╔════╝╚══██╔══╝██╔══██╗██╔══██╗██╔════╝
░░░██║░░░░╚███╔╝░██████╔╝███████║  ╚█████╗░░░░██║░░░██║░░██║██████╔╝█████╗░░
░░░██║░░░░██╔██╗░██╔══██╗██╔══██║  ░╚═══██╗░░░██║░░░██║░░██║██╔══██╗██╔══╝░░
░░░██║░░░██╔╝╚██╗██║░░██║██║░░██║  ██████╔╝░░░██║░░░╚█████╔╝██║░░██║███████╗
░░░╚═╝░░░╚═╝░░╚═╝╚═╝░░╚═╝╚═╝░░╚═╝  ╚═════╝░░░░╚═╝░░░░╚════╝░╚═╝░░╚═╝╚══════╝
]]