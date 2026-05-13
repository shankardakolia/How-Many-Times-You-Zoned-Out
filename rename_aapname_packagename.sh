#!/bin/bash

# Script to automate Flutter app name and package name changes
# Usage: ./rename_appname_packagename.sh <app_name> <package_name>
# Example: ./rename_appname_packagename.sh "Simple Poll Maker Lite" "com.shankardakolia.simplepollmakerlite"

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to show usage
show_usage() {
    echo -e "${RED}Error: Missing required parameters${NC}"
    echo ""
    echo "Usage: $0 <app_name> <package_name>"
    echo ""
    echo "Examples:"
    echo "  $0 \"Prefix Suffix Viewer\" \"com.shankardakolia.prefixwordbuilder\""
    echo "  $0 \"Simple Poll Maker Lite\" \"com.shankardakolia.simplepollmakerlite\""
    echo ""
    echo "Parameters:"
    echo "  app_name      - The display name of the app (in quotes if contains spaces)"
    echo "  package_name  - The Android package name (e.g., com.example.appname)"
    echo ""
    exit 1
}

# Check if required parameters are provided
if [ $# -lt 2 ]; then
    show_usage
fi

# Get mandatory parameters
APP_NAME="$1"
PACKAGE_NAME="$2"

# Validate package name format
if ! [[ "$PACKAGE_NAME" =~ ^[a-z][a-z0-9]*(\.[a-z][a-z0-9]*)+$ ]]; then
    echo -e "${RED}Error: Invalid package name format${NC}"
    echo "Package name should be like: com.example.appname (lowercase letters, dots, numbers)"
    echo "Got: $PACKAGE_NAME"
    exit 1
fi

# Convert package name to path format (dots to slashes)
PACKAGE_PATH="${PACKAGE_NAME//./\/}"

# Extract the last two parts for the nested directory structure
# This works for any number of package parts (e.g., com.shankardakolia.simplepollmakerlite)
# Last part is the project name, second last is the organization name
IFS='.' read -ra PACKAGE_PARTS <<< "$PACKAGE_NAME"
NUM_PARTS=${#PACKAGE_PARTS[@]}

if [ $NUM_PARTS -lt 3 ]; then
    echo -e "${RED}Error: Package name should have at least 3 parts (e.g., com.example.app)${NC}"
    exit 1
fi

# Get the last part as project name
PROJECT_NAME="${PACKAGE_PARTS[$NUM_PARTS-1]}"
# Get the second last part as organization name
ORG_NAME="${PACKAGE_PARTS[$NUM_PARTS-2]}"

# For the nested directory path, we need all parts after the first one
# Example: com.shankardakolia.simplepollmakerlite -> shankardakolia/simplepollmakerlite
NESTED_PATH=""
for ((i=1; i<$NUM_PARTS; i++)); do
    if [ $i -eq 1 ]; then
        NESTED_PATH="${PACKAGE_PARTS[$i]}"
    else
        NESTED_PATH="$NESTED_PATH/${PACKAGE_PARTS[$i]}"
    fi
done

echo -e "${GREEN}Starting Flutter app rename process...${NC}"
echo -e "App Name: ${YELLOW}$APP_NAME${NC}"
echo -e "Package Name: ${YELLOW}$PACKAGE_NAME${NC}"
echo -e "Directory Structure: ${YELLOW}$NESTED_PATH${NC}"
echo ""

# Check if we're in a Flutter project
if [ ! -f "pubspec.yaml" ]; then
    echo -e "${RED}Error: Not in a Flutter project directory${NC}"
    echo "Please run this script from the root of your Flutter project (where pubspec.yaml is located)"
    exit 1
fi

# Confirm with user
echo -e "${YELLOW}This will modify your Flutter project configuration. Continue? (y/n)${NC}"
read -r confirmation
if [[ ! "$confirmation" =~ ^[Yy]$ ]]; then
    echo -e "${RED}Operation cancelled${NC}"
    exit 0
fi

echo ""

# Step 1: Update app name in AndroidManifest.xml
echo -e "${GREEN}Step 1: Updating Android app name...${NC}"
MANIFEST_FILE="android/app/src/main/AndroidManifest.xml"
if [ -f "$MANIFEST_FILE" ]; then
    # Backup original file
    cp "$MANIFEST_FILE" "${MANIFEST_FILE}.backup"
    
    # Update android:label attribute
    sed -i '' "s/android:label=\".*\"/android:label=\"$APP_NAME\"/" "$MANIFEST_FILE"
    echo -e "${GREEN}✓ Updated app name in AndroidManifest.xml${NC}"
else
    echo -e "${RED}Error: AndroidManifest.xml not found at $MANIFEST_FILE${NC}"
    exit 1
fi

# Step 2: Update package name in android/app/build.gradle.kts
echo -e "${GREEN}Step 2: Updating build.gradle.kts...${NC}"
BUILD_GRADLE="android/app/build.gradle.kts"
if [ -f "$BUILD_GRADLE" ]; then
    cp "$BUILD_GRADLE" "${BUILD_GRADLE}.backup"
    
    # Update namespace
    sed -i '' "s/namespace = \".*\"/namespace = \"$PACKAGE_NAME\"/" "$BUILD_GRADLE"
    
    # Update applicationId
    sed -i '' "s/applicationId = \".*\"/applicationId = \"$PACKAGE_NAME\"/" "$BUILD_GRADLE"
    
    echo -e "${GREEN}✓ Updated package name in build.gradle.kts${NC}"
else
    echo -e "${RED}Error: build.gradle.kts not found at $BUILD_GRADLE${NC}"
    exit 1
fi

# Step 3: Restructure Kotlin directories
echo -e "${GREEN}Step 3: Restructuring Kotlin directories...${NC}"

KOTLIN_BASE="android/app/src/main/kotlin"
if [ -d "$KOTLIN_BASE" ]; then
    
    # Navigate to kotlin/com directory
    COM_DIR="$KOTLIN_BASE/com"
    
    if [ -d "$COM_DIR" ]; then
        # Find the example directory (could be named differently based on initial project name)
        EXAMPLE_DIR=$(find "$COM_DIR" -maxdepth 1 -type d -name "*example*" | head -n 1)
        
        if [ -d "$EXAMPLE_DIR" ]; then
            echo -e "${YELLOW}Found example directory: $EXAMPLE_DIR${NC}"
            
            # Find MainActivity.kt inside subdirectories of example directory
            MAIN_ACTIVITY=$(find "$EXAMPLE_DIR" -name "MainActivity.kt" -type f | head -n 1)
            
            if [ -f "$MAIN_ACTIVITY" ]; then
                # Copy MainActivity.kt to com directory
                cp "$MAIN_ACTIVITY" "$COM_DIR/"
                echo -e "${GREEN}✓ Copied MainActivity.kt to $COM_DIR/${NC}"
                
                # Update package name in the copied MainActivity.kt (temporarily set to com)
                sed -i '' "s/^package .*/package com/" "$COM_DIR/MainActivity.kt"
                
                # Delete the example directory
                rm -rf "$EXAMPLE_DIR"
                echo -e "${GREEN}✓ Deleted example directory${NC}"
            else
                echo -e "${RED}Error: MainActivity.kt not found in example directory${NC}"
                exit 1
            fi
        else
            echo -e "${YELLOW}No example directory found, looking for alternative structure...${NC}"
            
            # Alternative: Maybe the structure is already using the default package
            MAIN_ACTIVITY=$(find "$COM_DIR" -name "MainActivity.kt" -type f | head -n 1)
            if [ -f "$MAIN_ACTIVITY" ]; then
                echo -e "${GREEN}Found MainActivity.kt at: $MAIN_ACTIVITY${NC}"
                # Keep it as is, we'll move it later
                cp "$MAIN_ACTIVITY" "$COM_DIR/temp_MainActivity.kt"
                mv "$COM_DIR/temp_MainActivity.kt" "$COM_DIR/MainActivity.kt"
            else
                echo -e "${RED}Error: No MainActivity.kt found${NC}"
                exit 1
            fi
        fi
        
        # Now create the nested directory structure (handles any depth)
        # Example: com/shankardakolia/simplepollmakerlite
        NESTED_DIR="$COM_DIR/$NESTED_PATH"
        mkdir -p "$NESTED_DIR"
        echo -e "${GREEN}✓ Created nested directory: $NESTED_DIR${NC}"
        
        # Move MainActivity.kt from com directory to the nested directory
        if [ -f "$COM_DIR/MainActivity.kt" ]; then
            mv "$COM_DIR/MainActivity.kt" "$NESTED_DIR/"
            echo -e "${GREEN}✓ Moved MainActivity.kt to $NESTED_DIR/${NC}"
            
            # Update package name in MainActivity.kt to the correct package
            sed -i '' "s/^package .*/package $PACKAGE_NAME/" "$NESTED_DIR/MainActivity.kt"
            echo -e "${GREEN}✓ Updated package declaration in MainActivity.kt to: $PACKAGE_NAME${NC}"
        else
            echo -e "${RED}Error: MainActivity.kt not found in com directory${NC}"
            exit 1
        fi
        
        # Clean up any empty directories in com (except the new nested structure)
        find "$COM_DIR" -type d -empty -delete 2>/dev/null || true
        
    else
        echo -e "${RED}Error: com directory not found at $COM_DIR${NC}"
        exit 1
    fi
else
    echo -e "${RED}Error: Kotlin directory not found at $KOTLIN_BASE${NC}"
    exit 1
fi

# Step 4: Update iOS app name
echo -e "${GREEN}Step 4: Updating iOS app name...${NC}"
if [ -d "ios" ]; then
    # Update Info.plist
    INFO_PLIST="ios/Runner/Info.plist"
    if [ -f "$INFO_PLIST" ]; then
        cp "$INFO_PLIST" "${INFO_PLIST}.backup"
        
        # Update CFBundleDisplayName
        /usr/libexec/PlistBuddy -c "Set :CFBundleDisplayName '$APP_NAME'" "$INFO_PLIST" 2>/dev/null || \
        /usr/libexec/PlistBuddy -c "Add :CFBundleDisplayName string '$APP_NAME'" "$INFO_PLIST"
        
        # Update CFBundleName
        /usr/libexec/PlistBuddy -c "Set :CFBundleName '$APP_NAME'" "$INFO_PLIST" 2>/dev/null || \
        /usr/libexec/PlistBuddy -c "Add :CFBundleName string '$APP_NAME'" "$INFO_PLIST"
        
        echo -e "${GREEN}✓ Updated iOS app name${NC}"
    else
        echo -e "${YELLOW}Warning: iOS Info.plist not found${NC}"
    fi
    
    # Update Xcode project bundle identifier
    if [ -f "ios/Runner.xcodeproj/project.pbxproj" ]; then
        sed -i '' "s/PRODUCT_BUNDLE_IDENTIFIER = .*/PRODUCT_BUNDLE_IDENTIFIER = $PACKAGE_NAME;/" "ios/Runner.xcodeproj/project.pbxproj"
        echo -e "${GREEN}✓ Updated iOS bundle identifier${NC}"
    fi
else
    echo -e "${YELLOW}iOS directory not found, skipping iOS changes${NC}"
fi

# Step 5: Update any other Kotlin files if they exist
echo -e "${GREEN}Step 5: Updating other Kotlin files...${NC}"
find "android" -name "*.kt" -type f | while read -r file; do
    if grep -q "^package com\." "$file" 2>/dev/null; then
        sed -i '' "s/^package com\.[a-z0-9.]*/package $PACKAGE_NAME/" "$file"
        echo -e "${GREEN}✓ Updated package in $(basename "$file")${NC}"
    fi
done

# Step 6: Clean and get dependencies
echo -e "${GREEN}Step 6: Cleaning and getting dependencies...${NC}"
flutter clean
flutter pub get

echo ""
echo -e "${GREEN}✅ App rename completed successfully!${NC}"
echo ""
echo -e "${YELLOW}Summary:${NC}"
echo -e "  App Name: ${GREEN}$APP_NAME${NC}"
echo -e "  Package Name: ${GREEN}$PACKAGE_NAME${NC}"
echo -e "  Directory: ${GREEN}android/app/src/main/kotlin/com/$NESTED_PATH/${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. Run 'flutter run' to test the app"
echo "  2. Check the backup files (*.backup) if you need to restore"
echo "  3. For iOS, update the signing team in Xcode if needed"
echo "  4. Verify the directory structure:"
echo "     ls -la android/app/src/main/kotlin/com/$NESTED_PATH/"
echo ""