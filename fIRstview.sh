#!/bin/bash
#
#   fIRstview - fIRstview is a Linux Incident Response automation script that collects several artefacts on your system.
#
#   Author: Leandro Fróes
#
# Copyright (C) 2019 Leandro Fróes
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.


[[ $EUID -ne 0 ]] && echo "[!] Running as a non-root user!"

usage(){
cat << EOF

NAME:
    fIRstview - fIRstview is a Linux Incident Response tool that gives you a first view and collects useful information to your Forensic Analysis.

SYNOPSIS:
    fIRstview.sh [-h] [-a] [-u USER] [-p PID] [-f FILE]

OPTIONS:

    -u,--user USER
          Specify the user which you want to investigate and generate a report.
    -p,--pid PID
          Specify the process which you want to investigate and generate a report.
    -f,--file FILE
          Specify a file which you want to investigate and generate a report.
    -a,--all
          Generate a full report with no filter.
    -h,--help
          Display this help menu.

EOF
}

if [ $# -eq 0  ]; then
  usage
  exit 1
fi

f(){
  FILEREPORT=$(echo $FILE | rev | cut -d/ -f1 | rev)-file-report-$(date +"%Y-%m-%d-%I:%M%p").log
  echo "Report generated at `date`" >> $FILEREPORT
  echo "Running as `whoami`" >> $FILEREPORT
  ( for i in \
  "ls -la $FILE" \
  "file -p $FILE" \
  "stat $FILE" \
  "lsof $FILE" \
  "md5sum $FILE" \
  "sha1sum $FILE"

  do
    echo -e "\n\n[+] $i\n-----------------------------------"
    eval $i 2>&-
  done) >> $FILEREPORT
}

user(){
  USERREPORT=$USR-report-$(date +"%Y-%m-%d-%I:%M%p").log
  echo "Report generated at `date`" >> $USERREPORT
  echo "Running as `whoami`" >> $USERREPORT
  ( for i in \
  "id $USR" \
  "who -a | grep $USR" \
  "lastlog | grep $USR" \
  "ls -rthla ~$USR" \
  "cat ~$USR/.ssh/known_hosts" \
  "cat ~$USR/.bashrc" \
  "cat ~$USR/.profile" \
  "cat ~$USR/.bash_logout" \
  "grep $USR /etc/passwd" \
  "grep $USR /etc/group" \
  "cat /var/spool/cron/crontabs/$USR" \
  "lsof -u $USR" \
  "lsof -i | grep $USR" \
  "ps -fU $USR"

  do
    echo -e "\n\n[+] $i\n-----------------------------------"
    eval $i 2>&-
  done) >> $USERREPORT

  cat /home/$USR/.bash_history > $USR-user-history-$(date +"%Y-%m-%d-%I:%M%p").log
  echo "[+] User history dumped at $PWD"
}

pid(){
  PROCREPORT=$PID-process-report-$(date +"%Y-%m-%d-%I:%M%p").log
  echo "Report generated at `date`" >> $PROCREPORT
  echo "Running as `whoami`" >> $PROCREPORT
  ( for i in \
  "ps -p $PID -wo %p%P%C%x%t%U%u%c%a" \
  "lsof -p $PID" \
  "cat /proc/$PID/cmdline" \
  "cat /proc/$PID/comm" \
  "ls -la /proc/$PID/exe" \
  "ls -la /proc/$PID/cwd" \
  "cat /proc/$PID/environ" \
  "ss -ltp | grep 'pid=$PID'"

  do
    echo -e "\n\n[+] $i\n-----------------------------------"
    eval $i 2>&-
  done) >> $PROCREPORT
}

all(){
  FULLREPORT=full-report-$(date +"%Y-%m-%d-%I:%M%p").log
  echo "Report generated at `date`" >> $FULLREPORT
  echo "Running as `whoami`" >> $FULLREPORT
  ( for i in \
  "##### SYSTEM #####\n" \
  "uname -a" \
  "uptime" \
  "df -h" \
  "fdisk -l" \
  "mount -l" \
  "cat /etc/fstab" \
  "free" \
  "lsusb" \
  "lsmod" \
  "env" \
  "set | grep 'LD_PRELOAD'" \
  "##### NETWORKING #####\n" \
  "hostname" \
  "ip a" \
  "ip link show" \
  "cat /etc/network/interfaces" \
  "ip r s" \
  "ip n" \
  "cat /etc/hosts" \
  "cat /etc/resolv.conf" \
  "ss -putan" \
  "##### USERS #####\n" \
  "who -a" \
  "lastlog" \
  "grep -E ':0+' /etc/passwd" \
  "getent passwd {1000..65535}" \
  "cat /etc/sudoers" \
  "ls -lrth /etc/cron.d" \
  "ls -lrth /etc/cron.hourly" \
  "ls -lrth /etc/cron.daily" \
  "ls -lrth /etc/cron.weekly" \
  "ls -lrth /etc/cron.monthly" \
  "##### PROCESSES AND SERVICES #####\n" \
  "ls -lrth /etc/*.d" \
  "service --status-all" \
  "ps -ewo %p%P%C%x%t%U%u%c%a" \
  "jobs -l" \
  "##### FILES #####\n" \
  "lsof" \
  "lsof -i" \
  "find / \\( -nouser -o -nogroup \\) -exec ls -lah {} +" \
  "lsattr / -R | grep '\\----i'" \
  "##### MISC #####\n" \
  "ls -lrtha /tmp" \
  "find / -name 'authorized_keys'" \
  "find /var/log -size 0b -exec ls -lah {} +" \
  "find / -type p -exec ls -lah {} +"

  do
    echo -e "\n\n[+] $i\n-----------------------------------"
    eval $i 2>&-
  done) >> $FULLREPORT
}

while getopts u:p:f:ah opt; do
  case "$opt" in
    u|--user)   USR=$OPTARG
                if grep -qw ^$USR /etc/passwd; then
                  user
                else
                  echo "ERROR: This user does not exist.";
                  exit 1
                fi
                ;;
    p|--pid)    PID=$OPTARG
                if ps -p $PID > /dev/null; then
                  pid
                else
                  echo "ERROR: This pid does not exist.";
                  exit 1
                fi
                ;;
    f|--file)   FILE=$OPTARG
                if [ ! -f $FILE ]; then
                  echo "ERROR: This file does not exist.";
                  exit 1;
                fi
                f
                ;;
    a|--all) all
                ;;
    h|--help)   usage
                exit 0
                ;;
    *)          usage
                exit 1
                ;;
  esac
done

echo "[+] Done!"
echo "[+] Report generated at $PWD"
exit 0
