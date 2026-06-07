#!/bin/bash

set -e

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

TARGET_DIR="$HOME/.local/share/plasma/plasmoids/org.kde.plasma.lock_logout.workflow"

echo "Deploying plasmoid..."

rm -rf "$TARGET_DIR"

cp -a \
    "$PROJECT_DIR/plasmoid5/org.kde.plasma.lock_logout.workflow" \
    "$HOME/.local/share/plasma/plasmoids/"

echo "Rebuilding KDE cache..."

kbuildsycoca5

echo "Restarting Plasma..."

kquitapp5 plasmashell || true

sleep 2

plasmashell >/dev/null 2>&1 &

echo "Done."
