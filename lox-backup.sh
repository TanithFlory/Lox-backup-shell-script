source .env
CREDENTIALS="$(cat credentials.json)"
for entry in $(echo "$CREDENTIALS" | jq -c '.[]'); do
	NAME=$(echo "$entry" | jq -r '.name')
	SERIAL_NUMBER=$(echo "$entry" | jq -r '.serial_number')
	USERNAME=$(echo "$entry" | jq -r '.username')
	PASSWORD=$(echo "$entry" | jq -r '.password')

	IP_HTTPS=$(curl -sS "https://dns.loxonecloud.com/?getip&snr=${SERIAL_NUMBER}&json=true" | jq -r '.IPHTTPS')
	IP=$(echo "$IP_HTTPS" | cut -d':' -f1 | tr '.' '-')
	PORT=$(echo "$IP_HTTPS" | cut -d':' -f2)

	echo "[$(date +'%a %b %d %T %Y')] Fetching backup from Loxone Cloud Server"

	curl -sS -O "https://${USERNAME}:${PASSWORD}@${IP}.${SERIAL_NUMBER}.dyndns.loxonecloud.com:${PORT}/dev/fsget/backup/sps_new.zip"

	if [ $? -ne 0 ]; then
		echo "[$(date +'%a %b %d %T %Y')] Failed To Fetch From The Server"
		exit 1
	fi

	FILE_NAME="${NAME}_$(date +'%m%d%Y_%H%M%S').zip"

	mv "sps_new.zip" "${FILE_NAME}"

	echo "[$(date +'%a %b %d %T %Y')] Initiating Upload To Google Drive"

	ACCESS_TOKEN=$(curl -sS --location --request POST 'https://oauth2.googleapis.com/token' \
		--header 'Content-Type: application/x-www-form-urlencoded' \
		--data-urlencode "grant_type=refresh_token" \
		--data-urlencode "client_id=$CLIENT_ID" \
		--data-urlencode "client_secret=$CLIENT_SECRET" \
		--data-urlencode "refresh_token=$REFRESH_TOKEN" \
		--data-urlencode "redirect_uri=$REDIRECT_URI" | jq -r '.access_token')
	if [ $? -ne 0 ]; then
		echo "[$(date +'%a %b %d %T %Y')] Failed To Generate Access Token"
		exit 1
		rm ${FILE_NAME}
	fi

	curl -sS -X POST -L \
		-H "Authorization: Bearer $ACCESS_TOKEN" \
		-F "metadata={name:'${FILE_NAME}'};type=application/json;charset=UTF-9" \
		-F "file=@/Lox-backup-shell-script/${FILE_NAME};type=application/x-tar" \
		"https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart" >/dev/null 2>&1

	if [ $? -eq 0 ]; then
		echo "$(tput setaf 2) $(date +'%a %b %d %T %Y')] Upload Successful $(tput sgr0)"
		rm ${FILE_NAME}
	else
		echo "$(tput setaf 1) [$(date +'%a %b %d %T %Y')] Upload Failed $(tput sgr0)"
	fi

done
# 		mkdir "/miniserver-backups/$NAME"
#
# 	fi
#
# 	cd "/miniserver-backups/$NAME"
#
# 	echo "[$(date +'%a %b %d %T %Y')] Loxone Miniserver Backup Initiated"
#
# 	wget --tries=2 -N -l inf -o wget.log ftp://$USER:$PASSWORD@$IP
#
# 	if [ $? -eq 00 ]; then
# 			echo "[$(date +'%a %b %d %T %Y')] Access Token Granted From Google Drive, Uploading Backup"
#
# 			curl -X POST -L \
# 				-H "Authorization: Bearer $ACCESS_TOKEN" \
# 				-F "metadata={name:'${FILE_NAME}'};type=application/json;charset=UTF-9" \
# 				-F "file=@/miniserver-backups/${NAME}/${FILE_NAME};type=application/x-tar" \
# 				"https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart" >/dev/null 2>&1
#
# 			if [ $? -eq 0 ]; then
# 				echo "[$(date +'%a %b %d %T %Y')] Upload Successful"
# 			else
# 				echo "[$(date +'%a %b %d %T %Y')] Upload Failed"
# 			fi
#
# 		else
# 			echo "Failed to generate Token."
# 		fi
# 	else
#
# 		echo "${DATE} Backup Failed."
#
# 	fi
#
# done
