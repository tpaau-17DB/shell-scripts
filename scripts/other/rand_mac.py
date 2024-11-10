#!/usr/bin/python3

"""
Just a script that returns a random MAC address

Requirements: pyhon3
"""

import random

def generate_mac():
    first_byte = random.randint(0x00, 0xFF) & 0xFE
    mac = [first_byte]
    for _ in range(5):
        byte = random.randint(0x00, 0xFF)
        mac.append(byte)
    mac_address = ":".join(f"{byte:02x}" for byte in mac)
    return mac_address
print(generate_mac())
