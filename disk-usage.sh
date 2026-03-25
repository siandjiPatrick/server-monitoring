#/bin/bash                                          |
#					            |
#Description					    |
#---------------------------------------------------|
# This Skript is used to Monitore the Disk	    |
# And Extend the size auf Mount point if the        |
# disk usaged size rech 90%                         |
#---------------------------------------------------|
#@uthor: Patrick Siandji			    |
#						    |
#----------------------------------------------------

SLEEP_TIME=2
LOG_FORMAT=$(date "+%Y-%m-%d %H:%M:%S")
LOG_DIR="/var/log/Monitoring"
echo
echo "--> LOG Directory ${LOG_DIR} will be created ..."
mkdir -p ${LOG_DIR}
sleep ${SLEEP_TIME}

echo "--> creation of ${LOG_DIR} succeed "

LOG_FILE="${LOG_DIR}/disk_usage.log"
echo "--> creation of ${LOG_FILE} is starting ..."
if [[ ! -f ${LOG_FILE} ]]; then
	touch ${LOG_FILE}
        sleep ${SLEEP_TIME} 
        echo "--> creation of ${LOG_FILE} is succed"
else
        echo "--> LOG FILE ${LOG_FILE} already exist ..."
	sleep ${SLEEP_TIME}
fi
echo
echo "--> check Disk usage information  ..."
echo "${LOG_FORMAT} - Disk Usage Monitoring is starting ..." >> ${LOG_FILE}

#set root directory (/) as  default mount point
# </> will be set if no param are set
MOUNT_POINT=${1:-/}

#get disk usage in %  on defined mount point
disk_usage=$(df | grep -E "${MOUNT_POINT}$" | awk -F " " '{ print $5 }' | sed "s/%//g")
disk_partition_name=$(df | grep -E "${MOUNT_POINT}$" | awk -F " " '{ print $1 }')
device_typ=$(lsblk | grep -E "${MOUNT_POINT}$" | awk -F " " '{ print $6 }')
disk_filesystem_typ=$(lsblk -f | grep -E "${MOUNT_POINT}$" | awk -F " " '{ print $2 }')
echo
echo "Device Typ: ${device_typ}"
echo "Aktuel Disk Usage on '${MOUNT_POINT}' :  ${disk_usage}%"
echo "Disk Partition Name:  ${disk_partition_name}"
echo "Disk Filesystem typ:  ${disk_filesystem_typ}"
echo

# Limit the disk Usage on MOUNT Point of 10%
DISK_USAGE_LIMIT=10

if (( $disk_usage > $DISK_USAGE_LIMIT )); then
	echo "[ ALERT !!! ] Disk usage over ${DISK_USAGE_LIMIT}%"
	source ../Mail/mail.attachement.sh
fi


