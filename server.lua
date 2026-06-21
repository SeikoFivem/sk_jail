local JailedPlayers = {}

-- Fonction pour vérifier les permissions
function HasPermission(source)
    -- OPTION 1 : Tout le monde peut utiliser (pour les tests)
    -- return true
    
    -- OPTION 2 : Vérifier avec ace permissions
    if IsPlayerAceAllowed(source, "jail.command") then
        return true
    end
    
    -- OPTION 3 : Vérifier le groupe
    if IsPlayerAceAllowed(source, "group.admin") or 
       IsPlayerAceAllowed(source, "group.moderator") or 
       IsPlayerAceAllowed(source, "group.superadmin") then
        return true
    end
    
    -- OPTION 4 : Framework ESX
    -- if ESX ~= nil then
    --     local xPlayer = ESX.GetPlayerFromId(source)
    --     if xPlayer and (xPlayer.getGroup() == "admin" or xPlayer.getGroup() == "superadmin" or xPlayer.getGroup() == "moderator") then
    --         return true
    --     end
    -- end
    
    -- OPTION 5 : Framework QB-Core
    -- if QBCore ~= nil then
    --     local Player = QBCore.Functions.GetPlayer(source)
    --     local permission = QBCore.Functions.HasPermission(source, "admin") or QBCore.Functions.HasPermission(source, "god")
    --     if permission then
    --         return true
    --     end
    -- end
    
    return false
end

-- Fonction pour obtenir le groupe du joueur (à adapter selon votre framework)
function GetPlayerGroup(source)
    -- ESX
    -- if ESX ~= nil then
    --     local xPlayer = ESX.GetPlayerFromId(source)
    --     return xPlayer and xPlayer.getGroup() or "user"
    -- end
    
    -- QB-Core
    -- if QBCore ~= nil then
    --     local Player = QBCore.Functions.GetPlayer(source)
    --     if QBCore.Functions.HasPermission(source, "god") then
    --         return "god"
    --     elseif QBCore.Functions.HasPermission(source, "admin") then
    --         return "admin"
    --     end
    --     return "user"
    -- end
    
    -- Par défaut, utilise ace permissions
    if IsPlayerAceAllowed(source, "group.admin") then
        return "admin"
    elseif IsPlayerAceAllowed(source, "group.moderator") then
        return "moderator"
    else
        return "user"
    end
end

-- Commande pour envoyer un joueur en prison
RegisterCommand('jail', function(source, args, rawCommand)
    if not HasPermission(source) then
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            multiline = true,
            args = {"Système", "Vous n'avez pas la permission d'utiliser cette commande."}
        })
        return
    end

    if #args < 2 then
        -- Afficher l'aide avec le format moderne
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 255, 255},
            multiline = true,
            args = {"", "^3/jail^0 [ID] [temps en minutes] [raison]"}
        })
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 255, 255},
            multiline = true,
            args = {"", "    Emprisonne un joueur pour une durée déterminée"}
        })
        return
    end

    local targetId = tonumber(args[1])
    local jailTime = tonumber(args[2]) * 60 -- Convertir en secondes
    local reason = table.concat(args, " ", 3) or "Aucune raison spécifiée"

    if not targetId or not GetPlayerName(targetId) then
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            multiline = true,
            args = {"Erreur", "Joueur introuvable."}
        })
        return
    end

    if jailTime < Config.MinJailTime then
        jailTime = Config.MinJailTime
    elseif jailTime > Config.MaxJailTime then
        jailTime = Config.MaxJailTime
    end

    JailPlayer(targetId, jailTime, reason, source)
end, false)


-- Fonction pour emprisonner un joueur
function JailPlayer(playerId, time, reason, admin)
    local playerName = GetPlayerName(playerId)
    local adminName = admin and GetPlayerName(admin) or "Console"

    JailedPlayers[playerId] = {
        time = time,
        reason = reason,
        startTime = os.time()
    }

    TriggerClientEvent('jail:sendToJail', playerId, time, reason)
    
    -- Notification au joueur emprisonné
    TriggerClientEvent('chat:addMessage', playerId, {
        color = {255, 0, 0},
        multiline = true,
        args = {"Prison", string.format("Vous avez été emprisonné pour %d minutes. Raison: %s", math.floor(time/60), reason)}
    })

    -- Notification à l'admin
    if admin then
        TriggerClientEvent('chat:addMessage', admin, {
            color = {0, 255, 0},
            multiline = true,
            args = {"Succès", string.format("%s a été emprisonné pour %d minutes.", playerName, math.floor(time/60))}
        })
    end

    -- Notification globale aux admins
    TriggerClientEvent('chat:addMessage', -1, {
        color = {255, 165, 0},
        multiline = true,
        args = {"Info Prison", string.format("%s a été emprisonné par %s pour %d minutes.", playerName, adminName, math.floor(time/60))}
    })

    print(string.format("[JAIL] %s a emprisonné %s pour %d secondes. Raison: %s", adminName, playerName, time, reason))
