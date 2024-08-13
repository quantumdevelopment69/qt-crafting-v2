Core = {

    getjob = function()
        if ESX ~= nil then
            return ESX.GetPlayerData().job.name
        elseif QBCore ~= nil then
            return QBCore.Functions.GetPlayerData().job.name
        end
    end,

    getGangs = function()
        return QBCore.Functions.GetPlayerData().gang.name
    end
    
}