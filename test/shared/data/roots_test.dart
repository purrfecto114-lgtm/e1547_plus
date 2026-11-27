import 'dart:io';

import 'package:dio/io.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('the bundled roots load into a security context', () async {
    final SecurityContext? context = await loadTrustedRoots();

    expect(context, isNotNull);
    expect(trustedRoots, same(context));
  });

  test(
    'the bundle carries the roots the frozen android store predates',
    () async {
      final String pem = await rootBundle.loadString(trustedRootsAsset);

      expect(pem, contains('ISRG Root X1'));
      expect(pem, contains('ISRG Root X2'));
      expect(pem, contains('GTS Root R1'));
      expect('BEGIN CERTIFICATE'.allMatches(pem).length, greaterThan(100));
    },
  );

  test('the media adapter always rides the dart stack', () {
    expect(mediaAdapter(null), isA<IOHttpClientAdapter>());
    expect(
      mediaAdapter((host: '127.0.0.1', port: 8080)),
      isA<IOHttpClientAdapter>(),
    );
    // the api adapter keeps the native engine when no proxy is set
    expect(proxyAwareAdapter(null), isNot(isA<IOHttpClientAdapter>()));
  });
}
