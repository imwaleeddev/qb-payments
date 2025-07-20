-- .gg/slax -- made by im.waleed
QBCore = exports['qb-core']:GetCoreObject()
Config = {
    Debug = false,
    Inventory = 'qb-inventory',
    invoice_item = 'payment_invoice',
    SocietyTax = 5, -- Society Tax By Percent or false
}

Config.Menus = {
    [1] = {
        name = 'Burgershot',
        label = 'Open Burgershot Menu',
        Items = {
            {
                name = 'atomsbaconburger',
                price = 15,
            },
            {
                name = 'atomsdrink',
                price = 25,
            },
            {
                name = 'atomstburger',
                price = 55,
            },
        },
        locations = {
            vector3(-1195.19, -893.63, 14.0),
        },
        groups = {
            ['burgershot'] = 0,
        },
    }
}

G_print = print
print = function(...)
    if not Config.Debug then return end
    G_print(...)
end
