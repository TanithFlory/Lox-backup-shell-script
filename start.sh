CRON_EXPRESSION="0 1 * * 1"

CRON_JOB="$CRON_EXPRESSION /lox-backup/lox-backup.sh"

echo "$CRON_JOB" > /tmp/cron_job  

crontab /tmp/cron_job 

rm /tmp/cron_job

echo "Cron starting..."

exec crond -f -l 3

if [ $? -eq 0 ]; then
  echo "CRON Successful"
else 
  echo "CRON Failed"

fi
