#!/usr/bin/env python3
import time
from datetime import datetime
from CO2Meter.CO2Meter import *
import requests

sensor = CO2Meter("/dev/hidraw5")

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
    r = requests.post('https://ambidata.io/api/v2/channels/25097/dataarray', json={'writeKey': 'f636e04ddb53c434', 'data': data})
    time.sleep(300)