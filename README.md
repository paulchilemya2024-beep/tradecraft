# Tradecraft — first web version

An educational investing simulator with React/TypeScript, Flask, and a native C++17 execution engine. All money and trades are virtual.

## Try it locally

Run `./start.ps1` for generated demo prices at http://127.0.0.1:5178. Run `start-live.cmd` for private prompts for your Alpaca paper keys and live IEX prices at http://127.0.0.1:5179. Stop the relevant terminal with Ctrl+C. After an update, restart the server to load the new backend. Keys entered into the live launcher are held only for that process.

Fresh installation: Python 3.11+, Node.js 22.12+, and Visual Studio Build Tools with the C++ desktop workload. Run `./setup.ps1` then `./start.ps1`.

## Version 1 includes

- Ten stocks/funds, $10,000 starting cash, reviewed whole-share market orders.
- C++ integer-cent execution, bid/ask spread, realized/unrealized results.
- Persistent portfolios, private trade journals, duplicate-order protection, and atomic balances.
- Twelve lessons in four categories with examples, source links, practice exercises, quizzes, search/filtering, and saved completion.
- Hosted email sign-up, sign-in, confirmation, password recovery, and sign-out through Supabase.
- Verified authentication tokens; each user's portfolio, orders, and lesson progress are separately scoped on the server.
- Separate live and demo balances. Local mode remains accessible only on localhost.
- PostgreSQL storage for hosting; SQLite for local development. Old local tables are preserved and copied into the new schema on first use.
- Vercel frontend configuration, a Render Docker backend, health endpoint, restricted cross-origin access, and Linux/PostgreSQL CI checks.

## Host it

Read [DEPLOYMENT.md](DEPLOYMENT.md). Recommended personal/non-commercial beta: Vercel Hobby + Render Free + Supabase Free. This is a free-tier design, not a guarantee of unlimited or permanently free service. Hosting accounts and provider setup are still required. No public deployment has been made from this workspace.

The public build defaults to generated demo data. Using personal Alpaca keys does not establish public market-data display rights. Confirm those rights before enabling hosted live data.

## Source map

- `src/main.tsx`: trading dashboard.
- `src/AccountGate.tsx`, `src/api.ts`: sign-in and authenticated backend requests.
- `src/Learning.tsx`, `content/lessons.json`: learning library and quizzes.
- `backend/app.py`: authenticated account/trading/learning endpoints.
- `backend/auth.py`: asymmetric Supabase JWT verification against its public signing keys.
- `backend/storage.py`: transactional SQLite/PostgreSQL storage and local migration.
- `backend/market.py`: generated prices and optional IEX quote adapter.
- `engine/engine.cpp`: native trade calculations; Python calls the compiled library.

## Tests

```powershell
./build-engine.ps1
.venv/Scripts/python.exe -m unittest discover -s tests -v
npm run build
```

Local tests cover money calculations, concurrent orders, retries, user separation, lesson progress, token signatures/expiry/issuer/audience, and unsafe deployment configuration. PostgreSQL integration tests require `TEST_POSTGRES_URL` pointing to a dedicated test database. The GitHub Actions workflow supplies that database, builds the C++ library on Linux, runs the suite, and builds the Docker image. CI has not run until the repository is uploaded.

## Limits of the simulation

Demo movement is generated from artificial mathematical patterns, not real historical prices. It is not suitable for judging a trading strategy. Live fills approximate bid/ask quotes and do not simulate order-book depth, partial fills, slippage, dividends, splits, taxes, leverage, or short selling. The live adapter blocks stale/invalid quotes but does not implement a complete exchange holiday/session calendar. This version supports immediate market orders and whole shares only; lessons explicitly distinguish concepts from implemented features.

The backend reads live quotes at most every five seconds. The dashboard refreshes every five seconds locally and every fifteen seconds when hosted, only while the page is visible. Only one refresh can be pending at a time. There is no WebSocket or constant background market-data stream.

This is a small educational beta, not a brokerage or a production financial service. The default Gunicorn configuration uses one process and eight threads so its market cache and basic per-account write limiter are shared. Horizontal scaling requires a shared cache/limiter. Logs deliberately omit request credentials, connection strings, and SQL parameters.
