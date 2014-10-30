import socket
import colorsys
from time import sleep
import datetime
import select

SERVER_ADDRESS = "192.168.0.207"
PORT = 7
 
s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
s.bind((SERVER_ADDRESS, PORT))

while True:
    data, addr = s.recvfrom(1024)
    print "recv ", data

