obj-m += ipt_redirect.o

all:
	make -C /lib/modules/$(shell uname -r)/build M=$(PWD) modules

clean:
	make -C /lib/modules/$(shell uname -r)/build M=$(PWD) clean

test:
	sudo dmesg -C
	# sometimes the module can't be imported for reasons that are unknown
	# see here for solution: https://bugzilla.redhat.com/show_bug.cgi?id=1957293
	sudo insmod ipt_redirect.ko
	sudo rmmod ipt_redirect.ko
	sudo dmesg

test-add:
	sudo dmesg -C
	# sometimes the module can't be imported for reasons that are unknown
	# see here for solution: https://bugzilla.redhat.com/show_bug.cgi?id=1957293
	sudo insmod ipt_redirect.ko
	sudo dmesg

test-remove:
	sudo dmesg -C
	# sometimes the module can't be imported for reasons that are unknown
	# see here for solution: https://bugzilla.redhat.com/show_bug.cgi?id=1957293
	sudo rmmod ipt_redirect.ko
	sudo dmesg