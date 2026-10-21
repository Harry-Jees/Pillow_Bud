# Maintenance execution plan

1. Fix security-sensitive key handling and record authentication.
2. Make database initialization failures visible instead of continuing with unavailable persistence.
3. Encrypt sensitive metadata in new database writes while retaining a legacy-read path.
4. Align model configuration with the actual Qwen GGUF download.
5. Remove stale scaffolding and consolidate documentation around the actual implementation.
6. Run formatting, static analysis, tests, and native builds; record exact results before merging.

## Verification status

Source changes have been made on a maintenance branch. Flutter tooling has not been run in this environment, so the changes are not yet verified by analyzer, tests, or platform builds. Do not describe the branch as production-ready until those checks pass.
