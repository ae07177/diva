#!/bin/bash
echo "DB Setup Started"
HOST_NAME=`hostname`

if [ $HOST_NAME == "mysql-parallel-0" ]
then
echo "Performing Master Setup"
mysql -u root -proot123 -e "CREATE USER 'root'@'%' IDENTIFIED BY 'root123'"
mysql -u root -proot123 -e "GRANT REPLICATION SLAVE ON *.* TO 'root'@'%'" 
mysql -u root -proot123 -e "FLUSH PRIVILEGES"

fi

if [ $HOST_NAME == "mysql-parallel-1" ]
then
echo "Performing Master Setup"
mysql -u root -proot123 -e "CREATE USER 'root'@'%' IDENTIFIED BY 'root123'"
mysql -u root -proot123  -e "GRANT REPLICATION SLAVE ON *.* TO 'root'@'%'"
mysql -u root -proot123 -e "FLUSH PRIVILEGES"

LOG=`mysql -uroot -proot123 -h mysql-parallel-0.mysql-parallel -e "show master status" | awk '{print $1}' | tail -1`
echo "LOG is $LOG"
POS=`mysql -uroot -proot123 -h mysql-parallel-0.mysql-parallel -e "show master status" | awk '{print $2}' | tail -1`
echo "POS - $POS"

echo "Stopping Slave on mysql-1"
mysql -uroot -proot123 -e "stop slave"
echo "Configuring Master on mysql-1"
mysql -uroot -proot123 -e "CHANGE MASTER TO MASTER_HOST = 'mysql-parallel-0.mysql-parallel',MASTER_USER = 'root', MASTER_PASSWORD = 'root123', MASTER_LOG_FILE = '${LOG}', MASTER_LOG_POS = ${POS};"
echo "Starting Slave on mysql-1"
mysql -uroot -proot123 -e "start slave"


LOG=`mysql -uroot -proot123 -h mysql-parallel-1.mysql-parallel -e "show master status" | awk '{print $1}' | tail -1`
echo $LOG
POS=`mysql -uroot -proot123 -h mysql-parallel-1.mysql-parallel -e "show master status" | awk '{print $2}' | tail -1`
echo $POS

mysql -uroot -proot123 -h mysql-parallel-0.mysql-parallel -e "stop slave"
mysql -uroot -proot123 -h mysql-parallel-0.mysql-parallel -e "CHANGE MASTER TO MASTER_HOST = 'mysql-parallel-1.mysql-parallel',MASTER_USER = 'root', MASTER_PASSWORD = 'root123', MASTER_LOG_FILE = '${LOG}', MASTER_LOG_POS = ${POS};" 
mysql -uroot -proot123 -h mysql-parallel-0.mysql-parallel -e "start slave"

fi
