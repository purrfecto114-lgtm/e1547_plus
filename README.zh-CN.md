<table>
  <tr>
    <td width="20%">
      <img src="assets/icon/app/round.png"/>
    </td>
    <td width="80%">
      <h1>e1547</h1>
      <h4>精致的 e621 浏览器</h4>
      <a href="README.md"><img src="https://img.shields.io/badge/README-English-orange" alt="English"></a>
      <a href="https://github.com/purrfecto114-lgtm/e1547_plus/commits/master"><img src="https://img.shields.io/github/commit-activity/m/purrfecto114-lgtm/e1547_plus"></a>
      <a href="https://github.com/purrfecto114-lgtm/e1547_plus/commits/master"><img src="https://img.shields.io/github/last-commit/purrfecto114-lgtm/e1547_plus"></a>
      <a href="blob/master/LICENSE"><img src="https://img.shields.io/github/license/purrfecto114-lgtm/e1547_plus"></a>
      <a href="https://github.com/purrfecto114-lgtm/e1547_plus/releases"><img src="https://img.shields.io/github/downloads/purrfecto114-lgtm/e1547_plus/total"></a>
    </td>
  </tr>
</table>

## 关于此分支

本仓库是 [e1547](https://github.com/clynamic/e1547)（GPL-3.0）的分支，重点关注 Android 7 及其他低内存设备上的稳定性。基于上游 21.1.1 演进，维护自己的 `21.2.x` 及后续发布线 —— 每项改动均按版本记录在 [变更日志](CHANGELOG.md)中。

在上游的基础上，本分支附带两项批次：

- 面向 Android 7 与低内存设备的稳定性批次 —— 限制解码尺寸的图片缓存、按设备内存分级的视频播放器池、带异常防护的缓存数据库访问，以及按内存自适应的默认值
- 安全批次 —— 导出数据库不含凭据并可选 AES-256-GCM 加密（导入时要求密码），导入校验加固、Cookie WebView 锁定本站、数据库文件排除在系统备份之外、请求超时、加盐 PBKDF2 应用锁与防暴力回退，以及兼容 Android 7 指纹 API 的生物识别锁

分支的改动均以 Pull Request 的形式回馈上游（[#190](https://github.com/clynamic/e1547/pull/190)–[#193](https://github.com/clynamic/e1547/pull/193)）。

应用内更新器检查本仓库的新版本；由于本分支使用自己的签名密钥，无法直接覆盖安装官方版本 —— 见下方[升级](#升级)说明。

## 功能

- 跨平台（Android、iOS、Windows、Linux）
- 浏览、编辑、评论帖子，浏览图集
- 下载图片支持传输中途取消；收藏、点赞与点踩
- 关注标签并接收通知；本地黑名单
- DText 解析；视频支持，可选清晰度、按需加载
- 多账号登录；多应用主题
- 多语言界面 —— 十三种语言，内置离线标签词典（约 4000 条简体中文含繁体渲染、约 370 条日语）
- 首次启动引导与设置中的语言、画质选择
- PIN 锁与生物识别锁，切换器中显示隐私遮罩（默认关闭，可在设置中开启）
- 数据库导出可选密码加密（AES-256-GCM），导入时需输入密码
- 无痕键盘模式；登录前的 18 周岁确认
- 稳定的游标分页，带页脚与跳页
- 特殊搜索词筛选（排序、评级、文件类型等），元标签自动补全并按组分类

### 桌面端说明

桌面版编译自同一份代码但属于较年轻的平台，已知差距按影响排序：

- **桌面端无法解决 Cloudflare 质询** —— Cookie WebView 仅移动端可用，桌面用户只能重试等待。
- **Windows/Linux 无截屏保护** —— 安全显示设置自动隐藏（Windows 有原生等价物，尚未接入）。
- **桌面端无后台同步与通知** —— 关注更新仅在前台刷新。
- **更新器打开发布页**（按平台过滤），而非就地下载。

其余功能 —— 浏览、视频、自适应宽窗口布局、数据库导入导出、完整界面 —— 与移动端一致。

## 本地化

界面提供十三种语言，首次启动的欢迎界面或设置中均可选择。日语与俄语已经母语审校；韩语、意大利语、波兰语和越南语为机器翻译，尚未经母语审校。

添加新语言：在 `lib/l10n` 下创建 `app_<locale>.arb`（含 `app_en.arb` 全部键的翻译），将语言加入 `lib/settings/data/language.dart` 的 `appLanguages`，再运行 `flutter gen-l10n`。

## 截图

<p align="center">
  <img src="fastlane/metadata/android/en-US/images/phoneScreenshots/1_en-US.png" width="30%">
  <img src="fastlane/metadata/android/en-US/images/phoneScreenshots/2_en-US.png" width="30%">
  <img src="fastlane/metadata/android/en-US/images/phoneScreenshots/3_en-US.png" width="30%">
</p>

## 下载

APK、IPA、Windows 与 Linux 安装包可在 [releases](https://github.com/purrfecto114-lgtm/e1547_plus/releases) 页面获取。稳定版标记为“最新”；`rc` 预发布版跟踪开发进展，可在同一周期内覆盖安装。更新可用 [obtainium](https://github.com/ImranR98/Obtainium) 管理，应用源填 https://github.com/purrfecto114-lgtm/e1547_plus/releases/。

### 证书指纹

如需验证下载的 APK 文件的真实性，可以核对签名证书指纹：

- **SHA1：** `29:85:3D:AC:C5:EC:58:A2:7F:2B:AC:8D:C0:E7:5A:A6:67:7C:91:73`
- **SHA256：** `10:71:32:BE:71:8B:99:BC:04:1B:0C:56:85:49:BB:89:26:3B:87:92:4F:67:97:FE:07:0E:F4:E0:90:E5:9F:B9`

可使用 [AppVerifier](https://github.com/soupslurpr/AppVerifier) 之类的工具。

## 安装

### 在 Android 上安装

需要 Android 7.0 或更高版本。

1. 下载[最新 APK](https://github.com/purrfecto114-lgtm/e1547_plus/releases)
2. 在 Android 设备上用文件管理器打开
3. 点击安装

#### 应该下载哪个 APK？

- 支持 64 位的手机（2016 年以后的几乎所有机型）→ `e1547-arm64.apk`
- 仅支持 32 位的手机 → `e1547-armv7.apk`
- 还是装不上？→ `e1547-universal.apk`

只要设备支持，请优先选择 arm64 版本：32 位进程的内存上限小得多，在老旧低内存设备上应用更容易被系统杀掉。

### 在 iOS 上安装

应用未上架 AppStore —— 按照 [Sideloadly](https://sideloadly.io/) 的说明操作，或越狱后直接安装 [IPA](https://github.com/purrfecto114-lgtm/e1547_plus/releases)。

### 升级

本分支内的更新可直接覆盖安装旧的分支版本。从官方版本或其他签名不同的构建升级时，Android 会拒绝覆盖安装（应用包名相同）：先在旧应用的设置中导出数据库，卸载旧应用，安装本构建后再导入。

## 编译

1. 安装 [Flutter](https://flutter.dev/docs/get-started/install) 3.44.9 或更新版本（stable）
2. 克隆本 GitHub 仓库
3. 运行 `flutter build <file>`，其中 `<file>` 为 `apk` 或 `ipa`

构建桌面安装包还需要 `fastlane`（各平台的额外要求见 `.github/workflows/deployment.yml`，例如 Windows 的 InnoSetup、Linux 的 GTK 与 mpv 开发库）。

## 社区

本分支的 Bug 反馈与功能请求请提交到其 [issue tracker](https://github.com/purrfecto114-lgtm/e1547_plus/issues)；上游项目为应用本体维护着一个 [Discord 服务器](https://discord.gg/MRwKGqfmUz)。

## 致谢

基于 clragon 与 [clynamic](https://clynamic.net) 的 [e1547](https://github.com/clynamic/e1547)，最初由 [Perlatus](https://github.com/perlatus) 编写、[Miyoyo](https://github.com/miyoyo) 进行性能优化，并感谢其他众多贡献者。中文离线标签说明融合了 [e621 标签汉化&中文搜索](https://sleazyfork.org/en/scripts/554343) 用户脚本（jcjyids，GPL-3.0-or-later）的社区词典。

本分支为 Android 7 与低内存稳定性而维护。
