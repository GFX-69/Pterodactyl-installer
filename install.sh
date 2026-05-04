#!/bin/bash

set -e

######################################################################################
#                                                                                    #
# Project 'Akash Pterodactyl Auto Installer'                                         #
#                                                                                    #
# Created by: Akash (FX-YT.X)                                                        #
# GitHub/YouTube: https://www.youtube.com/@FX-YT.X                                   #
#                                                                                    #
# Based on: pterodactyl-installer by Vilhelm Prytz                                   #
#                                                                                    #
# This script is for personal / educational use                                      #
#                                                                                    #
######################################################################################

export GITHUB_SOURCE="v1.2.0"
export SCRIPT_RELEASE="Akash-v1.0"
export GITHUB_BASE_URL="https://raw.githubusercontent.com/pterodactyl-installer/pterodactyl-installer"

LOG_PATH="/var/log/akash-pterodactyl-installer.log"

# check for curl
if ! [ -x "$(command -v curl)" ]; then
  echo "* curl is required in order for this script to work."
  echo "* install using apt"
  exit 1
fi

# remove old lib
[ -f /tmp/lib.sh ] && rm -rf /tmp/lib.sh

echo "🔥 Downloading installer core..."
curl -sSL -o /tmp/lib.sh "$GITHUB_BASE_URL"/master/lib/lib.sh

# source
source /tmp/lib.sh

execute() {
  echo -e "\n\n* Akash Installer $(date) \n\n" >>$LOG_PATH

  [[ "$1" == *"canary"* ]] && export GITHUB_SOURCE="master" && export SCRIPT_RELEASE="Akash-canary"

  update_lib_source

  echo "🚀 Running: $1"
  run_ui "${1//_canary/}" |& tee -a $LOG_PATH

  if [[ -n $2 ]]; then
    echo -e -n "👉 Next step ($2)? (y/N): "
    read -r CONFIRM
    if [[ "$CONFIRM" =~ [Yy] ]]; then
      execute "$2"
    else
      echo "❌ Skipped $2"
      exit 1
    fi
  fi
}

echo "========================================"
echo "🔥 AKASH PTERODACTYL INSTALLER 🔥"
echo "========================================"

done=false
while [ "$done" == false ]; do

  options=(
    "Install Panel"
    "Install Wings"
    "Install Panel + Wings (Auto)"
    "Panel (Canary)"
    "Wings (Canary)"
    "Panel + Wings (Canary)"
    "Uninstall"
  )

  actions=(
    "panel"
    "wings"
    "panel;wings"
    "panel_canary"
    "wings_canary"
    "panel_canary;wings_canary"
    "uninstall_canary"
  )

  echo ""
  echo "👉 Choose option:"

  for i in "${!options[@]}"; do
    echo "[$i] ${options[$i]}"
  done

  echo -n "Enter number: "
  read -r action

  if [[ ! "$action" =~ ^[0-9]+$ ]] || [ "$action" -ge "${#actions[@]}" ]; then
    echo "❌ Invalid option"
    continue
  fi

  done=true
  IFS=";" read -r i1 i2 <<<"${actions[$action]}"
  execute "$i1" "$i2"

done

rm -rf /tmp/lib.sh

echo "✅ Done! Installer finished."
