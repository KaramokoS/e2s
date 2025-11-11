# -*- mode: python ; coding: utf-8 -*-
import sys
from pathlib import Path

block_cipher = None

project_dir = Path(__file__).parent

a = Analysis(
    ['run_qml.py'],
    pathex=[str(project_dir)],
    binaries=[],
    datas=[
        ('window.qml', '.'),                    # fichier QML principal
        ('*.qml', '.'),                         # tous les autres QML
        ('static/*', 'static'),                 # images et icônes
        ('ref_files/*', 'ref_files'),           # PDF de référence
        ('db/hospital.db', 'db'),               # base SQLite
        ('Colors.qml', '.'),                     # couleurs QML
    ],
    hiddenimports=['backend', 'database'],     # modules Python
    hookspath=[],
    runtime_hooks=[],
    excludes=[],
    win_no_prefer_redirects=False,
    win_private_assemblies=False,
    cipher=block_cipher,
)

pyz = PYZ(a.pure, a.zipped_data,
          cipher=block_cipher)

exe = EXE(
    pyz,
    a.scripts,
    [],
    exclude_binaries=True,
    name='E2SApp',
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    console=False
)

coll = COLLECT(
    exe,
    a.binaries,
    a.zipfiles,
    a.datas,
    strip=False,
    upx=True,
    name='E2SApp'
)
