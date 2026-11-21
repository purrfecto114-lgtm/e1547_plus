import 'package:e1547/l10n/app_localizations.dart';
import 'package:e1547/task/task.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../_support/harness.dart';

void main() {
  setUpAll(() => initializeTestApp());

  final Map<TaskErrorCategory, String> enHints = {
    TaskErrorCategory.directory:
        'The save folder is missing or read-only. Pick the download folder again.',
    TaskErrorCategory.auth:
        'The server rejected this account. Check your login, then retry.',
    TaskErrorCategory.network:
        'The transfer failed. Retry once the network is back.',
    TaskErrorCategory.saving:
        'Saving to the gallery failed. Check free space, then retry.',
    TaskErrorCategory.unknown:
        'This task failed. Retry it, or open its details.',
  };

  final Map<TaskErrorCategory, String> zhHints = {
    TaskErrorCategory.directory: '保存文件夹缺失或只读，请重新选择下载文件夹。',
    TaskErrorCategory.auth: '服务器拒绝了这个账号，请检查登录后重试。',
    TaskErrorCategory.network: '传输失败，等网络恢复后重试。',
    TaskErrorCategory.saving: '保存到相册失败，请检查剩余空间后重试。',
    TaskErrorCategory.unknown: '此任务失败，可重试或打开详情。',
  };

  final Map<TaskErrorCategory, String> zhHantHints = {
    TaskErrorCategory.directory: '儲存資料夾缺失或唯讀，請重新選擇下載資料夾。',
    TaskErrorCategory.auth: '伺服器拒絕了這個帳號，請檢查登入後重試。',
    TaskErrorCategory.network: '傳輸失敗，等網路恢復後重試。',
    TaskErrorCategory.saving: '儲存到相簿失敗，請檢查剩餘空間後重試。',
    TaskErrorCategory.unknown: '此任務失敗，可重試或開啟詳情。',
  };

  /// Pumps the failure hint for every category plus the retention notice,
  /// so a locale that still renders hardcoded english fails loudly here.
  Future<void> pumpHints(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final TaskErrorCategory category
                    in TaskErrorCategory.values)
                  Text(taskErrorHint(context, category)),
                TaskErrorDetails(
                  task: Task(
                    id: 1,
                    action: TaskAction.download,
                    postId: 4992046,
                    status: TaskStatus.failed,
                    error:
                        "Invalid argument(s): Uri https://static1.e621.net/data/sample.jpg must have scheme 'file:'.",
                    createdAt: DateTime(2026, 11, 20),
                    completedAt: DateTime(2026, 11, 20),
                    metadata: null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('failure hints speak the app language', (tester) async {
    await pumpHints(tester);
    for (final MapEntry<TaskErrorCategory, String> entry in enHints.entries) {
      expect(find.text(entry.value), findsOneWidget);
    }
    expect(
      find.text('Failed tasks are kept for 7 days before they are cleaned up.'),
      findsOneWidget,
    );
  });

  testWidgets('failure hints speak chinese', (tester) async {
    await pumpHints(tester, locale: const Locale('zh'));
    for (final MapEntry<TaskErrorCategory, String> entry in zhHints.entries) {
      expect(find.text(entry.value), findsOneWidget);
    }
    expect(find.text('失败的任务将保留 7 天，之后自动清理。'), findsOneWidget);
  });

  testWidgets('failure hints speak traditional chinese', (tester) async {
    await pumpHints(
      tester,
      locale: const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
    );
    for (final MapEntry<TaskErrorCategory, String> entry
        in zhHantHints.entries) {
      expect(find.text(entry.value), findsOneWidget);
    }
    expect(find.text('失敗的任務會保留 7 天，之後自動清理。'), findsOneWidget);
  });
}
