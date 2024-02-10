source .env

NAME="MODO_SHOWROOM"
USER=$MS_USERNAME
PASSWORD=$MS_PASSWORD
IP="192.168.1.245"
DATE="[$(date +'%a %b %d %T %Y')]"

if [ ! -d "/miniserver-backups/$NAME" ]; then
	mkdir "/miniserver-backups/$NAME"

fi

cd "/miniserver-backups/$NAME"

echo "${DATE} Loxone Miniserver Backup Initiated."

wget --tries=2 -r -N -l inf -o wget.log ftp://$USER:$PASSWORD@$IP

if [ $? -eq 0 ]; then

	echo "${DATE} Backup Created Successfully, Location - $(pwd) "

	echo "Compressing The Backup."

	tar czf "${NAME}-$(date +'%m%d%Y').tar.gz" $IP/

	rm -r "/miniserver-backups/${NAME}/$IP"

	echo "${DATE} Compression Succesful."

else

	echo "${DATE} Backup Failed."

fi
