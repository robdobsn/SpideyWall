import socket
import colorsys
from time import sleep
import datetime
 
SERVER_ADDRESS = "192.168.0.117"
PORT = 7
 
s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM) 

cmdmsg = bytearray.fromhex("01010b0200000001000000000000")
msglen = 14
TOTLEDS = 96

n = 0
lasttime = datetime.datetime.now()
for k in range(100):
        
    cmdmsg[5] = n
    cmdmsg[7] = 10;
    cmdmsg[8] = 0;
    cmdmsg[11] = 255;
    
    s.sendto(cmdmsg, (SERVER_ADDRESS, PORT))
    sleep(0.05)

    difftime = datetime.datetime.now() - lasttime
    lasttime = datetime.datetime.now()
    n = n + 1
    if (n >= TOTLEDS):
        n = 0

data = s.recv(1024)
s.close()
print ('Received', repr(data))
