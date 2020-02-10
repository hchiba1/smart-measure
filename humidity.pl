#!/usr/bin/perl -w
use strict;
use File::Basename;
use Getopt::Std;
my $PROGRAM = basename $0;
my $USAGE=
"Usage: $PROGRAM [options] -t TEMPERATURE -r REL_HUMID
-e: output expected errors
-R TARGET_REL_HUMID: specify target RH
";
# Hidden option:
# -a: specify target RH=55
# -v VOL_HUMID: inverse transformation to RH (use instead of -r)

my %OPT;
getopts('t:r:R:v:ae', \%OPT);

### Analyze options ###
my $Temp = $OPT{t} || die $USAGE;

if ($OPT{v}) {
    # Inverse transformation
    printf("RH: %.1f %%\n", get_rel_humid($OPT{v}, $Temp));
    exit 1;
}

my $RH = $OPT{r} || die $USAGE;

### Evaluate input values ###
my ($Temp_err, $Temp_err_msg) = eval_temperature($Temp);
my ($RH_err, $RH_err_msg) = eval_rel_humid($RH);
my $VH = get_vol_humid($RH, $Temp);

print_vol_humid($VH);

if ($OPT{e}) {
    print $Temp_err_msg;
    print $RH_err_msg;
}

printf("range: %.3f - %.3f g/m3\n", 
       get_vol_humid($RH-$RH_err, $Temp-$Temp_err), 
       get_vol_humid($RH+$RH_err, $Temp+$Temp_err));

if ($OPT{a}) {
    print_ideal_humid($Temp, $RH, 55);
}

if ($OPT{R}) {
    print_ideal_humid($Temp, $RH, $OPT{R});
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

    # Inverse transformation of get_vol_humid():
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
    my ($t, $rel_humid, $idea_rel_humid) = @_;

    my $vol_humid = get_vol_humid($rel_humid, $t);

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
