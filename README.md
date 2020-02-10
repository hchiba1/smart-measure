# smart-measure

## Humidity
**Volumetric humidity** can be obtained by ideal gas law:  
_pV = nRT_ with _n = w/M_  
i.e. _w/V = M/R * p/T_  
where p can be calculated by saturation vapor pressure _E(t)_ (Tetens, 1930) multiplied by **relative humidity**.  
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
Here RH=55% is considered ideal, and the program calculates how much water is necessary to realize it.

### Comments about VH
- VH = 5g/m3 -> 50% flu survive
- VH = 7g/m3 -> 20% flu survive
- VH = 11g/m3 -> 5% flu survive
- VH = 17g/m3 -> no flu survive

Ideally, 11 < VH < 17 g/m3
- VH <= 7 g/m3 : Very dry
- 7 < VH <= 11 g/m3 : Dry
- 11 < VH <= 17 g/m3 : Moist
- VH > 17 g/m3 : Humid

### Exprected errors
Following errors are taken into consideration. (It depends on sensors used.)

RH
- 30 <= RH < 70: 5%
- RH >= 70, RH < 30: 10%
- RH > 90, RH < 20: more?

Temp
- 10 <= Temp < 40: 1
- Temp >= 40, Temp < 10: 2
- Temp > 50, Temp < 0: more?

Accordingly, the obtained VH may also have error to some extent.
