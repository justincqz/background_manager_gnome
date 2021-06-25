#!/usr/bin/perl

use 5.010;
use strict;
use warnings;

use XML::LibXML;
use Hash::PriorityQueue;

my $numArgs = $#ARGV + 1;
if ($numArgs != 1) {
    print "\nUsage: bg_manager.pl cur_path\n";
    exit;
}
my $curPath = $ARGV[0];

my $filename = "$curPath/wallpapers.xml";

my $dom = XML::LibXML->load_xml(location => $filename);
my ($sec,$min,$h,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
my $list = Hash::PriorityQueue->new();

foreach my $WP ($dom->findnodes('wallpapers/WP')) {
    my @time_p = split /:/, $WP->findnodes('time');
    my $hour = $time_p[0] + 0;
    my $minutes = $time_p[1] + 0;
    my $path = $WP->findnodes('fpath');
    $list->insert($path, $hour * 100 + $minutes);
    say "Hour: ", $hour, " Minutes: ", $minutes, " Path: ", $path;
}

$list->insert("cur", $h * 100 + $min);

my $prev;
do {
    my $elem = $list->pop();
    if ($elem eq "cur") {
        if ($prev ne "") {
            system("gsettings set org.gnome.desktop.background picture-uri file://$prev");
        }
        exit;
    }
    say $prev = $elem;
} while ($prev ne undef);

