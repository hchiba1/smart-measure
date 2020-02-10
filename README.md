# smart-measure

## Humidity
**Volumetric humidity** (_VH_) can be obtained by ideal gas law:  
_pV = nRT_ with _n = w/M_  
i.e. _w/V = M/R * p/T_  
where p can be calculated by saturation vapor pressure _E(t)_ (Tetens,1930) multiplied by **relative humidity** (_RH_).  
_E(t) = 6.1078x10^(7.5t/(t+237.3))_
```
$ ./humidity.pl
Usage: humidity.pl -t TEMPERATURE -r REL_HUMID
```
```
$ ./humidity.pl -t 22.5 -r 30
VolHum : 5.992 g/m3 - Very dry (5g/m3 -> 50% flu survive, 7g/m3 -> 20% flu survive)
RelHum : 30% (consider 5% of error? 25-35%)
Temp   : 22.5 (consider 1 degree of error? 21.5-23.5)
ideally RH=55? +4.994 g/m3 -> 10.986 g/m3
VolHum range : 4.714 - 7.402 g/m3
```
Here _RH=55%_ is considered ideal, and the program calculates how much water is necessary to realize it.

### Comments about VH
- _VH = 5g/m3_ -> 50% flu survive
- _VH = 7g/m3_ -> 20% flu survive
- _VH = 11g/m3_ -> 5% flu survive
- _VH = 17g/m3_ -> no flu survive

Ideally, 11 < VH < 17 g/m3
- _VH <= 7 g/m3_ : Very dry
- _7 < VH <= 11 g/m3_ : Dry
- _11 < VH <= 17 g/m3_ : Moist
- _VH > 17 g/m3_ : Humid

### Exprected errors
Following errors are taken into consideration. (It depends on sensors used.)

_RH_
- _30 <= RH < 70_: 5%
- _RH >= 70, RH < 30_: 10%
- _RH > 90, RH < 20_: more?

_Temp_
- _10 <= Temp < 40_: 1
- _Temp >= 40, Temp < 10_: 2
- _Temp > 50, Temp < 0_: more?

Accordingly, the obtained VH may also have error to some extent.
