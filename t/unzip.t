#!perl 

use strict;
use warnings;
use Test::More tests => 1;

	
#test unzip on linux
ok( check_unzip() == 1 , 'have_unzip' );
	

	

#LINUX ONLY!!!
sub check_unzip {
	my @check = `unzip -v`;
	if($check[0] =~ /UnZip/i){
		return 1;
	}
	else {
		print STDERR "\t###### YOU MUST have unzip installed!! RTFM my friend...######";
		return 0;
	}
}


