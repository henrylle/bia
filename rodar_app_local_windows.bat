@echo off
docker-compose up -d database
if %errorlevel% neq 0 exit /b %errorlevel%
call npm install -g npm@latest --loglevel=error
call npm install --loglevel=error
call npm run build --prefix client --loglevel=error
call npx sequelize db:migrate
npm start
