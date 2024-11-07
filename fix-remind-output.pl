#!/usr/bin/perl
use strict;
use warnings;
my $map = {
        '1st' => 'First',
            '2nd' => 'Second',
            '3rd' => 'Third',
            '4th' => 'Fourth',
            'last' => 'Last',

            'sun' => 'Sunday',
            'mon' => 'Monday',
            'tue' => 'Tuesday',
            'wed' => 'Wednesday',
            'thu' => 'Thursday',
            'fri' => 'Friday',
            'sat' => 'Saturday',

            'jan' => 'January',
            'feb' => 'February',
            'mar' => 'March',
            'apr' => 'April',
            'may' => 'May',
            'jun' => 'June',
            'jul' => 'July',
            'aug' => 'August',
            'sep' => 'September',
            'oct' => 'October',
            'nov' => 'November',
            'dec' => 'December',

            'month_1' => 'January',
            'month_2' => 'February',
            'month_3' => 'March',
            'month_4' => 'April',
            'month_5' => 'May',
            'month_6' => 'June',
            'month_7' => 'July',
            'month_8' => 'August',
            'month_9' => 'September',
            'month_10' => 'October',
            'month_11' => 'November',
            'month_12' => 'December',
};

my @lines = ();
my $in_subdiv = 0;
my $country = '';
my $country_lines = {};
while(<>) {
        my $line = $_;
        if ($line =~ /^# COUNTRY\s*(\S+)/) {
                $country = $1;
                output(\@lines);
                @lines = ();
                $in_subdiv = 0;
                print $line;
                next;
        } elsif ($line =~ /^# SUBDIV/) {
                output(\@lines);
                $in_subdiv = 1;
                @lines = ();
                print $line;
                next;
        }

        next if $line =~ /EASTERN:/;
        while (my ($k, $v) = each(%$map)) {
                $line =~ s/\b$k\b/$v/g;
        }
        next if $country_lines->{$country}->{$line};
        push(@lines, $line);
        if (!$in_subdiv) {
                $country_lines->{$country}->{$line} = 1;
        }
}

sub output
{
        my ($lines) = @_;
        @$lines = sort { $a cmp $b } (@$lines);
        my $prev = '';
        foreach my $line (@$lines) {
                next if $line eq $prev;
                $prev = $line;
                print $line;
        }
}
