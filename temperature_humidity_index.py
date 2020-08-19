#!/usr/bin/env python3
import argparse

parser = argparse.ArgumentParser(description='Calculate temperature-humidity index')
parser.add_argument('-t', '--temperature', help='Celsius temperature')
parser.add_argument('-r', '--humidity', help='relative humidity')
args = parser.parse_args()

if not args.temperature or not args.humidity:
    parser.print_help()
    exit

di = 46.3
t = float(args.temperature)
h = float(args.humidity)

print(0.81*t)
print(di + 0.81*t)
print(0.99*t-14.3)
print((0.99*t-14.3)*h)
print((0.99*t-14.3)*h*0.01)
print(di + 0.81*t + (0.99*t-14.3)*h*0.01)
