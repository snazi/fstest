FROM node:22-alpine
WORKDIR /app

COPY package.json ./
COPY packages/shared/package.json packages/shared/package.json
COPY apps/api/package.json apps/api/package.json
RUN npm install

COPY packages/shared packages/shared
COPY apps/api apps/api
RUN npm run build -w @flashsale/shared && npm run build -w @flashsale/api

WORKDIR /app/apps/api
EXPOSE 3001
CMD ["npm", "run", "start"]
