PROD:
    docker build -t ikonewka_backend_image -f Dockerfile_prod .
    docker run -d -p 60001:8000 --name ikonewka_backend_container --network ikonewka_network ikonewka_backend_image
DEV:
    docker build -t ikonewka_backend_dev_image -f Dockerfile_dev .
    docker run -d -p 60001:5000 --name ikonewka_backend_dev_container --network ikonewka_network ikonewka_backend_dev_image

