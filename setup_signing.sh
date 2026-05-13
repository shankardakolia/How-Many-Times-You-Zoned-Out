#!/bin/bash

set -e

# Paths
KEY_PROPS="android/key.properties"
KEYSTORE="android/app/keystore.jks"
GRADLE_KTS="android/app/build.gradle.kts"
GRADLE_GROOVY="android/app/build.gradle"

echo "🚀 Setting up Keystore, Properties, and Signing Config..."

# --------------------------------------------------
# 1. Generate Keystore
# --------------------------------------------------
if [ ! -f "$KEYSTORE" ]; then
    echo "🔐 Generating keystore.jks..."
    keytool -genkey -v \
      -keystore "$KEYSTORE" \
      -keyalg RSA -keysize 2048 -validity 10000 \
      -alias upload -storepass android -keypass android \
      -dname "CN=Shankar Dakolia, L=Mumbai, ST=Maharashtra, C=IN" -noprompt
else
    echo "✔ Keystore already exists."
fi

# --------------------------------------------------
# 2. Create key.properties
# --------------------------------------------------
echo "📝 Writing key.properties..."
cat <<EOF > "$KEY_PROPS"
storePassword=android
keyPassword=android
keyAlias=upload
storeFile=keystore.jks
EOF

# --------------------------------------------------
# 3. Detect Gradle Type
# --------------------------------------------------
if [ -f "$GRADLE_KTS" ]; then
    echo "📦 Detected Kotlin DSL (build.gradle.kts)"
    GRADLE_FILE="$GRADLE_KTS"
    DSL="kts"
elif [ -f "$GRADLE_GROOVY" ]; then
    echo "📦 Detected Groovy DSL (build.gradle)"
    GRADLE_FILE="$GRADLE_GROOVY"
    DSL="groovy"
else
    echo "❌ No Gradle file found!"
    exit 1
fi

# --------------------------------------------------
# 4. Inject Signing Config (ONLY if missing)
# --------------------------------------------------

if grep -q "AUTO-GENERATED SIGNING CONFIG" "$GRADLE_FILE"; then
    echo "✔ signingConfigs already present. Skipping injection."
else
    echo "⚙ Adding signing configuration..."

    if [ "$DSL" = "kts" ]; then
        # Insert import at the top for Kotlin DSL
        if ! grep -q "import java.util.Properties" "$GRADLE_FILE"; then
            sed -i "" '1i\
import java.util.Properties
' "$GRADLE_FILE"
        fi

cat <<'EOF' >> "$GRADLE_FILE"

// 🔐 AUTO-GENERATED SIGNING CONFIG
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")

if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(keystorePropertiesFile.inputStream())
}

android {
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties.getProperty("keyAlias")
            keyPassword = keystoreProperties.getProperty("keyPassword")
            storeFile = file("keystore.jks")
            storePassword = keystoreProperties.getProperty("storePassword")
        }
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}
EOF

    else
cat <<'EOF' >> "$GRADLE_FILE"

// 🔐 AUTO-GENERATED SIGNING CONFIG
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file("key.properties")

if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile file('keystore.jks')
            storePassword keystoreProperties['storePassword']
        }
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
EOF

    fi
fi

# --------------------------------------------------
# 5. Clean + Build
# --------------------------------------------------
echo "🧹 Cleaning project..."
flutter clean

echo "📦 Fetching dependencies..."
flutter pub get

echo "🧪 Building signed AAB..."
flutter build appbundle --release

echo "✅ DONE: Signed AAB generated successfully."
