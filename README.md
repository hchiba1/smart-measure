# smart-measure

## humidity
Volumetric humidity (VH) can be obtained by ideal gas law  
_pV = nRT with n = w/M_  
i.e. VH: _w/V = M/R * p/T_  
p is obtained by saturation vapor pressure (Tetens, 1930) multiplied by relative humidity (RH).
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
Here RH=55% is considered as ideal humidity, and the program calculates how much water is necessary to realize it.

### Exprected errors
Following errors are taken into consideration.

RH
- 30 <= RH < 70: 5%
- RH >= 70, RH < 20: 10%

Temp
- 10 <= Temp < 40: 1
- Temp >= 40, Temp < 10 :2

Accordingly, obtained VH may have error.
