// Pinned divergences from the staging-corpus fuzz against dmark. Entries
// carrying a `skip` field are pinned known bugs: the suite documents the
// bug without breaking CI, and removing the `skip` field (in
// `fixtures/divergences.json`) is the signal that the underlying bug has
// been fixed and the test starts enforcing parity. No entry is skipped
// right now — every divergence below enforces fixed behavior. Regenerate
// frozen JSON with `./test/markup/regenerate.sh divergences`.

import '_support/fixtures.dart';

void main() => runFixtures('divergences');
