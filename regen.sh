#!/bin/sh
# Rebuild portrait.jpg from the current GitHub avatar, then the two cards.
# Needs ImageMagick 7 (magick) and gh; update_profile.py itself is stdlib only.
#
# The avatar is rounded off and flattened onto the card's backdrop colour, so
# the circle sits on the panel with no visible box. Keep the colour below in
# step with "backdrop" in card.json.
set -e
cd "$(dirname "$0")"
backdrop='#14121c'
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
# Token first, in its own assignment so `set -e` sees gh fail: an expired login
# should not leave a fresh portrait sitting next to yesterday's cards, and an
# empty token renders the stats as em-dashes.
GITHUB_TOKEN=$(gh auth token)
export GITHUB_TOKEN
login=$(python3 -c 'import json;print(json.load(open("card.json"))["login"])')
curl -fsSL --max-time 30 "https://github.com/$login.png" -o "$tmp/avatar.png"
size=$(magick "$tmp/avatar.png" -format '%w' info:)
magick -size "${size}x${size}" xc:black -fill white \
  -draw "circle $((size / 2)),$((size / 2)) $((size / 2)),3" "$tmp/mask.png"
magick "$tmp/avatar.png" -alpha off "$tmp/mask.png" -alpha off -compose CopyOpacity -composite \
  -background "$backdrop" -alpha remove -alpha off -strip -quality 88 portrait.jpg
python3 update_profile.py
