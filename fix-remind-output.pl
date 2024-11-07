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

while(<>) {
        my $line = $_;
        while (my ($k, $v) = each(%$map)) {
                $line =~ s/\b$k\b/$v/g;
        }
        print $line;
}
