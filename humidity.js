#!/usr/bin/env node

const commander = require('commander')
      .option('-r, --rel <REL_HUMID>', 'relative humidity', parseFloat)
      .option('-t, --temp <TEMP>', 'temperature', parseFloat)
      .parse(process.argv);

const vol_humid = get_vol_humid(commander.temp, commander.rel);
console.log(vol_humid.toFixed(2), 'g/m3');

// Functions
function get_vol_humid(t, rel_humid) {
  const M = 18.01528;
  const R = 8.314;

  const eq_p = 6.1078 * 10 ** ((7.5 * t) / (t + 237.3));
  const vol_humid = M/R * (eq_p * rel_humid) / (t + 273.15);

  return vol_humid;
}
