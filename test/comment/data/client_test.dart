import 'package:dio/dio.dart';
import 'package:e1547/comment/comment.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../_support/client.dart';
import '../../_support/fake_e621.dart';
import '../../_support/fixtures.dart';
import '../../_support/harness.dart';

void main() {
  late FakeE621 fake;
  late CommentClient client;

  setUpAll(initializeTestApp);

  setUp(() async {
    fake = await FakeE621.start();
    client = CommentClient(dio: dioFor(fake));
  });

  tearDown(() => fake.stop());

  test('maps a recorded comment onto the model', () async {
    final recorded = loadFixtureList('comments.json').first;

    final comment = (await client.page()).first;

    expect(comment.id, recorded['id']);
    expect(comment.body, recorded['body']);
    expect(comment.postId, recorded['post_id']);
    expect(comment.creatorId, recorded['creator_id']);
    expect(comment.creatorName, recorded['creator_name']);
    expect(comment.score, recorded['score']);
    expect(comment.hidden, recorded['is_hidden']);
  });

  test('creates a comment with the params the server permits', () async {
    final postId = loadFixtureList('posts.json').first['id']! as int;

    await client.create(postId: postId, content: 'hello');

    expect(fake.requests.last.body, {
      'comment[body]': 'hello',
      'comment[post_id]': '$postId',
    });
  });

  test('updates a comment body', () async {
    final id = loadFixtureList('comments.json').first['id']! as int;

    await client.update(id: id, postId: 0, content: 'edited');

    expect((await client.get(id: id)).body, 'edited');
  });

  test('votes a comment regardless of the response shape', () async {
    final id = loadFixtureList('comments.json').first['id']! as int;

    await client.vote(id: id, upvote: true, replace: false);

    expect(fake.requests.last.path, '/comments/$id/votes.json');
    expect(fake.requests.last.body, {'score': '1', 'no_unvote': 'false'});
  });

  test('the server rejects params it does not permit', () async {
    final postId = loadFixtureList('posts.json').first['id']! as int;

    await expectLater(
      client.dio.post(
        '/comments.json',
        data: FormData.fromMap({
          'comment[body]': 'hello',
          'comment[post_id]': '$postId',
          'comment[creator_id]': '9000',
        }),
      ),
      throwsA(
        isA<DioException>().having(
          (e) => e.response?.statusCode,
          'statusCode',
          400,
        ),
      ),
    );
  });
}
