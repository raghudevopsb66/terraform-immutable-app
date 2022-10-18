#!/bin/bash

if [ -f /etc/nginx/default.d/roboshop.conf ]; then
  sed -i -e "s/ENV/${ENV}/" /etc/nginx/default.d/roboshop.conf /etc/filebeat/filebeat.yml
  systemctl restart nginx
  systemctl restart filebeat
  exit
fi

MEM=$(echo $(free -m  | grep ^Mem | awk '{print $2}')*0.8 |bc | awk -F . '{print $1}')
sed -i  -e "s/ENV/${ENV}/" \
        -e "/Environment=REDIS_HOST=/ c Environment=REDIS_HOST=${REDIS_ENDPOINT}" \
        -e "/MONGO_URL/ c Environment=MONGO_URL=\"mongodb://${DOCDB_USER}:${DOCDB_PASS}@${DOCDB_ENDPOINT}:27017/${DB_NAME}?tls=true&replicaSet=rs0&readPreference=secondaryPreferred&retryWrites=false\"" \
        -e "/DB_HOST/ c Environment=DB_HOST=${MYSQL_ENDPOINT}" \
        -e "s/1439/$MEM/g" \
         /etc/systemd/system/${COMPONENT}.service /etc/filebeat/filebeat.yml

systemctl daemon-reload
systemctl restart ${COMPONENT}
systemctl enable ${COMPONENT}
systemctl restart filebeat
