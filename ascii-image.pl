# expand_url_privmsgs
#   ON  -> Expand URLs in private messages (This is the default)
#   OFF -> Do NOT expand URLs in private messages
# expand_url_whitelist
#   A whitespace delimited list of channels where we want to expand URLs sent
#   to us. If left undefined, URLs sent to all channels will be expanded.
#   This is undefined by default.

use Irssi;
use strict;
use LWP;
use LWP::UserAgent;
use URI::Escape;
use vars qw($VERSION %IRSSI);

$VERSION = '1.0';
%IRSSI = (
    authors     => 'Aurélien Thieriot',
    contact     => 'a.thieriot@gmail.com',
    name        => 'irssi ascii image',
    description => 'Display an ASCII representation of an image using jp2a.',
    license     => 'MIT',
    url         => 'https://github.com/athieriot/irssi-ascii-image',
    changed     => '2011-08-14',
);

Irssi::settings_add_bool('expand_url', 'expand_url_privmsgs', 1);
Irssi::settings_add_str('expand_url', 'expand_url_white', undef);

my $ua = LWP::UserAgent->new;
$ua->agent("Display an ASCII representation of an image using jp2a. (https://github.com/athieriot/irssi-ascii-image)");
$ua->timeout(15);

# All of these functions are pretty much the same. There must be a way to
# consolidate them.
sub message_public {
	my ($server, $msg, $nick, $address, $target) = @_;

	if (whitelisted($target)) {
		my $new_msg = message($msg);

		Irssi::signal_continue($server, $new_msg, $nick, $address,
			$target);
	}
}
sub message_private {
    my ($server, $msg, $nick, $address) = @_;

    if (Irssi::settings_get_bool('expand_url_privmsgs')) {
        my $new_msg = message($msg);

        Irssi::signal_continue($server, $new_msg, $nick, $address);
    }
}

sub whitelisted {
	my ($channel) = @_;
	my $whitelist = Irssi::settings_get_str('expand_url_white');

	# If our whitelist is undefined, we assume all channels are
	# acceptable.
	if ($whitelist eq undef) {
		return 1;
	}

	my @chans = split(' ', $whitelist);

	# Otherwise, make sure our channel is on the list.
	foreach my $chan (@chans) {
		if ($channel eq $chan) {
			return 1;
		}
	}
	return 0;
}

# This is where the magic happens.
sub message {
	my ($msg) = @_;
	# Split $msg into an array delimited by spaces.
	# Check each element for ^http:// or ^https://
	# If it matches, replace it with the response from longurl's API
	# 	Unless there's an error
	# Collapse the array back into a single value and return it

	my @values = split(' ', $msg);
	foreach my $val (@values) {
		if ($val =~ /(jpg|gif|jpeg|png)$/i) {
            $val = `convert $val jpg:- | jp2a --colors --grayscale -f -`;
		}
	}
	return join(' ', @values);
}

Irssi::signal_add_last("message public", "message_public");
Irssi::signal_add_last("message private", "message_private");
