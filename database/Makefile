
network:
	docker network create ikonewka_network

build:
	docker build -t ikonewka_mysql_image .

run:
	docker run -d --name ikonewka_mysql_container --network ikonewka_network ikonewka_mysql_image

tag:
	docker tag ikonewka_mysql_image 192.168.0.2:5000/ikonewka_mysql_image

push:
	docker push 192.168.0.2:5000/ikonewka_mysql_image
