# Security Check Before Pushing to GitHub

Use this checklist before your first push to ensure no sensitive data is committed.

---

## 1. Files That Must NOT Be Committed

These are in `.gitignore` and must stay untracked:

| File / Pattern | Why |
|----------------|-----|
| `.env` | Contains real `POSTGRES_PASSWORD`, `AIRFLOW__CORE__FERNET_KEY`, etc. |
| `dbt_project/profiles.yml` | Contains `POSTGRES_PASSWORD` via env_var (and default `analytics`) |
| `project_context.md` | Local notes; may mention credentials |
| `venv/`, `env/`, `.venv` | Virtual env; can contain paths and tools |
| `data/raw/`, `*.csv` | Data files; large and may contain PII |
| `airflow/logs/`, `airflow/airflow.db` | Airflow runtime data |
| `dbt_project/target/`, `dbt_project/logs/` | dbt artifacts |

**Before first commit:** Run:

```bash
git status
git check-ignore -v .env dbt_project/profiles.yml
```

Confirm `.env` and `dbt_project/profiles.yml` are listed as ignored. If either appears under "Changes to be committed", **unstage and do not commit** (e.g. `git reset HEAD .env`).

---

## 2. What Is Safe in the Repo (No Change Needed)

- **docker-compose.yml** – Uses `${POSTGRES_PASSWORD:-analytics}` (env var + default). No literal secret. Default `analytics` is a common dev default for portfolio projects.
- **ingestion/load_to_postgres.py** – Reads credentials from `os.getenv(...)` only. No hardcoded passwords.
- **README / docs** – References to "password: analytics" or "credentials in .env" are documentation only.

---

## 3. CI Password in GitHub Actions

**File:** `.github/workflows/dbt_tests.yml`

**Current:** Postgres service and steps use:

- `POSTGRES_USER: analytics`
- `POSTGRES_PASSWORD: analytics`

**Risk:** Low for a portfolio repo. The password is only used in CI for an ephemeral Postgres container (no real data, container is destroyed after the run).

**Options:**

- **Leave as-is** – Acceptable for many open-source/portfolio projects. Add a one-line comment in the workflow: `# CI-only throwaway DB; not used in production.`
- **Use GitHub Secrets** – For stricter hygiene, in the repo: Settings → Secrets and variables → Actions, add e.g. `POSTGRES_PASSWORD`. In the workflow replace `POSTGRES_PASSWORD: analytics` with `POSTGRES_PASSWORD: ${{ secrets.POSTGRES_PASSWORD }}` and set that secret to `analytics` (or another value). No need to change the repo default password for local dev.

---

## 4. Pre-Push Checklist

- [ ] `.env` is in `.gitignore` and **not** in `git status` / "to be committed".
- [ ] `dbt_project/profiles.yml` is in `.gitignore` and **not** in "to be committed".
- [ ] No other files under `data/raw/` or with real secrets are staged.
- [ ] You have an `.env.example` (without real values) so others know which vars to set; `.env` itself is never committed.
- [ ] (Optional) You’ve decided how to handle the CI password (leave as-is vs GitHub secret) and added a short comment in the workflow if needed.

---

## 5. If You Already Committed Something Sensitive

- **Do not push.** Run `git reset HEAD~1` (or the right number of commits) to undo the last commit(s) that added the file, then add the file to `.gitignore` and commit again without it.
- If you already pushed: rotate the exposed secret (new DB password, new FERNET_KEY, etc.) and remove the secret from the repo history (e.g. `git filter-branch` or BFG) or create a new repo and push only safe history. Prefer not pushing secrets in the first place.

---

## Summary

- **Never commit:** `.env`, `profiles.yml`, raw data, or any file containing real passwords/keys.
- **Safe to commit:** docker-compose with env var references, code that uses `os.getenv()`, README/docs that describe credentials without listing real values.
- **CI:** Hardcoded `analytics`/`analytics` in the workflow is a common pattern for ephemeral test DBs; optionally move to GitHub Secrets and add a comment.

Run `git status` and `git check-ignore` before the first push and use this doc as your security check.
