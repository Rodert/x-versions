FROM node:22-alpine AS build

WORKDIR /app
COPY package.json ./
COPY index.html ./
COPY scripts ./scripts
RUN npm run build

FROM node:22-alpine
WORKDIR /app
ENV NODE_ENV=production
COPY --from=build /app/dist ./dist
COPY scripts/server.mjs ./scripts/server.mjs
EXPOSE 3000
CMD ["npm", "start"]
