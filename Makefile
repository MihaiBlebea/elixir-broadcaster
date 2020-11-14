
docker-up:
	docker-compose build &&\
	docker-compose up -d

docker-down:
	docker-compose stop &&\
	docker-compose rm

docs:
	mix docs