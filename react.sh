#!/bin/bash
function build(){
    cd client
    # Garante que a variável tenha a porta 3001
    echo "VITE_API_URL=http://54.144.81.161:3001" > .env
    npm install
    npm run build
    cd ..
}
build