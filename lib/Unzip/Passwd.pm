package Unzip::Passwd;
use strict;
use warnings;
use Data::Dumper;

=head1 NAME

 Unzip::Passwd - Unzip files with password.

=head1 DESCRIPTION

Extreamly simple Unzip abstraction using the unzip program( MUST BE INSTALLED )
 
WARNING: This is Alpha version.

=head1 VERSION

Version 0.0.15

=cut

our $VERSION = '0.0.15';

=head1 SYNOPSIS

 #Instance
 my $obj = Unzip::Passwd->new( filename => 'myfile.zip',
 					destiny => 'some/path/to/file/unziped',
					passwd => 'somebetterpassword',
							);
 #unzip ...
 $obj->unzip;

 #done!



=head1 METHODS


=head2 new

This is the constructor

=cut

sub new {
    my ( $class, %parameters ) = @_;
    my $self = undef;
    foreach my $k ( ( keys %parameters ) ) {
        if ( $k =~ /^filename|passwd|destiny|errors|debug$/ ) {
			if(defined($parameters{$k})){
	            $self->{$k} = $parameters{$k};
	        }
        }
        else {
            print "\nFATAL ERROR! Wrong attribute - '$k'. RTFM my friend! \n";
            exit 0;
        }
    }
    bless( $self, $class );
    return $self;
}

=head2 unzip

Do the job, basicly. But first invokes the analyze method, to have certain the zip file is fine.
If analyze returns 1, then unzip will try to open the zip file.
No parameters, will return 1 if it's all ok. Otherwise, will return 0 and throw an exception.

=cut

sub unzip {
    my ($self) = @_;
    my @errors = ();
    $self->errors(undef);
    my $ok = 0;
    if ( !defined( $self->filename ) || !$self->filename ) {
        push @errors, "You must define the 'filename' correctly!.";
        $self->errors( \@errors );
    }
    else {
        my @files = @{ $self->list_files };
        if ( @files > 0 ) {

#prepare files and directories(if exists) to extract. This avoids confirmation messages too.
            if ( @errors == 0 && @files > 0 && $self->analyze( \@files ) ) {
                $self->exec_unzip;
            }
            else {
                $ok = 0;
            }
            print "\n";
        }
        else {
            push @errors, 'the zip file list returns empty!';
            $ok = 0;
        }
    }

    if ( ref( $self->errors ) =~ /ARRAY/ ) {
        push @{ $self->errors }, @errors;
        $self->show_errors;
		$ok = 0;
    }
    else {
        $ok = 1;
    }

    return $ok;
}

=head2 list_files

This try to obtain a list of files from zipfile in $self->filename. If succeded, returns an arrayref with the filelist. Otherwise returns 
an arrayref empty. 

=cut

sub list_files {
    my ($self) = @_;
    my @files  = ();
    my @errors = ();
    if ( -e $self->filename ) {
        my @c = readpipe 'unzip -l ' . $self->filename;
        @files = ();
        foreach (@c) {

            #extracting just the filename. It's all the matters.
            if ( $_ =~ /\d+.+?\d+-\d+-\d+ \d\d:\d\d(\ |\t)+(.+?)$/ ) {
                push @files, $2;
            }
        }
    }
    else {
        push @errors,
            "The file '"
          . $self->filename
          . "', defined in filename attribute doesn't exists!";

    }
    my @olderrors = ();
    if ( @errors > 0 ) {
        if ( ref( $self->errors ) =~ /ARRAY/ ) {
            push @olderrors, @{ $self->errors };
            push @olderrors, @errors;
            $self->errors( \@olderrors );
        }
        else {
            $self->errors( \@errors );
        }
    }
    return \@files;
}

=head2 analyze

Analyzes possible file and directory problems( permissions and non-existing directories etc ). Returns 1 if 
all it's ok! Otherwise returns 0. Receives the files list( arrayref ) as parameter.

=cut

sub analyze {
    my ( $self, $files ) = @_;
    my $ok     = 0;
    my @errors = ();
    foreach ( @{$files} ) {
        my $file    = $_;
        my $dirfile = undef;
        print "\n" . $file;
        if ( defined( $self->destiny ) and length( $self->destiny ) > 0 ) {
            $dirfile = $self->destiny . '/' . $file;
        }
        else {
            $self->destiny('./');
        }
        $file = $self->destiny . '/' . $file;
        if ( -d $self->destiny ) {
            if ( -e $file ) {
                print "\nOVERWRITING $file (already exists)";
                eval { $ok = unlink $file; };
                if ($@) {
                    push @errors, $@;
                    $ok = 0;
                }
                else {
                    print "\nOK!";
                    $ok = 1;
                }
            }
            else {
                $ok = 1;
            }
        }
        else {
            push @errors,
                "The destination directory doesn't exists '"
              . $self->destiny . "'";
            $ok = 0;
        }
    }

    #This is weard... I really need to do this better... :(
    my @olderrors = ();
    if ( @errors > 0 ) {
        if ( ref( $self->errors ) =~ /ARRAY/ ) {
            push @olderrors, @{ $self->errors };
            push @olderrors, @errors;
            $self->errors( \@olderrors );
        }
        else {
            $self->errors( \@errors );
        }
    }
    else {
        $ok = 1;
    }
    return $ok;
}

