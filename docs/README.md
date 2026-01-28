# Project Documentation

## What does this do?

This directory contains comprehensive documentation about the analytics pipeline architecture, data model, setup procedures, and security considerations.

## Why does it exist?

Well-documented projects are:
- Easier to understand and maintain
- More professional and portfolio-ready
- Accessible to team members and stakeholders
- Self-explanatory for future reference

## Contents

### Architecture Documentation

- **`ARCHITECTURE.md`** - High-level system architecture, component interactions, and data flow diagrams
  - Explains how ingestion, dbt, Airflow, and Metabase work together
  - Describes the medallion architecture (bronze/silver/gold layers)
  - Includes infrastructure diagrams

### Data Model Documentation

- **`DATA_MODEL.md`** - Detailed documentation of the dimensional data model
  - Fact tables and their grain
  - Dimension tables and their attributes
  - Relationships and foreign keys
  - Business metrics definitions

### Setup Guides

- **`GITHUB_SETUP.md`** - Step-by-step guide for setting up the GitHub repository
  - Repository initialization
  - Branch protection rules
  - GitHub Actions configuration
  - Secrets management

### Security Documentation

- **`SECURITY_CHECK.md`** - Security best practices and checklist
  - Environment variable management
  - Credential handling
  - Git ignore patterns
  - Production deployment considerations

## How to Use

1. **New team members**: Start with `ARCHITECTURE.md` for system overview
2. **Data analysts**: Read `DATA_MODEL.md` to understand available tables
3. **Developers**: Reference setup guides when configuring environments
4. **DevOps**: Review security documentation before production deployment

## Contributing

When adding new features or making significant changes:
1. Update relevant documentation files
2. Keep diagrams and examples current
3. Add new documentation files for major features
4. Ensure all links and references are accurate

## Related Files

- Main `README.md` - Quick start guide and project overview
- `dbt_project/README.md` - dbt-specific documentation
- `airflow/README.md` - Airflow orchestration details
