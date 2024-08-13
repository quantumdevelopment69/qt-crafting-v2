---@diagnostic disable: missing-parameter
local QT = exports["qt-library"]:Load()
local cache = {}

local DeletrSequence = function()
    for i = 1, #cache do
        DeleteObject(cache[i].obj)
    end
    for i = 1, #cache do 
        RemoveBlip(cache[i].blips)
    end
    QT.RemoveContext()
end

AddEventHandler("onResourceStop", function(res)
    if GetCurrentResourceName() == res then
        DeletrSequence()
    end
end)

RegisterNetEvent("qt-sendNotify")
AddEventHandler("qt-sendNotify", function(data)
    String.SendAlert(data)
end)

QT.AddCommand(Shared.Commands.prefix.."create", function()
    QT.TriggerServerCall("qt_crafting-CheckPerm", function(access)
        if access then 
            SetupCraft()
        else
            String.SendAlert({
                type = "system",
                title = L("main_title"),
                msg = L("insufficient_permissions")
            })
        end
    end, "create")
end)

SetupCraft = function()
    local jobs = {}
    local gangs = {}
    local blip = {}
    local model = nil

    local formFields = {
        { label = L("table_name"), type = 'input', required = true },
        { label = L("obj_hash"), type = 'input', required = false },
        { label = L("job"), value = 'checkbox', type = 'checkbox' },
        { label = L("blip"), value = 'checkbox2', type = 'checkbox' },
    }

    if Shared.Framework == "qb" then
        table.insert(formFields, { label = L("gang"), value = 'checkbox3', type = 'checkbox' })
    end

    local formData = QT.CreateBox(L("create_craft_title"), formFields)

    if formData then
        local jobsSuccess = true
        local blipSuccess = true

        if formData['input-3'] then
            jobsForm(function(jobsData)
                if not jobsData then
                    String.SendAlert({
                        type = "system",
                        title = L("main_title"),
                        msg = L("canceled_creation")
                    })
                    jobsSuccess = false
                    return
                end
                jobs = jobsData
            end)
        end

        if formData['input-4'] then
            blipForm(function(blipData)
                if not blipData then
                    String.SendAlert({
                        type = "system",
                        title = L("main_title"),
                        msg = L("canceled_creation")
                    })
                    blipSuccess = false
                    return
                end
                blip = blipData
            end)
        end

        if Shared.Framework == "qb" and formData['input-5'] then
            gangsForm(function(gangsData)
                if not gangsData then
                    String.SendAlert({
                        type = "system",
                        title = L("main_title"),
                        msg = L("canceled_creation")
                    })
                    return
                end
                gangs = gangsData
            end)
        end

        if not jobsSuccess or not blipSuccess then
            return
        end

        local questionForm = QT.Question({
            title = L("title_question_1"),
            question = L("question_1"),
            disclaimer = L("disclaimer_1"),
        })

        if questionForm == "confirm" then
            if formData['input-2'] and formData['input-2'] ~= "" then
                model = formData['input-2']
            else
                model = Shared.DefaultModel
            end
            SetupPOS(model, function(pos)
                TriggerServerEvent("qt_crafting-SetupCraft", {
                    name = formData['input-1'],
                    model = model,
                    coords = pos,
                    blip = blip,
                    jobs = jobs,
                    gangs = gangs, 
                })
            end)
        elseif questionForm == "cancel" then
            String.SendAlert({
                type = "system",
                title = L("main_title"),
                msg = L("canceled_creation")
            })
        end
    end
end

jobsForm = function(cb)
    Wait(200)
    local JobList = GlobalState.Jobs
    local options = {}

    for k, v in pairs(JobList) do
        table.insert(options, k)
    end

    local jobsInput = QT.CreateBox(L("jobs_config"), {
        { label = L("select_job"), options = options, type = 'multi-select' },
    })

    if jobsInput then 
        local jobValues = {}

        local decodedJobsInput = json.decode(jobsInput['input-1'])

        if decodedJobsInput then
            for _, selectedOption in ipairs(decodedJobsInput) do
                table.insert(jobValues, selectedOption)
            end
        end

        cb(jobValues)
    else
        cb(false)
    end
end

