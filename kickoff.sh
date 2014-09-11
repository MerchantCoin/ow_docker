#!/bin/bash
mkdir /var/log/datadog
mkdir /var/log/nginx
chown -R omniwallet:omniwallet /opt/omniwallet-data /var/log/nginx /var/log/datadog /var/log/ow
rm /opt/omniwallet-data/revision.json
rm /opt/omniwallet-data/msc_cron.lock
supervisord -c /etc/supervisor/supervisord.conf
