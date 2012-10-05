#!/usr/bin/perl 

use Modern::Perl    '2012';
use Data::Dump      'ddx';
use HTML::TreeBuilder;
use DBI;

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

ddx(\%countries);

say "Reading countries from the database";

my $dbh = DBI->connect('dbi:Pg:dbname=paranoia', '', '');

my $list = $dbh->selectall_arrayref('SELECT id,name FROM countries');

my %names;
my %idtocountry;
# Build the list of names based on real country names
for my $country (@$list) {
	my ($id, $name)     = @$country;
	$idtocountry{$id}   = $name;

	my @candidates  = grep {$_ =~ /$name/i} keys %countries;

	$names{$id}   //= [];
	map {push(@{$names{$id}}, @{$countries{$_}})} @candidates;

	if (scalar @{$names{$id}} == 0) {
		delete $names{$id};
	}
}

# Insert the names into the database
for my $country (keys %names) {
	say "Inserting names into " . $idtocountry{$country};
	for my $name (@{$names{$country}}) {
		my $sth = $dbh->prepare("INSERT INTO first_names (country, name) VALUES (?, ?)");
		$sth->execute($country, $name);
		$sth->finish;
	}
}

say "Insert done";
$dbh->disconnect;

