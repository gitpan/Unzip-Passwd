#!/usr/bin/perl 
#===============================================================================
#
#         FILE:  test.pl
#
#        USAGE:  ./test.pl  
#
#  DESCRIPTION:  
#
#      OPTIONS:  ---
# REQUIREMENTS:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  YOUR NAME (), 
#      COMPANY:  
#      VERSION:  1.0
#      CREATED:  31-08-2010 10:52:25
#     REVISION:  ---
#===============================================================================

use strict;
use warnings;
use lib '/home/andre/projetos/Unzip-Passwd/lib';
use Unzip::Passwd;


my $obj = Unzip::Passwd->new( 	filename 	=> 'test.zip' ,
								destiny	=> './tmp',
								passwd => '12345',
#								debug => 1,
							);
$obj->unzip;

