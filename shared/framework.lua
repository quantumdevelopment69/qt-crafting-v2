if Shared.Framework == "esx" then 
    ESX = exports[Shared.FrameworkNames.esx]:getSharedObject()
elseif Shared.Framework == "qb" then 
    QBCore = exports[Shared.FrameworkNames.qb]:GetCoreObject()
end

