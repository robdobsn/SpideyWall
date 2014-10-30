import socket
import colorsys
from time import sleep
import datetime
import select

def FindLed():
    for ii in range(100):
        cmdmsg = bytearray.fromhex("0103")
        s.sendto(cmdmsg, (SERVER_ADDRESS, PORT))
        ready = select.select([s], [], [], 10)
        if ready[0]:
            data = s.recv(4096)
            print ('Received', repr(data))
    
def Snake():
    #cmdmsg = bytearray.fromhex("05040060002001010b0200000001000000000000")
    cmdmsg = bytearray.fromhex("01010b0200000001000000000000")
    msglen = 14
    TOTLEDS = 96

    n = 0
    lasttime = datetime.datetime.now()
    for k in range(100):

        cmdmsg[2] = 11  # fill solid = 8, fill gradient = 11
        cmdmsg[5] = n  # start at nth led
        cmdmsg[7] = 10;  # fill 10 leds
        cmdmsg[8] = 1;   # start with colour 
        cmdmsg[11] = 255;   # end with colour
        
        s.sendto(cmdmsg, (SERVER_ADDRESS, PORT))
        sleep(0.05)

        difftime = datetime.datetime.now() - lasttime
        lasttime = datetime.datetime.now()
        n = n + 1
        if (n >= TOTLEDS):
            n = 0


 
SERVER_ADDRESS = "192.168.0.117"
PORT = 7
 
s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM) 
s.setblocking(0)

while True:
    inp = input('F: Find LED, S: Snake, X: Exit')
    if inp == "F" or inp == 'f':
        FindLed()
    elif inp == "S" or inp == 's':
        Snake()
        print ("HERE")
    else:
        s.close()
        print ("Exit")
        break

