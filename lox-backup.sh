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

echo "${DATE} Loxone Miniserver Backup Initiated.\n"

wget --tries=2 -r -N -l inf -o wget.log ftp://$USER:$PASSWORD@$IP

if [ $? -eq 0 ]; then

	echo "${DATE} Backup Created Successfully, Location - $(pwd)"

	echo "Compressing The Backup."

	FILE_NAME="${NAME}-$(date +'%m%d%Y').tar.gz"

	tar czf "${FILE_NAME}" $IP/

	rm -r "/miniserver-backups/${NAME}/$IP"

	echo "${DATE} Compression Succesful."

	echo "${DATE} Initiating Upload To Google Drive"

	ACCESS_TOKEN=$(curl --location --request POST 'https://oauth2.googleapis.com/token' \
		--header 'Content-Type: application/x-www-form-urlencoded' \
		--data-urlencode "grant_type=refresh_token" \
		--data-urlencode "client_id=$CLIENT_ID" \
		--data-urlencode "client_secret=$CLIENT_SECRET" \
		--data-urlencode "refresh_token=$REFRESH_TOKEN" \
		--data-urlencode "redirect_uri=$REDIRECT_URI" | jq -r '.access_token')

	if [ $? -eq 0 ]; then
		echo "${DATE} Access Token Granted From Google Drive, Uploading Backup \n"

		curl -X POST -L \
			-H "Authorization: Bearer $ACCESS_TOKEN" \
			-F "metadata={name:'Backup'};type=application/json;charset=UTF-8" \
			-F "file=@/miniserver-backups/${NAME}/${FILE_NAME};type=application/x-tar" \
			"https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart"

		if [ $? -eq 0 ]; then
			echo "${DATE} Upload Successful\n"
		else
			echo "${DATE} Upload Failed\n"
		fi

	else
		echo "Failed to generate Token. \n"
	fi
else

	echo "${DATE} Backup Failed."

fi
