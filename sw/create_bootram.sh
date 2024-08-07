#!/bin/bash

echo "Generating bootram files 0"
cat gowin_ip/bootram_2kx8_0/bootram_2kx8_0.vh > gowin_ip/bootram_2kx8_0/bootram_2kx8_0.v
python3 sw/create_bootram_frag.py fw/fw-brom/build/fw-brom.vx0 >> gowin_ip/bootram_2kx8_0/bootram_2kx8_0.v
echo "endmodule" >> gowin_ip/bootram_2kx8_0/bootram_2kx8_0.v

echo "Generating bootram files 1"
cat gowin_ip/bootram_2kx8_1/bootram_2kx8_1.vh > gowin_ip/bootram_2kx8_1/bootram_2kx8_1.v
python3 sw/create_bootram_frag.py fw/fw-brom/build/fw-brom.vx1 >> gowin_ip/bootram_2kx8_1/bootram_2kx8_1.v
echo "endmodule" >> gowin_ip/bootram_2kx8_1/bootram_2kx8_1.v

echo "Generating bootram files 2"
cat gowin_ip/bootram_2kx8_2/bootram_2kx8_2.vh > gowin_ip/bootram_2kx8_2/bootram_2kx8_2.v
python3 sw/create_bootram_frag.py fw/fw-brom/build/fw-brom.vx2 >> gowin_ip/bootram_2kx8_2/bootram_2kx8_2.v
echo "endmodule" >> gowin_ip/bootram_2kx8_2/bootram_2kx8_2.v

echo "Generating bootram files 3"
cat gowin_ip/bootram_2kx8_3/bootram_2kx8_3.vh > gowin_ip/bootram_2kx8_3/bootram_2kx8_3.v
python3 sw/create_bootram_frag.py fw/fw-brom/build/fw-brom.vx3 >> gowin_ip/bootram_2kx8_3/bootram_2kx8_3.v
echo "endmodule" >> gowin_ip/bootram_2kx8_3/bootram_2kx8_3.v
