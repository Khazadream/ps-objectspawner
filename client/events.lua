local ox_inventory = exports.ox_inventory
local QBCore = exports['qb-core']:GetCoreObject()

-- TODO: Rework this to use ox_inventory
RegisterNetEvent('ps-objectspawner:client:containers', function(data)
    local objectData = data

    TriggerServerEvent("inventory:server:OpenInventory", "stash", "container_"..objectData.id, {maxweight = 1000000, slots = 10})
    TriggerEvent("inventory:client:SetCurrentStash", "container_"..objectData.id)

    TriggerServerEvent('ps-objectspawner:server:OpenStash', data)

end)

-- Event to remove an object with a target interaction
RegisterNetEvent('ps-objectspawner:client:removeObject', function(data)
    local src = source
    local objectData = data
    local model = objectData.propName

    -- Check if the player is a police officer and if the object is owned by the player
    local Player = QBCore.Functions.GetPlayerData()
    local PlayerName = Player.charinfo.firstname .. ' ' .. Player.charinfo.lastname
    if Player.job.name ~= "police" then
        if objectData.name ~= PlayerName then
            QBCore.Functions.Notify("Vous n'êtes pas autorisé à retirer cet objet", "error")
            return
        end
    end

    -- Give back the object to the player
    TriggerServerEvent('ka-placeableitems:server:giveBackPlaceItem', model, objectData.options)

    -- Delete the object from the database
    TriggerServerEvent("ps-objectspawner:server:DeleteObject", objectData.id)

end)

-- Event to move an object with a target interaction
RegisterNetEvent('ps-objectspawner:client:mooveObject', function(data)
    local src = source
    local objectData = data
    local model = objectData.propName

    -- Check if the player is a police officer and if the object is owned by the player
    local Player = QBCore.Functions.GetPlayerData()
    local PlayerName = Player.charinfo.firstname .. ' ' .. Player.charinfo.lastname
    if Player.job.name ~= "police" then
        if objectData.name ~= PlayerName then
            QBCore.Functions.Notify("Vous n'êtes pas autorisé à retirer cet objet", "error")
            return
        end
    end

    -- Place same object to new position
    local result = exports.object_gizmo:useGizmo(data.handle)
    local CurrentModel = model
    local finalCoords = result.position
    local CurrentObjectType = objectData.type
    local Options = objectData.options
    Options.rotation = result.rotation
    local CurrentObjectName = objectData.name
    TriggerServerEvent("ps-objectspawner:server:CreateNewObject", CurrentModel, finalCoords, CurrentObjectType, Options, CurrentObjectName)

    -- Delete the object from the database
    TriggerServerEvent("ps-objectspawner:server:DeleteObject", objectData.id)
end)