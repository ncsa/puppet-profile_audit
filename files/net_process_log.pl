#!/usr/bin/perl -wT

#
# Script will log network connections (excluding 10.2, 10.1 and 127.0.0.1)
# as well as user processes running to syslog
#
# Usage: net_process_log.pl --ssarg|-A --ssfilter-|-F --psarg|-a --ignoreusers|-i --test
#
# --ssarg (-A)  arguments to pass on to the ss command
#         default is 'natupeH'
# --ssfilter (-F)  network filter to pass on to the ss command
#         default is '! dst 127.0.0.1 and ! src 127.0.0.1'
# --psarg (-a) argumets to pass on to the ps command
#         default is 'axho user:32,pid,ppid,pcpu,pmem,args'
# --ignoreusers (-i)  Users to ignore from ps command output
#         default is 'root,dbus,postfix,chrony,munge,telegraf,libstoragemgmt,nrpe,polkitd'
# --test (-t)  Run in test mode.  Print output, but do not send to logs
#         default is send to logs
#

use strict;
use warnings;
use Sys::Syslog;
use Getopt::Long qw(:config no_ignore_case);
use Scalar::Util qw(tainted);

# Make environment safer
delete @ENV{qw(IFS CDPATH ENV BASH_ENV)};
$ENV{'PATH'} = '/usr/sbin:/usr/bin';

my $test = '0';
my $ss_arg = 'natupeH';
my $ss_filter = '! dst 127.0.0.1 and ! src 127.0.0.1';
my $ps_arg = 'axho user:32,pid,ppid,pcpu,pmem,args';
my $ignore_users = 'avahi,chrony,dbus,libstoragemgmt,munge,nrpe,polkitd,postfix,rngd,root,telegraf,unbound';
GetOptions( 'ssarg|A=s' => \$ss_arg,
            'ssfilter|F=s' => \$ss_filter,
            'psarg|a=s' => \$ps_arg,
            'ignoreusers|i=s' => \$ignore_users,
            'test|t' => \$test);

#Only alpha-numberic allowed for ss argument
( my $ss_arg_untaint ) = $ss_arg  =~ m/^([A-Z0-9]+)$/ig;
if ( ! defined $ss_arg_untaint ) {
   print "Bad value passed for ss argument\n";
   exit;
}

# Remove leading spaces from filter
$ss_filter =~ s/^[ ]*//;

# Don't allow leading period or slash in filter
my $bad_filter = $ss_filter =~ m/^[.\/]/;

# Check for potentially malicious characters in filter
( my $ss_filter_untaint ) = $ss_filter  =~ m/^([A-Z0-9! .\/]+)$/ig;

# Reject if unsafe
if ( ! defined $ss_filter_untaint  || $bad_filter) {
   print "Bad value passed for ss filter\n";
   exit;
}

#Only alpha-numberic, space, colon, and comma allowed for ps argument
( my $ps_arg_untaint ) = $ps_arg  =~ m/^([A-Z0-9 :,]+)$/ig;
if ( ! defined $ps_arg_untaint ) {
   print "Bad value passed for ps argument\n";
   exit;
}

#Only alpha-numberic and comma allowed for ignore_user
( my $ignore_users_untaint ) = $ignore_users  =~ m/^([A-Z0-9,]+)$/ig;
if ( ! defined $ignore_users_untaint ) {
   print "Bad value passed for ignoreusers\n";
   exit;
}
my $ignore_string='';
foreach my $user ( split /,/, $ignore_users_untaint ) {
   $ignore_string = $ignore_string . "^" . $user . " |";
}
$ignore_string =~ s/\|$//;

openlog("NetProcessLog", 0, 'LOG_LOCAL0') or die "Cannot open log";

my $ss_command = "ss -$ss_arg_untaint '( $ss_filter_untaint )'";
open CMD, '-|', "$ss_command | tr -s ' ' | sort -n --key=5" or die "Cannot run ss";
while ( defined(my $line=<CMD>)) {
        chomp $line;

        if ($test) {
                print "$line \n";
        } else {
                syslog('LOG_INFO', $line);
        }
}
close CMD;

my $ps_command = "ps $ps_arg_untaint | egrep -v '$ignore_string' | sort";
open CMD, '-|', "$ps_command" or die "Cannot run ps";
while ( defined(my $line=<CMD>)) {
        chomp $line;

        my @ps_line_split = split(/\s+/, $line);
        my $pid_tainted = $ps_line_split[1];
        my $pid = '';
        my $pwd = '';

        # Error check and untaint pid variable
        if ($pid_tainted =~ m/^(\d+)$/) {
                $pid = $1;
                $pwd = `readlink -f /proc/$pid/cwd`;

                if ($? != 0 ) {
                        $pwd = "ERROR-CANNOT-LOOKUP-PWD"
                }

                chomp $pwd;

        } else {
                $pwd = "ERROR-NON-NUMERIC-PID-DETECTED"
        }

        my $output = "$line PWD=$pwd\n";

        if ($test) {
                print "$output";
        } else {
                syslog('LOG_INFO', "$output");
        }
}
close CMD;

closelog();


