# Method-to-code map

| Thesis component | Repository source | Main artifacts |
|---|---|---|
| EV demand / SCF scenario inputs | `data/monte_carlo/` | 2030/2035/2040 SCF workbooks, maximum-demand workbook |
| Exact Branch-and-Cut benchmark | `cplex/branch_and_cut/EVCS_BranchandCut.mod` | CPLEX solution/output when rerun |
| HBIPSO-GR heuristic | `matlab/hbipso_gr/hbipso_gr_evcs.m`, `Run_HBIPSO_EVCS.m` | `hbipso_best.mat`, charger allocation CSVs |
| MATLAB input preparation | `matlab/hbipso_gr/Input_data_HBIPSO.m` | `evcs_data.mat` |
| Charger-type post-processing | `Split_Charger.m`, `post_split_chargers_by_type.m` | charger allocation tables |
| MATLAB-to-CPLEX hybrid bridge | `hbipso_to_cplex_hybrid.m`, `hbipso2cplex_bridge.m`, export/merge helpers | `evcs_hybrid_from_matlab.dat`, CPLEX working `.dat` |
| Hybrid exact refinement | `cplex/hybrid/Hybrid.mod` | refined station/charger solution when rerun |
| Three-method comparison | `results/optimization/three_method_comparison.xlsx` | B&C / HBIPSO-GR / Hybrid comparison |
| Distribution-network assessment | `powerworld/cases/` | with-EV and without-EV `.pwb` cases |
| PowerWorld comparison | `results/powerworld/ev_powerworld_comparison.xlsx` | frozen grid-comparison results |
| Method visualisation | `figures/source/algorithm_flowchart.pptx` | editable flowchart source |
