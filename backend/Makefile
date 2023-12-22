build:
	docker build -t ikonewka_backend_image:$(shell ./increment_version.sh) .

tag:
	docker tag ikonewka_backend_image:$(shell cat version) 192.168.0.2:5000/ikonewka_backend_image:$(shell cat version)

push:
	docker push 192.168.0.2:5000/ikonewka_backend_image:$(shell cat version)

update:
	sed -i -r "s/ikonewka_backend_image:[0-9]+\.[0-9]+\.[0-9]+/ikonewka_backend_image:$(shell cat version)/g" ikonewka_backend_deployment.yaml

run:
	docker run -d -p 60005:8000 --name ikonewka_backend_container ikonewka_backend_image:$(shell cat version)

prod:
	$(MAKE) build tag push update
