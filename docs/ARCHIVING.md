# Archiving an X Android release

## Source policy

Google Play (`com.twitter.android`) is the official source used for daily version discovery. APKMirror is a binary mirror used only when Google Play has no public download URL. A mirror download is never described as an official download.

The archive script fails closed: it will not create a release unless every extracted APK has package name `com.twitter.android` and its signing certificate SHA-256 matches the expected X certificate supplied by the maintainer.

## Required release evidence

Every release includes:

- `provenance.json`: mirror name, source page, direct download URL, collection time, package, version, expected certificate fingerprint, and validation result.
- `checksums.sha256`: SHA-256 checksum for every APK and the published ZIP.
- `signature-report.txt`: `apksigner` output for each APK.
- The complete APK set in a ZIP, including base and split APKs.

## Download, verify, publish

Download an `.apk` or `.apkm` manually from its APKMirror release page, then run:

```sh
scripts/archive-from-mirror.sh \
  --artifact ~/Downloads/x.apkm \
  --source-page 'https://www.apkmirror.com/apk/x-corp/x/' \
  --source-download 'https://www.apkmirror.com/apk/x-corp/x/.../download/' \
  --expected-cert-sha256 'X_OFFICIAL_CERTIFICATE_SHA256'
```

Requirements: `aapt`, `apksigner`, `jq`, `unzip`, `zip`, `shasum`, and authenticated GitHub CLI (`gh`). Obtain the expected certificate fingerprint independently from a known official X installation before publishing.
