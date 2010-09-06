#!perl 

use strict;
use warnings;
use Test::More tests => 3;
use Data::Dumper;
#instancing with all stuff
#
use Unzip::Passwd;
my $obj = Unzip::Passwd->new ( filename => '' ,
						 destiny => './tmp' ,
						 passwd => '12345' ,
						);


#first if elsif else - file and destination exists...
$obj->filename('test.zip');
$obj->destiny('./tmp');
ok( $obj->unzip == 1 , 'filename_and_destination' );


	
#first if elsif else - file is not defined...
$obj->filename(undef);
ok( $obj->unzip == 0 , 'file_not_defined' );



#first if elsif else - file exists, but the destination don't...
$obj->filename('test.zip');
$obj->destiny(undef);
ok( $obj->unzip == 1 , 'without_destination' );






