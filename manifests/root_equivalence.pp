# @summary Configure root equivalence reporting
#
# See https://wiki.ncsa.illinois.edu/display/SecOps/k5login+root+equivalence+reporting
#
# @param crons
#   Hash of CRON entries for root equivalence reporting
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
) {

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
    environment => ['SHELL=/bin/sh', ],
  }
  $crons.each | $k, $v | {
    cron { $k: * => $v }
  }

}
