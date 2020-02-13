# smart-measure

## Volumetric humidity
Volumetric humidity (VH) can be calculated from relative humidity (RH) and temperature.
```
$ ./humidity.pl
Usage: humidity.pl [options] -r REL_HUMID -t TEMPERATURE
-A TARGET_VOL_HUMID: specify target VH
-R TARGET_REL_HUMID: specify target RH
-V CUBIC_METER: specify volume of room
-e: output expected errors
```

### Examples
```
$ ./humidity.pl -t 22.5 -r 30
5.99 g/m3 - Very dry (5g/m3 -> 50% flu survive, 7g/m3 -> 20% flu survive)
```
Here, _VH=11_ is considered ideal, and the program calculates how much water is necessary to realize it in the specified volume of room.
```
$ ./humidity.pl -t 22.5 -r 30 -A 11 -V 500
5.99 g/m3 - Very dry (5g/m3 -> 50% flu survive, 7g/m3 -> 20% flu survive)
+5.01 g/m3 -> 11.0 g/m3, RH=55.1% (+2.50L for 500.0m3)
```
Humidity sensors may have error to some extent.
```
$ ./humidity.pl -t 22.5 -r 30 -e
5.99 g/m3 - Very dry (5g/m3 -> 50% flu survive, 7g/m3 -> 20% flu survive)
(5% of error for RH=30%?: 25-35%)
(1 degree of error for Temp=22.5?: 21.5-23.5)
range: 4.71 - 7.40 g/m3
```

### Formula
**Volumetric humidity** (VH) can be obtained by ideal gas law:  
_pV = nRT_ with _n = w/M_  
_i.e. VH_: _w/V = M/R * p/T_  
where p can be calculated by saturation vapor pressure _E(t)_ (Tetens,1930) multiplied by **relative humidity** (RH).  
_p = E(t) * RH_  
_E(t) = 6.1078x10^(7.5t/(t+237.3))_

### Comments about VH
- _VH = 5g/m3_ -> 50% flu survive
- _VH = 7g/m3_ -> 20% flu survive
- _VH = 11g/m3_ -> 5% flu survive
- _VH = 17g/m3_ -> no flu survive

Preferably, _11 < VH < 17 g/m3_
- _VH <= 7 g/m3_ : Very dry
- _7 < VH <= 11 g/m3_ : Dry
- _11 < VH <= 17 g/m3_ : Moist
- _VH > 17 g/m3_ : Humid

### Exprected errors
Following errors are taken into consideration. (It depends on sensors used.)

RH
- _30 <= RH < 70_: 5%
- _RH >= 70, RH < 30_: 10%
- _RH > 90, RH < 20_: more?

Temp
- _10 <= Temp < 40_: 1
- _Temp >= 40, Temp < 10_: 2
- _Temp > 50, Temp < 0_: more?

Accordingly, the obtained VH may also have error to some extent.
