#docker compose up -d database
npm install --loglevel=error
npm run build --prefix client --loglevel=error
#npx sequelize db:migrate
docker compose up -d
#npm start
