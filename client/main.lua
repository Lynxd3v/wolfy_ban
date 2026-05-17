ESX = exports.es_extended:getSharedObject()

TriggerEvent('chat:addSuggestion', '/'..Wolfy.Command['unban'].command, 'Játékos unbannolása', {
    { name="banId", help="Játékos ban ID-ja" },
})

TriggerEvent('chat:addSuggestion', '/'..Wolfy.Command['ban'].command, 'Játékos kitiltása', {
    { name="id", help="Játékos ID" },
    { name="time", help="Kitiltás időtartama napokban (0 = örökre)" },
    { name="reason", help="Kitiltás oka" }
})

TriggerEvent('chat:addSuggestion', '/'..Wolfy.Command['banpanel'].command, 'Ban panel')

function Panel(bool, bansList)
    if bool then
        local filteredBanList = {}
        for i = 1, #bansList do
            local ban = bansList[i]
            table.insert(filteredBanList, {
                name = ban.name,
                bannedby = ban.bannedby,
                time = (ban.time == 0 and 0 or os.date('%Y-%m-%d %H:%M:%S', ban.time)),
                reason = ban.reason,
                banId = ban.banId,
                identifier = {
                    license = ban.identifier.license,
                    discord = ban.identifier.discord,
                    fivem   = ban.identifier.fivem,
                    ip      = ban.identifier.ip,
                }
            })
        end
        SendNUIMessage({
            action = 'showPanel',
            banList = filteredBanList
        })
    else
        SendNUIMessage({
            action = 'hidePanel',
        })
    end

    SetNuiFocus(bool, bool)
end

RegisterNUICallback('closePanel', function()
    Panel(false)
end)

RegisterNUICallback('unban', function(data, cb)
    cb('ok')

    ESX.TriggerServerCallback('wolfy_ban:unbanPlayer', function(data2)
        if data2.success then
            Panel(true, data2.banList)
            ESX.ShowNotification('Sikeresen unbanned player!')
        else
            ESX.ShowNotification('Hiba történt a player unbanolásakor!')
        end
    end,data.banId)

end)

RegisterCommand(Wolfy.Command['banpanel'].command, function()
    local bans = json.decode(LoadResourceFile(GetCurrentResourceName(), 'ban.json'))

    ESX.TriggerServerCallback('wolfy_ban:getIsPlayerAdmin', function(isAdmin)
        if isAdmin then
            Panel(true, bans)
        else
            ESX.ShowNotification('Nincsen megfelelő jogosultságod!')
        end
    end)
end, false)
