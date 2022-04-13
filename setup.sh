#!/bin/bash

set -eu -o pipefail

# Vars
scriptname="$0"

if [[ $(whoami) == "root" ]]; then
  echo "Don't run this script as root. Thank you."
  exit 2
fi

deps() {
  sudo apt update -y
  sudo apt install -y python3-pip python3-venv
  workdir="$(mktemp -d)"
  mkdir "${workdir}/env"
  python3 -m venv "${workdir}/env"
  source "${workdir}/env/bin/activate"
  pip3 install ansible
  ansible-galaxy collection install community.general
}

help() {
echo " ${scriptname} [module]
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
  git clone https://github.com/IamLunchbox/ansible-setup "${workdir}/setup"
  cd "${workdir}/setup/ansible"
else
  cd ./ansible
fi
echo "Running ansible now. You will be prompted for your sudo password"
if [[ $(command -v ansible-playbook) ]]; then
  ansible-playbook -K ${1}.yaml
elif [[ -x ${HOME}/.local/bin/ansible-playbook ]]; then
  ${HOME}/.local/bin/ansible-playbook -K ${1}.yaml
else
  echo "I could not find the ansible-playbook script. Exiting."
  exit 11
fi
}

cleanup() {
for part in ${@}; do
case $part in
  "venv")
    sudo apt remove -y python3-venv
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

case "$1" in
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
    cleanup "venv" "pip"
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
