Config = {}

-- Position de la prison (Prison de Bolingbroke par défaut)
Config.JailLocation = {
    x = 1679.04,
    y = 2513.71,
    z = 45.56,
    heading = 260.0
}

-- Position de sortie de prison
Config.ReleaseLocation = {
    x = 1850.5,
    y = 2585.8,
    z = 45.67,
    heading = 270.0
}

-- Zone de la prison (pour vérifier si le joueur essaie de s'échapper)
Config.JailZone = {
    center = vector3(1679.04, 2513.71, 45.56),
    radius = 100.0
}

-- Temps minimum de peine en secondes (5 minutes par défaut)
Config.MinJailTime = 300

-- Temps maximum de peine en secondes (60 minutes par défaut)
Config.MaxJailTime = 3600

-- Activer/désactiver le message de bienvenue en prison
Config.WelcomeMessage = true

-- Geler la faim et la soif en prison
Config.FreezeMetabolism = false

-- Système de notifications à utiliser
-- Options: "custom" (notifications modernes intégrées), "ox_lib", "okokNotify", "mythic_notify", "t-notify", "esx", "qb"
-- Recommandé: "custom" pour des notifications modernes automatiques
Config.NotificationSystem = "custom"

-- Permissions pour envoyer en prison (identifiants Steam, license, etc.)
Config.AdminGroups = {
    "admin",
    "moderator",
    "superadmin"
}
