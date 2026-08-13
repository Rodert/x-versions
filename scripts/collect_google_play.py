#!/usr/bin/env python3
"""Record the version currently exposed by X's official Google Play listing."""

from __future__ import annotations

import json
from datetime import datetime, timezone
from pathlib import Path

from google_play_scraper import app

ROOT = Path(__file__).resolve().parents[1]
CHECKS_PATH = ROOT / "data" / "checks.json"
RELEASES_PATH = ROOT / "data" / "releases.json"
PACKAGE = "com.twitter.android"
SOURCE_URL = f"https://play.google.com/store/apps/details?id={PACKAGE}"


def load(path: Path) -> list[dict]:
    if not path.exists():
        return []
    return json.loads(path.read_text(encoding="utf-8"))


def write(path: Path, data: list[dict]) -> None:
    path.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def main() -> None:
    listing = app(PACKAGE, lang="en", country="us")
    version = listing.get("version")
    if not version:
        raise RuntimeError(f"Google Play did not return a version for {PACKAGE}")

    checked_at = datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")
    check = {
        "checked_at": checked_at,
        "package": PACKAGE,
        "version": version,
        "play_updated_at": listing.get("updated"),
        "source": SOURCE_URL,
    }
    checks = load(CHECKS_PATH)
    checks.append(check)
    write(CHECKS_PATH, checks)

    releases = load(RELEASES_PATH)
    if any(release["version"] == version for release in releases):
        print(f"Official Google Play version unchanged: {version}")
        return

    releases.append(
        {
            "version": version,
            "first_seen_at": checked_at,
            "package": PACKAGE,
            "source": SOURCE_URL,
            "archive_status": "awaiting_official_device_export",
        }
    )
    write(RELEASES_PATH, releases)
    print(f"New official Google Play version discovered: {version}")


if __name__ == "__main__":
    main()
