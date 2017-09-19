package Melick::Time;

# Copyright (c) 1999 Lyle Melick.  All rights reserved.  This
# program is free software; you may redistribute it and/or modify it
# under the same terms as Perl itself.

require 5.002;
require Exporter;

$VERSION  = "1.0";

BEGIN {
        use Exporter   ();

        @ISA        = qw(Exporter);
        @EXPORT     = qw(&Time);
}

#--------------------
#
# Get todays date...
#
#--------------------
sub Time {

#-------
#
# Arrays
#
#-------
    @WeekDay = ('Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday');

    @Month = ('Invalid Month','January','February','March','April','May','June','July','August','September','October','November','December');

#-----
#
# Pull Date
#
#-----
    ($sec,$minute,$hour,$mday,$mon,$yr,$wday,$yday,$isdst) = localtime(time);

    while (length($hour) < 2) {
        $hour = join('', '0', $hour);
    }

    while (length($minute) < 2) {
        $minute = join('', '0', $minute);
    }

    while (length($sec) < 2) {
        $sec = join('', '0', $sec);
    }

    $Time = join("",$hour,":",$minute,":",$sec);

}

$Time;
1;
__END__

