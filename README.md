# LoadBalancer-Distribuidos
<b>Autor:</b> Johan David Ballesteros <br>
<b>Código:</b>A00 <br>
<b>Repositorio:</b> https://github.com/DavidPDP/LoadBalancer-Distribuidos

##Problema
<p align ='justify'>Deberá realizar el aprovisionamiento de un ambiente compuesto por los siguientes elementos: un servidor encargado de realizar balanceo de carga, dos servidores web (puede emplear apache+php o crear un servicio web con el lenguaje de su preferencia) y un servidor de base de datos (postgresql o mysql). Se debe probar el funcionamiento del balanceador a través de una aplicación web que realice consultas a la base de datos a través de los servidores web (mostrar visualmente cual servidor web atiende la petición)</p>
####Arquitectura
![alt text](https://github.com/DavidPDP/LoadBalancer-Distribuidos/blob/master/images/diagrama_despliegue.png)

##Objetivos 
* Realizar de forma autónoma el aprovisionamiento automático de infraestructura
* Diagnosticar y ejecutar de forma autónoma las acciones necesarias para lograr infraestructuras estables
* Integrar servicios ejecutandose en nodos distintos

##Supuestos
<p align ='justify'> Se ha realizado la instalación de vagrant y del box del sistema operativo CentOS 6.5. También se ha puesto el box apuntar al mirror de CentOS y no a uno local.</p>
##Desarrollo
<p align ='justify'>Para el desarrollo del problema se deben automatizar una serie de comandos, los siguientes son los comandos identificados para futura automatización</p>
###Instalación de Nginx
<p align ='justify'>Para el servidor que tomará el rol de balanceador de cargas se procederá a instalar el Nginx, el cual es un servidor web/proxy que permite múltiples funcionalidades, entre estas la funcionalidad de balanceo de carga. Para instalar Nginx se tiene que proceder a correr los siguientes comandos: </p>
1.Accedemos hasta la carpeta de repositorios de yum
```sh
# cd /etc/yum.repos.d
```
2.Creamos un nuevo archivo de repositorio para Nginx
```sh
# vi nginx.repo
```
3.Se agrega las siguientes líneas que permiten configurar la ruta donde se procederá a descargar el nginx, específicando el sistema operativo, la versión y la arquitectura del computador. Luego de esto, se procede a guardar el archivo. 
```txt
[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/centos/$releasever/$basearch/
gpgcheck=0
enabled=1
```
4.Finalmente se instala Nginx por medio de yum.
```sh
# yum install nginx
```
![alt text](https://github.com/DavidPDP/LoadBalancer-Distribuidos/blob/master/images/imagen1.png)

###Configurando Nginx como balanceador de carga
<p align='justify'>Una vez instalado Nginx se debe proceder a configurarlo en su funcionalidad de balanceador de carga, para esto se debe proceder con los siguientes pasos: </p>
1.Se accede al archivo de configuración
```sh
# cd /etc/nginx/nginx.conf
```
2.Eliminamos el contenido del archivo predeterminado y agregamos el siguiente texto. Este texto permite configurar los servidores a los cuales el balanceador redirigirá y el puerto del balanceador donde eschuará e interceptará las peticiones. Después de esto se procede a guardar el archivo.
```txt
worker_processes  1;
events {
   worker_connections 1024;
}

http {
    upstream servers {
         server 192.168.131.3;
         server 192.168.131.4;
    }

    server {
        listen 8080;

        location / {
              proxy_pass http://servers;
        }
    }
}
```
4.Abrir el puerto 8080 por el cual asignamos el servicio de balanceador de carga.
```sh
# iptables -I INPUT -p tcp --dport 8080 --syn -j ACCEPT
```
5.Guardar los cambios del servicio de iptables.
```sh
# service iptables save
```
5.Reiniciar el servicio de iptables para que puede actualizar los cambios.
```sh
# service iptables restart
```
3.Por último se procede a iniciar el servicio de Nginx.
```sh
# service nginx start
```
##
<p align = "justify"> Una vez identificados los anteriores comandos, debemos proceder automatizarlos. Para eso se trabajará con la herramienta Vagrant, la cual permite la creación y configuración de entornos de desarrollo virtualizados. Esta herramienta después de instalada permite por medio del siguiente comando, crear un archivo llamado VagrantFile</p>
```sh
vagrant init
```
<p align="justify"> El archivo VagrantFile tiene dos propósitos principales</p>
* Marcar el directorio raíz del proyecto.
* Describir los tipos de máquina y recursos que necesita para ejecutar el proyecto.





