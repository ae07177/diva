#!/bin/bash
HOST_NAME=`hostname`
if [ $HOST_NAME == "mysql-parallel-0" ]
then

if [[ -f /data/ibdata1 ]] && [[ -f /data/ib_logfile0 ]]
then
echo "DB Files already present in /data. No Need to Copy"
else
cp -varf /var/lib/mysql/. /data/.
fi

cat <<EOF>/etc/my.cnf
[mysqld]
user=mysql
server-id=1
log-bin="mysql-bin"
binlog-do-db=diva
replicate-do-db=diva
relay-log="mysql-relay-log"
auto-increment-offset = 1
EOF

echo "Starting the MySQL Process"
/usr/sbin/mysqld --defaults-file=/etc/my.cnf &disown
echo "Running DB Configure Script"
sleep 20
/bin/sh /tmp/configure_db.sh
fi

if [ $HOST_NAME == "mysql-parallel-1" ]
then

if [[ -f /data/ibdata1 ]] && [[ -f /data/ib_logfile0 ]]
then
echo "DB Files already present in /data. No Need to Copy"
else
cp -varf /var/lib/mysql/. /data/.
fi


cat <<EOF> /etc/my.cnf
[mysqld]
user=mysql
server-id=2
log-bin="mysql-bin"
binlog-do-db=diva
replicate-do-db=diva
relay-log="mysql-relay-log"
auto-increment-offset = 2
EOF


echo "Starting the MySQL Process"
mv /var/lib/mysql/auto.cnf /var/lib/mysql/auto.cnf.bak
/usr/sbin/mysqld --defaults-file=/etc/my.cnf  &disown
echo "Running DB Configure Script"
sleep 20
/bin/sh /tmp/configure_db.sh
fi
