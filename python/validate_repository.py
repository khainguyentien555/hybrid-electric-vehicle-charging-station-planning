#!/usr/bin/env python3
from pathlib import Path
import hashlib, csv, sys, zipfile

ROOT = Path(__file__).resolve().parents[1]
errors = []

required = [
    'README.md','CITATION.cff','citation.bib','VERSION',
    'cplex/branch_and_cut/EVCS_BranchandCut.mod','cplex/hybrid/Hybrid.mod','cplex/hybrid/evcs_hybrid.dat',
    'matlab/hbipso_gr/Run_HBIPSO_EVCS.m','matlab/hbipso_gr/hbipso_gr_evcs.m','matlab/hbipso_gr/Input_data_HBIPSO.m',
    'data/monte_carlo/scf_2030.xlsx','data/monte_carlo/scf_2035.xlsx','data/monte_carlo/scf_2040.xlsx',
    'results/optimization/chargers_per_station.csv','results/optimization/chargers_by_type_per_station.csv',
    'powerworld/cases/with_ev.pwb','powerworld/cases/without_ev.pwb','powerworld/CASE_INDEX.csv',
    'checksums/REFERENCE_SHA256SUMS.txt'
]
for rel in required:
    p=ROOT/rel
    if not p.exists() or (p.is_file() and p.stat().st_size == 0):
        errors.append(f'MISSING/EMPTY: {rel}')

# SHA-256 manifest
manifest = ROOT/'checksums/REFERENCE_SHA256SUMS.txt'
if manifest.exists():
    for line_no,line in enumerate(manifest.read_text(encoding='utf-8').splitlines(),1):
        if not line.strip(): continue
        try:
            expected, rel = line.split('  ',1)
        except ValueError:
            errors.append(f'MANIFEST FORMAT line {line_no}: {line!r}')
            continue
        p=ROOT/rel
        if not p.is_file():
            errors.append(f'MANIFEST FILE MISSING: {rel}')
            continue
        actual=hashlib.sha256(p.read_bytes()).hexdigest()
        if actual != expected:
            errors.append(f'CHECKSUM MISMATCH: {rel}')

# CSV structural checks
csv_expect = {
    'results/optimization/chargers_per_station.csv': 2,
    'results/optimization/chargers_by_type_per_station.csv': 2,
    'powerworld/CASE_INDEX.csv': 3,
}
for rel,min_rows in csv_expect.items():
    p=ROOT/rel
    if p.is_file():
        try:
            rows=list(csv.reader(p.open(encoding='utf-8-sig',newline='')))
            if len(rows) < min_rows:
                errors.append(f'CSV TOO SHORT: {rel} ({len(rows)} rows)')
        except Exception as e:
            errors.append(f'CSV READ ERROR: {rel}: {e}')

# Office Open XML artifacts should be valid ZIP containers
for p in list((ROOT/'data').rglob('*.xlsx')) + list((ROOT/'results').rglob('*.xlsx')) + list((ROOT/'figures').rglob('*.pptx')):
    try:
        with zipfile.ZipFile(p) as z:
            names=set(z.namelist())
            if '[Content_Types].xml' not in names:
                errors.append(f'OOXML CONTENT TYPES MISSING: {p.relative_to(ROOT)}')
    except Exception as e:
        errors.append(f'OOXML READ ERROR: {p.relative_to(ROOT)}: {e}')

# Basic binary checks
for rel in ['powerworld/cases/with_ev.pwb','powerworld/cases/without_ev.pwb','data/intermediate/evcs_data.mat','results/optimization/hbipso_best.mat']:
    p=ROOT/rel
    if p.is_file() and p.stat().st_size < 64:
        errors.append(f'BINARY FILE SUSPICIOUSLY SMALL: {rel}')

if errors:
    print('ARCHIVAL VALIDATION: FAIL')
    for e in errors: print(' -', e)
    sys.exit(1)

print('ARCHIVAL VALIDATION: PASS')
print(' - required repository structure: PASS')
print(' - SHA-256 archival manifest: PASS')
print(' - CSV structural checks: PASS')
print(' - OOXML container checks: PASS')
print(' - binary/reference artifact presence: PASS')
