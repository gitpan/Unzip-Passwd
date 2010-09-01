package Unzip::Passwd;
use Moose;

has filename 	=> (is => 'rw'); #nome do arquivo zip
has passwd		=> (is => 'rw'); #senha
has destiny		=> (is => 'rw'); #caminho para o destino do arquivo
has errors		=> (is => 'rw'); #atributo que guarda os erros.
has debug		=> (is => 'rw' , default => 0); #atributo que guarda os erros.

=head1 NAME

Unzip::Passwd

=head DESCRIPTION

 Classe para descompactar arquivos zip que tenham senha.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.0.4';


=head1 SYNOPSIS

 #Instanciando
 my $obj = Unzip::Passwd->new( filename => 'myfile.zip',
 								destiny => 'some/path/to/file/unziped',
								passwd => 'somebetterpassword',
							);
 #descompactando...
 $obj->unzip;



=head2 METHOD

=cut

sub unzip {

	my ( $self ) 	= @_;
	my @errors 		= ();
	my @commands	= ();
	if( !$self->filename ){
		push @errors, 'É preciso entrar com um nome de arquivo no formato zip';
	}
	elsif(! -e $self->filename ){
		push @errors, 'O arquivo "' . $self->filename . '" não existe!';
	}
	my @c = readpipe 'unzip -l ' . $self->filename;
	my @files = ();
	map {push @files, $2 if $_ =~ /\d+.+?\d+-\d+-\d+ \d\d:\d\d(\ |\t)+(.+?)$/ }@c;
	print "\nFILES: \n";
	#preparando arquivos para descompactar. Evitando mensagens de confirmação...
	if(@files > 0){
		map { 	my $file = $_;
				print "\n" . $file;
				my $dirfile = $self->destiny . '/' . $file if defined($self->destiny) and length($self->destiny) > 0;
				if(-e $file and !defined($self->destiny) ){
					print "\nDELETING $file (already exists)";
					eval{unlink $file};
					if($@){
						push @errors, $@;
					}
					else{
						print "\nOK!";
					}
				}
				elsif(!-e $file and !defined($self->destiny)){
					print "\nERROR: O arquivo ou diretório $file não existe!";
				}
				elsif(defined($self->destiny) and length($self->destiny) > 0 and -e $dirfile ) {
					print "\nDELETING $dirfile (already exists)";
					eval{unlink $dirfile;};
					if($@){
						push @errors, $@;
					}
					else{
						print "\nOK!";
					}
				}

		}@files;
	}
	elsif(-e $self->filename and @files == 0){
		push @errors, 'O arquivo zip "' . $self->filename . '" está vazio!';
	}
	else {
		push @errors, 'O arquivo "' . $self->filename . '" não existe!';
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
		my $comm  =  'unzip';
		if(defined($self->passwd) and length($self->passwd) > 0){
			$comm .= ' -P ' . $self->passwd . ' ';
		}
		elsif(!defined($self->passwd) || length($self->passwd) == 0){
			#that's ok!
			$comm  =  'unzip ' . $self->filename;
		}
#print "\nSELF_DESTINY: " . $self->destiny;
		if(defined($self->destiny) and length($self->destiny) > 0){
			$comm .= ' -d ' . $self->destiny;
		}
		elsif(!defined($self->destiny) || length($self->destiny) == 0){
			#that's ok!
		}
		else {
			push @errors,'O tamanho do nome do arquivo de destino deve ser maior que 0';
		}

		my $target = $self->filename;
		if($comm !~ /$target/){
			$comm .= " $target";
			@commands = readpipe $comm;
		}
		else {
			@commands = readpipe $comm;
		}

#		print "\nCOMM: $comm";
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
}


=head2 show_errors

 Mostra os erros armazenados em $self->errors.

=cut

sub show_errors {
	my ( $self ) = @_;
	if(ref($self->errors) =~ /ARRAY/){
		foreach my $e(@{$self->errors}){
			print "\ne";
		}
	}
	else{
		print "\nNo errors! :D\n";
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


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2010 Andre Carneiro.

This program is released under the following license: Artistic2


=cut

1; # End of Unzip::Passwd
