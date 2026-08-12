# Replication Text

This repository is a small online text of replication exercises for advanced undergraduates. Undergraduate econometrics is recommended but not required.

Each exercise is short and self-contained, living under `exercises/<NN-name>/` with its own data, R scripts, and write-up. The workflow for each one: do the replication first, then write it up.

The first version has:

1. Introduction (`chapters/01-introduction.qmd`)
2. Exercise 1: Walker (`exercises/01-walker/`) - replicate Walker et al. (2023), "Anticipatory impacts of the repeal of Roe v. Wade on female college applicants," then extend the design with Title IX pregnancy and parenting policy information from The Pregnant Scholar policy directory.

Exercise 1 is currently an empty shell (`exercises/01-walker/data/`, `data-raw/`, `R/`, `results/`) waiting on the replication itself.

## Quick start

```r
install.packages(c(
  "readr", "dplyr", "tidyr", "stringr", "ggplot2",
  "fixest", "broom", "rvest", "xml2", "purrr", "scales"
))
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

## Notes for instructors

The rendered book currently uses `index.qmd`, `chapters/01-introduction.qmd`, and `exercises/01-walker/exercise.qmd`.

To add a new exercise, create `exercises/<NN-name>/` with its own `data/`, `data-raw/`, `R/`, `results/`, and an `exercise.qmd`, then add that `exercise.qmd` to the `chapters` list in `_quarto.yml`.

## License

Course text is licensed CC BY 4.0. Code is licensed MIT. See `LICENSE.md`.
