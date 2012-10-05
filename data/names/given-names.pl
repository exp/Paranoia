#!/usr/bin/perl 

use Modern::Perl    '2012';
use Data::Dump      'ddx';
use HTML::TreeBuilder;

my %countries;
my $root    = HTML::TreeBuilder->new_from_url('http://en.wikipedia.org/wiki/List_of_most_popular_given_names');

my @tables  = $root->look_down(
	_tag    => 'table',
	class   => 'wikitable',
);

say "Got $#tables innit";

for my $table (@tables) {
	my @rows    = $table->look_down(
		_tag    => 'tr',
		style   => undef,
	);

	for my $row (@rows) {
		# Name of the country first, the rest are names
		my $columns = $row->content;
		my $country = shift(@$columns)->as_text;
		$country    =~ s/^([\w, ]+)\s+.*$/$1/;

		my @names   = grep {$_ ne "NA"} map {split(/\s*[,\/]\s*/)} map {$_->as_text} @$columns;

		$countries{$country}    //= [];
		push (@{$countries{$country}}, @names);
	}
}

ddx(%countries);
