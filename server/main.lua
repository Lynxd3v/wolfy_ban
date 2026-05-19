AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    local player = source
    deferrals.defer()

    Wait(100)

    local banFile = LoadResourceFile(GetCurrentResourceName(), 'ban.json')
    local bans = banFile and json.decode(banFile) or {}
    local reworkFile = false

    deferrals.update('Ellenőrzés ki vagy e tiltva!')

    for i = #bans, 1, -1 do
        local ban = bans[i]
        local isBanned = false

        for k, v in pairs(ban.identifier) do
            if v == GetPlayerIdentifierByType(player, k) then
                isBanned = true
            end
        end

        if isBanned then
            if os.time() <= ban.time or ban.time == 0 then
                deferrals.done("🛑Ki vagy tiltva a szerverről!\n\nIndok: " .. ban.reason .. "\nBan ID: " .. ban.banId ..
                    "\nAdmin: " ..
                    ban.bannedby .. "\nLejár: " .. (ban.time == 0 and 'Soha' or os.date("%Y-%m-%d %H:%M:%S", ban.time)))
            else
                table.remove(bans, i)
                reworkFile = true
            end
        end
    end

    if reworkFile then
        SaveResourceFile(GetCurrentResourceName(), 'ban.json', json.encode(bans, { indent = true }), -1)
    end

    deferrals.update('Üdvözlünk a szerveren, ' .. name .. '!')

    Wait(500)

    deferrals.done()
end)

Wolfy.GetAdmin = function(type, group)
    for _, v in ipairs(Wolfy.Command[type].groups) do
        if v == group then
            return true
        end
    end
    return false
end

Wolfy.GenerateToken = function(bans)
    if #bans == 0 then return math.random(10000, 99999) end

    local id
    local unique = false

    while not unique do
        id = math.random(10000, 99999)
        unique = true

        for _, ban in ipairs(bans) do
            if ban.banId == id then
                unique = false
                break
            end
        end
    end

    return id
end

Wolfy.Message = function(source, msg)
    if source == 0 then
        print(msg)
    else
        TriggerClientEvent('esx:showNotification', source, msg)
    end
end

ESX.RegisterServerCallback('wolfy_ban:getIsPlayerAdmin', function(source, cb)
    local isAdmin = false
    local xPlayer = ESX.GetPlayerFromId(source)

    if Wolfy.GetAdmin('banpanel', xPlayer.getGroup()) then
        isAdmin = true
    end
    cb(isAdmin)
end)

