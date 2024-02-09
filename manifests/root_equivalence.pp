# @summary Configure root equivalence reporting
#
# See https://wiki.ncsa.illinois.edu/display/SecOps/k5login+root+equivalence+reporting
#
# @param crons
#   Hash of CRON entries for root equivalence reporting
#
# @param enable_yum_repo
#   Optional yum repo that must be enabled for list of packages to be installed.
#   This is needed to support enabling the rhel-7-server-optional-rpms repo for RHEL 7.
#
# @param files
#   Hash of files (scripts, etc) used for root equivalence reporting
#
# @param packages
#   Array of packages that need to be installed for root equivalence reporting
#
# @example
#   include profile_audit::root_equivalence
#
class profile_audit::root_equivalence (
  Hash $crons,
  Hash $files,
  Array $packages,
  Optional[String] $enable_yum_repo = '',
) {
  # IF SET $enable_yum_repo THEN ENSURE THAT REPO IS ENABLED
  if ( ! empty($enable_yum_repo) ) {
    $exec_name="yum-enable-${enable_yum_repo}"
    Package {
      require => [
        Exec[$exec_name],
      ],
    }
    exec { $exec_name :
      path    => [
        '/bin',
        '/usr/bin',
      ],
      command => "yum-config-manager --enable ${enable_yum_repo}",
      onlyif  => "yum repolist disabled | grep '${enable_yum_repo}'",
      unless  => "yum repolist enabled | grep '${enable_yum_repo}'",
    }
  }

  ensure_packages( $packages )

  File {
    owner  => root,
    group  => root,
    ensure => file,
    mode   => '0644',
  }
  $files.each | $k, $v | {
    file { $k: * => $v }
  }

  Cron {
    user        => 'root',
    hour        => 8,
    minute      => 1,
    environment => ['SHELL=/bin/sh',],
  }
  $crons.each | $k, $v | {
    cron { $k: * => $v }
  }
}
