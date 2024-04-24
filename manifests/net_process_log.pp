# @summary Logs user processes and open network connections to syslog
#
# Logs user processes and open network connections to syslog
#
# @param enable_net_process_log
#   Enable/disable the net_process_log logging
#
# @param ignore_users
#   String to pass to net_process_log.pl script as -i argument.
#   Setting to empty string will use default defined in net_process_log.pl.
#   Format is a csv of users to ignore. Example : "root,chrony,dbus".
#
# @param ps_arg
#   String to pass to net_process_log.pl script as --psarg argument.
#   Setting to empty string will use default defined in net_process_log.pl.
#
# @param ss_arg
#   String to pass to net_process_log.pl script as --ssarg argument.
#   Setting to empty string will use default defined in net_process_log.pl
#   
# @param ss_filter
#   String to pass to net_process_log.pl script as --ssfilter argument.
#   Setting to empty string will use default defined in net_process_log.pl
#
# @param minute_interval
#   Value to use in the minute field of the cron task 
#
# @example
#   include profile_audit::net_process_log
class profile_audit::net_process_log (
  Boolean $enable_net_process_log,
  String $ignore_users,
  String $ps_arg,
  String $ss_arg,
  String $ss_filter,
  String $minute_interval,
) {
  if ($enable_net_process_log) {
    $ensure_parm = 'present'
  } else {
    $ensure_parm = 'absent'
  }

  file { '/root/cron_scripts/net_process_log.pl':
    ensure  => $ensure_parm,
    mode    => '0750',
    owner   => 'root',
    group   => 'root',
    source  => "puppet:///modules/${module_name}/net_process_log.pl",
    require => File['/root/cron_scripts'],
  }

  # Setup any non-default options, otherwise *_option stays blank
  # so we use default(s) from script
  if $ignore_users != '' {
    $ignore_users_option = "-i \"${ignore_users}\""
  } else {
    $ignore_users_option = ''
  }

  if $ps_arg != '' {
    $ps_arg_option = "--psarg \"${ps_arg}\""
  } else {
    $ps_arg_option = ''
  }

  if $ss_arg != '' {
    $ss_arg_option = "--ssarg \"${ss_arg}\""
  } else {
    $ss_arg_option = ''
  }

  if $ss_filter != '' {
    $ss_filter_option = "--ssfilter \"${ss_filter}\""
  } else {
    $ss_filter_option = ''
  }

  cron { 'net_process_log':
    ensure      => $ensure_parm,
    user        => 'root',
    minute      => $minute_interval,
    hour        => '*',
    month       => '*',
    weekday     => '*',
    monthday    => '*',
    environment => ['SHELL=/bin/sh',],
    command     => "/root/cron_scripts/net_process_log.pl ${ignore_users_option} ${ps_arg_option} ${ss_arg_option} ${ss_filter_option} >/dev/null 2>&1",
  }
}
