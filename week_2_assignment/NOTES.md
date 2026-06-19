# Git Scenario-Based Questions

> **Intermediate → Advanced Git Interview & Practice Guide**

A practical collection of real-world Git scenarios covering merge conflicts, branch management, recovery techniques, security incidents, deployment workflows, and team collaboration best practices.

---

## 📑 Table of Contents

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

**Scenario:** Two developers edited the same section of `app.py` in different branches. During the merge, Git reports a conflict.

### Why did the conflict happen?

The conflict happened because Git detected that both developers modified the **exact same lines of code** differently. Since Git could not automatically determine which version should be kept, it stopped the merge process and asked for manual intervention.

### How would you resolve it safely?

1. Open the conflicted file.
2. Review the changes from both branches carefully.
3. Decide whether to:
   - keep one version,
   - combine both changes,
   - or rewrite the section completely.
4. Remove Git conflict markers such as:

   ```
   <<<<<<< HEAD
   =======
   >>>>>>> branch-name
   ```

5. Test the application to ensure everything works correctly.
6. Stage the resolved file:

   ```bash
   git add app.py
   ```

7. Complete the merge:

   ```bash
   git commit
   ```

> 💡 **Best Practice:** Good communication between developers and frequent pulls from the main branch help reduce merge conflicts.

---

## 2. Accidental Commit to Main

**Scenario:** You accidentally committed unfinished work directly to the `main` branch instead of a feature branch.

### How would you move the work safely?

**Step 1 — Create a New Branch**
```bash
git checkout -b feature-login-fix
```
This preserves your unfinished work.

**Step 2 — Move Back to Main**
```bash
git checkout main
```

**Step 3 — Remove the Commit from Main**
```bash
git reset --hard HEAD~1
```
This moves the main branch back one commit.

### Why this works
- Your work remains safely stored in the new branch.
- The main branch stays clean and production-ready.
- Team members avoid pulling unfinished code.

> ⚠️ **Alternative Safer Option:** If the commit was already pushed publicly, use `git revert <commit-id>` instead of `reset`, because rewriting shared history can affect other developers.

---

## 3. Remote Push Rejected

**Scenario:** You run `git push origin main` and Git responds:
```
rejected because remote contains work you do not have locally
```

### Why did this happen?

This happens when someone else pushed changes to the remote repository before you did. Your local branch is now **behind** the remote branch. Git blocks the push to prevent overwriting other people's work.

### What should you do next?

**Step 1 — Pull Latest Changes**
```bash
git pull origin main
```

**Step 2 — Resolve Any Conflicts**
If conflicts appear:
- Review the files
- Resolve conflicts manually
- Test the application

**Step 3 — Push Again**
```bash
git push origin main
```

> 💡 **Best Practice:** Always pull frequently before pushing, especially in collaborative environments.

---

## 4. Deleted Branch Recovery

**Scenario:** A teammate deleted a feature branch after merging, but later discovered important work was missing.

### Can the commits still be recovered?

**Yes.** Git usually keeps deleted commits for some time unless garbage collection permanently removes them.

### Which Git tools can help?

**Using `git reflog`:**
```bash
git reflog
```
This shows recent branch movements and commit references.

**Using `git log`:**
```bash
git log --all
```
This helps locate missing commits.

**Recover the Commit:**
```bash
git checkout -b recovered-branch <commit-id>
```

### Why reflog is powerful
`git reflog` can recover:
- deleted branches
- accidental resets
- overwritten commits
- lost work after rebases

---

## 5. Sensitive Credentials Exposure

**Scenario:** A developer accidentally pushed AWS credentials to GitHub.

### Immediate actions to take

1. **Revoke the Credentials Immediately** — Disable or delete the exposed keys in AWS IAM.
2. **Generate New Credentials** — Create replacement keys for the application.
3. **Remove Secrets from Git History** using tools such as:
   ```bash
   git filter-repo
   ```
   or the **BFG Repo-Cleaner**.
4. **Force Push the Cleaned Repository**
   ```bash
   git push --force
   ```

### Why deleting the file alone is not enough