# Internal method.
# This is who really do the job... Takes the options and agreggate to command before execute.
# Returns 1 if all is right. Otherwise returns 0.

=head2 exec_unzip

This is a internal method. You should exec unzip method. Never exec this method directly.

=cut

sub exec_unzip {
    my ($self) = @_;

    #the command obviously starts with unzip...
    my $comm     = 'unzip';
    my @errors   = ();
    my @commands = ();
    my $ok       = 0;

#LAST CHECK. This is necessary for stupid someone decides run exec_unzip directly!
    if ( $self->filename ) {

#THIS PART AGREGATE OPTIONS FROM CONFIG( see the constructor method ), BEFORE EXECUTE.

    #if the password is defined and have some password... -P is added to command
        if ( defined( $self->passwd ) && length( $self->passwd ) > 0 ) {
            $comm .= ' -u -P ' . $self->passwd . ' ';
        }
        elsif ( !defined( $self->passwd ) || length( $self->passwd ) == 0 ) {

            #that's ok!
            $comm = 'unzip -u ' . $self->filename;    #default
        }

        #same thing for destination folder
        if ( defined( $self->destiny ) && length( $self->destiny ) > 0 && -d $self->destiny ) {
            $comm .= ' -d ' . $self->destiny;
        }
        else {
            push @errors, "The destiny of zip content CAN'T be undefined or invalid!";
        }
        my $target = $self->filename;

        #FINALY!!! EXECUTE THIS CRAP!!!
        if ( $comm !~ /$target/ ) {
            $comm .= " $target";
            eval{@commands = readpipe $comm;};
			if($@){
				push @errors,"ERROR: $@";
			}
        }
        else {
            eval{@commands = readpipe $comm;};
			if($@){
				push @errors,"ERROR: $@";
			}
        }

#        map { push @errors, $_ if $_ =~ /error|doesn't exists|not exists/i; } @commands;
        if ( !@errors ) {
            $ok = 1;
        }
        else {
            $self->errors( \@errors );
			$ok = 0;
        }
    }
    else {
        push @errors, "You MUST define a filename correctly!";
        $self->errors( \@errors );
        $ok = 0;
    }

    return $ok;
}

=head2 show_errors

Makes the obvious. Show errors. Don't receives anything. Returns the error messages( arrayref ).

=cut

sub show_errors {
    my ($self) = @_;
    my $m      = '';
    my @errors = ();
    if ( ref( $self->errors ) =~ /ARRAY/ ) {
        @errors = @{ $self->errors };
        foreach my $e (@errors) {
            print STDERR "\nERROR: $e";
        }
    }
    else {
        print STDERR "\nNo errors! :D\n";
        @errors = ();
    }
    return \@errors;
}

=head1 ACCESSORS


=head2 filename 

Name/Path of file that will be 'unziped'


=head2 passwd

string with the password


=head2 destiny

filepath to extract file


=head2 errors

stack(array) of errors


=cut

sub filename {
    my $self = shift;
	if(@_){
		$self->{filename} = shift;
	}
    return $self->{filename};
}

sub passwd {
    my $self = shift;
	if(@_){
		$self->{passwd} = shift;
	}
    return $self->{passwd};
}

sub destiny {
    my $self = shift;
	if(@_){
		$self->{destiny} = shift;
	}
    return $self->{destiny};
}

sub errors {
    my $self = shift;
	if(@_){
		$self->{errors} = shift;
	}
    return $self->{errors};
}

=head1 DEPENDECIES

unzip program MUST be installed!

=head1 AUTHOR

Andre Carneiro, C<< <andregarciacarneiro at gmail.com> >>


=head1 NOTES FOR THIS VERSION


More tests implement.

Moose implementation was removed because Moose have so much dependencies that aggregates unnecessary complexity to this
very simple module( keep shit simple ).

=head1 BUGS


Please report any bugs or feature requests to C<bug-unzip-passwd at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Unzip-Passwd>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.


=head1 SUPPORT

This module was tested JUST ON LINUX. DON'T HAVE SUPPORT IN WINDOWS YET. MAYBE LATER...

You can find documentation for this module with the perldoc command.

   perldoc Unzip::Passwd


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Unzip-Passwd>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Unzip-Passwd>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Unzip-Passwd>

=item * Search CPAN

L<http://search.cpan.org/dist/Unzip-Passwd/>

=back

=head1 TODO

All other features from unzip ( Linux version ). :D

Aggregates some log module.

Finish the tests... :(

Create a better way to treat exceptions...

=head1 ACKNOWLEDGEMENTS

Luis Campos de Carvalho(Champs) - for inspiration.

=head1 LICENSE AND COPYRIGHT

Copyright 2010 Andre Carneiro.

This program is released under the following license: Artistic2


=cut

1;    # End of Unzip::Passwd
