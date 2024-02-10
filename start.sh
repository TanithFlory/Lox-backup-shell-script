CRON_EXPRESSION="30 19 * * *"

CRON_JOB="$CRON_EXPRESSION /Lox-backup-shell-script/lox-backup.sh"

echo "$CRON_JOB" >/tmp/cron_job

crontab /tmp/cron_job

rm /tmp/cron_job

echo "Cron starting..."

exec cron -f -l 3
