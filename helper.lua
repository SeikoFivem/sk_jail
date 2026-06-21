-- Script Helper pour obtenir votre identifiant
-- Ce script affiche votre identifiant dans le chat quand vous tapez /myid

RegisterCommand('myid', function(source, args, rawCommand)
    if source == 0 then
        print("Cette commande doit être utilisée en jeu, pas depuis la console serveur.")
        return
    end
    
    local identifiers = GetPlayerIdentifiers(source)
    local message = "^3=== VOS IDENTIFIANTS ===^0\n"
    
    for _, id in ipairs(identifiers) do
        message = message .. "^2" .. id .. "^0\n"
    end
    
    message = message .. "\n^1IMPORTANT:^0 Pour Rockstar/Epic, utilisez l'identifiant ^3license:^0"
    
    TriggerClientEvent('chat:addMessage', source, {
        color = {255, 255, 0},
        multiline = true,
        args = {"Vos identifiants", message}
    })
    
    -- Aussi dans les logs serveur
    print(string.format("[JAIL HELPER] Identifiants de %s:", GetPlayerName(source)))
    for _, id in ipairs(identifiers) do
        print("  - " .. id)
    end
end, false)

-- Afficher automatiquement l'ID à la connexion (désactiver en production)
AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    local source = source
    
    -- Attendre que le joueur soit complètement connecté
    Citizen.Wait(5000)
    
    local identifiers = GetPlayerIdentifiers(source)
    
    print(string.format("^3[JAIL HELPER] %s s'est connecté avec les identifiants suivants:^0", name))
    for _, id in ipairs(identifiers) do
        print("  ^2- " .. id .. "^0")
    end
end)

print("^2[JAIL HELPER] Script chargé ! Tapez /myid en jeu pour voir vos identifiants.^0")