gangsForm = function(cb)
    Wait(200)
    local JobList = GlobalState.Gangs
    local options = {}

    for k, v in pairs(JobList) do
        table.insert(options, k)
    end

    local gangsInput = QT.CreateBox(L("gangs_config"), {
        { label = L("select_gang"), options = options, type = 'multi-select' },
    })

    if gangsInput then 
        local gangValues = {}

        local decodedgangsInput = json.decode(gangsInput['input-1'])

        if decodedgangsInput then
            for _, selectedOption in ipairs(decodedgangsInput) do
                table.insert(gangValues, selectedOption)
            end
        end

        cb(gangValues)
    else
        cb(false)
    end
end

blipForm = function(cb)
    Wait(200)
    local blipInput = QT.CreateBox(L("blip_config"), {
        { label = L("sprite_label"), type = 'number', required = true },
        { label = L("size_label"), type = 'number', required = true },
        { label = L("color_label"), type = 'number', required = true },
        { label = L("text_label"), type = 'input', required = true },
    }) 
    if blipInput then 
        local tabela = { 
            sprite = blipInput['input-1'],
            size = blipInput['input-2'],
            color = blipInput['input-3'],
            text = blipInput['input-4']
        }
        cb(tabela)
    else
        cb(false)
    end
end

local function RotationToDirection(rotation)
	local adjustedRotation =
	{
		x = (math.pi / 180) * rotation.x,
		y = (math.pi / 180) * rotation.y,
		z = (math.pi / 180) * rotation.z
	}
	local direction =
	{
		x = -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
		y = math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
		z = math.sin(adjustedRotation.x)
	}
	return direction
end

local function RayCastGamePlayCamera(distance)
    local cameraRotation = GetGameplayCamRot()
	local cameraCoord = GetGameplayCamCoord()
	local direction = RotationToDirection(cameraRotation)
	local destination =
	{
		x = cameraCoord.x + direction.x * distance,
		y = cameraCoord.y + direction.y * distance,
		z = cameraCoord.z + direction.z * distance
	}
	local a, b, c, d, e = GetShapeTestResult(StartShapeTestRay(cameraCoord.x, cameraCoord.y, cameraCoord.z, destination.x, destination.y, destination.z, -1, PlayerPedId(), 0))
	return b, c, e
end

SetupPOS = function(model, cb)
    local heading = 0
    local obj
    local created = false

    QT.RequestModel(model)
    CreateThread(function()
        while true do
            ---@diagnostic disable-next-line: need-check-nil
            local hit, coords, entity = RayCastGamePlayCamera(100.0)

            if not created then
                created = true
                obj = CreateObject(model, coords.x, coords.y, coords.z + 0.5, false, false, false)
                SetEntityCollision(obj, false, true)
                SetEntityAlpha(obj, 180, false)
                
            end

            SendNUIMessage({
                action = "SetupHelpOn"
            })

            if IsControlPressed(0, 174) then
                heading = heading + 1.5
            end

            if IsControlPressed(0, 175) then
                heading = heading - 1.5
            end

            if IsDisabledControlPressed(0, 176) then
                local pos = vector4(coords.x, coords.y, coords.z, heading)
                cb(pos)
                DeleteObject(obj)
                SendNUIMessage({
                    action = "SetupHelpOff"
                })

                break
            end

            local pedPos = GetEntityCoords(PlayerPedId())
            local distance = #(coords - pedPos)

            if distance >= 1.5 then
                SetEntityCoords(obj, coords.x, coords.y, coords.z + 0.5)
                SetEntityHeading(obj, heading)
            end
            Wait(0)
        end
    end)
    collectgarbage("collect")
end

AddEventHandler('onClientResourceStart', function (resourceName)
    if(GetCurrentResourceName() ~= resourceName) then return end
     CreateTables()
end)

local CanAcces = function(id)
    local jobs = GlobalState.WorkShops[id]["jobs"]
    local gangs = GlobalState.WorkShops[id]["gangs"]

    if jobs ~= nil and #jobs > 0 then
        for i = 1, #jobs do
            if Core.getjob() == jobs[i] then
                return true
            end
        end
        return false
    end

    if Shared.Framework == "qb" and gangs ~= nil and #gangs > 0 then
        for i = 1, #gangs do
            if Core.getGangs() == gangs[i] then
                return true
            end
        end
        return false
    end

    return true
end


