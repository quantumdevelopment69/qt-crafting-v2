if Shared.Framework == "esx" then 
    ESX = exports["es_extended"]:getSharedObject()
elseif Shared.Framework == "qb" then 
    QBCore = exports['qb-core']:GetCoreObject()
end

