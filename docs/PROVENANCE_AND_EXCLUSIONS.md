# Provenance and exclusions

## Source archive

This repository was curated from the supplied degree archive:

`LVTN-2430605-KDD24ANC-Nguyen Tien Khai.rar`

The repository is intentionally narrower than the original archive. Its purpose is computational reproducibility, not preservation of every administrative or publication file.

## Retained

- CPLEX `.mod` and relevant `.dat` model files.
- Canonical MATLAB `.m` source files and frozen `.mat` intermediates/results.
- Charger-allocation CSVs and method-comparison workbooks.
- Monte Carlo/SCF Excel workbooks.
- PowerWorld `.PWB` and `.pwd` files plus the comparison workbook.
- Editable algorithm flowchart and one retained reference visual.

## Intentionally excluded

- `Bai bao khoa hoc/` - journal manuscripts, copyright forms, checklists, and reviewer correspondence are publication-administration artifacts, not required for thesis computation.
- `Bao cao chuyen de 1/` and `Bao cao chuyen de 2/` - stage reports/slides are narrative progress records and duplicate material represented by the computational archive.
- `Ho so bao ve LVTS/` - defense minutes, correction forms, plagiarism documents, thesis DOCX/PDF, and administrative forms are excluded from the computational core.
- Monte Carlo PDF reports - excluded because the underlying Excel workbooks are retained and are the more useful reproducibility artifacts.
- CPLEX Eclipse/OPL workspace metadata (`.project`, `.oplproject`, `.settings/`) - excluded as machine/workspace configuration, not model logic.
- `Code Matlab/Thuat toan lai de xuat/` - excluded after confirming all same-named files are byte-identical to the retained canonical copies in `Code Matlab/Thuat toan HBIPSO-GR/`.

## Filename normalization

Several Vietnamese/space-heavy original filenames were renamed to stable ASCII repository paths. The exact original-to-repository mapping is recorded in `docs/SOURCE_FILE_MAP.csv`.