end

-- Commande pour libérer un joueur
RegisterCommand('unjail', function(source, args, rawCommand)
    if not HasPermission(source) then
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            multiline = true,
            args = {"Système", "Vous n'avez pas la permission d'utiliser cette commande."}
        })
        return
    end

    if #args < 1 then
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 255, 255},
            multiline = true,
            args = {"", "^3/unjail^0 [ID]"}
        })
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 255, 255},
            multiline = true,
            args = {"", "    Libère un joueur de prison"}
        })
        return
    end

    local targetId = tonumber(args[1])

    if not targetId or not GetPlayerName(targetId) then
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            multiline = true,
            args = {"Erreur", "Joueur introuvable."}
        })
        return
    end

    if not JailedPlayers[targetId] then
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            multiline = true,
            args = {"Erreur", "Ce joueur n'est pas en prison."}
        })
        return
    end

    ReleasePlayer(targetId, source)
end, false)

-- Ajouter les suggestions de commande
TriggerEvent('chat:addSuggestion', '/unjail', 'Libère un joueur de prison', {
    { name = "ID", help = "ID du joueur à libérer" }
})

-- Fonction pour libérer un joueur
function ReleasePlayer(playerId, admin)
    local playerName = GetPlayerName(playerId)
    local adminName = admin and GetPlayerName(admin) or "Système"

    JailedPlayers[playerId] = nil
    TriggerClientEvent('jail:releaseFromJail', playerId)

    TriggerClientEvent('chat:addMessage', playerId, {
        color = {0, 255, 0},
        multiline = true,
        args = {"Prison", "Vous avez été libéré de prison."}
    })

    if admin then
        TriggerClientEvent('chat:addMessage', admin, {
            color = {0, 255, 0},
            multiline = true,
            args = {"Succès", string.format("%s a été libéré de prison.", playerName)}
        })
    end

    print(string.format("[JAIL] %s a libéré %s de prison.", adminName, playerName))
end

-- Vérifier le temps de peine toutes les secondes
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        
        for playerId, data in pairs(JailedPlayers) do
            if GetPlayerName(playerId) then
                local elapsedTime = os.time() - data.startTime
                local remainingTime = data.time - elapsedTime

                if remainingTime <= 0 then
                    ReleasePlayer(playerId, nil)
                else
                    -- Envoyer le temps restant au client
                    TriggerClientEvent('jail:updateTime', playerId, remainingTime)
                end
            else
                -- Le joueur s'est déconnecté
                JailedPlayers[playerId] = nil
            end
        end
    end
end)

-- Gérer les déconnexions
AddEventHandler('playerDropped', function(reason)
    local playerId = source
    if JailedPlayers[playerId] then
        print(string.format("[JAIL] Le joueur %s s'est déconnecté alors qu'il était en prison. Temps restant: %d secondes", 
            GetPlayerName(playerId), 
            JailedPlayers[playerId].time - (os.time() - JailedPlayers[playerId].startTime)))
        -- Vous pouvez sauvegarder les données dans une base de données ici
        JailedPlayers[playerId] = nil
    end
end)

-- Vérifier si un joueur tente de s'échapper
RegisterServerEvent('jail:checkEscape')
AddEventHandler('jail:checkEscape', function()
    local playerId = source
    if JailedPlayers[playerId] then
        local remainingTime = JailedPlayers[playerId].time - (os.time() - JailedPlayers[playerId].startTime)
        local reason = JailedPlayers[playerId].reason
        
        -- Remettre le joueur en prison avec la raison
        TriggerClientEvent('jail:sendToJail', playerId, remainingTime, reason)
        
        TriggerClientEvent('chat:addMessage', playerId, {
            color = {255, 0, 0},
            multiline = true,
            args = {"Prison", "Tentative d'évasion détectée ! Vous avez été replacé en prison."}
        })
    end
end)

-- Commande pour vérifier le temps restant
RegisterCommand('jailtime', function(source, args, rawCommand)
    if JailedPlayers[source] then
        local remainingTime = JailedPlayers[source].time - (os.time() - JailedPlayers[source].startTime)
        local minutes = math.floor(remainingTime / 60)
        local seconds = remainingTime % 60
        
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 165, 0},
            multiline = true,
            args = {"Prison", string.format("Temps restant: %d minutes et %d secondes", minutes, seconds)}
        })
    else
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            multiline = true,
            args = {"Prison", "Vous n'êtes pas en prison."}
        })
    end
end, false)

-- Ajouter les suggestions de commande
TriggerEvent('chat:addSuggestion', '/jailtime', 'Affiche votre temps restant en prison')
