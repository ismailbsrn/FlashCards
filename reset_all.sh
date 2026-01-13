#!/bin/bash

echo "🔄 Resetting all databases and storage..."
echo ""

# Reset backend database
echo "1️⃣ Resetting backend database..."
cd backend
if [ -f "flashcards.db" ]; then
    rm -f flashcards.db
    echo "   ✅ Backend database deleted"
else
    echo "   ℹ️  Backend database not found (already clean)"
fi
cd ..

# Clear Flutter app data (shared preferences and local database)
echo ""
echo "2️⃣ Clearing Flutter app storage..."

# For iOS simulator
echo "   📱 iOS Simulator..."
IOS_BOOTED=$(xcrun simctl list devices 2>/dev/null | grep "Booted" | head -n 1)
if [ ! -z "$IOS_BOOTED" ]; then
    # Try common bundle identifiers
    for BUNDLE_ID in "com.example.flashcards2" "com.example.flashcards" "com.ismailbasaran.flashcards"; do
        xcrun simctl privacy booted reset all "$BUNDLE_ID" 2>/dev/null && echo "   ✅ Reset app data for $BUNDLE_ID"
        xcrun simctl uninstall booted "$BUNDLE_ID" 2>/dev/null && echo "   ✅ Uninstalled $BUNDLE_ID"
    done
else
    echo "   ℹ️  No iOS simulator running"
fi

# For Android emulator
echo ""
echo "   🤖 Android Emulator..."
ADB_DEVICES=$(adb devices 2>/dev/null | grep -v "List" | grep "device" | wc -l)
if [ "$ADB_DEVICES" -gt 0 ]; then
    adb shell pm clear com.example.flashcards2 2>/dev/null && echo "   ✅ Android app data cleared" || echo "   ℹ️  App not installed on Android"
else
    echo "   ℹ️  No Android emulator running"
fi

# For web (Chrome)
echo ""
echo "   🌐 Web Browser..."
if [ -d "$HOME/Library/Application Support/Google/Chrome/Default/Local Storage" ]; then
    echo "   ⚠️  Please manually clear browser data or use incognito mode"
    echo "      DevTools → Application → Storage → Clear site data"
fi

# For macOS app
echo ""
echo "   🍎 macOS App..."
MACOS_APP_SUPPORT="$HOME/Library/Containers/com.example.flashcards2/Data/Library/Application Support"
if [ -d "$MACOS_APP_SUPPORT" ]; then
    rm -rf "$MACOS_APP_SUPPORT/com.example.flashcards2"
    echo "   ✅ macOS app data cleared"
else
    echo "   ℹ️  macOS app data not found"
fi

echo ""
echo "✅ Reset complete!"
echo ""
echo "💡 To restart the backend:"
echo "   cd backend && ./venv/bin/python -m uvicorn app.main:app --reload"
echo ""
echo "💡 The databases will be automatically recreated on first use."
