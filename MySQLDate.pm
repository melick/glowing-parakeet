package Melick::MySQLDate;

# Copyright (c) 2002 Lyle Melick.  All rights reserved.  This
# program is free software; you may redistribute it and/or modify it
# under the same terms as Perl itself.

require 5.002;
require Exporter;

$VERSION  = "1.0";

BEGIN {
        use Exporter   ();

        @ISA        = qw(Exporter);
        @EXPORT     = qw(&MySQLDate);
}

#--------------------
#
# Get todays date...
#
#--------------------
sub MySQLDate {

#-----
#
# Pull Date
#
#-----
    ($sec,$minute,$hour,$mday,$mon,$yr,$wday,$yday,$isdst) = localtime(time);

# Year
    $year = $yr + 1900;

# Month
    $mon++;
    if ($mon <= 9) {
        $month = join("", "0", $mon);
    } else {
        $month = $mon;
    }

# Day
    if ($mday <= 9) {
        $Mday = join("", "0", $mday);
    } else {
        $Mday = $mday;
    }

# Short Form
    $TodaysDate = join("-",$year,$month,$Mday);

}

$TodaysDate;
1;
__END__

