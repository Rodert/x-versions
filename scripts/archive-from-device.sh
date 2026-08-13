#!/usr/bin/env bash
set -euo pipefail

package_name="com.twitter.android"
expected_cert="${X_EXPECTED_CERT_SHA256:?Set the expected official certificate SHA-256.}"
work_dir="$(mktemp -d)"
trap 'rm -rf "$work_dir"' EXIT

command -v adb >/dev/null
command -v apksigner >/dev/null
command -v aapt >/dev/null
command -v gh >/dev/null
adb get-state | grep -qx device

version="$(adb shell dumpsys package "$package_name" | tr -d '\r' | sed -n 's/.*versionName=\([^ ]*\).*/\1/p' | head -1)"
test -n "$version"

while IFS= read -r remote_path; do
  adb pull "$remote_path" "$work_dir/$(basename "$remote_path")" >/dev/null
done < <(adb shell pm path "$package_name" | tr -d '\r' | sed 's/^package://')

find "$work_dir" -maxdepth 1 -name '*.apk' -print -quit | grep -q .
for apk in "$work_dir"/*.apk; do
  aapt dump badging "$apk" | head -1 | grep -Fq "name='$package_name'"
  apksigner verify --print-certs "$apk" | grep -Fqi "certificate SHA-256 digest: ${expected_cert}"
done

archive="x-${version}-official-google-play-apks.zip"
manifest="x-${version}-official-google-play-apks.sha256"
checked_at="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
printf '{\n  "package": "%s",\n  "version": "%s",\n  "source": "Google Play Store",\n  "source_url": "https://play.google.com/store/apps/details?id=%s",\n  "exported_at": "%s"\n}\n' "$package_name" "$version" "$package_name" "$checked_at" > "$work_dir/provenance.json"
(cd "$work_dir" && zip -q "$archive" ./*.apk provenance.json && shasum -a 256 "$archive" > "$manifest")

tag="v${version}"
gh release create "$tag" "$work_dir/$archive" "$work_dir/$manifest" --title "X ${version} (official Google Play export)" --notes "Exported from an official Google Play installation. See the provenance record and SHA-256 manifest."
