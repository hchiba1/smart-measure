#!/usr/bin/perl -w
use strict;
use File::Basename;
use Getopt::Std;
my $PROGRAM = basename $0;
my $USAGE=
"Usage: $PROGRAM -t TEMPERATURE -r REL_HUMID
";
# Hidden option:
# -v VOL_HUMID: transform VH to RH (use instead of -r)

my %OPT;
getopts('t:r:v:', \%OPT);

my $t = $OPT{t} || die $USAGE;
if ($OPT{v}) {
    printf("RelHum : %.1f %%\n", get_rel_humid($OPT{v}, $t));
    exit 1;
}
my $rel_humid = $OPT{r} || die $USAGE;

my $vol_humid = get_vol_humid($rel_humid, $t);
printf("VolHum : %.3f g/m3", $vol_humid);
if ($vol_humid >= 17) {
    print " - Humid (17g/m3 -> no flu survive)\n";
} elsif ($vol_humid > 11) {
    print " - Moist (11g/m3 -> 5% flu survive, 17g/m3 -> no flu survie)\n";
} elsif ($vol_humid > 7) {    
    print " - Dry (7g/m3: 20% flu survive, 11g/m3 -> 5% flu survive)\n";
} else {
    print " - Very dry (5g/m3 -> 50% flu survive, 7g/m3 -> 20% flu survive)\n";
}

print "RelHum : $rel_humid% (";
my $percent_error = 10;
if ($rel_humid > 90) {
    print "too high to measure; ";
} elsif ($rel_humid >= 70) {
    $percent_error = 10
} elsif ($rel_humid >= 30) {
    $percent_error = 5;
} elsif ($rel_humid >= 20) {
    $percent_error = 10;
} else {
    print "too low to measure; ";
}
print "consider $percent_error% of error? ";
print $rel_humid-$percent_error, "-", $rel_humid+$percent_error, "%";
print ")\n";

print "Temp   : ${t} (";
my $t_error = 1;
if ($t > 50) {
    print "too high to measure; ";
} elsif ($t >= 40) {
    $t_error = 2;
} elsif ($t >= 10) {
    $t_error = 1;
} elsif ($t >= 0) {
    $t_error = 2;
} else {
    print "too low to measure; ";
}
print "consider $t_error degree of error? ";
print $t-$t_error, "-", $t+$t_error;
print ")\n";

my $idea_rel_humid = 55;
if ($rel_humid != $idea_rel_humid) {
    my $idea_vol_humid = get_vol_humid($idea_rel_humid, $t);
    print "ideally RH=$idea_rel_humid? ";
    if ($idea_vol_humid >= $vol_humid) {
        print "+";
    }
    printf "%.3f", $idea_vol_humid - $vol_humid;
    print " g/m3";
    printf(" -> %.3f g/m3", $idea_vol_humid);
    print "\n";
}

printf("VolHum range : %.3f - %.3f g/m3\n", get_vol_humid($rel_humid-$percent_error, $t-$t_error), get_vol_humid($rel_humid+$percent_error, $t+$t_error));

################################################################################
### Functions ##################################################################
################################################################################

# Volumetric humidity can be obtained from relative humidity by ideal gas law
sub get_vol_humid {
    my ($rel_humid, $t) = @_;
    
    # Equilibrium vapor pressure of water by Tetens (1930)
    my $eq_p = 6.1078 * 10 ** ((7.5 * $t) / ($t + 237.3));
    # the factor is about 6.11

    # Volumetric humidity can be obtained by ideal gas law
    #  pV = nRT with n = w/M
    #  i.e. w/V = M/R * p/T
    # and vapor pressure of water
    #  p = eq_p * rel_humid
    my $M = 18.01528; # molar mass of H2O
    my $R = 8.314;

    my $vol_humid = $M/$R * ($eq_p * $rel_humid) / ($t + 273.15);
    # M/R is about 2.17
}

sub get_rel_humid {
    my ($vol_humid, $t) = @_;

    my $eq_p = 6.1078 * 10 ** ((7.5 * $t) / ($t + 237.3));

    # w/V (= Hv) = M/R * Ps/T * Hr
    # i.e. Hv * R/M * T/Ps = Hr
    my $M = 18.01528;
    my $R = 8.314;

    my $rel_humid = $R/$M * ($t + 273.15) / $eq_p * $vol_humid;
}
