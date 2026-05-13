#!/bin/bash

# ----------------------------------------
# Auto AAB Signature Checker (Flutter Project)
# ----------------------------------------

echo "🔍 Searching for release AAB..."

# Default Flutter release AAB path
AAB_DIR="build/app/outputs/bundle/release"

# Check if directory exists
if [ ! -d "$AAB_DIR" ]; then
  echo "❌ Release bundle directory not found:"
  echo "   $AAB_DIR"
  echo ""
  echo "👉 Run: flutter build appbundle"
  exit 1
fi

# Find .aab file
AAB_FILE=$(find "$AAB_DIR" -name "*.aab" | head -n 1)

if [ -z "$AAB_FILE" ]; then
  echo "❌ No .aab file found in:"
  echo "   $AAB_DIR"
  exit 1
fi

echo "✅ Found AAB:"
echo "   $AAB_FILE"
echo "----------------------------------------"

# Check if jarsigner exists
if ! command -v jarsigner &> /dev/null; then
  echo "❌ jarsigner not found. Install JDK:"
  echo "   brew install openjdk"
  exit 1
fi

echo "🔐 Verifying signature..."
echo "----------------------------------------"

VERIFY_OUTPUT=$(jarsigner -verify -verbose -certs "$AAB_FILE" 2>&1)

# Check signature validity
if echo "$VERIFY_OUTPUT" | grep -q "jar verified"; then
  echo "✅ AAB is SIGNED"
else
  echo "❌ AAB is NOT properly signed"
  echo "$VERIFY_OUTPUT"
  exit 1
fi

# Show certificate details
echo ""
echo "📜 Certificate Details:"
echo "----------------------------------------"
echo "$VERIFY_OUTPUT" | grep -E "X.509|CN=|OU=|O=|L=|ST=|C="

# Detect debug key
if echo "$VERIFY_OUTPUT" | grep -qi "Android Debug"; then
  echo ""
  echo "⚠️ WARNING: DEBUG KEY DETECTED"
  echo "❌ NOT suitable for Play Store release"
  exit 1
else
  echo ""
  echo "🚀 Production (RELEASE) signature detected"
fi

echo "----------------------------------------"
echo "✔️ AAB verification complete"
