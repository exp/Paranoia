#!/usr/bin/perl 

use Modern::Perl    '2012';
use POSIX           qw/ceil/;
use Image::Magick;
use Math::Vector::Real;

sub rn {
	my $start   = shift;
	my $end     = shift;

	my $rand    = rand($end-$start);
	$rand       += $start;

	return $rand;
}

sub vec_format {
	my $vector  = shift;
	my $scale   = shift;

	my $x   = $vector->[0];
	my $y   = $vector->[1];

	$x      = $x / $scale + 25;
	$y      = $y / $scale + 25;

	return "$x,$y";
}

sub render {
	my $x       = shift;
	my $y       = shift;
	my $office  = shift;

	my $scale   = 0.05; # Metres per pixel

	my $geometry    = ceil($x / $scale + 50) . 'x' . ceil($y / $scale + 100);
	say "Image geometry is $geometry";

	# Set up a white backgrounded image of the right size
	my $image   = Image::Magick->new();
	$image->Set(size    => $geometry);
	$image->ReadImage('canvas:white');

	for my $wall (@$office) {
		my $v1      = ${$wall}[0];
		my $v2      = ${$wall}[1];
		my $res     = $v1 + $v2;
		say "Vector is $v1 -> $res";

		my $points  = vec_format($v1,$scale) . " " . vec_format($res,$scale);
		say "Points are $points";

		# Draw the shit
		$image->Draw(
			primitive   => 'line',
			points      => $points,
		);

	}

	my $scaley  = $y / $scale + 35;
	my $scalex  = 1 / $scale + 25;
	say "Scalex: $scalex, scaley: $scaley";
	my $points  = "25,$scaley $scalex,$scaley";

	say "Points: $points";
	# Add scale
	$image->Draw(
		primitive   => 'line',
		points      => $points,
	);

	$image->Draw(
		primitive   => 'text',
		points      => '25,' . ($scaley + 20),
		pointsize   => 14,
		text        => '1 Metre',
	);

	$scaley += 30;
	$scalex = 10 / $scale + 25;
	$points = "25,$scaley $scalex,$scaley";
	
	$image->Draw(
		primitive   => 'line',
		points      => $points,
	);

	$image->Draw(
		primitive   => 'text',
		points      => '25,' . ($scaley + 20),
		pointsize   => 14,
		text        => '10 Metres',
	);

	# Find filename
	my $id          = 0;
	my $filename    = "office-";
	$id++ while (-f "$filename$id.png");

	$image->Write("$filename$id.png");
	say "Wrote $filename$id.png";
}

# Offices are represented as a series of vectors in an array
my @office;

# Set the office size, anywhere from 1:1 to 4:1 from 10 to 50 metres 
# on the short side
my $ratio   = sprintf("%.2f",rn(1,4));
my $y       = sprintf("%.2f",rn(10,50));
my $x       = sprintf("%.2f",$y*$ratio);

say "Office size is ${x}m x ${y}m";

push(@office,[V(0 , 0),V($x, 0)]);
push(@office,[V(0 , 0),V(0 ,$y)]);
push(@office,[V(0 ,$y),V($x, 0)]);
push(@office,[V($x, 0),V(0 ,$y)]);

render($x,$y,\@office)
