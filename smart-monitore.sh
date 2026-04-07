#!/bin/bash

#set -euo pipefail

USAGE_FILE="$(dirname "$0")/usage.sh"
UTILS_FILE="$(dirname "$0")/utils.sh"
NOTIFY_EMAIL_FILE="$(dirname "$0")/notify/email.sh"

if [[ -f "$USAGE_FILE" ]]; then
    source "$USAGE_FILE"
else
    echo "Error: usage.sh not found"
    exit 1
fi

if [[ -f "$UTILS_FILE" ]]; then
    source "$UTILS_FILE"
else
    echo "Error: usage.sh not found"
    exit 1
fi

if [[ -f "$NOTIFY_EMAIL_FILE" ]]; then
    source "$NOTIFY_EMAIL_FILE"
else
    echo "Error: usage.sh not found"
    exit 1
fi




main(){

        case "${1:-}" in
            ""|-h|--help)
                show_message ""
                show_usage
                exit 0
                ;;

            -v|--version)       
                show_message ""
                show_version
                exit 0
                ;;

            -s|status)
                show_message "Show current system status (CPU, memory, disk, load, etc.) in progress ..."
                sleep 2
                exit 0
                ;;

            disk|DISK)
                case $2 in 
                    ""|--help)
                        show_usage_disk_monitoring
                        exit 0
                        ;;
                    -h|--human)
                        show_message "Human-readable sizes"
                        exit 0
                        ;;
                    --threshold)
                        show_message "Show warning if usage exceeds threshold"
                        exit 0
                        ;;
                    top)
                        case $3 in
                            "")
                                show_message "Show largest directories under a given path"
                                exit 0
                                ;;
                            -n|--limit)
                                show_message "Number of entries to display (default: 10)"
                                shift
                                ;;
                            --sort)
                                show_message "Sort by size"
                                shift
                                ;;
                            *)
                                show_error_message "Error: command not Found! please check > $0 $1 --help "
                                ;;
                        esac
                        ;;
                    extend)
                        case $3 in
                            "")
                                show_message "Extend disk (LVM-based systems)"
                                exit 0
                                ;;
                            --auto)
                                show_message "Automatically extend if possible"
                                shift
                                ;;
                            --yes)
                                show_message "Skip confirmation prompt"
                                shift
                                ;;
                            --size)
                                show_message "Target size"
                                shift
                                ;;
                            *)
                                show_error_message "Error: command not Found! please check > $0 $1 --help "
                                ;;
                        esac
                        ;;
                    *)
                        show_error_message "Error: command not Found! please check > $0 $1 --help "
                        ;;
                esac
                ;;

            cpu|CPU)
                case $2 in 
                    ""|--help)
                        show_usage_cpu_monitoring
                        exit 0
                        ;;
                   
                    top)
                        case $3 in
                            "")
                                show_message "Show top CPU-consuming processes"
                                ;;
                            -n|--limit)
                                show_message "Number of processes to display"
                                shift
                                ;;
                            *)
                                show_error_message "Error: command not Found! please check > $0 $1 --help "
                                ;;
                        esac
                        ;;
                    usage)
                        
                        show_message "Show overall CPU usage statistics"
                        shift
                        ;;
                           
                    *)
                        show_error_message "Error: command not Found! please check > $0 $1 --help "
                        ;;
                esac
                ;;
         
            memory)
                case $2 in 
                    ""|--help)
                        show_usage_memory_monitoring
                        exit 0
                        ;;
                *)
                    show_error_message "Error: command not Found! please check > $0 $1 --help "
                    ;;
                esac
                ;;
            
            report)
                case $2 in 
                    ""|--help)
                        show_usage_report
                        exit 0
                        ;;
                *)
                    show_error_message "Error: command not Found! please check > $0 $1 --help "
                    ;;
                esac
                ;;
            backup)
                case $2 in 
                    ""|--help)
                        show_usage_backup
                        exit 0
                        ;;
                *)
                    show_error_message "Error: command not Found! please check > $0 $1 --help "
                    ;;
                esac
                ;;
            notify)
                case $2 in 
                    ""|--help)
                        show_usage_notify
                        exit 0
                        ;;
                    email)
                        case $3 in
                            "")
                                show_message "Send notification via email"
				DEFAULT_RECIPIENT="siandjipatrick@yahoo.fr"
				DEFAULT_SUBJECT="Patrickstyl - Homelab Monitoring"
				send_email
                                ;;
                            --to)
                                show_message "Recipient email"
                                shift
                                ;;
                            --subject)
                                show_message "Email subject"
                                shift
                                ;;
                            *)
                                show_error_message "Error: command not Found! please check > $0 $1 --help "
                                ;;
                        esac
                        ;;
                *)
                    show_error_message "Error: command not Found! please check > $0 $1 --help "
                    ;;
                esac
                ;;
        esac

}

main "$@"
