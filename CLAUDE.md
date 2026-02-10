# Claude Instructions for reichlab-analyses

This repository contains small, self-contained analyses. Follow these rules when creating or modifying analyses.

## Directory Structure

- Each analysis gets its own subdirectory at the repo root using **kebab-case** naming (e.g., `variogram-score-demo/`, `forecast-comparison-by-horizon/`).
- Scripts, output plots, and any generated data all live inside the analysis subdirectory.
- Use a `plots/` subdirectory for figures and a `data/` subdirectory for generated or small input datasets, when applicable.
- Do NOT put loose files (scripts, PNGs, CSVs) at the repo root. The repo root should only contain this file, README.md, .gitignore, and analysis subdirectories.

## Working Directory

- **The repo root is always the working directory.** All scripts must be runnable from the repo root.
- Output paths in scripts should be relative to the repo root, e.g., `"analysis-name/plots/figure.png"`, not `"plots/figure.png"`.
- Run commands: `Rscript analysis-name/script.R` or `python analysis-name/script.py`

## Reproducibility

- Every script must be **fully reproducible**: runnable start-to-finish without manual intervention.
- List required packages at the top of each script via `library()` calls (R) or imports (Python).
- If a script depends on external data, it should either fetch it programmatically or document exactly where to obtain it in the script header.
- Do NOT depend on objects or state from other analyses. Each analysis is self-contained.

## Script Conventions

- Begin each script with a header comment block explaining:
  - What the analysis does (1-3 sentences)
  - Usage (the command to run it from the repo root)
  - Dependencies (required packages)
- Use relative paths from the repo root for all file I/O.
- Save outputs (plots, tables) into the analysis subdirectory, not to the console or clipboard.

## When Creating a New Analysis

1. Create a new subdirectory with a descriptive kebab-case name.
2. Write the script with a header comment, library calls, and repo-root-relative paths.
3. Run the script from the repo root to verify it works.
4. Add a row to the table in README.md describing the new analysis.

## Formats

- **Scripts** (`.R`, `.py`) are the default for straightforward analyses.
- **Notebooks** (`.qmd`, `.Rmd`, `.ipynb`) are encouraged for more complex analyses where narrative context helps tell the story. Use notebooks when an analysis builds up intuition incrementally, compares multiple approaches, or benefits from inline prose explaining the "why" alongside the code and results.
- When creating a notebook, it should still be fully reproducible (render/run start-to-finish without manual intervention).
- Rendered notebook output (`.html`) may be committed alongside the source if useful for sharing, but is not required.

## Languages

- R and Python are both fine. Use whichever is more natural for the analysis.
- For R, prefer ggplot2 for plots.
- For Python, prefer matplotlib or plotnine.
