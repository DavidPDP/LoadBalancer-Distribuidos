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
# vagrant init
```
<p align="justify"> El archivo VagrantFile tiene dos propósitos principales</p>
* Marcar el directorio raíz del proyecto.
* Describir los tipos de máquina y recursos que necesita para ejecutar el proyecto.

<p align="justify"> A continuación se presenta el VagrantFile del problema</p>
<a href="https://github.com/DavidPDP/LoadBalancer-Distribuidos/blob/master/Parcial1/Vagrantfile"><b>Vista del VagrantFile</b></a>
<p align="justify"> En el vagrant se puede apreciar diferentes cosas. Lo primero son cuatro definiciones de máquinas virtuales, a cada una se le asigna una ip privada y una interfaz tipo bridge. El aprovisionamiento se realiza con la herramienta Chef, que permite aprovisionar las máquinas. En el VagrantFile chef apunta al directorio cookbooks y agrega los diferentes tipos de recipes. En el caso de los servidores web, ambos apuntan al recipe web, esto se debe a que ambos tienen la misma configuración excepto las variables que se especifican en el chef.json (variables desde el VagrantFile). Por la máquina centos_balancer es la única que se sube con el box de centos normal mientras que lass otras con el centos update, el cual está configurado para acceder a los recursos a un mirror local en la red donde se está trabajando.</p>

![alt text]()

<a href="https://github.com/DavidPDP/LoadBalancer-Distribuidos/tree/master/Parcial1/cookbooks"><b>Vista de los cookbooks</b></a>

###Aprovisionamiento
<p align="justify">Ya desarrollado la estructura de los cookbooks y configurado el archivo VagrantFile, se deben seguir los siguientes pasos para poder aprovisionar la infraestructura</p>

####Primero: Destruir Máquinas y Recursos
```sh
# vagrant destroy -f
```
<p align="justify">Este comando permite detener y destruir todas las máquinas que están siendo gestionadas por Vagrant desde el root(VagrantFile), al igual que sus recursos. Si es la primera vez que se va a realizar el aprovisionamiento, se puede obviar este paso, pero es recomendable hacerlo. La opción "-f" sirve para que el sistema no pregunte la confirmación antes de destruir la máquina.</p>
####Segundo: Levantar Máquinas y Aprovisionarlas
```sh
# vagrant up
```
<p align="justify">Este comando permite crear y configurar las máquinas virtuales acorde a la configuración del VagrantFile. Una vez ejecutado, procederá a crear y a instalar cada uno de los servicios que se le indicó por medio de la herramienta Chef. Finalmente se tiene toda la arquitectura solicitada.</p>

##Problemas
<p align="justify">El primer problema fue la instalación de servicios que no se encontraban alojados en el mirror local, esto debido a que el box utilizado apuntaba directamente al mirror local. La solución a este problema fue aprovisionar el servidor del balanceador con la box original, que accedía a mirrors remotos (Internet). Se propuso esa solución, debido a que el mirror local es compartido y no se quería dañar la configuración, lo cual afectaría el trabajo de todo el curso.<br><br>
El segundo problema fue escoger la tecnología para llevar acabo el balanceador de cargas. Entre las tecnologías se encontró Apache, Balanceador Web Pound y Nginx. Las dos primeras se llevó a cabo los tutoriales y se siguió la documentación pero no dieron resultados concretos debido a la complejidad de sus archivos de configuración. Esta complejidad radicaba en el tamaño del archivo. Se iba a seguir intentado con estas dos primeras tecnologías, pero en medio de la búsqueda se encontró que una de las funcionalidades de Nginx era balanceador de carga y con esta tecnología se había tenido un primer acercamiento en el curso, por tal motivo se decidió investigar un poco más, encontrando un <a href="https://www.youtube.com/watch?v=XdHrywooTi0"><b>tutorial</b></a> fácil donde mostraba que el archivo de configuración para la funcionalidad era relativamente simple.<br><br>
El tercer problema se debió a una mala configuración del archivo <a href="https://github.com/DavidPDP/LoadBalancer-Distribuidos/blob/master/Parcial1/cookbooks/web/templates/default/select.php.erb"><b>select.php</b></a> la cual no permitía que se visualizara la consulta. La mala configuración era una variable que se pasaba al template, esta variable se posicionó en la línea de llamado a la base de datos por parte del servidor web y cambiaba el nombre de la misma. Esto ocasionó que el servidor de base de datos pudiera ejecutar la creación de la base de datos y las tablas, y que posterior a esto el servidor web consultara una base de datos que no existía. Como resultado no se podía consultar el archivo.<br><br>
El último problema se debió a la configuración realizada en el balanceador de cargas, el cual redirigía por medio de un puerto, y no por medio de la selección de un archivo. Como el redireccionamiento dirigía al index de los servidores web, se procedió a pensar como ejecutar un la consulta desde ese archio index. Para resolver este problema, se procedió a utilizar el archivo <b>htaccess</b>, el cual permite configurar los ajustes iniciales del servidor. Con este se puede permitir por medio de una <a href ="https://github.com/DavidPDP/LoadBalancer-Distribuidos/blob/master/Parcial1/cookbooks/web/files/default/.htaccess"><b>directiva</b></a> que el HTML del index puede ser ejecutado desde un archivo PHP, permitiendo finalmente ejecutar la consulta desde el index.</p>







