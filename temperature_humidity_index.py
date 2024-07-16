#!/usr/bin/env python3
import argparse

parser = argparse.ArgumentParser(description='Calculate temperature-humidity index')
parser.add_argument('-t', '--temperature', help='Celsius temperature')
parser.add_argument('-r', '--humidity', help='relative humidity')
parser.add_argument('-v', '--verbose', action='store_true', help='verbose')
args = parser.parse_args()

if not args.temperature or not args.humidity:
    parser.print_help()
    exit(0)

t = float(args.temperature)
h = float(args.humidity)
di = 0.81*t + 0.01*h*(0.99*t-14.3) + 46.3
# or THI =0.8*T + RH*(T-14.4) + 46.4
di2 = 0.8*t + 0.01*h*(t-14.4) + 46.4

if args.verbose:
    print('0.81T =', 0.81*t, sep="\t")
    print('46.3 + 0.81T =', 46.3 + 0.81*t, sep="\t")
    print('H(0.99T - 14.3) =', (0.99*t-14.3)*h*0.01)
    print('46.3 + 0.81T + H(0.99T-14.3) =', di)
    print('0.8T + RH(T-14.4) + 46.4 =', di2)
else:
    print(di, end=': ')

if di >= 85:
    print('Too Hot!!')
elif di >= 80:
    print('Hot')
elif di >= 77:
    print('Bit Hot')
elif di >= 70:
    print('Not Hot')
elif di >= 65:
    print('Good!')
elif di >= 60:
    print('None')
elif di >= 55:
    print('Bit Cold')
else:
    print('Cold')
