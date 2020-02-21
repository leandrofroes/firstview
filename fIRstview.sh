#!/bin/bash
#
#   fIRstview - fIRstview is a Linux Incident Response tool that gives you a first view and collects useful information to your Forensic Analysis.
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


[[ $EUID -ne 0 ]] || echo "[+] Running as non-root user!"

usage(){
cat << EOF

NAME:
    fIRstview - fIRstview is a Linux Incident Response tool that gives you a first view and collects useful information to your Forensic Analysis.

SYNOPSIS:
    fIRstview.sh [-h] [-a] [-s] [-o OUTPUT] [-u USER] [-p PID] [-f FILE]

OPTIONS:

    -u,--user USER
          Specify the user which you want to investigate.
    -p,--pid PID
          Specify the process which you want to investigate
    -f,--file FILE
          Specify a file which you want to investigate.
    -s,--system
          Display system information.
    -h,--help
          Display this help menu.

EOF
}

if [ $# -eq 0  ]; then
  usage
  exit 1
fi

OUTDIR=.

f(){
  FILEREPORT=$OUTDIR/$(echo $FILE | rev | cut -d/ -f1 | rev)-report-$(date +"%Y-%m-%d-%I-%M%p").log
  echo "Report generated at `date`" >> $FILEREPORT
  echo "Running as `whoami`" >> $FILEREPORT
  ( for i in \
  "ls -l $FILE" \
  "file $FILE" \
  "stat $FILE" \
  "lsof $FILE" \
  "find / -type f -name $FILE -exec ls -l {} +" \
  "md5sum $FILE" \
  "sha1sum $FILE"

  do
    echo -e "\n\n[+] $i\n-----------------------------------"
    eval $i 2>&-
  done) >> $FILEREPORT
}

user(){
  USERREPORT=$OUTDIR/$USR-report-$(date +"%Y-%m-%d-%I-%M%p").log
  echo "Report generated at `date`" >> $USERREPORT
  echo "Running as `whoami`" >> $USERREPORT
  ( for i in \
  "id $USR" \
  "who -a | grep $USR" \
  "ls -rthla ~$USR" \
  "lsof -u $USR" \
  "cat ~$USR/.ssh/known_hosts" \
  "cat ~$USR/.bashrc" \
  "cat ~$USR/.profile" \
  "cat ~$USR/.bash_logout" \
  "cat /var/spool/cron/crontabs/$USR" \
  "lsof -i | grep $USR" \
  "ps -fU $USR" \
  "lastlog | grep $USR" \
  "grep $USR /etc/passwd" \
  "grep $USR /etc/group"

  do
    echo -e "\n\n[+] $i\n-----------------------------------"
    eval $i 2>&-
  done) >> $USERREPORT

  cat /home/$USR/.bash_history > $OUTDIR/$USR-history-$(date +"%Y-%m-%d-%I-%M%p").log
  echo "[+] User history dumped at $OUTDIR"

}

pid(){
  PIDREPORT=$OUTDIR/$(ps -p $PID -o %c | tail -1)-report-$(date +"%Y-%m-%d-%I-%M%p").log
  echo "Report generated at `date`" >> $PIDREPORT
  echo "Running as `whoami`" >> $PIDREPORT
  ( for i in \
  "lsof -p $PID" \
  "ps -p $PID -wo %p%P%x%t%U%u%c%a" \
  "cat /proc/$PID/cmdline" \
  "ss -ltp | grep 'pid=$PID'"

  do
    echo -e "\n\n[+] $i\n-----------------------------------"
    eval $i 2>&-
  done) >> $PIDREPORT
}

system(){
  SYSREPORT=$OUTDIR/system-report-$(date +"%Y-%m-%d-%I-%M%p").log
  echo "Report generated at `date`" >> $SYSREPORT
  echo "Running as `whoami`" >> $SYSREPORT
  ( for i in \
  "uname -a" \
  "uptime" \
  "df -h" \
  "fdisk -l" \
  "mount -l" \
  "free -m" \
  "cat /etc/fstab" \
  "lsusb" \
  "lsmod" \
  "env" \
  "echo $LD_PRELOAD" \
  "hostname" \
  "ip a" \
  "ip link show" \
  "cat /etc/network/interfaces" \
  "ip r s" \
  "ip n" \
  "cat /etc/hosts" \
  "cat /etc/resolv.conf" \
  "ss -putan" \
  "lastlog" \
  "who -a" \
  "grep -E ':0+' /etc/passwd" \
  "getent passwd {1000..65535}" \
  "cat /etc/sudoers" \
  "ls -lrth /etc/cron.d" \
  "ls -lrth /etc/cron.hourly" \
  "ls -lrth /etc/cron.daily" \
  "ls -lrth /etc/cron.weekly" \
  "ls -lrth /etc/cron.monthly" \
  "ls -lrtha /tmp" \
  "ls -lrth /etc/*.d" \
  "service --status-all" \
  "ps -ewo %p%P%x%t%U%u%c%a" \
  "jobs -l" \
  "lsof" \
  "lsof -i"

  do
    echo -e "\n\n[+] $i\n-----------------------------------"
    eval $i 2>&-
  done) >> $SYSREPORT
}

while getopts u:p:f:sh opt; do
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
    s|--system) system
                ;;
    h|--help)   usage
                exit 0
                ;;
  esac
done

echo "[+] Done!"
exit 0
