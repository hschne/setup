# Post Installation

Here are some things to set up once you have started some programs.

## Better Lockscreen

```
betterlockscreen -u ~/Pictures/Backgrounds
```

## Setup Spicetify

You must run Spotify once before running Spicetify!

```bash
spicetify
spicetify backup apply enable-devtools
git clone --depth=1 https://github.com/spicetify/spicetify-themes.git
cd spicetify-themes && cp -r * ~/.config/spicetify/Themes
spicetify config current_theme Sleek
spicetify config color_scheme elementary
spicetiry apply
```
