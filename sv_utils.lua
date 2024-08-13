
local QT = exports["qt-library"]:Load()
local WorkShops = {}
local Recipes = {}

AddEventHandler('onServerResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        LoadData()
    end
end)

LoadData = function()
    -- # jobs data

    local jobs = Core.GetJobs()
    GlobalState.Jobs = jobs
    
    if Shared.Framework == "qb" then 
        local gangs = Core.GetGangs()
        GlobalState.Gangs = gangs
    end

    -- # main data 

    local jsondata = LoadResourceFile(GetCurrentResourceName(), "data/tables.json")
    if jsondata then
        WorkShops = json.decode(jsondata)
        if jsondata ~= nil then 
          GlobalState.WorkShops = json.decode(jsondata)
        end
        if not WorkShops then
            WorkShops = {}
        end
    end

    -- # items cook data 

    local jsondata2 = LoadResourceFile(GetCurrentResourceName(), "data/items.json")
    if jsondata2 then
        Recipes = json.decode(jsondata2)
        if jsondata2 ~= nil then 
          GlobalState.Recipes = json.decode(jsondata2)
        end
        if not Recipes then
            Recipes = {}
        end
    end

    -- #

end

QT.RegisterServerCall("qt_crafting-CheckPerm", function(source, cb, perm)
    local identifier = QT.GetIdentifier(Shared.PlayersLicense, source)
    if Shared.Commands.perms[perm][identifier] then 
        cb(true) 
    else
        cb(false)
    end
end)

