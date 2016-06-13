Docker Symfony-Drupal
=====================

Este Dockerfile esta optimizado para trabajar con Symfony2 y Drupal en entorno de desarrollo 

Crear imagen desde Dockerfile
-----------------------------
Construir la imagen basada en el Dockerfile:

    docker build -t lliccien/symfony-drupal .

Crear contenedor de Mysql oficial:

    docker run --name some-mysql -e MYSQL_ROOT_PASSWORD=my-secret-pw -d mysql

Crear contenedor como demonio definiendo: puertos, volumen y enlace con mysql basado en la imagen lliccien/symfony-drupal (la carpeta ~/www debe existir antes de crear el contenedor):

    docker run -p 80:80 -v ~/www:/var/www/html --name=testing --link some-mysql-mysql:mysql -d lliccien/symfony-drupal

Inspeccionar la configuración del contenedor para saber los datos como la ip, lo puertos, memoria, entre otros del contenedor:

    docker inspect testing

Ingresar al contenedor en modo consola:

    docker exec -it testing bash

