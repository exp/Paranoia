#!/usr/bin/perl

# Test bot for procedural generation. This should just sit on irc and
# run the procedural generation functions so we can test their quality

use Modern::Perl    '2012';
use IO::Async::Loop;
use Net::Async::IRC;
use Log::Log4perl   ':easy';
use Data::Dump      qw/ddx pp/;

#######################################################################
# Procedural generation                                               #
#######################################################################
use Paranoia::Names;
my $namegen = Paranoia::Names->new();

Log::Log4perl->easy_init($WARN);
my $logger  = get_logger();

my $loop = IO::Async::Loop->new;

my $irc = Net::Async::IRC->new(
	nick        => "Procbot",
	user        => "Procbot",
	realname    => "I am a bot, you are dumb",

	on_message_text => \&handle_message,
);

sub send_message {
	my $channel = shift;
	my $message = shift;

	$irc->send_message("PRIVMSG", undef, $channel, $message);
}

sub handle_command {
	my $channel = shift;
	my $text    = shift;
	my $command = shift;

	given ($command) {
		when (/name/) {
			send_message($channel, $namegen->person);
		}
	}
}

sub handle_message {
	my $irc     = shift;
	my $message = shift;
	my $hints   = shift;

	ddx(@_) if @_;

	given ($message->command) {
		when (/NOTICE/) {
			$logger->warn("Notice: " . pp($message->args));
		}
		when (/PRIVMSG/) {
			my ($channel, $text)    = $message->args;
			if ($text   =~ /^!(\w+)/) {
				handle_command($channel,$text,$1);
			}
		}
		default {
			$logger->error("Unknown command: " . $message->command . "\n" . pp($message->args));
		}
	}
}

$loop->add( $irc );

$irc->login(
	host        => "irc.hardchats.com",
	on_login    => sub {
		$logger->warn("Connected, joining channels");
		$irc->send_message("JOIN", undef, "#paranoia");
	}
);

$logger->warn("Starting up");
$loop->loop_forever;
