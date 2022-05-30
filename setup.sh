#!/bin/bash

set -e -u -o pipefail

# Vars
scriptname="$0"
orange='\033[1;33m'
NC='\033[0m'

if [[ $(whoami) == "root" ]]; then
  echo "Don't run this script as root. Thank you."
  exit 2
fi

msg() {
  echo -e "${orange}${@}${NC}"
}

deps() {
  msg "Updating"
  sudo apt update -y
  msg "Installing python-debs"
  sudo apt install -y python3-pip
  msg "Installing ansible"
  pip3 install ansible -U
  msg "Installing the general collection"
  ansible-galaxy collection install community.general
}

help() {
echo "${scriptname} [module]
 A wrapper for my ansible setup scripts. Currently supported modules are:
 - ansible_dev
 - admin
 - dev
 - kali

 Commands:
 -h      Help"
}

run() {
if [[ ! -d "./ansible/roles/base" ]]; then
  msg "Could not find the necessary role, cloning into the temporary directory"
  git clone https://github.com/IamLunchbox/ansible-setup "${workdir}/setup"
  cd "${workdir}/setup/ansible"
else
  cd ./ansible
fi
msg "Running ansible now. You will be prompted for your sudo password"
if [[ $(command -v ansible-playbook) ]]; then
  ansible-playbook -K ${1}.yaml
elif [[ -x ${HOME}/.local/bin/ansible-playbook ]]; then
  ${HOME}/.local/bin/ansible-playbook -K ${1}.yaml
else
  msg "I could not find the ansible-playbook script. Exiting."
  exit 11
fi
}

cleanup() {
for part in ${@}; do
case $part in
  "ansible")
    pip3 remove ansible
    ;;
  "pip")
    sudo apt remove -y python3-pip
    ;;
esac
done
}

if [[ $# == 0 ]] || [[  $# -gt 1 ]]; then
  help
  exit 1
fi

for package in $@; do
  case "$package" in
    "ansible_dev"|"ansible")
      deps
      run "ansible_dev"
      echo 0
      ;;

    "dev")
      deps
      run "dev"
      exit 0
      ;;

    "admin")
      deps
      run "admin"
      exit 0
      ;;

    "kali")
      deps
      run "kali"
      ;;

    "core")
      echo "Core is not supported yet"
      exit 6
      run "core"
      cleanup "ansible" "pip"
      ;;

    "-h"|"--help"|"help")
      help
      exit 0
      ;;

    *)
      help
      exit 3
      ;;
  esac
  done
