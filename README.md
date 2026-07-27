# Fedora macOS Setup

Configuration reproductible de Fedora Workstation avec une apparence inspirée
de macOS.

## Contenu

- thème sombre, icônes et curseur WhiteSur ;
- dock inférieur masqué automatiquement ;
- transparence et flou ;
- boutons de fenêtre à gauche ;
- police Inter ;
- monitoring CPU, RAM, réseau et températures ;
- aperçu des fenêtres au survol des icônes du dock ;
- affichage Finder en colonnes dans GNOME Fichiers (`Ctrl+3`) ;
- mise en veille immédiate à la fermeture du capot ;
- fond d'écran et écran de verrouillage assortis.

Le script ne modifie pas GDM, le gestionnaire de connexion, afin de ne pas
risquer de bloquer l'ouverture de session après une mise à jour de GNOME.

## Installation

Sur une installation Fedora Workstation fraîche :

```bash
git clone https://github.com/YounesOumalik/fedora-macos-setup.git
cd fedora-macos-setup
chmod +x install.sh
./install.sh
```

Saisissez le mot de passe administrateur lorsque Fedora le demande. À la fin,
déconnectez-vous puis reconnectez-vous.

## Compatibilité

La configuration a été créée pour Fedora 44 et GNOME 50. Le script récupère la
version GNOME 50 validée de l'extension Dock Window Preview.

WhiteSur et les extensions GNOME sont des projets tiers. Après une mise à niveau
majeure de Fedora ou GNOME, vérifiez leur compatibilité avant de relancer le
script.

La vue en colonnes provient du dépôt COPR tiers
[`yannmasoch/nautilus-my-computer`](https://github.com/yannmasoch/nautilus-my-computer).
Elle est encore marquée bêta par son auteur.

## Sources principales

- [WhiteSur GTK](https://github.com/vinceliuice/WhiteSur-gtk-theme)
- [WhiteSur Icons](https://github.com/vinceliuice/WhiteSur-icon-theme)
- [WhiteSur Cursors](https://github.com/vinceliuice/WhiteSur-cursors)
- [Dock Window Preview](https://extensions.gnome.org/extension/9492/dock-window-preview/)
- [My Computer for Nautilus](https://github.com/yannmasoch/nautilus-my-computer)
