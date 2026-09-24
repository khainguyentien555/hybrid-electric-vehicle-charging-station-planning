# Reproducibility guide

## Scope

This package preserves the executable source files and frozen computational artifacts supplied with the master's thesis. It supports traceability across stochastic demand inputs, optimization, charger allocation, MATLAB-to-CPLEX hybrid refinement, and PowerWorld grid assessment.

The thesis reports the following primary environment:

- MATLAB R2023b
- IBM ILOG CPLEX Optimization Studio 22.1.2
- PowerWorld Simulator 22 GSO
- Microsoft Excel

Because CPLEX and PowerWorld are commercial products and the original solver/stochastic runtime state is not fully containerized, GitHub Actions performs archival-integrity validation rather than full numerical solver reproduction.

## Recommended execution order

### 1. Demand / SCF inputs

Inspect the frozen workbooks in `data/monte_carlo/`:

- `scf_2030.xlsx`
- `scf_2035.xlsx`
- `scf_2040.xlsx`
- `max_demand_with_cf.xlsx`

These are retained as source data artifacts. The large PDF Monte Carlo reports from the original degree folder are intentionally excluded because they duplicate the workbook lineage and do not add executable content.

### 2. Exact Branch-and-Cut baseline

Open `cplex/branch_and_cut/EVCS_BranchandCut.mod` in IBM ILOG CPLEX Optimization Studio 22.1.2 (or a compatible environment) and solve the embedded-data model.

### 3. HBIPSO-GR workflow in MATLAB

Recommended order:

1. `matlab/hbipso_gr/Input_data_HBIPSO.m` - prepares/saves `evcs_data.mat`.
2. `matlab/hbipso_gr/Run_HBIPSO_EVCS.m` - launches the HBIPSO-GR workflow.
3. `matlab/hbipso_gr/hbipso_gr_evcs.m` - core HBIPSO-GR implementation.
4. `matlab/hbipso_gr/Split_Charger.m` and `post_split_chargers_by_type.m` - post-processing of charger counts/types.
5. visualisation helpers as needed.

Frozen reference artifacts are retained in `data/intermediate/` and `results/optimization/`.

### 4. MATLAB-to-CPLEX hybrid refinement

The bridge utilities are:

- `hbipso_to_cplex_hybrid.m`
- `hbipso2cplex_bridge.m`
- `export_evcs_to_opl_dat.m`
- `make_opl_dat_from_hbipso.m`
- `merge_dat_into_onefile_mod.m`
- `prep_evcs_from_cplex_embed.m`

The archive contains two non-identical `evcs_hybrid.dat` lineages. Both are preserved intentionally:

- `data/intermediate/evcs_hybrid_from_matlab.dat` - exported MATLAB-side artifact;
- `cplex/hybrid/evcs_hybrid.dat` - working data file stored with the CPLEX hybrid model.

Use `cplex/hybrid/Hybrid.mod` for the hybrid exact-refinement stage.

### 5. PowerWorld assessment

Open the binary cases with PowerWorld Simulator 22 GSO (or a compatible version):

- `powerworld/cases/without_ev.pwb`
- `powerworld/cases/with_ev.pwb`

Associated display files are in `powerworld/displays/`. The frozen comparative workbook is `results/powerworld/ev_powerworld_comparison.xlsx`.

The thesis describes Newton-Raphson power-flow assessment on the 22 kV distribution-network model.

## Archival validation

Run:

```bash
python python/validate_repository.py
```

The validator does not solve CPLEX, execute MATLAB, or run PowerWorld. It verifies repository structure, SHA-256 integrity, selected CSV shapes, and presence/readability of binary/reference artifacts.

## Reproducibility boundary

A full bit-for-bit numerical replay is not claimed across stochastic and commercial-solver stages. Solver versions, random state, numerical tolerances, and software configuration can affect a fresh execution. Frozen outputs are therefore preserved separately from source workflows so deviations can be diagnosed rather than silently overwritten.
