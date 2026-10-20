# Pillow Bud — implementation backlog

Use the repository-root `TODO.md` for the consolidated maintenance checklist.

## App-specific follow-up
- [ ] Add passphrase-protected, authenticated, portable backup export/import. The current export is Base64-encoded and unencrypted.
- [ ] Move chat and journal persistence out of plaintext SharedPreferences and into the encrypted repository layer.
- [ ] Add a migration that authenticates/re-encrypts legacy records before removing the legacy CBC-only read path.
- [ ] Add tests for schema migration, backup corruption, and import across a clean installation.
- [ ] Verify Android, iOS, Windows, macOS, and Linux builds with the actual Flutter SDK/toolchains.
- [ ] Verify local inference memory use and download integrity on representative devices.
