use strict;
use warnings;
use ExtUtils::MakeMaker;


WriteMakefile(
    NAME                => 'Unzip::Passwd',
    AUTHOR              => q{Andre Carneiro <andregarciacarneiro@gmail.com>},
    VERSION_FROM        => 'lib/Unzip/Passwd.pm',
#    ABSTRACT_FROM       => 'lib/Unzip/Passwd.pm',
    ($ExtUtils::MakeMaker::VERSION ge 6.3002
      ? ('LICENSE'=> 'Artistic2')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Unzip-Passwd-*' },
);
