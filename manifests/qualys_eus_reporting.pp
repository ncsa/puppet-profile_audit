# @summary Remove old, historical wrapper for subscription-manager to lie about enabled repos.
#   This only cleans up old files that are no longer needed.
#   See SVCPLAN-5381 & SVC-12072 for historical details.
#   Once all NCSA hosts have removed these files this class can go away.
#
# @example
#   include profile_audit::qualys_eus_reporting
class profile_audit::qualys_eus_reporting {
  $alias_ensure_parm = 'absent'

  # Remove profile alias
  file { '/etc/profile.d/qualys_eus_reporting.sh':
    ensure  => $alias_ensure_parm,
    #mode    => '0644',
    #owner   => 'root',
    #group   => 'root',
    #content => file("${module_name}/qualys_eus_reporting.sh"),
  }

  # Remove script that the alias will call
  file { '/root/scripts/qualys_eus_reporting.sh':
    ensure  => $alias_ensure_parm,
    #mode    => '0750',
    #owner   => 'root',
    #group   => 'root',
    #content => epp( "${module_name}/qualys_eus_reporting.sh.epp"),
  }
}
