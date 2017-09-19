use strict;
use warnings;

use Crypt::GCM;
use Crypt::Rijndael;

use Bytes::Random::Secure qw( random_bytes_hex );
my $random_bytes_hex = Bytes::Random::Secure->new(
    Bits        => 64,
    NonBlocking => 1,
); # Seed with 64 bits, and use /dev/urandom (or other non-blocking).


# ----- message to be 'delivered'
my $message = "6c6d6c6240353567";
my $user = 'SSG\HCSAdmin';
print "my %PasswordStore = (\n";

# ----- encryption parameters
my $key = random_bytes_hex(32); # 256 bit;
my $aad = random_bytes_hex(20); # 160 bit; 
my $iv = random_bytes_hex(12);  # 96 bit - for compatibility & efficiency;  
# ----- output of encryption pass.
my $tag = '';
my $ciphertext = '';

# ----- use this to generate tag & ciphertext
my $gcm = Crypt::GCM->new(
    -key => pack('H*', $key),
    -cipher => 'Crypt::Rijndael',
);
$gcm->set_iv(pack 'H*', $iv);
$gcm->aad(pack 'H*', $aad);
$ciphertext = unpack 'H*', $gcm->encrypt(pack 'H*', $message);
$tag = unpack 'H*', $gcm->tag();


# ----- print out all this lovely stuff
my $sec_blob = join(':', $key, $aad, $iv, $tag, $ciphertext); 
printf "  '%s' => '%s',\n", $user, $sec_blob;
print ");\n";
print "my (\$key, \$aad, \$iv, \$tag, \$ciphertext) = split(/\\:/, \$PasswordStore{\$user});\n";


# ----- HC SVNT DRACONES -----
=begin GHOSTCODE
=end GHOSTCODE
=cut

