# Security policy

Pillow Bud can store highly sensitive conversations, journal entries, and mood notes. Security reports should be handled privately and respectfully.

## Reporting a vulnerability

**Do not publish exploit instructions, private user data, journal entries, backup files, keys, or credentials in a public issue.**

Use GitHub's private vulnerability reporting feature for this repository if it is enabled. Otherwise, contact the repository maintainer through a private GitHub channel. Include:
- affected version, commit, platform, and configuration;
- a concise impact description and safe reproduction steps;
- whether the issue involves data exposure, tampering, loss, or availability;
- a suggested mitigation, if known.

Do not include real personal records or secrets. Please allow the maintainer a reasonable opportunity to investigate before publicly disclosing a vulnerability. No response-time guarantee is currently promised.

## Security-sensitive areas

- OS secure storage, master-key creation, caching, and reset behavior;
- encrypted SQLite fields and migration of legacy records;
- encrypted SharedPreferences payloads and duplicate persistence paths;
- PBv3 passphrase-protected backups, authentication, malformed-file handling, and restore atomicity;
- model download integrity, resume behavior, file size, storage use, and native inference;
- crisis phrase detection, false positives/negatives, and emergency-resource copy;
- biometric lock, app lifecycle, logs, and exported files.

## Current design and limitations

- New database records use AES-256-CBC with HMAC-SHA256 encrypt-then-MAC authentication. Older IV-only records remain readable for compatibility and are not authenticated until safely migrated.
- The master key must come from OS secure storage. A hardcoded fallback is not acceptable.
- PBv3 backups use PBKDF2-HMAC-SHA256 (120,000 iterations) to derive encryption and authentication keys, AES-CBC to encrypt the archive, and HMAC-SHA256 to authenticate it before decryption. PBv2 is a legacy, installation-bound format.
- This is a custom backup format and has not had an independent cryptographic review. Automated tests do not replace security review or real-device testing.
- Chat and journal content has more than one persistence path. That increases complexity and is scheduled for consolidation.
- The local AI model can produce incorrect, biased, or unsafe content. Crisis detection is phrase-based and cannot reliably determine a person's risk or replace human support.
- Model download requires network access. Local inference itself is designed not to call a hosted model API.

Please avoid describing the application as fully secure, clinically validated, or independently audited.
