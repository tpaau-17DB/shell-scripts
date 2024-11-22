#!/usr/bin/python3

"""
This script is used to display CPU usage in the form of a bar, so it's easier to read.
It was primarily designed for use with Waybar.

Requirements: python3 and psutil
"""

import sys
import psutil

# Print the bar
def print_loading_bar(value, max_value, length = 30, fill = '#'):
    """
    Method used to quickly create loading bars
    """
    percent = value / max_value
    filled_length = int(length * percent)
    loading_bar = fill * filled_length + '-' * (length - filled_length)
    print(f' [{loading_bar}]')
    sys.stdout.flush()

# Get the cpu usage and print it as a bar
def print_cpu_usage():
    while True:
        cpu_usage = psutil.cpu_percent(interval=1)
        print_loading_bar(cpu_usage, 100)

if __name__ == "__main__":
    print_cpu_usage()
