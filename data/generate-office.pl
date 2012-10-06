#!/usr/bin/perl 

use Modern::Perl    '2012';
use POSIX           qw/ceil/;
use Image::Magick;
use Math::Vector::Real;
use Data::Dump      'pp';

use constant    ATOM    => 2;

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

		my $points  = vec_format($v1,$scale) . " " . vec_format($res,$scale);

		# Draw the shit
		$image->Draw(
			primitive   => 'line',
			points      => $points,
		);

	}

	my $scaley  = $y / $scale + 35;
	my $scalex  = 1 / $scale + 25;
	my $points  = "25,$scaley $scalex,$scaley";

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

sub clear_space {
	my $min     = shift;
	my $max     = shift;
	my $atom    = shift;    # The minimum space on each side of a line
	my $points  = shift;

	my @checks  = sort {$a <=> $b} (@$points, $max);

	my $last    = 0;
	my $space   = 0;
	for my $point (@checks) {
		# If there's enough space between this point and the last, add
		# the space
		my $avail   = $point - $last - $atom*2;
		if ($avail >= 0) {
			$space  += $avail;
		}
		$last   = $point;
	}

	return $space;
}

sub extrap_space {
	my $min     = shift;
	my $max     = shift;
	my $atom    = shift;
	my $pos     = shift;
	my $points  = shift;

	my @sorted  = sort {$a <=> $b} @$points;

	# Trim the side
	$min    += $atom;

	# Add the far wall to the points
	push(@sorted,$max);

	# If we have no points, we insert the point at its original position
	unless (@$points) {
		return $min + $pos;
	}

	for my $point (@sorted) {
		# If there is at least 2 * atom free space then the point goes
		# there, otherwise add the distance and move to the next line
		# Min represents the leftmost point that could be placed
		my $space   = $point - $min - $atom;
		if ($pos >= 0 && ($space - $pos) >= 0) {
			return $min + $pos;
		} elsif ($pos >= 0 && $space > 0) {
			$min    = $point + $atom;
			$pos    -= $space;
		} elsif ($pos > 0) {
			$min    = $point + $atom;
		} else {
			return undef;
		}
	}

	return undef;
}

sub add_divisions {
	my $x       = shift;
	my $office  = shift;
	my @points;

	# While there are still gaps where lines could be added
	# grab the available free space, pick a point within it and
	# then extrapolate its final position
	my $count   = 0;
	my $atom    = 1;
	while ((my $size = clear_space(0,$x,ATOM,\@points)) >= ATOM) {
		my $position    = sprintf("%.2f",rn(0,$size));
		my $finalpos    = extrap_space(0,$x,ATOM,$position,\@points);

		# If there's nowhere to fit this entry we have filled all
		# available space and should return
		last unless ($finalpos);

		push (@points, $finalpos);
	}

	return @points;
}

# Offices are represented as a series of vectors in an array
my @office;

# Set the office size, anywhere from 1:1 to 4:1 from 10 to 30 metres 
# on the short side
my $ratio   = sprintf("%.2f",rn(1,4));
my $y       = sprintf("%.2f",rn(10,30));
my $x       = sprintf("%.2f",$y*$ratio);

say "Office size is ${x}m x ${y}m";

push(@office,[V(0 , 0),V($x, 0)]);
push(@office,[V(0 , 0),V(0 ,$y)]);
push(@office,[V(0 ,$y),V($x, 0)]);
push(@office,[V($x, 0),V(0 ,$y)]);

# Add random partition lines
my @horiz   = add_divisions($x,$y,\@office);
my @vert    = add_divisions($y,$x,\@office);

for my $line (@horiz) {
	push @office, [V($line,0),V(0,$y)];
}
for my $line (@vert) {
	push @office, [V(0,$line),V($x,0)];
}

render($x,$y,\@office)
