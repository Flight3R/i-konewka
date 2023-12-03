sudo docker network create ikonewka_network
sudo docker build -t ikonewka_mysql_image .

PROD:
    sudo docker run -d --name ikonewka_mysql_container --network ikonewka_network ikonewka_mysql_image
DEV:
    sudo firewall-cmd --zone=public --add-port=3306/tcp
    sudo docker run -d -p 3306:3306 --name ikonewka_mysql_container ikonewka_mysql_image


sudo firewall-cmd --zone=public --add-port=60001/tcp
PROD:
    sudo docker build -t ikonewka_backend_image -f Dockerfile_prod .
    sudo docker run -d -p 60001:8000 --name ikonewka_backend_container --network ikonewka_network ikonewka_backend_image
DEV:
    sudo docker build -t ikonewka_backend_dev_image -f Dockerfile_dev .
    sudo docker run -d -p 60001:5000 --name ikonewka_backend_dev_container --network ikonewka_network ikonewka_backend_dev_image

