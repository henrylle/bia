FROM public.ecr.aws/docker/library/node:22-slim
RUN npm install -g npm@11 --loglevel=error

#Instalando o curl
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src/app

COPY package*.json ./

RUN npm install --loglevel=error

COPY . .

RUN NODE_OPTIONS=--openssl-legacy-provider REACT_APP_API_URL=http://bia-alb-1731596714.us-east-1.elb.amazonaws.com SKIP_PREFLIGHT_CHECK=true npm run build --prefix client

RUN mv client/build build

RUN rm  -rf client/*

RUN mv build client/

EXPOSE 8080

CMD [ "npm", "start" ]
