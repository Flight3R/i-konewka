build:
	docker build -t ikonewka_mysql_image:$(shell ./increment_version.sh) .

tag:
	docker tag ikonewka_mysql_image:$(shell cat version) 192.168.0.2:5000/ikonewka_mysql_image:$(shell cat version)

push:
	docker push 192.168.0.2:5000/ikonewka_mysql_image:$(shell cat version)

update:
	sed -i -r "s/ikonewka_mysql_image:[0-9]+\.[0-9]+\.[0-9]+/ikonewka_mysql_image:$(shell cat version)/g" ikonewka_mysql_deployment.yaml

network:
	docker network create ikonewka_network

run:
	docker run -d --name ikonewka_mysql_container --network ikonewka_network ikonewka_mysql_image

prod:
	$(MAKE) build tag push update