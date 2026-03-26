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
#sleep ${SLEEP_TIME}

echo "--> creation of ${LOG_DIR} succeed "

LOG_FILE="${LOG_DIR}/disk_usage.log"
echo "--> creation of ${LOG_FILE} is starting ..."
if [[ ! -f ${LOG_FILE} ]]; then
	touch ${LOG_FILE}
        #sleep ${SLEEP_TIME} 
        echo "--> creation of ${LOG_FILE} is succed"
else
        echo "--> LOG FILE ${LOG_FILE} already exist ..."
	#sleep ${SLEEP_TIME}
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
	#source mail/mail.attachement.sh "${disk_usage}%"
	
        #get volume groupe Free Size to extend LV
	echo "============= get volume groupe Free Size to extend LV ==========="
	V_NAME=$(vgs --noheadings 2> /dev/null | awk -F " " '{ print $1 }' )
        V_FREE=$(vgs --noheadings 2> /dev/null | awk -F " " '{ print $7 }' )
	V_SIZE=$(vgs --noheadings 2> /dev/null | awk -F " " '{ print $6 }'| sed  's/[<g]//g'  ) 
	echo
	echo "Volume group Name: $V_NAME"
	echo "Volume group Total Size: $V_SIZE"
	echo "Volume group Free Size: $V_FREE"
        echo	

	echo "============= get Information about ogical Volume       ==========="
  	L_NAME=$(lvs --noheadings 2> /dev/null | grep -i ${V_NAME} | awk -F " " 'NR==1 { print $1 }')
        L_SIZE=$(lvs --noheadings 2> /dev/null | grep -i ${L_NAME} | awk -F " " '{ print $4 }' | sed 's/[<g]//g')
	echo
	echo "Logical Volume Name: ${L_NAME}"
	echo "Logical Volume Total Size: ${L_SIZE}"

	if (( $V_FREE <= 0 ));then
		echo "Volume $V_NAME don't have enought size"
		PV_FREE=$(pvs --noheadings 2> /dev/null | grep $V_NAME |  awk -F " " '{ print $6 }' )
		echo "PV Free:  ${PV_FREE}"
	        
		#< <(...) → process substitution, permet de lire la sortie de la commande
                #readarray -t → lit chaque ligne et met chaque ligne dans un élément du tableau
                #${#LIST_PV_NAME[@]} → nombre d’éléments réel	
		#LIST_PV_NAME=$(pvs --noheadings 2> /dev/null |  awk -F " " '{ print $1 }'): ceci ne renvois pas d array
		readarray -t LIST_PV_NAME < <(pvs --noheadings 2>/dev/null | awk '{print $1}')
		#echo "${LIST_PV_NAME[@]}" # get number of pv Name
		
		echo
		for pv in ${LIST_PV_NAME[@]};do
		   #echo "pv_name: $pv --> VG: $(pvdisplay $pv 2>/dev/null| grep -i "VG NAME" | awk '{print $3}')"
		   vg=$(pvdisplay $pv 2>/dev/null| grep -i "VG NAME" | awk '{print $3}')
		   if [ -z "$vg" ]; then
			   echo "${pv} don't have a Volume Group"
		   else

			   echo "${pv} has a Volume Group name ${vg}"
	           fi
                done 
	
	fi	

	
fi
