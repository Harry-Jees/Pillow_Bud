# Security policy

Pillow Bud stores sensitive personal reflections. Please do not publish exploit details or private user data in public issues.

## Reporting a vulnerability

Report suspected vulnerabilities privately to the repository owner through GitHub's private vulnerability reporting feature, if enabled, or contact the maintainer directly through a private channel. Include affected versions, reproduction steps, impact, and any suggested mitigation. Do not include real journal entries, credentials, or personal data.

## Security-sensitive areas

Prioritize review of:
- OS secure key storage and encryption key lifecycle
- Database record encryption and legacy-data migration
- Backup export/import and file handling
- Model downloads, integrity, and disk usage
- Crisis detection and safety-resource copy
- Biometric lock and app lifecycle behavior

## Current limitations

- Older records may use unauthenticated AES-CBC encryption for backward compatibility.
- Chat/journal payloads are encrypted before being stored in SharedPreferences, but they are duplicated across persistence layers and should be consolidated.
- Exported backups are Base64-encoded, not encrypted.
- A local AI model can produce incorrect or unsafe content; crisis detection is not a substitute for emergency support.
- Backups are not encrypted as complete files and are currently installation-key-bound.

Do not describe the app as fully encrypted or production-secure until these limitations are addressed and verified.
