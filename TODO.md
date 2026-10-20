# Pillow Bud maintenance checklist

## Security and data integrity
- [x] Remove the hardcoded master-key fallback.
- [x] Authenticate new encrypted database records and fail on tampering.
- [x] Encrypt newly written mood labels in the database.
- [x] Encrypt serialized chat/journal payloads stored by SharedPreferences.
- [x] Stop silently swallowing database initialization errors.
- [ ] Replace Base64-only backups with a portable, authenticated, passphrase-protected backup format and add restore UX.
- [ ] Consolidate duplicate chat/journal persistence into a single repository layer.
- [ ] Add a tested migration path that re-encrypts legacy unauthenticated records.
- [ ] Audit crisis detection, emergency resources, and safety copy.

## Build and release
- [x] Remove debug signing from Android release builds.
- [x] Add Android internet permission for model downloads.
- [ ] Configure and test private release signing in CI without committing secrets.
- [ ] Build and smoke-test every claimed native platform.

## Quality
- [ ] Run `flutter pub get`, `dart format`, `flutter analyze`, and `flutter test` from `pillow_bud/`.
- [ ] Add tests for encryption tampering, key-store failure, database migrations, backup corruption, and restore behavior.
- [ ] Track `pubspec.lock` for reproducible app builds.
- [ ] Review all docs whenever model, storage, or platform behavior changes.
