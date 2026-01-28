# GitHub Configuration

## What does this do?

This directory contains GitHub-specific configuration files, including CI/CD workflows that automate testing and deployment.

## Why does it exist?

GitHub Actions workflows provide:
- Automated testing on pull requests
- Continuous integration to catch errors early
- Automated documentation generation and deployment
- Quality gates before code merges

## Contents

### Workflows

- **`workflows/dbt_tests.yml`** - Runs dbt tests and generates documentation on pull requests and pushes to main branch

## Workflow Details

### dbt Tests and Documentation

**Triggers:**
- Pull requests to `main` or `develop` branches
- Pushes to `main` branch

**What it does:**
1. Sets up PostgreSQL service container
2. Installs Python and dbt dependencies
3. Runs all dbt tests to validate data quality
4. Generates dbt documentation
5. Deploys documentation to GitHub Pages (on main branch only)

**Environment:**
- Uses PostgreSQL 15 Alpine image
- Runs on Ubuntu latest
- Python 3.10

## Viewing Workflow Results

1. Go to the **Actions** tab in your GitHub repository
2. Click on a workflow run to see detailed logs
3. Check test results and any failures
4. View deployed documentation at: `https://<username>.github.io/<repo-name>/`

## Adding New Workflows

To add new GitHub Actions workflows:
1. Create a `.yml` file in `.github/workflows/`
2. Follow GitHub Actions syntax
3. Commit and push - workflows run automatically

## Related Documentation

- GitHub Actions docs: https://docs.github.com/en/actions
- dbt documentation: https://docs.getdbt.com/
