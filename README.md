# Script de Jail pour FiveM

## 👀 Preview

**[PREVIEW](https://www.youtube.com/watch?v=6MCqXg_Qd6s)**

## Description
Ce script permet de gérer un système de jail sur votre serveur FiveM avec les fonctionnalités suivantes :
- Jail de joueurs avec durée personnalisable
- Libération automatique à la fin de la peine
- Système anti-évasion
- Affichage du temps restant
- Permissions pour les administrateurs

## Installation

1. Téléchargez ou clonez ce dossier dans votre répertoire `resources` de votre serveur FiveM
2. Ajoutez `ensure sk_jail` dans votre fichier `server.cfg`
3. Redémarrez votre serveur

## Configuration

Modifiez le fichier `config.lua` pour personnaliser :
- La position de la prison
- La position de sortie
- La zone de jail (rayon)
- Le temps minimum et maximum de peine
- Les groupes d'administrateurs

### Exemple de configuration :
```lua
Config.JailLocation = {
    x = 1679.04,
    y = 2513.71,
    z = 45.56,
    heading = 260.0
}
```

## Permissions

### Méthode 1 : ACE Permissions (Recommandé)
Ajoutez dans votre `server.cfg` :
```
add_ace group.admin jail.command allow
add_principal identifier.license:VOTRE_LICENCE_ID group.admin
```

### Méthode 2 : Groups
Modifiez le tableau `Config.AdminGroups` dans `config.lua`

## Commandes

### Commandes Admin :

**Jail un joueur :**
```
/jail
```
Affiche l'aide :
```
/jail [ID] [temps en minutes] [raison]
    Jail un joueur pour une durée déterminée
```

Exemple d'utilisation :
```
/jail 1 30 Troll
/jail 2 15 HRP
```

**Libérer un joueur :**
```
/unjail
```
Affiche l'aide :
```
/unjail [ID]
    Libère un joueur de jail
```

Exemple d'utilisation :
```
/unjail 1
```

### Commandes Joueur :
- `/jailtime` - Afficher le temps restant en jail et la raison

## Fonctionnalités

### 1. Emprisonnement
- Les joueurs sont téléportés à la prison de Bolingbroke
- Leurs armes sont retirées
- Un timer s'affiche à l'écran
- Les joueurs ne peuvent pas utiliser d'armes ou entrer dans des véhicules

### 2. Système Anti-Évasion
- Si un joueur sort de la zone de prison, il est automatiquement replacé
- Une notification est envoyée

### 3. Libération
- Automatique à la fin de la peine
- Manuelle via la commande `/unjail`
- Les joueurs sont téléportés à la sortie de prison

### 4. Affichage
- Timer visible à l'écran pendant toute la durée
- **Raison du jail affichée sous le timer**
- Notifications modernes en haut à droite
- Messages dans le chat

## Intégration avec les Frameworks

### ESX
Décommentez et modifiez dans `server.lua` :
```lua
function GetPlayerGroup(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    return xPlayer.getGroup()
end
```

### QB-Core
Décommentez et modifiez dans `server.lua` :
```lua
function GetPlayerGroup(source)
    local Player = QBCore.Functions.GetPlayer(source)
    return Player.PlayerData.group
end
```

## Personnalisation

### Changer la position du jail
1. Rendez-vous à l'endroit souhaité en jeu
2. Utilisez une commande pour obtenir vos coordonnées (ex: `/getcoords`)
3. Modifiez `Config.JailLocation` dans `config.lua`

### Modifier le rayon de la zone
Changez `Config.JailZone.radius` dans `config.lua` (en unités GTA)

### Ajuster les temps de jail
Modifiez `Config.MinJailTime` et `Config.MaxJailTime` dans `config.lua` (en secondes)

## Support et Bugs

Si vous rencontrez des problèmes :
1. Vérifiez que le script est bien démarré (`ensure sk_jail` dans server.cfg)
2. Consultez les logs du serveur (F8 dans le jeu)
3. Vérifiez que vous avez les permissions nécessaires
4. Assurez-vous que les coordonnées sont correctes

## Crédits

Script créé par Seîko
Version 1.0.0

## Licence

Ce script est fourni tel quel. Vous êtes libre de le modifier selon vos besoins.
