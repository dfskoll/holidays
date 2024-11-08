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

my $month_to_num = {
            'january' => 0,
            'february' => 1,
            'march' => 2,
            'april' => 3,
            'may' => 4,
            'june' => 5,
            'july' => 6,
            'august' => 7,
            'september' => 8,
            'october' => 9,
            'november' => 10,
            'december' => 11,
};

my $month_days = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
my $num_to_month = {
        0 => 'January',
        1 => 'February',
        2 => 'March',
        3 => 'April',
        4 => 'May',
        5 => 'June',
        6 => 'July',
        7 => 'August',
        8 => 'September',
        9 => 'October',
        10 => 'November',
        11 => 'December',
};

my $wkday_to_num = {
            'sunday' => 0,
            'monday' => 1,
            'tuesday' => 2,
            'wednesday' => 3,
            'thursday' => 4,
            'friday' => 5,
            'saturday' => 6,
};

my $num_to_wkday = {
        0 => 'Sunday',
        1 => 'Monday',
        2 => 'Tuesday',
        3 => 'Wednesday',
        4 => 'Thursday',
        5 => 'Friday',
        6 => 'Saturday',
};

my $ordinal_to_num = {
        first => 1,
        second => 2,
        third => 3,
        fourth => 4,
        'last' => -1
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
        $line = fixup_line($line);
        next if $country_lines->{$country}->{$line};
        push(@lines, $line);
        if (!$in_subdiv) {
                $country_lines->{$country}->{$line} = 1;
        }
}

sub fixup_line_1
{
        my ($line) = @_;
        return $line unless $line =~ /^(.*) MSG (.*)/;
        my $first = $1;
        my $second = $2;
        my (undef, $days, $direction, $ordinal, $weekday, $month) = split(/ /, $first);
        my $ordnum = $ordinal_to_num->{lc($ordinal)};
        my $wkdaynum = $wkday_to_num->{lc($weekday)};
        my $monnum = $month_to_num->{lc($month)};

        if ($direction eq 'past') {
                my $start_day = $ordnum * 7 - 6 + $days;
                $wkdaynum = ($wkdaynum + $days) % 7;
                return "REM " . $num_to_wkday->{$wkdaynum} . " $start_day " . $num_to_month->{$monnum} . " ADDOMIT SCANFROM -28 MSG $second\n";
        } else {
                if ($ordnum < 0) {  # X prior last weekday
                        $monnum++;
                        if ($monnum == 12) {
                                $monnum = 0;
                        }
                        $days += 7;
                        return "REM $weekday 1 " . $num_to_month->{$monnum} . " --$days ADDOMIT SCANFROM -28 MSG $second\n";
                } else {
                        my $start_day = $ordnum * 7 - 6;
                        return "REM " . $num_to_wkday->{$wkdaynum} . " $start_day " . $num_to_month->{$monnum} . " --" . $days . " ADDOMIT SCANFROM -28 MSG $second\n";
                }
        }
        return $line;
}

sub fixup_line_2
{
        my ($line) = @_;
        return $line unless $line =~ /^(.*) MSG (.*)/;
        my $first = $1;
        my $second = $2;
        my (undef, $which, $wkday, $from_before, $month, $day) = split(/ /, $first);

        if ($which ne 'First') {
                return $line;
        }

        my $monnum = $month_to_num->{lc($month)};

        if ($from_before eq 'before') {
                $day -= 6;
                if ($day < 0) {
                        $monnum--;
                        if ($monnum < 0) {
                                $monnum = 11;
                        }
                        print STDERR $monnum . "\n";
                        $day += $month_days->[$monnum];
                }
        }
        return "REM $wkday $day " . $num_to_month->{$monnum} . " ADDOMIT SCANFROM -28 MSG $second\n";
}

sub fixup_line
{
        my ($line) = @_;
        return $line unless ($line =~ /^FIXUP([12])/);
        if ($1 eq '1') {
                return fixup_line_1($line);
        } elsif ($1 eq '2') {
                return fixup_line_2($line);
        }
        return $line;
}

sub output
{
        my ($lines) = @_;
        @$lines = sort { sort_function($a, $b) } (@$lines);
        my $prev = '';
        foreach my $line (@$lines) {
                next if $line eq $prev;
                $prev = $line;
                print $line;
        }
}

sub sort_function
{
        my ($a, $b) = @_;
        my $an = calculate_sort_number($a);
        my $bn = calculate_sort_number($b);

        if ($an != $bn) {
                return $an <=> $bn;
        }
        return $a cmp $b;
}

sub calculate_sort_number
{
        my ($line) = @_;
        my ($day, $mon);
        if ($line =~ /^(REM|OMIT) (\d+) /) {
                $day = $2;
        } elsif ($line =~ /^REM (Sunday|Monday|Tuesday|Wednesday|Thursday|Friday|Saturday) (\d+)/) {
                $day = $2;
        } elsif ($line =~ /^REM (First|Second|Third|Fourth|Last) /) {
                $day = 7 * $ordinal_to_num->{lc($1)} - 6;
                if ($day < 0) {
                        $day = 29;
                }
        }
        if ($line =~ / (January|February|March|April|May|June|July|August|September|October|November|December) /) {
                $mon = $month_to_num->{lc($1)};
        } elsif ($line =~ /easterdate/) {
                $mon = 3;
                $day = 15;
        }
        if (defined($mon) && defined($day)) {
                my $ans = $mon*31 + $day;
                return $ans;
        }
        return 999;
}

