# @summary Allow qualys to sudo to root and add wrapper for subscription-manager to lie about enabled repos.
#   See SVC-12072 for details
#
# @param enabled
#   Boolean to enable/disable wrapper for subscription-manager
#
# @param repos
#   Array of hashes containing repos to add to the qualys_eus_reporting.sh script
#
# @example
#   include profile_audit::qualys_eus_reporting
class profile_audit::qualys_eus_reporting (
  Boolean     $enabled,
  Array[Hash] $repos,
){

  if ($enabled) and (! $facts['rhsm_manage_repo'] ) {
    $alias_ensure_parm = 'present'
  } else {
    $alias_ensure_parm = 'absent'
  }

  file { '/etc/profile.d/qualys_eus_reporting.sh':
    ensure  => $alias_ensure_parm,
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    content => file("${module_name}/qualys_eus_reporting.sh"),
  }

  # Create script that the alias will call
  file { '/root/qualys_eus_reporting.sh':
    ensure  => $alias_ensure_parm,
    mode    => '0750',
    owner   => 'root',
    group   => 'root',
    content => epp( "${module_name}/qualys_eus_reporting.sh.epp"),
  }

}
