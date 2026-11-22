// ignore_for_file: avoid_print
// Times the pin KDF at several iteration counts, to ground the
// unlock-wait discussion in measurements instead of impressions.
// Run from the repo root: dart run tool/bench_kdf.dart
import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

Future<int> _timeKdf(int iterations) async {
  final salt = Uint8List.fromList(
    List.generate(16, (_) => Random.secure().nextInt(256)),
  );
  final kdf = Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: iterations,
    bits: 256,
  );
  final sw = Stopwatch()..start();
  await Isolate.run(() async {
    final key = await kdf.deriveKey(
      secretKey: SecretKey(utf8.encode('1234')),
      nonce: salt,
    );
    key.extractBytes();
  });
  return sw.elapsedMilliseconds;
}

Future<void> main() async {
  // warm up the isolate machinery once
  await _timeKdf(1000);
  for (final iterations in [150000, 30000, 10000]) {
    final samples = <int>[];
    for (var i = 0; i < 3; i++) {
      samples.add(await _timeKdf(iterations));
    }
    samples.sort();
    print(
      '$iterations iterations: ${samples.join('/')} ms '
      '(median ${samples[1]})',
    );
  }
}
