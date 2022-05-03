# @summary Add wrapper for subscription-manager to lie about enabled repos (requires that qualys can sudo to root)
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

  if ($enabled) and (! $profile_audit::qualys::escalated_scans ) {
    $notify_text = @("EOT"/)
    qualys_eus_reporting is enabled but qualys::escalated_scans is not \
    you should enable qualys::escalated_scans when using qualys_eus_reporting\
    | EOT
    notify { $notify_text:
      withpath => true,
    }
  }

  if ($enabled) and (! $repos ) {
    notify { 'qualys_eus_reporting is enabled but repos is not defined':
      withpath => true,
    }
  }

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
  file { '/root/scripts/qualys_eus_reporting.sh':
    ensure  => $alias_ensure_parm,
    mode    => '0750',
    owner   => 'root',
    group   => 'root',
    content => epp( "${module_name}/qualys_eus_reporting.sh.epp"),
  }

}
