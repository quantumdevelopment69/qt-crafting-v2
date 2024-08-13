Shared = {}
Shared.Locale = "en"
Shared.Framework = "esx" -- # esx, qb
Shared.Target = "ox_target" -- # supports qb-target and ox_target
Shared.LIBRARY_NOTIFY = true 
Shared.ImagePath = "ox_inventory/web/images/" -- # where images for items will display
Shared.DefaultModel = "gr_prop_gr_bench_02a" -- # if you dont want other prop or just dont want to fulfil prop field into creation menu 

-- # inventory paths 
--[[
    "qb-inventory/html/images/"
    "lj-inventory/html/images/"
    "ox_inventory/web/images/"
    "qs-inventory/html/images/"
    "ps-inventory/html/images/"
]]

Shared.FrameworkNames = {
    esx = "es_extended",
    qb = "qb-core",
}

Shared.PlayersLicense = "steam" -- # steam, license, discord, IP adress
Shared.Commands = {
    prefix = "craft:",
    perms = {
        ["create"] = {
            ["steam:1100001015109d9"] = true, -- # steam or rockstar license ( its from server to server )
        },
        ["edit"] = {
            ["steam:1100001015109d9"] = true, -- # steam or rockstar license ( its from server to server )
        },
    },
}

-- # to do ( readme, busy docs, library docs, )
