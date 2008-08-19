# Simple script for growl notifications in irssi
#
# If anyone has a better suggestion to DRY up the signals I would appreciate
# it. Nate Murray
# Settings:
#       /SET growl_on_regex [regex]

use strict;
use Irssi;
use vars qw($VERSION %IRSSI);

# Dev. info ^_^
$VERSION = "0.0";
%IRSSI = (
	authors     => "Nate Murray",
	contact     => "nate\@natemurray.com",
	name        => "Growl",
	description => "Simple script that will growlnotify the messages",
	license     => "GPL",
	url         => "http://www.xcombinator.com",
	changed     => "Tue Jun 17 08:55:13 PDT 2008"
);

# All the works
sub growl_it {
	my ($title, $data) = @_;
    $data =~ s/["';]//g;
    system("growlnotify -H localhost -m '$data' -t '$title'");
}

# All the works
sub growl_message {
	my ($server, $data, $nick, $mask, $target) = @_;
    # Irssi::settings_get_bool('growl_on_my_nick_only');
    my $filter = Irssi::settings_get_str('growl_on_regex');

    if($filter) {
      growl_it($nick, $data) if $data =~ /$filter/;
    } else {
      growl_it($nick, $data);
    }
	Irssi::signal_continue($server, $data, $nick, $mask, $target);
}

sub growl_join {
	my ($server, $channel, $nick, $address) = @_;
    growl_it("Join", "$nick has joined");
	Irssi::signal_continue($server, $channel, $nick, $address);
}

sub growl_part {
	my ($server, $channel, $nick, $address) = @_;
    growl_it("Part", "$nick has parted");
	Irssi::signal_continue($server, $channel, $nick, $address);
}

sub growl_quit {
	my ($server, $nick, $address, $reason) = @_;
    growl_it("Quit", "$nick has quit: $reason");
	Irssi::signal_continue($server, $nick, $address, $reason);
}

sub growl_invite {
	my ($server, $channel, $nick, $address) = @_;
    growl_it("Invite", "$nick has invited you on $channel");
	Irssi::signal_continue($server, $channel, $address);
}

sub growl_topic {
	my ($server, $channel, $topic, $nick, $address) = @_;
    growl_it("Topic: $topic", "$nick has changed the topic to $topic on $channel");
	Irssi::signal_continue($server, $channel, $topic, $nick, $address);
}

# Hook me up
#Irssi::settings_add_bool('misc', 'growl_on_my_nick_only', 0); # false
Irssi::settings_add_str('misc', 'growl_on_regex', 0); # false

Irssi::signal_add('message public', 'growl_message');
Irssi::signal_add('message private', 'growl_message');
Irssi::signal_add('message join', 'growl_join');
Irssi::signal_add('message part', 'growl_part');
Irssi::signal_add('message quit', 'growl_quit');
Irssi::signal_add('message invite', 'growl_invite');
Irssi::signal_add('message topic', 'growl_topic');
