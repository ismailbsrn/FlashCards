#!/usr/bin/env python3
"""
Add SPDX short license headers to source files that do not already contain one.
Usage: python tools/add_spdx_headers.py
"""
import os
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
EXCLUDE_DIRS = {
    'build', '.dart_tool', '.pub', 'Pods', 'node_modules', 'ios/Pods', 'android/.gradle', 'build', 'Generated.xcconfig'
}
EXCLUDE_SUFFIXES = {'.g.dart', '.pb.dart', '.template', '.png', '.jpg', '.jpeg', '.gif', '.lock', '.iml'}

PREFIX_MAP = {
    # line comment style
    '.dart': '// ',
    '.kt': '// ', '.kts': '// ', '.java': '// ', '.groovy': '// ', '.js': '// ', '.ts': '// ', '.tsx': '// ', '.jsx': '// ', '.swift': '// ', '.c': '// ', '.cpp': '// ', '.h': '// ', '.m': '// ', '.mm': '// ', '.cs': '// ',
    '.py': '# ', '.sh': '# ', '.bash': '# ', '.zsh': '# ', '.yml': '# ', '.yaml': '# ', '.ini': '# ', '.toml': '# ',
    '.html': '<!-- ', '.xml': '<!-- ', '.xsd': '<!-- ', '.plist': '<!-- ',
}

HEADER_LINES = [
    'SPDX-License-Identifier: MIT',
    'Copyright (c) 2026 Ismail Basaran'
]

def should_skip(path: Path) -> bool:
    if any(part in EXCLUDE_DIRS for part in path.parts):
        return True
    if path.suffix in EXCLUDE_SUFFIXES:
        return True
    if path.name.startswith('.'):
        return True
    if not path.is_file():
        return True
    # skip large binary files
    try:
        if path.stat().st_size > 5_000_000:
            return True
    except Exception:
        pass
    return False


def build_header(prefix: str, suffix: str) -> str:
    if prefix.strip().startswith('<!--'):
        # html style: wrap in a single comment with leading and trailing markers
        inner = '\n'.join(HEADER_LINES)
        return f'<!-- {inner} -->\n\n'
    else:
        return ''.join(prefix + line + '\n' for line in HEADER_LINES) + '\n'


def file_has_spdx(path: Path) -> bool:
    try:
        with path.open('r', encoding='utf-8') as f:
            for _ in range(50):
                line = f.readline()
                if not line:
                    break
                if 'SPDX-License-Identifier' in line:
                    return True
    except Exception:
        return True  # if we can't read, skip
    return False


def main():
    modified = []
    for path in ROOT.rglob('*'):
        if should_skip(path):
            continue
        ext = path.suffix.lower()
        prefix = PREFIX_MAP.get(ext)
        if not prefix:
            # unknown extension — skip
            continue
        if file_has_spdx(path):
            continue
        # read and write file
        try:
            text = path.read_text(encoding='utf-8')
        except Exception:
            continue
        header = build_header(prefix, ext)
        # preserve shebang if present
        if text.startswith('#!'):
            first_line, rest = text.split('\n', 1)
            new_text = first_line + '\n' + header + rest
        else:
            new_text = header + text
        try:
            path.write_text(new_text, encoding='utf-8')
            modified.append(str(path.relative_to(ROOT)))
        except Exception:
            continue
    print(f"Inserted SPDX headers into {len(modified)} files")
    if modified:
        print('\n'.join(modified))

if __name__ == '__main__':
    main()
