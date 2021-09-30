FROM node:14

RUN npm install -g npm@latest

WORKDIR /usr/src/app

COPY package*.json ./

RUN npm install

COPY . .

WORKDIR /usr/src/app/client

RUN REACT_APP_API_URL=http://localhost:3001 npm run build

WORKDIR /usr/src/app

RUN mv client/build build

RUN rm  -rf client/*

RUN mv build client/

EXPOSE 8080

CMD [ "npm", "start" ]