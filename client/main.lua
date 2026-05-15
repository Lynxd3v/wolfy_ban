ESX = exports.es_extended:getSharedObject()

function Panel(bool, bansList)
    local filteredBanList = {}
    for i = 1, #bansList do
        local ban = bansList[i]
        table.insert(filteredBanList, {
            name = ban.name,
            bannedby = ban.bannedby,
            time = (ban.time == 0 and 0 or os.date("%Y-%m-%d %H:%M:%S", ban.time)),
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

    if bool then
        SendNUIMessage({
            action = 'showPanel',
            banList = filteredBanList
        })
    else
        SendNUIMessage({
            action = 'hidePanel',
        })
    end
end

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
