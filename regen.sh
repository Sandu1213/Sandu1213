#!/bin/sh
# Rebuild launch.jpg from its source photo, then the two cards.
# Needs ImageMagick 7 (magick) and gh; update_profile.py itself is stdlib only.
#
# The picture is NASA/Joel Kowsky's photo of the SpaceX Crew-6 launch, public
# domain (credited in README.md, as NASA's usage guidelines ask):
# https://commons.wikimedia.org/wiki/File:NASA%E2%80%99s_SpaceX_Crew-6_Launch_(NHQ202303020008).jpg
# Cropped to the card's panel proportions and kept at about twice the size it
# is drawn at, so it stays sharp on a retina screen without bloating the SVG
# it is embedded in.
set -e
cd "$(dirname "$0")"
src="https://upload.wikimedia.org/wikipedia/commons/thumb/1/17/NASA%E2%80%99s_SpaceX_Crew-6_Launch_%28NHQ202303020008%29.jpg/1280px-NASA%E2%80%99s_SpaceX_Crew-6_Launch_%28NHQ202303020008%29.jpg"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
# Token first, in its own assignment so `set -e` sees gh fail: an expired login
# should not leave a fresh picture sitting next to yesterday's cards, and an
# empty token renders the stats as em-dashes.
GITHUB_TOKEN=$(gh auth token)
export GITHUB_TOKEN
curl -fsSL --max-time 30 -A "profile-card (github.com/Sandu1213)" "$src" -o "$tmp/launch-src.jpg"
magick "$tmp/launch-src.jpg" -gravity north -crop 1280x1463+0+60 +repage \
  -resize 800x -strip -quality 82 launch.jpg
python3 update_profile.py
