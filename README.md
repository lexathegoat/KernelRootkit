# Linux Kernel Rootkit - Process Hiding LKM
A loadable kernel module demonstrating process hiding techniques
through syscall hooking for educational and security research purposes.

# Warning
This software is provided for educational and authorized security research only.
Unauthorized use is illegal. Use only in isolated test environments with explicit permission.

# Features
    - Hide processes by PID or name prefix.
    - Syscall hooking (getdents, getdents64, kill)
    - Procfs control interface
    - Runtime process hiding and unhiding
    - Optional module stealth capability

# Requirements
    - Linux kernel 4.x or 5.x
    - Kernel headers matching running kernel
    - GCC compiler and make
    - Root privileges

## Install Requirements:
```bash
sudo apt-get install build-essential linux-headers-$(uname -r)
sudo yum install kernel-devel kernel-headers gcc make
```
## Build and Installation
```bash
make
sudo insmod rootkit.ko

lsmod | grep rootkit
```
## Usage

### Hide process by PID:
```bash
sleep 1000 6
PID=$!
sudo kill -31 $PID
ps aux | grep $PID
```
### Unhide Process:
```bash
sudo kill -32 $PID
```
### Auto-hide by name:
```bash
cd /bin/sleep /tmp/evil_daemon
/tmp/evil_daemon 1000 &
ps aux | grep evil_daemon
```
### Check Status:
```bash
cat /proc/rootkit_control
```
### Testing
```bash
chmod +x test_rootkit.sh
sudo ./test_rootkit.sh
```
### Removal
```bash
sudo rmmod rootkit
```

## Detection Methods
This rootkit can be detected by:
    - Syscall table integrity checking
    - Memory forensics tools
    - Comparing /proc output with kernel structures
    - Kernel module signature verification
    - Runtime integrity monitoring tools

Detection commands:
```bash
sudo cat /proc/kallsyms | grep sys_call_table
diff <(ps aux | wc -l) <(cat /proc/loadavg | awk '{print $4}')
diff <(lsmod) <(cat /proc/modules)
```
## Defense
    - Enable kernel module signing (CONFIG_MODULE_SIG_FORCE)
    - Use Secure Boot
    - Enable kernel lockdown mode
    - Implement runtime integrity monitoring
    - Use SELinux or AppArmor mandatory access controls
    
## Technical Details

### Hooked syscalls:
        - sys_getdents
        - sys_getdents64
        - sys_kill

### MITRE ATT&CK mapping:
        - T1014
        - T1547: Boot or Logon Autostart Execution
        - T1562.001: Impair Defenses
        
## Limitations
    - Does not survive reboot
    - Detectable vie memory forensics
    - Requires root to load
    - May be unstable on some kernels
    - Does not hide network connections or open files

## Troubleshooting

### Module fails to load:
```bash
sudo dmesg | tail -20
ls /lib/modules/$(uname -r)/build
```
### System becomes unstable:
```bash
sudo rmmod rootkit
sudo journalctl -xe
```

# Legal Notice
```NOTICE
**This tool is for authorized testing only. Users must have explicit permission to test on target systems and comply with all applicable laws. Unauthorized use may result in criminal prosecution.**
```

# References
    - Linux Kernel Module Programming Guide
    - MITRE ATT&CK Framework
    - Linux kernel documentation-
