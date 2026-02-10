# reichlab-analyses

Small, self-contained analyses related to Reich Lab research. Each analysis lives in its own subdirectory with scripts and outputs together.

## Structure

```
reichlab-analyses/
  analysis-name/          # one directory per analysis
    script.R              # reproducible script(s)
    plots/                # output figures
    data/                 # any generated or small input data
  another-analysis/
    ...
```

## Formats

- **Scripts** (`.R`, `.py`) are the default for straightforward analyses.
- **Notebooks** (`.qmd`, `.Rmd`, `.ipynb`) are encouraged for more complex analyses where narrative context, step-by-step explanation, and inline results help tell the story. Notebooks are especially useful when an analysis builds up intuition incrementally or compares multiple approaches.

## Conventions

- **One directory per analysis.** Scripts and their outputs live together.
- **Run from the repo root.** All scripts assume the working directory is the repo root, not the analysis subdirectory. For example: `Rscript variogram-score-demo/variogram_score_demo.R`
- **Fully reproducible.** Each script should run start-to-finish without manual intervention. Any data dependencies should be documented in the script header or fetched by the script itself.
- **Descriptive directory names.** Use kebab-case. The directory name is the primary documentation of what the analysis is about. No date prefix unless the analysis is inherently tied to a specific date.
- **Script header comments** serve as documentation. No separate README needed per analysis unless the analysis is complex enough to warrant it.

## Analyses

| Directory | Description |
|-----------|-------------|
| `variogram-score-demo/` | Demonstrates how the variogram score evaluates pairwise differences across locations, contrasting it with MAE |
