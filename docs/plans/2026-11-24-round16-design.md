# Round 16 Design — 8 项功能/修复（发版 22.9.5+240）

> 验证阶段已完成（systematic-debugging Phase 1-2），本文档记录每项的验证结论、
> 方案取舍与推荐，作为 TDD 实现计划（2026-11-24-round16.md）的输入。

## 验证结论总表

| # | 用户报告 | 验证结论 | 类型 |
|---|---|---|---|
| 1 | 惯用手只改搜索按钮 | 成立：Handedness 仅控制 FAB 位置/气泡侧/自动补全侧（13 处 FAB + 2 处侧边），无布局镜像 | 功能缺失 |
| 2 | tag 翻译仓缺陷 | 成立：`danbooru-e621-CN-`（尾连字符）；README 自述机翻未校对；231,462 条中 14,146 条无中文、36,212 条混英文残留、5 条 Excel #NAME? 碎片、5,932 条译文=原文 | 数据质量 |
| 3 | 订阅页滑动卡顿 | 成立：缩略图存 sample URL（约 800px），tile 解码 cap 写死 `tileSize*2` 不接 qualityFactor；每 tile Column+Card 重建 | 性能 |
| 4 | 订阅"最新"排序失效 | 真 bug：`server.dart:89` `seen ?? true ? Value(0) : absent` 运算符优先级错误，浏览作品页后 unseen 被错误清零/写入 | bug |
| 5 | 缩略图质量无效 | 部分成立：网格只改解码尺寸（URL 恒 sample）；订阅页完全不接该链路 | 半失效 |
| 6 | 卡片大小 x✖️x 布局 | 已有三档尺寸（120/180/300），无列数选择；需求属实 | 功能缺失 |
| 7 | 导出/导入图标反 | 成立：导出=Icons.download（下载箭头朝下进托盘）、导入=Icons.file_upload | bug |
| 8 | 加解密无反馈+限制 | 部分成立：有阻塞进度条；无密码长度限制、无超时兜底、解密重试无上限 | 健壮性 |

## 各项设计

### 1. 惯用手二级设置：布局镜像开关

**现状**：`HandednessSettingsTile` 弹窗选左右手，仅影响 FAB/气泡/自动补全。
**方案**（二选一）：
- A. 在 HandednessDialog 内加"镜像布局"SwitchListTile，存 `layoutMirror` bool 设置
- B. 独立顶级设置项

**选 A**：语义内聚（都在"惯用手"下），一级设置不加行。镜像实现走
`Directionality` 包裹 app 根（`TextDirection.rtl/ltr` 交换），Material 组件
天然支持。风险：RTL 影响文字方向——中文/英文 LTR 文字不受影响（Unicode bidi
算法保留拉丁文字方向），仅布局起点交换。**开关描述文案必须写明"镜像布局方向"**。

### 2. tag 翻译（danbooru-e621-CN-）改进

**现状**：app 内置 4,101 条人工校对中文 tag 描述（tag_descriptions_zh.dart），
来源是 sleazyfork 用户脚本，**不是**该 GitHub 仓。该仓是 webui-tagcomplete 的
机翻数据源。
**裁决**：该仓数据质量不适合直接进 app（机翻未校对+碎片）。改进方向：
- 在 `tag_descriptions_zh.dart` 文件头注释中补充该仓为"参考但不采用"的原因记录
- 不引入其数据（质量差）；如需扩充词条，走人工校对路径
**最小实现**：README 记录 + 文档说明，不动数据。若用户后续要求引入，做过滤
管线（去 #NAME?、去译文=原文、去无中文条目）后再评估。

### 3. 订阅页滑动卡顿

**根因**：`FollowTile` 的 `CachedNetworkImage` 用 `memCacheWidth:
min(tileSize*2*dpr, 1080)` 固定 cap，不响应 thumbnailQuality 设置；
缩略图 URL 是 sample（sample 通常 800px 宽）。滑动时每 tile 新建
Column+Card+CrossFade。
**方案**：接入与 post 网格相同的 `ImageCacheSizeProvider` 链路
（`min(tileSize*qualityFactor*dpr, qualityCap)`），并把 FollowTile 的
Column 包裹进 `RepaintBoundary`。qualityFactor 低档（1.0）时解码尺寸
降为 tileSize（300px）——sample 800px→300px 解码，单 tile 位图内存降 7 倍。

