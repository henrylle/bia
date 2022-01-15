docker-compose up -d database
npm install
cd client
npm run build
cd ..
npx sequelize db:migrate
npm start