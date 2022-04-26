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

  # Alias that gets added to roots .bashrc
  $bash_alias = 'function subscription-manager { /root/qualys_eus_reporting.sh "$@"; } #qualys_EUS_fake'

  if ($enabled) {
    $ensure_parm = 'present'

    exec { 'add_qualys_EUS_alias':
      path    => '/bin:/usr/bin',
      command => "sed -i \'\$a${bash_alias}\' /root/.bashrc",
      unless  => "grep \'${bash_alias}\' /root/.bashrc",
    }

  } else {
    $ensure_parm = 'absent'

    exec { 'remove_qualys_EUS_alias':
      path    => '/bin:/usr/bin',
      command => "sed -i \'\\|${bash_alias}|d\' /root/.bashrc",
      onlyif  => "grep \'${bash_alias}\' /root/.bashrc",
    }

  }

  file { '/root/qualys_eus_reporting.sh':
    ensure  => $ensure_parm,
    mode    => '0750',
    owner   => 'root',
    group   => 'root',
    content => epp( "${module_name}/qualys_eus_reporting.sh.epp"),
  }

  sudo::conf { 'qualys_scan':
    ensure   => $ensure_parm,
    priority => 10,
    content  => file("${module_name}/qualys_reporting"),
  }

  pam_access::entry { 'Allow sudo for qualys':
    user       => 'qualys',
    origin     => 'LOCAL',
    permission => '+',
    position   => '-1',
  }

}
