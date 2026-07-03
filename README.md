# R, AI, and Reproductive Policy

This repository is a small student textbook for learning R, reproducible social science, and careful AI-assisted research.

The core project asks students to replicate Walker et al. (2023), "Anticipatory impacts of the repeal of Roe v. Wade on female college applicants," and then extend the design with Title IX pregnancy and parenting policy information from The Pregnant Scholar policy directory.

## What students build

- A cleaned Common Data Set applicant panel for 2018-2022.
- An event-study/difference-in-differences replication of the Walker paper.
- A reproducible extension that merges campus Title IX pregnancy/parenting policy indicators.
- A short audit trail showing how AI was used, checked, and corrected.

The repository includes toy data so the R scripts run immediately. The toy data are not the Walker data and should not be used as evidence. Students replace them with their collected CDS panel in `data-raw/walker_cds_applicants.csv`.

## Quick start

```r
install.packages(c(
  "readr", "dplyr", "tidyr", "stringr", "ggplot2",
  "fixest", "broom", "rvest", "xml2", "purrr", "scales"
))
source("R/run_replication_template.R")
source("R/merge_title_ix_extension.R")
```

## Render the textbook

This is a Quarto book. If Quarto is installed locally:

```bash
quarto render
```

If Quarto is not installed locally, push the repository to GitHub and the included workflow will render and publish the book with GitHub Pages.

## Put it on GitHub

From this folder:

```bash
git init
git add .
git commit -m "Initial R AI Title IX textbook"
git branch -M main
git remote add origin https://github.com/YOUR-USER/YOUR-REPO.git
git push -u origin main
```

Then open the repository on GitHub, go to Settings -> Pages, and choose GitHub Actions as the Pages source.

## License

Course text is licensed CC BY 4.0. Code is licensed MIT. See `LICENSE.md`.

