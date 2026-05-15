#!/bin/bash
# Usage: create_bootram.sh [PROJECT_DIR] [FW_NAME]
#   PROJECT_DIR: target project directory (default: .)
#   FW_NAME:     firmware project name under fw/ (default: fw-brom)
#
# Examples:
#   ./sw/create_bootram.sh                           # 9K default
#   ./sw/create_bootram.sh project_tangnano9k        # 9K explicit
#   ./sw/create_bootram.sh project_tangprimer25k fw-tangprimer25k

PROJECT_DIR="${1:-.}"
FW_NAME="${2:-fw-brom}"
FW_DIR="fw/${FW_NAME}"
IP_DIR="${PROJECT_DIR}/gowin_ip"

echo "Generating bootram files into ${IP_DIR} from ${FW_DIR}"

echo "Generating bootram files 0"
cat ${IP_DIR}/bootram_2kx8_0/bootram_2kx8_0.vh > ${IP_DIR}/bootram_2kx8_0/bootram_2kx8_0.v
python3 sw/create_bootram_frag.py ${FW_DIR}/build/${FW_NAME}.vx0 >> ${IP_DIR}/bootram_2kx8_0/bootram_2kx8_0.v
echo "endmodule" >> ${IP_DIR}/bootram_2kx8_0/bootram_2kx8_0.v

echo "Generating bootram files 1"
cat ${IP_DIR}/bootram_2kx8_1/bootram_2kx8_1.vh > ${IP_DIR}/bootram_2kx8_1/bootram_2kx8_1.v
python3 sw/create_bootram_frag.py ${FW_DIR}/build/${FW_NAME}.vx1 >> ${IP_DIR}/bootram_2kx8_1/bootram_2kx8_1.v
echo "endmodule" >> ${IP_DIR}/bootram_2kx8_1/bootram_2kx8_1.v

echo "Generating bootram files 2"
cat ${IP_DIR}/bootram_2kx8_2/bootram_2kx8_2.vh > ${IP_DIR}/bootram_2kx8_2/bootram_2kx8_2.v
python3 sw/create_bootram_frag.py ${FW_DIR}/build/${FW_NAME}.vx2 >> ${IP_DIR}/bootram_2kx8_2/bootram_2kx8_2.v
echo "endmodule" >> ${IP_DIR}/bootram_2kx8_2/bootram_2kx8_2.v

echo "Generating bootram files 3"
cat ${IP_DIR}/bootram_2kx8_3/bootram_2kx8_3.vh > ${IP_DIR}/bootram_2kx8_3/bootram_2kx8_3.v
python3 sw/create_bootram_frag.py ${FW_DIR}/build/${FW_NAME}.vx3 >> ${IP_DIR}/bootram_2kx8_3/bootram_2kx8_3.v
echo "endmodule" >> ${IP_DIR}/bootram_2kx8_3/bootram_2kx8_3.v
