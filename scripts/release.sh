#!/usr/bin/env bash
#
# Build, sign and publish a GitHub release of the Android APK in one shot.
#
#   ./scripts/release.sh
#
# The version/tag is read from `version:` in pubspec.yaml (the part before
# the `+`). To cut a new release, bump that line, commit, then run this.
#
# Requirements:
#   - flutter
#   - gh (GitHub CLI), authenticated  ->  gh auth login
#   - android/key.properties present  ->  release signing (else build is
#     debug-signed and the script refuses to publish)
#
# Each release gets two assets:
#   - autoprompter.apk            (stable name -> evergreen "latest" link)
#   - autoprompter-<version>.apk  (versioned archive copy)
#
set -euo pipefail

cd "$(dirname "$0")/.."   # repo root

# --- version from pubspec.yaml (strip "version:" and the "+build" suffix) ---
version="$(grep -E '^version:' pubspec.yaml | sed -E 's/^version:[[:space:]]*//; s/\+.*$//')"
[ -n "$version" ] || { echo "✗ Could not read 'version:' from pubspec.yaml"; exit 1; }
tag="v$version"
echo "▶ Preparing release $tag"

# --- preconditions ------------------------------------------------------------
command -v flutter >/dev/null || { echo "✗ flutter not found in PATH"; exit 1; }
command -v gh      >/dev/null || { echo "✗ gh (GitHub CLI) not found in PATH"; exit 1; }
gh auth status >/dev/null 2>&1 || { echo "✗ gh is not authenticated (run: gh auth login)"; exit 1; }

if [ ! -f android/key.properties ]; then
  echo "✗ android/key.properties is missing — the build would be DEBUG-signed."
  echo "  Configure the release keystore before publishing."
  exit 1
fi

if [ -n "$(git status --porcelain)" ]; then
  echo "✗ Working tree is not clean — commit or stash before releasing:"
  git status --short
  exit 1
fi

if gh release view "$tag" >/dev/null 2>&1; then
  echo "✗ Release $tag already exists. Bump 'version:' in pubspec.yaml first."
  exit 1
fi

# --- make sure the commit being released is on the remote ---------------------
branch="$(git rev-parse --abbrev-ref HEAD)"
echo "▶ Pushing $branch to origin"
git push origin "$branch"

# --- build the universal release APK ------------------------------------------
echo "▶ Building release APK (flutter build apk --release)"
flutter build apk --release

src="build/app/outputs/flutter-apk/app-release.apk"
[ -f "$src" ] || { echo "✗ Expected build output not found: $src"; exit 1; }

mkdir -p dist
cp "$src" "dist/autoprompter.apk"               # evergreen / stable link
cp "$src" "dist/autoprompter-$version.apk"      # versioned archive copy

sha="$(shasum -a 256 dist/autoprompter.apk | awk '{print $1}')"
bytes="$(stat -f%z dist/autoprompter.apk 2>/dev/null || stat -c%s dist/autoprompter.apk)"
echo "▶ APK $((bytes / 1024 / 1024)) MB · SHA-256 $sha"

# --- release notes ------------------------------------------------------------
notes="$(mktemp)"
trap 'rm -f "$notes"' EXIT
cat > "$notes" <<EOF
**Autoprompter $version** — Android.

### 📥 Download & install
Download **\`autoprompter.apk\`** below and open it on your phone.

- **Requirements:** Android 7.0+ — universal APK (\`arm64-v8a\`, \`armeabi-v7a\`, \`x86_64\`).
- When prompted, allow **"Install unknown apps"** for your browser/file manager.
- Google Play Protect may warn the app is unverified (it is signed with the developer's own key, not distributed via Play) — choose **Install anyway**.
- **Permissions:** microphone (speech recognition) and internet.

### 🔒 Integrity
\`\`\`
SHA-256: $sha
\`\`\`

> **iOS:** install via Xcode / TestFlight / App Store (no direct download).
EOF

# --- publish ------------------------------------------------------------------
echo "▶ Creating GitHub release $tag"
gh release create "$tag" \
  "dist/autoprompter.apk#Autoprompter (latest stable link)" \
  "dist/autoprompter-$version.apk#Autoprompter $version (Android APK, universal)" \
  --title "Autoprompter $version" \
  --notes-file "$notes" \
  --latest

git fetch --tags origin >/dev/null 2>&1 || true

repo="$(gh repo view --json nameWithOwner --jq .nameWithOwner)"
echo
echo "✓ Released $tag"
echo "  Release page:   $(gh release view "$tag" --json url --jq .url)"
echo "  Evergreen link: https://github.com/$repo/releases/latest/download/autoprompter.apk"
