#!/bin/bash
mkdir /var/log/datadog
mkdir /var/log/nginx
chown -R omniwallet:omniwallet /opt/omniwallet-data /var/log/nginx /var/log/datadog /var/log/ow
rm -f /opt/omniwallet-data/revision.json
rm -f /opt/omniwallet-data/msc_cron.lock
supervisord -c /etc/supervisor/supervisord.conf
