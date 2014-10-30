import socket
import colorsys
from time import sleep
import datetime
 
SERVER_ADDRESS = "192.168.0.117"
PORT = 7
 
s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM) 

blank = bytes.fromhex("000000")
green = bytes.fromhex("00ff00")
red = bytes.fromhex("ff0000")
blue = bytes.fromhex("0000ff")
ledvals = []
TOTLEDS = 96
for i in range(TOTLEDS):
    ledvals.append(blank)

n = 0
lasttime = datetime.datetime.now()
for k in range(200):
    ledvals[n] = green
    ledvals[n-1 if n > 0 else TOTLEDS-1] = blank
    dat = b"".join(ledvals)
    s.sendto(dat, (SERVER_ADDRESS, PORT))
    sleep(.025)

    difftime = datetime.datetime.now() - lasttime
    lasttime = datetime.datetime.now()
    n = n + 1
    if (n >= TOTLEDS):
        n = 0

data = s.recv(1024)
s.close()
print ('Received', repr(data))
