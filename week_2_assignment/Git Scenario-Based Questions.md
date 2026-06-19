# Git Scenario-Based Assignment
### Intermediate → Advanced

---

## Table of Contents

1. [Merge Conflict Scenario](#1-merge-conflict-scenario)
2. [Accidental Commit to Main](#2-accidental-commit-to-main)
3. [Remote Push Rejected](#3-remote-push-rejected)
4. [Deleted Branch Recovery](#4-deleted-branch-recovery)
5. [Sensitive Credentials Exposure](#5-sensitive-credentials-exposure)
6. [Rebase vs Merge Decision](#6-rebase-vs-merge-decision)
7. [Emergency Production Hotfix](#7-emergency-production-hotfix)
8. [Working Directory Interruption](#8-working-directory-interruption)
9. [Wrong Commit Message](#9-wrong-commit-message)
10. [Local Branch Behind Main](#10-local-branch-behind-main)
11. [Multiple Remote Repositories](#11-multiple-remote-repositories)
12. [CI/CD Deployment Failure](#12-cicd-deployment-failure)
13. [Large Feature Development](#13-large-feature-development)
14. [Detached HEAD Situation](#14-detached-head-situation)
15. [Protected Main Branch](#15-protected-main-branch)

---

## 1. Merge Conflict Scenario

> **Scenario:** Two developers edited the same section of `app.py` in different branches. During merge, Git reports a conflict.

### Why Did the Conflict Happen?

A merge conflict occurs when Git **cannot automatically determine** which version of the code should be kept. This happens when two developers modify the same lines — or nearby lines — in the same file on separate branches. Since Git cannot safely assume which change is correct, it halts the merge and requires manual resolution.

**Example — Developer A's branch:**
```python
def login():
    authenticate_user()
```

**Example — Developer B's branch:**
```python
def login():
    validate_credentials()
```

Git sees two different versions of the same function and cannot decide which one to keep without human input.

---

### How to Resolve It Safely

**Step 1:** Run the merge command.
```bash
git merge feature-branch
```

**Step 2:** Open the conflicted file and locate the conflict markers:
```python
<<<<<<< HEAD
authenticate_user()
=======
validate_credentials()
>>>>>>> feature-branch
```

**Step 3:** Analyze both changes and decide:
- Should one replace the other entirely?
- Should both be combined into a single, correct implementation?

**Example resolution combining both:**
```python
def login():
    validate_credentials()
    authenticate_user()
```

**Step 4:** Remove all conflict markers (`<<<<<<<`, `=======`, `>>>>>>>`).

**Step 5:** Test the application thoroughly.

**Step 6:** Stage and commit the resolution:
```bash
git add app.py
git commit
```

> **Key Principle:** Never resolve conflicts blindly. Always understand the *business logic* behind both changes before making a decision. When in doubt, discuss with the other developer.

---

## 2. Accidental Commit to Main

> **Scenario:** You accidentally committed unfinished code directly to `main` instead of a feature branch.

### How to Move the Work to a New Branch Safely

**Step 1:** Create a new branch at the current HEAD (which includes your accidental commit):
```bash
git checkout -b feature/login-improvements
```

The commit now exists safely on the new branch.

**Step 2:** Switch back to `main`:
```bash
git checkout main
```

**Step 3:** Remove the accidental commit from `main`:
```bash
git reset --hard HEAD~1
```

> **Important:** `HEAD~1` removes the last commit. If you accidentally made multiple commits, adjust the number accordingly (e.g., `HEAD~3` removes the last 3 commits).

**If the commit was already pushed to the remote**, do NOT use `git reset`. Use `git revert` instead to avoid rewriting shared history:
```bash
git revert <commit-id>
```

### Why Is This the Safer Approach?

| Action | Outcome |
|--------|---------|
| Create feature branch first | Preserves your work |
| `git reset` on local main | Cleanly removes the accidental commit |
| `git revert` on pushed main | Creates a new "undo" commit — safe for shared history |
| Test before continuing | Ensures main is stable |

---

## 3. Remote Push Rejected

> **Scenario:** You run `git push origin main` and Git responds: `rejected because remote contains work you do not have locally`.

### Why Did This Happen?

The remote repository has **new commits** that your local copy does not have. Git refuses to push because doing so would overwrite those commits and destroy a teammate's work.

**Visual representation:**

```
Remote main:   A → B → C
Local main:    A → B → D
```

When you try to push `D`, Git sees that `C` exists on the remote but not locally, and rejects the push.

---

### What You Should Do

**Option 1 — Standard pull (creates a merge commit):**
```bash
git pull origin main
# Resolve any conflicts if they arise
git push origin main
```

**Option 2 — Rebase pull (cleaner, linear history):**
```bash
git pull --rebase origin main
# Resolve any conflicts if they arise
git push origin main
```

> **Never use `git push --force`** on shared branches. This overwrites remote history and deletes your teammates' commits. Force push is only acceptable on personal/feature branches that no one else is using.

---

## 4. Deleted Branch Recovery

> **Scenario:** A teammate deleted a feature branch after merging, but later realized important work is missing.

### Can the Commits Still Be Recovered?

**Yes — in most cases.** Deleting a branch only removes the *branch pointer*, not the underlying commits. Git retains unreachable commits until **garbage collection** runs (which may take days or weeks). Acting quickly improves your chances of recovery.

---

### Tools for Recovery

#### `git reflog` — Most Effective Tool
Reflog records every movement of `HEAD`, even across deleted branches:
```bash
git reflog
```

**Sample output:**
```
abc123 HEAD@{2}: commit: Added payment API integration
def456 HEAD@{3}: checkout: moving from main to feature-payment
```

Once you find the commit hash, recover it:
```bash
git checkout abc123
git checkout -b recovered-payment-feature
```

#### `git log --all --graph`
Shows all commits, including those on deleted branches (if not yet garbage collected):
```bash
git log --all --graph --oneline
```

#### `git fsck --lost-found`
Identifies "dangling" (orphaned) commits:
```bash
git fsck --lost-found
```

Recovered objects appear in `.git/lost-found/commit/`.

> **Best Practice:** Before deleting a branch, always verify the merge was successful and all work is accounted for.

---

## 5. Sensitive Credentials Exposure

> **Scenario:** A developer accidentally pushed AWS keys into a public GitHub repository.

### Immediate Actions to Take

This is a **security incident** — treat it urgently:

1. **Revoke the exposed keys immediately** via the AWS IAM console
2. **Generate new credentials** and update all services that use them
3. **Audit AWS CloudTrail logs** for any unauthorized activity since the commit was pushed
4. **Notify the security team** and document the incident
5. **Remove the secrets from Git history** (see below)
6. **Update CI/CD pipelines** that reference the compromised credentials

---

### Why Deleting the File Is Not Enough

Even after running:
```bash
git rm secrets.txt
git commit -m "Remove credentials"
git push
```

...the secrets **still exist in Git history**. Anyone can retrieve them using:
```bash
git checkout <old-commit-id>
cat secrets.txt
```

Or by cloning the repository and browsing history.

---

### How to Remove Secrets from History

**Using `git filter-repo` (recommended):**
```bash
pip install git-filter-repo
git filter-repo --path secrets.txt --invert-paths
```

**Using BFG Repo Cleaner:**
```bash
java -jar bfg.jar --delete-files secrets.txt
git reflog expire --expire=now --all
git gc --prune=now --aggressive
git push --force
```

> **Prevention:** Use tools like **AWS Secrets Manager**, **HashiCorp Vault**, or **dotenv files** (added to `.gitignore`) to manage credentials. GitHub's secret scanning feature can alert you before secrets are ever made public.

---

## 6. Rebase vs Merge Decision

> **Scenario:** Your team wants a clean, linear Git history with fewer merge commits.

### Recommendation: Rebase

For a clean, linear history, **rebase** is the appropriate strategy.

**Before rebase:**
```
main:    A → B → C
                  \
feature:           D → E
```

**After rebase:**
```
main:    A → B → C → D → E
```

The feature branch commits (`D`, `E`) are replayed on top of the latest `main`, creating a linear history with no merge commits.

---

### Rebase vs Merge Comparison

| Aspect | `git merge` | `git rebase` |
|--------|-------------|--------------|
| History | Preserves full branching history | Creates clean, linear history |
| Merge commits | Yes — creates a merge commit | No merge commits |
| Safety | Safe on shared branches | Risky on shared branches |
| Traceability | Easier to see when branches diverged | Harder to see original branch points |
| Best for | Long-lived shared branches | Personal/feature branches |

---

### Risks of Rebasing

Rebasing **rewrites commit history** — it creates new commits with different hashes. If you rebase commits that others have already pulled, they will see:

- Duplicate commits
- Missing commits
- Confusing conflicts when they try to push

**Golden Rule of Rebasing:**
> Only rebase commits that exist **only on your local machine**. Never rebase commits that have been pushed to a shared branch.

If you must force-push after a rebase:
```bash
git push --force-with-lease origin feature-branch
```

`--force-with-lease` is safer than `--force` — it fails if someone else has pushed since your last fetch.

---

## 7. Emergency Production Hotfix

> **Scenario:** Production is down due to a login bug while new features are still in development on the `develop` branch.

### Recommended Strategy: Hotfix Branch

Never fix production bugs directly on `main` or `develop`. Use a dedicated **hotfix branch** created from the stable production state.

---

### Workflow

**Step 1:** Create a hotfix branch from `main` (or your production tag):
```bash
git checkout main
git checkout -b hotfix/login-fix
```

**Step 2:** Implement and test the fix:
```bash
# make the fix
git add .
git commit -m "Fix: Resolve null pointer in login token validation"
```

**Step 3:** Merge back into `main` and deploy:
```bash
git checkout main
git merge hotfix/login-fix
git tag -a v1.2.1 -m "Hotfix: login token fix"
git push origin main --tags
```

**Step 4:** Merge the fix into `develop` so it's included in future releases:
```bash
git checkout develop
git merge hotfix/login-fix
git push origin develop
```

**Step 5:** Delete the hotfix branch:
```bash
git branch -d hotfix/login-fix
```

> **Why merge into both `main` AND `develop`?** If you only merge into `main`, the bug fix will be overwritten when `develop` is eventually merged for the next release.

---

## 8. Working Directory Interruption

> **Scenario:** You are halfway through implementing a feature when your manager asks you to urgently fix an issue on `main`.

### Git Stash — Save Your Work Without Committing

`git stash` temporarily shelves your uncommitted changes so you can switch context without losing work or creating a messy partial commit.

**Save current work:**
```bash
git stash
# Output: Saved working directory and index state WIP on feature-branch
```

**Switch to handle the urgent task:**
```bash
git checkout main
# fix the issue, commit it
git checkout feature-branch
```

**Restore your stashed work:**
```bash
git stash pop
```

---

### Useful Stash Commands

| Command | Purpose |
|---------|---------|
| `git stash` | Stash tracked changes |
| `git stash -u` | Stash including untracked files |
| `git stash list` | View all stashes |
| `git stash pop` | Restore latest stash and remove it |
| `git stash apply stash@{2}` | Restore a specific stash without removing it |
| `git stash drop stash@{0}` | Delete a specific stash |
| `git stash clear` | Remove all stashes |

> **Tip:** Give your stash a descriptive name for easier identification later:
> ```bash
> git stash push -m "WIP: payment form validation"
> ```

---

## 9. Wrong Commit Message

> **Scenario:** You committed with the message `"stuff fixed"` and want to correct it professionally.

### Amend the Last Commit Message

```bash
git commit --amend -m "Fix: Resolve authentication token validation edge case"
```

If you want to open your default editor for a longer message:
```bash
git commit --amend
```

> **Important:** `git commit --amend` rewrites the last commit. If the commit has already been pushed, you'll need to force push — which is only acceptable on personal branches:
> ```bash
> git push --force-with-lease origin feature-branch
> ```
> **Never amend commits on shared or protected branches.**

---

### What Makes a Good Commit Message?

A professional commit message answers two questions:
- **What** changed?
- **Why** was it changed?

**Format (Conventional Commits standard):**
```
<type>: <short summary>

[optional body explaining why and what]

[optional footer with issue references]
```

**Types:**

| Type | Usage |
|------|-------|
| `feat` | A new feature |
| `fix` | A bug fix |
| `docs` | Documentation changes |
| `refactor` | Code restructuring, no behavior change |
| `test` | Adding or updating tests |
| `chore` | Maintenance tasks |

**Examples:**
```
fix: Resolve null pointer exception in login token validation
feat: Add multi-factor authentication support
docs: Update API setup instructions in README
```

---

## 10. Local Branch Behind Main

> **Scenario:** Your feature branch is several commits behind the latest `main` branch.

### How to Sync Your Branch

**Step 1:** Update your local `main`:
```bash
git checkout main
git pull origin main
git checkout feature-reporting
```

**Step 2:** Choose your integration strategy:

---

### Option 1: Merge

```bash
git merge main
```

**Resulting history:**
```
main:      A → B → C ─────────── M
                    \           /
feature:             D → E → F
```

**Pros:**
- Safe — preserves the full history
- Non-destructive — doesn't rewrite commits
- Preferred for shared branches

**Cons:**
- Creates an extra merge commit
- History can become cluttered over time

---

### Option 2: Rebase

```bash
git rebase main
```

**Resulting history:**
```
A → B → C → D → E → F
```

**Pros:**
- Clean, linear history
- Easier to read `git log`
- Simpler `git bisect` debugging

**Cons:**
- Rewrites commit history (changes commit hashes)
- Risky if the branch is shared with others

---

### When to Use Each

| Situation | Recommended Approach |
|-----------|---------------------|
| Shared feature branch | `git merge` |
| Personal feature branch | `git rebase` |
| Team requires linear history | `git rebase` |
| Preserving exact history | `git merge` |

---

## 11. Multiple Remote Repositories

> **Scenario:** A DevOps engineer needs to push code to both GitHub and GitLab from one local repository.

### Why Use Multiple Remotes?

Organizations use multiple remotes for several reasons:
- **Backup/redundancy** — if one platform goes down, code exists elsewhere
- **Mirror for compliance** — some organizations mirror to internal GitLab from public GitHub
- **Separate deployment pipelines** — GitHub for development, GitLab CI for production
- **Open source + internal** — public repo on GitHub, private fork on internal GitLab

---

### Working with Multiple Remotes

**Add a second remote:**
```bash
git remote add gitlab https://gitlab.com/company/project.git
```

**View all remotes:**
```bash
git remote -v
# origin  https://github.com/company/project.git (fetch)
# origin  https://github.com/company/project.git (push)
# gitlab  https://gitlab.com/company/project.git (fetch)
# gitlab  https://gitlab.com/company/project.git (push)
```

**Push to a specific remote:**
```bash
git push origin main    # Push to GitHub
git push gitlab main    # Push to GitLab
```

**Push to all remotes at once (configure in `.git/config`):**
```ini
[remote "all"]
    url = https://github.com/company/project.git
    url = https://gitlab.com/company/project.git
```

Then:
```bash
git push all main
```

---

## 12. CI/CD Deployment Failure

> **Scenario:** After merging code into `main`, the CI/CD pipeline fails and production deployment breaks.

### Using Git to Identify the Problem

**Review recent commits:**
```bash
git log --oneline -10
```

**Compare current state with previous:**
```bash
git diff HEAD~1 HEAD
```

**Inspect a specific commit:**
```bash
git show <commit-id>
```

**Use `git bisect` to find the exact breaking commit:**
```bash
git bisect start
git bisect bad                  # Current state is broken
git bisect good <stable-tag>    # Last known good state
# Git will checkout commits in between for you to test
git bisect good  # or: git bisect bad
# Repeat until Git identifies the first bad commit
git bisect reset  # Return to HEAD when done
```

---

### Safe Rollback Strategies

**Option 1: `git revert` (Preferred for shared branches)**
```bash
git revert <commit-id>
git push origin main
```

Creates a new commit that undoes the changes. History is preserved. Safe and auditable.

**Option 2: `git reset` (Local only — never on shared branches)**
```bash
git reset --hard <stable-commit-id>
git push --force-with-lease origin main
```

> **Recommendation:** In production environments, always use `git revert`. It is reversible, leaves a clear audit trail, and does not rewrite shared history.

---

## 13. Large Feature Development

> **Scenario:** A developer works on a single branch for three months without merging updates from `main`.

### Problems This Creates

**Massive merge conflicts**
After three months, dozens or hundreds of files in `main` may have changed. Resolving all conflicts at once is extremely time-consuming and error-prone.

**Integration surprises**
The feature may depend on APIs, functions, or data structures that no longer exist or have changed significantly.

**Delayed feedback**
Bugs in the feature remain undiscovered for months. They become harder to fix once the code is deeply entangled.

**Increased deployment risk**
A single enormous merge is far riskier than many small, incremental merges. Rollback becomes harder.

**Blocked code review**
A pull request with thousands of changes is nearly impossible to review meaningfully.

---

### Best Practices to Prevent This

| Practice | Why It Helps |
|----------|-------------|
| Sync with `main` daily or weekly | Catch conflicts early when they are small |
| Break large features into sub-tasks | Each sub-task can be merged independently |
| Use **feature flags** | Merge incomplete features safely behind a flag |
| Adopt **trunk-based development** | Short-lived branches merged frequently |
| Create incremental pull requests | Smaller reviews = faster feedback |

**Feature flag example:**
```python
if feature_flags.is_enabled("new-payment-flow"):
    run_new_payment_flow()
else:
    run_existing_payment_flow()
```

This allows merging incomplete code into `main` without affecting users.

---

## 14. Detached HEAD Situation

> **Scenario:** A student runs `git checkout a1b2c3d` to inspect a specific commit.

### What Is a Detached HEAD State?

Normally, `HEAD` points to a **branch**, which in turn points to a commit:
```
HEAD → feature-login → commit abc123
```

In detached HEAD state, `HEAD` points **directly to a commit** — not to any branch:
```
HEAD → commit a1b2c3d
```

You are essentially in "read-only browsing" mode — no branch is tracking your position.

---

### Why It Can Be Dangerous

If you make new commits while in detached HEAD:
```bash
git commit -m "Experimental fix"
```

These commits have **no branch reference**. When you switch to another branch:
```bash
git checkout main
```

Git warns you that the commits may be lost. After enough time, garbage collection will permanently delete them.

---

### How to Safely Exit Detached HEAD

**If you made commits you want to keep:**
```bash
git checkout -b recovery-branch
```

This creates a branch at your current position, saving all commits.

**If you just want to return to your branch without saving:**
```bash
git checkout main
```

**If you accidentally lost commits:**
```bash
git reflog
# Find the commit hash
git checkout -b recovered-work <commit-hash>
```

> **Common use cases for intentional detached HEAD:**
> - Inspecting old code for debugging
> - Running tests against a specific release
> - Comparing behavior between versions
> Always create a branch before making any commits in this state.

---

## 15. Protected Main Branch

> **Scenario:** Your company prevents direct pushes to the `main` branch.

### Why Branch Protection Is Important

Branch protection rules prevent:

- **Accidental direct pushes** — a typo can break production
- **Unreviewed code** — untested changes reaching production
- **Force pushes** — which can destroy shared history
- **Bypassing CI/CD checks** — skipping automated tests
- **Unauthorized changes** — only approved contributors can merge

**Common branch protection rules:**

| Rule | Purpose |
|------|---------|
| Require pull request | No direct pushes allowed |
| Require N approvals | At least N reviewers must approve |
| Require status checks | CI/CD must pass before merge |
| Require linear history | Enforce rebase or squash merges |
| Restrict who can merge | Only specific roles can merge to main |
| No force pushes | History cannot be rewritten |

---

### How Pull Requests Improve Quality and Collaboration

**Code Review**
Multiple developers inspect the changes, catch bugs, and suggest improvements before code reaches production.

**Knowledge Sharing**
Team members learn about each other's work, spreading knowledge across the team and reducing silos.

**Automated Validation**
CI/CD pipelines run automatically on every PR:
- Unit tests
- Integration tests
- Security scans (SAST/DAST)
- Code linting and formatting checks

**Documentation and Context**
PR descriptions, comments, and discussions explain *why* decisions were made — creating a permanent record.

**Reduced Production Risk**
Defects are caught before deployment. The cost of fixing a bug in code review is dramatically lower than fixing it in production.

**Audit Trail**
Every change has a clear record of who made it, who approved it, and why — essential for compliance and incident investigation.

> **In mature DevOps organizations**, pull requests serve as a **quality gate** that enforces peer review, automated testing, security scanning, and collaborative discussion before any code reaches production.

---

## Quick Reference Summary

| Scenario | Key Git Commands |
|----------|----------------|
| Merge conflict | `git merge`, `git add`, `git commit` |
| Undo accidental commit | `git reset --hard HEAD~1`, `git revert` |
| Push rejected | `git pull --rebase`, `git push` |
| Recover deleted branch | `git reflog`, `git checkout -b` |
| Remove secrets from history | `git filter-repo`, BFG Cleaner |
| Clean linear history | `git rebase` |
| Production hotfix | `git checkout -b hotfix/`, merge to `main` + `develop` |
| Switch context safely | `git stash`, `git stash pop` |
| Fix commit message | `git commit --amend` |
| Sync branch with main | `git merge main` or `git rebase main` |
| Multiple remotes | `git remote add`, `git push <remote>` |
| Find breaking commit | `git bisect`, `git log`, `git diff` |
| Roll back safely | `git revert <commit-id>` |
| Detached HEAD | `git checkout -b <new-branch>` |
| Branch protection | Pull requests, CI/CD status checks |

---

*This guide covers common real-world Git scenarios encountered in professional software development and DevOps environments.*
