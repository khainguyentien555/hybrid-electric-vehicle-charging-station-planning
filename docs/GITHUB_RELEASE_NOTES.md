# GitHub release notes - v1.0.0

## Integrated EV Charging Infrastructure Planning - Master's Thesis Reproducibility Package

Initial public archival release of the computational package supporting the master's thesis:

**Tien-Khai Nguyen**, “Research on Electric Vehicle Charging Infrastructure Planning in Urban Areas,” Master's thesis, Ho Chi Minh City University of Technology and Education, Ho Chi Minh City, Vietnam, 2026.

### Included

- IBM ILOG CPLEX Branch-and-Cut baseline model
- HBIPSO-GR MATLAB source and frozen results
- MATLAB-to-CPLEX hybrid refinement workflow
- 2030/2035/2040 SCF and demand workbooks
- PowerWorld with-EV and without-EV cases
- Optimization and grid-comparison result files
- Numerical-lineage and method-to-code documentation
- SHA-256 archival manifest
- Automated GitHub Actions integrity validation

### Reproducibility boundary

This release preserves and validates the archival computational materials. GitHub Actions do not execute the commercial CPLEX or PowerWorld solvers and do not claim a full solver replay. See `docs/REPRODUCIBILITY.md`.

### Version

**v1.0.0 - Initial public archival release**
