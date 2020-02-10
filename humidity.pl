#!/usr/bin/perl -w
use strict;
use File::Basename;
use Getopt::Std;
my $PROGRAM = basename $0;
my $USAGE=
"Usage: $PROGRAM [options] -t TEMPERATURE -r REL_HUMID
-a: aim at ideal humidity
-e: output expected errors
";
# Hidden option:
# -v VOL_HUMID: inverse transformation to RH (use instead of -r)

my %OPT;
getopts('t:r:v:ae', \%OPT);

### Analyze options ###
my $temp = $OPT{t} || die $USAGE;

if ($OPT{v}) {
    # Inverse transformation
    printf("RH: %.1f %%\n", get_rel_humid($OPT{v}, $temp));
    exit 1;
}

my $rel_humid = $OPT{r} || die $USAGE;

### Evaluate input values ###
my ($temp_error, $tmp_error_msg) = eval_temperature($temp);
my ($rh_error, $rh_error_msg) = eval_rel_humid($rel_humid);
my $vol_humid = get_vol_humid($rel_humid, $temp);

print_vol_humid($vol_humid);

if ($OPT{e}) {
    print $tmp_error_msg;
    print $rh_error_msg;
}

printf("range: %.3f - %.3f g/m3\n", 
       get_vol_humid($rel_humid-$rh_error, $temp-$temp_error), 
       get_vol_humid($rel_humid+$rh_error, $temp+$temp_error));

if ($OPT{a}) {
    print_ideal_humid($rel_humid, $vol_humid, $temp);
}

################################################################################
### Functions ##################################################################
################################################################################

# Volumetric humidity can be obtained from relative humidity by ideal gas law
sub get_vol_humid {
    my ($rel_humid, $t) = @_;

    # Volumetric humidity can be obtained by ideal gas law
    #  pV = nRT with n = w/M
    #  i.e. w/V = M/R * p/T
    # and vapor pressure of water
    #  p = eq_p * rel_humid
    # i.e. vol_humid = M/R * eq_p/T * rel_humid

    # Equilibrium vapor pressure of water by Tetens (1930)
    my $eq_p = 6.1078 * 10 ** ((7.5 * $t) / ($t + 237.3));

    my $M = 18.01528; # molar mass of H2O
    my $R = 8.314;

    my $vol_humid = $M/$R * ($eq_p * $rel_humid) / ($t + 273.15);
}

sub get_rel_humid {
    my ($vol_humid, $t) = @_;

    # Inverse of get_vol_humid:
    #  rel_humid = R/M * T/eq_p * vol_humid

    my $eq_p = 6.1078 * 10 ** ((7.5 * $t) / ($t + 237.3));

    my $M = 18.01528;
    my $R = 8.314;

    my $rel_humid = $R/$M * ($t + 273.15) / $eq_p * $vol_humid;
}

sub eval_rel_humid {
    my ($rel_humid) = @_;

    my $msg = "";
    $msg .= "RH=$rel_humid% (";
    my $percent_error = 10;
    if ($rel_humid > 90) {
        $msg .= "too high to measure; ";
    } elsif ($rel_humid >= 70) {
        $percent_error = 10
    } elsif ($rel_humid >= 30) {
        $percent_error = 5;
    } elsif ($rel_humid >= 20) {
        $percent_error = 10;
    } else {
        $msg .= "too low to measure; ";
    }
    $msg .= "consider $percent_error% of error? ";
    $msg .= $rel_humid-$percent_error;
    $msg .= "-";
    $msg .= $rel_humid+$percent_error;
    $msg .= "%";
    $msg .= ")\n";

    return($percent_error, $msg);
}

sub eval_temperature {
    my ($t) = @_;

    my $msg = "";
    $msg .= "Temp=${t} (";
    my $t_error = 1;
    if ($t > 50) {
        $msg .= "too high to measure; ";
    } elsif ($t >= 40) {
        $t_error = 2;
    } elsif ($t >= 10) {
        $t_error = 1;
    } elsif ($t >= 0) {
        $t_error = 2;
    } else {
        $msg .= "too low to measure; ";
    }
    $msg .= "consider $t_error degree of error? ";
    $msg .= $t-$t_error;
    $msg .= "-";
    $msg .= $t+$t_error;
    $msg .= ")\n";

    return($t_error, $msg);
}

sub print_vol_humid {
    my ($vol_humid) = @_;

    printf("%.3f g/m3", $vol_humid);
    if ($vol_humid > 17) {
        print " - Humid (17g/m3 -> no flu survive)\n";
    } elsif ($vol_humid > 11) {
        print " - Moist (11g/m3 -> 5% flu survive, 17g/m3 -> no flu survie)\n";
    } elsif ($vol_humid > 7) {
        print " - Dry (7g/m3: 20% flu survive, 11g/m3 -> 5% flu survive)\n";
    } else {
        print " - Very dry (5g/m3 -> 50% flu survive, 7g/m3 -> 20% flu survive)\n";
    }
}

sub print_ideal_humid {
    my ($rel_humid, $vol_humid, $t) = @_;

    my $idea_rel_humid = 50;

    if ($rel_humid != $idea_rel_humid) {
        my $idea_vol_humid = get_vol_humid($idea_rel_humid, $t);
        print "aim at RH=$idea_rel_humid? VH: ";
        if ($idea_vol_humid >= $vol_humid) {
            print "+";
        }
        printf "%.3f", $idea_vol_humid - $vol_humid;
        print " g/m3";
        printf(" -> %.3f g/m3", $idea_vol_humid);
        print "\n";
    }
}
