#! /bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This command must be run as root"
   exit 1
fi
if [[ -a "/usr/bin/dwac" ]]; then
  $(rm -rf /usr/bin/dwac)
  $(rm -rf $HOME/.dwac)
fi
echo 'Uninstall program successfully'