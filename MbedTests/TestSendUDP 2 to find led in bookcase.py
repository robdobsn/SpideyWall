import socket
import colorsys
from time import sleep
import datetime
import select
import pygame
import sys

SERVER_ADDRESS = "192.168.0.101"
PORT = 7

def FindLed():
    for ii in range(100):
        cmdmsg = bytearray.fromhex("0103")
        s.sendto(cmdmsg, (SERVER_ADDRESS, PORT))
        ready = select.select([s], [], [], 10)
        if ready[0]:
            data = s.recv(4096)
            print ('Received', repr(data))
    
def Resize():
    cmdmsg = bytearray.fromhex("050409c402d4")
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

def ShowLed(ledi):
    cmdmsg = bytearray.fromhex("01010b0200000001000000000000")

    cmdmsg[2] = 11  # fill solid = 8, fill gradient = 11
    cmdmsg[4] = int(ledi / 256)
    cmdmsg[5] = int(ledi % 256)  # start at nth led
    cmdmsg[7] = 1;  # fill nn leds
    cmdmsg[8] = 255;   # start with colour 
    cmdmsg[9] = 255;   # start with colour 
    cmdmsg[10] = 255;   # start with colour 
    cmdmsg[11] = 255;   # end with colour
    cmdmsg[12] = 255;   # end with colour
    cmdmsg[13] = 255;   # end with colour
        
    s.sendto(cmdmsg, (SERVER_ADDRESS, PORT))

 
s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM) 
s.setblocking(0)

pygame.init()
screen = pygame.display.set_mode((250, 150))
pygame.display.set_caption('Find led')
pygame.key.set_repeat(300,100)

# Fill background
background = pygame.Surface(screen.get_size())
background = background.convert()
background.fill((250, 250, 250))

ledNum = 0

# Display some text
font = pygame.font.Font(None, 46)
text = font.render(str(ledNum), 1, (10, 10, 10))
textpos = text.get_rect()
textpos.centerx = background.get_rect().centerx
background.blit(text, textpos)

# Blit everything to the screen
screen.blit(background, (0, 0))
pygame.display.flip()

# Event loop
mainloop = True
while mainloop:
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            mainloop = False
            sys.exit()
        elif event.type == pygame.KEYDOWN:
            if event.key == pygame.K_ESCAPE:
                mainloop = False
            elif event.key == pygame.K_LEFT:
                ledNum = ledNum - 10
                if ledNum < 0:
                    ledNum = 0
            elif event.key == pygame.K_RIGHT:
                ledNum = ledNum + 10
            elif event.key == pygame.K_UP:
                ledNum = ledNum + 1
            elif event.key == pygame.K_DOWN:
                ledNum = ledNum - 1      
                if ledNum < 0:
                    ledNum = 0
            elif event.key == 106:
                Resize()
                print ("Resized")
                    

    
        background.fill((250, 250, 250))
        text = font.render(str(ledNum), 1, (10, 10, 10))
        textpos = text.get_rect()
        textpos.centerx = background.get_rect().centerx
        background.blit(text, textpos)
        
        screen.blit(background, (0, 0))
        pygame.display.flip()

        ShowLed(ledNum)

pygame.quit()

'''while True: 
    ev = pygame.event.get()
    for event in ev:
        if event.type == pygame.QUIT: 
            sys.exit(0) 
        elif event.type == pygame.KEYDOWN:
            if event.key == pygame.K_ESCAPE:
                sys.exit(0)
            elif event.key == pygame.K_LEFT:
                print "LEFT"
            print "KEY" + event.key

    inp = raw_input('F: Find LED, S: Snake, R: Resize, X: Exit ... ')
    if inp == "F" or inp == 'f':
        FindLed()
    elif inp == "S" or inp == 's':
        Snake()
        print ("HERE")
    elif inp == "R" or inp == 'r':
        Resize()
    else:
        s.close()
        print ("Exit")
        break

'''
