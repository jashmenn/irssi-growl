# == WHAT
# Simple script for growl notifications in irssi
#
# == WHO
# Nate Murray 2008
# 
# == CONFIG
#   /SET growl_on_regex [regex]
#   /SET growl_channel_regex [regex]
#
# == EXAMPLES
#
#   growl everything:
#   /SET growl_on_regex  .*
#
#   ignore jdewey
#   /SET growl_on_regex  (?=^(?:(?!jdewey).)*$).*
#
# == INSTALL
# Place in ~/.irssi/scripts/
# /script load growl.pl
#
# == CONTRIBUTE
# If anyone has a better suggestion to DRY up the signals I would appreciate it. 
# 
# http://gist.github.com/6206
# or 
# git clone git://gist.github.com/6206.git gist-6206

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
	changed     => "Mon Sep 22 11:55:07 PDT 2008"
);

# All the works
sub do_growl {
	my ($title, $data) = @_;
    $data =~ s/["';]//g;
    system("growlnotify -H localhost -m '$data' -t '$title'");
    return 1
}

sub growl_it {
	my ($server, $title, $data, $channel, $nick) = @_;

    my $filter = Irssi::settings_get_str('growl_on_regex');
    my $channel_filter = Irssi::settings_get_str('growl_channel_regex');

    if($filter) {
      return 0 if $data !~ /$filter/;
    }

    if($channel_filter && $server->ischannel($channel)) {
      return 0 if $channel !~ /$channel_filter/;
    }


    do_growl($title, $data);
}

# All the works
sub growl_message {
	my ($server, $data, $nick, $mask, $target) = @_;
    my ($goal, $text) = split(/ :/, $data, 2);
    growl_it($server, $nick, $data, $target, $nick);
	Irssi::signal_continue($server, $data, $nick, $mask, $target);
}

sub growl_join {
	my ($server, $channel, $nick, $address) = @_;
    growl_it($server, "Join", "$nick has joined", $channel, $nick);
	Irssi::signal_continue($server, $channel, $nick, $address);
}

sub growl_part {
	my ($server, $channel, $nick, $address) = @_;
    growl_it($server, "Part", "$nick has parted", $channel, $nick);
	Irssi::signal_continue($server, $channel, $nick, $address);
}

sub growl_quit {
	my ($server, $nick, $address, $reason) = @_;
    growl_it($server, "Quit", "$nick has quit: $reason", $server, $nick);
	Irssi::signal_continue($server, $nick, $address, $reason);
}

sub growl_invite {
	my ($server, $channel, $nick, $address) = @_;
    growl_it($server, "Invite", "$nick has invited you on $channel", $channel, $nick);
	Irssi::signal_continue($server, $channel, $address);
}

sub growl_topic {
	my ($server, $channel, $topic, $nick, $address) = @_;
    growl_it($server, "Topic: $topic", "$nick has changed the topic to $topic on $channel", $channel, $nick);
	Irssi::signal_continue($server, $channel, $topic, $nick, $address);
}

sub growl_privmsg {
	# $server = server record where the message came
	# $data = the raw data received from server, with PRIVMSGs it is:
	#         "target :text" where target is either your nick or #channel
	# $nick = the nick who sent the message
	# $host = host of the nick who sent the message
	my ($server, $data, $nick, $host) = @_;
    my ($target, $text) = split(/ :/, $data, 2);
    growl_it($server, $nick, $data, $target, $nick);
	Irssi::signal_continue($server, $data, $nick, $host);
}


# Hook me up
Irssi::settings_add_str('misc', 'growl_on_regex', 0);      # false
Irssi::settings_add_str('misc', 'growl_channel_regex', 0); # false
Irssi::signal_add('message public', 'growl_message');
Irssi::signal_add('message private', 'growl_message');
Irssi::signal_add('message join', 'growl_join');
Irssi::signal_add('message part', 'growl_part');
Irssi::signal_add('message quit', 'growl_quit');
Irssi::signal_add('message invite', 'growl_invite');
Irssi::signal_add('message topic', 'growl_topic');
Irssi::signal_add('event privmsg', 'growl_privmsg');