CreateTables = function()
    Wait(500)
    if GlobalState.WorkShops ~= nil then 
        for k, v in pairs (GlobalState.WorkShops) do 

            QT.RequestModel(v.model)
            propobj = CreateObject(v.model, vector3(v.coords.x, v.coords.y, v.coords.z), false, true)
            SetEntityHeading(propobj, v.coords.w)
            FreezeEntityPosition(propobj, true) 
            SetEntityInvincible(propobj, true)
            table.insert(cache, {
                obj = propobj,
            })
            SetModelAsNoLongerNeeded(v.model)
            PlaceObjectOnGroundProperly(propobj)
            if Shared.Target == "ox_target" then  
                exports.ox_target:addLocalEntity(propobj, {
                    {
                        name = 'table_'..k,
                        label = L('enter_craft'),
                        icon = "fa-solid fa-hammer",
                        distance = 3,
                        canInteract = function()
                        local access = CanAcces(v.id)
                            if access then 
                                return true 
                            else
                                return false 
                            end
                        end,
                        onSelect = function(data)
                            OpenCraftMenu(v.id)
                        end,
                    }
                })
            elseif Shared.Target == "qb-target" then
                exports['qb-target']:AddTargetEntity(propobj, {
                    options = {
                        {
                            icon = "fa-solid fa-hammer",
                            label = L('enter_craft'),
                            canInteract = function()
                            local access = CanAcces(v.id)
                                if access then 
                                    return true 
                                else
                                    return false 
                                end
                            end,
                            action = function()
                                OpenCraftMenu(v.id)
                            end,
                        }
                    },
                    distance = 3.0
                })
            end
            if GlobalState.WorkShops[k].blip ~= nil then 
                CreateBlip({
                    coords = GlobalState.WorkShops[k].coords, 
                    sprite = tonumber(GlobalState.WorkShops[k].blip.sprite), 
                    color = tonumber(GlobalState.WorkShops[k].blip.color), 
                    size = tonumber(GlobalState.WorkShops[k].blip.size), 
                    text = GlobalState.WorkShops[k].blip.text
                })
            end

        end
    end
end

RegisterNetEvent("qt-crafting:Re:Sync")
 AddEventHandler("qt-crafting:Re:Sync", function()
    DeletrSequence()
    CreateTables()
end)

OpenCraftMenu = function(id)

        SendNUIMessage({
            action = "CraftMenu", 
            tableIndex = id, 
            TableName = GlobalState.WorkShops[id].name,
            Inventory = Shared.ImagePath, 
            recipes = GlobalState.Recipes
        })
        SetNuiFocus(true, true)

end

exports('OpenMenu', OpenCraftMenu)

QT.AddCommand(Shared.Commands.prefix.."edit", function()
    QT.TriggerServerCall("qt_crafting-CheckPerm", function(access)
        if access then 
            EditMenu()
        else
            String.SendAlert({
                type = "system",
                title = L("main_title"),
                msg = L("insufficient_permissions")
            })
        end
    end, "edit")
end)

EditMenu = function()
    local opcije = {} 
    for k, v in pairs (GlobalState.WorkShops) do 
        table.insert(opcije, {
            title = v.name,
            icon = 'fa-solid fa-wrench',
            event = "qt_crafting-EditTable",
            description = "To modify click arrow",
            args = { id = v.id, name = v.name },
            arrow = true,
        })
    end
    QT.RegisterContextIndex({
        menu_id = 'editMenu',
        header = L('edit_menu_title'),
        options = opcije
    })
    QT.ShowContext("editMenu")
end

AddEventHandler("qt_crafting-EditTable", function(data)
    Wait(100)
    QT.RegisterContextIndex({
        menu_id = "editMenu2",
        header = data.name,
        back = "editMenu",
        options = {
            {
                title = L("modify_items"),
                description = L("modify_items_desc"),
                icon = "fa-solid fa-toolbox",
                arrow = true, 
                event = "qt_crafting-ModifyItems",
                args = { id = data.id, name = data.name }
            },
            {
                title = L("change_position"),
                description = L("change_position_desc"),
                icon = "fa-solid fa-map-location-dot",
                arrow = true, 
                event = "qt_crafting-ModifyApp",
                args = { id = data.id, name = data.name }
            },
            {
                title = L("teleport_table"),
                description = L("teleport_table_desc"),
                icon = "fa-brands fa-google-play",
                arrow = true, 
                event = "qt_crafting-TeleportTable",
                args = data.id
            },
            {
                title = L("delete_table"),
                description = L("delete_table_desc"),
                icon = "fa-solid fa-trash-can",
                arrow = true, 
                serverEvent = "qt_crafting-EditActions",
                args = { action = "delete", id = data.id, name = data.name }
            },
        }
    })
    QT.ShowContext("editMenu2") 
end)

