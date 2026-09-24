# Integrated EV Charging Infrastructure Planning — Master's Thesis Reproducibility Package

## Thesis

**Research on Electric Vehicle Charging Infrastructure Planning in Urban Areas**  
**Author:** Tien-Khai Nguyen  
**Institution:** Ho Chi Minh City University of Technology and Engineering (HCMUTE), Ho Chi Minh City, Vietnam  
**Year:** 2026


[![Archival Integrity Validation](https://github.com/khainguyentien555/evcs-optimization-master-thesis/actions/workflows/validate.yml/badge.svg)](https://github.com/khainguyentien555/evcs-optimization-master-thesis/actions/workflows/validate.yml)

**Code, data, optimization models, numerical results, and PowerWorld cases supporting the computational workflow of the master's thesis.**

**Associated thesis:**  
Tien-Khai Nguyen, **“Research on Electric Vehicle Charging Infrastructure Planning in Urban Areas”** (*Planning of Electric Vehicle Charging Station Infrastructure in Urban Areas*), Master's thesis in Electrical Engineering, Ho Chi Minh City University of Technology and Engineering, Ho Chi Minh City, Vietnam, 2026.

## What this repository reproduces

This repository preserves the computational lineage used in the thesis from demand/scenario inputs through EV charging-station planning and grid-impact assessment. The released material supports technical inspection of four linked layers:

1. EV charging-demand and simultaneous-charging-factor (SCF) inputs;
2. an exact Branch-and-Cut baseline formulated in IBM ILOG CPLEX;
3. HBIPSO-GR and the MATLAB-to-CPLEX hybrid refinement workflow; and
4. PowerWorld comparison of the distribution network with and without EV charging load.

The thesis applies the framework to Phu Quoc over a 2030-2040 planning horizon.

## Computational lineage

```text
Monte Carlo / EV-demand assumptions
                |
                v
      Branch-and-Cut baseline
                |
                +-------------------+
                |                   |
                v                   v
           HBIPSO-GR       MATLAB -> CPLEX bridge
                |                   |
                +---------> Hybrid refinement
                                |
                                v
                    charger/station allocation
                                |
                                v
                    PowerWorld grid assessment
                                |
                                v
                     comparative result files
```

## Repository layout

```text
.
├── cplex/
│   ├── branch_and_cut/          # exact MOMIP baseline
│   └── hybrid/                  # hybrid refinement model and working .dat
├── matlab/
│   └── hbipso_gr/               # HBIPSO-GR, charger split, CPLEX bridge, visualisation
├── data/
│   ├── monte_carlo/             # 2030/2035/2040 SCF and maximum-demand workbooks
│   └── intermediate/            # MATLAB intermediate artifacts
├── results/
│   ├── optimization/            # charger allocations and three-method comparison
│   └── powerworld/              # with-EV / without-EV comparison workbook
├── powerworld/
│   ├── cases/                   # binary PowerWorld cases
│   ├── displays/                # PowerWorld display files
│   └── CASE_INDEX.csv
├── figures/
│   ├── source/                  # editable algorithm flowchart
│   └── reference/               # retained reference visual
├── docs/                        # reproduction, lineage, mapping, provenance
├── checksums/                   # SHA-256 integrity manifest and file inventory
├── python/                      # lightweight repository/integrity validator
└── .github/workflows/           # GitHub Actions validation and checksum generation
```

## Software environment documented in the thesis

The thesis reports the following primary computational tools:

- **MATLAB R2023b** for HBIPSO-GR and supporting scripts;
- **IBM ILOG CPLEX Optimization Studio 22.1.2** for the Branch-and-Cut and hybrid exact-refinement models;
- **PowerWorld Simulator 22 GSO** for distribution-network power-flow assessment; and
- Microsoft Excel for data preparation and result tabulation.

The CPLEX and PowerWorld components require their respective commercial software/licenses. The GitHub Actions workflow therefore performs **archival integrity and structural validation**, not a full solver replay.

## Quick integrity check

The included Python validator uses only the Python standard library:

```bash
python python/validate_repository.py
```

A successful check ends with:

```text
ARCHIVAL VALIDATION: PASS
```

This verifies the expected repository structure, checks the frozen SHA-256 manifest, confirms key CSV shapes, and checks that the released Office/MAT/PowerWorld artifacts are present and non-empty.

## Full computational reproduction

See [`docs/REPRODUCIBILITY.md`](docs/REPRODUCIBILITY.md) for the recommended manual execution order. In summary:

1. inspect the frozen Monte Carlo/SCF inputs in `data/monte_carlo/`;
2. run the CPLEX Branch-and-Cut baseline in `cplex/branch_and_cut/`;
3. prepare MATLAB inputs with `Input_data_HBIPSO.m` and run `Run_HBIPSO_EVCS.m`;
4. use the charger-splitting and MATLAB-to-CPLEX bridge utilities for the hybrid workflow;
5. solve/refine the hybrid model in CPLEX; and
6. inspect/solve the PowerWorld with-EV and without-EV cases and compare against the released workbook.

Exact numerical replay can depend on solver version, stochastic seed/state, and commercial-software configuration. The repository therefore distinguishes **frozen archival artifacts** from **executable source workflows**.

## Reproducibility boundary

This repository is a curated computational archive, not a dump of the complete degree folder. It intentionally excludes:

- thesis defense/administrative records;
- plagiarism-check reports;
- journal submission packages, copyright forms, and reviewer correspondence;
- stage-report DOCX/PDF/PPTX files;
- large Monte Carlo PDF reports that duplicate released workbook data; and
- duplicate MATLAB files whose byte content is identical to the canonical copies retained here.

See [`docs/PROVENANCE_AND_EXCLUSIONS.md`](docs/PROVENANCE_AND_EXCLUSIONS.md).

## Citation

Please cite the associated thesis when using this repository's computational materials:

> T.-K. Nguyen, “Research on Electric Vehicle Charging Infrastructure Planning in Urban Areas,” Master's thesis, Ho Chi Minh City University of Technology and Engineering, Ho Chi Minh City, Vietnam, 2026.

Machine-readable metadata are provided in [`CITATION.cff`](CITATION.cff) and [`citation.bib`](citation.bib).

## License status

No repository-wide open-source or open-data reuse license is granted at this release. See [`LICENSE_NOTICE.md`](LICENSE_NOTICE.md).

## Version

Current archival release: **v1.0.0**.
