docker-compose up -d database
call npm install --loglevel=error
call npm run build --prefix client --loglevel=error
call npx sequelize db:migrate
npm start