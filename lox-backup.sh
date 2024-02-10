source .env

NAME="MODO_SHOWROOM"
USER=$MS_USERNAME
PASSWORD=$MS_PASSWORD
IP="192.168.1.245"

if [ ! -d "/miniserver-backups/$NAME" ]; then
	mkdir "/miniserver-backups/$NAME"

fi

cd "/miniserver-backups/$NAME"

echo "[$(date +'%a %b %d %T %Y')] Loxone Miniserver Backup Initiated"

wget --tries=2 -r -N -l inf -o wget.log ftp://$USER:$PASSWORD@$IP

if [ $? -eq 0 ]; then

	echo "[$(date +'%a %b %d %T %Y')] Backup Created Successfully, Location - $(pwd)"

	echo "[$(date +'%a %b %d %T %Y')] Compressing The Backup."

	FILE_NAME="${NAME}-$(date +'%m%d%Y').tar.gz"

	tar czf "${FILE_NAME}" $IP/

	rm -r "/miniserver-backups/${NAME}/$IP"

	echo "[$(date +'%a %b %d %T %Y')] Compression Succesful."

	echo "[$(date +'%a %b %d %T %Y')] Initiating Upload To Google Drive"

	ACCESS_TOKEN=$(curl --location --request POST 'https://oauth2.googleapis.com/token' \
		--header 'Content-Type: application/x-www-form-urlencoded' \
		--data-urlencode "grant_type=refresh_token" \
		--data-urlencode "client_id=$CLIENT_ID" \
		--data-urlencode "client_secret=$CLIENT_SECRET" \
		--data-urlencode "refresh_token=$REFRESH_TOKEN" \
		--data-urlencode "redirect_uri=$REDIRECT_URI" | jq -r '.access_token' >/dev/null 2>&1)

	if [ $? -eq 0 ]; then
		echo "[$(date +'%a %b %d %T %Y')] Access Token Granted From Google Drive, Uploading Backup"

		curl -X POST -L \
			-H "Authorization: Bearer $ACCESS_TOKEN" \
			-F "metadata={name:'${FILE_NAME}'};type=application/json;charset=UTF-9" \
			-F "file=@/miniserver-backups/${NAME}/${FILE_NAME};type=application/x-tar" \
			"https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart" >/dev/null 2>&1

		if [ $? -eq 0 ]; then
			echo "[$(date +'%a %b %d %T %Y')] Upload Successful"
		else
			echo "[$(date +'%a %b %d %T %Y')] Upload Failed"
		fi

	else
		echo "Failed to generate Token."
	fi
else

	echo "${DATE} Backup Failed."

fi