AddEventHandler("qt_crafting-TeleportTable", function(table_id)
    local coords = GlobalState.WorkShops[table_id].coords
    SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z)
    SetEntityHeading(PlayerPedId(), coords.w)
    String.SendAlert({
        type = "info",
        title = L("main_title"),
        msg = L("successfully_teleported")
    })
end)

AddEventHandler("qt_crafting-ModifyApp", function(data)
    Wait(100)
    QT.RegisterContextIndex({
        menu_id = "modifyapp",
        header = data.name,
        back = "editMenu2",
        options = {
            {
                title = L("change_prop"),
                description = L("change_prop_desc"),
                icon = "fa-solid fa-kaaba",
                arrow = true, 
                event = "qt_crafting-ModifyApp2",
                args = { id = data.id, action = "ModifyApp", section = "change_prop" }
            },
            {
                title = L("change_blip"),
                description = L("change_blip_desc"),
                icon = "fa-solid fa-location-dot",
                arrow = true, 
                event = "qt_crafting-ModifyApp2",
                args = { id = data.id, action = "ModifyApp", section = "change_blip" }
            },
            {
                title = L("set_new_pos"),
                description = L("set_new_pos_desc"),
                icon = "fa-solid fa-up-down-left-right",
                arrow = true, 
                event = "qt_crafting-ModifyApp2",
                args = { id = data.id, action = "ModifyApp", section = "new_pos" }
            },
            {
                title = L("set_new_name"),
                description = L("set_new_name_desc"),
                icon = "fa-solid fa-square-h",
                arrow = true, 
                event = "qt_crafting-ModifyApp2",
                args = { id = data.id, action = "ModifyApp", section = "new_name" }
            },
            {
                title = L("change_access"),
                description = L("change_access_desc"),
                icon = "fa-solid fa-suitcase",
                arrow = true, 
                event = "qt_crafting-ModifyApp2",
                args = { id = data.id, action = "ModifyApp", section = "new_jobs" }
            },
            {
                title = L("change_access_gangs"),
                description = L("change_access_gangs_desc"),
                icon = "fa-solid fa-cannabis",
                arrow = true, 
                event = "qt_crafting-ModifyApp2",
                args = { id = data.id, action = "ModifyApp", section = "new_gangs" }
            },
            {
                title = L("reload_defaults"),
                description = L("reload_defaults_desc"),
                icon = "fa-solid fa-repeat",
                arrow = true, 
                event = "qt_crafting-ModifyApp2",
                args = { id = data.id, action = "ModifyApp", section = "reload_defaults" }
            },
        }
    })
    QT.ShowContext("modifyapp") 
end)

AddEventHandler("qt_crafting-ModifyApp2", function(data)
    Wait(100)

    if data.section == "change_prop" then 

        local formData = QT.CreateBox(L("change_prop_title"), {
            { label = L("enter_new_model"), type = 'input', required = true },
        })
        if formData then 
            TriggerServerEvent("qt_crafting-EditActions", { action = data.action, section = data.section, id = data.id, model = formData['input-1'] } )
            String.SendAlert({
                type = "success",
                title = L("main_title"),
                msg = L("change_success")
            })
        end

    elseif data.section == "change_blip" then 

        blipForm(function(blipData)
            if blipData then 
              TriggerServerEvent("qt_crafting-EditActions", { action = data.action, section = data.section, id = data.id, blipData = blipData } )
              String.SendAlert({
                type = "success",
                title = L("main_title"),
                msg = L("change_success")
            })
            else
                String.SendAlert({
                    type = "system",
                    title = L("main_title"),
                    msg = L("canceled_blipsettings")
                })  
            end
        end)

    elseif data.section == "new_pos" then 

        SetupPOS(GlobalState.WorkShops[data.id].model, function(pos)
            TriggerServerEvent("qt_crafting-EditActions", { action = data.action, section = data.section, id = data.id, pos = pos } )
            String.SendAlert({
                type = "success",
                title = L("main_title"),
                msg = L("change_success")
            })
        end)

    elseif data.section == "new_name" then 

        local formData = QT.CreateBox(L("new_name_title"), {
            { label = L("enter_new_name"), type = 'input', required = true },
        })
        if formData then 
            TriggerServerEvent("qt_crafting-EditActions", { action = data.action, section = data.section, id = data.id, name = formData['input-1'] } )
            String.SendAlert({
                type = "success",
                title = L("main_title"),
                msg = L("change_success")
            })
        end

    elseif data.section == "new_jobs" then 

        jobsForm(function(jobsData)
            if jobsData then 
                TriggerServerEvent("qt_crafting-EditActions", { action = data.action, section = data.section, id = data.id, jobs = jobsData } )
                String.SendAlert({
                    type = "success",
                    title = L("main_title"),
                    msg = L("change_success")
                })
            else
                String.SendAlert({
                    type = "system",
                    title = L("main_title"),
                    msg = L("canceled_jobsettings")
                })  
            end
        end)

    elseif data.section == "new_gangs" then 

        if Shared.Framework == "qb" then 
            gangsForm(function(gangsData)
                if gangsData then
                    TriggerServerEvent("qt_crafting-EditActions", { action = data.action, section = data.section, id = data.id, gangs = gangsData } )
                    String.SendAlert({
                        type = "success",
                        title = L("main_title"),
                        msg = L("change_success")
                    })
                else
                    String.SendAlert({
                        type = "system",
                        title = L("main_title"),
                        msg = L("canceled_gangsettings")
                    })  
                end
            end)
        else
            String.SendAlert({
                type = "system",
                title = L("main_title"),
                msg = L("only_for_qb")
            })  
        end

    elseif data.section == "reload_defaults" then 
        TriggerServerEvent("qt_crafting-EditActions", { action = data.action, section = data.section, id = data.id } )
        String.SendAlert({
            type = "success",
            title = L("main_title"),
            msg = L("change_success")
        })
    end

end)

