#/bin/bash

: <<"COMMENT"
Description	
---------------------------------------------------------------------------------------------------
 This Skript is used to Monitore the Disk	   
 And Extend the size auf Mount point if the        
 disk usaged size reach 90%                        

---------------------------------------------------------------------------------------------------                                                   
@uthor: Patrick Siandji		
COMMENT

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

echo "--> check Disk usage information  ..."
echo "${LOG_FORMAT} - Disk Usage Monitoring is starting ..." >> ${LOG_FILE}

#set root directory (/) as  default mount point
# </> will be set if no param are set
MOUNT_POINT=${1:-/}

#get disk usage in %  on defined mount point
disk_usage=$(df | grep -E "${MOUNT_POINT}$" | awk -F " " '{ print $5 }' | sed "s/%//g")
disk_partition_name=$(df | grep -E "${MOUNT_POINT}$" | awk -F " " '{ print $1 }')
device_typ=$(lsblk | grep  -E "${MOUNT_POINT}$" | awk -F " " '{ print $6 }' | uniq)
disk_filesystem_typ=$(lsblk -f | grep -E "${MOUNT_POINT}$" | awk -F " " '{ print $2 }' | uniq)

echo
echo "Device Typ: ${device_typ}"
echo "Aktuel Disk Usage on '${MOUNT_POINT}' :  ${disk_usage}%"
echo "Disk Partition Name:  ${disk_partition_name}"
echo "Disk Filesystem typ:  ${disk_filesystem_typ}"
# Limit the disk Usage on MOUNT Point of 10%
DISK_USAGE_LIMIT=10

if [ "$(echo "$disk_usage > $DISK_USAGE_LIMIT" | bc )" -eq 1 ]; then
	echo
	echo "[ ALERT !!! ] Disk usage over ${DISK_USAGE_LIMIT}%"
	
	TO="siandjipatrick@yahoo.fr"
        SUBJECT="[ ALERT !!! ] Disk usage over ${DISK_USAGE_LIMIT}%"
        FROM="Monitoring Service  <monitoring-service@gmail.com>"
        BODY=""
        USERNAME="Devops-Team"
        STATUS="BAD"
        COLOR_STATUS="red"
	MAIL_TITLE="Disk Server Monitoring on $LOG_FORMAT"
        DISK_PART_NAME="${disk_partition_name}"
        DEVICE_TYPE="${device_typ}"
        MOUNT_POINT="${MOUNT_POINT}"
        DISK_FS_TYP="${disk_filesystem_typ}"
        DISK_USAGE="${disk_usage}%"
        
	
	source mail/send-monitoring-mail.sh \
	"$TO"                  \
        "$SUBJECT"             \
        "$FROM"                \
        "$BODY"                \
        "$USERNAME"            \
        "$STATUS"              \
        "$COLOR_STATUS"        \
        "$MAIL_TITLE"          \
        "$DISK_PART_NAME"      \
        "$DEVICE_TYPE"         \
        "$MOUNT_POINT"         \
        "$DISK_FS_TYP"         \
        "$DISK_USAGE"          

        #get volume groupe Free Size to extend LV
	echo "============= get volume groupe Free Size to extend LV ==========="
	V_NAME=$(vgs --noheadings 2> /dev/null | awk -F " " '{ print $1 }' )
        V_FREE=$(vgs --noheadings 2> /dev/null | awk -F " " '{ print $7 }'| sed  's/[<g]//g' )
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
       
	# --> check if we still have more free space in the volume group
	# --> Extend the Volume Group if we still have more free space in the volume group
	# --> check If we  have a phisical Volume (PV) to extend the Volume Group
	# --> Check if the PV is already attached to one Lolume Group (VG)
	# --> Create a PV IF we dont have one
	# --> Check if we have unmount and unsigned disk Device 
	# --> if we dont have a phisical Device to create a PV we will print an Alert message
	# --> Alert message -> this disk is full an cannot be extend. You need to Add a physical device	
	
	# 1-check if we still have more free space in the volume group
	if [[ $(echo "$V_FREE <= 10" | bc) -eq 1  ]];then
		echo "Volume $V_NAME don't have Free Space"
		
		# check If we  have a Free physical Volume (PV) to extend the Volume Group
		readarray -t UNEXTENDED_PVS < <(pvs --noheadings -o pv_name,vg_name 2> /dev/null |
				     awk -F " " '$2 == "" { print $1 }')
		echo "PV Free:  ${UNEXTENDED_PVS[@]}"
		
		free_size=()
		# if we have more than one PV with free space , 
		# then we will take the pv with the biggest to extend the VG
		if [[ ${#UNEXTENDED_PVS[@]} -gt  0 ]];then
			for pv in ${UNEXTENDED_PVS[@]};do
				free_size+=($(pvs --noheadings -o pv_free $pv 2> /dev/null | sed 's/[<>]//g'))
			done
			readarray -t sorted_free_size < <(printf "%s\n" "${free_size[@]}" | sort -nr)
		   	echo "free size : ${sorted_free_size[@]}"
			readarray pv_big_size < <(pvs --noheadings -o pv_name,pv_free,vg_name |
			                		          grep ${sorted_free_size[0]} |
								  awk ' $3 == "" {print $1}')
			echo "PV with big size --> ${pv_big_size[0]}"
			
			# extend the VG with the PV with the biggest size
			vgextend $V_NAME ${pv_big_size[0]}	

			# extend LV
		   
			# resize FS on LV
			#if  ;then

		        #fi
		else
	               echo "All Pvs are already extended"
		       #Check if we have unmount and unsigned disk Device 
		       echo "Get all unmounted Devices on the System"
		       readarray -t DEVICES < <(lsblk -npr -o NAME,MOUNTPOINT | awk '$2=="" { print $1 }')
		       echo ${DEVICES[@]}
		    
		       EMPTY_DISK_DEViCES=()
		       # check if a signature on Devices exists
		       for dev in ${DEVICES[@]};do
		            if [ $(blkid ${dev} | wc -l ) -lt 1 ];then   
		 	         echo "@@ info >>> disk $dev will be used to create PV"
			         EMPTY_DISK_DEViCES+=("$dev") 
			       
			         # create a new PV
			         echo "PV will be created with the first match ${dev} ..."
			         pvcreate $dev
			         echo "pv was succefull created"
				 # extend the VG with the created PV 
                                 vgextend $V_NAME ${dev}
          
			         break
		           else
		                 echo "Warning: Disk $dev is not empty. It will be remove from empty disk devices set"
			         #unset $dev $DEVICES
		           fi		
		       done
		       [[ ${#EMPTY_DISK_DEViCES[@]} == 0 ]] && \
		       echo "Alert !!! : you have to Add a physical device to extend your disk Space"
	        fi
	else
		# Extend Lv of 100%free space
		echo
		echo "The Logical Vaolume (LV)  $L_NAME will be extend of $V_FREE"
		#lvextend -l %100FREE -r /dev/${V_NAME}/${L_NAME}

		
	
	fi

	#Extend the Logical Volume Size  and Resize the Filesystem
	#Todo extend to 10% of VG
	#lvextend -L +1K -r  /dev/${V_NAME}/${L_NAME} 2> /dev/null
fi
