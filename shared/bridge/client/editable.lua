local QT = exports["qt-library"]:Load()

String = {}

function String.SendAlert(data)
    if Shared.LIBRARY_NOTIFY then
        QT.Notify(data)
    else
        -- # exports["okokNotify"]:Alert(data.title, data.message, 5000, data.type)
        --  ESX.ShowNotification(data.message)
    end
end

