#!/usr/bin/env bash
# Erzeugt alle Android-Launcher-Icons und Splash-Screens aus assets-icon/*.svg
set -e
cd "$(dirname "$0")/.."
# Ziel: assets-icon/android/ spiegelt die Struktur von android/app/src/main/res.
# Diese PNGs werden committed; der GitHub-Workflow kopiert sie nach "npx cap add"
# in das frisch erzeugte Android-Projekt (android/ ist in .gitignore).
RES=assets-icon/android
mkdir -p $RES/mipmap-{mdpi,hdpi,xhdpi,xxhdpi,xxxhdpi}
c() { convert "$@"; }   # LD_LIBRARY_PATH muss beim Aufruf leer sein

for pair in "mdpi 48 108" "hdpi 72 162" "xhdpi 96 216" "xxhdpi 144 324" "xxxhdpi 192 432"; do
  set -- $pair; d=$1; ic=$2; fg=$3
  half=$((ic/2))

  # Launcher-Icon (quadratisch)
  c -background none assets-icon/icon-square.svg -resize ${ic}x${ic}! -strip $RES/mipmap-$d/ic_launcher.png

  # Rundes Icon mit Kreis-Maske
  c -background none assets-icon/icon-square.svg -resize ${ic}x${ic}! -strip -depth 8 /tmp/sq-$d.png
  c -size ${ic}x${ic} xc:black -fill white -draw "circle $half,$half $half,0" /tmp/mask-$d.png
  c /tmp/sq-$d.png /tmp/mask-$d.png -alpha off -compose CopyOpacity -composite -strip $RES/mipmap-$d/ic_launcher_round.png

  # Adaptiver Foreground
  c -background none assets-icon/icon-foreground.svg -resize ${fg}x${fg}! -strip $RES/mipmap-$d/ic_launcher_foreground.png
  echo "$d ok"
done

# Splash-Screens: Himmelblauer Hintergrund mit zentriertem Icon
splash() { # W H out
  mkdir -p "$(dirname "$3")"
  c -size $1x$2 xc:#aed9f1 \
    \( assets-icon/icon-square.svg -resize "$(($2*3/4))x$(($2*3/4))" -strip \) \
    -gravity center -composite -strip "$3"
}
splash 480 320  $RES/drawable/splash.png
splash 480 320  $RES/drawable-land-mdpi/splash.png
splash 800 480  $RES/drawable-land-hdpi/splash.png
splash 960 720  $RES/drawable-land-xhdpi/splash.png
splash 1600 960 $RES/drawable-land-xxhdpi/splash.png
splash 1920 1280 $RES/drawable-land-xxxhdpi/splash.png
splash 320 480  $RES/drawable-port-mdpi/splash.png
splash 480 800  $RES/drawable-port-hdpi/splash.png
splash 720 960  $RES/drawable-port-xhdpi/splash.png
splash 960 1600 $RES/drawable-port-xxhdpi/splash.png
splash 1280 1920 $RES/drawable-port-xxxhdpi/splash.png
# Hintergrundfarbe des adaptiven Icons
mkdir -p $RES/values
cat > $RES/values/ic_launcher_background.xml <<'XML'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="ic_launcher_background">#8ECAE6</color>
</resources>
XML

# Falls ein lokales Android-Projekt existiert, direkt dorthin spiegeln
if [ -d android ]; then
  cp -r $RES/. android/app/src/main/res/
  echo "in android/app/src/main/res kopiert"
fi
