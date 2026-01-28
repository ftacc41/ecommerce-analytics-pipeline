# Pushing This Project to GitHub (First Time)

Follow these steps in order. You need a GitHub account and nothing created yet for this project on GitHub.

---

## Step 1: Initialize Git and Make Your First Commit (Local)

Run these in your project folder (`analytics_project_1`):

```bash
cd /Users/macbook/analytics_project_1

# Initialize a new repo
git init

# Confirm sensitive files are ignored (should list .env and profiles.yml)
git check-ignore -v .env dbt_project/profiles.yml

# See what will be committed (should NOT include .env or profiles.yml)
git status

# Stage all tracked files (respects .gitignore)
git add .

# Optional: double-check no secrets are staged
git status

# Create first commit
git commit -m "Initial commit: e-commerce analytics pipeline with dbt, Metabase, Airflow"
```

---

## Step 2: Create the Repository on GitHub

1. Go to [github.com](https://github.com) and sign in.
2. Click the **+** (top right) → **New repository**.
3. Fill in:
   - **Repository name:** e.g. `ecommerce-analytics-pipeline` (or any name you like).
   - **Description:** (optional) e.g. "E-commerce analytics pipeline with dbt, Metabase, and Airflow".
   - **Public** or **Private** – your choice.
   - **Do not** check "Add a README", "Add .gitignore", or "Choose a license" – you already have these in your project.
4. Click **Create repository**.

---

## Step 3: Connect Your Local Repo and Push

GitHub will show you "…or push an existing repository from the command line." Use that, or run (replace `YOUR_USERNAME` and `REPO_NAME` with your actual values):

```bash
cd /Users/macbook/analytics_project_1

# Add GitHub as the remote (use YOUR repo URL)
git remote add origin https://github.com/YOUR_USERNAME/REPO_NAME.git

# Rename branch to main if needed (GitHub default)
git branch -M main

# Push your first commit
git push -u origin main
```

**Example:** If your GitHub username is `johndoe` and the repo is `ecommerce-analytics-pipeline`:

```bash
git remote add origin https://github.com/johndoe/ecommerce-analytics-pipeline.git
git branch -M main
git push -u origin main
```

You may be asked for your GitHub username and password. For password, use a **Personal Access Token** (GitHub no longer accepts account passwords for git over HTTPS). To create one: GitHub → Settings → Developer settings → Personal access tokens → Generate new token; give it `repo` scope and use it when prompted for password.

---

## Step 4: Verify on GitHub

- Refresh your repo page on GitHub.
- You should see your files, README, docker-compose, dbt project, etc.
- Confirm **.env** and **dbt_project/profiles.yml** do **not** appear (they are gitignored).

---

## Troubleshooting

| Problem | Solution |
|--------|----------|
| "Permission denied" or "Authentication failed" | Use a Personal Access Token instead of your GitHub password. |
| "remote origin already exists" | Run `git remote remove origin` then add it again with the correct URL. |
| Wrong files committed (e.g. .env) | Do not push. Run `git reset HEAD~1`, add the file to .gitignore, and commit again without it. |
| Branch is "master" not "main" | Run `git branch -M main` before `git push`. |

---

## After the First Push

- For future changes: `git add .` → `git commit -m "Your message"` → `git push`.
- If you set up GitHub Actions (`.github/workflows/dbt_tests.yml`), push to `main` (or your default branch) to run dbt tests on push/PR.
