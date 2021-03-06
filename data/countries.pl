#!/usr/bin/perl 

use Modern::Perl    '2012';
use Data::Dump      'ddx';
use HTML::TreeBuilder;
use DBI;

my %countries;
my $root    = HTML::TreeBuilder->new_from_url('http://en.wikipedia.org/wiki/List_of_countries_by_population');

my @tables  = $root->look_down(
	_tag    => 'table',
	class   => 'wikitable sortable',
);

for my $table (@tables) {
	my @rows    = $table->look_down(
		_tag    => 'tr',
		style   => undef,
	);

	for my $row (@rows) {
		# Name of the country first, the rest are names
		my $columns     = $row->content;
		my $country     = $columns->[1]->as_text;
		$country        =~ s/\s*[\(\[].*//;
		$country        =~ s/^\W+//;
		my $population  = $columns->[2]->as_text;
		$population     =~ s/[,\s]//g;
		
		next unless ($population > 4500000);

		$countries{$country}    = $population;
	}
}

ddx(\%countries);

# Write the countries to the database
my $dbh = DBI->connect('dbi:Pg:dbname=paranoia', '', '');

for my $country (keys %countries) {
	say "Inserting country $country";
	my $sth = $dbh->prepare("INSERT INTO countries (name, population) VALUES (?, ?)");
	$sth->execute($country, $countries{$country}) || warn "Failed to insert country $country: $@";
	$sth->finish;
}

$dbh->disconnect;
say "Inserts done";
