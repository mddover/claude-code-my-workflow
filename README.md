# Linguistics Research Workflow

> A Claude Code workflow for syntax and psycholinguistics research — papers, statistical analysis, and presentations.

**Forked from:** [pedrohcgs/claude-code-my-workflow](https://github.com/pedrohcgs/claude-code-my-workflow)
**Adapted for:** Syntax & psycholinguistics research at Northwestern University

---

## What This Is

A structured Claude Code setup for managing linguistics research. You describe a task — write a paper section, run an analysis, review a manuscript — and Claude plans the approach, runs specialized review agents, fixes issues, verifies quality, and presents results. Based on the [academic workflow template](https://github.com/pedrohcgs/claude-code-my-workflow) by Pedro Sant'Anna.

---

## How It Works

### Contractor Mode

You describe a task. Claude plans the approach, implements it, runs specialized review agents, fixes issues, re-verifies, and scores against quality gates — all autonomously. You see a summary when the work meets quality standards (80/100 minimum).

### Specialized Agents

7 focused agents each check one dimension:

- **proofreader** — grammar, typos, `expex` example consistency
- **slide-auditor** — visual layout for Beamer presentations
- **pedagogy-reviewer** — teaching quality and narrative arc
- **r-reviewer** — R code quality, model specification, reproducibility
- **domain-reviewer** — syntax/psycholinguistics substance review
- **tikz-reviewer** — TikZ/forest diagram visual critique
- **verifier** — end-to-end compilation and output verification

### Quality Gates

Every file gets a score (0–100). Scores below threshold block the action:
- **80** — commit threshold
- **90** — PR threshold
- **95** — excellence (aspirational)

---

## Project Structure

```
linguistics-workflow/
├── CLAUDE.md                    # Project config (Claude reads this every session)
├── Bibliography/                # .bib files
├── Papers/                      # LaTeX papers, per-project subdirs
│   ├── anti-c-command/
│   ├── symbiotic-gaps/
│   └── pg-prediction-processing/
├── Presentations/               # PowerPoint files
├── Figures/                     # Shared figures
├── Preambles/                   # Shared LaTeX preambles
├── R/                           # Analysis scripts, per-project subdirs
├── Data/                        # Experimental data (gitignored)
├── scripts/                     # Utility scripts
├── explorations/                # Research sandbox
├── quality_reports/             # Plans, session logs
└── templates/                   # Document templates
```

---

## Tools & Conventions

| Tool | Use |
|------|-----|
| XeLaTeX + biber | Paper compilation (LSA Unified Style Sheet) |
| `expex` | Linguistic examples |
| `forest` | Syntactic trees |
| `ordinal` (R) | CLMMs for acceptability judgments |
| `lme4` (R) | Mixed-effects models for reading times |
| PCIbex | Experiment platform |
| PowerPoint | Presentations |

---

## Skills

| Skill | What It Does |
|-------|-------------|
| `/compile-latex` | 3-pass XeLaTeX + biber |
| `/extract-tikz` | TikZ/forest → PDF → SVG |
| `/proofread` | Grammar/typo/example review |
| `/visual-audit` | Slide layout audit |
| `/review-r` | R code quality review |
| `/validate-bib` | Cross-reference citations |
| `/lit-review` | Literature search + synthesis |
| `/review-paper` | Manuscript review |
| `/data-analysis` | End-to-end R analysis |
| `/commit` | Stage, commit, PR, merge |

---

## Prerequisites

| Tool | Required For | Install |
|------|-------------|---------|
| [Claude Code](https://code.claude.com/docs/en/overview) | Everything | `npm install -g @anthropic-ai/claude-code` |
| XeLaTeX | Paper compilation | [TeX Live](https://tug.org/texlive/) or [MacTeX](https://tug.org/mactex/) |
| R | Analysis | [r-project.org](https://www.r-project.org/) |
| pdf2svg | TikZ to SVG | `brew install pdf2svg` (macOS) |
| [gh CLI](https://cli.github.com/) | PR workflow | `brew install gh` (macOS) |

---

## Origin

Forked from [pedrohcgs/claude-code-my-workflow](https://github.com/pedrohcgs/claude-code-my-workflow), which was extracted from Econ 730 at Emory University. The core patterns (agents, rules, orchestrator, quality gates) are domain-agnostic. This fork adapts them for linguistics research: `expex` examples, `forest` trees, CLMMs, maze task analysis, and LSA-style bibliography.

---

## License

MIT License. See [LICENSE](LICENSE).
