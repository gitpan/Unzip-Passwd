#!perl

use Test::More tests => 1;

BEGIN {
    use_ok( 'Unzip::Passwd' ) || print "Bail out!
";
}

diag( "Testing Unzip::Passwd $Unzip::Passwd::VERSION, Perl $], $^X" );
