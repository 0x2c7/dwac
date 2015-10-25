#! /bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This command must be run as root"
   exit 1
fi
if ! [[ -a "/usr/bin/dwac" ]]; then
  $(ln -s $PWD/dwac.sh /usr/bin/dwac)
fi
echo 'Install program successfully'