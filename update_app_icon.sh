#!/bin/bash
set -e

ICON_PATH="play_store/icon.png"
PUBSPEC="pubspec.yaml"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo ""
echo "========================================"
echo "   App Icon Generator"
echo "========================================"
echo ""

# Step 1: Check icon
if [ ! -f "$ICON_PATH" ]; then
    echo -e "${RED}ERROR:${NC} $ICON_PATH not found."
    exit 1
fi

echo -e "${GREEN}Found:${NC} $ICON_PATH"
echo ""

# Step 2: Ensure dependency exists
if ! grep -q "flutter_launcher_icons:" "$PUBSPEC"; then
    echo "Adding flutter_launcher_icons to dev_dependencies..."

    sed -i.bak '/dev_dependencies:/a\
  flutter_launcher_icons: ^0.14.4' "$PUBSPEC"

    rm -f "${PUBSPEC}.bak"
    echo -e "${GREEN}Added dependency${NC}"
else
    echo -e "${GREEN}Dependency already exists${NC}"
fi

# Step 3: Ensure config exists at ROOT level
if ! grep -q "^flutter_launcher_icons:" "$PUBSPEC"; then
    echo "Adding flutter_launcher_icons config..."

    cat >> "$PUBSPEC" << 'EOF'

flutter_launcher_icons:
  android: true
  ios: true
  image_path: "play_store/icon.png"
  remove_alpha_ios: true
EOF

    echo -e "${GREEN}Config added${NC}"
else
    echo -e "${YELLOW}Config already exists (skipping)${NC}"
fi

echo ""

# Step 4: Install deps
flutter pub get

# Step 5: Generate icons
dart run flutter_launcher_icons

echo ""
echo "========================================"
echo -e "${GREEN} App icon generated successfully!${NC}"
echo "========================================"