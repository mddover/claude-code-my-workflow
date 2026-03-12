---
paths:
  - "Papers/**/*.tex"
  - "R/**/*.R"
---

# Task Completion Verification Protocol

**At the end of EVERY task, Claude MUST verify the output works correctly.** This is non-negotiable.

## For LaTeX Papers:
1. Compile with xelatex (3-pass + biber) and check for errors
2. Check for overfull hbox warnings
3. Check for undefined citations
4. Verify PDF was generated with non-zero size

## For R Scripts:
1. Run `Rscript R/project-name/filename.R`
2. Verify output files (PDF, RDS, CSV) were created with non-zero size
3. Spot-check estimates for reasonable magnitude

## For TikZ/Forest Diagrams:
1. Compile the containing document to verify tree renders
2. If extracting to SVG: verify SVG contains valid XML/SVG markup
3. Check that tree node labels don't overlap

## For Bibliography:
- Check that all `\textcite` / `\parencite` / `\cite` references in modified files have entries in the .bib file

## Common Pitfalls:
- **Assuming success**: Always verify output files exist AND contain correct content
- **biber not bibtex**: This project uses `biblatex` with `biber` backend
- **TEXINPUTS**: Required when preambles are in `../../Preambles/`
- **expex cross-references**: Verify `\getfullref` targets exist

## Verification Checklist:
```
[ ] Output file created successfully
[ ] No compilation/render errors
[ ] Images/figures display correctly
[ ] All citations resolve
[ ] Reported results to user
```
