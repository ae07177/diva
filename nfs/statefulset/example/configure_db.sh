#!/bin/bash
echo "DB Setup Started"
HOST_NAME=`hostname`
if [ $HOST_NAME == "mysql-0" ]
then
echo "Performing Master Setup"
mysql -u root -proot123  << EOF
create database diva;
GRANT REPLICATION SLAVE ON *.* TO 'root'@'%' IDENTIFIED BY 'root123';
FLUSH PRIVILEGES;
USE diva;
FLUSH TABLES WITH READ LOCK;
SHOW MASTER STATUS;
exit
EOF
fi

if [ $HOST_NAME == "mysql-1" ]
then
LOG=`mysql -uroot -proot123 -h mysql-0.mysql -e "show master status" | awk '{print $1}' | tail -1`
POS=`mysql -uroot -proot123 -h mysql-0.mysql -e "show master status" | awk '{print $2}' | tail -1`
export LOG
export POS
mysql -u root -proot123 << EOF
stop slave ;
CREATE DATABASE diva;
CHANGE MASTER TO MASTER_HOST='mysql-0.mysql',MASTER_USER='root', MASTER_PASSWORD='root123', MASTER_LOG_FILE='${LOG}', MASTER_LOG_POS=  ${POS};
SET GLOBAL SQL_SLAVE_SKIP_COUNTER = 1;
start SLAVE ;
EXIT
EOF



fi
