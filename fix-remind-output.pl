#!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;
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

my $output_dir = $ARGV[0];
if (defined($output_dir)) {
        if (! -d $output_dir) {
                mkdir($output_dir) or die("Cannot create $output_dir: $!");
        }
}

my $in_subdiv = 0;
my $country;
my $subdivs;
my $long_name;
my $subdiv;
my $type;
my $subdiv_lines = {};
my $country_lines = {};
my $category = 'public';
while(<STDIN>) {
        my $line = $_;
        next if $line =~ /EASTERN:/;
        if ($line =~ /^# COUNTRY\s+(\S+)\s+(\d+)\s+(\S.*)$/) {
                output($country);
                $country = $1;
                $subdivs = $2;
                $long_name = $3;
                $subdiv_lines = {};
                $country_lines = {};
                $in_subdiv = 0;
                $subdiv = undef;
                $category = 'public';
                next;
        } elsif ($line =~ /^# SUBDIV\s+(.*)/) {
                $in_subdiv = 1;
                $subdiv = $1;
                $category = 'public';
                next;
        } elsif ($line =~ /^# CATEGORY\s+(\S+)/) {
                $category = $1;
                next;
        }
        while (my ($k, $v) = each(%$map)) {
                $line =~ s/\b$k\b/$v/g;
        }
        $line = fixup_line($line);
        if ($category ne 'public' && $category ne 'government') {
                $type = 'optional';
        } else {
                $type = 'public';
        }

        if (!$in_subdiv) {
                push(@{$country_lines->{$type}}, $line);
        } else {
                push(@{$subdiv_lines->{$subdiv}->{$type}}, $line);
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
                        $day += $month_days->[$monnum];
                }
        }
        return "REM $wkday $day " . $num_to_month->{$monnum} . " ADDOMIT SCANFROM -28 MSG $second\n";
}


sub fixup_working_day_line
{
        my ($line) = @_;
        my($rem, $day, $month, $omit) = split(/ /, $line);
        my $monnum = $month_to_num->{lc($month)} + 1;
        $line =~ s/ OMIT SAT SUN AFTER ADDOMIT SCANFROM -28 / OMIT SAT SUN AFTER ADDOMIT SCANFROM -28 MAYBE-UNCOMPUTABLE SATISFY [wkdaynum(date(\$Ty, $monnum, $day))==0 || wkdaynum(date(\$Ty, $monnum, $day))==6] /;
        $line =~ s/ OMIT SAT SUN BEFORE ADDOMIT SCANFROM -28 / OMIT SAT SUN BEFORE ADDOMIT SCANFROM -28 MAYBE-UNCOMPUTABLE SATISFY [wkdaynum(date(\$Ty, $monnum, $day))==0 || wkdaynum(date(\$Ty, $monnum, $day))==6] /;
        return $line;
}

sub fixup_line
{
        my ($line) = @_;
        if ($line =~ / OMIT SAT SUN /) {
                return fixup_working_day_line($line);
        }

        return $line unless ($line =~ /^FIXUP([12])/);
        if ($1 eq '1') {
                return fixup_line_1($line);
        } elsif ($1 eq '2') {
                return fixup_line_2($line);
        }
        return $line;
}

sub remove_output_file
{
        my ($country, $subdiv) = @_;
        return undef unless $country;
        my $fname;
        my $lcc = lc($country);
        $lcc =~ s/\s/_/g;
        if ($subdiv) {
                my $lcs = lc($subdiv);
                $lcs =~ s/\s/_/g;
                $fname = "$output_dir/$lcc/$lcs.rem";
        } else {
                $fname = "$output_dir/$lcc.rem";
        }
        unlink($fname);
}

