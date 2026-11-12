#!/usr/bin/env python3
"""Build a standard npm-format source/runtime archive from explicit owned paths."""
import gzip
import json
from pathlib import Path
import tarfile

root = Path(__file__).resolve().parent.parent
manifest = json.loads((root / 'package.json').read_text())
destination = root / f"{manifest['name']}-{manifest['version']}.tgz"

def normalize(info):
    name = info.name.removeprefix('package/')
    path = Path(name)
    if info.issym() or info.islnk():
        raise ValueError(f'Symlinks are not included: {name}')
    if path.name.startswith('.env') and path.name != '.env.example':
        return None
    if path.name == '.DS_Store' or '__pycache__' in path.parts:
        return None
    if name.endswith('.sql') and name != 'test/fixture-schema.sql':
        raise ValueError(f'Private SQL must not be packaged: {name}')
    info.uid = info.gid = 0
    info.uname = info.gname = ''
    info.mtime = 0
    return info

with destination.open('wb') as raw:
    with gzip.GzipFile(fileobj=raw, mode='wb', mtime=0, filename='') as compressed:
        with tarfile.open(fileobj=compressed, mode='w') as archive:
            for name in ['package.json', *manifest['files']]:
                archive.add(root / name, arcname='package/' + name, filter=normalize)
print(destination.name)
