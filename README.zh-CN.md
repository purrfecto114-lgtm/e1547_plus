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

本仓库是 [e1547](https://github.com/clynamic/e1547)（GPL-3.0）的分支，
重点关注 Android 7 及其他低内存设备上的稳定性。

在上游 21.0.1 的基础上，本分支提供：

- 面向 Android 7 与低内存设备的稳定性批次 —— 限制解码尺寸的图片缓存、
  设有上限的视频播放器池、带异常防护的缓存数据库访问，以及按内存自适应的默认值
- 安全批次 —— 导出数据库不再包含凭据、导入校验加固、Cookie 捕获 WebView 锁定本站、
  数据库文件排除在系统备份之外、请求超时
- 传输级取消的下载 —— 取消任务即中断网络传输，且任务队列保持并发
- 完整本地化的界面 —— 七种语言，并为约 230 个常用标签提供精选中文说明

分支的改动均以 Pull Request 的形式回馈上游。

应用内更新器检查本仓库的新版本。由于本分支使用自己的签名密钥，
无法直接覆盖安装官方版本 —— 见下方[升级](#升级)说明。

## 功能

- 跨平台（Android、iOS、Windows、Linux）
- 浏览帖子与图集
- 编辑帖子
- 评论帖子
- 下载图片，支持传输中途取消
- 收藏、点赞与点踩
- 关注标签并接收通知
- 本地黑名单
- DText 解析
- 视频支持
- 多账号登录
- 多应用主题
- 多语言界面（English、简体中文、繁體中文、日本語、Русский、Deutsch、Español）
- 首次启动引导与设置中的语言选择
- 约 230 个常用标签的离线中文说明
- 稳定的游标分页，带页脚与跳页
- 特殊搜索词筛选（排序、评级、文件类型等），搜索输入框支持元标签自动补全

## 本地化

应用界面提供英语、简体中文、繁体中文、日语、俄语、德语和西班牙语，
可在首次启动的欢迎界面选择，也可随时在设置中更改。日语与俄语译文已经过母语审校。

如需添加新语言，请在 `lib/l10n` 下创建 `app_<locale>.arb` 文件，
包含 `app_en.arb` 全部键的翻译，将语言加入
`lib/settings/data/language.dart` 的 `appLanguages`，然后运行
`flutter gen-l10n` —— 语言选择器与引导步骤会自动识别。

## 截图

<p align="center">
  <img src="fastlane/metadata/android/en-US/images/phoneScreenshots/1_en-US.png" width="30%">
  <img src="fastlane/metadata/android/en-US/images/phoneScreenshots/2_en-US.png" width="30%">
  <img src="fastlane/metadata/android/en-US/images/phoneScreenshots/3_en-US.png" width="30%">
</p>

## 下载

APK、IPA、Windows 与 Linux 安装包可在
[releases](https://github.com/purrfecto114-lgtm/e1547_plus/releases) 页面获取。

管理本应用更新的好工具是 [obtainium](https://github.com/ImranR98/Obtainium)（详见[使用 Obtainium](#使用-obtainium)）。

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

#### 使用 Obtainium

1. 从 [F-Droid](https://f-droid.org/en/packages/dev.imranr.obtainium.fdroid/) 或其 [GitHub](https://github.com/ImranR98/Obtainium) 安装并打开 Obtainium
2. 点击底部抽屉的 "Add app"
3. 将 https://github.com/purrfecto114-lgtm/e1547_plus/releases/ 粘贴到 "App source URL*" 输入框
4. 点击 App source URL 输入框旁的添加按钮
5. 在随后的菜单中点击安装按钮

#### 应该下载哪个 APK？

- 支持 64 位的手机（2016 年以后的几乎所有机型）→ `e1547-arm64.apk`
- 仅支持 32 位的手机 → `e1547-armv7.apk`
- 还是装不上？→ `e1547-universal.apk`

只要设备支持，请优先选择 arm64 版本：32 位进程的内存上限小得多，
在老旧低内存设备上应用更容易被系统杀掉。

### 在 iOS 上安装

应用未上架 AppStore。

- 按照 [Sideloadly](https://sideloadly.io/) 的说明操作

或

- 越狱设备后直接安装 [IPA](https://github.com/purrfecto114-lgtm/e1547_plus/releases)

### 升级

本分支内的更新可以直接覆盖安装旧的分支版本。

从官方版本或其他签名不同的构建升级时，Android 会拒绝覆盖安装 ——
因为应用包名相同。请先在旧应用的设置中导出数据库，卸载旧应用，
安装本构建后再导入数据库。

## 编译

你可以从源码编译应用：

1. 安装 [Flutter](https://flutter.dev/docs/get-started/install) 3.44.9 或更新版本（stable）
2. 克隆本 GitHub 仓库
3. 运行 `flutter build <file>`，其中 `<file>` 为 `apk` 或 `ipa`

构建桌面安装包还需要 `fastlane`（各平台的额外要求见
`.github/workflows/deployment.yml`，例如 Windows 的 InnoSetup、
Linux 的 GTK 与 mpv 开发库）。

## 社区

本分支的 Bug 反馈与功能请求请提交到其
[issue tracker](https://github.com/purrfecto114-lgtm/e1547_plus/issues)。

上游项目为应用本体维护着一个 [Discord 服务器](https://discord.gg/MRwKGqfmUz)。

## 致谢

基于 clragon 与 [clynamic](https://clynamic.net) 的
[e1547](https://github.com/clynamic/e1547)，最初由
[Perlatus](https://github.com/perlatus) 编写，
[Miyoyo](https://github.com/miyoyo) 进行了性能优化，并感谢其他众多贡献者。

本分支为 Android 7 与低内存稳定性而维护。
