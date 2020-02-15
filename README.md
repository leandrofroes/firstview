# fIRstview

fIRstview is a Linux Incident Response tool that gives you a first view and collects useful information to your Forensic Analysis. Also, it's important to know that there's no dependencies to run it and the report is generated automatically.

## **Features**

### System

- Uptime
- Disk usage
- Partitions
- Memory usage
- OS and Kernel version
- Environment variables
- Hostname
- IP Address
- Route
- ARP
- Interfaces
- DNS info
- Network info
- USB info
- Kernel Modules
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

### User

- ID
- General info (id, shell, home directory, etc)
- Group
- Last login
- If the user is online
- Crontab
- Open files
- User config files (bashrc, profile, bash_logout)
- History
- Known hosts
- User processes
- User connections

### File

- General info (permissions, creator, size, etc)
- MAC info (modification, access, creation)
- Locations with the same file
- If the file is open
- MD5
- SHA1

### Process

- Process information (name, pid, ppid, time, command, etc)
- Files opened by the process
- Process command line
- Process connections

## **Options**

```
    -o, --output OUTPUT
          Specify the report output directory.
    -u,--user USER     
          Specify the user which you want to investigate.
    -p,--pid PID      
          Specify the process which you want to investigate.
    -f,--file FILE
          Specify a file which you want to investigate.
    -s,--system
          Display system information.
    -h,--help          
          Display this help menu.
```

## **Usage**

```
./fIRstview.sh -o <output_dir> -f /bin/ls
```

## **License**

The fIRstview is published under the GPL v3 License. Please refer to the file named LICENSE for more information.
