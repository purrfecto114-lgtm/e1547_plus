import 'dart:async';
import 'dart:convert';

import 'package:e1547/app/app.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/identity/identity.dart';
import 'package:e1547/l10n/app_localizations.dart';
import 'package:e1547/logs/logs.dart';
import 'package:e1547/pool/pool.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_sub/flutter_sub.dart';

class NotificationHandler extends StatefulWidget {
  const NotificationHandler({
    super.key,
    required this.child,
    required this.navigatorKey,
  });

  final Widget child;
  final GlobalKey<NavigatorState> navigatorKey;

  @override
  State<NotificationHandler> createState() => _NotificationHandlerState();
}

class _NotificationHandlerState extends State<NotificationHandler>
    with WidgetsBindingObserver {
  late Future<FlutterLocalNotificationsPlugin> notifications =
      initializeNotifications(onDidReceiveNotificationResponse: handle);
  List<Follow>? previousFollows;
  Logger logger = Logger('NotificationRouter');

  /// Whether the follow background task is currently registered.
  ///
  /// Workmanager keys tasks by their unique name, so re-registering
  /// replaces instead of duplicating; this flag only skips redundant
  /// registrations.
  bool followTaskRegistered = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initialize();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Granting notifications in system settings does not change the follow
    // set, so the stream listener short-circuits and nothing re-registers.
    // Returning to the app is the one moment the permission may have
    // improved; the system state is re-queried without prompting.
    if (state == AppLifecycleState.resumed) {
      recheckFollowBackgroundTask();
    }
  }

  Future<void> initialize() async {
    if (!PlatformCapabilities.hasNotifications) return;
    NotificationAppLaunchDetails? details = await (await notifications)
        .getNotificationAppLaunchDetails();
    if (details != null && details.didNotificationLaunchApp) {
      NotificationResponse? response = details.notificationResponse;
      if (response != null) {
        handle(response);
      }
    }
  }

  Future<void> setupFollowBackground(List<Follow> follows) async {
    if (!PlatformCapabilities.hasNotifications) return;
    bool isNotifying = follows
        .where((e) => e.type == FollowType.notify)
        .isNotEmpty;
    if (!isNotifying) {
      if (followTaskRegistered) {
        followTaskRegistered = false;
        await registerFollowBackgroundTask(follows);
      }
      return;
    }
    if (followTaskRegistered) return;
    // Notification follows exist, but no task is registered: either this is
    // the first run, or a previous permission request was denied. Queries
    // the system state first; only a fresh transition to notification
    // follows prompts, repeated follow updates must not loop the dialog.
    bool wasNotifying =
        previousFollows != null &&
        previousFollows!.where((e) => e.type == FollowType.notify).isNotEmpty;
    // A denial from an earlier run is remembered, so the user is not
    // asked again on every cold start; only a grant — through the prompt
    // or the system settings — clears the flag again.
    final ValueNotifier<bool> denied = context
        .read<Settings>()
        .deniedNotifications;
    final bool prompt = !wasNotifying && !denied.value;
    final FlutterLocalNotificationsPlugin plugin = await notifications;
    final bool granted = await hasNotificationPermission(
      plugin,
      prompt: prompt,
    );
    if (granted) {
      if (denied.value) denied.value = false;
      followTaskRegistered = true;
      await registerFollowBackgroundTask(follows);
    } else if (prompt) {
      denied.value = true;
    }
  }

  /// Returns whether notifications may currently be shown.
  ///
  /// Android is queried directly. iOS has no query without a request;
  /// once the follow stream has asked for the first time, a request
  /// returns the stored decision without showing anything, so it serves
  /// as the query there. Before that first ask, [prompt] decides whether
  /// the system dialog may be shown at all.
  Future<bool> hasNotificationPermission(
    FlutterLocalNotificationsPlugin plugin, {
    required bool prompt,
  }) async {
    final AndroidFlutterLocalNotificationsPlugin? android = plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android == null) {
      // iOS has no query without a request, but it only ever shows its
      // permission dialog once per install: after the follow stream has
      // asked once, every further request is answered immediately from
      // the stored decision and doubles as the query. A bare "true"
      // would register a background task that can never show a
      // notification for a user who declined the prompt.
      return requestNotificationPermissions(plugin);
    }
    // Android is queried directly; only an explicit prompt shows the
    // system dialog again.
    final bool? enabled = await android.areNotificationsEnabled();
    if (enabled ?? false) return true;
    if (!prompt) return false;
    return requestNotificationPermissions(plugin);
  }

  /// Requests the system notification permission.
  Future<bool> requestNotificationPermissions(
    FlutterLocalNotificationsPlugin plugin,
  ) async {
    bool? result;
    result = await plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    result = await plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
    return result ?? true;
  }

  /// Re-checks the notification permission after a resume.
  ///
  /// A permission granted in system settings changes nothing about the
  /// follow set, so this is the only path which picks it up again. The
  /// background task is (un)registered to match the system state;
  /// registration is idempotent, so repeated resumes register nothing.
  Future<void> recheckFollowBackgroundTask() async {
    if (!PlatformCapabilities.hasNotifications) return;
    final List<Follow>? follows = previousFollows;
    if (follows == null) return;
    if (follows.where((e) => e.type == FollowType.notify).isEmpty) return;
    // Resolved before the awaits: contexts must not cross async gaps.
    final ValueNotifier<bool> denied = context
        .read<Settings>()
        .deniedNotifications;
    final FlutterLocalNotificationsPlugin plugin = await notifications;
    final bool granted = await hasNotificationPermission(plugin, prompt: false);
    if (granted == followTaskRegistered) return;
    followTaskRegistered = granted;
    if (granted) {
      // A grant that arrived through the system settings clears a
      // remembered denial, the same way the prompt path does; leaving
      // it set would make the flag dead weight and suppress the only
      // legitimate re-prompt path on iOS.
      if (denied.value) denied.value = false;
      await registerFollowBackgroundTask(follows);
    } else {
      await cancelFollowBackgroundTask();
    }
  }

  Future<void> sendNotifications(List<Follow> follows, int identity) async {
    if (!PlatformCapabilities.hasNotifications) return;
    if (previousFollows != null) {
      // Resolved before the awaits: contexts must not cross async gaps.
      final BaseCacheManager cache = context.read<BaseCacheManager>();
      final bool hideContent = context
          .read<Settings>()
          .hideNotificationContent
          .value;
      final FlutterLocalNotificationsPlugin plugin = await notifications;
      await updateFollowNotifications(
        identity: identity,
        previous: previousFollows!,
        updated: follows,
        notifications: plugin,
        cache: cache,
        hideContent: hideContent,
      );
    }
  }

  Future<void> handle(NotificationResponse response) async {
    if (!context.mounted) return;
    String? payload = response.payload;
    if (payload == null) return;
    // Resolved up front, contexts must not cross async gaps.
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final IdentityClient identities = context.read<IdentityClient>();
    NotificationPayload? notification;
    try {
      notification = NotificationPayload.fromJson(json.decode(payload));
    } on FormatException catch (e, s) {
      logger.error('Failed to parse notification payload', null, e, s);
      return;
    }

    // A launch notification can arrive before the first frame attached
    // the navigator; its context only exists once built. Waiting for it
    // keeps a cold start tap from being dropped when the first frame
    // was not enough, the same way deep links wait.
    while (widget.navigatorKey.currentContext == null) {
      if (!mounted) return;
      await WidgetsBinding.instance.endOfFrame;
    }

    switch (notification.type) {
      case 'follow':
        // A notification belongs to the identity that created it; opening
        // it with whichever client is active would load from the wrong
        // host when the accounts (or their hosts) differ.
        final Identity? identity = await identities.getOrNull(
          notification.identity,
        );
        switch (planNotificationIdentity(
          identity: identity,
          activeIdentityId: identities.identity.id,
        )) {
          case NotificationIdentityAction.stale:
            widget.navigatorKey.currentState!.pushNamedAndRemoveUntil(
              '/subscriptions',
              (route) => route.isFirst,
            );
            messenger.showSnackBar(
              SnackBar(content: Text(l10n.notificationStaleIdentity)),
            );
            return;
          case NotificationIdentityAction.switchIdentity:
            await identities.activate(identity!.id);
          case NotificationIdentityAction.show:
            break;
        }
        widget.navigatorKey.currentState!.pushNamedAndRemoveUntil(
          '/subscriptions',
          (route) => route.isFirst,
        );
        if (notification.query != null) {
          final String? tags = notification.query!['tags'];
          final poolId = tags != null
              ? poolRegex().firstMatch(tags)?.namedGroup('id')
              : null;
          widget.navigatorKey.currentState!.push(
            MaterialPageRoute(
              builder: (context) => poolId != null
                  ? PoolLoadingPage(int.parse(poolId), orderByOldest: false)
                  : PostsPage(params: PostParams(tags: tags)),
            ),
          );
        }
        if (notification.id != null) {
          widget.navigatorKey.currentState!.push(
            MaterialPageRoute(
              builder: (context) => PostLoadingPage(notification!.id!),
            ),
          );
        }
        break;
      default:
        logger.warn('Unknown notification type {type}', {
          'type': notification.type,
        });
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final client = context.watch<Client>();
    return SubStream<List<Follow>>(
      create: () => client.follows
          .all(query: FollowsQuery(types: [FollowType.notify]))
          .streamed,
      keys: [client],
      listener: (event) async {
        await Future.wait([
          setupFollowBackground(event),
          sendNotifications(event, client.identity.id),
        ]);
        previousFollows = event;
      },
      builder: (context, stream) => widget.child,
    );
  }
}
