include ../../Makefile.inc
PROJ_NAME=fw-irqtest
DEBUG=no
BENCH=no
MULDIV=yes
COMPRESSED=no

SRCS = 	$(wildcard *.c) 	\
		$(wildcard *.S)

LDSCRIPT = ./linker.ld

RISCV_NAME 	?= riscv-none-elf
RISCV_PATH 	?= /home/besto/Work/xpack-riscv-none-elf-gcc-13.3.0-1/

MABI=ilp32
MARCH := rv32i
ifeq ($(MULDIV),yes)
	MARCH := $(MARCH)m
endif
ifeq ($(COMPRESSED),yes)
	MARCH := $(MARCH)ac
endif

CFLAGS = -march=$(MARCH) \
		  -mabi=$(MABI)  \
		  -ffunction-sections \
		  -fdata-sections \
		  -fno-stack-protector \
		  -fno-zero-initialized-in-bss \
		  -fno-builtin \
		  -nostartfiles \
		  -mstrict-align \
		  -MD -fstrict-volatile-bitfields \
		  -ffreestanding \
		  -Wl,-Bstatic,-T,$(LDSCRIPT),-Map,$(OBJDIR)/$(PROJ_NAME).map,--print-memory-usage \
		  -Wl,--gc-sections,--strip-debug

ifeq ($(DEBUG),yes)
	CFLAGS += -g3 -O0
endif

ifeq ($(DEBUG),no)
	CFLAGS += -g -O3
endif

ifeq ($(BENCH),yes)
	CFLAGS += -fno-inline
endif

RISCV_CLIB=$(RISCV_PATH)/$(RISCV_NAME)/lib/$(MARCH)/$(MABI)/

RISCV_OBJCOPY = $(RISCV_PATH)/bin/$(RISCV_NAME)-objcopy
RISCV_OBJDUMP = $(RISCV_PATH)/bin/$(RISCV_NAME)-objdump
RISCV_CC = $(RISCV_PATH)/bin/$(RISCV_NAME)-gcc


OBJDIR = build
OBJS := $(SRCS)
OBJS := $(OBJS:.c=.o)
OBJS := $(OBJS:.cpp=.o)
OBJS := $(OBJS:.S=.o)
OBJS := $(addprefix $(OBJDIR)/,$(OBJS))

SUBOBJ := $(addprefix $(OBJDIR)/,$(SUBDIRS))
SUBOBJ := $(addsuffix /*.o,$(SUBOBJ))

export RISCV_CC CFLAGS OBJDIR

all: $(SUBDIRS) $(OBJDIR)/$(PROJ_NAME).elf $(OBJDIR)/$(PROJ_NAME).hex $(OBJDIR)/$(PROJ_NAME).asm $(OBJDIR)/$(PROJ_NAME).v $(OBJDIR)/$(PROJ_NAME).bin

$(SUBDIRS): ECHO
	make -C $@

ECHO:
	@echo $(SUBDIRS)

$(OBJDIR)/%.elf: $(OBJS) | $(OBJDIR)
	$(RISCV_CC) $(CFLAGS) -o $@ $^ $(SUBOBJ) $(LIBS)

%.hex: %.elf
	$(RISCV_OBJCOPY) -O ihex $^ $@

%.bin: %.elf
	$(RISCV_OBJCOPY) -O binary $^ $@

%.v: %.elf
	$(RISCV_OBJCOPY) -O verilog $^ $@

%.asm: %.elf
	$(RISCV_OBJDUMP) -S -D -x $^ > $@

$(OBJDIR)/%.o: %.c
	mkdir -p $(dir $@)
	$(RISCV_CC) -c $(CFLAGS)  $(INC) -o $@ $^

$(OBJDIR)/%.o: %.cpp
	mkdir -p $(dir $@)
	$(RISCV_CC) -c $(CFLAGS)  $(INC) -o $@ $^

$(OBJDIR)/%.o: %.S
	mkdir -p $(dir $@)
	$(RISCV_CC) -c $(CFLAGS) -o $@ $^ -D__ASSEMBLY__=1

$(OBJDIR):
	mkdir -p $@

clean:
	rm -f $(OBJDIR)/$(PROJ_NAME).elf
	rm -f $(OBJDIR)/$(PROJ_NAME).hex
	rm -f $(OBJDIR)/$(PROJ_NAME).map
	rm -f $(OBJDIR)/$(PROJ_NAME).v
	rm -f $(OBJDIR)/$(PROJ_NAME).asm
	rm -f $(OBJDIR)/$(PROJ_NAME).bin
	find $(OBJDIR) -type f -name '*.d' -print0 | xargs -0 -r rm
	find $(OBJDIR) -type f -name '*.o' -print0 | xargs -0 -r rm

.SECONDARY: $(OBJS)

