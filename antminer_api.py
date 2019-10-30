#!/usr/bin/env python3

# Copyright 2013 Setkeh Mkfr
#
# This program is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.  See COPYING for more details.

#Short Python Example for connecting to The Cgminer API
#Written By: setkeh <https://github.com/setkeh>
#Thanks to Jezzz for all his Support.
#NOTE: When adding a param with a pipe | in bash or ZSH you must wrap the arg in quotes
#E.G "pga|0"


#python miner.py 192.168.88.250 stats

import socket
import json
import sys

def linesplit(socket):
        buffer = socket.recv(4096).decode("ascii").rstrip(' \t\r\n\0') 
        done = False
        while not done:
                more = socket.recv(4096).decode("ascii").rstrip(' \t\r\n\0') 
                if not more:
                        done = True
                else:
                        buffer = buffer+more
        if buffer:
                return buffer

api_command = sys.argv[2]
data = {'command': api_command}
api_ip = sys.argv[1]


s = socket.socket(socket.AF_INET,socket.SOCK_STREAM)
s.connect((api_ip, 4028))
message = json.dumps(data)
s.sendto(message.encode(), (api_ip, 4028))

response = linesplit(s)
print(response)
response = json.loads(response)
print(response)
s.close()
