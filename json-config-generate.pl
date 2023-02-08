#!/usr/bin/env perl

my $json = Create::JSON->load();
$json->_create_json();

package Create::JSON
{
	use JSON::MaybeXS;
	use feature qw|say|;
	use Term::ANSIColor qw|:constants|;
	
	sub load()
	{
		my $class = shift;
		return bless {}, $class;
	}
	
	sub _create_json()
	{
		my $self = shift;
		my $db   = [];
		my $json = {};
		my $json_file = q|find-replace-|.time().q|.json|;
		
		printf qq|> %s %s%s\n|, q|fill in the info below, it will be saved to:|, UNDERLINE GREEN $json_file, RESET;
		
		my $default_file_type = q~\.html$~;
		
		my $dir_remember;
		
		my $n = 0;
		ADD:
		{
			printf qq|> %s%s: |, YELLOW q|label|, RESET;
			chomp ($$db[$n]{label} = <STDIN>);
			
			if ($dir_remember and -e $dir_remember)
			{
				printf qq|> %s%s%s\n|, YELLOW qq|using directory: |, UNDERLINE $dir_remember, RESET;
				$$db[$n]{dir} = $dir_remember;
			}
			else 
			{
				printf qq|> %s%s: |, YELLOW q|directory|, RESET;
				chomp ($$db[$n]{dir} = <STDIN>);
			}
			
			unless (-d $$db[$n]{dir})
			{
				printf qq|> %s%s\n|, RED q|directory dosn't exist so resetting!|, RESET; 
				goto ADD;
			}
			
			$$db[$n]{dir} =~ s`/\Z``;
			$dir_remember = $$db[$n]{dir};
			
			printf qq|> %s%s%s: |, YELLOW qq|regex to filter file type, default = |, UNDERLINE $default_file_type, RESET;
			chomp (my $regex_filetype = <STDIN>);
			
			$$db[$n]{filetype} = $user =~ m`^$` ? $default_file_type : $regex_filetype;
			
			printf qq|> %s%s: |, YELLOW q|find|, RESET;
			chomp ($$db[$n]{find} = <STDIN>);
			
			printf qq|> %s%s: |, YELLOW q|replace|, RESET;
			chomp ($$db[$n]{replace} = <STDIN>);
		}
	
		$json = encode_json($db);
		printf qq|> saving to: %s%s%s\n|, UNDERLINE GREEN $json_file, RESET qq|\n> |, $json;
		printf q|> %s%s: |, GREEN q|(w)rite / (r)edo / (a)dd / (q)uit|, RESET;
		my $final_choice = <STDIN>;
		
		if ($final_choice =~ m~^w(?:rite)?$~i)
		{
			open my $fh, q|>|, $json_file or RED die qq|> can't open file so quitting!\n|, RESET;
			say $fh $json;
			close $fh;
			
			printf qq|> %s%s\n|, GREEN q|saved!|, RESET;
			exit 69;
			
		}
		elsif ($final_choice =~ m~^q(?:uit)?$~i)
		{
			printf qq|> %s%s\n|, RED q|quitting! (nothing saved)|, RESET;
			exit 69;
		}
		elsif ($final_choice =~ m~^r(?:edo)?$~i)
		{
			goto ADD;
		} 
		elsif ($final_choice =~ m~^a(?:dd)?$~i)
		{
			$n++;
			goto ADD;
		} 
		else 
		{
			printf qq|> %s%s\n|, GREEN q|you didn't choose so redoing |, RESET;
			goto ADD;
		}
	}
	
}