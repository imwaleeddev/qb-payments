local Interacts = {}
local Cart = {}

function FixItems(Items)
    for k, v in pairs(Items) do
        local _item = QBCore.Shared.Items[v.name]
        _item = _item or {
            label = v.name,
            image = v.name .. '.png',
        }
        v.img = v.img or v.image or 'nui://' .. Config.Inventory .. '/html/images/' .. _item.image
        v.label = _item.label
    end
end

function SetupMenu(Items)
    SendNUIMessage({
        action = 'Menu',
        Items = Items,
        Cart = Cart,
    })
    SetNuiFocus(true, true)
end

Citizen.CreateThread(function()
    Config.Inventory = Config.Inventory or 'qb-inventory'
    for k, v in pairs(Config.Menus) do
        Citizen.CreateThread(function()
            FixItems(v.Items)
            for _, coords in pairs(v.locations) do
                if not coords.xyz then return end
                coords = type(coords) == 'vector3' and coords or vector3(coords.x, coords.y, coords.z)
                exports.interact:AddInteraction({
                    coords = coords,
                    distance = 3.0,
                    interactDst = 1.5,
                    id = 'interact_' .. k,
                    groups = v.groups,
                    options = {
                        {
                            label = v.label or 'Open Cashier !',
                            action = function(entity, coords, args)
                                SetupMenu(v.Items)
                            end,
                        },
                    }
                })
                Interacts[#Interacts + 1] = 'interact_' .. k
            end
        end)
    end
end)

RegisterNUICallback('add', function(data, cb)
    local item = data.item
    local price = tonumber(data.price)
    if item and price then
        local inCart
        for k, v in pairs(Cart) do
            if v.name == item then
                inCart = true
                v.amount = (v.amount or 1) + 1
                v.price = v.price + price
                break
            end
        end
        if not inCart then
            local _item = QBCore.Shared.Items[item]
            _item = _item or {
                label = item,
                image = item .. '.png',
            }
            Cart[#Cart + 1] = {
                name = item,
                label = _item.label,
                img = 'nui://' .. Config.Inventory .. '/html/images/' .. _item.image,
                amount = 1,
                price = price,
            }
        end
    else
        print('item', item, 'price', price)
        QBCore.Functions.Notify('Item Or Price Not Found', 'error')
    end
    cb(Cart)
end)

RegisterNUICallback('remove', function(data, cb)
    local item = data.item
    local price = tonumber(data.price)
    if item and price then
        local inCart
        for k, v in pairs(Cart) do
            if v.name == item then
                inCart = true
                v.price = v.price - (price / v.amount)
                v.amount = (v.amount or 1) - 1
                if v.amount <= 0 then
                    table.remove(Cart, k)
                end
                break
            end
        end
        if not inCart then
            QBCore.Functions.Notify('Item Not In Your Cart', 'error')
        end
    else
        print('item', item, 'price', price)
        QBCore.Functions.Notify('Item Or Price Not Found', 'error')
    end
    cb(Cart)
end)

RegisterNUICallback('trash', function(data, cb)
    local item = data.item
    if item then
        local inCart
        for k, v in pairs(Cart) do
            if v.name == item then
                table.remove(Cart, k)
                inCart = true
                break
            end
        end
        if not inCart then
            QBCore.Functions.Notify('Item Not In Your Cart', 'error')
        end
    else
        print('item', item)
        QBCore.Functions.Notify('Item Or Price Not Found', 'error')
    end
    cb(Cart)
end)

function ChargePlayer(id, type)
    print('id', id, 'type', type)
    TriggerServerEvent('qb-payments:server:charge', id, Cart, type)
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
    Cart = {}
end

RegisterNUICallback('pay', function(data, cb)
    if not Cart or #Cart <= 0 then
        QBCore.Functions.Notify('Your Cart Is Empty', 'error')
        return
    end
    local _Options = {}
    QBCore.Functions.TriggerCallback('qb-payments:server:players', function(result)
        if not result or #result <= 0 then
            QBCore.Functions.Notify('No Players Near You', 'error')
            return
        end
        for k, v in pairs(result) do
            _Options[#_Options + 1] = {
                value = v.value,
                label = v.name,
            }
        end
        local input = lib.inputDialog('Create Invoice Form', {
            {
                type = 'select',
                label = 'Player',
                required = true,
                options = _Options
            },
            {
                type = 'select',
                label = 'Method',
                required = true,
                options = {
                    {
                        value = 'cash',
                        label = 'Cash',
                    },
                    {
                        value = 'bank',
                        label = 'Bank',
                    },
                }
            },
        })

        if not input then return end
        ChargePlayer(input[1], input[2])
    end)
    cb(true)
end)

RegisterNUICallback('close', function(data, cb)
    SetNuiFocus(false, false)
    cb(true)
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        for k, v in pairs(Interacts) do
            exports.interact:RemoveInteraction(v)
        end
    end
end)


RegisterNetEvent('qb-payments:client:charge', function(_cart, total, sender, monetType)
    lib.registerContext({
        id = 'paymentRequest',
        title = 'You Got Invoice From ' .. sender.name .. ' For ' .. total .. '$',
        options = {
            {
                title = 'Accept',
                onSelect = function()
                    TriggerServerEvent('qb-payments:server:accept', sender, _cart, monetType)
                end
            },
            {
                title = 'Decline',
                onSelect = function()
                    TriggerServerEvent('qb-payments:server:decline', sender, _cart, monetType)
                end
            },
        }
    })
    lib.showContext('paymentRequest')
end)
