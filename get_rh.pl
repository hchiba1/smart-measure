#!/usr/bin/perl -w
use strict;
use File::Basename;
use Getopt::Std;
my $PROGRAM = basename $0;
my $USAGE=
"Usage: $PROGRAM -t TEMPERATURE -v HOL_HUMID
";

my %OPT;
getopts('t:v:', \%OPT);

my $t = $OPT{t} || die $USAGE;
my $vol_humid = $OPT{v} || die $USAGE;

my $rel_humid = transform_humidity($vol_humid, $t);
printf("RelHum : %.1f %%\n", $rel_humid);

################################################################################
### Functions ##################################################################
################################################################################

# Volumetric humidity can be obtained from relative humidity by ideal gas law
sub transform_humidity {
    my ($vol_humid, $t) = @_;
    
    # Equilibrium vapor pressure of water by Tetens (1930)
    my $eq_p = 6.1078 * 10 ** ((7.5 * $t) / ($t + 237.3));
    # the factor is about 6.11

    # Relative humidity can be obtained by ideal gas law
    #  pV = nRT with n = w/M
    # and vapor pressure of water
    #  p = Ps * Hr
    # i.e. Hr = R/M * T/Ps *Hr
    my $M = 18.01528; # molar mass of H2O
    my $R = 8.314;

    my $rel_humid = $R/$M * ($t + 273.15) / $eq_p * $vol_humid;
}
