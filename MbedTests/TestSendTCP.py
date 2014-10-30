import socket
import colorsys
from time import sleep
import datetime
 
ECHO_SERVER_ADDRESS = "192.168.0.117"
ECHO_PORT = 7
 
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM) 
s.connect((ECHO_SERVER_ADDRESS, ECHO_PORT))

blank = bytes.fromhex("000000")
green = bytes.fromhex("00ff00")
red = bytes.fromhex("ff0000")
blue = bytes.fromhex("0000ff")
ledvals = []
TOTLEDS = 64
for i in range(TOTLEDS):
    ledvals.append(blank)

n = 0
lasttime = datetime.datetime.now()
for k in range(10):
    ledvals[n] = blue
    ledvals[n-1 if n > 0 else TOTLEDS-1] = blank
    dat = b"".join(ledvals)
    s.send(dat)
    sleep(.1)

    difftime = datetime.datetime.now() - lasttime
    print (difftime)
    lasttime = datetime.datetime.now()
    n = n + 1

data = s.recv(1024)
s.close()
print ('Received', repr(data))
