# Proofreading Report: `Papers/symbiotic-gaps/main.tex`

**Paper:** The Acceptability of Symbiotic Gaps
**Date:** 2026-03-12
**Reviewer:** Proofreading Agent

---

## Issue 1: Typo -- "items sets" should be "item sets"
- **Location:** Line 334, Section 3.3 (Materials and procedure)
- **Current:** `"Twenty-four items sets were constructed"`
- **Proposed:** `"Twenty-four item sets were constructed"`
- **Category:** Typo
- **Severity:** High

## Issue 2: `\pex` used for single-example block (introduction)
- **Location:** Lines 26--28, Section 1 (Introduction)
- **Current:** `\pex\label{intro-pg}` / `\a\label{intro-pg-a} Which articles...` / `\xe`
- **Proposed:** Use `\ex` ... `\xe` instead of `\pex`/`\a`/`\xe` to avoid an unnecessary "(a)" sub-label for a single example.
- **Category:** Examples
- **Severity:** Medium

## Issue 3: `\pex` used for single-item principles (NLFP and Subject Condition)
- **Location:** Lines 242--245 (NLFP) and lines 251--254 (Subject Condition)
- **Current:** Both use `\pex` with a single `\a` to display a named principle.
- **Proposed:** Consider using `\ex` ... `\xe` or a dedicated block environment. The current form prints "(a)" before the principle text.
- **Category:** Examples
- **Severity:** Low (may be intentional for indentation formatting)

## Issue 4: Orphaned label `intro-pg-a` (defined but never referenced)
- **Location:** Line 27
- **Current:** `\a\label{intro-pg-a}` is defined but no `\ref{intro-pg-a}` appears in the document.
- **Proposed:** Remove the label, or convert to `\ex`/`\xe` per Issue 2.
- **Category:** Examples
- **Severity:** Low

## Issue 5: Orphaned labels `bg-pg` and `bg-no-true-a`/`bg-no-true-b`
- **Location:** Line 48 (`\label{bg-pg}`), line 56 (`\label{bg-no-true-a}`), line 57 (`\label{bg-no-true-b}`)
- **Current:** `bg-pg` parent label is defined but text references only sub-labels `bg-pg-a` and `bg-pg-b`. Sub-labels `bg-no-true-a` and `bg-no-true-b` are defined but never individually referenced.
- **Proposed:** Remove unused labels.
- **Category:** Examples
- **Severity:** Low

## Issue 6: Missing abstract
- **Location:** Between `\maketitle` (line 16) and `\section{Introduction}` (line 22)
- **Current:** No `\begin{abstract}...\end{abstract}` block.
- **Proposed:** Add an abstract. Most journal and conference submissions require one.
- **Category:** Academic Quality
- **Severity:** High

## Issue 7: Spaces in `\includegraphics` file paths
- **Location:** Lines 346, 353, 455, 462, 469
- **Current:** File paths contain spaces, e.g., `{Experiment 1/Symbiotic Gaps 2x2 - Mean Acceptability...}`
- **Proposed:** Rename files/directories to eliminate spaces, or ensure `grffile` package is loaded. Spaces can cause compilation failures on some systems.
- **Category:** Compilation risk
- **Severity:** Medium

## Issue 8: Processing difficulty claim could benefit from citation
- **Location:** Line 551, Section 5.1 (The role of the matrix gap)
- **Current:** Claim about tracking three gap-filler dependencies as a processing burden lacks supporting citation.
- **Proposed:** Consider citing relevant processing literature (e.g., Gibson 2000, Wagers & Phillips 2009).
- **Category:** Academic Quality
- **Severity:** Low

## Issue 9: Judgment markers use raw `*`/`??` instead of `\ljudge{}`
- **Location:** Lines 56, 57, 68, 69 (examples in Section 2)
- **Current:** `*Which articles...` and `??What kinds of books...` use raw characters.
- **Proposed:** Use `\ljudge{*}` and `\ljudge{??}` for consistent formatting per project conventions in CLAUDE.md.
- **Category:** Consistency
- **Severity:** Low

## Issue 10: Potential overfull hbox in Table 2 pairwise comparisons
- **Location:** Lines 500--522 (Table `tab:exp2-pairwise`)
- **Current:** Long contrast labels in a 5-column table.
- **Proposed:** Verify during compilation. If overfull, use `\small` or abbreviate condition names.
- **Category:** Overflow
- **Severity:** Low

## Issue 11: Section "General discussion" inconsistent capitalization
- **Location:** Line 545
- **Current:** `\section{General discussion}`
- **Proposed:** `\section{General Discussion}` for consistency with other section titles.
- **Category:** Consistency
- **Severity:** Low

## Issue 12: Subsections in Section 5 lack labels
- **Location:** Lines 549 and 553
- **Current:** No `\label{}` on these subsections.
- **Proposed:** Add labels for potential future cross-referencing.
- **Category:** Consistency
- **Severity:** Low

---

## Summary

| Severity | Count |
|----------|-------|
| High     | 2     |
| Medium   | 2     |
| Low      | 8     |
| **Total**| **12**|

### Overall Assessment

The paper is well-written with consistent notation, proper citation practices, no em-dashes, no contractions, and no duplicated words. The theoretical argumentation is clear and well-structured, and the experimental sections are thorough.

**Priority fixes:** The typo "items sets" (Issue 1) and the missing abstract (Issue 6) should be addressed before submission.
