# smart-measure

## Volumetric humidity
Volumetric humidity (VH) can be calculated from relative humidity (RH) and temperature.
```
$ ./humidity.pl
Usage: humidity.pl [options] -r REL_HUMID -t TEMPERATURE
-e: output expected errors
-R TARGET_REL_HUMID: specify target RH
```

### Examples
```
$ ./humidity.pl -t 22.5 -r 30
5.992 g/m3 - Very dry (5g/m3 -> 50% flu survive, 7g/m3 -> 20% flu survive)
range: 4.714 - 7.402 g/m3
```
```
$ ./humidity.pl -t 22.5 -r 30 -e
5.992 g/m3 - Very dry (5g/m3 -> 50% flu survive, 7g/m3 -> 20% flu survive)
Temp=22.5 (consider 1 degree of error? 21.5-23.5)
RH=30% (consider 5% of error? 25-35%)
range: 4.714 - 7.402 g/m3
```
```
$ ./humidity.pl -t 22.5 -r 30 -R 55
5.992 g/m3 - Very dry (5g/m3 -> 50% flu survive, 7g/m3 -> 20% flu survive)
range: 4.714 - 7.402 g/m3
aim at RH=55? VH: +4.994 g/m3 -> 10.986 g/m3
```
Here, _RH=55%_ is considered ideal, and the program calculates how much water is necessary to realize it.

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
