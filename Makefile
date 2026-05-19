include Makefile.inc
MAKE		?= make

# Select target board: tangnano9k | tangprimer25k
TARGET		?= tangnano9k

# -----------------------------------------------------------------------------
# Tang Nano 9K target
#   - fw-brom: ISP flasher bootrom (8KB BSRAM @ 0x8000_0000)
#   - fw-flash: user application running from SPI Flash XIP
# -----------------------------------------------------------------------------
ifeq ($(TARGET),tangnano9k)

GOWIN_PROJ	 = project_tangnano9k/picotiny_tangnano9k.gprj
FW_FILE		 = fw/fw-flash/build/fw-flash.v
COMx		 ?= COM14

.PHONY: all brom flash clean program

all: brom flash

$(FW_FILE): flash

brom:
	$(MAKE) -C fw/tangnano9k/brom

flash:
	$(MAKE) -C fw/tangnano9k/flash

clean:
	$(MAKE) -C fw/tangnano9k/brom clean
	$(MAKE) -C fw/tangnano9k/flash clean

program: $(FW_FILE)
	$(PYTHON_NAME) sw/pico-programmer.py $(FW_FILE) $(COMx)

# -----------------------------------------------------------------------------
# Tang Primer 25K target
#   - fw-tangprimer25k: dedicated firmware running from BROM
#     No SPI Flash on bare core board; program lives in 8KB BROM.
#     Build this, then run Gowin IDE to synthesize bitstream with
#     bootram IPs initialized by this firmware.
# -----------------------------------------------------------------------------
else ifeq ($(TARGET),tangprimer25k)

GOWIN_PROJ	 = project_tangprimer25k/picotiny_tangprimer25k.gprj

.PHONY: all brom25k clean bootram

all: brom25k

brom25k:
	$(MAKE) -C fw/tangprimer25k/brom

# Copy firmware 32-bit hex file to project directory for $readmemh init.
# Gowin synthesizer will pick up $readmemh initialization.
# Usage: make bootram TARGET=tangprimer25k [FW=brom|irqtest|coremark]
FW ?= brom

bootram:
	$(MAKE) -C fw/tangprimer25k/$(FW)
ifeq ($(FW),brom)
	cp fw/tangprimer25k/$(FW)/build/fw-tangprimer25k.hex32 project_tangprimer25k/src/fw-tangprimer25k.hex
else
	cp fw/tangprimer25k/$(FW)/build/fw-$(FW).hex32 project_tangprimer25k/src/fw-tangprimer25k.hex
endif
	@echo "Bootram init file copied. Re-synthesize in Gowin IDE."

clean:
	$(MAKE) -C fw/tangprimer25k/brom clean

# No 'program' target for 25K -- firmware is embedded in bitstream.

else
$(error Unknown TARGET=$(TARGET). Use tangnano9k or tangprimer25k)
endif

export PYTHON_NAME
export RISCV_NAME
export RISCV_PATH
