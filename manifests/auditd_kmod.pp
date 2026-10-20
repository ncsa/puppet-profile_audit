# @summary Configure auditd to log kernel module operations and send logged events to syslog
#
# @param enabled
#   Whether to enable auditd kernel module logging
#
# @example
#   include profile_audit::auditd_kmod
class profile_audit::auditd_kmod (
  Boolean $enabled,
) {
  if ($enabled) {
    service { 'auditd':
      ensure => 'running',
      enable => true,
    }

    exec { 'reload-auditd-rules':
      command     => '/sbin/augenrules --load',
      refreshonly => true,
      require     => Service['auditd'],
    }

    exec { 'reload-auditd-plugins':
      command     => '/sbin/auditctl --signal reload',
      refreshonly => true,
      require     => Service['auditd'],
    }

    file { '/etc/audit/rules.d/30-auditd-kmod.rules':
      ensure => 'file',
      mode   => '0644',
      owner  => 'root',
      group  => 'root',
      source => "puppet:///modules/${module_name}/30-auditd-kmod.rules",
      notify => Exec['reload-auditd-rules'],
    }

    $selinux_enabled = $facts.dig('os', 'selinux', 'enabled')
    $seltype = $selinux_enabled ? {
      true    => 'audisp_exec_t',
      default => undef,
    }

    file { '/usr/local/bin/auditd-kmod-syslog.py':
      ensure  => 'file',
      mode    => '0755',
      owner   => 'root',
      group   => 'root',
      source  => "puppet:///modules/${module_name}/auditd-kmod-syslog.py",
      seltype => $seltype,
      notify  => Exec['reload-auditd-plugins'],
    }

    file { '/etc/audit/plugins.d/kmod-syslog.conf':
      ensure => 'file',
      mode   => '0644',
      owner  => 'root',
      group  => 'root',
      source => "puppet:///modules/${module_name}/kmod-syslog.conf",
      notify => Exec['reload-auditd-plugins'],
    }
  }
}
