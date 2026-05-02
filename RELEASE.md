# Release Process

This repository uses an **intentional, label-gated release process**. Releases are automated, but they only happen when maintainers explicitly signal intent via labels.

---

## Release Types

### Beta Releases

Beta releases are **pre-production** builds intended for early testing and feedback.

* Tag format: `vX.Y.Z-beta.N` or `beta`
* GitHub Release marked as **Pre-release**
* APIs and structure may change without notice
* Not recommended for production use

### Stable Releases

Stable releases are production-ready versions.

* Tag format: `vX.Y.Z` (e.g., `v1.0.0`)
* GitHub Release marked as **Latest**
* Follows semantic versioning
* Suitable for production use

---

## How a Beta Release Is Created

### 1. Open a Pull Request

Contributors open a PR as usual.

* PRs are auto-labeled based on files and content
* No release happens automatically

### 2. Mark the PR for Beta

A maintainer must **explicitly add the `beta` label** to the PR.

> This label is a release signal and is **never auto-applied**.

### 3. Merge the PR

When the PR is merged:

* The PR is automatically locked
* A push occurs on `main`

### 4. Automated Release Workflow Runs

The `Automated Beta Release` workflow:

* Finds the merged PR associated with the commit
* Checks for the `beta` label

**If the label is present:**

* A beta release is created
* Changelog is generated automatically via `release-please-action`

**If the label is NOT present:**

* The workflow exits cleanly
* No tag, no release, no noise

---

## Stable Releases

Stable releases are created manually:

1. Ensure `CHANGELOG.md` is up to date
2. Create and push a tag: `git tag -a v1.0.0 -m "Release v1.0.0"`
3. Push the tag: `git push origin v1.0.0`
4. Create a GitHub Release from the tag

---

## Labels That Affect Releases

| Label          | Effect                              |
| -------------- | ----------------------------------- |
| `beta`         | Triggers a beta release on merge    |
| `skip-release` | Prevents any release (reserved)     |
| `release`      | Reserved for future stable releases |

---

## Changelog Generation

Changelogs are generated:

* **Automatically** via `release-please-action` for beta releases
* **Manually** for stable releases

Conventional commit types used:

| Type       | Section       |
| ---------- | ------------- |
| `feat`     | Features      |
| `fix`      | Bug Fixes     |
| `perf`     | Performance   |
| `docs`     | Documentation |
| `refactor` | Refactors     |

---

## Why This Process Exists

* Prevents accidental releases
* Keeps beta releases intentional and reviewable
* Scales cleanly as contributors grow
* Aligns labels (intent) with automation (behavior)

---

## Summary

> **Labels express intent. Automation enforces it.**

If a release happened, it was intentional.
If it did not, it was by design.

---

For questions or suggestions, open a GitHub Issue or Discussion.