sub open_output_file
{
        my ($country, $subdiv) = @_;
        return undef unless $country;
        my $fp;
        my $lcc = lc($country);
        $lcc =~ s/\s/_/g;
        if ($subdiv) {
                my $lcs = lc($subdiv);
                $lcs =~ s/\s/_/g;
                if (! -d "$output_dir/$lcc") {
                        mkdir("$output_dir/$lcc") or die("Cannot create directory $output_dir/$lcc: $!");
                }
                open($fp, '>', "$output_dir/$lcc/$lcs.rem") or die("Cannot open $output_dir/$lcc/$lcs.rem for writing: $!");
                print $fp <<"EOF";
# SPDX-License-Identifier: MIT
# Holiday file for subdivision $subdiv in $long_name
# Derived from the Python holidays project at
# https://github.com/vacanza/holidays
#
# Note that this file includes only the holidays for
# the specific subdivision $subdiv.
#
# If you want the national holidays as well, you must
# also include [\$SysInclude]/$lcc.rem

EOF
        } else {
                open($fp, '>', "$output_dir/$lcc.rem") or die("Cannot open $output_dir/$lcc.rem for writing: $!");
                print $fp <<"EOF";
# SPDX-License-Identifier: MIT
# Holiday file for $long_name
# Derived from the Python holidays project at
# https://github.com/vacanza/holidays
EOF
                if ($subdivs > 0) {
                        print $fp <<"EOF";
#
# Note: This file consists only of the country-wide
# holidays for $long_name.
#
# For region-specific holidays, you need to include
# one of the regional *.rem files in the directory
# [\$SysInclude]/$lcc/
EOF
                }
                $fp->print("\n");
        }
        return $fp;
}

sub output
{
        my ($country) = @_;
        my $fp;

        my @lines;
        my $seen;
        my $subdiv_seen;
        my $did_something = 0;
        return unless $country;

        # Do the country lines first
        if ($output_dir) {
                $fp = open_output_file($country, undef);
        } else {
                print "# COUNTRY $country\n";
        }

        # Country-level public holidays
        @lines = sort { sort_function($a, $b) } (@{$country_lines->{public}});
        foreach my $line (@lines) {
                next if $seen->{$line};
                $seen->{$line} = 1;
                $did_something = 1;
                if ($output_dir) {
                        $fp->print($line);
                } else {
                        print $line;
                }
        }

        # Country-level optional holidays
        @lines = sort { sort_function($a, $b) } (@{$country_lines->{optional}});
        foreach my $line (@lines) {
                next if $seen->{$line};
                $seen->{$line} = 1;
                $line = adjust_optional($line);
                $did_something = 1;
                if ($output_dir) {
                        $fp->print($line);
                } else {
                        print $line;
                }
        }
        if ($output_dir) {
                $fp->close();
                if (!$did_something) {
                        remove_output_file($country, undef);
                }
        }

        # Now the subdivisions
        foreach my $subdiv (sort { $a cmp $b } (keys(%$subdiv_lines))) {
                # Do nothing if there are no lines
                if (scalar(@{$subdiv_lines->{$subdiv}->{public}}) == 0 && scalar(@{$subdiv_lines->{$subdiv}->{optional}}) == 0) {
                        return;
                }
                if ($output_dir) {
                        $fp = open_output_file($country, $subdiv);
                }
                $did_something = 0;
                $subdiv_seen = {};
                # Subdivision-level public holidays
                @lines = sort { sort_function($a, $b) } (@{$subdiv_lines->{$subdiv}->{public}});
                foreach my $line (@lines) {
                        next if $seen->{$line};
                        next if $subdiv_seen->{$line};
                        $subdiv_seen->{$line} = 1;
                        if (!$output_dir) {
                                print "# SUBDIV $subdiv\n" unless $did_something;
                        }
                        $did_something = 1;
                        if ($output_dir) {
                                $fp->print($line);
                        } else {
                                print $line;
                        }
                }

                # Subdivision-level optional holidays
                @lines = sort { sort_function($a, $b) } (@{$subdiv_lines->{$subdiv}->{optional}});
                foreach my $line (@lines) {
                        next if $seen->{$line};
                        next if $subdiv_seen->{$line};
                        $subdiv_seen->{$line} = 1;
                        $line = adjust_optional($line);
                        if (!$output_dir) {
                                print "# SUBDIV $subdiv\n" unless $did_something;
                        }
                        $did_something = 1;
                        if ($output_dir) {
                                $fp->print($line);
                        } else {
                                print $line;
                        }
                }
                if ($output_dir) {
                        $fp->close();
                        if (!$did_something) {
                                remove_output_file($country, $subdiv);
                        }
                }
        }
}

sub adjust_optional
{
        my ($line) = @_;
        $line =~ s/^OMIT /REM /;
        $line =~ s/ ADDOMIT / /;
        return $line;
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
                my $ans = $mon*31 + $day;
                if ($line =~ /Uy\)\+(\d+)/) {
                        $ans += $1;
                } elsif ($line =~ /Uy\)-(\d+)/) {
                        $ans -= $1;
                }
                return $ans;
        }
        if (defined($mon) && defined($day)) {
                my $ans = $mon*31 + $day;
                return $ans;
        }
        return 999;
}

