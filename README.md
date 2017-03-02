# LoadBalancer-Distribuidos
<b>Autor:</b> Johan David Ballesteros <br>
<b>Código:</b>A00 <br>
<b>Repositorio:</b> https://github.com/DavidPDP/LoadBalancer-Distribuidos

##Problema
<p align ='justify'>Deberá realizar el aprovisionamiento de un ambiente compuesto por los siguientes elementos: un servidor encargado de realizar balanceo de carga, dos servidores web (puede emplear apache+php o crear un servicio web con el lenguaje de su preferencia) y un servidor de base de datos (postgresql o mysql). Se debe probar el funcionamiento del balanceador a través de una aplicación web que realice consultas a la base de datos a través de los servidores web (mostrar visualmente cual servidor web atiende la petición)</p>
####Arquitectura
![alt text]()

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
![alt text](https://github.com/DavidPDP/LoadBalancer-Distribuidos/blob/master/images/captura1.png)

###Configurando Nginx como balanceador de carga
<p align='justify'>Una vez instalado Nginx se debe proceder a configurarlo en su funcionalidad de balanceador de carga, para esto se debe proceder con los siguientes pasos: </p>
1.Se accede al archivo de configuración
```sh
# cd /etc/nginx/nginx.conf
```






