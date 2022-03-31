#!/bin/bash

set -eu -o pipefail

# Vars
scriptname="$0"

if [[ $(whoami) == "root" ]]; then
  echo "Don't run this script as root. Thank you."
  exit 2
fi

deps() {
if [[ ! $(command -v pip3 2>/dev/null) ]]; then
  sudo apt update -y
  sudo apt install -y python3-pip
fi

if [[ ! $(command -v ansible  2>/dev/null) ]] ||
[[ ! $(command -v ${HOME}/.local/bin/ansible  2>/dev/null) ]]; then
  pip3 install --user ansible
fi
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
if [[ ! -f "./ansible/ansible_dev.yaml" ]]; then
  rundir="$(mktemp -d)"
  git clone https://github.com/IamLunchbox/ansible-setup ${rundir}
  cd "${rundir}/ansible"
else
  cd ./ansible
fi
echo "Running ansible now. You will be prompted for your sudo password"
${HOME}/.local/bin/ansible-playbook -K ${1}.yaml
}

cleanup() {
for part in ${@}; do
case $part in
  "ansible")
    pip remove --user ansible
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

case "$1" in
  "ansible_dev"|"ansible")
    deps
    run "ansible_dev"
    echo 0
    ;;
  "dev")
    deps
    run "dev"
    cleanup "ansible"
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
    cleanup "ansible"
    ;;
  "core")
    echo "Core is not supported yet"
    exit 6
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
