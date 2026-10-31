import 'package:e1547/settings/settings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('classifyImportSchemaVersion', () {
    test('the current schema imports', () {
      expect(
        classifyImportSchemaVersion(supportedSchemaVersion),
        ImportSchemaGate.ok,
      );
    });

    test('older schemas import, migration upgrades them', () {
      expect(classifyImportSchemaVersion(1), ImportSchemaGate.ok);
    });

    test('a newer schema is rejected as too new', () {
      expect(
        classifyImportSchemaVersion(supportedSchemaVersion + 1),
        ImportSchemaGate.tooNew,
      );
    });

    test('a file without a schema version is not an e1547 export', () {
      // sqlite reports user_version 0 for a file it treats as brand new;
      // opening it would run onCreate, create every app table itself, and
      // let a 0-byte file pass the table check — destroying the user's
      // data once the import completes.
      expect(classifyImportSchemaVersion(0), ImportSchemaGate.empty);
    });

    test('a file that is no sqlite database at all is rejected', () {
      expect(classifyImportSchemaVersion(null), ImportSchemaGate.empty);
    });
  });
}
