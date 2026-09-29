# Verification status — version 1

- React/TypeScript local build: passed.
- Hosted frontend build with placeholder public configuration: passed; real credentials were not used.
- Backend test suite: 24 passed, 7 PostgreSQL integration tests skipped locally because a PostgreSQL test service was unavailable.
- Account isolation, duplicate orders, concurrent cash updates, JWT verification, progress isolation, and deployment configuration checks: passed.
- Original local database migration: manually checked; balances, holdings and trades preserved without duplication.
- Browser: lesson library, incorrect/correct quiz feedback, saved completion after reload, and sign-in screen rendering checked. No browser console errors appeared in the lesson flow.
- Native engine: compiled Windows C++ library exercised by the tests.
- Linux Docker build and PostgreSQL integration: not run locally (Docker daemon unavailable); GitHub Actions configuration is included to run them.
- Supabase cloud sign-up, confirmation delivery, password reset, and deployed service-to-service connectivity: not yet verified. Requires project configuration and an email sender.
- Public market data: disabled by default pending display-rights confirmation.
- No public deployment has been created.

Local preview: http://127.0.0.1:5180 . The preview includes one completed lesson from the browser verification. It uses a separate practice database from your existing live-data account.
