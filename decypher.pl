use strict;
use warnings;

use Crypt::GCM;
use Crypt::Rijndael;


my $user = 'SSG\HCSAdmin';

my %PasswordStore = (
  'kpi'  => '4bc8c94d52f92fbf111b98f5a77652db81d941a07344cffeb19199d684d79435:960a77fdddba0bf108838a741dd609575a0e2adb:14c23b93de9e59e3ef68638f:2099bca1fd011e24c29e32a904c01059:9f16ff8cdd5f2b',
  'melick' => 'ce921d4a2048f401c238278c2fa038ddd031ecd5ec3814d5df835db0bb9c7be5:1d9ac900ded0660ca8612a5f405fb33b1c427b9c:58259ce79c24d6494be30491:f766171058001682bef25e32774fca5a:662785c23cae294dc22123f7ef6d5595',
  'root' => '466b016bfa6d13bfcc48e8b70c561c31a7aa027a7e0927293b83210c84f167e1:059bd3a983a071377e583a1bfda712f788152071:ad34ed54eb63f31c6d3913da:1ec2a0f6c0be75ebb8ed3e60da1a937d:d737ae08320abda07f8d04e910af42a4',
  'test' => '805beda56de875c9ca6fe4482ebde5f8c79424de4a6fc71583acd7d37e7c12ac:5b726ba951bbc6f3143fde882208dc86be60cf9a:18b639ee63b767d8a6739cc1:7e08c0ffa8bb040a63d2db44f22d816d:5038f13ed4d8d03a6f5fa57911a3d7fb45827595e63e84dc06bdee4c9d6955',
  'SSG\HCSAdmin' => '359acfca4dd69eca8ca1381e4544331dda8fdd57f54f1cc17e62d57cd17065ab:03fe356926991b32dc6289692580e13d53c7e958:7e1ccbdbcf6526194cf2fca5:3293b598abaeb7aede5632e2df920ac2:396a4f8d701fc1ab',
);
my ($key, $aad, $iv, $tag, $ciphertext) = split(/\:/, $PasswordStore{$user});


# ----- unpack the password
my $gcm2 = Crypt::GCM->new(
    -key => pack('H*', $key),
    -cipher => 'Crypt::Rijndael',
);
$gcm2->set_iv(pack 'H*', $iv);
$gcm2->aad(pack 'H*', $aad);
$gcm2->tag(pack 'H*', $tag);
my $plaintext = $gcm2->decrypt(pack 'H*', $ciphertext);
my $password = unpack 'H*', $plaintext;

# ----- convert each two digit into char code
$password =~ s/([a-fA-F0-9][a-fA-F0-9])/chr(hex($1))/eg;
printf "[%s]\n", $password;

# ----- HC SVNT DRACONES -----
=begin GHOSTCODE
=end GHOSTCODE
=cut
