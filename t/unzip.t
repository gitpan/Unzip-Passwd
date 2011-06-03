#!perl 

use strict;
use warnings;
use Test::More tests => 1;

	
#test unzip on linux
ok( check_unzip() == 1 , 'have_unzip' );
	

	

#<>UX TEST ONLY!!!
sub check_unzip {
	my $ok = 0;
	if($ok = `which unzip`){
           $ok = 1;
        }
        else {
           print STDERR "\n\nOOOPS! unzip executable not found!\n\n";
        }
	return $ok;
}


