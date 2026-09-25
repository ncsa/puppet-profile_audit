# @summary A short summary of the purpose of this class
#
# A description of what this class does
# @param root_cron_scripts_dir
#   Directory where root cron scripts exist
#
# @example
#   include profile_audit
class profile_audit (
  String $root_cron_scripts_dir,
)  {
  include profile_audit::net_process_log
  include profile_audit::qualys
  include profile_audit::root_equivalence
  #include ::profile_audit::vetting

  file { $root_cron_scripts_dir:
    ensure =>  'directory',
  }

  # Only include qualys_eus_reporting on Redhat systems (not centos)
  case $facts['os']['name'] {
    'Redhat' : {
      include profile_audit::qualys_eus_reporting
    }
    default  : {} # do nothing
  }
}
