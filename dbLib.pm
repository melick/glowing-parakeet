package Melick::dbLib;

# Copyright (c) 2014 Lyle Melick.  All rights reserved.  This
# program is free software; you may redistribute it and/or modify it
# under the same terms as Perl itself.

# ----- connects to the desired SQL Server database.  Called by all perls creating/altering Views, Tables or Stored Procedures and making sure they got created.
#       Lyle Melick - lmelick@ssandg.com - SS&G Healthcare Services LLC
#       Created: 2014 May 09 from previous implementations - LOMelick
#       File name: $HeadURL: file://192.168.43.18/users$/LMelick/SVN/TAC_Missing_CoPay/trunk/lib/dbLib.pm $
#
        my $Author    = 'Last updated by: $Author: lmelick $';
        my $Version   = '$Revision: 141 $';                                      (my $keyword,$Version,my $junque)                   = split(/ /,$Version);   $Version =~ s/\A\s+//;   $Version =~ s/\s+\z//;
        my $BuildDate = '$Date: 2014-05-06 14:00:55 -0400 (Tue, 06 May 2014) $'; ($keyword, $BuildDate, my $BuildTime, my $TZoffset) = split(/ /,$BuildDate); $BuildDate =~ s/\A\s+//; $BuildDate =~ s/\s+\z//;
#

require 5.14.0;
require Exporter;

BEGIN {
        use Exporter   ();

        @ISA        = qw(Exporter);
        @EXPORT     = qw(connection $dbh $SQL_Database $SQL_Schema
                         mkObject 
                         ckObject );
}


sub connection {

    my ($which_db) = @_;

    # -----------------------------------------------------------------
    # ----- (pointer in /etc/odbc.ini on Lamp & maybe BSD)
    if ($which_db eq 'Enigma') {

        our $SQL_Instance = '';          # ----- not really used for MySQL
        our $SQL_Engine   = 'mysql';
        our $SQL_Server   = 'celestia';  # ----- machine name of server
        our $SQL_User     = 'melick';
        our $SQL_Database = 'enigma';
        our $SQL_Schema   = '';          # ----- probably not really used for MySQL

    } elsif ($which_db eq 'MDsuite_DSICX') {

        our $SQL_Instance = 'BBSQL001\MDsuite';     # ----- (pointer in /etc/odbc.ini on Lamp & maybe BSD)
        our $SQL_Engine   = 'ODBC';
        our $SQL_Server   = 'DSICX';                # ----- ODBC Handle in both Debian & Windows
        our $SQL_User     = 'kpi';
        our $SQL_Database = 'DSICX';
        our $SQL_Schema   = 'dbo';

    }


    # -----------------------------------------------------------------
    # ----- pull the password from Davey Jone's Locker
    use Crypt::GCM;
    use Crypt::Rijndael;
    
    
    #my $user = 'kpi';
    
    my %PasswordStore = (
      'melick' => '72ce4a8dfbd4a4b9992ddeb9ab4ba25361f0e2c08d1b28c5b9fd2bbfe5eb23a4:54f572683621e41a54e267020be69e382a646f07:94a50ca730952e0482183d05:93be2ba1c245f589f0230c732f70b196:79d4cb0c3755074b',
      'root'   => 'de6dadc6574d563760825b21e424d24ca6e108c2784b7a6d631a40edcf2bd447:f127e4680e612e0ba2b8d920891f5e9f952a9d4e:c577e153140c6e36232cee4d:759250ea6d71b9987150cfe849d4a29e:eceeff1331744978b1305e',
    );
    my ($key, $aad, $iv, $tag, $ciphertext) = split(/\:/, $PasswordStore{$SQL_User});
    
    
    # ----- unpack the password
    my $gcm2 = Crypt::GCM->new(
        -key => pack('H*', $key),
        -cipher => 'Crypt::Rijndael',
    );
    $gcm2->set_iv(pack 'H*', $iv);
    $gcm2->aad(pack 'H*', $aad);
    $gcm2->tag(pack 'H*', $tag);
    my $plaintext = $gcm2->decrypt(pack 'H*', $ciphertext);
    our $SQL_Password = unpack 'H*', $plaintext;
    
    # ----- convert each two digit into char code
    $SQL_Password =~ s/([a-fA-F0-9][a-fA-F0-9])/chr(hex($1))/eg;



    # -----------------------------------------------------------------
    # ----- Connect to the database already!
    use DBI();
    if ($SQL_Engine eq 'ODBC') {
        our $dbh = DBI->connect("DBI:$SQL_Engine:$SQL_Server", "$SQL_User", "$SQL_Password", {PrintError => 0, RaiseError => 1, odbc_exec_direct => 1}) or die "Can't connect to database: $DBI::errstr\n"; #$dbh->trace(1);
        $dbh->do("SET ANSI_NULLS ON");
        $dbh->do("SET ANSI_WARNINGS ON");
    } elsif ($SQL_Engine eq 'mysql') {
        our $dbh = DBI->connect("DBI:$SQL_Engine:database=$SQL_Database;host=$SQL_Server", "$SQL_User", "$SQL_Password", {PrintError => 0, RaiseError => 1}) or die "Can't connect to database: $DBI::errstr\n"; #$dbh->trace(1);
    }
    #printf "[%s] [%s] [%s] [%s] [%s] [%s]\n", $SQL_Instance, $SQL_Server, $SQL_Database, $SQL_Schema, $SQL_User , $SQL_Password;
    

    my $use_stmt = join('', "USE ", $SQL_Database, ';');
    $dbh->do($use_stmt);
    $dbh;

}


