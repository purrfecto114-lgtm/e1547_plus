import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;

/// The bundled modern root certificate store.
///
/// Android 7 froze its system CA store before ISRG Root X1 — Let's
/// Encrypt's root — was added to it, and the cronet engine validates
/// against that frozen store. Cloudflare rotates the cdn hosts between
/// its certificate authorities: static1.e621.net moved to a Let's
/// Encrypt chain in november 2026, and every media request to it failed
/// with ERR_CERT_AUTHORITY_INVALID on those devices while the api host
/// kept its Google Trust Services chain. The media stack validates
/// against this bundle instead, which carries the current set of public
/// roots, so the next authority rotation cannot break it again.
///
/// The bundle replaces the system store for the [SecurityContext] it
/// feeds, so it ships the full set rather than just the missing roots.
const String trustedRootsAsset = 'assets/ca/roots.pem';

SecurityContext? _trustedRoots;

/// The loaded bundle context, or null before [loadTrustedRoots] ran.
SecurityContext? get trustedRoots => _trustedRoots;

/// Loads the bundled roots into a [SecurityContext] for later media
/// requests. Safe to call more than once; the last load wins.
Future<SecurityContext?> loadTrustedRoots() async {
  try {
    final ByteData data = await rootBundle.load(trustedRootsAsset);
    final SecurityContext context = SecurityContext()
      ..setTrustedCertificatesBytes(data.buffer.asUint8List());
    _trustedRoots = context;
  } on Object {
    // A missing or unreadable bundle leaves the system store in charge:
    // every current host validates against it except the ones that
    // rotated to a root the frozen store predates, which is exactly the
    // state before this existed.
    _trustedRoots = null;
  }
  return _trustedRoots;
}
