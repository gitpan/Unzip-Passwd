package Unzip::Passwd;
use Moose;

has filename 	=> (is => 'rw'); #nome do arquivo zip
has passwd		=> (is => 'rw'); #senha
has destiny		=> (is => 'rw'); #caminho para o destino do arquivo
has errors		=> (is => 'rw'); #atributo que guarda os erros.
has debug		=> (is => 'rw' , default => 0); #atributo que guarda os erros.

=head1 NAME

 Unzip::Passwd - Unzip files with password.

=head1 DESCRIPTION

 Extreamly simple Unzip abstraction using the unzip program( MUST BE INSTALLED )
 
 WARNING: This is a pre-Alpha module.

=head1 VERSION

Version 0.0.8

=cut

our $VERSION = '0.0.8';


=head1 SYNOPSIS

 #Instance
 my $obj = Unzip::Passwd->new( filename => 'myfile.zip',
 								destiny => 'some/path/to/file/unziped',
								passwd => 'somebetterpassword',
							);
 #unzip ...
 $obj->unzip;

 #done!


=head2 METHOD


=head2 unzip

 Do the job, basicly. But first invokes the analyze method, to have certain the zip file is fine. 
 No parameters, just return 1 if it's all ok. Otherwise, will return 0 and trhow an exception.



=cut

sub unzip {
	my ( $self ) 	= @_;
	my @errors 		= ();
	if( !$self->filename ){
		push @errors, 'You must enter with a zip file name.';
	}
	elsif(! -e $self->filename ){
		push @errors, 'O arquivo "' . $self->filename . '" não existe!';
	}
	my @c = readpipe 'unzip -l ' . $self->filename;
	my @files = ();
	foreach(@c) {
			if( $_ =~ /\d+.+?\d+-\d+-\d+ \d\d:\d\d(\ |\t)+(.+?)$/ ){
				push @files, $2  
			}
	}
	print "\nFILES: \n";

	#preparando arquivos para descompactar. Evitando mensagens de confirmação...
	if(@files > 0){
		$self->analyze(\@files);
	}
	elsif(-e $self->filename and @files == 0){
		push @errors, 'the zip file "' . $self->filename . '" is empty!';
	}
	else {
		push @errors, 'The file "' . $self->filename . '" not exists!';
	}
	print "\n";
	
	if( @errors > 0 ){
		foreach my $e( @errors ) {
			print "\nERROR: $e";
		}
		$self->errors(\@errors);
		return 0;
	}
	else{
		return $self->exec_unzip;
	}
}


=head2 show_errors

 Makes the obvious. Just show errors. Don't receives anything. Returns the error messages( arrayref ).

=cut

sub show_errors {
	my ( $self ) = @_;
	my $m = '';
	my @errors = @{$self->errors};
	if(ref($self->errors) =~ /ARRAY/){
		foreach my $e(@{$self->errors}){
			push @errors, $e;
		}
	}
	else{
		print "\nNo errors! :D\n";
		@errors = ();
	}
	if(@errors){
		my @objerrors = $self->errors;
		push @objerrors , @errors;
		$self->errors(\@errors);
	}
	return \@errors;
}


=head2 analyze

 Analyze possible file and directory problems( permissions non-existing directories etc ). return 1 if 
 all it's ok! Otherwise return 0. Receives the files list( arrayref ) as parameter.

=cut

sub analyze {
	my ( $self , $files ) = @_;
	my $ok = 0;
	my @errors = ();
	foreach(@{$files}) { 	
		my $file = $_;
		my $dirfile = undef;
		print "\n" . $file;
		if ( defined($self->destiny) and length($self->destiny) > 0 ) {
			$dirfile = $self->destiny . '/' . $file ;
		}
		else{
			$self->destiny( undef );
		}
		if(-e $file && !defined($self->destiny) ){
			print "\nDELETING $file (already exists)";
			eval{$ok = unlink $file};
			if($@){
				push @errors, $@;
			}
			else{
				print "\nOK!";
				$ok = 1;
			}
		}
		elsif(!-e $file && !defined($self->destiny)){
			print "\nERROR: The file or directory '$file' not exists!";
			push @errors , "ERROR: O arquivo ou diretório $file não existe!" ;
		}
		elsif(defined($self->destiny) && length($self->destiny) > 0 ) {
			print "\nDELETING $dirfile (already exists)";
			eval{unlink $dirfile;};
			if($@){
				push @errors, $@;
			}
			else{
				print "\nOK!";
				$ok = 1;
			}
		}
	}

	#This is weard... I don't know how to get better... :p
	if(@errors > 0){
		my @objerrors = @{$self->errors};
		push @objerrors , @errors;
		$self->errors( \@objerrors );
	}
	return $ok;
}


#This is who really do the job... Takes the options and agreggate to command before execute.
sub exec_unzip {
	my ( $self ) = @_;
	#the command obviously starts with unzip...
	my $comm  =  'unzip';
	my @errors = ();
	my @commands = ();

	#if the password is defined and have some password... -P is added
	if(defined($self->passwd) and length($self->passwd) > 0){
		$comm .= ' -P ' . $self->passwd . ' ';
	}
	elsif(!defined($self->passwd) || length($self->passwd) == 0){
		#that's ok!
		$comm  =  'unzip ' . $self->filename;
	}

	#same thing to destination folder
	if(defined($self->destiny) and length($self->destiny) > 0){
		$comm .= ' -d ' . $self->destiny;
	}
	else {
		push @errors,'The size MUST be bigger than 0';
	}

	my $target = $self->filename;
	if($comm !~ /$target/){
		$comm .= " $target";
		@commands = readpipe $comm;
	}
	else {
		@commands = readpipe $comm;
	}

#	print "\nCOMM: $comm";
	map { 
		push @errors , $_ if $_ =~ /error/i;
	}@commands;
	if(!@errors){
		return 1;
	}
	else {
		$self->errors(\@errors);
		return 0;
	}
}



=head2 AUTHOR

Andre Carneiro, C<< <andregarciacarneiro at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-unzip-passwd at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Unzip-Passwd>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

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

 Create tests... :(

=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2010 Andre Carneiro.

This program is released under the following license: Artistic2


=cut

1; # End of Unzip::Passwd
