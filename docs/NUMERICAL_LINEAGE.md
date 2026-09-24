# Numerical lineage

## Research workflow

The thesis integrates three computational layers:

1. **Demand estimation and charging simultaneity** - scenario workbooks provide year-specific SCF and maximum-demand inputs.
2. **Siting/sizing optimization** - an exact Branch-and-Cut model, HBIPSO-GR, and a hybrid workflow are compared.
3. **Grid-impact assessment** - selected EV charging loads are injected into the PowerWorld distribution-network model for with-EV / without-EV comparison.

## Canonical source choices in this repository

The original archive contains a second folder named `Code Matlab/Thuat toan lai de xuat/`. Every file in that folder has been SHA-256 compared with the same-named file in `Code Matlab/Thuat toan HBIPSO-GR/` and is byte-identical. The duplicated folder is therefore not redistributed; the HBIPSO-GR copy is retained as the canonical source.

The two supplied `evcs_hybrid.dat` files are **not** byte-identical. Both are retained under distinct paths because they represent separate MATLAB-export and CPLEX-working lineages.

## Frozen outputs versus regenerated outputs

Files in `results/` and `data/intermediate/` are frozen artifacts supplied in the original thesis archive. A fresh solver run should write to a separate working directory where practical; do not overwrite frozen artifacts merely to force agreement.

If regenerated values differ materially, inspect software version, random state, solver settings/tolerances, input lineage, and post-processing order before changing the archival baseline.
