NAME="MODO_SHOWROOM"
IP="192.168.1.245"
DATE="[$(date +'%a %b %d %T %Y')]"
cd /miniserver-backups/$NAME

echo "${DATE} Loxone Miniserver Backup Initiated."

wget --tries=2 -r -N -l inf -o wget.log ftp:://$USER:$PASSWORD@$IP

if [$? -eq 0]; then

	echo "${DATE} Backup Created Successfully, Location - $(pwd)/${NAME}"

	echo "Compressing The Backup."

	tar czf backup-$(date+"%a %b %d %T %Y").tar.gz $IP/

	echo "${DATE} Compression Succesful."

else

	echo "${DATE} Backup Failed."

fi
