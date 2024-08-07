import sys

if len(sys.argv) < 2 or '-h' in sys.argv:
    print("Usage: python create_bootram_frag.py input_file.vx0-3")
    sys.exit()

fin = open(sys.argv[1])
HEX = "0123456789ABCDEF"

cache = []

i = 0;
for line in fin:
    if not line.startswith('@'):
        cache.insert(0, line.strip())
        if (len(cache) == 32):
            string = "".join(cache)
            IDX = HEX[i>>4] + HEX[i%16]
            print("defparam sp_inst_0.INIT_RAM_" + IDX + " = 256'h" + string + ";")
            cache = []
            i = i+1
