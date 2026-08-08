# Multiple-Cutoff RDiT on the Shanghai Stock Exchange

This repository contains the Stata workflow for my NYU bachelor’s thesis on how
major events affected Shanghai Stock Exchange securities. The public scripts
comprise more than 1,200 lines of Stata code and form part of a wider analysis
of approximately 0.5 GB of licensed daily market data.

## Research question and design

The project develops a rolling-window fixed-effects Regression Discontinuity in
Time workflow to identify potentially important market dates and then estimate
multi-cutoff effects. It studies the Shanghai Stock Exchange across a long panel
of listed securities and uses Stata for data construction, estimation and
output generation.

## Public source files

- `new_main.do` — orchestration entry point for the empirical analysis
- `new_merger.do` — construction and merging of the research panel
- `new_reg1.do` — rolling-window event-date identification
- `new_reg2.do` — multi-treatment estimation
- `new_reg3.do` — higher-polynomial robustness analysis

## Main findings

- Monte Carlo simulations recovered the underlying discontinuities close to
  their specified effects, while distant false positives were generally
  economically small.
- Single-treatment and multi-treatment estimates frequently differed
  materially, indicating that isolated event analysis can absorb the effects
  of neighbouring events.
- The procedure identified seven relevant dates during 2020—the highest number
  in the periods examined—with the initial COVID-19 shock followed by a
  substantial market rebound.

## Data and replication

The underlying Wind and CSMAR market data cannot be redistributed. Running the
analysis requires Stata and authorised access to those source datasets.
