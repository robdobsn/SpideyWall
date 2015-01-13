import socket
import colorsys
from time import sleep
import datetime
import select

try: input = raw_input
except NameError: pass

def FindLed():
    for ii in range(100):
        cmdmsg = bytearray.fromhex("0000000103")
        s.sendto(cmdmsg, (SERVER_ADDRESS, PORT))
        ready = select.select([s], [], [], 10)
        if ready[0]:
            data = s.recv(4096)
            print ('Received', repr(data))
    
def Resize():
    cmdmsg = bytearray.fromhex("000000050410000800")
    s.sendto(cmdmsg, (SERVER_ADDRESS, PORT))
    ready = select.select([s], [], [], 10)
    if ready[0]:
        data = s.recv(4096)
        print ('Received', repr(data))

def Snake():
    #cmdmsg = bytearray.fromhex("00000005040060002001010b0200000001000000000000")
    cmdmsg = bytearray.fromhex("0000000101000b0200000001000000000000")
    msglen = 14
    TOTLEDS = 1600

    n = 0
    lasttime = datetime.datetime.now()
    for k in range(2000):

        cmdmsg[6] = 11  # fill solid = 8, fill gradient = 11
        cmdmsg[8] = int(n / 256)
        cmdmsg[9] = int(n % 256)  # start at nth led
        cmdmsg[11] = 4;  # fill nn leds
        cmdmsg[12] = 255;   # start with colour 
        cmdmsg[15] = 255;   # end with colour
        
        s.sendto(cmdmsg, (SERVER_ADDRESS, PORT))
        sleep(.05)

        difftime = datetime.datetime.now() - lasttime
        lasttime = datetime.datetime.now()
        n = n + 1
        if (n >= TOTLEDS):
            n = 0

def AllTest():
    print("All Test\n")
    cmdmsg = bytearray.fromhex("000100080200002000505050")
    s.sendto(cmdmsg, (SERVER_ADDRESS, PORT))
    ready = select.select([s], [], [], 10)
    if ready[0]:
        data = s.recv(4096)
        print ('Received', repr(data))    

def PadTest():
    print("Pad Test - Pad 5 = RED\n")
    cmdmsg = bytearray.fromhex("000100050605800000")
    s.sendto(cmdmsg, (SERVER_ADDRESS, PORT))
    ready = select.select([s], [], [], 10)
    if ready[0]:
        data = s.recv(4096)
        print ('Received', repr(data))    

def LinkTest():
    print("Link Test - Link 18 = RED\n")
    cmdmsg = bytearray.fromhex("0002000c071201800000010040008000")
    s.sendto(cmdmsg, (SERVER_ADDRESS, PORT))
    ready = select.select([s], [], [], 10)
    if ready[0]:
        data = s.recv(4096)
        print ('Received', repr(data))    

def StepTest(ledidx):
    cmdmsg = bytearray.fromhex("0000000101000b0200000001000000000000")
    msglen = 14
    TOTLEDS = 1

    n = ledidx
    for k in range(TOTLEDS):

        cmdmsg[6] = 11  # fill solid = 8, fill gradient = 11
        cmdmsg[8] = int(n / 256)
        cmdmsg[9] = int(n % 256)  # start at nth led
        cmdmsg[11] = 1;  # fill nn leds
        cmdmsg[12] = 255;   # start with colour 
        cmdmsg[15] = 255;   # end with colour
        
        s.sendto(cmdmsg, (SERVER_ADDRESS, PORT))
        print("Showing led " + str(n) + "\n")
        sleep(1)

        n = n + 1
 
SERVER_ADDRESS = "192.168.0.227"
PORT = 7
 
s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM) 
s.setblocking(0)

while True:
    inp = input('F: Find LED, S: Snake, R: Resize, A: All, P: Pad, L: Link, sTep: T, X: Exit ... ')
    if inp == "F" or inp == 'f':
        print("Find Led")
        FindLed()
    elif inp == "S" or inp == 's':
        print("Snake")
        Snake()
        print ("Snake Done")
    elif inp == "R" or inp == 'r':
        Resize()
    elif inp == "A" or inp == "a":
        AllTest()
    elif inp == "P" or inp == "p":
        PadTest()
    elif inp == "L" or inp == "l":
        LinkTest()
    elif inp == "L" or inp == "l":
        StepTest()
    elif inp == "T" or inp == "t":
        inp2 = input("LED no")
        ledidx = int(inp2)
        StepTest(ledidx)
    else:
        print ("Exiting")
        s.close()
        break

