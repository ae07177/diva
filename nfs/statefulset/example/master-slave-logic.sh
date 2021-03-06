#!/bin/bash
HOST_NAME=`hostname`
if [ $HOST_NAME == "mysql-0" ]
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
binlog-do-db=diva
relay-log=/var/lib/mysql/mysql-relay-bin
relay-log-index=/var/lib/mysql/mysql-relay-bin.index
log-error = /var/lib/mysql/mysql.err
master-info-file = /var/lib/mysql/mysql-master.info
relay-log-info-file = /var/lib/mysql/mysql-relay-log.info
log-bin = /var/lib/mysql/mysql-bin
EOF

echo "Starting the MySQL Process"
/usr/sbin/mysqld --defaults-file=/etc/my.cnf &disown
echo "Running DB Configure Script"
sleep 20
/bin/sh /tmp/configure_db.sh
fi

if [ $HOST_NAME == "mysql-1" ]
then

#if [[ -f /data/ibdata1 ]] && [[ -f /data/ib_logfile0 ]]
#then
#echo "DB Files already present in /data. No Need to Copy"
#else
cp -varf /var/lib/mysql/. /data/.
#fi


cat <<EOF> /etc/my.cnf
[mysqld]
user=mysql
server-id = 2
replicate-do-db=diva
relay-log = /var/lib/mysql/mysql-relay-bin
relay-log-index = /var/lib/mysql/mysql-relay-bin.index
log-error = /var/lib/mysql/mysql.err
master-info-file = /var/lib/mysql/mysql-master.info
relay-log-info-file = /var/lib/mysql/mysql-relay-log.info
log-bin = /var/lib/mysql/mysql-bin
EOF


echo "Starting the MySQL Process"
mv /var/lib/mysql/auto.cnf /var/lib/mysql/auto.cnf.bak
/usr/sbin/mysqld --defaults-file=/etc/my.cnf  &disown
echo "Running DB Configure Script"
sleep 20
/bin/sh /tmp/configure_db.sh
fi
