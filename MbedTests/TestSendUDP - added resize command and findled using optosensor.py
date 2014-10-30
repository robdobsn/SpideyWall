import socket
import colorsys
from time import sleep
import datetime
import select

try: input = raw_input
except NameError: pass

def FindLed():
    for ii in range(100):
        cmdmsg = bytearray.fromhex("0103")
        s.sendto(cmdmsg, (SERVER_ADDRESS, PORT))
        ready = select.select([s], [], [], 10)
        if ready[0]:
            data = s.recv(4096)
            print ('Received', repr(data))
    
def Resize():
    cmdmsg = bytearray.fromhex("050410000800")
    s.sendto(cmdmsg, (SERVER_ADDRESS, PORT))
    ready = select.select([s], [], [], 10)
    if ready[0]:
        data = s.recv(4096)
        print ('Received', repr(data))

def Snake():
    #cmdmsg = bytearray.fromhex("05040060002001010b0200000001000000000000")
    cmdmsg = bytearray.fromhex("01010b0200000001000000000000")
    msglen = 14
    TOTLEDS = 120

    n = 0
    lasttime = datetime.datetime.now()
    for k in range(1000):

        cmdmsg[2] = 11  # fill solid = 8, fill gradient = 11
        cmdmsg[4] = int(n / 256)
        cmdmsg[5] = int(n % 256)  # start at nth led
        cmdmsg[7] = 1;  # fill nn leds
        cmdmsg[8] = 255;   # start with colour 
        cmdmsg[11] = 255;   # end with colour
        
        s.sendto(cmdmsg, (SERVER_ADDRESS, PORT))
        sleep(.05)

        difftime = datetime.datetime.now() - lasttime
        lasttime = datetime.datetime.now()
        n = n + 1
        if (n >= TOTLEDS):
            n = 0


 
SERVER_ADDRESS = "192.168.0.84"
PORT = 7
 
s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM) 
s.setblocking(0)

while True:
    inp = input('F: Find LED, S: Snake, R: Resize, X: Exit ... ')
    if inp == "F" or inp == 'f':
        print("Find Led")
        FindLed()
    elif inp == "S" or inp == 's':
        print("Snake")
        Snake()
        print ("Snake Done")
    elif inp == "R" or inp == 'r':
        Resize()
    else:
        print ("Exiting")
        s.close()
        break