### 4. 排序失效修复（运算符优先级）

**根因**：`server.dart:89`：
```dart
unseen: seen ?? true ? const Value(0) : const Value.absent(),
```
Dart 中 `??` 低于 `?:`…（实际是 `??` 绑定更松，表达式解析为
`seen ?? (true ? Value(0) : Value.absent())`）。syncWith 默认（seen=null）
时永远返回 `Value(0)` 之外的情况——**原意应为 seen ?? true 即"默认视为已读
清零"**。语义应为：`unseen: (seen ?? true) ? Value(0) : Value.absent()`。
**修复**：加括号明确优先级 + 单测锁定语义（seen=true→0，seen=false→absent，
null→0）。同步修复 `withLatest` 里 `foreground` 的连带路径。

### 5. 缩略图质量（实测无效）

**根因 A（视觉）**：网格 URL 恒 sample，卡片 ~180dp，三档解码差异肉眼难辨。
**根因 B（链路）**：订阅页根本不接 qualityFactor（见 #3）。
**方案**：
- 订阅页接入（并入 #3）
- 网格低档改用 preview URL（sample→preview 真正省流量+内存，差异可见），
  中/高档保持 sample
- 设置项 helper 文案说明三档行为差异

### 6. 卡片大小二级设置：x✖️x 布局

**现状**：TileSize 三档像素（120/180/300），crossAxisCount 由
`maxWidth/tileSize` 自动算出。**方案**：外观设置的"卡片大小"弹窗升级为
二级页面：上半保留三档大小选择，下半加"网格密度"选择（列数偏好：自动/
紧凑+1 列/宽松-1 列）。互联网阅读习惯（Pinterest/小红书/Instagram）：
- 默认自动（当前行为）
- 紧凑：crossAxisCount+1（更多内容一屏，浏览效率优先）
- 宽松：crossAxisCount-1（更大卡片，视觉优先）
存 `gridDensity` enum（auto/dense/loose），TileLayout 计算 crossAxisCount
时应用偏移。**不做自由列数输入**（YAGNI，档位化与现有 TileSize 一致）。

### 7. 导出/导入图标修正

`Icons.download`→`Icons.file_upload`（导出：从手机上传出去），
`Icons.file_upload`→`Icons.file_download`（导入：下载进手机）。
与 app 内既有语义对齐（下载管理用 Icons.download 表"取回"）。

### 8. 加解密反馈与限制

- 密码限制：最短 4 字符（太短无暴力抵抗意义，但导出场景不设过高门槛），
  空密码=不加密（现状保留）
- 超时兜底：encrypt/decrypt 包 `.timeout(Duration(seconds: 120))`，超时报
  "操作超时，请重试"而非永久转圈
- 解密失败重试计数：连错 5 次退出流程（防暴力猜测，也是明确反馈）
- 进度反馈保持阻塞进度条，文案增加"正在加密…"/"正在解密…"阶段区分

## 发版策略（用户指令）

- 版本 22.9.5+240（0.0.x patch 位，build 239 已备未发→240 直接跳，
  22.9.4+239 的三件套改版为 22.9.5+240 重新做）
- **dispatch 必带 skip_playstore=true**（PLAYSTORE secret 未配置，
  上轮 release job 红根因）
- **tag 后手动把 GitHub release 改为 pre-release**（改动过大，用户指令）
- **写入 docs/RELEASE.md 行为指南**：pre-release 手动改的操作步骤

## 风险

- #1 RTL 镜像影响所有 Directionality 敏感组件（列表滚动条、抽屉侧）——
  需全量测试回归
- #5 preview URL 切换改变磁盘缓存键，切换档位首次会重新下载缩略图——
  属预期行为
- l10n 新 key 需 13 个 arb 全量翻译
