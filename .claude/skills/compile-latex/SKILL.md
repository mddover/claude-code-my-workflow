---
name: compile-latex
description: Compile a LaTeX paper with XeLaTeX (3 passes + biber). Use when compiling papers or presentations.
argument-hint: "[path/to/file without .tex extension]"
allowed-tools: ["Read", "Bash", "Glob"]
---

# Compile LaTeX Paper

Compile a LaTeX document using XeLaTeX with full citation resolution via biber.

## Steps

1. **Navigate to the paper directory** and compile with 3-pass sequence:

```bash
cd Papers/project-name
TEXINPUTS=../../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode $ARGUMENTS.tex
biber $ARGUMENTS
TEXINPUTS=../../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode $ARGUMENTS.tex
TEXINPUTS=../../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode $ARGUMENTS.tex
```

**Alternative (latexmk):**
```bash
cd Papers/project-name
TEXINPUTS=../../Preambles:$TEXINPUTS latexmk -xelatex -interaction=nonstopmode $ARGUMENTS.tex
```

2. **Check for warnings:**
   - Grep output for `Overfull \\hbox` warnings
   - Grep for `undefined citations` or `Label(s) may have changed`
   - Report any issues found

3. **Open the PDF** for visual verification:
   ```bash
   open Papers/project-name/$ARGUMENTS.pdf   # macOS
   # xdg-open Papers/project-name/$ARGUMENTS.pdf  # Linux
   ```

4. **Report results:**
   - Compilation success/failure
   - Number of overfull hbox warnings
   - Any undefined citations
   - PDF page count

## Why 3 passes?
1. First xelatex: Creates `.aux` file with citation keys
2. biber: Reads `.aux` and `.bcf`, generates `.bbl` with formatted references
3. Second xelatex: Incorporates bibliography
4. Third xelatex: Resolves all cross-references with final page numbers

## Important
- **Always use XeLaTeX**, never pdflatex (required for `fontspec`)
- **Always use biber**, never bibtex (required for `biblatex` with `style=unified`)
- **TEXINPUTS** is required if shared preambles are in `Preambles/`
- If the file is not in `Papers/`, adjust the path accordingly
