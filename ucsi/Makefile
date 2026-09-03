CFLAGS_trace.o := -I$(src)
ccflags-y += -I$(src)

obj-m += typec_ucsi.o

typec_ucsi-y := ucsi.o trace.o debugfs.o psy.o displayport.o thunderbolt.o

KDIR ?= /lib/modules/$(shell uname -r)/build

default:
	$(MAKE) -C $(KDIR) M=$(PWD) modules

clean:
	$(MAKE) -C $(KDIR) M=$(PWD) clean
