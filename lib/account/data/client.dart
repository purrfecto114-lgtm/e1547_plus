import 'dart:async';

import 'package:deep_pick/deep_pick.dart';
import 'package:dio/dio.dart';
import 'package:e1547/account/account.dart';
import 'package:e1547/identity/identity.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/traits/traits.dart';
import 'package:flutter/foundation.dart';

class AccountClient {
  AccountClient({
    required this.dio,
    required this.identity,
    required this.traits,
    required this.postsService,
  });

  final Dio dio;
  final Identity identity;
  final ValueNotifier<Traits> traits;
  final PostClient postsService;

  Future<void> available() => dio.head('/status.json');

  /// The tail of the in-flight push chain; pushes run one after another
  /// so a failing push rolls the value back before the next one starts.
  Future<void>? _pushTail;

  Future<void> push({required Traits traits, CancelToken? cancelToken}) {
    // Concurrent pushes run in order: each one rolls its own value back
    // before the next starts, so a chain of failed pushes unwinds to the
    // state the first of them started from, and no rollback can clobber
    // a value a newer push wrote. Without the order, two failing pushes
    // would restore each other's optimistic value and silently lose the
    // user's original denylist.
    final Future<void> tail = _pushTail ?? Future<void>.value();
    final Completer<void> settled = Completer<void>();
    _pushTail = settled.future;
    return tail.then((_) => _push(traits, cancelToken)).whenComplete(() {
      settled.complete();
      if (identical(_pushTail, settled.future)) _pushTail = null;
    });
  }

  Future<void> _push(Traits traits, CancelToken? cancelToken) async {
    Traits previous = this.traits.value;
    this.traits.value = traits;
    if (identity.username == null) return;
    try {
      if (!listEquals(previous.denylist, traits.denylist)) {
        Map<String, dynamic> body = {
          'user[blacklisted_tags]': traits.denylist.join('\n'),
        };

        await dio.put(
          '/users/${identity.username}.json',
          data: FormData.fromMap(body),
          cancelToken: cancelToken,
        );
      }
    } on DioException {
      // Roll back only if the local denylist is still the one this
      // push wrote: a concurrent pull may have applied a newer server
      // value while the request was in flight, and restoring the
      // pre-push denylist would clobber it.
      if (listEquals(this.traits.value.denylist, traits.denylist)) {
        this.traits.value = this.traits.value.copyWith(
          denylist: previous.denylist,
        );
      }
      rethrow;
    }
  }

  Future<void> pull({CancelToken? cancelToken}) =>
      get(cancelToken: cancelToken);

  Future<Account?> get({CancelToken? cancelToken}) async {
    if (identity.username == null) return null;

    // A push may change the local denylist while the request is in
    // flight; the pulled value is stale by then and must not be
    // applied over it.
    List<String> denylistSnapshot = traits.value.denylist;

    Account result = await dio
        .get('/users/${identity.username}.json', cancelToken: cancelToken)
        .then((response) => E621Account.fromJson(response.data));

    Post? avatar;

    if (result.avatarId != null) {
      // TODO: this shouldnt be here
      try {
        avatar = await postsService.get(
          id: result.avatarId!,
          cancelToken: cancelToken,
        );
      } on ClientException catch (e) {
        // The avatar is supplementary: a post that cannot be fetched
        // must not fail the whole account pull, it merely leaves the
        // account without one. Cancellations abort the pull as usual.
        if (CancelToken.isCancel(e)) rethrow;
        avatar = null;
      }
    }

    String? avatarUrl = avatar?.file;
    if (avatar != null && result.hasCroppedAvatar && !avatar.isDeleted) {
      String? reference = avatar.file ?? avatar.sample ?? avatar.preview;
      if (reference != null) {
        avatarUrl =
            croppedAvatarUrl(
              reference: reference,
              userId: result.id,
              avatarId: avatar.id,
            ) ??
            avatarUrl;
      }
    }

    traits.value = traits.value.copyWith(
      // TODO: also store "id"
      // The server denylist is applied only if no push replaced the
      // local one while the request was in flight; a slow pull must
      // not overwrite a just-pushed value.
      denylist: listEquals(traits.value.denylist, denylistSnapshot)
          ? result.blacklistedTags?.split('\n').trim() ?? []
          : traits.value.denylist,
      // TODO: also store "perPage"
      // TODO: this shouldn't be file but sample
      avatar: avatarUrl,
    );

    return result;
  }
}

extension E621Account on Account {
  static Account fromJson(dynamic json) => pick(json).letOrThrow(
    (pick) => Account(
      id: pick('id').asIntOrThrow(),
      name: pick('name').asStringOrThrow(),
      avatarId: pick('avatar_id').asIntOrNull(),
      hasCroppedAvatar: pick('has_cropped_avatar').asBoolOrFalse(),
      blacklistedTags: pick('blacklisted_tags').asStringOrNull(),
      perPage: pick('per_page').asIntOrNull(),
    ),
  );
}
