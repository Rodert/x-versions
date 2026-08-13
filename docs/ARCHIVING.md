# Archiving an official X Android release

X is distributed through Google Play as an Android App Bundle. A device installation normally includes a base APK and one or more configuration or feature split APKs. Archive the complete set.

## Requirements

- A device where X was installed or updated through the official Google Play Store.
- Android Platform Tools (`adb`).
- Android Build Tools (`apksigner`).
- GitHub CLI (`gh`) authenticated with permission to create releases.
- The SHA-256 fingerprint of X's official app-signing certificate, obtained and reviewed independently.

## Export and publish

Enable USB debugging, connect the device, and run:

```sh
X_EXPECTED_CERT_SHA256='OFFICIAL_CERTIFICATE_SHA256' scripts/archive-from-device.sh
```

The script reads every path returned by `adb shell pm path com.twitter.android`, verifies the package and signer certificate for each APK, writes a SHA-256 manifest and provenance record, then creates a GitHub Release.

Do not use an APK obtained from a third-party download site. The expected certificate fingerprint is intentionally required as an input: it prevents treating an unknown signing key as official.