local function GenerateTableID()
    local digits = '0123456789'
    local idLength = 8
    local uniqueId = ''
    for i = 1, idLength do
        local randomIndex = math.random(1, #digits)
        uniqueId = uniqueId .. digits:sub(randomIndex, randomIndex)
    end
    return uniqueId
end

RegisterNetEvent("qt_crafting-SetupCraft", function(data)
    local id

    repeat
        id = GenerateTableID()
    until WorkShops[id] == nil

    local new_craftable = {
        id = id, 
        name = data.name, 
        model = data.model, 
        coords = data.coords, 
        blip = data.blip,
        jobs = data.jobs,
        gangs = data.gangs
    }

    WorkShops[id] = new_craftable
    Recipes[id] = {}

    UpdateJSON('workshop')
    UpdateJSON("items")
    
    TriggerClientEvent("qt-sendNotify", source, {
        title = L("main_title"), 
        msg = L("success_create"):format(data.name),
        type = "success"
    })

    LoadData()

    Wait(500)

    TriggerClientEvent("qt-crafting:Re:Sync", -1)

end)

RegisterNetEvent("qt_crafting-EditActions", function(data)
    if data.action == "delete" then 

        if GlobalState.WorkShops ~= nil and GlobalState.WorkShops[data.id] ~= nil then 
            WorkShops[data.id] = nil 
            GlobalState.WorkShops = WorkShops 
        end
        if GlobalState.Recipes ~= nil and GlobalState.Recipes[data.id] ~= nil then 
            Recipes[data.id] = nil 
            GlobalState.Recipes = Recipes
        end
        UpdateJSON('workshop')
        UpdateJSON('items')

    elseif data.action == "add_item" then 
            
        local new_item = {
            recipe = data.recipe,
            label = data.label,
            amount = data.amount, 
            craft_time = data.craft_time,  
        }

        Recipes[data.id][data.item] = new_item
        GlobalState.Recipes = Recipes
        UpdateJSON('items')

    elseif data.action == "removeItem" then 

        if GlobalState.Recipes ~= nil and GlobalState.Recipes[data.id] ~= nil then 
            Recipes[data.id][data.item] = nil 
            GlobalState.Recipes = Recipes
            UpdateJSON('items')
        end

    elseif data.action == "ChangeLabelItem" then 

        if GlobalState.Recipes ~= nil and GlobalState.Recipes[data.id] ~= nil then 
            Recipes[data.id][data.item].label = data.new_label 
            GlobalState.Recipes = Recipes
            UpdateJSON('items')
        end

    elseif data.action == "ChangeCraftTime" then 

        if GlobalState.Recipes ~= nil and GlobalState.Recipes[data.id] ~= nil then 
            Recipes[data.id][data.item].craft_time = data.new_time 
            GlobalState.Recipes = Recipes
            UpdateJSON('items')
        end

    elseif data.action == "ChangeRecipeItem" then 

        if GlobalState.Recipes ~= nil and GlobalState.Recipes[data.id] ~= nil then 
            Recipes[data.id][data.item].recipe = data.recipe 
            GlobalState.Recipes = Recipes
            UpdateJSON('items')
        end

    elseif data.action == "ChangeReward" then 

        if GlobalState.Recipes ~= nil and GlobalState.Recipes[data.id] ~= nil then 
            Recipes[data.id][data.item].amount = data.amount 
            GlobalState.Recipes = Recipes
            UpdateJSON('items')
        end

    elseif data.action == "ModifyApp" then 

        if data.section == "change_prop" then 

            if GlobalState.WorkShops ~= nil and GlobalState.WorkShops[data.id] ~= nil then 
                WorkShops[data.id].model = data.model
                GlobalState.WorkShops = WorkShops 
            end

        elseif data.section == "change_blip" then 

            if GlobalState.WorkShops ~= nil and GlobalState.WorkShops[data.id] ~= nil then 
                WorkShops[data.id].blip = data.blipData
                GlobalState.WorkShops = WorkShops 
            end

        elseif data.section == "new_pos" then 

            if GlobalState.WorkShops ~= nil and GlobalState.WorkShops[data.id] ~= nil then 
                WorkShops[data.id].coords = data.pos
                GlobalState.WorkShops = WorkShops 
            end

        elseif data.section == "new_name" then 

            if GlobalState.WorkShops ~= nil and GlobalState.WorkShops[data.id] ~= nil then 
                WorkShops[data.id].name = data.name
                GlobalState.WorkShops = WorkShops 
            end

        elseif data.section == "new_jobs" then 

            if GlobalState.WorkShops ~= nil and GlobalState.WorkShops[data.id] ~= nil then 
                WorkShops[data.id].jobs = data.jobs
                GlobalState.WorkShops = WorkShops 
            end

        elseif data.section == "new_gangs" then 

            if GlobalState.WorkShops ~= nil and GlobalState.WorkShops[data.id] ~= nil then 
                WorkShops[data.id].gangs = data.gangs
                GlobalState.WorkShops = WorkShops 
            end

        elseif data.section == "reload_defaults" then 

            if GlobalState.WorkShops ~= nil and GlobalState.WorkShops[data.id] ~= nil then 
                WorkShops[data.id].jobs = {}
                WorkShops[data.id].gangs = {}
                WorkShops[data.id].blip = {}
                GlobalState.WorkShops = WorkShops 
            end

        end

        UpdateJSON('workshop')
        
    end

    Wait(500)
    TriggerClientEvent("qt-crafting:Re:Sync", -1)

end)

UpdateJSON = function(action)
    local fileName, fileContent
    if action == "workshop" then
        fileName = "data/tables.json"
        fileContent = json.encode(WorkShops, { indent = true })
    elseif action == 'items' then
        fileName = "data/items.json"
        fileContent = json.encode(Recipes, { indent = true })
    end

    if fileName and fileContent then
        local success, err = pcall(function()
            SaveResourceFile(GetCurrentResourceName(), fileName, fileContent, -1)
        end)
        if not success then
            print("Error saving file: " .. err)
        end
    end
end

QT.RegisterServerCall("qt-crafting-CheckItems", function(source, cb, recipe)
    local totalItems = #recipe
    local itemsChecked = 0
    
    for _, data in ipairs(recipe) do
        local amount = tonumber(data.amount)
        local check = Core.HasItem(source, data.item, amount)
        if not check then 
            break  
        else
            itemsChecked = itemsChecked + 1
        end
    end
    
    if itemsChecked == totalItems then
        cb(true)
    else
        cb(false)
    end
end)

RegisterNetEvent("qt-crafting-GiveItem", function(data)
    local source = source

    if not source or not GetPlayerName(source) then
        print("Invalid source:", source)
        return
    end

    if type(data) ~= "table" or not data.item or not data.amount or not data.recipe then
        print("Invalid data format:", data)
        return
    end

    if type(data.item) ~= "string" or not tonumber(data.amount) or tonumber(data.amount) <= 0 then
        print("Invalid item or amount:", data.item, data.amount)
        return
    end

    if type(data.recipe) ~= "table" then
        print("Invalid recipe structure:", data.recipe)
        return
    end

    local hasItems = true
    for _, itemData in pairs(data.recipe) do
        if not itemData.item or not tonumber(itemData.amount) or tonumber(itemData.amount) <= 0 then
            print("Invalid recipe item or amount:", itemData.item, itemData.amount)
            hasItems = false
            break
        end

        if not Core.HasItem(source, itemData.item, tonumber(itemData.amount)) then
            hasItems = false
            break
        end
    end

    if not hasItems then
        TriggerClientEvent('qt-crafting-Notify', source, "You don't have enough items to craft.")
        return
    end

    Core.AddItem(source, data.item, tonumber(data.amount))

    for _, itemData in pairs(data.recipe) do
        Core.RemoveItem(source, itemData.item, tonumber(itemData.amount))
    end
    
end)
