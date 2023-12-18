docker network create ikonewka_network

PROD:
    docker build -t ikonewka_mysql_image .
    docker run -d --name ikonewka_mysql_container --network ikonewka_network ikonewka_mysql_image
DEV:
    docker build -t ikonewka_mysql_dev_image .
    docker run -d -p 3306:3306 --name ikonewka_mysql_dev_container ikonewka_mysql_dev_image
