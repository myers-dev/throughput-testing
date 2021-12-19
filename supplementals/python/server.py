#!/usr/bin/python3

import socket
import sys
import _thread
import time
from datetime import datetime

global __DEBUG__
__DEBUG__=True

def connection_handler(s,number,port):
    sleep=6
    while True:
        c, addr = s.accept()
        if __DEBUG__:
            print(f"Got connection from {addr} socket number {number} port {port}")
        msg = f"RCV from {addr[0]}:{addr[1]} to {host}:{port} sleeping {sleep} seconds"
        c.send(bytes(msg,"utf-8"))
        time.sleep(sleep)

        msg = f"Closing connection from {addr[0]}:{addr[1]} to {host}:{port}"
        c.send(bytes(msg,"utf-8"))
        c.close()

host = socket.gethostname()

port_range = 1
starting_port = 1025

s=[None]*port_range

for i in range(port_range):
    try:
        s[i] = socket.socket()
        if __DEBUG__:
            print(f"Successfully created socket #{i}")
    except socket.error:
        if __DEBUG__:
            print (f'Failed to create socket #{i}')
        sys.exit(1)

port = starting_port

for i in range(port_range):
    try:
        s[i].bind((host, port))
        if __DEBUG__:
            print(f"Successfully executed bind socket {i} port {port}")
    except:
        if __DEBUG__:
            print(f"Failed to bind socket {i} port {port}")
        sys.exit(1)
    port+=1

for i in range(port_range):
    try:
        s[i].listen()
        if __DEBUG__:
            print(f"Successfully made a socket {i} as listen")
    except:
        if __DEBUG__:
            print(f"Failed to made a socket {i} as listen")
        sys.exit(1)

for i in range(port_range):
    _thread.start_new_thread(connection_handler,(s[i],i,starting_port + i,))
    if __DEBUG__:
        print (f"Started thread to handle connection {s[i]}")

while True:
    pass