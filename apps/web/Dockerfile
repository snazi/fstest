FROM node:22-alpine
WORKDIR /app

COPY package.json ./
COPY packages/shared/package.json packages/shared/package.json
COPY apps/web/package.json apps/web/package.json
RUN npm install

COPY packages/shared packages/shared
COPY apps/web apps/web
RUN npm run build -w @flashsale/web

WORKDIR /app/apps/web
EXPOSE 3000
CMD ["npm", "run", "start", "--", "-H", "0.0.0.0", "-p", "3000"]
