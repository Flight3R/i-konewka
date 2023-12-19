
build:
	docker build -t ikonewka_backend_image .

run:
	docker run -d -p 60001:8000 --name ikonewka_backend_container --network ikonewka_network ikonewka_backend_image

tag:
	docker tag ikonewka_backend_image 192.168.0.2:5000/ikonewka_backend_image

push:
	docker push 192.168.0.2:5000/ikonewka_backend_image
