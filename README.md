# fIRstview

fIRstview is a Live Response/Incident Response automation tool that collects several information from a Linux based system. Since it's written in Shell the script has no dependencies and the report is generated automatically.

## **Features**

### All module

- Uptime
- Disk usage
- Partitions
- Memory usage
- OS and Kernel version
- Environment variables
- Hostname
- IP Address
- Route Table
- ARP
- Interfaces
- DNS info
- Network info
- Iptables listing
- USB info
- Kernel modules
- Online Users
- Last logins
- Privileged Users
- Non-System Users
- Crontabs
- Temp directory
- Daemons
- Running services
- Processes
- Jobs
- Open files
- Open Connections
- Fstab
- Mounts
- Unusual authorized keys location
- 0 bytes log files
- Files/directories with no user or no group
- Immutable files/directories
- Pipe files

### User module

- ID
- General info (id, shell, home directory, etc)
- Groups
- Last login
- If the user is online
- Crontab
- Open files
- User config files (bashrc, profile, bash_logout)
- History
- Known hosts
- User processes
- User connections

### File module

- General info (permissions, creator, size, etc)
- MAC info (modification, access, creation)
- If the file is open
- MD5
- SHA1
- ELF information

### Process module

- Process information (name, pid, ppid, time, command, etc)
- Files opened by the process
- Process command line
- Process command
- Process binary
- Process working directory
- Process environment
- Process connections

### Logs module

- dmesg
- auth.log
- secure
- dpkg.log
- kern.log
- lastlog
- syslog
- alternative.log
- cron.log
- messages
- debug
- daemon.log
- boot.log
- user.log
- apache2/httpd access.log

## **Options**

```
    -u,--user USER
          Specify the user which you want to investigate and generate a report.
    -p,--pid PID
          Specify the process which you want to investigate and generate a report.
    -f,--file FILE
          Specify a file which you want to investigate and generate a report.
    -l, --logs
        Dump several system logs.
    -a,--all
          Generate a full report with no filter.
    -h,--help
          Display this help menu.
```

## **Installation**

```
git clone https://github.com/leandrofroes/firstview
cd firstview
chmod +x fIRstview.sh
```

## **Example**

```
sudo ./fIRstview.sh -u <username>
```

## Version 0.3 new features:

- New log collection module
- Removed timestamp from the report file name
- The report now is generated in an output directory created by the script

### All module:

- Now it has the log collection module embedded


## Version 0.2 new features:

### All module:

- Unusual authorized keys location
- 0 bytes log files
- Files/directories with no user or no group
- Immutable files/directories
- Pipe files
- Add CPU usage to ps command

### Process module:

- Process command
- Process binary
- Process working directory
- Process environment
- Add CPU usage to ps command

### File module:

- Add -p option to file command to preserve timestamp.

### General:

- The commands now are organized in a logical way, making easier to analyse them.
- Fix EUID checking logic

## **License**

The fIRstview is published under the GPL v3 License. Please refer to the file named LICENSE for more information.
