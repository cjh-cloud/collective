FROM node:alpine AS development

WORKDIR /usr/src/app

COPY package*.json ./

RUN yarn install

COPY . . 

RUN yarn build

FROM node:alpine as production

ARG NODE_ENV=production
ENV NODE_ENV=${NODE_ENV}

WORKDIR /usr/src/app

COPY package*.json ./

RUN yarn install --production=true

COPY . .

COPY --from=development /usr/src/app/dist ./dist

CMD ["node", "dist/main"]
