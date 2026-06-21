local isJailed = false
local jailTime = 0
local jailReason = ""
local savedHunger = nil
local savedThirst = nil

-- Envoyer le joueur en prison
RegisterNetEvent('jail:sendToJail')
AddEventHandler('jail:sendToJail', function(time, reason)
    isJailed = true
    jailTime = time
    jailReason = reason or "Aucune raison"
    
    local playerPed = PlayerPedId()
    
    -- Sauvegarder les niveaux de faim et soif actuels (si activé dans config)
    if Config.FreezeMetabolism then
        TriggerEvent('jail:saveMetabolism')
    end
    
    -- Téléporter le joueur en prison
    SetEntityCoords(playerPed, Config.JailLocation.x, Config.JailLocation.y, Config.JailLocation.z, false, false, false, true)
    SetEntityHeading(playerPed, Config.JailLocation.heading)
    
    -- Retirer les armes
    RemoveAllPedWeapons(playerPed, true)
    
    -- Afficher un message de bienvenue
    if Config.WelcomeMessage then
        ShowNotification("Prison", "Vous êtes en prison\nUtilisez /jailtime pour voir votre temps restant", "error")
    end
    
    -- Démarrer les threads de prison
    StartJailThreads()
end)

-- Libérer le joueur
RegisterNetEvent('jail:releaseFromJail')
AddEventHandler('jail:releaseFromJail', function()
    isJailed = false
    jailTime = 0
    jailReason = ""
    
    local playerPed = PlayerPedId()
    
    -- Téléporter le joueur à la sortie
    SetEntityCoords(playerPed, Config.ReleaseLocation.x, Config.ReleaseLocation.y, Config.ReleaseLocation.z, false, false, false, true)
    SetEntityHeading(playerPed, Config.ReleaseLocation.heading)
    
    -- Restaurer les niveaux de faim et soif (si activé dans config)
    if Config.FreezeMetabolism then
        TriggerEvent('jail:restoreMetabolism')
    end
    
    ShowNotification("Prison", "Vous avez été libéré de prison", "success")
end)

-- Mettre à jour le temps
RegisterNetEvent('jail:updateTime')
AddEventHandler('jail:updateTime', function(time)
    jailTime = time
end)

-- Démarrer les threads de la prison
function StartJailThreads()
    -- Thread pour afficher le temps restant
    Citizen.CreateThread(function()
        while isJailed do
            Citizen.Wait(0)
            
            local minutes = math.floor(jailTime / 60)
            local seconds = jailTime % 60
            
            -- Afficher le texte à l'écran
            SetTextFont(4)
            SetTextProportional(1)
            SetTextScale(0.5, 0.5)
            SetTextColour(255, 255, 255, 255)
            SetTextDropshadow(0, 0, 0, 0, 255)
            SetTextEdge(1, 0, 0, 0, 255)
            SetTextDropShadow()
            SetTextOutline()
            SetTextEntry("STRING")
            AddTextComponentString(string.format("~r~Prison\n~w~Temps restant: ~b~%02d:%02d\n~o~Raison: ~w~%s", minutes, seconds, jailReason))
            DrawText(0.5, 0.9)
        end
    end)
    
    -- Thread pour geler la faim et la soif (si activé dans config)
    if Config.FreezeMetabolism then
        Citizen.CreateThread(function()
            while isJailed do
                Citizen.Wait(1000) -- Vérifier chaque seconde
                
                -- Maintenir les niveaux de faim et soif constants
                TriggerEvent('jail:freezeMetabolism')
            end
        end)
    end
    
    -- Thread pour vérifier si le joueur tente de s'échapper
    Citizen.CreateThread(function()
        while isJailed do
            Citizen.Wait(5000) -- Vérifier toutes les 5 secondes
            
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local distance = #(playerCoords - Config.JailZone.center)
            
            if distance > Config.JailZone.radius then
                -- Le joueur est sorti de la zone de prison
                TriggerServerEvent('jail:checkEscape')
            end
        end
    end)
    
    -- Thread pour désactiver certaines actions
    Citizen.CreateThread(function()
        while isJailed do
            Citizen.Wait(0)
            
            -- Désactiver les armes
            DisablePlayerFiring(PlayerId(), true)
            DisableControlAction(0, 37, true) -- Désactiver la sélection d'armes
            
            -- Désactiver l'entrée dans les véhicules
            DisableControlAction(0, 23, true) -- Enter vehicle (F)
            DisableControlAction(0, 75, true) -- Exit vehicle (F)
            
            -- Empêcher le joueur de courir (optionnel)
            -- DisableControlAction(0, 21, true) -- Sprint
        end
    end)
end

