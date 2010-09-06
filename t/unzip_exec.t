#!perl 

use strict;
use warnings;
use Test::More tests => 2;

#instancing with all stuff
#
use Unzip::Passwd;
my $obj = Unzip::Passwd->new ( filename => 'test' ,
						 destiny => './tmp' ,
						 passwd => '12345' ,
						);

	
#exec unzip_exec. Is 'naked' yet...
ok( $obj->exec_unzip == 1 , 'unzip_exec_test' );


#exec unzip_exec without filename
$obj->filename(undef);
ok( $obj->exec_unzip == 0 , 'unzip_exec_fail1_test' );

