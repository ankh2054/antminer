
#!/usr/bin/env python3

# A simple script for managing cgminer devices
# python3 miner3.py 192.168.88.250 summary

import socket  # import the built-in package to open a TCP/IP socket to connect to miners
import json  # use the JSON package to format messages sent to the miner
import sys

api_command = sys.argv[2]
data = {'command': api_command}

def api_cmd(hostaddress=sys.argv[1]):  # take the sysarg passed host IP address and send it a status command

    try:  # use the try command to help catch errors
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)  # use the socket package to create a new connection
        sock.settimeout(5)  # set the socket timeout to five second
        sock.connect((hostaddress, 4028))  # connect to the provided host

        message = json.dumps(data)  # create the JSON formatted command using sysarg input
        sock.sendto(message.encode(), (hostaddress, 4028))  # send the command to the miner
        response = sock.recv(4096).decode("ascii").rstrip(' \t\r\n\0')  # receive and clean up the response

        sock.shutdown(socket.SHUT_RDWR)  # send the shutdown to the socket so it closes the connection cleanly
        sock.close()  # close our socket

        response_decoded = json.loads(response)  # decode the JSON response so we can access the individual data later
        print(response_decoded)  # print the entire response received

    except Exception as e:
        print("Error: " + str(e))  # if there is an error, print it


def main():
    #check_status("192.168.88.250")
    api_cmd()

main()
