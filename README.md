# Papyrus Islands

Un thème [Omarchy](https://omarchy.org/) : palette Catppuccin Mocha (accent bleu
`#89b4fa`) et trois fonds d'écran.

![Capture d'écran](papyrus_theme.png)

![Aperçu](preview.jpg)

## Fonds d'écran

Le fond d'origine est l'aperçu ci-dessus ; les deux variantes se parcourent avec
`omarchy theme bg next`.

![Fond d'écran 2](backgrounds/wallpaper-2.jpg)

![Fond d'écran 3](backgrounds/wallpaper-3.jpg)

## Installation

```sh
omarchy theme install https://github.com/papyrus448/omarchy-papyrus-islands
```

Omarchy clone le dépôt dans `~/.config/omarchy/themes/papyrus-islands`, n'installe
que les fichiers de thème (`colors.toml`, `backgrounds/`, `preview.jpg`) et
applique le thème immédiatement.

- Fond suivant : `omarchy theme bg next`
- Mise à jour : `omarchy theme update`
- Retrait : `omarchy theme remove papyrus-islands`

Le thème ne contient aucun script. L'arrondi des fenêtres, les couleurs de bordure
et la barre sont gérés par Omarchy et par ta propre configuration, pas par ce
dépôt.

## Fichiers de référence (non installés)

Les dossiers `fastfetch/` et `bar/` contiennent la configuration de console et la
disposition d'îlots utilisées sur la machine de l'auteur. `omarchy theme install`
ne les applique pas : ce sont des exemples à copier soi-même si on le souhaite.
La barre `bar/layout.json` nécessite le plugin
[Islands](https://github.com/DanielLob-o/Islands), qui s'installe séparément via
`omarchy plugin add https://github.com/DanielLob-o/Islands.git --enable`.

## Crédits

- [Omarchy](https://omarchy.org/) et son shell, par David Heinemeier Hansson
- [Catppuccin](https://catppuccin.com/) pour la palette Mocha
- [Islands](https://github.com/DanielLob-o/Islands) par Daniel Lobo (MIT)
- Fond d'écran : [Wallhaven 3qg92y](https://wallhaven.cc/w/3qg92y)
- Logo fastfetch : fourni par l'auteur du thème

## Licence

Les fichiers de configuration de ce dépôt sont sous licence MIT (voir
[`LICENSE`](LICENSE)). Les images (fonds d'écran, aperçu, capture, logo) ne sont
pas couvertes par cette licence.
