# Git Collaboration & Workflow Practice

Hands-on Git labs and scenario-based study material completed as part of the NextGen DevOps program, week 2. Covers everyday collaboration workflows (branching, merging, conflicts) through to advanced/production-grade Git practices (rebase, hotfixes, multiple remotes, tagging, and recovery).

---

## Contents

### [Lab_Work.md](./Lab_Work.md)

Step-by-step walkthrough of two hands-on labs, each with terminal commands and screenshots.

#### Lab 1 — Branching, Merging & Conflict Resolution

- Initialize a repo and create a homepage file
- Develop a navbar and a footer on separate branches (simulating two developers)
- Merge one branch cleanly, trigger a conflict on the other
- Resolve the conflict and push everything to GitHub

#### Lab 2 — Advanced Git & DevOps Workflow

- Feature development on a dedicated branch
- Emergency production hotfix branched from `main`
- Rebasing a feature branch onto `main`
- Stashing in-progress work to context-switch safely
- Configuring multiple remotes (GitHub + GitLab) and pushing to both
- Creating and pushing an annotated release tag (`v1.0`)
- Undoing a bad commit with `git reset --soft` (local) and `git revert` (already pushed)

### [Git Scenario-Based Questions.md](./Git%20Scenario-Based%20Questions.md)

15 real-world Git scenarios written up as interview/practice Q&A, covering:

- Merge conflicts, accidental commits to `main`, and rejected pushes
- Recovering deleted branches (`git reflog`, `git fsck`)
- Responding to leaked credentials (revoking keys, scrubbing history with `git filter-repo`/BFG)
- Rebase vs. merge tradeoffs, production hotfixes, and stashing
- CI/CD failure triage (`git bisect`, `git revert`), long-lived branch risks, detached HEAD, and protected `main` branches

Ends with a quick-reference table mapping each scenario to its key command.

### [NOTES.md](./NOTES.md)

Working notes and draft answers for the same set of Git scenarios — used to think through each problem before writing up the final, polished version in `Git Scenario-Based Questions.md`.

### [images/](./images/)

24 screenshots captured during the labs, showing terminal output for each step (branch creation, conflict markers, merges, stash, remotes, tagging) and the resulting state on GitHub.

---

## Key Topics Covered

- Branching & merging (fast-forward and conflicted)
- Conflict resolution and reading conflict markers
- Rebase vs. merge — when to use each safely
- `git stash` for context-switching
- Hotfix branching strategy for production issues
- Multiple remotes (GitHub + GitLab)
- Annotated tags and releases
- Undo strategies: `git reset --soft` vs `git revert`
- Recovering lost work: `git reflog`, `git fsck`
- Git security: handling exposed credentials and history scrubbing

---

## Author

Documenting my NextGen DevOps program learning journey, one Git workflow at a time.
