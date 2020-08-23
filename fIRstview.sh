#!/bin/bash
#
#   fIRstview - fIRstview is a Live Response/Incident Response automation tool that collects several information from a Linux based system.
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


[[ $EUID -ne 0 ]] && echo "[!] You must be root!" && exit 1

usage(){
    cat << EOF
NAME:
	fIRstview - fIRstview is a Live Response/Incident Response automation tool that collects several information from a Linux based system.

SYNOPSIS:
	fIRstview.sh [-h] [-a] [-l] [-u USER] [-p PID] [-f FILE]

OPTIONS:
	-u,--user USER
		Specify the user which you want to investigate and generate a report.
	-p,--pid PID
		Specify the process which you want to investigate and generate a report.
	-f,--file FILE
		Specify a file which you want to investigate and generate a report.
	-l,--logs
		Dump several system logs.
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

OUTDIR=$PWD/fIRstview_output

[[ ! -d $OUTDIR ]] && mkdir $OUTDIR

cd $OUTDIR

f(){
    FILEREPORT=$(echo $FILE | rev | cut -d/ -f1 | rev)-file-report
    ERRORLOG=$(echo $FILE | rev | cut -d/ -f1 | rev)-file-report-error.log
    echo "Report generated at `date`" >> $FILEREPORT
    echo "Running as `whoami`" >> $FILEREPORT
    ( for i in \
    "ls -la $FILE" \
    "file -p $FILE" \
    "stat $FILE" \
    "lsof $FILE" \
    "md5sum $FILE" \
    "sha1sum $FILE" \
    "readelf -a $FILE"

    do
        echo -e "\n\n[+] $i\n-----------------------------------"
        eval $i 2>> $ERRORLOG
    done) >> $FILEREPORT
}

user(){
    USERREPORT=$USR-report
    ERRORLOG=$USR-report-error.log
    echo "Report generated at `date`" >> $USERREPORT
    echo "Running as `whoami`" >> $USERREPORT
    ( for i in \
    "id $USR" \
    "who -a | grep $USR" \
    "lastlog | grep $USR" \
    "ls -rthla ~$USR" \
    "grep $USR /etc/passwd" \
    "grep $USR /etc/group" \
    "cat /var/spool/cron/crontabs/$USR" \
    "lsof -u $USR" \
    "lsof -i | grep $USR" \
    "ps -fU $USR"

    do
        echo -e "\n\n[+] $i\n-----------------------------------"
        eval $i 2>> $ERRORLOG
    done) >> $USERREPORT

    ERRORLOGS=user-home-files-error.log
    cat /home/$USR/.bash_history > $USR-user-history.log 2>> $ERRORLOGS
    cat ~$USR/.ssh/known_hosts > $USR-user-known_hosts.log 2>> $ERRORLOGS
    cat ~$USR/.bashrc > $USR-user-bashrc.log 2>> $ERRORLOGS
    cat ~$USR/.profile > $USR-user-profile.log 2>> $ERRORLOGS
    cat ~$USR/.bash_logout > $USR-user-bash_logout.log 2>> $ERRORLOGS
}

pid(){
    PIDREPORT=$PID-pid-report
    ERRORLOG=$PID-pid-report-error.log
    echo "Report generated at `date`" >> $PIDREPORT
    echo "Running as `whoami`" >> $PIDREPORT
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
        eval $i 2>> $ERRORLOG
    done) >> $PIDREPORT
}

logs(){
    ERRORLOGS=error_logs.log
    cat /var/log/dmesg > dmesg.log 2>> $ERRORLOGS
    cat /var/log/auth.log > auth.log 2>> $ERRORLOGS
    cat /var/log/dpkg.log > dpkg.log 2>> $ERRORLOGS
    cat /var/log/kern.log > kern.log 2>> $ERRORLOGS
    cat /var/log/lastlog > lastlog.log 2>> $ERRORLOGS
    cat /var/log/syslog > syslog.log 2>> $ERRORLOGS
    cat /var/log/alternative.log > alternative.log 2>> $ERRORLOGS
    cat /var/log/cron.log > cron.log 2>> $ERRORLOGS
    cat /var/log/messages > messages.log 2>> $ERRORLOGS
    cat /var/log/debug > debug.log 2>> $ERRORLOGS
    cat /var/log/daemon.log > daemon.log 2>> $ERRORLOGS
    cat /var/log/boot.log > boot.log 2>> $ERRORLOGS
    cat /var/log/user.log > user.log 2>> $ERRORLOGS
    cat /var/log/apache2/access.log > apache_access.log 2>> $ERRORLOGS
}

all(){
    FULLREPORT=full-system-report
    ERRORLOG=full-system-report-error.log
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
    "iptables -L" \
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
        eval $i 2>> $ERRORLOG
    done) >> $FULLREPORT

    ERRORLOGS=error_logs.log
    cat /var/log/dmesg > dmesg.log 2>> $ERRORLOGS
    cat /var/log/auth.log > auth.log 2>> $ERRORLOGS
    cat /var/log/dpkg.log > dpkg.log 2>> $ERRORLOGS
    cat /var/log/kern.log > kern.log 2>> $ERRORLOGS
    cat /var/log/lastlog > lastlog.log 2>> $ERRORLOGS
    cat /var/log/syslog > syslog.log 2>> $ERRORLOGS
    cat /var/log/alternative.log > alternative.log 2>> $ERRORLOGS
    cat /var/log/cron.log > cron.log 2>> $ERRORLOGS
    cat /var/log/messages > messages.log 2>> $ERRORLOGS
    cat /var/log/debug > debug.log 2>> $ERRORLOGS
    cat /var/log/daemon.log > daemon.log 2>> $ERRORLOGS
    cat /var/log/boot.log > boot.log 2>> $ERRORLOGS
    cat /var/log/user.log > user.log 2>> $ERRORLOGS
    cat /var/log/apache2/access.log > apache_access.log 2>> $ERRORLOGS
  
}

while getopts u:p:f:lah opt; do
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
        l|--logs)   logs
                    ;;
        a|--all)    all
                    ;;
        h|--help)   usage
                    exit 0
                    ;;
        *)          usage
                    exit 1
                    ;;
    esac
done

cd ..
zip -P novirus -r fIRstview_output.zip $OUTDIR > /dev/null
echo "[+] Report generated at $PWD."
echo "[+] Done!"
exit 0
