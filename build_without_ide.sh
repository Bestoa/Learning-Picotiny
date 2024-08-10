rm oss-build/*
mkdir -p oss-build
yosys -p "read_verilog \
    -D__NO_GOWIN_IDE__ \
    hw/picomemory.v \
    hw/picoperipheral.v \
    hw/picorv32.v \
    hw/picotiny.v \
    hw/simpleuart.v \
    hw/spimemio_puya.v \
    gowin_ip/bootram_2kx8_0/bootram_2kx8_0.v \
    gowin_ip/bootram_2kx8_1/bootram_2kx8_1.v \
    gowin_ip/bootram_2kx8_2/bootram_2kx8_2.v \
    gowin_ip/bootram_2kx8_3/bootram_2kx8_3.v \
    gowin_ip/gowin_rpll/gowin_rpll.v \
    gowin_ip/sram_8kx8/sram_8kx8.v;\
    synth_gowin -json oss-build/picorv-nohdmi.json"
nextpnr-himbaechel  --device GW1NR-LV9QN88PC6/I5 \
    --vopt family=GW1N-9C  \
    --vopt cst=./project/picotiny.cst \
    --json oss-build/picorv-nohdmi.json \
    --write oss-build/picorv-nohdmi_pnr.json
gowin_pack -d GW1N-9C -o oss-build/picorv-nohdmi.fs oss-build/picorv-nohdmi_pnr.json 