AddEventHandler("qt_crafting-ModifyItems", function(data)
    Wait(100)
    QT.RegisterContextIndex({
        menu_id = "modifyItems",
        header = data.name,
        back = "editMenu2",
        options = {
            {
                title = L("AddItems"),
                description = L("AddItems_desc"),
                icon = "fa-solid fa-file-circle-plus",
                arrow = true, 
                event = "qt_crafting-AddItems",
                args = data.id
            },
            {
                title = L("items_list"),
                description = L("items_list_desc"),
                icon = "fa-solid fa-sheet-plastic",
                arrow = true, 
                event = "qt_crafting-ItemsListing",
                args = data.id
            },
        }
    })
    QT.ShowContext("modifyItems") 
end)

function createRecipe(numRecipe, cb)
    local recipetable = {}
    for i = 1, numRecipe do
        Wait(200)
        local recipeInput = QT.CreateBox(L('reciepe_item').. ' (' .. i .. '/' ..numRecipe..')', {
            { label = L("item_name"), type = 'input', required = true },
            { label = L("item_label"), type = 'input', required = true },
            { label = L("item_amount"), type = 'input', required = true },
        })
        if not recipeInput then return end 
         table.insert(recipetable, { 
            item = recipeInput['input-1'], 
            label = recipeInput['input-2'], 
            amount = recipeInput['input-3'] 
        })
    end
    cb(recipetable)
end

AddEventHandler("qt_crafting-AddItems", function(table_id)
    Wait(200)
    local formData = QT.CreateBox(L("adding_items_title"), {
        { label = L("item_name"), type = 'input', required = true },
        { label = L("item_label"), type = 'input', required = true },
        { label = L("reward_amound"), type = 'input', required = true },
        { label = L("craft_time"), type = 'number', required = true },
        { label = L("required_items_number"), type = 'number', required = true },
    })
    if formData then 
        createRecipe(formData['input-5'], function(recipe)
           TriggerServerEvent("qt_crafting-EditActions", {
              action = "add_item", 
              item = formData['input-1'],
              label = formData['input-2'],
              amount = formData['input-3'],
              craft_time = tonumber(formData['input-4']),  
              id = table_id,
              recipe = recipe
           })
        end)
    end
end)

RegisterNUICallback("close", function()
    SetNuiFocus(false, false)
end)

AddEventHandler("qt_crafting-ItemsListing", function(table_id)
    Wait(200)
    local opcije = {} 
    for k, v  in pairs (GlobalState.Recipes[table_id]) do 
        table.insert(opcije, {
            title = v.label,
            icon = 'fa-solid fa-gear',
            event = "qt_crafting-ItemUpdateMenu",
            args = { item = k, table_id = table_id, label = v.label },
        })
    end
    QT.RegisterContextIndex({
        menu_id = 'items_list_tableee',
        header = L('items_list'),
        back = "editMenu2",
        options = opcije
    })
    QT.ShowContext('items_list_tableee')
end)

