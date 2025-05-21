#/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 <theme-name>"
  exit 1
fi

THEME_NAME="$1"

EXTRACT_DIR="/tmp/hyprcursor-extract"
CREATE_DIR="/tmp/hyprcursor-create"

sudo rm -rf "$EXTRACT_DIR"
sudo rm -rf "$CREATE_DIR"

mkdir -p "$EXTRACT_DIR"
mkdir -p "$CREATE_DIR"

sudo hyprcursor-util --extract "/usr/share/icons/${THEME_NAME}" --output "$EXTRACT_DIR"
sudo sed -i "s/^name = Extracted Theme$/name = ${THEME_NAME}/" "$EXTRACT_DIR/extracted_${THEME_NAME}/manifest.hl"
sudo hyprcursor-util --create "$EXTRACT_DIR/extracted_${THEME_NAME}/" --output "$CREATE_DIR"

mkdir ~/.local/share/icons/${THEME_NAME}
cp -r "$CREATE_DIR/theme_${THEME_NAME}/"* ~/.local/share/icons/${THEME_NAME}/
