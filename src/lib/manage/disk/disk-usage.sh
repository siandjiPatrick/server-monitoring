#!/bin/bash

: <<"COMMENT"
Description	
---------------------------------------------------------------------------------------------------
 This Skript is used to Monitore the Disk	   
 And Extend the size auf Mount point if the        
 disk usaged size reach 90%                        

---------------------------------------------------------------------------------------------------                                                   
@uthor: Patrick Siandji		
COMMENT

is_a_partition(){
    [[ $(lsblk -pnd -o TYPE $1 | head -n1) == "part" ]] 
}

#can_be_used_as_pv(){

#}

needs_pvresize() {
    local VG_NAME=$1
    #delete the first element with shift
    shift
    local PV_ATTACHED_ON_VG=("$@")
    local TOLERANCE=$(echo "4 * 1024 * 1024" | bc)
    local need_resizing=()
   
    for pv in ${PV_ATTACHED_ON_VG[@]}; do
	echo >&2
	echo "pv = $pv" >&2
	if [[  $(pvs --no-headings -o vg_name "$pv"| xargs) == "$VG_NAME" ]];then

	    if is_a_partition "$pv"; then
	        parent=$(lsblk -dn -o pkname "$pv")
	        pv_parent="/dev/$parent"
	        echo "pv parent ->  $pv_parent" >&2
	        pv_size=$(pvs --noheadings --units b --nosuffix -o pv_size "$pv" 2>/dev/null | tr -d ' ')
	        disk_size=$(lsblk -b -dn -o SIZE "$pv_parent")
	        echo "disk size $pv_parent --> $disk_size" >&2
	        echo "pv size $pv  --> $pv_size" >&2
	    else
                pv_size=$(pvs --noheadings --units b --nosuffix -o pv_size "$pv" 2>/dev/null | tr -d ' ')
                disk_size=$(lsblk -b -dn -o SIZE $pv)
	        echo "PV size $pv --> $pv_size" >&2
	        echo "disk size $pv --> $disk_size" >&2
	    fi

            #compare disk-size with pv size 
            if [[ -n "$pv_size" && -n "$disk_size" ]]; then
                diff=$((disk_size - pv_size))
                echo "diff = $diff bytes" >&2

	        if (( $(echo "$diff > $TOLERANCE" | bc) )); then
                    echo "→ pvresize needed" >&2
		    need_resizing+=("$pv")
                else
                    echo "→ no resize needed" >&2
                fi
            fi
	fi
    done

    if [ ${#need_resizing[@]} -gt 0 ];then
        echo ${need_resizing[@]}
	return 0
    else
	return 1
    fi

}


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
        
	: << COMMENT	
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
COMMENT
        #get volume groupe Free Size to extend LV
	echo "============= get volume groupe Free Size to extend LV ==========="
	V_NAME=$(vgs --noheadings 2> /dev/null | awk -F " " 'NR == 1 { print $1 }' )
        V_FREE=$(vgs --noheadings 2> /dev/null | awk -F " " 'NR == 1 { print $7 }'| sed  's/[<g]//g' )
	V_SIZE=$(vgs --noheadings 2> /dev/null | awk -F " " 'NR == 1 { print $6 }'| sed  's/[<g]//g'  ) 
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
	if [[ $(echo "$V_FREE <= 15" | bc) -eq 1  ]];then
		echo "Volume $V_NAME don't have Free Space"
		
		# check If we  have a Free physical Volume (PV) to extend the Volume Group
		readarray -t UNEXTENDED_PVS < <(pvs --noheadings -o pv_name,vg_name 2> /dev/null |awk -F " " '$2=="" { print $1 }')
		echo "PV Free:  ${UNEXTENDED_PVS[@]}"
                
                readarray -t DEVICES < <(lsblk -npr -o NAME,MOUNTPOINT | awk '$2=="" { print $1 }')
                echo ${DEVICES[@]}
		
		readarray -t PV_ATTACHED_ON_VG < <(pvs --noheadings -o pv_name 2> /dev/null | awk -F " " '{ print $1 }')
		echo "PV_ATTACHED_ON_VG ${PV_ATTACHED_ON_VG[@]}"
                
	        readarray -t need_toBe_resize < <(needs_pvresize "$V_NAME" "${PV_ATTACHED_ON_VG[@]}")	
		other_pvs=()
		free_size=()
		
		# check if we dont have unused Pvs. If so then extend VG on this Pv
                # if we have more than one PVs with free space , 
		# then we will take the pv with the biggest size to extend the VG
		if [[ ${#UNEXTENDED_PVS[@]} -gt  0 ]];then
			echo
			echo "check if we dont have unused Pvs. If so then extend VG on this Pv"
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
			#lvextend -l +100%FREE -r "dev/$V_NAME/$L_NAME"
		elif (( ${#need_toBe_resize[@]} > 0 )); then
                        echo "to be resize: ${need_toBe_resize[@]}"

                       for pv in "${need_toBe_resize[@]}"; do
                           echo "→ pvresize $pv"
                           #pvresize "$pv"
                       done
                : << 'COMMENT'
		elif needs_pvresize "$V_NAME" "${PV_ATTACHED_ON_VG[@]}"; then
			readarray -t need_toBe_resize < <(needs_pvresize "$V_NAME" "${PV_ATTACHED_ON_VG[@]}")
			echo "to be resize: ${need_toBe_resize[@]}"
			echo "pvresize disk "
		elif [ ${#DEVICES[@]} -gt 0 ]; then
			echo
		        echo "Get all unmounted Devices on the System and check if a Signature on Devices exists"
		        EMPTY_DISK_DEViCES=()
	                # check if a signature on Devices exists
	                for dev in ${DEVICES[@]};do
		               if [ $(blkid ${dev} | wc -l ) -lt 1 ];then   
				   echo
		 	           echo "@@ info:  No Signature detectet on $dev. This can be used to create PV"
			           EMPTY_DISK_DEViCES+=("$dev") 
			       
			           # create a new PV
			           pvcreate $dev
			           echo "pv with $dev was succefull created"
				   # extend the VG with the created PV 
                                   vgextend $V_NAME ${dev}
          			   echo "$V_NAME wassuccessfully extend with $dev "

			           break
		               else
		                   echo "$dev  is alreaddy in use. if you want to destroy them use the command > wipefs -a $dev"
		               fi		
		           #[[ ${#EMPTY_DISK_DEViCES[@]} == 0 ]] && \
		           #echo "Alert !!! : you have to Add a physical device to extend your disk Space"
		#else 
			       	   
			       #other_pvs=()
			       echo "$pv is an another Pv other than $V_NAME"
	                       vg=$(pvs -o vg_name --noheadings "$pv")
			       other_pvs+=("$pv $vg")
                               echo ""


                       done
 
		       echo "other pvs ${other_pvs[@]}"
	               
		       for i in ${!other_pvs[@]};do
			  pv=$(echo ${other_pvs[$i]} | awk '{ print $1 }')
			  vg=$(echo ${other_pvs[$i]} | awk '{ print $2 }')
                          vgfree_bytes=$(vgs --noheadings --nosuffix -o vg_free --units b $vg)
			  vgsize_bytes=$(vgs --noheadings --nosuffix -o vg_size --units b $vg)
                          vgfree_percent=$(awk "BEGIN { printf \"%.1f\", ($vgfree_bytes/$vgsize_bytes)*100 }")
                          echo "pv:$pv <--> vg:$vg <--> vgfree:$vgfree_bytes <--> vgfree_percent:$vgfree_percent%"
                          if [ "$(echo "$vgfree_percent > 75" | bc)" -eq 1 ]; then
				  echo "size bigger than 75%"
			  fi
		       done
		fi  
COMMENT
        else
		echo "fin"
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

