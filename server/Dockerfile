FROM node:18-alpine

RUN apk add --no-cache sqlite

WORKDIR /app

COPY package.json ./
RUN npm install --production

COPY dist/ ./dist/
COPY scripts/ ./scripts/

RUN mkdir -p /app/data

VOLUME ["/app/data"]

ENV NODE_ENV=production
ENV PORT=3001
ENV DB_PATH=/app/data/carbonlink.db
ENV ADMIN_DB_PATH=/app/data/carbonlink_admin.db

EXPOSE 3001

CMD ["node", "dist/index.js"]