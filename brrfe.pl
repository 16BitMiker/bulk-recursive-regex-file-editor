#!/usr/bin/env perl

use Term::ANSIColor qw|:constants|;

die q|> |, RED qq|need a .json config!|, RESET, qq|\n|
unless (@ARGV and -f $ARGV[0] and $ARGV[0] =~ m`\.json$`);

my $dir = $ARGV[0];
my $go = IITS::Clone::Cleaner->load($dir);
$go->go;

package IITS::Clone::Cleaner
{
	use Term::ANSIColor qw|:constants|;
	use JSON::MaybeXS;
	use Data::Dump      qw|dump|;
	use feature         qw|say|;

	sub load()
	{
		my $class = shift;
		chomp (my $file   = shift);
		
		$file =~ s`/\Z``;
		
		say q|> loading: |, UNDERLINE GREEN $file, RESET;
		
		open my $fh, qq|<|, $file or die RED qq|can't open json!\n|, RESET;
		
		chomp (my $decoded_json = join m``, <$fh>);
		
		say q|> |, BLUE $decoded_json, RESET;
		
		printf qq|> %s%s|, YELLOW q|want to continue? (y/n): |, RESET;
		chomp (my $choice = <STDIN>);
		
		if ($choice =~ m`y`i)
		{
			say q|> |, GREEN q|proceeding...|, RESET;
		}
		elsif ($choice =~ m`n`i)
		{
			die q|> |, RED qq|quitting!|, RESET, qq|\n|;
		}
		else 
		{
			die q|> |, RED qq|invalid choice so quitting anyway!|, RESET, qq|\n|;
		}
		
		my $json = decode_json($decoded_json);
		
		return bless {json => $json, dir => $dir}, $class;
	}
	
	sub go()
	{
		my $self = shift;
		$$self{files} = $self->_scan_all_files();
		$self->_apply_fixes();
	}
	
	sub _scan_all_files()
	{
		my $self = shift;
		my @files;
		my @folders = ($$self{json}[0]{dir});	
		
		LOOPY:
		{
			my $folder = shift @folders;
						
			while (glob(qq|${folder}/*|))
			{
				push @files,   $_ if -f $_;
				push @folders, $_ if -d $_;
			}
				
			goto LOOPY if @folders;
		}
		
		return [ @files ];
	}
	
	sub _apply_fixes()
	{
		my $self = shift;
		
		my $n = 0;
		FILE: for my $file(values @{$$self{files}})
		{
			for my $regex (sort values @{$$self{json}})
			{
				next if $file =~ m`$0`;
				next FILE unless $file =~ m~$$regex{filetype}~;
				
				open my $fh, q|+<|, $file 
				or die RED qq|can't open file so quitting!\n|, RESET;
				
				my $content = (join q||, <$fh>) =~ s`\n` `gr;
				$content =~ s`\t{2,}|\s{2,}` `g;
				
				my $edits = $content =~ s`$$regex{find}`$$regex{replace}`ge;
				
				say q|~|x45;
				say q|> |, q|now editing |, UNDERLINE GREEN $file =~ s`^.*/``gr, RESET;
				say q|> |, q|label: |, BLUE UNDERLINE $$regex{label}, RESET;
				say q|> |, q|finding: |, YELLOW UNDERLINE $$regex{find}, RESET;
				say q|> |, q|replacing: |, YELLOW UNDERLINE $$regex{replace}, RESET;
				say q|> |, q|edits: |, YELLOW UNDERLINE $edits, RESET;
				
				seek $fh, 0, 0;
				truncate $fh, 0;
				
				say $fh $content;
				close $fh;
			}
		}
		
		
	}
}

__END__
