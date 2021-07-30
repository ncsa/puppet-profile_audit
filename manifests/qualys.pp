# @summary Configure host to be scanned by qualys
#
# See https://wiki.ncsa.illinois.edu/display/SecOps/Qualys+Authenticated+Scanning+Host+setup
#
# @param enabled
#   Boolean to define if authenticated qualys scan enabled
#
# @param gid
#   String of the GID of the local qualys user
#
# @param group
#   String of the group name of the local qualys user
#
# @param homedir
#   String of the home directory path of the local qualys user
#
# @param ip
#   String of the IP address that the qualys user can login from
#
# @param ssh_authorized_key
#   String of the public ssh authorized key that the qualys user uses for authentication
#
# @param ssh_authorized_key_type
#   String of the key type used for the qualys user's authentication
#
# @param sshd_custom_cfg
#   Hash of additional sshd match parameters for matchblock for qualys access
#
# @param uid
#   String of the UID of the local qualys user
#
# @param user
#   String of the username of the local qualys user
#
# @param user_comment
#   String of the comment in passwd file of the local qualys user
#
# @example
#   include profile_audit::qualys
#
class profile_audit::qualys (
  Boolean            $enabled,
  String             $gid,
  String             $group,
  String             $homedir,
  String             $ip,
  Optional[ String ] $ssh_authorized_key,
  String             $ssh_authorized_key_type,
  Hash               $sshd_custom_cfg,
  String             $uid,
  String             $user,
  String             $user_comment,
) {

  # ONLY SETUP If enabled AND A ssh_authorized_key IS PROVIDED FOR QUALYS USER
  if ( $enabled and ! $ssh_authorized_key )
  {
    $notify_text = @("EOT"/)
      Qualys is enabled, but no ssh authorized key has been supplied for the \
      qualys user. A ssh authorized key must be supplied if qualys is enabled.\
      | EOT
    notify { $notify_text:
      withpath => true,
    }
  }
  elsif ( $enabled and $ssh_authorized_key )
  {

    group { $group:
      ensure => 'present',
      name   => $group,
      gid    => $gid,
    }

    user { $user:
      ensure         => 'present',
      name           => $user,
      comment        => $user_comment,
      gid            => $gid,
      home           => $homedir,
      managehome     => true,
      password       => '!!',
      purge_ssh_keys => true,
      shell          => '/bin/bash',
      uid            => $uid,
    }

    file {
      $homedir:
        ensure => 'directory',
        mode   => '0700',
      ;
      "${homedir}/.ssh":
        ensure => 'directory',
        mode   => '0700',
      ;
      "${homedir}/.ssh/authorized_keys":
        ensure => 'present',
        mode   => '0600',
      ;
      default:
        owner => $user,
        group => $group,
      ;
    }

    ssh_authorized_key { $user:
      user => $user,
      key  => $ssh_authorized_key,
      type => $ssh_authorized_key_type,
    }

    ::sshd::allow_from{ 'sshd allow qualys from qualys appliance':
      hostlist                => [ $ip ],
      users                   => [ $user ],
      groups                  => [ $group ],
      additional_match_params => $sshd_custom_cfg,
    }

    # CLEAN UP OLD VERSION OF SSHD MATCH FOR QUALYS
    $match_condition = "User ${user}"
    sshd_config_match { $match_condition :
      ensure => absent,
    }

  }

}
