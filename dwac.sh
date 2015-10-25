#! /bin/bash
readonly DATA_FOLDER="$HOME/.dwac"
readonly STATUS_FILE="$DATA_FOLDER/status"
readonly LIST_FILE="$DATA_FOLDER/blocked"
readonly HOSTS_FILE="/etc/hosts"
readonly BLOCKED_HOSTS_FILE="/etc/hosts_blocked"
readonly BACKUP_HOSTS_FILE="/etc/hosts_backup"

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

# Create data folder
function dwac_create_data_folder {
  if ! [[ -d "$DATA_FOLDER" ]]
    then
      $(mkdir $DATA_FOLDER)
  fi
}

# Save list file
function dwac_save_list {
  dwac_create_data_folder
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
  dwac_create_data_folder
  $( rm -rf $STATUS_FILE)
  echo "$1" >> $STATUS_FILE
}

# Display list of commands and usage
function dwac_help {
  echo -e "DWAC (Dark Wing Access Controll)"
  echo
  echo -e '1. Introduce'
  echo -e '  \e[39mDwac is a simple solution for multi-program access control on Linux. It helps you prevent the access to specific sites you define. By using a general filter standing at the DNS lookup process, the program can block request from any browser or any program using normal HTTP request. Hopefully, this is safe enough for normal users :)'
  echo
  echo -e '2. Usage'
  echo -e '  \e[39mdwac help \tDisplay information about this program'
  echo -e '  dwac status \tRunning status and sites blocked'
  echo -e '  dwac add [site] \tAdd a site to the blocked list'
  echo -e '  dwac remove [site] \tRemove a site from the block list'
  echo -e '  dwac start \tStart program. When program is running. Your /etc/hosts will be replaced'
  echo -e '  dwac stop \tStop program. After program is stopped. Your /etc/hosts will be reversed'
  echo -e '  dwac restart \tRestart program'
  echo
  echo -e '3. Credit'
  echo -e '  \e[39mAuthor: Minh Nguyen (nguyenquangminh0711@gmail.com)'
  echo -e '  License: MIT'
  echo
  echo -e 'Thanks for using this program :)'
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

# Get list of blocked sites
function dwac_list {
  dwac_load_list
  for i in "${site_list[@]}"
  do
    echo -e "$i"
  done
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
      echo -e "\e[92mProgram starts successfully\e[39m"
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
      echo -e "\e[93mProgram stops successfully\e[39m"
  fi
}

# Get the status of the dwac program
function dwac_status {
  dwac_load_status
  dwac_load_list
  if [[ $status == "1" ]]
    then
      echo -e "\e[92mRunning"
    else
      echo -e "\e[93mNot running"
  fi
  echo -e "\e[39m"
}

# Root rqeuired
function root_required {
  if [[ $EUID -ne 0 ]]; then
     echo "This command must be run as root" 1>&2
     exit 1
  fi
}

#

# Controller
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
  list)
    dwac_list
    ;;
  start)
    root_required
    dwac_start
    ;;
  stop)
    root_required
    dwac_stop
    ;;  
  status)
    root_required
    dwac_status
    ;;
  restart)
    root_required
    dwac_stop
    dwac_start
    ;;
  *)
    echo "Command not found. Please use call with argument 'help' for more information"
    exit 1

esac  