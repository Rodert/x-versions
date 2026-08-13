# X Android Versions

收集和记录 X（原 Twitter）Android 官方版本，包名为 `com.twitter.android`。

## 官方来源

- [X 官方下载说明](https://help.x.com/en/using-x/download-the-x-app)
- [Google Play: X](https://play.google.com/store/apps/details?id=com.twitter.android)

每日工作流从 Google Play 记录当前公开版本。Google Play 不提供公开、稳定的 APK 直链；本仓库不从 APKMirror 或其他第三方镜像下载 APK。

新版本的安装包必须从已由 Google Play 安装 X 的 Android 设备导出。导出完整 split APK 集合后，脚本会检查包名、版本和官方签名证书，再发布至对应 GitHub Release。

## 文件说明

- [`data/releases.json`](data/releases.json)：发现到的官方版本及归档状态。
- [`data/checks.json`](data/checks.json)：每日检查记录。
- [`scripts/collect_google_play.py`](scripts/collect_google_play.py)：采集 Google Play 版本。
- [`scripts/archive-from-device.sh`](scripts/archive-from-device.sh)：从官方 Play 安装的设备导出、校验、发布 APK。
- [`docs/ARCHIVING.md`](docs/ARCHIVING.md)：二进制归档操作说明。

本仓库的脚本和数据采用 Apache-2.0 许可证。X、Twitter、Google Play 及应用二进制的商标与权利归各自权利人所有。
