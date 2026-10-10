# One image recipe for the CRM services (api, migrate, app). Each compose service
# picks a target. The eve research agent is deliberately not built or deployed.
# Node 24 for Next.js and the Prisma CLI, plus the Bun the repo pins.
FROM oven/bun:1.3.12-debian AS bun
FROM node:24-bookworm-slim AS base
COPY --from=bun /usr/local/bin/bun /usr/local/bin/bun
RUN ln -s /usr/local/bin/bun /usr/local/bin/bunx \
 && apt-get update && apt-get install -y --no-install-recommends ca-certificates openssl curl git \
 && rm -rf /var/lib/apt/lists/*
WORKDIR /repo
ENV CRM_TELEMETRY_DISABLED=1 \
    NEXT_TELEMETRY_DISABLED=1

# Install once for the whole workspace. postinstall runs `prisma generate`,
# which needs a DATABASE_URL to parse the config but never connects.
FROM base AS deps
COPY . .
RUN DATABASE_URL="postgresql://build:build@localhost:5432/build" bun install --frozen-lockfile

# ── API (NestJS on Bun) ──────────────────────────────────────────────────────
FROM deps AS api
WORKDIR /repo/apps/api
RUN bun run build
ENV NODE_ENV=production PORT=3001
EXPOSE 3001
CMD ["bun", "dist/main.js"]

# ── One-shot: apply migrations, then exit ────────────────────────────────────
FROM deps AS migrate
WORKDIR /repo/packages/db
CMD ["bunx", "prisma", "migrate", "deploy"]

# ── App (Next.js). API_URL is inlined at build time by next.config.ts ───────
FROM deps AS app
ARG API_URL
ARG APP_URL
ENV API_URL=$API_URL NEXT_PUBLIC_API_URL=$API_URL APP_URL=$APP_URL
WORKDIR /repo/apps/app
RUN DATABASE_URL="postgresql://build:build@localhost:5432/build" \
    BETTER_AUTH_SECRET="build-only-not-a-secret-build-only" \
    bun run build
ENV NODE_ENV=production PORT=3000
EXPOSE 3000
CMD ["bun", "run", "start"]
