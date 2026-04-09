#!/bin/bash
write_log_message(){
   local error_message="$1"
   local log_file="$2"
    if [ -z "$error_message" ]; then
       echo "Error: Something was wrong. Please Try again" >> $log_file
    else
       echo "$error_message" >> $log_file
    fi
}
show_message(){
    local message="$1"
    if [ -z "$message" ]; then
       echo "please wait ..."
       sleep 2
    else
       echo "$message"
    fi
}

show_error_message(){
    local error_message="$1"
    if [ -z "$error_message" ]; then
       echo "Error: Something was wrong. Please Try again "
    else
       echo "$error_message"
    fi
}

show_version(){

    SMART_MONITOR_VERSION="1.0.1" # git tag
    show_usage 2>&1 > /dev/null
    echo "$info"
    echo "Version == $smart_monitor_version"
    echo

}

show_usage_disk_monitoring(){
    show_usage 2>&1 > /dev/null
    echo "$disks_subcommands"
    echo
    echo "$author"
    echo

}

show_usage_cpu_monitoring(){
    show_usage 2>&1 > /dev/null
    echo "$cpu_subcommands"
    echo
    echo "$author"
    echo

}

show_usage_memory_monitoring(){
    show_usage 2>&1 > /dev/null
    echo "$memory_subcommands"
    echo
    echo "$author"
    echo

}

show_usage_report(){
    show_usage 2>&1 > /dev/null
    echo "$report_command"
    echo
    echo "$author"
    echo

}

show_usage_backup(){
    show_usage 2>&1 > /dev/null
    echo "$report_command"
    echo
    echo "$author"
    echo

}

show_usage_notify(){
    show_usage 2>&1 > /dev/null
    echo "$notify_command"
    echo
    echo "$author"
    echo

}

