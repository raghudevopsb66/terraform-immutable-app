#!/bin/bash

if [ -f /etc/nginx/default.d/roboshop.conf ]; then
  sed -i -e "s/ENV/${ENV}/" /etc/nginx/default.d/roboshop.conf /etc/filebeat/filebeat.yml
  systemctl restart nginx
  systemctl restart filebeat
  exit
fi
MEM=$(echo $(free -m  | grep ^Mem | awk '{print $2}')*0.8 |bc | awk -F . '{print $1}')
sed -i -e "s/ENV/${ENV}/" -e "/REDIS_HOST/ c Environment=REDIS_HOST=${REDIS_ENDPOINT}" -e ""



-e "s/DOCDB_ENDPOINT/${DOCDB_ENDPOINT}/" -e "s/DOCDB_USER/${DOCDB_USER}/" -e "s/DOCDB_PASS/${DOCDB_PASS}/" -e "s/RABBITMQ_USER_PASSWORD/${RABBITMQ_USER_PASSWORD}/" -e "/java/ s/MEM/$MEM/g" -e "s/MYSQL_ENDPOINT/${MYSQL_ENDPOINT}/" -e "s/REDIS_ENDPOINT/${REDIS_ENDPOINT}/"  /etc/systemd/system/${COMPONENT}.service /etc/filebeat/filebeat.yml

systemctl daemon-reload
systemctl restart ${COMPONENT}
systemctl enable ${COMPONENT}
systemctl restart filebeat