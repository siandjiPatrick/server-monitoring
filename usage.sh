#!/bin/bash
show_usage() {

info="${INFO:-🧰🚀 smart-monitor - System Monitoring & Automation CLI Tool}"

local usage="${USAGE:-$(cat <<EOF
ℹ️ Usage:
==================================================================================
   smart-monitor [GLOBAL OPTIONS] COMMAND [SUBCOMMAND] [ARGS...]
EOF
)}"

local description="${DESCRIPTION:-$(cat <<EOF
ℹ️ Description:
==================================================================================
  📊 smart-monitor is a system monitoring and automation CLI tool that can
  📡 collect metrics, 🧠 analyze system state, 📄 generate reports,
  ⚙️ trigger actions, and 📤 publish results via multiple outputs
  (terminal, JSON, email, web).
EOF
)}"

local global_options="${GLOBAL_OPTIONS:-$(cat <<EOF
⚙️ Global Options:
==================================================================================
  ❓ -h, --help              Show help
  🏷️ -v, --version           Get the Version of smart-monitor
EOF
)}"

local commands="${COMMANDS:-$(cat <<EOF
Commands:
==================================================================================

  👉📡 status    Show current system status (CPU, memory, disk, load, etc.)
  👉💾 disk      Disk operations and analysis
  👉⚡  cpu       CPU monitoring and statistics
  👉🧠 memory    Memory usage and statistics
  👉📊 report    Generate system reports with optional output targets
  👉🔁 monitor   Continuous monitoring mode (real-time or interval-based)
  👉🗄️ backup    Backup operations for filesystems and data
  👉🌐 notify    Send notifications (email, webhooks, integrations)
EOF
)}"

disks_subcommands="${DISKS_SUBCOMMANDS:-$(cat <<EOF
💾 Disk Subcommands :
=================================================================================

  📂 disk usage [OPTIONS] [MOUNTPOINT]
  Description: Show disk usage for all or specific mountpoint

  Options:
      ⚙️ -h, --human               Human-readable sizes
      🚨 --threshold PERCENT       Show warning if usage exceeds threshold

  👉📁 disk top [PATH]             Show largest directories under a given path
      Options:
        🔢 -n, --limit N           Number of entries to display (default: 10)
        ↕️ --sort size             Sort by size

  👉📦 disk extend [MOUNTPOINT]    Extend disk (LVM-based systems)
      Options:
        🤖 --auto                  Automatically extend if possible
        📏 --size SIZE             Target size
        ✅ --yes                   Skip confirmation prompt
EOF
)}"

cpu_subcommands="${CPU_SUBCOMMANDS:-$(cat <<EOF
⚡ CPU Subcommands:
==================================================================================

  👉🔥 cpu top              Show top CPU-consuming processes
      Options:
        🔢 -n, --limit N    Number of processes to display

  👉📊 cpu usage            Show overall CPU usage statistics
EOF
)}"

memory_subcommands="${MEMORY_SUBCOMMANDS:-$(cat <<EOF
🧠 Memory Subcommands:
==================================================================================
  memory usage: Show memory usage statistics

  👉🧾 memory top           Show memory-heavy processes
EOF
)}"

report_command="${REPORT_COMMAND:-$(cat <<EOF
📊 Report Command:
==================================================================================
  report generate: Generate a system report

  Options:
      📄 --format FORMAT     Output format (text, json, html)
      💾 --output FILE       Save report to file
      📤 --to DESTINATION    Send report to destination: 📧email | 🌐web | file | stdout
      📧 --email ADDRESS     Email recipient
      🌐 --web URL           Web endpoint for publishing
EOF
)}"

backup_command="${BACKUP_COMMAND:-$(cat <<EOF
🗄️ Backup Command:
==================================================================================
  backup usage: Perform backup operations

  Options:
    📥 --source PATH         Source directory
    📤 --dest PATH           Destination directory
    🗜️ --compress            Compress backup
    🔁 --incremental         Incremental backup
    ⏰ --schedule CRON       Schedule backup via cron
EOF
)}"

notify_command="${NOTIFY_COMMAND:-$(cat <<EOF
🌐 Notify Command:
==================================================================================

👉📧 notify email            Send notification via email
      Options:
        📬 --to ADDRESS      Recipient email
        📝 --subject TEXT    Email subject

  👉🌍 notify web            Send notification to a web endpoint (webhook)
      Options:
        🔗 --url URL         Webhook URL
        📡 --method METHOD   HTTP method (POST/PUT)
EOF
)}"

local examples="${EXAMPLES:-$(cat <<EOF
📚 Examples:

  🚀 smart-monitor status
  🚀 smart-monitor disk usage --human
  🚀 smart-monitor disk top /home
  🚀 smart-monitor cpu top -n 5
  🚀 smart-monitor report generate --format html --to web
  🚀 smart-monitor report generate --to email --email admin@example.com
  🚀 smart-monitor monitor --interval 60 --alert
  🚀 smart-monitor backup --source /data --dest /backup
  🚀 smart-monitor notify email --to admin@example.com
  🚀 smart-monitor notify web --url https://example.com/webhook
EOF
)}"

smart_monitor_version="${SMART_MONITOR_VERSION:-1.0.0}"

local author_name="${AUTHOR_NAME:-Patrick Siandji}"
local author_email="${AUTHOR_EMAIL:-siandjipatrick@yahoo.fr}"
author="${AUTHOR:-Author: $author_name <$author_email>}"

################### print usage of smart-monitor tool #######################
cat <<EOF


$info            
$author

$usage

$description

$global_options

$commands

$disks_subcommands

$cpu_subcommands

$memory_subcommands

$report_command

$backup_command

$notify_command

$examples

==================================================================================
Version: $smart_monitor_version
License: MIT
==================================================================================

EOF
}


#example


#AUTHOR_NAME="mitterand"
#AUTHOR_EMAIL="asmitterand@yahoo.fr"
#show_usage