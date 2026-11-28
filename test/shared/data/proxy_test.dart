import 'package:e1547/shared/data/proxy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('isLocalNetworkHost', () {
    test('matches the loopback ranges', () {
      expect(isLocalNetworkHost('127.0.0.1'), isTrue);
      expect(isLocalNetworkHost('127.9.9.9'), isTrue);
      expect(isLocalNetworkHost('::1'), isTrue);
    });

    test('matches the private ipv4 ranges', () {
      expect(isLocalNetworkHost('10.0.0.5'), isTrue);
      expect(isLocalNetworkHost('172.16.0.1'), isTrue);
      expect(isLocalNetworkHost('172.31.255.255'), isTrue);
      expect(isLocalNetworkHost('192.168.1.10'), isTrue);
      expect(isLocalNetworkHost('172.32.0.1'), isFalse);
      expect(isLocalNetworkHost('172.15.0.1'), isFalse);
      expect(isLocalNetworkHost('11.0.0.5'), isFalse);
      expect(isLocalNetworkHost('193.168.1.10'), isFalse);
    });

    test('matches the link-local and unique-local ipv6 ranges', () {
      expect(isLocalNetworkHost('fe80::1'), isTrue);
      expect(isLocalNetworkHost('fd00::1'), isTrue);
      expect(isLocalNetworkHost('fc00::1'), isTrue);
      expect(isLocalNetworkHost('2a01::1'), isFalse);
    });

    test('never matches hostnames', () {
      expect(isLocalNetworkHost('e621.net'), isFalse);
      expect(isLocalNetworkHost('localhost'), isFalse);
      expect(isLocalNetworkHost('static1.e621.net'), isFalse);
      expect(isLocalNetworkHost(''), isFalse);
    });
  });

  group('requestLocalNetworkPermission', () {
    // The tests run on the host machine, where dart:io reports a
    // non-android platform: the helper must answer null without ever
    // reaching the channel.
    test('answers null off android', () async {
      expect(await requestLocalNetworkPermission('192.168.1.10'), isNull);
    });

    test('answers null for hosts off the local network', () async {
      expect(await requestLocalNetworkPermission('e621.net'), isNull);
    });
  });
}
