include ../../../Makefile.inc
PROJ_NAME=fw-bench
DEBUG=no
MULDIV=yes
COMPRESSED=no

SRCS = $(wildcard *.c) $(wildcard *.S)

LDSCRIPT = ./linker.ld

RISCV_NAME 	?= riscv-none-elf
RISCV_PATH 	?= /home/besto/Work/xpack-riscv-none-elf-gcc-13.3.0-1/

MABI=ilp32
MARCH := rv32i
ifeq ($(MULDIV),yes)
	MARCH := $(MARCH)m
endif

CFLAGS = -march=$(MARCH) \
		  -mabi=$(MABI)  \
		  -ffunction-sections -fdata-sections \
		  -fno-stack-protector -fno-builtin -nostartfiles \
		  -mstrict-align -ffreestanding \
		  -Wl,-Bstatic,-T,$(LDSCRIPT),-Map,$(OBJDIR)/$(PROJ_NAME).map,--print-memory-usage \
		  -Wl,--gc-sections,--strip-debug

ifeq ($(DEBUG),yes)
	CFLAGS += -g3 -O0
else
	CFLAGS += -g -O3
endif

RISCV_OBJCOPY = $(RISCV_PATH)/bin/$(RISCV_NAME)-objcopy
RISCV_OBJDUMP = $(RISCV_PATH)/bin/$(RISCV_NAME)-objdump
RISCV_CC = $(RISCV_PATH)/bin/$(RISCV_NAME)-gcc

OBJDIR = build
OBJS := $(SRCS)
OBJS := $(OBJS:.c=.o)
OBJS := $(OBJS:.S=.o)
OBJS := $(addprefix $(OBJDIR)/,$(OBJS))

all: $(OBJDIR)/$(PROJ_NAME).elf $(OBJDIR)/$(PROJ_NAME).hex32

$(OBJDIR)/%.elf: $(OBJS) | $(OBJDIR)
	$(RISCV_CC) $(CFLAGS) -o $@ $^

%.hex32: %.bin
	$(PYTHON_NAME) ../../../sw/bin2hex32.py $^ $@

%.bin: %.elf
	$(RISCV_OBJCOPY) -O binary $^ $@

$(OBJDIR)/%.o: %.c | $(OBJDIR)
	mkdir -p $(dir $@)
	$(RISCV_CC) -c $(CFLAGS) -o $@ $^

$(OBJDIR)/%.o: %.S | $(OBJDIR)
	mkdir -p $(dir $@)
	$(RISCV_CC) -c $(CFLAGS) -o $@ $^ -D__ASSEMBLY__=1

$(OBJDIR):
	mkdir -p $@

clean:
	rm -rf $(OBJDIR)

.SECONDARY: $(OBJS)
