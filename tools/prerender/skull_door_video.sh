#!/usr/bin/env bash
# Codifica los cuadros de render_skull_door.gd a video Ogg Theora (assets/video/skull_door.ogv) con viñeta, grano de película y
# un leve viraje de color. Uso: tools/prerender/skull_door_video.sh <carpeta_cuadros> [fps]
set -e
FRAMES="${1:?carpeta de cuadros}"
FPS="${2:-15}"
cd "$(dirname "$0")/../.."
ffmpeg -y -loglevel error -framerate "$FPS" -i "$FRAMES/%04d.png" \
  -vf "vignette=PI/4.5,noise=alls=10:allf=t,eq=contrast=1.05:saturation=0.9" \
  -c:v libtheora -q:v 6 -an assets/video/skull_door.ogv
ls -la assets/video/skull_door.ogv
