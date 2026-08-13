# X Android Versions

收集和记录 X（原 Twitter）Android 官方版本，包名为 `com.twitter.android`。

## 官方来源

- [X 官方下载说明](https://help.x.com/en/using-x/download-the-x-app)
- [Google Play: X](https://play.google.com/store/apps/details?id=com.twitter.android)

每日工作流从 Google Play 记录当前公开版本。Google Play 不提供公开、稳定的 APK 直链，因此二进制可从 APKMirror 获取；每一个发布包均须通过 X 官方签名证书校验，未通过校验不会发布。

每个 Release 都必须包含来源页与下载 URL、采集时间、包名、版本、逐 APK SHA-256、签名证书 SHA-256、签名验证结果及完整 split APK 清单。详见 [归档说明](docs/ARCHIVING.md)。

## 文件说明

- [`data/releases.json`](data/releases.json)：发现到的官方版本及归档状态。
- [`data/checks.json`](data/checks.json)：每日检查记录。
- [`scripts/collect_google_play.py`](scripts/collect_google_play.py)：采集 Google Play 版本。
- [`scripts/archive-from-mirror.sh`](scripts/archive-from-mirror.sh)：校验 APKMirror 下载的 APK/APKM 并发布。
- [`docs/ARCHIVING.md`](docs/ARCHIVING.md)：二进制归档操作说明。

本仓库的脚本和数据采用 Apache-2.0 许可证。X、Twitter、Google Play 及应用二进制的商标与权利归各自权利人所有。
