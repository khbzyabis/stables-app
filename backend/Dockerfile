# Multi-stage build → small, non-root runtime image.
FROM node:20-bookworm-slim AS builder
WORKDIR /app
ENV NODE_ENV=development
COPY package.json package-lock.json* ./
RUN npm ci
COPY prisma ./prisma
RUN npx prisma generate
COPY tsconfig*.json nest-cli.json ./
COPY src ./src
RUN npm run build && npm prune --omit=dev

FROM node:20-bookworm-slim AS runtime
WORKDIR /app
ENV NODE_ENV=production
# Run as the built-in non-root user.
USER node
COPY --chown=node:node --from=builder /app/node_modules ./node_modules
COPY --chown=node:node --from=builder /app/dist ./dist
COPY --chown=node:node --from=builder /app/prisma ./prisma
COPY --chown=node:node package.json ./
EXPOSE 3000
# Migrations are applied as a pre-deploy step, not on container start, so scaling
# replicas never race on the schema. Override the command to run migrations.
CMD ["node", "dist/main.js"]
