#!/usr/bin/env python3
"""Verify the distributable excludes private inputs and remains self-contained."""
import json
from pathlib import Path, PurePosixPath
import sys
import tarfile

archive = Path(sys.argv[1] if len(sys.argv) > 1 else 'whmcs-mcp-sql-1.0.0.tgz')
manifest = json.loads((Path(__file__).resolve().parent.parent / 'package.json').read_text())
allowed_roots = {'package.json', *(PurePosixPath(name).parts[0] for name in manifest['files'])}
with tarfile.open(archive) as handle:
    names = handle.getnames()
    for name in names:
        path = PurePosixPath(name)
        assert not path.is_absolute() and '..' not in path.parts, name
        assert len(path.parts) >= 2 and path.parts[0] == 'package', name
        assert path.parts[1] in allowed_roots, name
        assert not any(part in {'.git', '.idea', '.vscode', '__pycache__', 'node_modules'} for part in path.parts), name
        assert not path.name.startswith('.env') or path.name == '.env.example', name
        assert not name.endswith('.sql') or name == 'package/test/fixture-schema.sql', name
    for required in [
        'package/src/index.ts', 'package/dist/index.js', 'package/npm-shrinkwrap.json',
        'package/tsconfig.json', 'package/test/fixture-schema.sql', 'package/.dockerignore',
        'package/docs/client-connections.md', 'package/Dockerfile', 'package/compose.yaml',
    ]:
        assert required in names, required
print(json.dumps({'archive': str(archive), 'files': len(names), 'bytes': archive.stat().st_size, 'privateInputsExcluded': True}))
