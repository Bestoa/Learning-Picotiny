import serial, sys
ser = serial.Serial(sys.argv[1], 115200, timeout=0.01)
