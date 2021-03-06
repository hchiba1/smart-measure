#!/usr/bin/perl -w
use strict;
use File::Basename;
use Getopt::Std;
my $PROGRAM = basename $0;
my $USAGE=
"Usage: $PROGRAM [options] -r REL_HUMID -t TEMPERATURE
-A TARGET_VOL_HUMID: specify target VH
-R TARGET_REL_HUMID: specify target RH
-V CUBIC_METER: specify volume of room
-e: output expected errors
";
# Hidden options:
# -a VOL_HUMID: inverse transformation to RH (use instead of -r)

my %OPT;
getopts('t:r:eR:V:a:A:', \%OPT);

### Analyze options ###
my $Temp = $OPT{t} || die $USAGE;

if ($OPT{a}) {
    # Inverse transformation
    printf("RH: %.1f %%\n", get_rel_humid($OPT{a}, $Temp));
    exit 1;
}

my $RH = $OPT{r} || die $USAGE;

### Evaluate input values ###
my $VH = get_vol_humid($RH, $Temp);

print_vol_humid($VH);

if ($OPT{e}) {
    my ($Temp_err, $Temp_err_msg) = eval_temperature($Temp);
    my ($RH_err, $RH_err_msg) = eval_rel_humid($RH);
    print $RH_err_msg;
    print $Temp_err_msg;
    printf("range: %.2f - %.2f g/m3\n", 
           get_vol_humid($RH-$RH_err, $Temp-$Temp_err), 
           get_vol_humid($RH+$RH_err, $Temp+$Temp_err));
}

if ($OPT{R}) {
    eval_target_rh($Temp, $RH, $OPT{R});
}

if ($OPT{A}) {
    eval_target_vh($Temp, $VH, $OPT{A});
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

    return($vol_humid);
}

sub get_rel_humid {
    my ($vol_humid, $t) = @_;

    # Inverse transformation of get_vol_humid():
    #  rel_humid = R/M * T/eq_p * vol_humid

    my $eq_p = 6.1078 * 10 ** ((7.5 * $t) / ($t + 237.3));

    my $M = 18.01528;
    my $R = 8.314;

    my $rel_humid = $R/$M * ($t + 273.15) / $eq_p * $vol_humid;

    return($rel_humid);
}

sub eval_rel_humid {
    my ($rel_humid) = @_;

    my $msg = "(";
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
    $msg .= "$percent_error% of error for RH=$rel_humid%?: ";
    $msg .= $rel_humid-$percent_error;
    $msg .= "-";
    $msg .= $rel_humid+$percent_error;
    $msg .= "%)\n";

    return($percent_error, $msg);
}

sub eval_temperature {
    my ($t) = @_;

    my $msg = "(";
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
    $msg .= "$t_error degree of error for Temp=${t}?: ";
    $msg .= $t-$t_error;
    $msg .= "-";
    $msg .= $t+$t_error;
    $msg .= ")\n";

    return($t_error, $msg);
}

sub print_vol_humid {
    my ($vol_humid) = @_;

    printf("%.2f g/m3", $vol_humid);
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

sub eval_target_rh {
    my ($t, $rel_humid, $idea_rel_humid) = @_;

    my $vol_humid = get_vol_humid($rel_humid, $t);

    if ($rel_humid != $idea_rel_humid) {
        my $idea_vol_humid = get_vol_humid($idea_rel_humid, $t);
        print "aim at RH=$idea_rel_humid? VH: ";
        if ($idea_vol_humid >= $vol_humid) {
            print "+";
        }
        my $vh_diff = $idea_vol_humid - $vol_humid;
        printf "%.2f g/m3 -> %.2f g/m3", $vh_diff, $idea_vol_humid;
        if ($OPT{V}) {
            my $volume = $OPT{V};
            print " (";
            if ($idea_vol_humid >= $vol_humid) {
                print "+";
            }
            printf "%.2fL for %.1fm3)", $vh_diff * $volume / 1000, $volume;
        }
        print "\n";
    }
}

sub eval_target_vh {
    my ($t, $vol_humid, $idea_vol_humid) = @_;

    if ($vol_humid != $idea_vol_humid) {
        if ($idea_vol_humid >= $vol_humid) {
            print "+";
        }
        my $vh_diff = $idea_vol_humid - $vol_humid;
        printf "%.2f g/m3 -> %.1f g/m3", $vh_diff, $idea_vol_humid;
        my $rel_humid = get_rel_humid($idea_vol_humid, $Temp);
        printf ", RH=%.1f%%", $rel_humid;
        if ($OPT{V}) {
            my $volume = $OPT{V};
            print " (";
            if ($idea_vol_humid >= $vol_humid) {
                print "+";
            }
            printf "%.2fL for %.1fm3)", $vh_diff * $volume / 1000, $volume;
        }
        print "\n";
    }
}
