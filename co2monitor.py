#!/usr/bin/env python3
import sys
import re
import time
from datetime import datetime
import argparse
from CO2Meter.CO2Meter import *
import requests

parser = argparse.ArgumentParser(description='CO2Monitor')
parser.add_argument('-d', '--dev', default=0, type=int, help='devise number')
parser.add_argument('--ambient', help='channel and key for Ambient')
args = parser.parse_args()

dev = f"/dev/hidraw{args.dev}"
sensor = CO2Meter(dev)

channel, key = '', ''
if args.ambient:
    matched = re.search(r'^(\d+):([0-9a-z]+)$', args.ambient)
    if not matched:
        print('ERROR: invalid value in --ambient')
        sys.exit(1)
    channel, key = matched.groups()

while True:
    sensor_data = sensor.get_data()
    now = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    if not 'co2' in sensor_data or not 'temperature' in sensor_data:
        time.sleep(1)
        continue
    co2 = sensor_data['co2']
    temp = sensor_data['temperature']
    data = [{'created': now, 'd6': co2, 'd7': temp}]
    print(data, flush=True)
    if args.ambient:
        try:
            r = requests.post(f'https://ambidata.io/api/v2/channels/{channel}/dataarray', json={'writeKey': key, 'data': data})
        except requests.exceptions.ConnectionError as e:
            print(e, file=sys.stderr)
    time.sleep(300)
