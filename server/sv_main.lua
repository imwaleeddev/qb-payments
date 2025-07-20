G_print = G_print or print
Citizen.CreateThread(function()
    Config.invoice_item = string.lower(Config.invoice_item)
    if not QBCore.Shared.Items[Config.invoice_item] then
        exports['qb-core']:AddItem(Config.invoice_item, {
            name = Config.invoice_item,
            label = 'Payments Invoice',
            weight = 0,
            useable = true,
            type = 'item',
            image = Config.invoice_item .. '.png',
            unique = true,
            shouldClose = true,
            combinable = nil,
            description = 'Payments Invoice!'
        })
    end
end)

QBCore.Functions.CreateCallback('qb-payments:server:players', function(source, cb, ...)
    local src = source
    local xPlayer = QBCore.Functions.GetPlayer(src)
    local Players = {}
    if xPlayer then
        local coords = GetEntityCoords(GetPlayerPed(src))
        for _, v in ipairs(QBCore.Functions.GetPlayers()) do
            local targetCoords = GetEntityCoords(GetPlayerPed(v))
            local distance = #(coords - targetCoords)

            if distance <= 10.0 then
                local P = QBCore.Functions.GetPlayer(v)
                if P.PlayerData.source ~= src then
                    local name = P.PlayerData.charinfo.firstname .. ' ' .. P.PlayerData.charinfo.lastname
                    Players[#Players + 1] = {
                        value = tonumber(P.PlayerData.source),
                        name = "[" .. P.PlayerData.source .. "] - " .. name,
                        citizenid = P.PlayerData.citizenid,
                    }
                end
            end
        end

        cb(Players)
    end
end)

RegisterNetEvent('qb-payments:server:charge', function(id, cart, monetType)
    local src = source
    local xPlayer = QBCore.Functions.GetPlayer(src)
    local xTarget = QBCore.Functions.GetPlayer(id)
    if not xPlayer then return G_print('Creator Is Not Found') end
    if not xTarget then
        TriggerClientEvent('QBCore:Notify', src, 'Player Not Online :(', 'error')
        return
    end
    if xPlayer then
        local info = {}
        local total = 0
        for k, v in pairs(cart) do
            total = total + (v.price)
        end
        local sender = {
            id = src,
            name = xPlayer.PlayerData.charinfo.firstname .. ' ' .. xPlayer.PlayerData.charinfo.lastname,
        }
        TriggerClientEvent('qb-payments:client:charge', xTarget.PlayerData.source, cart, total, sender, monetType)
        TriggerClientEvent('QBCore:Notify', src,
            'Invoice Sent To ' ..
            xTarget.PlayerData.charinfo.firstname ..
            ' ' .. xTarget.PlayerData.charinfo.lastname .. ' For ' .. total .. '$')
    end
end)


RegisterNetEvent('qb-payments:server:accept', function(sender, cart, monetType)
    local src = source
    local xPlayer = QBCore.Functions.GetPlayer(src)
    local xTarget = QBCore.Functions.GetPlayer(sender.id)
    if not xPlayer then return G_print('xPlayer Is Not Found') end
    if not xTarget then
        TriggerClientEvent('QBCore:Notify', src, 'Player Not Online :(', 'error')
        return
    end
    if xPlayer then
        local info = {}
        local total = 0
        for k, v in pairs(cart) do
            info[#info + 1] = {
                item = v.name,
                price = v.price,
                amount = v.amount
            }
            total = total + (v.price)
        end
        if xPlayer.Functions.RemoveMoney(monetType or 'cash', total, 'Pay With Payments System') then
            xPlayer.Functions.AddItem(Config.invoice_item, 1, nil, info)
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.invoice_item], 'add')
            if Config.SocietyTax then
                if exports['qb-management']:GetAccount(xTarget.PlayerData.job.name) then
                    local tax = math.floor((total / 100) * Config.SocietyTax)
                    exports['qb-management']:AddMoney(xTarget.PlayerData.job.name, tax)
                    total = total - tax
                else
                    G_print(xTarget.PlayerData.job.name .. ' Society Is Not Found')
                end
            end
            xTarget.Functions.AddMoney(monetType or 'cash', total, 'Pay With Payments System')
        else
            TriggerClientEvent('QBCore:Notify', src, 'You Dont Have Enough Money', 'error')
        end
    end
end)

RegisterNetEvent('qb-payments:server:decline', function(sender, cart, monetType)
    local src = source
    local xPlayer = QBCore.Functions.GetPlayer(src)
    local xTarget = QBCore.Functions.GetPlayer(sender.id)
    if not xPlayer then return G_print('xPlayer Is Not Found') end
    if not xTarget then
        TriggerClientEvent('QBCore:Notify', src, 'Player Not Online :(', 'error')
        return
    end
    if xPlayer then
        TriggerClientEvent('QBCore:Notify', xTarget.PlayerData.source, 'Your Invoice Has Been Declined', 'error')
    end
end)