Even if the file is deleted, Git still stores it inside previous commits. Anyone can retrieve it from repository history.

### Additional Security Measures
- Rotate passwords and tokens
- Check audit logs for suspicious access
- Use `.gitignore` to avoid future exposure
- Use secret scanning tools such as:
  - GitHub Secret Scanning
  - TruffleHog
  - GitLeaks

---

## 6. Rebase vs Merge Decision

**Scenario:** Your team wants a clean, linear Git history with fewer merge commits.

### Would you recommend merge or rebase?

I would recommend **rebase** for feature branches because it creates a cleaner and more readable history.

### How Rebase Works

Instead of creating an extra merge commit, rebase moves your commits on top of the latest branch history.

```bash
git checkout feature-branch
git rebase main
```

### Advantages of Rebase
- Cleaner history
- Easier debugging
- Better commit organization
- Fewer unnecessary merge commits

### Risks Involved

Rebasing shared branches can:
- Rewrite commit history
- Confuse team members
- Create duplicate commits
- Cause difficult conflicts

### When to Use Merge Instead

Use merge when:
- Working on shared branches
- Preserving historical context matters
- Avoiding history rewrites is important

> 📌 **Simple Rule:**
> - **Rebase** for local/private feature cleanup.
> - **Merge** for shared collaborative work.

---

## 7. Emergency Production Hotfix

**Scenario:** Production is down due to a login bug while new features are still under development.

### Which branch strategy should be used?

A **hotfix branch strategy** should be used.

### Workflow

**Step 1 — Create Hotfix Branch**
```bash
git checkout main
git checkout -b hotfix-login-error
```

**Step 2 — Fix the Issue**
Apply the minimal required fix.

**Step 3 — Test Thoroughly**
Run:
- Unit tests
- Regression tests
- Smoke tests

**Step 4 — Merge into Main**
```bash
git checkout main
git merge hotfix-login-error
```

**Step 5 — Deploy to Production**

**Step 6 — Merge Back into Development Branches**
This ensures other branches also receive the fix.

### Why Hotfix Branches Matter

They allow urgent fixes without mixing unfinished features into production.

---

## 8. Working Directory Interruption

**Scenario:** You are halfway through a feature when your manager asks for an urgent fix.

### Which Git feature helps?

**`git stash`**

### How it works

Save incomplete work temporarily:
```bash
git stash
```

Switch branches safely:
```bash
git checkout main
```

After finishing the urgent task:
```bash
git stash pop
```

### Benefits
- Prevents incomplete commits
- Keeps working directory clean
- Helps context-switch quickly

> 💡 **Best Practice:** Use meaningful stash names:
> ```bash
> git stash push -m "Halfway login redesign"
> ```

---

## 9. Wrong Commit Message

**Scenario:** You committed:
```bash
git commit -m "stuff fixed"
```

### How can you correct it professionally?

Use:
```bash
git commit --amend -m "Fix login validation issue"
```

### Why this is important

Professional commit messages:
- Improve readability
- Help during debugging
- Assist code reviews
- Improve project documentation

### Good Commit Message Characteristics
- Clear
- Short
- Action-oriented
- Descriptive

**Example:**
- ✅ `Add JWT authentication middleware`
- ❌ `changes`

---

## 10. Local Branch Behind Main

**Scenario:** Your feature branch is several commits behind `main`.

### How can you update your branch?

**Option 1 — Merge**
```bash
git checkout feature-branch
git merge main
```

| Pros | Cons |
|------|------|
| Safer for shared branches | Adds merge commits |
| Preserves full history | |

**Option 2 — Rebase**
```bash
git checkout feature-branch
git rebase main
```

| Pros | Cons |
|------|------|
| Cleaner linear history | Can rewrite history |
| Easier to read | Risky on shared branches |

> 💡 **Best Practice:** Rebase local work before opening pull requests, but avoid rebasing public shared branches.

---

## 11. Multiple Remote Repositories

**Scenario:** A DevOps engineer pushes code to both GitHub and GitLab from one repository.

### Why use multiple remotes?

