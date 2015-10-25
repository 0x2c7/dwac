#! /bin/bash
readonly STATUS_FILE='status.txt'
readonly LIST_FILE='blocked.txt'
readonly HOSTS_FILE="/etc/hosts"
readonly BLOCKED_HOSTS_FILE='/etc/hosts_blocked'
readonly BACKUP_HOSTS_FILE='/etc/hosts_backup'

# Generate blocked hosts file
function dwac_generate_hosts {
  $(rm -rf $BLOCKED_HOSTS_FILE)
  for i in "${site_list[@]}"
  do
    echo "127.0.0.1 $i" >> "$BLOCKED_HOSTS_FILE"
  done
}

# Backup hosts
function dwac_backup_hosts {
  if ! [[ -a "$BACKUP_HOSTS_FILE" ]]
    then
      $(cp $HOSTS_FILE $BACKUP_HOSTS_FILE)
  fi
}

# Backup hosts
function dwac_replace_hosts {
  if [[ -a "$BLOCKED_HOSTS_FILE" ]]
    then
      $(rm -rf $HOSTS_FILE)
      $(cp $BLOCKED_HOSTS_FILE $HOSTS_FILE)
  fi
}

# Backup hosts
function dwac_reverse_hosts {
  if [[ -a "$BACKUP_HOSTS_FILE" ]]
    then
      $(rm -rf $HOSTS_FILE)
      $(cp $BACKUP_HOSTS_FILE $HOSTS_FILE)  
      $(rm -rf $BACKUP_HOSTS_FILE)  
  fi
}

# Load list file
function dwac_load_list {
  site_list=()
  if [[ -a "$LIST_FILE" ]]
    then
      while IFS='' read -r line || [[ -n "$line" ]]; do
        site_list+=($line)
      done < "$LIST_FILE"
  fi
}

# Save list file
function dwac_save_list {
  $( rm -rf $LIST_FILE)
  for i in "${site_list[@]}"
  do
    echo "$i" >> "$LIST_FILE"
  done
}

# Load status
function dwac_load_status {
  status='0'
  if [[ -a "$STATUS_FILE" ]]
    then
      while IFS='' read -r line || [[ -n "$line" ]]; do
        status="$line"
      done < "$STATUS_FILE"
  fi
}

# Save status
function dwac_save_status {
  $( rm -rf $STATUS_FILE)
  echo "$1" >> $STATUS_FILE
}

# Display list of commands and usage
function dwac_help {
  echo "Help"
}

# Add a site to the blocked list
function dwac_add {
  dwac_load_list
  contained=0
  for i in "${site_list[@]}"
  do
    if [[ "$i" == "$1" ]]
      then
        contained=1
    fi
  done
  if [[ "$contained" == "0" ]]
  then
    site_list+=($1)
    dwac_save_list
  else
    echo "Site existing in the blocked list"
  fi
}

# Remove a site from the blocked list
function dwac_remove {
  dwac_load_list
  found=0
  for i in "${site_list[@]}"
  do
    if [[ "$i" == "$1" ]]
      then
        found=1
    fi
  done
  if [[ "$found" == "1" ]]
  then
    site_list=(${site_list[@]/"$1"})
    dwac_save_list
  else
    echo "Site not found in the blocked list"
  fi
}

# Start the dwac program
function dwac_start {
  dwac_load_status
  dwac_load_list
  if [[ $status == "0" ]]
    then
      dwac_generate_hosts
      dwac_backup_hosts
      dwac_replace_hosts
      dwac_save_status "1"
      echo "Program starts successfully"
    else
      echo "Program is running"
  fi
}

# Stop the dwac program
function dwac_stop {
  dwac_load_status
  if [[ $status == "0" ]]
    then
      echo "Program is not running"
    else
      dwac_reverse_hosts
      dwac_save_status "0"
      echo "Program stops successfully"
  fi
}

# Get the status of the dwac program
function dwac_status {
  dwac_load_status
  echo "$status"
}

# Controller
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi
case "$1" in
  '')
    dwac_help
    ;;
  help)
    dwac_help
    ;;
  add)
    if [[ -z "$2" ]]
      then
        echo "Missing site to add. Type 'dwac help for more information'"
      else
        dwac_add "$2"
    fi
    ;;
  remove)
    if [[ -z "$2" ]]
      then
        echo "Missing site to remove. Type 'dwac help for more information'"
      else
        dwac_remove "$2"
    fi
    ;;
  start)
    dwac_start
    ;;
  stop)
    dwac_stop
    ;;
  status)
    dwac_status
    ;;
  restart)
    dwac_stop
    dwac_start
    ;;
  *)
    echo "Command not found. Please use call with argument 'help' for more information"
    exit 1

esac