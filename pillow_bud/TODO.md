# Pillow Bud app follow-up

See the repository-root [TODO.md](../TODO.md) for the consolidated maintenance and release checklist.

App-specific outstanding work:
- [ ] Run Flutter analysis and all tests with a compatible SDK.
- [ ] Test portable PBv3 backups end-to-end, including wrong passphrases, corruption, and restoring to a clean installation.
- [ ] Test PBv2 compatibility against a real legacy backup from a previous release.
- [ ] Consolidate duplicate chat/journal persistence from SQLite and SharedPreferences.
- [ ] Test schema migrations and legacy encrypted/plaintext field handling.
- [ ] Evaluate local model quality, memory use, cancellation, interrupted downloads, and failure recovery on representative devices.
- [ ] Verify crisis-detection false positives/negatives and resource copy.
- [ ] Smoke-test Android, Windows, Linux, macOS, and iOS only on their supported toolchains; do not claim a target is verified until its build and runtime checks pass.