AddEventHandler("qt_crafting-ItemUpdateMenu", function(data)
    Wait(100)
    QT.RegisterContextIndex({
        menu_id = "manipulate_iteme",
        header = data.label,
        back = "items_list_tableee",
        options = {
            {
                title = L("RemoveItem"),
                description = L("RemoveItem_desc"),
                icon = "fa-solid fa-trash-can",
                arrow = true, 
                serverEvent = "qt_crafting-EditActions",
                args = { action = "removeItem", id = data.table_id, item = data.item }
            },
            {
                title = L("Change_Label_Item"),
                description = L("Change_Label_Item_desc"),
                icon = "fa-solid fa-tv",
                arrow = true, 
                event = "qt_crafting-ItemUpdateMenu2",
                args = { action = "ChangeLabelItem", id = data.table_id, item = data.item }
            },
            {
                title = L("change_recipe_item"),
                description = L("change_recipe_item_desc"),
                icon = "fa-solid fa-newspaper",
                arrow = true, 
                event = "qt_crafting-ItemUpdateMenu2",
                args = { action = "ChangeRecipeItem", id = data.table_id, item = data.item }
            },
            {
                title = L("craft_time_change_item"),
                description = L("craft_time_change_item_desc"),
                icon = "fa-regular fa-clock",
                arrow = true, 
                event = "qt_crafting-ItemUpdateMenu2",
                args = { action = "ChangeCraftTime", id = data.table_id, item = data.item }
            },
            {
                title = L("change_item_amount_reward"),
                description = L("change_item_amount_reward_desc"),
                icon = "fa-solid fa-mountain-sun",
                arrow = true, 
                event = "qt_crafting-ItemUpdateMenu2",
                args = { action = "ChangeReward", id = data.table_id, item = data.item }
            },
        }
    })
    QT.ShowContext("manipulate_iteme") 
end)

AddEventHandler("qt_crafting-ItemUpdateMenu2", function(data)
    Wait(200)
    if data.action == "ChangeLabelItem" then 
        local formData = QT.CreateBox(L("items_display_change"), {
            { label = L("item_name_new"), type = 'input', required = true },
        })
        if formData then 
            TriggerServerEvent("qt_crafting-EditActions", { action = data.action, new_label = formData['input-1'], id = data.id, item = data.item })
        end
    elseif data.action == "ChangeCraftTime" then 
        local formData = QT.CreateBox(L("items_craftime_change"), {
            { label = L("item_craftime_new"), type = 'number', required = true },
        })
        if formData then 
            TriggerServerEvent("qt_crafting-EditActions", { action = data.action, new_time = formData['input-1'], id = data.id, item = data.item })
        end
    elseif data.action == "ChangeRecipeItem" then 
        local formData = QT.CreateBox(L("adding_items_title"), {
            { label = L("required_items_number"), type = 'number', required = true },
        })
        if formData then 
            createRecipe(formData['input-1'], function(recipe)
               TriggerServerEvent("qt_crafting-EditActions", { action = data.action, item = data.item, id = data.id, recipe = recipe })
            end)
        end
    elseif data.action == "ChangeReward" then 
        local formData = QT.CreateBox(L("change_reward_am_title"), {
            { label = L("new_reward_amount"), type = 'number', required = true },
        })
        if formData then 
            TriggerServerEvent("qt_crafting-EditActions", { action = data.action, amount = tonumber(formData['input-1']), id = data.id, item = data.item })
        end
    end
    String.SendAlert({
        type = "success",
        title = L("main_title"),
        msg = L("change_success")
    })
end)

CreateBlip = function(data)
    blip = AddBlipForCoord(data.coords.x, data.coords.y, data.coords.z)
    SetBlipSprite(blip, data.sprite)
    SetBlipScale(blip, data.size) 
    SetBlipColour(blip, data.color) 
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(data.text)
    EndTextCommandSetBlipName(blip)
    table.insert(cache, {
        blips = blip,
    })
end

RegisterNUICallback("HasItems", function(data, cb)
    QT.TriggerServerCall("qt-crafting-CheckItems", function(canCraft)
        if canCraft then 
            cb(true)
            QT.SetBusy(true)
        else
            cb(false) 
            String.SendAlert({
                type = "system",
                title = L("main_title"),
                msg = L("not_enough_to_craft")
            })
        end
    end, data.recipe)
end)

RegisterNUICallback("GiveItem", function(data)
    QT.SetBusy(false) 
    TriggerServerEvent("qt-crafting-GiveItem", data)
end)