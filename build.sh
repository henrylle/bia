aws ecr get-login-password --region us-east-1 --profile bia | docker login --username AWS --password-stdin 870567088900.dkr.ecr.us-east-1.amazonaws.com
docker build -t bia .
docker tag bia:latest 870567088900.dkr.ecr.us-east-1.amazonaws.com/bia:latest
docker push 870567088900.dkr.ecr.us-east-1.amazonaws.com/bia:latest