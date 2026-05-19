#!/usr/bin/env python3
"""Convert a binary file to Verilog $readmemh format (32-bit little-endian words).
Usage: bin2hex32.py <input.bin> <output.hex>
"""
import struct
import sys

def main():
    if len(sys.argv) != 3:
        print(f"Usage: {sys.argv[0]} <input.bin> <output.hex>")
        sys.exit(1)

    in_path = sys.argv[1]
    out_path = sys.argv[2]

    with open(in_path, 'rb') as f:
        data = f.read()

    # Pad to 4-byte boundary
    pad = (4 - len(data) % 4) % 4
    data += b'\x00' * pad

    with open(out_path, 'w') as out:
        for i in range(0, len(data), 4):
            word = struct.unpack('<I', data[i:i+4])[0]
            out.write(f'{word:08x}\n')

    print(f"Generated {out_path}: {len(data)//4} words ({len(data)} bytes)")

if __name__ == '__main__':
    main()
