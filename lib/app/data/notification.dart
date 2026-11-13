import 'package:e1547/identity/identity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification.freezed.dart';
part 'notification.g.dart';

@freezed
abstract class NotificationPayload with _$NotificationPayload {
  const factory NotificationPayload({
    required int identity,
    required String type,
    Map<String, String>? query,
    int? id,
  }) = _NotificationPayload;

  factory NotificationPayload.fromJson(Map<String, dynamic> json) =>
      _$NotificationPayloadFromJson(json);
}

/// How a notification tap relates to the identities on this device.
enum NotificationIdentityAction {
  /// The payload's identity is active; its page can open directly.
  show,

  /// The payload's identity exists; activate it before showing the page,
  /// so content loads from the host that produced the notification.
  switchIdentity,

  /// The payload's identity is gone; the notification is stale and must
  /// not be opened with whichever client happens to be active.
  stale,
}

/// Decides how a notification tap should load its content.
///
/// A notification is created by a specific identity; opening it with the
/// currently active client would query the wrong host whenever the two
/// differ, and a post id can even point to different content per host.
NotificationIdentityAction planNotificationIdentity({
  required Identity? identity,
  required int activeIdentityId,
}) {
  if (identity == null) return NotificationIdentityAction.stale;
  if (identity.id == activeIdentityId) return NotificationIdentityAction.show;
  return NotificationIdentityAction.switchIdentity;
}