RegisterCommand(Wolfy.Command['ban'].command, function(source, args)
    local banFile = LoadResourceFile(GetCurrentResourceName(), 'ban.json')
    local bans = banFile and json.decode(banFile) or {}
    local xPlayer = ESX.GetPlayerFromId(source)

    if (source == 0 and true or Wolfy.GetAdmin('ban', xPlayer.getGroup())) then
        local targetId = tonumber(args[1])
        local time = tonumber(args[2])
        local reason = table.concat(args, ' ', 3)

        if not targetId or not time or #reason == 0 then
            Wolfy.Message(source, 'Valamelyik érték nincs megadva')
            return
        end

        local xTarget = ESX.GetPlayerFromId(targetId)
        
        if xTarget then
            table.insert(bans, {
                name = GetPlayerName(targetId),
                bannedby = source == 0 and 'Console' or GetPlayerName(source),
                time = (time == 0 and 0 or time * 86400 + os.time()),
                reason = reason,
                banId = Wolfy.GenerateToken(bans),
                identifier = {
                    license = GetPlayerIdentifierByType(targetId, 'license'),
                    steam   = GetPlayerIdentifierByType(targetId, 'steam'),
                    discord = GetPlayerIdentifierByType(targetId, 'discord'),
                    fivem   = GetPlayerIdentifierByType(targetId, 'fivem'),
                    xbl     = GetPlayerIdentifierByType(targetId, 'xbl'),
                    live    = GetPlayerIdentifierByType(targetId, 'live'),
                    ip      = GetPlayerIdentifierByType(targetId, 'ip'),
                }
            })
        else
            Wolfy.Message(source, 'Nincsen ilyen IDjű játékos!')
            return
        end

        DropPlayer(targetId, 'Ki lettél tiltva!')
        SaveResourceFile(GetCurrentResourceName(), 'ban.json', json.encode(bans, { indent = true }), -1)
        Wolfy.Message(source, 'Sikeresen bannoltad a játékost! BanID: ' .. bans[#bans].banId)
    end
end, false)

RegisterCommand(Wolfy.Command['unban'].command, function(source, args)
    local banFile = LoadResourceFile(GetCurrentResourceName(), 'ban.json')
    local bans = banFile and json.decode(banFile) or {}
    local xPlayer = ESX.GetPlayerFromId(source)

    if (source == 0 and true or Wolfy.GetAdmin('unban', xPlayer.getGroup())) then
        local unbanId = tonumber(args[1])

        if not unbanId then
            Wolfy.Message(source, 'Add meg a ban ID-t!')
            return
        end

        for i = 1, #bans do
            if bans[i].banId == unbanId then
                table.remove(bans, i)
                SaveResourceFile(GetCurrentResourceName(), 'ban.json', json.encode(bans, { indent = true }), -1)
                Wolfy.Message(source, 'Sikeresen unbannoltad! BanID: ' .. unbanId)
                return
            end
        end

        Wolfy.Message(source, 'Nem található ilyen ban ID!')
    end
end, false)

ESX.RegisterServerCallback('wolfy_ban:unbanPlayer', function(source, cb, banId)
    local banFile = LoadResourceFile(GetCurrentResourceName(), 'ban.json')
    local bans = banFile and json.decode(banFile) or {}
    local xPlayer = ESX.GetPlayerFromId(source)

    if (source == 0 and true or Wolfy.GetAdmin('unban', xPlayer.getGroup())) then
        for i = 1, #bans do
            if bans[i].banId == banId then
                table.remove(bans, i)
                SaveResourceFile(GetCurrentResourceName(), 'ban.json', json.encode(bans, { indent = true }), -1)
                cb({ success = true, banList = bans })
                return
            end
        end
    end
    cb({ success = false })
end)

ESX.RegisterServerCallback('wolfy_ban:getBanTime', function(source, cb, time)
    cb((time == 0 and 0 or os.date('%Y-%m-%d %H:%M:%S', time)))
end)

function GetResourceAllowed()
    local caller = GetInvokingResource()

    if not caller then return false end

    return Wolfy.ResourceAllowed[caller] == true
end

exports('banPlayer', function(targetId, time, reason)
    local bans = json.decode(LoadResourceFile(GetCurrentResourceName(), 'ban.json')) or {}

    if not GetResourceAllowed() then
        return
    end

    table.insert(bans, {
        name = GetPlayerName(targetId),
        bannedby = source == 0 and 'Console' or GetPlayerName(source),
        time = (time == 0 and 0 or time * 86400 + os.time()),
        reason = reason,
        banId = Wolfy.GenerateToken(bans),
        identifier = {
            license = GetPlayerIdentifierByType(targetId, 'license'),
            steam   = GetPlayerIdentifierByType(targetId, 'steam'),
            discord = GetPlayerIdentifierByType(targetId, 'discord'),
            fivem   = GetPlayerIdentifierByType(targetId, 'fivem'),
            xbl     = GetPlayerIdentifierByType(targetId, 'xbl'),
            live    = GetPlayerIdentifierByType(targetId, 'live'),
            ip      = GetPlayerIdentifierByType(targetId, 'ip'),
        }
    })

    SaveResourceFile(GetCurrentResourceName(), 'ban.json', json.encode(bans, { indent = true }), -1)
    DropPlayer(targetId, 'Ki lettél tiltva!')
end)

exports('unbanPlayer', function(banId)
    local bans = json.decode(LoadResourceFile(GetCurrentResourceName(), 'ban.json')) or {}

    if not GetResourceAllowed() then
        return
    end

    for i = 1, #bans do
        if bans[i].banId == banId then
            table.remove(bans, i)
            SaveResourceFile(GetCurrentResourceName(), 'ban.json', json.encode(bans, { indent = true }), -1)
            break
        end
    end
end)
