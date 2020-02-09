# smart-measure

## humidity
Volumetric humidity (VH) can be obtained from relative humidity (RH) by ideal gas law.
```
$ ./humidity.pl
Usage: humidity.pl -r REL_HUMID -t TEMPERATURE
```
```
$ ./humidity.pl -t 20 -r 50
VolHum : 8.641 g/m3 - Dry (7g/m3: 20% flu survive, 11g/m3 -> 5% flu survive)
RelHum : 50% (consider 5% of error? 45-55%)
Temp   : 20 (consider 1 degree of error? 19-21)
ideally RH=55? +0.864 g/m3 -> 9.505 g/m3
VolHum range : 7.334 - 10.075 g/m3
```
```
$ ./humidity.pl -t 22 -r 30
VolHum : 5.823 g/m3 - Very dry (5g/m3 -> 50% flu survive, 7g/m3 -> 20% flu survive)
RelHum : 30% (consider 5% of error? 25-35%)
Temp   : 22 (consider 1 degree of error? 21-23)
ideally RH=55? +4.852 g/m3 -> 10.675 g/m3
VolHum range : 4.580 - 7.194 g/m3
```
