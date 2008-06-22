import cwiid
import time
import socket
import struct

HOST = '192.168.1.83'                 # Symbolic name meaning the local host
PORT = 0xAC3d              # Arbitrary non-privileged port

s=socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect((HOST, PORT))

print "Presiona los botones 1 y 2 en el wiimote..."
wm = cwiid.Wiimote()
wm.rumble = 1
time.sleep(.2)
wm.rumble = 0
wm.rpt_mode = 31

while True:
    acc, buttons = wm.state['acc'], wm.state['buttons']
    acc = map(lambda x: (x-128.)/64, acc)
    print acc
    s.send(struct.pack("<fff", *acc))
    time.sleep(.1)
