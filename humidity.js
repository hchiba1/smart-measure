#!/usr/bin/env node

const commander = require('commander')
      .option('-r, --rel <REL_HUMID>', 'relative humidity', parseFloat)
      .option('-t, --temp <TEMP>', 'temperature', parseFloat)
      .parse(process.argv);

const M = 18.01528;
const R = 8.314;

const t = commander.temp;
const rel_humid = commander.rel;
const eq_p = 6.1078 * 10 ** ((7.5 * t) / (t + 237.3));

const vol_humid = M/R * (eq_p * rel_humid) / (t + 273.15);

console.log(vol_humid);
