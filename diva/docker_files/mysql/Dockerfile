#This is a Custom CentOS7 Image with MySQL
FROM tutum/centos:latest
MAINTAINER arvind <arvind.ks1985@gmail.com>
RUN yum install http://repo.mysql.com/mysql-community-release-el7-5.noarch.rpm -y 
RUN yum clean all
RUN yum install mysql-community-server -y
ADD my.cnf /etc/
RUN yum clean all
EXPOSE  3306
ADD start_mysql /tmp/
#ADD start_mysqld /tmp/
RUN touch /var/lib/mysql/mysql.sock
RUN chown -R mysql:mysql  /var/lib/mysql
RUN mysql_install_db
CMD /usr/sbin/mysqld --defaults-file=/etc/my.cnf 
