# Multiple-Cutoff RDiT on the Shanghai Stock Exchange

Independent empirical research code for my bachelor thesis, *Multiple Cutoffs
Regression Discontinuity in Time Analysis of Major Events Effects on the
Shanghai Stock Exchange*.

> **Repository-preparation status:** candidate for the public portfolio, but not
> yet cleared for release. Before publishing, confirm that the event-window
> convention in `new_reg1.do` is the intended submitted version; the thesis text
> and code appear to describe the pre/post windows in opposite order.

## Project idea

The project develops a rolling-window fixed-effects Regression Discontinuity in
Time workflow to identify potentially important market dates and then estimate
multi-cutoff effects. It studies the Shanghai Stock Exchange across a long panel
of listed securities and uses Stata for data construction, estimation, and
output generation.

## Public source files

- `new_main.do` — orchestration entry point for the empirical analysis
- `new_merger.do` — construction and merging of the research panel
- `new_reg1.do` — rolling-window event-date identification
- `new_reg2.do` — multi-treatment estimation
- `new_reg3.do` — higher-polynomial robustness analysis

Simulation scripts, intermediate datasets, generated tables and figures, local
IDE state, and archived code are deliberately excluded from the public
allowlist.

## Data availability

No raw or derived data are included. The research uses data obtained through
Wind Financial Terminal and CSMAR, whose licences do not permit treating the
files as ordinary open-source repository assets. The code is therefore shared
for methodological transparency, not as a one-command public replication
package.

The author's thesis PDF may be added under `paper/` only after confirming that
the submitted document is cleared for public distribution.

## Reproducibility note

Running the analysis requires Stata plus authorised access to the original data.
The scripts also reflect the research environment used for the submitted
project. No claim is made that a fresh clone can reproduce the paper without
those licensed inputs.