Organizations may use multiple remotes for:
- Backups
- Disaster recovery
- CI/CD separation
- Mirroring repositories
- Collaboration across platforms

### Example Remotes
```bash
git remote -v
```

Output:
```
origin   github-url
gitlab   gitlab-url
```

### Push to a Specific Remote
```bash
git push gitlab main
```
or:
```bash
git push origin main
```

> 💡 **Best Practice:** Use clear remote names like `origin`, `backup`, `gitlab`, `production`.

---

## 12. CI/CD Deployment Failure

**Scenario:** After merging into `main`, the deployment pipeline fails.

### How can Git help identify the issue?

**Check Recent Commits**
```bash
git log
```

**Compare Changes**
```bash
git diff
```

**Find the Breaking Commit**
```bash
git bisect
```

### How to Roll Back Safely

**Option 1 — Revert** (safest for shared repositories)
```bash
git revert <commit-id>
```

**Option 2 — Roll Back to Stable Release**
```bash
git checkout <stable-commit>
```

> ⚠️ **Best Practice:** Never rush fixes directly into production without testing rollback strategies first.

---

## 13. Large Feature Development

**Scenario:** A developer works on one branch for three months without syncing with `main`.

### Problems This Creates
- Massive merge conflicts
- Outdated dependencies
- Integration failures
- Difficult testing
- Higher deployment risk

### Best Practices to Prevent This
- Merge changes frequently
- Pull updates regularly
- Break large tasks into smaller features
- Use pull requests often
- Run continuous integration tests

> 🚀 **Modern Agile Recommendation:** Small frequent merges reduce risk significantly compared to long-lived branches.

---

## 14. Detached HEAD Situation

**Scenario:** A developer runs:
```bash
git checkout a1b2c3d
```

### What is a detached HEAD state?

A **detached HEAD** means Git is pointing directly to a commit instead of a branch.

### Why can it become dangerous?

If you create commits in this state and later switch branches, those commits may become **unreachable** and eventually lost.

### How to Save Work

Create a branch immediately:
```bash
git checkout -b recovery-branch
```

### Common Use Cases

Detached HEAD is useful for:
- Testing old commits
- Debugging historical versions
- Temporary experiments

---

## 15. Protected Main Branch

**Scenario:** Your company prevents direct pushes to `main`.

### Why is branch protection important?

Branch protection:
- Prevents accidental production changes
- Enforces code reviews
- Improves security
- Ensures testing before deployment

### How Pull Requests Improve Quality

Pull requests help by:
- Enabling peer reviews
- Triggering automated tests
- Improving collaboration
- Catching bugs early
- Maintaining coding standards

### Typical Pull Request Workflow

1. Create feature branch
2. Push changes
3. Open pull request
4. Team reviews code
5. CI/CD tests run
6. Approve and merge

### Why Companies Use This

Protected branches reduce production failures and improve software reliability in team environments.

---

## 📚 Summary

| # | Scenario | Key Command/Concept |
|---|----------|---------------------|
| 1 | Merge Conflict | `git add` + `git commit` |
| 2 | Accidental Commit to Main | `git reset --hard HEAD~1` |
| 3 | Push Rejected | `git pull` then push |
| 4 | Deleted Branch Recovery | `git reflog` |
| 5 | Exposed Credentials | `git filter-repo` + revoke keys |
| 6 | Rebase vs Merge | `git rebase` for clean history |
| 7 | Production Hotfix | Hotfix branch from `main` |
| 8 | Task Interruption | `git stash` |
| 9 | Wrong Commit Message | `git commit --amend` |
| 10 | Branch Behind Main | `git merge` or `git rebase` |
| 11 | Multiple Remotes | `git remote add` |
| 12 | Deployment Failure | `git bisect` + `git revert` |
| 13 | Long-lived Branches | Frequent small merges |
| 14 | Detached HEAD | `git checkout -b` |
| 15 | Protected Main | Pull request workflow |

---

## 🤝 Contributing

Feel free to add more scenarios or improvements via pull requests.

## 📄 License

This study guide is open for educational use.