-- Fonction pour afficher une notification moderne
function ShowNotification(title, message, type, duration)
    -- Type: "success" (vert), "error" (rouge), "info" (bleu), "warning" (orange)
    local notifType = type or "info"
    local notifDuration = duration or 5000
    
    -- Vérifier la configuration
    local notifSystem = Config.NotificationSystem or "auto"
    
    -- Si custom ou auto, utiliser notre système HTML
    if notifSystem == "custom" or notifSystem == "auto" then
        SendNUIMessage({
            action = 'showNotification',
            title = title,
            message = message,
            type = notifType,
            duration = notifDuration
        })
        return
    end
    
    -- Sinon utiliser les systèmes externes
    -- Pour ox_lib
    if notifSystem == "ox_lib" and GetResourceState('ox_lib') == 'started' then
        exports['ox_lib']:notify({
            title = title,
            description = message,
            type = notifType,
            position = 'top-right'
        })
    -- Pour okokNotify
    elseif notifSystem == "okokNotify" and GetResourceState('okokNotify') == 'started' then
        exports['okokNotify']:Alert(title, message, notifDuration, notifType)
    -- Pour mythic_notify
    elseif notifSystem == "mythic_notify" and GetResourceState('mythic_notify') == 'started' then
        exports['mythic_notify']:DoHudText(notifType, message)
    -- Pour t-notify
    elseif notifSystem == "t-notify" and GetResourceState('t-notify') == 'started' then
        exports['t-notify']:Custom({
            style = notifType,
            message = message,
            duration = notifDuration
        })
    -- Pour ESX
    elseif notifSystem == "esx" and ESX ~= nil and ESX.ShowNotification then
        ESX.ShowNotification(message, notifType)
    -- Pour QB-Core
    elseif notifSystem == "qb" and QBCore ~= nil and QBCore.Functions and QBCore.Functions.Notify then
        QBCore.Functions.Notify(message, notifType)
    -- Fallback: utiliser notre système HTML
    else
        SendNUIMessage({
            action = 'showNotification',
            title = title,
            message = message,
            type = notifType,
            duration = notifDuration
        })
    end
end

-- ========================================
-- GESTION DE LA FAIM ET SOIF EN PRISON
-- ========================================

-- Sauvegarder les niveaux de faim et soif
RegisterNetEvent('jail:saveMetabolism')
AddEventHandler('jail:saveMetabolism', function()
    -- Pour ESX
    if ESX ~= nil then
        ESX.TriggerServerCallback('esx_status:getStatus', function(status)
            for k, v in pairs(status) do
                if v.name == 'hunger' then
                    savedHunger = v.val
                elseif v.name == 'thirst' then
                    savedThirst = v.val
                end
            end
        end)
    -- Pour QB-Core
    elseif QBCore ~= nil then
        local Player = QBCore.Functions.GetPlayerData()
        if Player.metadata then
            savedHunger = Player.metadata.hunger or 100
            savedThirst = Player.metadata.thirst or 100
        end
    -- Pour autres frameworks (ex: vRP, Standalone)
    else
        -- Utiliser un système par défaut
        savedHunger = 100
        savedThirst = 100
    end
end)

-- Geler les niveaux de faim et soif
RegisterNetEvent('jail:freezeMetabolism')
AddEventHandler('jail:freezeMetabolism', function()
    if not isJailed then return end
    
    -- Pour ESX
    if ESX ~= nil then
        if savedHunger then
            TriggerEvent('esx_status:set', 'hunger', savedHunger)
        end
        if savedThirst then
            TriggerEvent('esx_status:set', 'thirst', savedThirst)
        end
    -- Pour QB-Core
    elseif QBCore ~= nil then
        if savedHunger then
            TriggerServerEvent('QBCore:Server:SetMetaData', 'hunger', savedHunger)
        end
        if savedThirst then
            TriggerServerEvent('QBCore:Server:SetMetaData', 'thirst', savedThirst)
        end
    end
end)

-- Restaurer les niveaux de faim et soif
RegisterNetEvent('jail:restoreMetabolism')
AddEventHandler('jail:restoreMetabolism', function()
    -- Pour ESX
    if ESX ~= nil then
        if savedHunger then
            TriggerEvent('esx_status:set', 'hunger', savedHunger)
        end
        if savedThirst then
            TriggerEvent('esx_status:set', 'thirst', savedThirst)
        end
    -- Pour QB-Core
    elseif QBCore ~= nil then
        if savedHunger then
            TriggerServerEvent('QBCore:Server:SetMetaData', 'hunger', savedHunger)
        end
        if savedThirst then
            TriggerServerEvent('QBCore:Server:SetMetaData', 'thirst', savedThirst)
        end
    end
    
    -- Réinitialiser les valeurs sauvegardées
    savedHunger = nil
    savedThirst = nil
end)

-- Commande de test (à retirer en production)
RegisterCommand('testjail', function()
    TriggerServerEvent('jail:test')
end, false)

-- À ajouter tout en bas de client.lua

Citizen.CreateThread(function()
    -- Suggestion pour /jail avec les indicateurs [ID] [temps] [raison]
    TriggerEvent('chat:addSuggestion', '/jail', 'Emprisonne un joueur pour une durée déterminée', {
        { name = "ID", help = "ID du joueur" },
        { name = "temps", help = "Durée en minutes" },
        { name = "raison", help = "Raison de l'emprisonnement" }
    })

    -- Suggestion pour /unjail avec l'indicateur [ID]
    TriggerEvent('chat:addSuggestion', '/unjail', 'Libère un joueur de prison', {
        { name = "ID", help = "ID du joueur à libérer" }
    })

    -- Suggestion pour /jailtime (pas d'arguments)
    TriggerEvent('chat:addSuggestion', '/jailtime', 'Affiche votre temps restant en prison', {})
end)