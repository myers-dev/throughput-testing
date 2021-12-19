#!/usr/bin/python3 

import socket
import sys
import _thread
import time

global __DEBUG__
__DEBUG__=True

def connection_handler(host,port):
    while True:
        try:
            s=socket.socket()
        except:
            if __DEBUG__:
                print (f'Failed to create socket')
            sys.exit(1)

        s.connect((host, port))
        msg1=s.recv(1024).decode('utf-8')
        if __DEBUG__:
            print(msg1)
        msg2=s.recv(1024).decode('utf-8')
        if __DEBUG__:
            print(msg2)
        s.close()


host = "10.1.0.4"
#host = socket.gethostname()

threads=5
starting_port = 1025

for i in range(threads):
    _thread.start_new_thread(connection_handler,(host,starting_port,))
    if __DEBUG__:
        print (f"Started thread to handle connection {i}")

while True:
    pass