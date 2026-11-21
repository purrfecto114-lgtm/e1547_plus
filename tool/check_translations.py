#!/usr/bin/env python3
"""Fails when any app_*.arb is missing or carrying extra keys vs app_en.arb.

gen-l10n only prints untranslated messages as a warning the CI never sees;
this keeps the door shut instead.
"""
import json
import sys
from pathlib import Path


def keys(path: Path) -> set[str]:
    data = json.loads(path.read_text(encoding='utf-8'))
    # Both the '@key' descriptions of the template and the '@@locale' stamp
    # are metadata, not messages.
    return {k for k in data if not k.startswith('@')}


def main() -> None:
    arb_dir = Path(__file__).resolve().parents[1] / 'lib' / 'l10n'
    template = keys(arb_dir / 'app_en.arb')
    failed = False
    for path in sorted(arb_dir.glob('app_*.arb')):
        if path.name == 'app_en.arb':
            continue
        other = keys(path)
        for key in sorted(template - other):
            print(f'{path.name}: missing "{key}"')
            failed = True
        for key in sorted(other - template):
            print(f'{path.name}: extra "{key}"')
            failed = True
    if failed:
        sys.exit(1)
    print(f'translations complete ({len(template)} keys per language)')


if __name__ == '__main__':
    main()
