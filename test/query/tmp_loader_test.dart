import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:e1547/query/data/loader.dart';

void main() {
  test('same-tick requires batch into one load call', () async {
    final loads = <List<int>>[];
    final loader = QueryLoader<int, int>(
      (ids) async {
        loads.add(ids);
        await Future<void>.value();
        return {for (final id in ids) id: id * 10};
      },
      limit: 320,
    );

    final results = await Future.wait([loader.require(1), loader.require(2)]);
    expect(results, [10, 20]);
    expect(loads, [
      [1, 2],
    ]);
  });

  test('requires that straddle an event loop boundary load separately',
      () async {
    final loads = <List<int>>[];
    final loader = QueryLoader<int, int>(
      (ids) async {
        loads.add(ids);
        return {for (final id in ids) id: id};
      },
    );

    final first = loader.require(1);
    await Future<void>.delayed(Duration.zero);
    final second = loader.require(2);
    await Future.wait([first, second]);
    expect(loads.length, 2);
  });
}
