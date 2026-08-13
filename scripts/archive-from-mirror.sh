#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 --artifact FILE --source-page URL --source-download URL --expected-cert-sha256 FINGERPRINT" >&2
  exit 2
}

artifact=""
source_page=""
source_download=""
expected_cert=""
while [ "$#" -gt 0 ]; do
  case "$1" in
    --artifact) artifact="${2:-}"; shift 2 ;;
    --source-page) source_page="${2:-}"; shift 2 ;;
    --source-download) source_download="${2:-}"; shift 2 ;;
    --expected-cert-sha256) expected_cert="${2:-}"; shift 2 ;;
    *) usage ;;
  esac
done
test -f "$artifact" && test -n "$source_page" && test -n "$source_download" && test -n "$expected_cert" || usage

for command in aapt apksigner jq unzip zip shasum gh; do command -v "$command" >/dev/null; done
package_name="com.twitter.android"
work_dir="$(mktemp -d)"
trap 'rm -rf "$work_dir"' EXIT

case "$artifact" in
  *.apk) cp "$artifact" "$work_dir/base.apk" ;;
  *.apkm|*.apks|*.zip) unzip -q "$artifact" '*.apk' -d "$work_dir" ;;
  *) echo "Artifact must be an APK or archive containing APK files." >&2; exit 2 ;;
esac
find "$work_dir" -maxdepth 1 -name '*.apk' -print -quit | grep -q . || { echo "No APK files found." >&2; exit 1; }

version=""
report="$work_dir/signature-report.txt"
for apk in "$work_dir"/*.apk; do
  badging="$(aapt dump badging "$apk" | head -1)"
  printf '%s\n%s\n\n' "== $(basename "$apk") ==" "$(apksigner verify --print-certs "$apk")" >> "$report"
  printf '%s' "$badging" | grep -Fq "name='$package_name'" || { echo "Unexpected package in $apk" >&2; exit 1; }
  apksigner verify --print-certs "$apk" | grep -Fqi "certificate SHA-256 digest: ${expected_cert}" || { echo "Unexpected signer in $apk" >&2; exit 1; }
  candidate="$(printf '%s\n' "$badging" | sed -n "s/.*versionName='\([^']*\)'.*/\1/p")"
  if [ -n "$candidate" ] && [ -z "$version" ]; then version="$candidate"; fi
done
test -n "$version" || { echo "Could not determine version." >&2; exit 1; }

collected_at="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
archive="x-${version}-apkmirror-verified-apks.zip"
(cd "$work_dir" && zip -q "$archive" ./*.apk)
(cd "$work_dir" && shasum -a 256 ./*.apk "$archive" > checksums.sha256)
files="$(find "$work_dir" -maxdepth 1 -name '*.apk' -exec basename {} \; | sort | jq -R . | jq -s .)"
jq -n --arg package "$package_name" --arg version "$version" --arg collected "$collected_at" --arg expected "$expected_cert" --arg page "$source_page" --arg download "$source_download" --argjson files "$files" '{package: $package, version: $version, collected_at: $collected, binary_source: {name: "APKMirror", release_page: $page, download_url: $download}, expected_signing_certificate_sha256: $expected, validation: {package_name: "passed", signing_certificate: "passed", checksums: "sha256"}, files: $files}' > "$work_dir/provenance.json"

tag="v${version}"
gh release create "$tag" "$work_dir/$archive" "$work_dir/checksums.sha256" "$work_dir/provenance.json" "$report" --title "X ${version} (APKMirror, signature verified)" --notes "Binary source: APKMirror. Package and X signing certificate validated. See provenance.json, checksums.sha256, and signature-report.txt."