# ----- create the object from pointers and a file passed in.
sub mkObject {


#    #my ($which_db, $SQL_Server, $SQL_Schema, $SQL_Database, $SQL_User, $SQL_Password, $object_type, $object) = @_;
#    my ($which_db, $object_type, $object, $inputfile) = @_;
#    #printf "I got w:%s, ot:%s, o:%s.\n", $which_db, $object_type, $object;
#    if ($object_type eq 'ROUTINE') { $drop_object = 'PROCEDURE' };

#    # ----- Let's git 'bizzy! ----- #
#    #use Melick::lib qw(connection);
#    my $dbh = &connection($which_db);
#    my $query = '';
#    my $return_value = 0;
#    if (substr($which_db,0,5) eq 'MySQL') {
#        # ----- this has not been tested.
#        $query = "DROP " . $object_type . " `" . $SQL_Database . "`.`" . $object . "'";
#    } elsif (substr($which_db,0,6) eq 'SQLsvr') {
#        if (($object_type eq 'VIEW') || ($object_type eq 'View') || ($object_type eq 'view')) {$object_type = 'TABLE'};
#        $query = "SELECT COUNT(*) AS numObjects FROM information_schema." . $object_type . "s WHERE " . $object_type . "_name = '" . $object . "'";
#    } else {
#        printf "[dbLib] Nope.  Not gonna.  ugitcher WhichDB right young man.\n";
#        exit;
#    }
#    my $sth = $dbh->prepare($query);
#    $sth->execute() or die "Can't execute SQL statement: $DBI::errstr\n";
#    while (my $ref = $sth->fetchrow_hashref()) {
#        $return_value = $ref->{'numObjects'};
#    }
#    $sth->finish();
#    warn "dbLib ERROR: view check in dbLib terminated early by error: $DBI::errstr\n" if $DBI::err;

    my $return_value = 0;
    return $return_value;
}


# ----- does the view exist?  If so, it should return a non-zero count from the information_scheam
sub ckObject {

    #my ($which_db, $SQL_Server, $SQL_Schema, $SQL_Database, $SQL_User, $SQL_Password, $object_type, $object) = @_;
    my ($which_db, $object_type, $object) = @_;
    #printf "I got w:%s, ot:%s, o:%s.\n", $which_db, $object_type, $object;
    
    # ----- Let's git 'bizzy! ----- #
    #use Melick::lib qw(connection);
    my $dbh = &connection($which_db);
    my $query = '';
    my $return_value = 0;
    if (substr($which_db,0,5) eq 'MySQL') {
        # ----- this has not been tested.
        $query = "SELECT COUNT(*) AS numObjects FROM information_schema." . $object_type . "s WHERE " . $object_type . "_name = '" . $object . "'";
    } elsif (substr($which_db,0,6) eq 'SQLsvr') {
        if (($object_type eq 'VIEW') || ($object_type eq 'View') || ($object_type eq 'view')) {$object_type = 'TABLE'};
        $query = "SELECT COUNT(*) AS numObjects FROM information_schema." . $object_type . "s WHERE " . $object_type . "_name = '" . $object . "'";
    } else {
        printf "[dbLib] Nope.  Not gonna.  ugitcher WhichDB right young man.\n";
        exit;
    }
    my $sth = $dbh->prepare($query);
    $sth->execute() or die "Can't execute SQL statement: $DBI::errstr\n";
    while (my $ref = $sth->fetchrow_hashref()) {
        $return_value = $ref->{'numObjects'};
    }
    $sth->finish();
    warn "dbLib ERROR: view check in dbLib terminated early by error: $DBI::errstr\n" if $DBI::err;

    return $return_value;

}


# ----- put your toys away little Johnny


# ----- HC SVNT DRACONES -----
=begin GHOSTCODE
=end GHOSTCODE
=cut
