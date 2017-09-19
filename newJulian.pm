package Melick::newJulian;

# Copyright (c) 1999 Lyle Melick.  All rights reserved.  This
# program is free software; you may redistribute it and/or modify it
# under the same terms as Perl itself.

require 5.002;
require Exporter;

$VERSION  = "1.0";

BEGIN {
        use Exporter   ();

        @ISA        = qw(Exporter);
        @EXPORT     = qw(&JulianDate);
}

# The following defines the first
# day that the Gregorian calendar was used
# in the British Empire (Sep 14, 1752).
# The previous day was Sep 2, 1752
# by the Julian calendar.  The year began
# at March 25th before this date.
$brit_jd = 2361222;

sub main'jdate
# Usage:($month,$day,$year,$weekday) = &jdate($julian_day);

{

    local($jd) = @_;
    local($jdate_tmp);
    local($m,$d,$y,$wkday);

    warn("WARNING: $jd pre-dates British use of Gregorian calendar\n") if ($jd < $brit_jd);

# calculate weekday (0=Sun, 6=Sat)

    $wkday = ($jd + 1) % 7;
    $jdate_tmp = $jd - 1721119;
    $y = int((4 * $jdate_tmp - 1)/146097);
    $jdate_tmp = 4 * $jdate_tmp - 1 - 146097 * $y;
    $d = int($jdate_tmp/4);
    $jdate_tmp = int((4 * $d + 3)/1461);
    $d = 4 * $d + 3 - 1461 * $jdate_tmp;
    $d = int(($d +4)/4);
    $m = int((5 * $d - 3)/153);
    $d = 5 * $d - 3 - 153 * $m;
    $d = int(($d + 5)/5);
    $y = 100 * $y + $jdate_tmp;
    if($m < 10) {
       $m += 3;
    } else {
       $m -= 9;
    ++$y;
    }
    ($m,$d,$y,$wkday);
}

sub main'jday

# Usage: $julian_day = &jday($month,$day,$year)

{

    local($m,$d,$y) = @_;
    local($ya,$c);

    $y = (localtime(time))[5] + 1900 if ($y eq "");

    if ($m > 2) {
        $m -= 3;
    } else {
        $m += 9;
        --$y;
    }

    $c = int($y/100);
    $ya = $y - (100 * $c);
    $jd = int((146097 * $c)/4) + int ((1461 * $ya)/4) + int((153 * $m + 2)/5) + $d + 1721119;

    warn("WARNING: $jd pre-dates British use of Gregorian calendar\n") if ($jd < $brit_jd);

    $jd;

}

